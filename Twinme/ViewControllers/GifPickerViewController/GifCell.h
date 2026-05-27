/*
 *  Copyright (c) 2026 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  GifCell: collection-view cell that shows an animated GIF preview.
 *  Animation is produced by the app's existing UIImage+Animated category,
 *  the same one the conversation bubbles use, so the look is consistent.
 */

#import <UIKit/UIKit.h>

@class GifItem;

NS_ASSUME_NONNULL_BEGIN

extern NSString * const GifCellReuseIdentifier;

@interface GifCell : UICollectionViewCell

- (void)configureWithGifItem:(GifItem *)gifItem;

@end

NS_ASSUME_NONNULL_END
