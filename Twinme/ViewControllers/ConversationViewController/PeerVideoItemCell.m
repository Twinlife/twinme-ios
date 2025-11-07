/*
 *  Copyright (c) 2018-2024 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (fabrice.trescartes@twin.life)
 *   Stephane Carrez (Stephane.Carrez@twin.life)
 */

#import <CocoaLumberjack.h>

#import <Twinlife/TLConversationService.h>

#import <Twinme/TLMessage.h>
#import <Twinme/TLTwinmeAttributes.h>

#import "PeerVideoItemCell.h"

#import "AnnotationCell.h"
#import "AnnotationCountCell.h"

#import "ConversationViewController.h"

#import <Utils/NSString+Utils.h>

#import <TwinmeCommon/AsyncImageLoader.h>
#import <TwinmeCommon/AsyncVideoLoader.h>
#import <TwinmeCommon/Design.h>
#import <TwinmeCommon/Utils.h>
#import "DecoratedLabel.h"
#import "PeerVideoItem.h"
#import "EphemeralView.h"

#import "UIView+Toast.h"
#import "UIColor+Hex.h"
#import "UIView+GradientBackgroundColor.h"

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static NSString *ANNOTATION_CELL_IDENTIFIER = @"AnnotationCellIdentifier";
static NSString *ANNOTATION_COUNT_CELL_IDENTIFIER = @"AnnotationCountCellIdentifier";

//
// Interface: PeerVideoItemCell ()
//

@interface PeerVideoItemCell ()<UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, AnnotationActionDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *avatarViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *avatarViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *avatarView;
@property (weak, nonatomic) IBOutlet UIImageView *contentImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentImageViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentImageViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentImageViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentImageViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *playImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *playImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *playImageViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *playImageViewBottomConstraint;
@property (weak, nonatomic) IBOutlet UIView *placeholderView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *replyViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *replyViewBottomConstraint;
@property (weak, nonatomic) IBOutlet UIView *replyView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *replyLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *replyLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *replyLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *replyLabelBottomConstraint;
@property (weak, nonatomic) IBOutlet DecoratedLabel *replyLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *replyImageViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *replyImageViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *replyImageViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *replyImageViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *replyImageViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *replyImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *replyImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *replyToImageContentViewTopConstraint;
@property (weak, nonatomic) IBOutlet UIView *replyToImageContentView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *gradientBottomViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *gradientBottomView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *progressViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *progressViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *progressViewBottomConstraint;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UILabel *progressLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *progressLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ephemeralViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ephemeralViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet EphemeralView *ephemeralView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *replyActionImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *replyActionImageViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *replyActionImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *annotationCollectionViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *annotationCollectionViewWidthConstraint;
@property (weak, nonatomic) IBOutlet UICollectionView *annotationCollectionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *checkMarkViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *checkMarkViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet UIView *checkMarkView;
@property (weak, nonatomic) IBOutlet UIImageView *checkMarkImageView;
@property (weak, nonatomic) IBOutlet UIView *overlayView;

@property (nonatomic) TLVideoDescriptor *videoDescriptor;
@property (nonatomic) CGFloat topLeftRadius;
@property (nonatomic) CGFloat topRightRadius;
@property (nonatomic) CGFloat bottomRightRadius;
@property (nonatomic) CGFloat bottomLeftRadius;
@property (nonatomic) AsyncVideoLoader *videoLoader;
@property (nonatomic) BOOL videoWasNotAvailable;

@property (nonatomic) NSTimer *updateEphemeralTimer;

@end

//
// Implementation: PeerVideoItemCell
//

#undef LOG_TAG
#define LOG_TAG @"PeerVideoItemCell"

@implementation PeerVideoItemCell

