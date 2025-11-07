/*
 *  Copyright (c) 2018-2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

//
// Interface: PreviewFileCell
//

@class UIPreviewFile;

@interface PreviewFileCell : UICollectionViewCell

- (void)bind:(UIPreviewFile *)previewFile;

@end
