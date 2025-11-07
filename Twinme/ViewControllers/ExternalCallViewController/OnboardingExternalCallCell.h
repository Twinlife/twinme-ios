/*
 *  Copyright (c) 2023 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

//
// Interface: OnboardingExternalCallCell
//

@class UIOnboarding;

@interface OnboardingExternalCallCell : UICollectionViewCell

@property (weak, nonatomic) id<OnboardingExternalCallDelegate> onboardingExternalCallDelegate;

- (void)bindWithOnboarding:(UIOnboarding *)uiOnboarding fromSupportSection:(BOOL)fromSupportSection;

@end
