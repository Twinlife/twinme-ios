/*
 *  Copyright (c) 2026 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

//
// Interface: UIMenuSelectValueItem
//

@interface UIMenuSelectValueItem : NSObject

@property (nonatomic, nonnull) NSString *title;
@property (nonatomic, nullable) NSString *subTitle;
@property (nonatomic) CGFloat valueHeight;

- (nonnull instancetype)initWithTitle:(nonnull NSString *)title subTitle:(nullable NSString *)subTitle;

- (void)calculateValueHeightWithMaxWidth:(CGFloat)maxWidth margin:(CGFloat)margin;

@end
