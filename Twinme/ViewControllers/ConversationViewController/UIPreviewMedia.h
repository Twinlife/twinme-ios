/*
 *  Copyright (c) 2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "UIPreviewInfo.h"

//
// Interface: UIPreviewMedia
//

@interface UIPreviewMedia : UIPreviewInfo

- (nonnull instancetype)initWithUrl:(nonnull NSURL *)url path:(nonnull NSString *)path size:(CGSize)size isVideo:(BOOL)isVideo;

@property (nonatomic, nonnull) NSString *path;
@property (nonatomic) CGSize size;

@end
