/*
 *  Copyright (c) 2017-2021 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Christian Jacquemot (Christian.Jacquemot@twinlife-systems.com)
 *   Chedi Baccari (Chedi.Baccari@twinlife-systems.com)
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <Twinlife/TLConversationService.h>

#import "AudioItem.h"

//
// Implementation: AudioItem
//

@implementation AudioItem

- (instancetype)initWithAudioDescriptor:(TLAudioDescriptor *)audioDescriptor replyToDescriptor:(TLDescriptor *)replyToDescriptor {
    
    self = [super initWithType:ItemTypeAudio descriptor:audioDescriptor replyToDescriptor:replyToDescriptor];
    
    if (self) {
        _audioDescriptor = audioDescriptor;
        self.copyAllowed = audioDescriptor.copyAllowed;
    }
    return self;
}

#pragma mark - Item

- (BOOL)isPeerItem {
    
    return NO;
}

- (BOOL)isAvailableItem {
    
    return self.audioDescriptor.isAvailable;
}

- (BOOL)isFileItemExist {
    
    NSURL *url = [self getURL];
    return url && [[NSFileManager defaultManager]fileExistsAtPath:[url path]];
}

- (int64_t)timestamp {
    
    return self.createdTimestamp;
}

- (NSURL *)getURL {
    
    return [self.audioDescriptor getURL];
}

- (int64_t)getLength {
    
    return self.audioDescriptor.length;
}

- (NSString *)getExtension {
    
    return self.audioDescriptor.extension;
}

- (int64_t)getDuration {
    
    return self.audioDescriptor.duration;
}

- (NSString *)getInformation {
    
    NSMutableString *fileInfo = [[NSMutableString alloc] init];
    if ([self getExtension]) {
        [fileInfo appendString:[self getExtension].uppercaseString];
        [fileInfo appendString:@"\n"];
    }
    
    if ([self getLength] > 0) {
        NSByteCountFormatter *byteCountFormatter = [[NSByteCountFormatter alloc] init];
        byteCountFormatter.countStyle = NSByteCountFormatterCountStyleFile;
        NSString *size = [byteCountFormatter stringFromByteCount:[self getLength]];
        [fileInfo appendString:size];
    }
    
    if ([self getDuration] != 0) {
        [fileInfo appendString:@"\n"];
        NSDateComponentsFormatter *dateComponentsFormatter = [[NSDateComponentsFormatter alloc] init];
        dateComponentsFormatter.zeroFormattingBehavior = NSDateComponentsFormatterZeroFormattingBehaviorDropAll;
        dateComponentsFormatter.allowedUnits = NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
        dateComponentsFormatter.unitsStyle = NSDateComponentsFormatterUnitsStyleAbbreviated;
        [fileInfo appendString:[NSString stringWithFormat:@"%@", [dateComponentsFormatter stringFromTimeInterval:[self getDuration]]]];
    }
    
    return fileInfo;
}

#pragma mark - NSObject

- (NSString *)description {
    
    NSMutableString *string = [NSMutableString stringWithCapacity:1024];
    [string appendString:@"AudioItem\n"];
    [self appendTo:string];
    return string;
}

@end
