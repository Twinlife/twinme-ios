/*
 *  Copyright (c) 2021 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 *   Stephane Carrez (Stephane.Carrez@twin.life)
 */

#import <CocoaLumberjack.h>

#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <Accelerate/Accelerate.h>

#import "ConversationViewController.h"

#import <TwinmeCommon/AudioTrack.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static const NSString * VERSION_SEPARTOR = @"\n";

//
// Interface: AudioTrack ()
//

@interface AudioTrack ()

+ (nullable NSData *)readTrack:(nonnull NSURL *)urlAsset nbLines:(int)nbLines save:(BOOL)save;

@end

//
// Implementation: AudioTrack
//

#undef LOG_TAG
#define LOG_TAG @"AudioTrack"

@implementation AudioTrack

- (nonnull instancetype)initWithURL:(nonnull NSURL *)urlAsset nbLines:(int)nbLines save:(BOOL)save {
    DDLogVerbose(@"%@ initWithURL: %@ nbLines: %d save: %d", LOG_TAG, urlAsset, nbLines, save);
    
    self = [super init];
    
    if (self) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *dataFilePath = [NSString stringWithCString:urlAsset.fileSystemRepresentation encoding:NSUTF8StringEncoding];
        dataFilePath = [dataFilePath stringByDeletingPathExtension];
        dataFilePath = [dataFilePath stringByAppendingPathExtension:@"dat"];
        
        if ([fileManager fileExistsAtPath:dataFilePath]) {
            _trackData = [AudioTrack readTrackFromFile:dataFilePath];
            if (!_trackData) {
                [fileManager removeItemAtPath:dataFilePath error:nil];
                _trackData = [AudioTrack readTrack:urlAsset nbLines:nbLines save:YES];
            }
        } else {
            _trackData = [AudioTrack readTrack:urlAsset nbLines:nbLines save:save];
        }
    }
    
    return self;
}

#pragma mark - private method

+ (nullable NSData *)readTrack:(nonnull NSURL *)urlAsset nbLines:(int)nbLines save:(BOOL)save {
    
    if (!urlAsset) {
        return nil;
    }
    
    AVURLAsset *soundTrackAsset = [[AVURLAsset alloc]initWithURL:urlAsset options:nil];
    if (!soundTrackAsset) {
        return nil;
    }
    
    AVAssetReader *assetReader = [[AVAssetReader alloc]initWithAsset:soundTrackAsset error:nil];
    AVAssetTrack *assetTrack = assetReader.asset.tracks.firstObject;
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:
                                    [NSNumber numberWithInt:kAudioFormatLinearPCM],AVFormatIDKey,
                                    [NSNumber numberWithInt:16],AVLinearPCMBitDepthKey,
                                    [NSNumber numberWithBool:NO],AVLinearPCMIsBigEndianKey,
                                    [NSNumber numberWithBool:NO],AVLinearPCMIsFloatKey,
                                    [NSNumber numberWithBool:NO],AVLinearPCMIsNonInterleaved,
                                    nil];
    
    if (assetTrack) {
        AVAssetReaderTrackOutput *trackOutput = [[AVAssetReaderTrackOutput alloc] initWithTrack:assetTrack outputSettings:outputSettings];
        [assetReader addOutput:trackOutput];
        
        UInt32 channelCount = 1;
        // float sampleRate = 0;
        NSArray *formatDescription = assetTrack.formatDescriptions;
        for (unsigned int i = 0; i < [formatDescription count]; ++i) {
            CMAudioFormatDescriptionRef item = (__bridge CMAudioFormatDescriptionRef)[formatDescription objectAtIndex:i];
            const AudioStreamBasicDescription* formatDescription = CMAudioFormatDescriptionGetStreamBasicDescription(item);
            if (formatDescription) {
                channelCount = formatDescription->mChannelsPerFrame;
                // sampleRate = formatDescription->mSampleRate;
            }
        }
        
        UInt32 bytesPerSample = 2 * channelCount;
        
        SInt16 maxAmplitude = 0;
        float maxSample = 0;
        float countSample = 0;
        NSMutableArray *dataSamples = [[NSMutableArray alloc] initWithCapacity:nbLines];
        float totalSample = [AudioTrack countSample:soundTrackAsset];
        UInt64 samplesPerLine = totalSample / nbLines;        
        [assetReader startReading];
        while (assetReader.status == AVAssetReaderStatusReading) {
            AVAssetReaderTrackOutput *trackOutput = (AVAssetReaderTrackOutput *)[assetReader.outputs objectAtIndex:0];
            CMSampleBufferRef sampleBufferRef = [trackOutput copyNextSampleBuffer];
            
            if (sampleBufferRef) {
                CMBlockBufferRef blockBufferRef = CMSampleBufferGetDataBuffer(sampleBufferRef);
                
                size_t length = CMBlockBufferGetDataLength(blockBufferRef);
                
                NSMutableData *data = [NSMutableData dataWithLength:length];
                CMBlockBufferCopyDataBytes(blockBufferRef, 0, length, data.mutableBytes);
                
                SInt16 *samples = (SInt16 *)data.mutableBytes;
                NSInteger sampleBufferCount = length / bytesPerSample;
                
                for (NSInteger i = 0; i < sampleBufferCount; i++) {
                    SInt16 leftSample = *samples++;
                    maxAmplitude = MAX(maxAmplitude, abs(leftSample));
                    maxSample = MAX(maxSample, abs(leftSample));
                    
                    SInt16 rightSample;
                    if (channelCount == 2) {
                        rightSample = *samples++;
                        maxAmplitude = MAX(maxAmplitude, abs(rightSample));
                        maxSample = MAX(maxSample, abs(leftSample));
                    }
                    
                    countSample++;
                    if (countSample > samplesPerLine) {
                        [dataSamples addObject:[NSNumber numberWithFloat:(float)maxSample]];
                        maxSample = 0;
                        countSample = 0;
                    }
                }
                
                CMSampleBufferInvalidate(sampleBufferRef);
                CFRelease(sampleBufferRef);
            }
        }
        
        if (countSample > 0 && dataSamples.count < nbLines) {
            [dataSamples addObject:[NSNumber numberWithFloat:(float)maxSample]];
        }
        
        NSMutableData *trackData = [[NSMutableData alloc] init];
        for (NSNumber *dataSample in dataSamples) {
            float value = [dataSample floatValue] / maxAmplitude;
            [trackData appendBytes:&value length:sizeof(float)];
        }
        
        // Return what we have without saving.
        if (!save) {
            return trackData;
        }
        
        if (assetReader.status == AVAssetReaderStatusCompleted) {
            NSString *dataFilePath = [urlAsset.URLByDeletingPathExtension absoluteString];
            dataFilePath = [dataFilePath stringByAppendingPathExtension:@"dat"];
            NSURL *urlToSave = [NSURL URLWithString:dataFilePath];
            NSError *error;
            
            NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
            NSString *appVersion = [NSString stringWithFormat:@"v%@", version];
            NSData *versionData = [appVersion dataUsingEncoding:NSUTF8StringEncoding];
            NSData *separtorData = [VERSION_SEPARTOR dataUsingEncoding:NSUTF8StringEncoding];
            
            NSMutableData *fileData = [NSMutableData data];
            [fileData appendData:versionData];
            [fileData appendData:separtorData];
            [fileData appendData:trackData];
            
            BOOL success = [fileData writeToURL:urlToSave options:NSDataWritingAtomic error:&error];
            if (success) {
                return trackData;
            }
        }
    }
    
    return nil;
}

