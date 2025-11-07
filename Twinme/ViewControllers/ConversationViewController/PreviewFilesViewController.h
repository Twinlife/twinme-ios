/*
 *  Copyright (c) 2024-2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (fabrice.trescartes@twin.life)
 */

#import "AbstractPreviewViewController.h"

//
// Interface: PreviewFilesViewController
//

@interface PreviewFilesViewController : AbstractPreviewViewController

@property (nonatomic) BOOL startWithMedia;

- (void)initWithPreviewMedia:(NSArray *)previewMedias errorPicking:(BOOL)errorPicking;

- (void)initWithImage:(NSURL *)url size:(CGSize)size;

- (void)initWithVideo:(NSURL *)url;

- (void)initWithPreviewFiles:(NSArray <NSURL *>*)previewFiles;

@end
