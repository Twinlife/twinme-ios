/*
 *  Copyright (c) 2023 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <TwinmeCommon/AbstractTwinmeViewController.h>

@interface OnboardingProfileViewController : AbstractTwinmeViewController

@property (nonatomic) BOOL startFromSupportSection;

- (void)showInView:(UIViewController*)view;

@end
