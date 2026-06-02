/*
 *  Copyright (c) 2026 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "PollItem.h"

#import <Twinlife/TLConversationService.h>

//
// Implementation: PollItem
//

@implementation PollItem

- (instancetype)initWithPollDescriptor:(TLPollDescriptor *)pollDescriptor {
    
    self = [super initWithType:ItemTypePoll descriptor:pollDescriptor replyToDescriptor:nil];
    
    if (self) {
        _pollDescriptor = pollDescriptor;
        self.copyAllowed = NO;
        [self updateVotesWithDescriptor:pollDescriptor];
    }
    return self;
}

#pragma mark - Item

- (BOOL)isPeerItem {
    
    return NO;
}

- (int64_t)timestamp {
    
    return self.createdTimestamp;
}

- (void)updateVotesWithDescriptor:(nonnull TLPollDescriptor *)pollDescriptor {
    
    self.votes = [pollDescriptor getVotes];
}

#pragma mark - NSObject

- (NSString *)description {
    
    NSMutableString* string = [NSMutableString stringWithCapacity:1024];
    [string appendString:@"PollItem\n"];
    [self appendTo:string];
    return string;
}

@end
