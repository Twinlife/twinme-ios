/*
 *  Copyright (c) 2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

typedef enum {
    PreviewTypeImage,
    PreviewTypeVideo,
    PreviewTypeFile
} PreviewType;


//
// Interface: UIPreviewInfo
//

@interface UIPreviewInfo : NSObject

@property (nonatomic, nonnull) NSURL *url;
@property (nonatomic) PreviewType previewType;

- (BOOL)isMedia;

@end
