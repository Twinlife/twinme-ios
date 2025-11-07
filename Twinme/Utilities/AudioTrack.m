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
            _trackData = [NSData dataWithContentsOfFile:dataFilePath];
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
        float sampleRate = 0;
        NSArray *formatDescription = assetTrack.formatDescriptions;
        for (unsigned int i = 0; i < [formatDescription count]; ++i) {
            CMAudioFormatDescriptionRef item = (__bridge CMAudioFormatDescriptionRef)[formatDescription objectAtIndex:i];
            const AudioStreamBasicDescription* formatDescription = CMAudioFormatDescriptionGetStreamBasicDescription(item);
            if (formatDescription) {
                channelCount = formatDescription->mChannelsPerFrame;
                sampleRate = formatDescription->mSampleRate;
            }
        }
        
        UInt32 bytesPerSample = 2 * channelCount;
        
        SInt16 maxAmplitude = 0;
        float maxSample = 0;
        float countSample = 0;
        NSMutableArray *dataSamples = [[NSMutableArray alloc] initWithCapacity:nbLines];
        float durationInSeconds = (assetReader.asset.duration.value / assetReader.asset.duration.timescale);
        UInt64 samplesPerLine = (durationInSeconds * sampleRate) / nbLines;
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
            BOOL success = [trackData writeToURL:urlToSave options:NSDataWritingAtomic error:&error];
            if (success) {
                return trackData;
            }
        }
    }
    
    return nil;
}

@end
