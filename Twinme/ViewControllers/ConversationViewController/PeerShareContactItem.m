/*
 *  Copyright (c) 2026 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "PeerShareContactItem.h"

#import <Twinlife/TLConversationService.h>

//
// Implementation: PeerShareContactItem
//

@implementation PeerShareContactItem

- (instancetype)initWithContactShareDescriptor:(TLContactShareDescriptor *)contactShareDescriptor {
    
    self = [super initWithType:ItemTypePeerShareContact descriptor:contactShareDescriptor replyToDescriptor:nil];
    
    if (self) {
        _contactShareDescriptor = contactShareDescriptor;
        self.copyAllowed = NO;
    }
    return self;
}

- (instancetype)initWithTwincodeDescriptor:(TLTwincodeDescriptor *)twincodeDescriptor {
    
    self = [super initWithType:ItemTypePeerShareContact descriptor:twincodeDescriptor replyToDescriptor:nil];
    
    if (self) {
        _twincodeDescriptor = twincodeDescriptor;
        self.copyAllowed = NO;
    }
    return self;
}

#pragma mark - Item

- (BOOL)isPeerItem {
    
    return YES;
}

- (int64_t)timestamp {
    
    return self.createdTimestamp;
}

- (NSUUID *)peerTwincodeOutboundId {
    
    if (self.contactShareDescriptor) {
        return self.contactShareDescriptor.descriptorId.twincodeOutboundId;
    } else {
        return self.twincodeDescriptor.descriptorId.twincodeOutboundId;
    }
}

- (BOOL)isSamePeer:(Item *)item {
    
    return [self.peerTwincodeOutboundId isEqual:item.peerTwincodeOutboundId];
}

#pragma mark - NSObject

- (NSString *)description {
    
    NSMutableString* string = [NSMutableString stringWithCapacity:1024];
    [string appendString:@"PeerShareContactItem\n"];
    [self appendTo:string];
    return string;
}

@end
