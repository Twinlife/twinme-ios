/*
 *  Copyright (c) 2020 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

//
// Interface: AppearanceColorCell
//

@class UICustomColor;

@interface AppearanceColorCell : UITableViewCell

- (void)bindWithColor:(UIColor *)color nameColor:(NSString *)nameColor image:(UIImage *)image;

@end
