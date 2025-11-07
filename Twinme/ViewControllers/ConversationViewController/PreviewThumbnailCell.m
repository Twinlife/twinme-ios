/*
 *  Copyright (c) 2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "PreviewThumbnailCell.h"

#import <ImageIO/ImageIO.h>
#import <AVFoundation/AVFoundation.h>

#import "UIPreviewMedia.h"
#import "UIPreviewFile.h"

#import <TwinmeCommon/Design.h>

//
// Interface: PreviewThumbnailCell ()
//

@interface PreviewThumbnailCell () <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fileImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *fileImageView;
@property (weak, nonatomic) IBOutlet UIView *overlayView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *trashViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *trashView;

@end

//
// Implementation: PreviewThumbnailCell
//

@implementation PreviewThumbnailCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.imageViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.imageViewBottomConstraint.constant *= Design.HEIGHT_RATIO;
    self.imageViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.imageViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.imageView.clipsToBounds = YES;
    self.imageView.layer.cornerRadius = Design.CONTAINER_RADIUS;
    
    self.fileImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.fileImageView.hidden = YES;
    
    self.overlayView.backgroundColor = Design.OVERLAY_COLOR;
    self.overlayView.clipsToBounds = YES;
    self.overlayView.layer.cornerRadius = Design.CONTAINER_RADIUS;
    self.overlayView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.overlayView.layer.borderWidth = 2;
    
    self.trashViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.trashView.image = [self.trashView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.trashView.tintColor = [UIColor whiteColor];
}

- (void)bindWithPreviewMedia:(nonnull UIPreviewMedia *)previewMedia isCurrentPreview:(BOOL)isCurrentPreview candDelete:(BOOL)canDelete {
    
    self.fileImageView.hidden = YES;
    self.imageView.hidden = NO;
    
    if (previewMedia.previewType == PreviewTypeVideo) {
        self.imageView.image = [self getVideoThumbnailWithMaxSize:previewMedia.url];
    } else {
        self.imageView.image = [self getImageThumbnailWithMaxSize:previewMedia.url];
    }
    
    if (isCurrentPreview) {
        self.trashView.hidden = !canDelete;
        self.overlayView.backgroundColor = Design.OVERLAY_COLOR;
    } else {
        self.trashView.hidden = YES;
        self.overlayView.backgroundColor = [UIColor clearColor];
    }
}

- (void)bindWithPreviewFile:(nonnull UIPreviewFile *)previewFile isCurrentPreview:(BOOL)isCurrentPreview candDelete:(BOOL)canDelete {
    
    self.fileImageView.image = previewFile.icon;
    self.fileImageView.hidden = NO;
    self.imageView.hidden = YES;
    
    if (isCurrentPreview) {
        self.trashView.hidden = !canDelete;
        self.overlayView.backgroundColor = Design.OVERLAY_COLOR;
    } else {
        self.trashView.hidden = YES;
        self.overlayView.backgroundColor = [UIColor clearColor];
    }
}

- (UIImage *)getVideoThumbnailWithMaxSize:(NSURL *)url {

    AVAsset *assetVideo = [AVAsset assetWithURL:url];
    CMTime durationVideo = [assetVideo duration];
    durationVideo.value = 0;
    AVAssetImageGenerator *thumbnailGenerator = [[AVAssetImageGenerator alloc]initWithAsset:assetVideo];
    thumbnailGenerator.appliesPreferredTrackTransform = YES;
    thumbnailGenerator.maximumSize = self.imageView.frame.size;
    CGImageRef thumbnail = [thumbnailGenerator copyCGImageAtTime:durationVideo actualTime:NULL error:NULL];
    if (thumbnail) {
        UIImage *image = [UIImage imageWithCGImage:thumbnail];
        CGImageRelease(thumbnail);
        return image;
    }
    return nil;
}

- (UIImage *)getImageThumbnailWithMaxSize:(NSURL *)url {
        
    CGFloat maxSize = self.imageView.image.size.height;
    
    CGImageSourceRef imageSource = CGImageSourceCreateWithURL((__bridge CFURLRef) url, NULL);
    if (!imageSource) {
        return nil;
    }
    
    CFStringRef keys[3];
    CFTypeRef values[3];
    CFNumberRef thumbnailSize = CFNumberCreate(NULL, kCFNumberCGFloatType, &maxSize);
    keys[0] = kCGImageSourceCreateThumbnailWithTransform;
    values[0] = (CFTypeRef)kCFBooleanTrue;
    keys[1] = kCGImageSourceCreateThumbnailFromImageAlways;
    values[1] = (CFTypeRef)kCFBooleanTrue;
    CFIndex numValues = 2;
    if (maxSize > 0) {
        numValues = 3;
        keys[2] = kCGImageSourceThumbnailMaxPixelSize;
        values[2] = (CFTypeRef)thumbnailSize;
    }
    CFDictionaryRef options = CFDictionaryCreate(NULL, (const void **)keys, (const void **)values, numValues, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    CGImageRef thumbnail = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, options);
    CFRelease(imageSource);
    CFRelease(options);
    CFRelease(thumbnailSize);
    UIImage *image = [UIImage imageWithCGImage:thumbnail];
    CGImageRelease(thumbnail);
    return image;
}


@end
