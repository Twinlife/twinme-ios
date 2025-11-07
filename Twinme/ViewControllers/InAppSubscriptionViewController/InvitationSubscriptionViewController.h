/*
 *  Copyright (c) 2023 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <TwinmeCommon/AbstractTwinmeViewController.h>

//
// Protocol: InvitationSubscriptionDelegate
//

@protocol InvitationSubscriptionDelegate <NSObject>

- (void)invitationSubscriptionSuccess;

@end

//
// Interface: InvitationSubscriptionViewController
//

@interface InvitationSubscriptionViewController : AbstractTwinmeViewController

@property (weak, nonatomic, nullable) id<InvitationSubscriptionDelegate> invitationSubscriptionDelegate;

@end
