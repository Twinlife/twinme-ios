/*
 *  Copyright (c) 2023-2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

//
// Interface: FullScreenImageCell
//

@class Item;
@class UIPreviewMedia;

@interface FullScreenImageCell : UICollectionViewCell

- (void)bindWithItem:(nonnull Item *)item;

- (void)bindWithPreviewMedia:(nonnull UIPreviewMedia *)previewMedia;

- (void)resetZoom;

@end