- (void)awakeFromNib {
    DDLogVerbose(@"%@ awakeFromNib", LOG_TAG);
    
    [super awakeFromNib];
    
    self.userInteractionEnabled = YES;
    self.contentView.userInteractionEnabled = YES;
    self.contentImageView.userInteractionEnabled = YES;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.videoWasNotAvailable = NO;

    UITapGestureRecognizer *tapContentGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTouchUpInsideContentView:)];
    [self.contentView addGestureRecognizer:tapContentGesture];
    
    self.avatarViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.avatarViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.avatarView.layer.cornerRadius = self.avatarViewHeightConstraint.constant * 0.5;
    self.avatarView.layer.masksToBounds = YES;
    
    self.contentImageViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.contentImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.contentImageViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.contentImageViewBottomConstraint.constant *= Design.HEIGHT_RATIO;
    self.contentImageViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.contentImageView.isAccessibilityElement = YES;
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onLongPressInsideContent:)];
    longPressGesture.delegate = self;
    [self.contentImageView addGestureRecognizer:longPressGesture];
    
    self.playImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.playImageViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.playImageViewBottomConstraint.constant *= Design.HEIGHT_RATIO;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTouchUpInsideImage:)];
    [self.contentImageView addGestureRecognizer:tapGesture];
    [tapGesture requireGestureRecognizerToFail:longPressGesture];
    
    self.placeholderView.isAccessibilityElement = YES;
    self.placeholderView.hidden = YES;
    self.placeholderView.backgroundColor = Design.GREY_ITEM;
    self.placeholderView.clipsToBounds = YES;
    
    UITapGestureRecognizer *placeholderTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTouchUpInsideImage:)];
    [self.placeholderView addGestureRecognizer:placeholderTapGesture];
    
    UILongPressGestureRecognizer *placeholderLongPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onLongPressInsideContent:)];
    placeholderLongPressGesture.delegate = self;
    [self.placeholderView addGestureRecognizer:placeholderLongPressGesture];
    [placeholderTapGesture requireGestureRecognizerToFail:placeholderLongPressGesture];
    
    self.replyViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.replyViewBottomConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.replyView.backgroundColor = Design.REPLY_BACKGROUND_COLOR;
    
    UITapGestureRecognizer *replyViewTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTouchUpReplyView:)];
    [self.replyView addGestureRecognizer:replyViewTapGesture];
    
    UILongPressGestureRecognizer *replyViewLongPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onLongPressInsideContent:)];
    replyViewLongPressGesture.delegate = self;
    replyViewLongPressGesture.cancelsTouchesInView = NO;
    [self.replyView addGestureRecognizer:replyViewLongPressGesture];
    [replyViewTapGesture requireGestureRecognizerToFail:replyViewLongPressGesture];
    
    self.replyLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.replyLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.replyLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.replyLabelBottomConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.replyLabel.font = Design.FONT_REGULAR32;
    self.replyLabel.numberOfLines = 3;
    self.replyLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.replyLabel.preferredMaxLayoutWidth = Design.PEER_MESSAGE_CELL_MAX_WIDTH;
    self.replyLabel.textColor = Design.REPLY_FONT_COLOR;
    CGFloat heightPadding = Design.TEXT_HEIGHT_PADDING;
    CGFloat widthPadding = Design.TEXT_WIDTH_PADDING;
    [self.replyLabel setPaddingWithTop:heightPadding left:widthPadding bottom:heightPadding right:widthPadding];
    [self.replyLabel setDecorShadowColor:[UIColor clearColor]];
    [self.replyLabel setDecorColor:[UIColor clearColor]];
    [self.replyLabel setBorderColor:[UIColor clearColor]];
    
    self.replyToImageContentViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.replyToImageContentView.backgroundColor = Design.REPLY_BACKGROUND_COLOR;
    UITapGestureRecognizer *replyToImageContentViewTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTouchUpReplyView:)];
    [self.replyToImageContentView addGestureRecognizer:replyToImageContentViewTapGesture];
    
    UILongPressGestureRecognizer *replyToImageContentViewLongPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onLongPressInsideContent:)];
    replyToImageContentViewLongPressGesture.delegate = self;
    replyToImageContentViewLongPressGesture.cancelsTouchesInView = NO;
    [self.replyToImageContentView addGestureRecognizer:replyToImageContentViewLongPressGesture];
    [replyToImageContentViewTapGesture requireGestureRecognizerToFail:replyToImageContentViewLongPressGesture];
    
    self.replyImageViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.replyImageViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.replyImageViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.replyImageViewBottomConstraint.constant *= Design.HEIGHT_RATIO;
    self.replyImageViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.replyImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.replyImageView.clipsToBounds = YES;
    self.replyImageView.layer.cornerRadius = 6.0;
    
    self.gradientBottomViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    [self.gradientBottomView setupGradientBackgroundFromColors:Design.BACKGROUND_GRADIENT_COLORS_BLACK];
    self.gradientBottomView.hidden = YES;
    
    self.progressViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.progressViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.progressViewBottomConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.progressView.trackTintColor =  [UIColor whiteColor];
    self.progressView.progressTintColor = Design.MAIN_COLOR;
    self.progressView.clipsToBounds = true;
    
    if (self.progressView.subviews.count > 1) {
        self.progressView.subviews[1].clipsToBounds = true;
        self.progressView.transform = CGAffineTransformMakeScale(1.0, Design.PROGRESS_VIEW_SCALE);
    }
    
    if (self.progressView.layer.sublayers.count > 1) {
        CALayer *layer = [self.progressView.layer.sublayers objectAtIndex:1];
        layer.cornerRadius =  self.progressView.frame.size.height * 0.5;
        self.progressView.layer.cornerRadius = self.progressView.frame.size.height * 0.5;
    }
    
    self.progressLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.progressLabel.font = Design.FONT_MEDIUM26;
    self.progressLabel.textColor = [UIColor whiteColor];
    
    self.ephemeralViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.ephemeralViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.ephemeralView.tintColor = [UIColor whiteColor];
    
    self.replyActionImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.replyActionImageViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.replyActionImageView.tintColor = Design.BLACK_COLOR;
    
    self.annotationCollectionViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.annotationCollectionViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    
    UICollectionViewFlowLayout* viewFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    [viewFlowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    [viewFlowLayout setMinimumInteritemSpacing:0];
    [viewFlowLayout setMinimumLineSpacing:0];
    [viewFlowLayout setItemSize:CGSizeMake(Design.ANNOTATION_CELL_WIDTH_NORMAL, self.annotationCollectionViewHeightConstraint.constant)];
    
    [self.annotationCollectionView setCollectionViewLayout:viewFlowLayout];
    self.annotationCollectionView.dataSource = self;
    self.annotationCollectionView.delegate = self;
    self.annotationCollectionView.backgroundColor = [UIColor clearColor];
    [self.annotationCollectionView registerNib:[UINib nibWithNibName:@"AnnotationCell" bundle:nil] forCellWithReuseIdentifier:ANNOTATION_CELL_IDENTIFIER];
    [self.annotationCollectionView registerNib:[UINib nibWithNibName:@"AnnotationCountCell" bundle:nil] forCellWithReuseIdentifier:ANNOTATION_COUNT_CELL_IDENTIFIER];
    
    self.overlayView.hidden = YES;
    self.overlayView.backgroundColor = Design.BACKGROUND_COLOR_WHITE_OPACITY85;
    
    CGFloat checkMarkViewHeightConstraintConstant = self.checkMarkViewHeightConstraint.constant * Design.HEIGHT_RATIO;
    CGFloat roundedCheckMarkViewHeightConstraintConstant = ((int) (roundf(checkMarkViewHeightConstraintConstant / 2))) * 2;
         
    self.checkMarkViewHeightConstraint.constant = roundedCheckMarkViewHeightConstraintConstant;
    self.checkMarkViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    
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
    
    self.contentImageView.image = nil;
    self.videoDescriptor = nil;
    self.avatarView.hidden = YES;
    self.avatarView.image = nil;
    self.topLeftRadius = 0;
    self.topRightRadius = 0;
    self.bottomRightRadius = 0;
    self.bottomLeftRadius = 0;
    
    self.videoWasNotAvailable = NO;
    if (self.videoLoader) {
        [self.videoLoader cancel];
        self.videoLoader = nil;
    }

    self.replyView.hidden = YES;
    self.replyToImageContentView.hidden = YES;
    self.replyLabel.text = nil;
}

