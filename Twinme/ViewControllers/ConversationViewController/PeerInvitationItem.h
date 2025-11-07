/*
 *  Copyright (c) 2018-2019 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "Item.h"

//
// Interface: PeerInvitationItem
//

@interface PeerInvitationItem : Item

@property TLInvitationDescriptor *invitationDescriptor;
@property NSUUID *conversationId;

- (instancetype)initWithInvitationDescriptor:(TLInvitationDescriptor *)invitationDescriptor conversationId:(NSUUID *)conversationId;

@end
