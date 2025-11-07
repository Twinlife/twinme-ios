/*
 *  Copyright (c) 2018 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "UIContact.h"

@class TLInvitationDescriptor;

@interface UIInvitation : UIContact

@property (nonatomic) TLInvitationDescriptor *invitationDescriptor;

- (bool)peerFailure;

@end
