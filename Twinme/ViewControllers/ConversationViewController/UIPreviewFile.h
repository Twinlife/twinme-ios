/*
 *  Copyright (c) 2025-2026 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "UIPreviewInfo.h"

//
// Interface: UIPreviewFile
//

@interface UIPreviewFile : UIPreviewInfo

- (nonnull instancetype)initWithUrl:(nonnull NSURL *)url title:(nonnull NSString *)title extension:(nullable NSString *)extension icon:(nonnull UIImage *)icon fileSize:(long long)fileSize;

@property (nonatomic, nonnull) NSString *title;
@property (nonatomic, nullable) NSString *extension;
@property (nonatomic, nonnull) UIImage *icon;
@property (nonatomic, nonnull) NSString *size;

@end
