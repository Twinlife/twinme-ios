/*
 *  Copyright (c) 2022 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "PeerClearItem.h"
#import <Twinlife/TLConversationService.h>

//
// Interface: PeerClearItem
//

@interface PeerClearItem ()

@end

//
// Implementation: PeerClearItem
//

@implementation PeerClearItem

- (instancetype)initWithClearDescriptor:(TLClearDescriptor *)clearDescriptor {
    
    self = [super initWithType:ItemTypePeerClear descriptor:clearDescriptor];
    
    if (self) {
        _clearDescriptor = clearDescriptor;
    }
    return self;
}

#pragma mark - Item

- (BOOL)isPeerItem {
    
    return YES;
}

- (NSUUID *)peerTwincodeOutboundId {
    
    return self.clearDescriptor.descriptorId.twincodeOutboundId;
}

- (BOOL)isSamePeer:(Item *)item {
    
    return [self.peerTwincodeOutboundId isEqual:item.peerTwincodeOutboundId];
}

- (int64_t)timestamp {
    
    return self.createdTimestamp;
}

#pragma mark - NSObject

- (NSString *)description {
    
    NSMutableString *string = [NSMutableString stringWithCapacity:1024];
    [string appendString:@"PeerClearItem\n"];
    [self appendTo:string];
    return string;
}

@end
