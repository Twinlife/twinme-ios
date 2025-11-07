/*
 *  Copyright (c) 2021 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <TwinmeCommon/AbstractTwinmeViewController.h>

//
// Protocol: LockScreenDelegate
//

@protocol LockScreenDelegate <NSObject>

- (void)unlockScreenSuccess;

@end

//
// Interface: LockScreenViewController
//

@interface LockScreenViewController : AbstractTwinmeViewController

@property (weak, nonatomic) id<LockScreenDelegate> lockScreenDelegate;

- (void)requestUnlockScreen;

@end
