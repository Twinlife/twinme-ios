/*
 *  Copyright (c) 2017-2021 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Christian Jacquemot (Christian.Jacquemot@twinlife-systems.com)
 *   Chedi Baccari (Chedi.Baccari@twinlife-systems.com)
 *   Thibaud David (contact@thibauddavid.com)
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <Twinlife/TLConversationService.h>

#import "ImageItem.h"

#import <Utils/NSString+Utils.h>

//
// Implementation: ImageItem
//

@implementation ImageItem

- (instancetype)initWithImageDescriptor:(TLImageDescriptor *)imageDescriptor replyToDescriptor:(TLDescriptor *)replyToDescriptor {
    
    self = [super initWithType:ItemTypeImage descriptor:imageDescriptor replyToDescriptor:replyToDescriptor];
    
    if (self) {
        _imageDescriptor = imageDescriptor;
        self.copyAllowed = imageDescriptor.copyAllowed;
    }
    return self;
}

#pragma mark - Item

- (BOOL)isPeerItem {
    
    return NO;
}

- (BOOL)isAvailableItem {
    
    return self.imageDescriptor.isAvailable;
}

- (int64_t)timestamp {
    
    return self.createdTimestamp;
}

- (BOOL)isFileItemExist {
    
    NSURL *url = [self getURL];
    return url && [[NSFileManager defaultManager]fileExistsAtPath:[url path]];
}

- (NSURL *)getURL {
    
    return [self.imageDescriptor getURL];
}

- (int64_t)getLength {
    
    return self.imageDescriptor.length;
}

- (NSString *)getExtension {
    
    return self.imageDescriptor.extension;
}

- (int)getHeight {
    
    return self.imageDescriptor.height;
}

- (int)getWidth {
    
    return self.imageDescriptor.width;
}

- (BOOL)isClearLocalItem {
    
    return [self getLength] == 0 && [self isAvailableItem];
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
        
        return fileInfo;
    }
}

#pragma mark - NSObject

- (NSString *)description {
    
    NSMutableString* string = [NSMutableString stringWithCapacity:1024];
    [string appendString:@"ImageItem\n"];
    [self appendTo:string];
    return string;
}

@end
