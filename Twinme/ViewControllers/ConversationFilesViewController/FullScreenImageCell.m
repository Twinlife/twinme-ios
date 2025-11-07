/*
 *  Copyright (c) 2023 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#include <math.h>

#import <mach/mach.h>
#import <mach/mach_host.h>

#import "FullScreenImageCell.h"

#import <Twinlife/TLConversationService.h>

#import "Item.h"
#import "ImageItem.h"
#import "PeerImageItem.h"
#import "UIPreviewMedia.h"
#import <TwinmeCommon/Design.h>

#import "UIImage+Animated.h"

//
// Interface: FullScreenImageCell ()
//

@interface FullScreenImageCell () <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;


@property (weak, nonatomic) TLImageDescriptor *imageDescriptor;

@property int scale;

@end

//
// Implementation: FullScreenImageCell
//

@implementation FullScreenImageCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.scrollView.delegate = self;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] init];
    [tapGesture addTarget:self action:@selector(doubleZoomLevel:)];
    tapGesture.numberOfTapsRequired = 2;
    
    [self.scrollView addGestureRecognizer:tapGesture];
}

- (void)bindWithItem:(Item *)item {
    
    if (item.isPeerItem) {
        PeerImageItem *peerImageItem = (PeerImageItem *)item;
        self.imageDescriptor = peerImageItem.imageDescriptor;
    } else {
        ImageItem *imageItem = (ImageItem *)item;
        self.imageDescriptor = imageItem.imageDescriptor;
    }
    
    NSURL *url = [self.imageDescriptor getURL];
    if ([UIImage isAnimatedImage:[url absoluteString]]) {
        [UIImage animatedImageWithURL:url completion:^(UIImage * _Nullable animatedImage, NSURL * _Nonnull imageUrl) {
            if ([[self.imageDescriptor getURL] isEqual:imageUrl]) {
                self.imageView.image = animatedImage;
            }
        }];
        self.scrollView.userInteractionEnabled = YES;
    } else {
        float freeBytes = [self freeMemory] * 0.25; // 25% free memory
        float maxSize = sqrt(freeBytes * 0.25);
        if (self.imageDescriptor.width < maxSize && self.imageDescriptor.height < maxSize) {
            maxSize = 0;
        }
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (strongSelf) {
                UIImage *image = [strongSelf.imageDescriptor getThumbnailWithMaxSize:maxSize];
                dispatch_async(dispatch_get_main_queue(), ^{
                    __strong typeof(weakSelf) strongSelf = weakSelf;
                    if (strongSelf) {
                        strongSelf.imageView.image = image;
                        strongSelf.scrollView.userInteractionEnabled = YES;
                    }
                });
            }
        });
    }
}

- (void)bindWithPreviewMedia:(nonnull UIPreviewMedia *)previewMedia {
    
    NSURL *url = previewMedia.url;
    if ([UIImage isAnimatedImage:[url absoluteString]]) {
        [UIImage animatedImageWithURL:url completion:^(UIImage * _Nullable animatedImage, NSURL * _Nonnull imageUrl) {
            if ([previewMedia.url isEqual:imageUrl]) {
                self.imageView.image = animatedImage;
            }
        }];
        
        self.scrollView.userInteractionEnabled = YES;
    } else {
        float widthScale = 1.0;
        float heightScale = 1.0;
        if (previewMedia.size.width > Design.DISPLAY_WIDTH) {
            widthScale =  previewMedia.size.width / Design.DISPLAY_WIDTH;
        }
        
        if (previewMedia.size.height > Design.DISPLAY_HEIGHT) {
            heightScale = previewMedia.size.height / Design.DISPLAY_HEIGHT;
        }
        
        float scale = MAX(widthScale, heightScale);
        
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (strongSelf) {
                UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:url] scale:scale];
                dispatch_async(dispatch_get_main_queue(), ^{
                    __strong typeof(weakSelf) strongSelf = weakSelf;
                    if (strongSelf) {
                        strongSelf.imageView.image = image;
                        strongSelf.scrollView.userInteractionEnabled = YES;
                    }
                });
            }
        });
    }
}

#pragma mark - Actions

- (void)doubleZoomLevel:(UITapGestureRecognizer *)tapGesture {
    
    if (self.scrollView.zoomScale > 1.0) {
        [self resetZoom];
    } else {
        CGPoint centerPoint = [tapGesture locationInView:self.imageView];
        CGFloat zoomLevel = MIN(self.scrollView.maximumZoomScale, self.scrollView.zoomScale * 2);
        CGFloat width = self.scrollView.frame.size.width / zoomLevel;
        CGFloat height = self.scrollView.frame.size.height / zoomLevel;
        [self.scrollView zoomToRect:CGRectMake(centerPoint.x - width * 0.5, centerPoint.y - height * 0.5, width, height) animated:YES];
    }
}

- (void)resetZoom {
    
    [self.scrollView setZoomScale:1 animated:YES];
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    
    return self.imageView;
}

- (long)freeMemory {
    
    mach_port_t host_port = mach_host_self();
    mach_msg_type_number_t host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
    vm_size_t pagesize;
    vm_statistics_data_t vm_stat;
    
    host_page_size(host_port, &pagesize);
    if (host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size) != KERN_SUCCESS) {
        NSLog(@"Failed to fetch vm statistics");
        return 0;
    }
    
    return vm_stat.free_count * pagesize;
}

@end
