/*
 *  Copyright (c) 2020-2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

//
// Interface: ColorCell
//

@class UICustomColor;

@interface ColorCell : UICollectionViewCell

- (void)bindWithColor:(UICustomColor *)customColor;

- (void)bindWithEditStyle:(BOOL)isSelected;

@end
