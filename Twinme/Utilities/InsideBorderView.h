/*
 *  Copyright (c) 2018-2020 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

//
// Interface: InsideBorderView
//

@interface InsideBorderView : UIView

- (void)clearBorder;

- (void)setBorder:(UIColor *)color borderWidth:(CGFloat)borderWidth width:(CGFloat)width height:(CGFloat)height left:(bool)left right:(bool)right top:(bool)top bottom:(bool)bottom;

@end
