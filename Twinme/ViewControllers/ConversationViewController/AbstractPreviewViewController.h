/*
 *  Copyright (c) 2024-2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (fabrice.trescartes@twin.life)
 */

#import <TwinmeCommon/AbstractTwinmeViewController.h>

//
// Interface: AbstractPreviewViewController
//

@protocol PreviewViewDelegate;

@interface AbstractPreviewViewController : AbstractTwinmeViewController

@property (weak, nonatomic) id<PreviewViewDelegate> previewViewDelegate;

@property (weak, nonatomic) IBOutlet UIView *textContainerView;
@property (weak, nonatomic) IBOutlet UITextView *messageTextView;
@property (weak, nonatomic) IBOutlet UIView *sendView;

- (void)initWithURL:(NSURL *)url;

- (void)initWithName:(NSString *)name avatar:(UIImage *)avatar certified:(BOOL)certified message:(NSString *)message;

- (void)initViews;

- (void)updateViews;

- (void)send:(BOOL)allowCopyText allowCopyFile:(BOOL)allowCopyFile timeout:(int64_t)timeout;

- (void)close;

@end
