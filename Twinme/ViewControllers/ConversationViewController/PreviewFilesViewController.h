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

@class UIPreviewMedia;

@interface PreviewFilesViewController : AbstractPreviewViewController

@property (weak, nonatomic) IBOutlet UIView *overlayView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;
@property (weak, nonatomic) IBOutlet UILabel *stateLabel;
@property (nonatomic) NSMutableArray *files;
@property (nonatomic) int countFilePicking;
@property (nonatomic) BOOL endFilePicking;
@property (nonatomic) BOOL pickMediaError;
@property (nonatomic) BOOL pickerExportingFile;

- (void)initWithPreviewMedia:(NSArray *)previewMedias errorPicking:(BOOL)errorPicking;

- (void)initWithImage:(NSURL *)url size:(CGSize)size;

- (void)initWithVideo:(NSURL *)url;

- (void)initWithPreviewFiles:(NSArray <NSURL *>*)previewFiles;

- (void)resizeImage:(UIPreviewMedia *)previewMedia;

@end
