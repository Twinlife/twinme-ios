/*
 *  Copyright (c) 2018-2021 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <Twinlife/TLConversationService.h>

#import "FileItem.h"

//
// Implementation: FileItem
//

@implementation FileItem

- (instancetype)initWithNamedFileDescriptor:(TLNamedFileDescriptor *)namedFileDescriptor replyToDescriptor:(TLDescriptor *)replyToDescriptor {
    
    self = [super initWithType:ItemTypeFile descriptor:namedFileDescriptor replyToDescriptor:replyToDescriptor];
    
    if (self) {
        _namedFileDescriptor = namedFileDescriptor;
        self.copyAllowed = namedFileDescriptor.copyAllowed;
    }
    return self;
}

#pragma mark - Item

- (BOOL)isPeerItem {
    
    return NO;
}

- (BOOL)isAvailableItem {
    
    return self.namedFileDescriptor.isAvailable;
}

- (int64_t)timestamp {
    
    return self.createdTimestamp;
}

- (BOOL)isFileItemExist {
    
    NSURL *url = [self getURL];
    return url && [[NSFileManager defaultManager]fileExistsAtPath:[url path]];
}

- (NSURL *)getURL {
    
    return [self.namedFileDescriptor getURL];
}

- (NSString *)getExtension {
    
    return self.namedFileDescriptor.extension;
}

- (int64_t)getLength {
    
    return self.namedFileDescriptor.length;
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
    
    return fileInfo;
}

#pragma mark - NSObject

- (NSString *)description {
    
    NSMutableString* string = [NSMutableString stringWithCapacity:1024];
    [string appendString:@"NamedFileItem\n"];
    [self appendTo:string];
    return string;
}

@end
