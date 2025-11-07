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
@protocol CustomColorDelegate;

@interface ColorCell : UICollectionViewCell

@property (weak, nonatomic) id<CustomColorDelegate> customColorDelegate;

- (void)bindWithColor:(UICustomColor *)customColor;

- (void)bindWithEditStyle:(BOOL)isSelected;

@end