#pragma mark - ItemCell

- (void)bindWithItem:(Item *)item conversationViewController:(ConversationViewController *)conversationViewController asyncManager:(AsyncManager *)asyncManager {
    DDLogVerbose(@"%@ bindWithItem: %@ conversationViewController: %@", LOG_TAG, item, conversationViewController);
    
    [super bindWithItem:item conversationViewController:conversationViewController];
    
    PeerVideoItem *peerVideoItem = (PeerVideoItem *)item;
    self.videoDescriptor = peerVideoItem.videoDescriptor;
    
    CGFloat topMargin = [conversationViewController getTopMarginWithMask:peerVideoItem.corners & ITEM_TOP_LEFT item:item];
    self.contentImageViewTopConstraint.constant = topMargin;
    self.replyViewTopConstraint.constant = topMargin;
    self.contentImageViewBottomConstraint.constant = -[conversationViewController getBottomMarginWithMask:peerVideoItem.corners & ITEM_BOTTOM_LEFT item:item];
    
    if (item.likeDescriptorAnnotations.count > 0 || item.forwarded) {
        self.annotationCollectionView.hidden = NO;
        self.annotationCollectionViewWidthConstraint.constant = [self annotationCollectionWidth];
        [self.annotationCollectionView reloadData];
    } else {
        self.annotationCollectionView.hidden = YES;
    }
    
    // Use an async loader to get the video thumbnail.
    // Trigger another video loader if we don't have the thumbnail
    // because it was not available in the past but now we have it.
    if (!self.videoLoader || (!self.videoLoader.image && self.videoLoader.isFinished && self.videoWasNotAvailable && [self.videoDescriptor isAvailable])) {
        self.videoLoader = [[AsyncVideoLoader alloc] initWithItem:item videoDescriptor:self.videoDescriptor size:CGSizeMake(Design.IMAGE_CELL_MAX_WIDTH, Design.IMAGE_CELL_MAX_HEIGHT)];
        if (!self.videoLoader.image) {
            [asyncManager addItemWithAsyncLoader:self.videoLoader];
        }
    }

    UIImage *image = self.videoLoader.image;
    if (image) {
        self.placeholderView.hidden = YES;
        if (self.item.mode != ItemModeNormal) {
            CGFloat maxHeight = Design.FORWARDED_IMAGE_CELL_MAX_HEIGHT;
            if (self.item.mode == ItemModeSmallPreview) {
                maxHeight = Design.FORWARDED_SMALL_IMAGE_CELL_MAX_HEIGHT;
            }
            if (image.size.height > maxHeight) {
                self.contentImageViewHeightConstraint.constant = maxHeight;
                self.contentImageViewWidthConstraint.constant = (maxHeight / image.size.height) * image.size.width;
            } else {
                self.contentImageViewHeightConstraint.constant = self.contentImageViewWidthConstraint.constant / image.size.width * image.size.height;
            }
        } else {
            CGFloat imageWidth;
            CGFloat imageHeight;
            if (self.videoDescriptor.width > self.videoDescriptor.height) {
                imageWidth = Design.IMAGE_CELL_MAX_WIDTH;
                imageHeight = (imageWidth * self.videoDescriptor.height) / self.videoDescriptor.width;
            } else if (self.videoDescriptor.height != 0) {
                imageHeight = Design.IMAGE_CELL_MAX_HEIGHT;
                imageWidth = (imageHeight * self.videoDescriptor.width) / self.videoDescriptor.height;
            } else {
                // Avoid division by 0.
                imageWidth = Design.IMAGE_CELL_MAX_WIDTH;
                imageHeight = Design.IMAGE_CELL_MAX_HEIGHT;
            }
            
            self.contentImageViewWidthConstraint.constant = Design.IMAGE_CELL_MAX_WIDTH;
            self.contentImageViewHeightConstraint.constant = self.contentImageViewWidthConstraint.constant / imageWidth * imageHeight;
        }
        
        self.contentImageView.image = image;
    } else {
        self.placeholderView.hidden = NO;
        self.videoWasNotAvailable = YES;
        
        CGFloat imageWidth;
        CGFloat imageHeight;
        if (self.videoDescriptor.width > self.videoDescriptor.height) {
            imageWidth = Design.IMAGE_CELL_MAX_WIDTH;
            imageHeight = (imageWidth * self.videoDescriptor.height) / self.videoDescriptor.width;
        } else if (self.videoDescriptor.height != 0) {
            imageHeight = Design.IMAGE_CELL_MAX_HEIGHT;
            imageWidth = (imageHeight * self.videoDescriptor.width) / self.videoDescriptor.height;
        } else {
            // Avoid division by 0.
            imageWidth = Design.IMAGE_CELL_MAX_WIDTH;
            imageHeight = Design.IMAGE_CELL_MAX_HEIGHT;
        }
        
        self.contentImageViewHeightConstraint.constant = self.contentImageViewWidthConstraint.constant / imageWidth * imageHeight;
    }
    
    if (![peerVideoItem isAvailableItem]) {
        self.gradientBottomView.hidden = NO;
        self.progressView.hidden = NO;
        self.progressLabel.hidden = NO;
        self.ephemeralView.hidden = YES;
        float progress = [Utils uploadProgressWithPosition:self.videoDescriptor.end length:self.videoDescriptor.length];
        self.progressView.progress = progress;
        self.progressLabel.text = [NSString stringWithFormat:@"%.0f %%", progress * 100.0];
    } else {
        self.gradientBottomView.hidden = YES;
    }
    
    self.replyImageViewHeightConstraint.constant = 0;
    self.replyImageViewTopConstraint.constant = 0;
    self.replyImageViewBottomConstraint.constant = 0;
    
    CGFloat heightPadding = Design.TEXT_HEIGHT_PADDING;
    CGFloat widthPadding = Design.TEXT_WIDTH_PADDING;
    [self.replyLabel setPaddingWithTop:0 left:widthPadding bottom:0 right:widthPadding];
    
    if (peerVideoItem.replyToDescriptor) {
        switch ([peerVideoItem.replyToDescriptor getType]) {
            case TLDescriptorTypeObjectDescriptor: {
                self.replyView.hidden = NO;
                self.replyToImageContentView.hidden = YES;
                self.replyViewTopConstraint.constant = topMargin;
                [self.replyLabel setPaddingWithTop:heightPadding left:widthPadding bottom:heightPadding right:widthPadding];
                TLObjectDescriptor *objectDescriptor = (TLObjectDescriptor *)peerVideoItem.replyToDescriptor;
                self.replyLabel.text = objectDescriptor.message;
                break;
            }
                
            case TLDescriptorTypeAudioDescriptor: {
                self.replyView.hidden = NO;
                self.replyToImageContentView.hidden = YES;
                self.replyViewTopConstraint.constant = topMargin;
                [self.replyLabel setPaddingWithTop:heightPadding left:widthPadding bottom:heightPadding right:widthPadding];
                self.replyLabel.text = TwinmeLocalizedString(@"conversation_view_controller_audio_message", nil);
                break;
            }
                
            case TLDescriptorTypeNamedFileDescriptor: {
                self.replyView.hidden = NO;
                self.replyToImageContentView.hidden = YES;
                self.replyViewTopConstraint.constant = topMargin;
                [self.replyLabel setPaddingWithTop:heightPadding left:widthPadding bottom:heightPadding right:widthPadding];
                TLNamedFileDescriptor *namedFileDescriptor = (TLNamedFileDescriptor *)peerVideoItem.replyToDescriptor;
                self.replyLabel.text = namedFileDescriptor.name;
                break;
            }
                
            case TLDescriptorTypeImageDescriptor: {
                self.replyView.hidden = YES;
                self.replyToImageContentView.hidden = NO;
                self.replyToImageContentViewTopConstraint.constant = topMargin;
                
                self.replyImageViewHeightConstraint.constant = Design.REPLY_IMAGE_MAX_HEIGHT;
                self.replyImageViewTopConstraint.constant = Design.REPLY_VIEW_IMAGE_TOP;
                self.replyImageViewBottomConstraint.constant = Design.REPLY_VIEW_IMAGE_TOP;
                
                if (!self.replyImageLoader) {
                    TLImageDescriptor *imageDescriptor = (TLImageDescriptor *)peerVideoItem.replyToDescriptor;
                                        
                    self.replyImageLoader = [[AsyncImageLoader alloc] initWithItem:item imageDescriptor:imageDescriptor size:CGSizeMake(Design.REPLY_IMAGE_MAX_WIDTH, Design.REPLY_IMAGE_MAX_HEIGHT)];
                    if (!self.replyImageLoader.image) {
                        [asyncManager addItemWithAsyncLoader:self.replyImageLoader];
                    }
                }

                self.replyImageView.image = self.replyImageLoader.image;
                
                break;
            }
                
            case TLDescriptorTypeVideoDescriptor: {
                self.replyView.hidden = YES;
                self.replyToImageContentView.hidden = NO;
                self.replyToImageContentViewTopConstraint.constant = topMargin;
                
                self.replyImageViewHeightConstraint.constant = Design.REPLY_IMAGE_MAX_HEIGHT;
                self.replyImageViewTopConstraint.constant = Design.REPLY_VIEW_IMAGE_TOP;
                self.replyImageViewBottomConstraint.constant = Design.REPLY_VIEW_IMAGE_TOP;
                
                if (!self.replyVideoLoader) {
                    TLVideoDescriptor *videoDescriptor = (TLVideoDescriptor *)peerVideoItem.replyToDescriptor;
                    
                    self.replyVideoLoader = [[AsyncVideoLoader alloc] initWithItem:item videoDescriptor:videoDescriptor size:CGSizeMake(Design.REPLY_IMAGE_MAX_WIDTH, Design.REPLY_IMAGE_MAX_HEIGHT)];
                    if (!self.replyVideoLoader.image) {
                        [asyncManager addItemWithAsyncLoader:self.replyVideoLoader];
                    }
                }

                self.replyImageView.image = self.replyVideoLoader.image;
                
                break;
            }
            default:
                break;
        }
    } else {
        self.replyView.hidden = YES;
        self.replyToImageContentView.hidden = YES;
        self.replyViewTopConstraint.constant = 0;
        self.replyToImageContentViewTopConstraint.constant = 0;
    }
    
    if (self.item.isEphemeralItem && self.item.isAvailableItem) {
        self.gradientBottomView.hidden = NO;
        self.ephemeralView.hidden = NO;
        self.progressView.hidden = YES;
        self.progressLabel.hidden = YES;
        
        if (self.updateEphemeralTimer) {
            [self.updateEphemeralTimer invalidate];
            self.updateEphemeralTimer = nil;
        }
        
        [self updateEphemeralView];
        self.updateEphemeralTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateEphemeralView) userInfo:nil repeats:YES];
    }
    
    int corners = peerVideoItem.corners;
    if ([[UIApplication sharedApplication] userInterfaceLayoutDirection] == UIUserInterfaceLayoutDirectionRightToLeft) {
        self.topLeftRadius = [conversationViewController getRadiusWithMask:corners & ITEM_TOP_RIGHT];
        self.topRightRadius = [conversationViewController getRadiusWithMask:corners & ITEM_TOP_LEFT];
        self.bottomRightRadius = [conversationViewController getRadiusWithMask:corners & ITEM_BOTTOM_LEFT];
        self.bottomLeftRadius = [conversationViewController getRadiusWithMask:corners & ITEM_BOTTOM_RIGHT];
    } else {
        self.topLeftRadius = [conversationViewController getRadiusWithMask:corners & ITEM_TOP_LEFT];
        self.topRightRadius = [conversationViewController getRadiusWithMask:corners & ITEM_TOP_RIGHT];
        self.bottomRightRadius = [conversationViewController getRadiusWithMask:corners & ITEM_BOTTOM_RIGHT];
        self.bottomLeftRadius = [conversationViewController getRadiusWithMask:corners & ITEM_BOTTOM_LEFT];
    }
    
    if (peerVideoItem.visibleAvatar) {
        self.avatarView.hidden = NO;
        self.avatarView.image = [conversationViewController getContactAvatarWithUUID:item.peerTwincodeOutboundId];
        
        if ([self.avatarView.image isEqual:[TLTwinmeAttributes DEFAULT_GROUP_AVATAR]]) {
            self.avatarView.backgroundColor = [UIColor colorWithHexString:Design.DEFAULT_COLOR alpha:1.0];
            self.avatarView.tintColor = [UIColor whiteColor];
        } else {
            self.avatarView.backgroundColor = [UIColor clearColor];
            self.avatarView.tintColor = [UIColor clearColor];
        }
    } else {
        self.avatarView.hidden = YES;
        self.avatarView.image = nil;
    }
    
    if ([conversationViewController isMenuOpen]) {
        self.overlayView.hidden = NO;
        [self.contentView bringSubviewToFront:self.overlayView];
        Item *selectedItem = [conversationViewController getSelectedItem];
        if ([selectedItem.descriptorId isEqual:self.item.descriptorId]) {
            [self.contentView bringSubviewToFront:self.replyView];
            [self.contentView bringSubviewToFront:self.replyToImageContentView];
            [self.contentView bringSubviewToFront:self.contentImageView];
            [self.contentView bringSubviewToFront:self.playImageView];
            [self.contentView bringSubviewToFront:self.gradientBottomView];
            [self.contentView bringSubviewToFront:self.ephemeralView];
            [self.contentView bringSubviewToFront:self.annotationCollectionView];
        }
    } else {
        self.overlayView.hidden = YES;
    }
    
    self.checkMarkView.hidden = !self.isSelectItemMode;
    self.checkMarkImageView.hidden = !item.selected;
    
    if (self.isSelectItemMode) {
        self.avatarView.hidden = YES;
    }
    
    [self updateColor];
    [self setNeedsDisplay];
}

