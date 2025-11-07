/*
 *  Copyright (c) 2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

//
// Interface: OnboardingDetailCell
//

@class UIPremiumFeatureDetail;

@interface OnboardingDetailCell : UITableViewCell

- (void)bindWithPremiumFeatureDetail:(nonnull UIPremiumFeatureDetail *)premiumFeatureDetail;

@end
