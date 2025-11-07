/*
 *  Copyright (c) 2018-2019 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "Item.h"

@class TLInvitationDescriptor;

@interface InvitationItem : Item

@property TLInvitationDescriptor *invitationDescriptor;
@property NSUUID *conversationId;

- (instancetype)initWithInvitationDescriptor:(TLInvitationDescriptor *)invitationDescriptor conversationId:(NSUUID *)conversationId;

@end
