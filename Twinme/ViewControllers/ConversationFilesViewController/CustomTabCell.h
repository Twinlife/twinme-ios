/*
 *  Copyright (c) 2023-2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

@class UICustomTab;

//
// Interface: CustomTabCell
//

@interface CustomTabCell : UICollectionViewCell

- (void)bindWithCustomTab:(UICustomTab *)uiCustomTab mainColor:(UIColor *)mainColor textSelectedColor:(UIColor *)textSelectedColor;

@end
