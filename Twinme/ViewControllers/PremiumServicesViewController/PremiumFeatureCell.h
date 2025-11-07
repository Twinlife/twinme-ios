/*
 *  Copyright (c) 2023 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

@class UIPremiumFeature;

//
// Interface: PremiumServicesViewController
//

@interface PremiumFeatureCell : UICollectionViewCell

- (void)bind:(UIPremiumFeature *)premiumFeature showBorder:(BOOL)showBorder;

@end
