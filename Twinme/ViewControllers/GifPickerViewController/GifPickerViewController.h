/*
 *  Copyright (c) 2026 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  GifPickerViewController: full-screen GIF picker presented from the
 *  conversation "+" menu. Shows trending GIFs and recently sent GIFs, lets the
 *  user search, and (when several providers are configured) switch between
 *  Tenor and Giphy. When a GIF is chosen it is downloaded to a temporary file
 *  and handed back to the delegate, which sends it as a normal image message.
 */

#import <UIKit/UIKit.h>

@class GifPickerViewController;
@class GifItem;

NS_ASSUME_NONNULL_BEGIN

@protocol GifPickerViewControllerDelegate <NSObject>

/// Called on the main queue once the chosen GIF has been downloaded locally.
/// `localPath` points to a temporary .gif file ready to be sent.
- (void)gifPickerViewController:(GifPickerViewController *)controller
       didSelectGifWithLocalPath:(NSString *)localPath
                         gifItem:(GifItem *)gifItem;

@optional
- (void)gifPickerViewControllerDidCancel:(GifPickerViewController *)controller;

@end

@interface GifPickerViewController : UIViewController

@property (nonatomic, weak) id<GifPickerViewControllerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
