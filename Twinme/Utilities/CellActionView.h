/*
 *  Copyright (c) 2019-2020 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

//
// Interface: CellActionView
//

@interface CellActionView : UIView

- (instancetype)initWithTitle:(NSString*)title icon:(NSString *)icon backgroundColor:(UIColor *)backgroundColor iconWidth:(float)iconWidth iconHeight:(float)iconHeight iconTopMargin:(float)iconTopMargin;

- (UIImage *)imageFromView;

@end
