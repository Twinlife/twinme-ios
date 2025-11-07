/*
 *  Copyright (c) 2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

//
// Interface: UIWhatsNew
//

@interface UIWhatsNew : NSObject

@property (nonatomic, nonnull) UIImage *image;
@property (nonatomic, nonnull) NSString *message;

- (nonnull instancetype)initWithImage:(nullable UIImage *)image message:(nonnull NSString *)message;

@end