+ (CGFloat)countSample:(AVURLAsset *)soundTrackAsset {
    
    UInt64 totalSample = 0;
    AVAssetReader *assetReader = [[AVAssetReader alloc]initWithAsset:soundTrackAsset error:nil];
    AVAssetTrack *assetTrack = assetReader.asset.tracks.firstObject;
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:
                                    [NSNumber numberWithInt:kAudioFormatLinearPCM],AVFormatIDKey,
                                    [NSNumber numberWithInt:16],AVLinearPCMBitDepthKey,
                                    [NSNumber numberWithBool:NO],AVLinearPCMIsBigEndianKey,
                                    [NSNumber numberWithBool:NO],AVLinearPCMIsFloatKey,
                                    [NSNumber numberWithBool:NO],AVLinearPCMIsNonInterleaved,
                                    nil];
    
    if (assetTrack) {
        AVAssetReaderTrackOutput *trackOutput = [[AVAssetReaderTrackOutput alloc] initWithTrack:assetTrack outputSettings:outputSettings];
        [assetReader addOutput:trackOutput];
        [assetReader startReading];
        while (assetReader.status == AVAssetReaderStatusReading) {
            AVAssetReaderTrackOutput *trackOutput = (AVAssetReaderTrackOutput *)[assetReader.outputs objectAtIndex:0];
            CMSampleBufferRef sampleBufferRef = [trackOutput copyNextSampleBuffer];
            
            if (sampleBufferRef) {
                CMItemCount numSamples = CMSampleBufferGetNumSamples(sampleBufferRef);
                totalSample += numSamples;
                CMSampleBufferInvalidate(sampleBufferRef);
                CFRelease(sampleBufferRef);
            }
        }
    }
    
    return totalSample;
}

+ (nullable NSData *)readTrackFromFile:(nonnull NSString *)filePath {
 
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    if (!data) {
        return nil;
    }
    
    NSData *separatorData = [VERSION_SEPARTOR dataUsingEncoding:NSUTF8StringEncoding];
    NSRange separatorRange = [data rangeOfData:separatorData options:0 range:NSMakeRange(0, data.length)];

    if (separatorRange.location == NSNotFound) {
        return nil;
    }
    
    NSData *versionData = [data subdataWithRange:NSMakeRange(0, separatorRange.location)];
    NSString *version = [[NSString alloc] initWithData:versionData encoding:NSUTF8StringEncoding];
    
    if (!version || ![version hasPrefix:@"v"]) {
        return nil;
    }
    
    NSUInteger trackStart = separatorRange.location + separatorRange.length;
    return [data subdataWithRange:NSMakeRange(trackStart, data.length - trackStart)];
}

@end
