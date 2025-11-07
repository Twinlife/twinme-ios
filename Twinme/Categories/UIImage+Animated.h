/*
 *  Copyright (c) 2021-2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

@import UIKit;

typedef void (^AnimatedImageCompletion)(UIImage * _Nullable image, NSURL * _Nonnull imageURL);

@interface UIImage (Animated)

+ (void)animatedImageWithURL:(nonnull NSURL *)url completion:(nonnull AnimatedImageCompletion)completion;

+ (void)animatedThumbnailWithURL:(nonnull NSURL *)url maxSize:(CGFloat)maxSize completion:(nonnull AnimatedImageCompletion)completion;

+ (BOOL)isAnimatedImage:(nonnull NSString *)file;

@end
