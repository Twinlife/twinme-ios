/*
 *  Copyright (c) 2018 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <QuickLook/QuickLook.h>

//
// Interface: PreviewItem
//

@interface PreviewItem : NSObject<QLPreviewItem>

@property(readonly, nonatomic) NSURL *previewItemURL;
@property(readonly, nonatomic) NSString *previewItemTitle;

- (instancetype)initPreviewItemWithURL:(NSURL *)url title:(NSString *)title;

@end

