/*
 *  Copyright (c) 2026 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "PeerPollItem.h"

#import <Twinlife/TLConversationService.h>

//
// Implementation: PeerPollItem
//

@implementation PeerPollItem

- (instancetype)initWithPollDescriptor:(TLPollDescriptor *)pollDescriptor {
    
    self = [super initWithType:ItemTypePeerPoll descriptor:pollDescriptor replyToDescriptor:nil];
    
    if (self) {
        _pollDescriptor = pollDescriptor;
        self.copyAllowed = NO;
        [self updateVotesWithDescriptor:pollDescriptor];
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
    
    return self.pollDescriptor.descriptorId.twincodeOutboundId;
}

- (BOOL)isSamePeer:(Item *)item {
    
    return [self.peerTwincodeOutboundId isEqual:item.peerTwincodeOutboundId];
}

- (void)updateVotesWithDescriptor:(nonnull TLPollDescriptor *)pollDescriptor {
    
    self.votes = [pollDescriptor getVotes];
}

#pragma mark - NSObject

- (NSString *)description {
    
    NSMutableString* string = [NSMutableString stringWithCapacity:1024];
    [string appendString:@"PeerPollItem\n"];
    [self appendTo:string];
    return string;
}


@end
