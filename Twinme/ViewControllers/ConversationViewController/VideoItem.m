/*
 *  Copyright (c) 2018-2021 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <Twinlife/TLConversationService.h>

#import "VideoItem.h"

#import <Utils/NSString+Utils.h>

//
// Interface: VideoItem
//

@implementation VideoItem

- (instancetype)initWithVideoDescriptor:(TLVideoDescriptor *)videoDescriptor replyToDescriptor:(TLDescriptor *)replyToDescriptor {
    
    self = [super initWithType:ItemTypeVideo descriptor:videoDescriptor replyToDescriptor:replyToDescriptor];
    
    if (self) {
        _videoDescriptor = videoDescriptor;
        self.copyAllowed = YES;
    }
    return self;
}

#pragma mark - Item

- (BOOL)isPeerItem {
    
    return NO;
}

- (BOOL)isAvailableItem {
    
    return self.videoDescriptor.isAvailable;
}

- (BOOL)isClearLocalItem {
    
    return [self getLength] == 0 && [self isAvailableItem];
}

- (int64_t)timestamp {
    
    return self.createdTimestamp;
}

- (BOOL)isFileItemExist {
    
    NSURL *url = [self getURL];
    return url && [[NSFileManager defaultManager]fileExistsAtPath:[url path]];
}

- (NSURL *)getURL {
    
    return [self.videoDescriptor getURL];
}

- (int64_t)getLength {
    
    return self.videoDescriptor.length;
}

- (NSString *)getExtension {
    
    return self.videoDescriptor.extension;
}

- (int64_t)getDuration {
    
    return self.videoDescriptor.duration;
}

- (int)getHeight {
    
    return self.videoDescriptor.height;
}

- (int)getWidth {
    
    return self.videoDescriptor.width;
}

- (NSString *)getInformation {
    
    if ([self isClearLocalItem]) {
        return TwinmeLocalizedString(@"conversation_view_controller_local_cleanup", nil);
    } else {
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
        
        if ([self getWidth] != 0 && [self getHeight] != 0) {
            [fileInfo appendString:@"\n"];
            [fileInfo appendString:[NSString stringWithFormat:@"%d x %d", [self getWidth], [self getHeight]]];
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
}

#pragma mark - NSObject

- (NSString *)description {
    
    NSMutableString *string = [NSMutableString stringWithCapacity:1024];
    [string appendString:@"VideoItem\n"];
    [self appendTo:string];
    return string;
}

@end
