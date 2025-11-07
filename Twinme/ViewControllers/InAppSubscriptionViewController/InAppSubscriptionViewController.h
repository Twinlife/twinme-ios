/*
 *  Copyright (c) 2022 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <TwinmeCommon/AbstractTwinmeViewController.h>

//
// Protocol: InAppSubscriptionViewControllerDelegate
//

@class InAppSubscriptionViewControllerDelegate;

@protocol InAppSubscriptionViewControllerDelegate <NSObject>

- (void)onSubscribeSuccess;

@end

//
// Interface: InAppSubscriptionViewController
//

@interface InAppSubscriptionViewController : AbstractTwinmeViewController

@property (weak, nonatomic) id<InAppSubscriptionViewControllerDelegate> inAppSubscriptionViewControllerDelegate;

@end
