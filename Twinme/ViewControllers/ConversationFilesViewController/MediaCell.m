/*
 *  Copyright (c) 2023 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import "MediaCell.h"

#import "Item.h"
#import "ImageItem.h"
#import "PeerImageItem.h"
#import "VideoItem.h"
#import "PeerVideoItem.h"

#import <TwinmeCommon/Design.h>

#import <TwinmeCommon/AsyncImageLoader.h>
#import <TwinmeCommon/AsyncVideoLoader.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static const CGFloat DESIGN_IMAGE_RADIUS = 6;
static const CGFloat DESIGN_IMAGE_MARGIN = 10;

static UIColor *DESIGN_PLACEHOLDER_COLOR;

//
// Interface: MediaCell ()
//

@interface MediaCell ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewBottomConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *placeholderImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *placeholderImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *checkMarkViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *checkMarkViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *checkMarkViewBottomConstraint;
@property (weak, nonatomic) IBOutlet UIView *checkMarkView;
@property (weak, nonatomic) IBOutlet UIImageView *checkMarkImageView;

@property (nonatomic) AsyncImageLoader *imageLoader;
@property (nonatomic) AsyncVideoLoader *videoLoader;

@end

//
// Implementation: MediaCell
//

#undef LOG_TAG
#define LOG_TAG @"MediaCell"

@implementation MediaCell

+ (void)initialize {
    DDLogVerbose(@"%@ initialize", LOG_TAG);
    
    DESIGN_PLACEHOLDER_COLOR = [UIColor colorWithRed:229./255. green:229./255. blue:229./255. alpha:1];
}

- (void)awakeFromNib {
    DDLogVerbose(@"%@ awakeFromNib", LOG_TAG);
    
    [super awakeFromNib];
        
    self.isAccessibilityElement = YES;
    self.contentView.backgroundColor = Design.WHITE_COLOR;
    
    CGFloat imageMargin = DESIGN_IMAGE_MARGIN * Design.WIDTH_RATIO;
    
    self.imageViewLeadingConstraint.constant = imageMargin;
    self.imageViewTrailingConstraint.constant = imageMargin;
    self.imageViewTopConstraint.constant = imageMargin;
    self.imageViewBottomConstraint.constant = imageMargin;
    
    self.imageView.clipsToBounds = YES;
    self.imageView.backgroundColor = DESIGN_PLACEHOLDER_COLOR;
    self.imageView.layer.cornerRadius = DESIGN_IMAGE_RADIUS;
    
    self.placeholderImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.placeholderImageView.hidden = YES;
    
    CGFloat checkMarkViewHeightConstraintConstant = self.checkMarkViewHeightConstraint.constant * Design.HEIGHT_RATIO;
    CGFloat roundedCheckMarkViewHeightConstraintConstant = ((int) (roundf(checkMarkViewHeightConstraintConstant / 2))) * 2;
         
    self.checkMarkViewHeightConstraint.constant = roundedCheckMarkViewHeightConstraintConstant;
    self.checkMarkViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.checkMarkViewBottomConstraint.constant *= Design.HEIGHT_RATIO;
    
    CALayer *checkMarkViewLayer = self.checkMarkView.layer;
    checkMarkViewLayer.cornerRadius = self.checkMarkViewHeightConstraint.constant * 0.5;
    checkMarkViewLayer.borderWidth = Design.CHECKMARK_BORDER_WIDTH;
    checkMarkViewLayer.borderColor = Design.CHECKMARK_BORDER_COLOR.CGColor;
    
    self.checkMarkView.clipsToBounds = YES;
    self.checkMarkView.hidden = YES;
    self.checkMarkView.backgroundColor = [UIColor whiteColor];
    self.checkMarkImageView.tintColor = Design.MAIN_COLOR;
}

- (void)prepareForReuse {
    DDLogVerbose(@"%@ prepareForReuse", LOG_TAG);
    
    [super prepareForReuse];
    
    if (self.imageLoader) {
        [self.imageLoader cancel];
        self.imageLoader = nil;
    }
    
    if (self.videoLoader) {
        [self.videoLoader cancel];
        self.videoLoader = nil;
    }
}

- (void)bindWithItem:(Item *)item asyncManager:(AsyncManager *)asyncManager size:(CGFloat)size isSelectable:(BOOL)isSelectable {
    DDLogVerbose(@"%@ bind", LOG_TAG);
    
    UIImage *image;
    
    if (item.type == ItemTypeVideo || item.type == ItemTypePeerVideo) {
        TLVideoDescriptor *videoDescriptor;
        if (item.isPeerItem) {
            PeerVideoItem *peerVideoItem = (PeerVideoItem *)item;
            videoDescriptor = peerVideoItem.videoDescriptor;
        } else {
            VideoItem *videoItem = (VideoItem *)item;
            videoDescriptor = videoItem.videoDescriptor;
        }
        
        // Use an async loader to get the video thumbnail.
        if (!self.videoLoader) {
            self.videoLoader = [[AsyncVideoLoader alloc] initWithItem:item videoDescriptor:videoDescriptor size:CGSizeMake(size, size)];
            if (!self.videoLoader.image) {
                [asyncManager addItemWithAsyncLoader:self.videoLoader];
            }
        }

        image = self.videoLoader.image;
        if (image) {
            self.imageView.image = image;
        }
    } else {
        TLImageDescriptor *imageDescriptor;
        if (item.isPeerItem) {
            PeerImageItem *peerImageItem = (PeerImageItem *)item;
            imageDescriptor = peerImageItem.imageDescriptor;
        } else {
            ImageItem *imageItem = (ImageItem *)item;
            imageDescriptor = imageItem.imageDescriptor;
        }
                
        // Use an async loader to get the image thumbnail.
        if (!self.imageLoader) {
            self.imageLoader = [[AsyncImageLoader alloc] initWithItem:item imageDescriptor:imageDescriptor size:CGSizeMake(size, size)];
            
            if (!self.imageLoader.image) {
                [asyncManager addItemWithAsyncLoader:self.imageLoader];
            }
        }
        image = self.imageLoader.image;
    }
    
    if (image) {
        self.imageView.image = image;
        self.placeholderImageView.hidden = YES;
    } else {
        self.imageView.image = nil;
        self.placeholderImageView.hidden = NO;
    }
    
    self.checkMarkView.hidden = !isSelectable;
    self.checkMarkImageView.hidden = !item.selected;
    
    [self updateColor];
}



- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    self.contentView.backgroundColor = Design.WHITE_COLOR;
}

@end
