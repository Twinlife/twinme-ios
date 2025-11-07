/*
 *  Copyright (c) 2016-2020 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Christian Jacquemot (Christian.Jacquemot@twinlife-systems.com)
 *   Thibaud David (contact@thibauddavid.com)
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "TTTAttributedLabel.h"

#define SelectInvitationLink @"SelectInvitationLink"

//
// Interface: DecoratedLabel
//

@interface DecoratedLabel : TTTAttributedLabel

- (void)setDecorColor:(UIColor *)decorColor;

- (void)setDecorShadowColor:(UIColor *)decorShadowColor;

- (void)setBorderColor:(UIColor *)borderColor;

- (void)setBorderWidth:(CGFloat)borderWidth;

- (void)setPaddingWithTop:(CGFloat)top left:(CGFloat)left bottom:(CGFloat)bottom right:(CGFloat)right;

- (void)setCornerRadiusWithTopLeft:(CGFloat)topLeft topRight:(CGFloat)topRight bottomRight:(CGFloat)bottomRight bottomLeft:(CGFloat)bottomLeft;

@end
