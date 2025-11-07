/*
 *  Copyright (c) 2018-2024 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <Twinlife/TLConversationService.h>

#import "PeerFileItem.h"

//
// Implementation: PeerFileItem
//

@implementation PeerFileItem

- (instancetype)initWithFileDescriptor:(TLNamedFileDescriptor *)namedFileDescriptor replyToDescriptor:(TLDescriptor *)replyToDescriptor {
    
    self = [super initWithType:ItemTypePeerFile descriptor:namedFileDescriptor replyToDescriptor:replyToDescriptor];
    
    if (self) {
        _namedFileDescriptor = namedFileDescriptor;
        self.copyAllowed = namedFileDescriptor.copyAllowed;
    }
    return self;
}

#pragma mark - Item

- (BOOL)isPeerItem {
    
    return YES;
}

- (BOOL)isAvailableItem {
    
    return self.namedFileDescriptor.isAvailable;
}

- (NSUUID *)peerTwincodeOutboundId {
    
    return self.namedFileDescriptor.descriptorId.twincodeOutboundId;
}

- (BOOL)isSamePeer:(Item *)item {
    
    return [self.peerTwincodeOutboundId isEqual:item.peerTwincodeOutboundId];
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

- (int64_t)getLength {
    
    return self.namedFileDescriptor.length;
}

- (NSString *)getExtension {
    
    return self.namedFileDescriptor.extension;
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
    
    NSMutableString *string = [NSMutableString stringWithCapacity:1024];
    [string appendString:@"PeerFileItem\n"];
    [self appendTo:string];
    return string;
}

@end
