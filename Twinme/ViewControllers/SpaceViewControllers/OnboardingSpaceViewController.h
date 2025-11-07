/*
 *  Copyright (c) 2023 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

//
// Protocol: OnboardingSpaceDelegate
//

@class UICustomColor;

@protocol OnboardingSpaceDelegate <NSObject>

- (void)didTouchCreateSpace;

- (void)didTouchDoNotDisplayAgain;

@end

#import <TwinmeCommon/AbstractTwinmeViewController.h>

@interface OnboardingSpaceViewController : AbstractTwinmeViewController

@property (nonatomic) BOOL startFromSupportSection;

- (void)showInView:(UIViewController*)view hideFirstPart:(BOOL)hideFirstPart;

@end
