/*
 *  Copyright (c) 2023 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

//
// Protocol: OnboardingExternalCallViewController
//

@protocol OnboardingExternalCallDelegate <NSObject>

@optional - (void)didTouchDoNotDisplayAgain;

- (void)didTouchCreateExernalCall;

@end


#import <TwinmeCommon/AbstractTwinmeViewController.h>

@interface OnboardingExternalCallViewController : AbstractTwinmeViewController

@property (weak, nonatomic) id<OnboardingExternalCallDelegate> onboardingExternalCallDelegate;

- (void)showInView:(UIViewController *)view;

@property (nonatomic) BOOL startFromSupportSection;

@end
