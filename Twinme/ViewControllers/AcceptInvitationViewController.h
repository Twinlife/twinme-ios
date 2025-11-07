/*
 *  Copyright (c) 2016-2024 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Chedi Baccari (Chedi.Baccari@twinlife-systems.com)
 *   Christian Jacquemot (Christian.Jacquemot@twinlife-systems.com)
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <TwinmeCommon/AbstractTwinmeViewController.h>

//
// Protocol: AcceptInvitationDelegate
//

@protocol AcceptInvitationDelegate <NSObject>

- (void)invitationDidFinish:(nullable TLContact *)contact;

@end

//
// Interface: AcceptInvitationViewController
//

@class TLProfile;
@class TLDescriptorId;
@class TLNotification;

@interface AcceptInvitationViewController : AbstractTwinmeViewController

@property (weak, nonatomic, nullable) id<AcceptInvitationDelegate> acceptInvitationDelegate;

- (void)initWithProfile:(nullable TLProfile *)profile url:(nullable NSURL *)url descriptorId:(nullable TLDescriptorId *)descriptorId originatorId:(nullable NSUUID *)originatorId isGroup:(BOOL)isGroup notification:(nullable TLNotification *)notification popToRootViewController:(BOOL)popToRootViewController;

- (void)showInView:(nonnull UIView *)view;

@end
