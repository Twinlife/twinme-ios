/*
 *  Copyright (c) 2019-2020 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <TwinmeCommon/AbstractTwinmeViewController.h>

//
// Protocol: SplashScreenDelegate
//

@class SettingsSpaceViewController;

@protocol SplashScreenDelegate <NSObject>

- (void)animationDidFinish:(BOOL)isMigration;

@end

//
// Interface: SplashScreenViewController
//

@interface SplashScreenViewController : AbstractTwinmeViewController

@property (weak, nonatomic) id<SplashScreenDelegate> splashScreenDelegate;

@end
