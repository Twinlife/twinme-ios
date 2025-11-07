/*
 *  Copyright (c) 2022 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <Twinlife/TLConversationService.h>
#import <Twinme/TLMessage.h>

#import "PeerLinkItem.h"

//
// Interface: PeerLinkItem
//

@interface PeerLinkItem ()

@property NSUUID *twincodeOutboundId;

@end

//
// Implementation: PeerLinkItem
//

@implementation PeerLinkItem

- (instancetype)initWithObjectDescriptor:(TLObjectDescriptor *)objectDescriptor replyToDescriptor:(TLDescriptor *)replyToDescriptor url:(NSURL *)url {
    
    self = [super initWithType:ItemTypePeerLink descriptor:objectDescriptor replyToDescriptor:replyToDescriptor];
    
    if (self) {
        _content = objectDescriptor.message;
        _url = url;
        _objectDescriptor = objectDescriptor;
        _twincodeOutboundId = objectDescriptor.descriptorId.twincodeOutboundId;
        self.copyAllowed = objectDescriptor.copyAllowed;
    }
    return self;
}

#pragma mark - Item

- (BOOL)isPeerItem {
    
    return YES;
}

- (NSUUID *)peerTwincodeOutboundId {
    
    return self.twincodeOutboundId;
}

- (BOOL)isSamePeer:(Item *)item {
    
    return [self.peerTwincodeOutboundId isEqual:item.peerTwincodeOutboundId];
}

- (int64_t)timestamp {
    
    return self.createdTimestamp;
}

- (void)appendTo:(NSMutableString*)string {
    
    [super appendTo:string];
    
    [string appendFormat:@" content: %@\n", self.content];
}

#pragma mark - NSObject

- (NSString *)description {
    
    NSMutableString *string = [NSMutableString stringWithCapacity:1024];
    [string appendString:@"PeerLinkItem\n"];
    [self appendTo:string];
    return string;
}

@end
