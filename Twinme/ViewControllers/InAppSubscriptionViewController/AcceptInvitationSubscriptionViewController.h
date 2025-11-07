/*
 *  Copyright (c) 2023 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

//
// Protocol: AcceptInvitationSubscriptionDelegate
//

@protocol AcceptInvitationSubscriptionDelegate <NSObject>

- (void)invitationSubscriptionDidFinish:(TLBaseServiceErrorCode)errorCode;

- (void)invitationSubscriptionDidCancel;

@end

#import <TwinmeCommon/AbstractTwinmeViewController.h>

@interface AcceptInvitationSubscriptionViewController : AbstractTwinmeViewController

@property (weak, nonatomic, nullable) id<AcceptInvitationSubscriptionDelegate> acceptInvitationSubscriptionDelegate;

- (void)initWithPeerTwincodeOutboundId:(nonnull NSUUID *)peerTwincodeOutboundId activationCode:(nonnull NSString *)activationCode;

- (void)showInView:(nonnull UIView *)view;

@end
