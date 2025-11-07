/*
 *  Copyright (c) 2023-2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

//
// Interface: OnboardingSpaceThirdPartCell
//

@protocol OnboardingSpaceDelegate;

@interface OnboardingSpaceThirdPartCell : UICollectionViewCell

@property (weak, nonatomic) id<OnboardingSpaceDelegate> onboardingSpaceDelegate;

- (void)bind:(BOOL)fromSupportSection;

@end
