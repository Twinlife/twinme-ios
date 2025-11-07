/*
 *  Copyright (c) 2017-2020 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Thibaud David (contact@thibauddavid.com)
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

//
// Interface: UIView (GradientBackgroundColor)
//

typedef enum {
    GradientOrientationVertical,
    GradientOrientationHorizontal,
    GradientOrientationDiagonal
} GradientOrientation;

@interface UIView (GradientBackgroundColor)

- (void)setupGradientBackgroundFromColors:(NSArray *)colors opacity:(CGFloat)opacity orientation:(GradientOrientation)gradientOrientation;

- (void)setupGradientBackgroundFromColors:(NSArray *)colors;

- (void)updateGradientBounds;

- (void)updateGradientColors:(NSArray<UIColor *> *)colors;

@end
