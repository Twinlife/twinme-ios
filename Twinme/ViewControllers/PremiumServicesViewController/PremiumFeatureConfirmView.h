/*
 *  Copyright (c) 2024-2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "AbstractConfirmView.h"

@class UIPremiumFeature;

//
// Interface: PremiumFeatureConfirmView
//

@interface PremiumFeatureConfirmView : AbstractConfirmView

- (void)initWithPremiumFeature:(nonnull UIPremiumFeature *)premiumFeature parentViewController:(nonnull UIViewController *)parentViewController;

@end