- (void)updateEphemeralView {
    
    if (self.item.state == ItemStateRead) {
        CGFloat timeSinceRead = ([[NSDate date] timeIntervalSince1970] * 1000) - self.item.readTimestamp;
        CGFloat percent = 1.0 - [Utils progressWithTime:timeSinceRead duration:self.item.expireTimeout];
        [self.ephemeralView updateWithPercent:percent color:[UIColor whiteColor] size:self.ephemeralViewHeightConstraint.constant];
    } else {
        [self.ephemeralView updateWithPercent:1.0 color:[UIColor whiteColor] size:self.ephemeralViewHeightConstraint.constant];
    }
}

- (void)deleteEphemeralItem {
    DDLogVerbose(@"%@ deleteEphemeralItem", LOG_TAG);
    
    if ([self.deleteActionDelegate respondsToSelector:@selector(deleteItem:)]) {
        [self.deleteActionDelegate deleteItem:self.item];
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    DDLogVerbose(@"%@ numberOfSectionsInCollectionView: %@", LOG_TAG, collectionView);
    
    return self.item.forwarded ? 2:1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    DDLogVerbose(@"%@ collectionView: %@ numberOfItemsInSection: %ld", LOG_TAG, collectionView, (long)section);
    
    if (self.item.forwarded && section == 0) {
        return 1;
    }
    return self.item.likeDescriptorAnnotations.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ collectionView: %@ layout: %@ sizeForItemAtIndexPath: %@", LOG_TAG, collectionView, collectionViewLayout, indexPath);
    
    if (self.item.forwarded && indexPath.section == 0) {
        return CGSizeMake(Design.ANNOTATION_CELL_WIDTH_NORMAL, self.annotationCollectionViewHeightConstraint.constant);
    }

    TLDescriptorAnnotation *descriptorAnnotation = [self.item.likeDescriptorAnnotations objectAtIndex:indexPath.row];
    return CGSizeMake([self annotationWidth:descriptorAnnotation], self.annotationCollectionViewHeightConstraint.constant);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    DDLogVerbose(@"%@ collectionView: %@ layout: %@ minimumLineSpacingForSectionAtIndex: %ld", LOG_TAG, collectionView, collectionViewLayout, (long)section);
    
    return 0;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(nonnull UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    DDLogVerbose(@"%@ collectionView: %@ layout: %@ referenceSizeForHeaderInSection: %ld", LOG_TAG, collectionView, collectionViewLayout, (long)section);
    
    return CGSizeMake(0, 0);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ collectionView: %@ cellForItemAtIndexPath: %@", LOG_TAG, collectionView, indexPath);
    
    if (self.item.forwarded && indexPath.section == 0) {
        AnnotationCell *annotationCell = [collectionView dequeueReusableCellWithReuseIdentifier:ANNOTATION_CELL_IDENTIFIER forIndexPath:indexPath];
        [annotationCell bindWithForwardedAnnotation:YES];
        return annotationCell;
    } else {
        TLDescriptorAnnotation *descriptorAnnotation = [self.item.likeDescriptorAnnotations objectAtIndex:indexPath.row];
        if (descriptorAnnotation.count == 1) {
            AnnotationCell *annotationCell = [collectionView dequeueReusableCellWithReuseIdentifier:ANNOTATION_CELL_IDENTIFIER forIndexPath:indexPath];
            annotationCell.annotationActionDelegate = self;
            [annotationCell bindWithAnnotation:descriptorAnnotation descriptorId:self.item.descriptorId isPeerItem:YES];
            return annotationCell;
        } else {
            AnnotationCountCell *annotationCountCell = [collectionView dequeueReusableCellWithReuseIdentifier:ANNOTATION_COUNT_CELL_IDENTIFIER forIndexPath:indexPath];
            annotationCountCell.annotationActionDelegate = self;
            [annotationCountCell bindWithAnnotation:descriptorAnnotation descriptorId:self.item.descriptorId isPeerItem:YES];
            return annotationCountCell;
        }
    }
}

#pragma mark - AnnotationActionDelegate

- (void)didTapAnnotation:(TLDescriptorId *)descriptorId {
    DDLogVerbose(@"%@ didTapAnnotation: %@", LOG_TAG, descriptorId);
    
    if ([self.reactionViewDelegate respondsToSelector:@selector(openAnnotationViewWithDescriptorId:)]) {
        [self.reactionViewDelegate openAnnotationViewWithDescriptorId:self.item.descriptorId];
    }
}

#pragma mark - IBActions

- (void)onTouchUpInsideImage:(UITapGestureRecognizer *)tapGesture {
    DDLogVerbose(@"%@ onTouchUpInsideImage: %@", LOG_TAG, tapGesture);
    
    if (self.isSelectItemMode) {
        if ([self.selectItemDelegate respondsToSelector:@selector(didSelectItem:)]) {
            [self.selectItemDelegate didSelectItem:self.item];
        }
        return;
    }
    
    if ([self.item isClearLocalItem]) {
        [[UIApplication sharedApplication].keyWindow makeToast:TwinmeLocalizedString(@"conversation_view_controller_local_cleanup", nil)];
    } else if (![self.item isDeletedItem] && [self.videoDescriptor isAvailable] && self.contentImageView.image && [self.videoActionDelegate respondsToSelector:@selector(fullscreenVideoWithVideoDescriptor:)]) {
        [self.videoActionDelegate fullscreenVideoWithVideoDescriptor:self.videoDescriptor];
    }
}

- (void)onLongPressInsideContent:(UILongPressGestureRecognizer *)longPressGesture {
    DDLogVerbose(@"%@ onLongPressInsideContent: %@", LOG_TAG, longPressGesture);
    
    if (longPressGesture.state == UIGestureRecognizerStateBegan && [self.menuActionDelegate respondsToSelector:@selector(openMenu:)]) {
        [self.menuActionDelegate openMenu:self.item];
    }
}

- (void)onTouchUpInsideContentView:(UITapGestureRecognizer *)tapGesture {
    DDLogVerbose(@"%@ onTouchUpInsideContentView: %@", LOG_TAG, tapGesture);
    
    if (self.isSelectItemMode) {
        if ([self.selectItemDelegate respondsToSelector:@selector(didSelectItem:)]) {
            [self.selectItemDelegate didSelectItem:self.item];
        }
    } else {
        if ([self.menuActionDelegate respondsToSelector:@selector(closeMenu)]) {
            [self.menuActionDelegate closeMenu];
        }
    }
}

- (void)onTouchUpReplyView:(UITapGestureRecognizer *)tapGesture {
    DDLogVerbose(@"%@ onTouchUpReplyView: %@", LOG_TAG, tapGesture);
    
    if ([self.replyItemDelegate respondsToSelector:@selector(didSelectReplyTo:)]) {
        [self.replyItemDelegate didSelectReplyTo:self.item.replyTo];
    }
}

#pragma - mark UIView (UIViewRendering)

- (void)drawRect:(CGRect)rect {
    
    [super drawRect:rect];
    
    CGFloat width = self.contentImageView.bounds.size.width;
    CGFloat height = self.contentImageView.bounds.size.height;
    CGFloat maxRadius = MIN(width / 2, height / 2);
    CGFloat topLeft = MIN(self.topLeftRadius, maxRadius);
    CGFloat topRight = MIN(self.topRightRadius, maxRadius);
    CGFloat bottomRight = MIN(self.bottomRightRadius, maxRadius);
    CGFloat bottomLeft = MIN(self.bottomLeftRadius, maxRadius);
    UIBezierPath *path = [[UIBezierPath alloc] init];
    [path moveToPoint:CGPointMake(topLeft, 0)];
    [path addLineToPoint:CGPointMake(width - topRight, 0)];
    [path addArcWithCenter:CGPointMake(width - topRight, topRight) radius:topRight startAngle:-M_PI_2 endAngle:0 clockwise:YES];
    [path addLineToPoint:CGPointMake(width, height - bottomRight)];
    [path addArcWithCenter:CGPointMake(width - bottomRight, height - bottomRight) radius:bottomRight startAngle:0 endAngle:M_PI_2 clockwise:YES];
    [path addLineToPoint:CGPointMake(bottomLeft, height)];
    [path addArcWithCenter:CGPointMake(bottomLeft, height - bottomLeft) radius:bottomLeft startAngle:M_PI_2 endAngle:M_PI clockwise:YES];
    [path addLineToPoint:CGPointMake(0, topLeft)];
    [path addArcWithCenter:CGPointMake(topLeft, topLeft) radius:topLeft startAngle:M_PI endAngle:-M_PI_2 clockwise:YES];
    CAShapeLayer *mask = [CAShapeLayer layer];
    mask.path = path.CGPath;
    self.contentImageView.layer.masksToBounds = YES;
    self.contentImageView.layer.mask = mask;
    
    CAShapeLayer *maskPlaceholder = [CAShapeLayer layer];
    maskPlaceholder.path = path.CGPath;
    self.placeholderView.layer.masksToBounds = YES;
    self.placeholderView.layer.mask = maskPlaceholder;
    
    width = self.replyView.bounds.size.width;
    height = self.replyView.bounds.size.height;
    maxRadius = MIN(width / 2, height / 2);
    topLeft = MIN(self.topLeftRadius, maxRadius);
    topRight = MIN(self.topRightRadius, maxRadius);
    bottomRight = MIN(self.bottomRightRadius, maxRadius);
    bottomLeft = MIN(self.bottomLeftRadius, maxRadius);
    path = [[UIBezierPath alloc] init];
    [path moveToPoint:CGPointMake(topLeft, 0)];
    [path addLineToPoint:CGPointMake(width - topRight, 0)];
    [path addArcWithCenter:CGPointMake(width - topRight, topRight) radius:topRight startAngle:-M_PI_2 endAngle:0 clockwise:YES];
    [path addLineToPoint:CGPointMake(width, height - bottomRight)];
    [path addArcWithCenter:CGPointMake(width - bottomRight, height - bottomRight) radius:bottomRight startAngle:0 endAngle:M_PI_2 clockwise:YES];
    [path addLineToPoint:CGPointMake(bottomLeft, height)];
    [path addArcWithCenter:CGPointMake(bottomLeft, height - bottomLeft) radius:bottomLeft startAngle:M_PI_2 endAngle:M_PI clockwise:YES];
    [path addLineToPoint:CGPointMake(0, topLeft)];
    [path addArcWithCenter:CGPointMake(topLeft, topLeft) radius:topLeft startAngle:M_PI endAngle:-M_PI_2 clockwise:YES];
    
    CAShapeLayer *maskReply = [CAShapeLayer layer];
    maskReply.path = path.CGPath;
    self.replyView.layer.masksToBounds = YES;
    self.replyView.layer.mask = maskReply;
    
    width = self.replyToImageContentView.bounds.size.width;
    height = self.replyToImageContentView.bounds.size.height;
    maxRadius = MIN(width / 2, height / 2);
    topLeft = MIN(self.topLeftRadius, maxRadius);
    topRight = MIN(self.topRightRadius, maxRadius);
    bottomRight = MIN(self.bottomRightRadius, maxRadius);
    bottomLeft = MIN(self.bottomLeftRadius, maxRadius);
    path = [[UIBezierPath alloc] init];
    [path moveToPoint:CGPointMake(topLeft, 0)];
    [path addLineToPoint:CGPointMake(width - topRight, 0)];
    [path addArcWithCenter:CGPointMake(width - topRight, topRight) radius:topRight startAngle:-M_PI_2 endAngle:0 clockwise:YES];
    [path addLineToPoint:CGPointMake(width, height - bottomRight)];
    [path addArcWithCenter:CGPointMake(width - bottomRight, height - bottomRight) radius:bottomRight startAngle:0 endAngle:M_PI_2 clockwise:YES];
    [path addLineToPoint:CGPointMake(bottomLeft, height)];
    [path addArcWithCenter:CGPointMake(bottomLeft, height - bottomLeft) radius:bottomLeft startAngle:M_PI_2 endAngle:M_PI clockwise:YES];
    [path addLineToPoint:CGPointMake(0, topLeft)];
    [path addArcWithCenter:CGPointMake(topLeft, topLeft) radius:topLeft startAngle:M_PI endAngle:-M_PI_2 clockwise:YES];
    
    CAShapeLayer *maskReplyImage = [CAShapeLayer layer];
    maskReplyImage.path = path.CGPath;
    self.replyToImageContentView.layer.masksToBounds = YES;
    self.replyToImageContentView.layer.mask = maskReplyImage;
    
    width = self.gradientBottomView.bounds.size.width;
    height = self.gradientBottomView.bounds.size.height;
    topLeft = 0;
    topRight = 0;
    path = [[UIBezierPath alloc] init];
    [path moveToPoint:CGPointMake(topLeft, 0)];
    [path addLineToPoint:CGPointMake(width - topRight, 0)];
    [path addArcWithCenter:CGPointMake(width - topRight, topRight) radius:topRight startAngle:-M_PI_2 endAngle:0 clockwise:YES];
    [path addLineToPoint:CGPointMake(width, height - bottomRight)];
    [path addArcWithCenter:CGPointMake(width - bottomRight, height - bottomRight) radius:bottomRight startAngle:0 endAngle:M_PI_2 clockwise:YES];
    [path addLineToPoint:CGPointMake(bottomLeft, height)];
    [path addArcWithCenter:CGPointMake(bottomLeft, height - bottomLeft) radius:bottomLeft startAngle:M_PI_2 endAngle:M_PI clockwise:YES];
    [path addLineToPoint:CGPointMake(0, topLeft)];
    [path addArcWithCenter:CGPointMake(topLeft, topLeft) radius:topLeft startAngle:M_PI endAngle:-M_PI_2 clockwise:YES];
    mask = [CAShapeLayer layer];
    mask.path = path.CGPath;
    self.gradientBottomView.layer.masksToBounds = YES;
    self.gradientBottomView.layer.mask = mask;
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    self.overlayView.backgroundColor = Design.BACKGROUND_COLOR_WHITE_OPACITY85;
    self.placeholderView.backgroundColor = Design.GREY_ITEM;
}

@end
