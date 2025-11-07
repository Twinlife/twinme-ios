/*
 *  Copyright (c) 2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "OnboardingConfirmView.h"

//
// Interface: OnboardingConfirmView
//

@class UIPremiumFeature;

@interface OnboardingDetailView : OnboardingConfirmView

- (void)initWithPremiumFeature:(nonnull UIPremiumFeature *)premiumFeature;

@end
