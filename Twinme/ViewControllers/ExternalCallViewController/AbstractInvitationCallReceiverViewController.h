/*
 *  Copyright (c) 2023 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <TwinmeCommon/AbstractTwinmeViewController.h>

@class TLCallReceiver;

//
// Interface: AbstractInvitationCallReceiverViewController
//

@interface AbstractInvitationCallReceiverViewController : AbstractTwinmeViewController

@property (nonatomic) TLCallReceiver *callReceiver;

- (void)initWithCallReceiver:(TLCallReceiver *)callReceiver;

- (void)initViews;

- (void)deleteCallReceiver;

@end
