/*
 *  Copyright (c) 2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

//
// Interface: PreviewThumbnailCell
//

@class UIPreviewMedia;
@class UIPreviewFile;

@interface PreviewThumbnailCell : UICollectionViewCell

- (void)bindWithPreviewMedia:(nonnull UIPreviewMedia *)previewMedia isCurrentPreview:(BOOL)isCurrentPreview candDelete:(BOOL)canDelete;

- (void)bindWithPreviewFile:(nonnull UIPreviewFile *)previewFile isCurrentPreview:(BOOL)isCurrentPreview candDelete:(BOOL)canDelete;

@end
