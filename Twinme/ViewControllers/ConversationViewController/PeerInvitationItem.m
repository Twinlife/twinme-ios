/*
 *  Copyright (c) 2018-2019 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <Twinlife/TLConversationService.h>

#import "PeerInvitationItem.h"

//
// Implementation: PeerInvitationItem
//

@implementation PeerInvitationItem

- (instancetype)initWithInvitationDescriptor:(TLInvitationDescriptor *)invitationDescriptor conversationId:(NSUUID *)conversationId {
    
    self = [super initWithType:ItemTypePeerInvitation descriptor:invitationDescriptor];
    
    if (self) {
        _invitationDescriptor = invitationDescriptor;
        _conversationId = conversationId;
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

- (void)updateTimestampsWithDescriptor:(TLDescriptor *)descriptor {
    
    // Keep the new descriptor instance.
    self.invitationDescriptor = (TLInvitationDescriptor *)descriptor;
    [super updateTimestampsWithDescriptor:descriptor];
}

#pragma mark - NSObject

- (NSString *)description {
    
    NSMutableString *string = [NSMutableString stringWithCapacity:1024];
    [string appendString:@"PeerInvitationItem\n"];
    [self appendTo:string];
    return string;
}

@end
