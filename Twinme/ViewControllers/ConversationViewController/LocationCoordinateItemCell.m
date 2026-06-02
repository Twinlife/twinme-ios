/*
 *  Copyright (c) 2026 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <Twinlife/TLConversationService.h>
#import <Twinme/TLTwinmeAttributes.h>

#import <Utils/NSString+Utils.h>

#import "LocationCoordinateItemCell.h"

#import "AnnotationCell.h"
#import "AnnotationCountCell.h"

#import "LocationItem.h"
#import "ConversationViewController.h"
#import "CustomAppearance.h"
#import "DecoratedLabel.h"
#import "EphemeralView.h"
#import "UIView+Toast.h"
#import "UIColor+Hex.h"

#import <TwinmeCommon/Cache.h>
#import <TwinmeCommon/Design.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static NSString *ANNOTATION_CELL_IDENTIFIER = @"AnnotationCellIdentifier";
static NSString *ANNOTATION_COUNT_CELL_IDENTIFIER = @"AnnotationCountCellIdentifier";

//
// Interface: LocationCoordinateItemCell ()
//

@interface LocationCoordinateItemCell () <CAAnimationDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, AnnotationActionDelegate>

@property (weak, nonatomic) IBOutlet UIView *contentLocationView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentLocationViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentLocationViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentLocationViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentLocationViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentLocationViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *locationImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *locationImageViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *locationImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *locationImageViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *coordinateLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *coordinateLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *coordinateLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *locationInfoLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *locationInfoLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *locationInfoLabelBottomConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *showMapImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *showMapImageViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *showMapImageViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *showMapImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ephemeralViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ephemeralViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ephemeralViewTopConstraint;
@property (weak, nonatomic) IBOutlet EphemeralView *ephemeralView;
@property (weak, nonatomic) IBOutlet UIView *contentDeleteView;
@property (weak, nonatomic) IBOutlet UIImageView *stateImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *stateImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *stateImageViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *stateImageViewBottomConstraint;
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
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *replyActionImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *replyActionImageViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *replyActionImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *annotationCollectionViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *annotationCollectionViewWidthConstraint;
@property (weak, nonatomic) IBOutlet UICollectionView *annotationCollectionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *checkMarkViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *checkMarkViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet UIView *checkMarkView;
@property (weak, nonatomic) IBOutlet UIImageView *checkMarkImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *infoImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *infoImageViewTrailinConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *infoImageView;
@property (weak, nonatomic) IBOutlet UIView *overlayView;

@property (nonatomic) TLGeolocationDescriptor *locationDescriptor;
@property (nonatomic) CGFloat topLeftRadius;
@property (nonatomic) CGFloat topRightRadius;
@property (nonatomic) CGFloat bottomRightRadius;
@property (nonatomic) CGFloat bottomLeftRadius;
@property (nonatomic) BOOL isDeleteAnimationStarted;

@property (nonatomic) CAShapeLayer *borderLayer;
@property (nonatomic) CustomAppearance *customAppearance;

@property (nonatomic) NSTimer *updateEphemeralTimer;

@end

//
// Implementation: LocationCoordinateItemCell
//

#undef LOG_TAG
#define LOG_TAG @"LocationCoordinateItemCell"

@implementation LocationCoordinateItemCell

- (void)awakeFromNib {
    DDLogVerbose(@"%@ awakeFromNib", LOG_TAG);
    
    [super awakeFromNib];
    
    self.isDeleteAnimationStarted = NO;
    
    self.userInteractionEnabled = YES;
    self.contentView.userInteractionEnabled = YES;
    self.contentLocationView.userInteractionEnabled = YES;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UITapGestureRecognizer *tapContentGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTouchUpInsideContentView:)];
    [self.contentView addGestureRecognizer:tapContentGesture];
    
    self.contentLocationViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.contentLocationViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.contentLocationViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.contentLocationViewBottomConstraint.constant *= Design.HEIGHT_RATIO;
    self.contentLocationViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    [self.contentLocationView setBackgroundColor:Design.MAIN_COLOR];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTouchUpInsideCall:)];
    [self.contentLocationView addGestureRecognizer:tapGesture];
    
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onLongPressInsideContent:)];
    longPressGesture.delegate = self;
    [self.contentLocationView addGestureRecognizer:longPressGesture];
    [tapGesture requireGestureRecognizerToFail:longPressGesture];
    
    self.locationImageViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.locationImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.locationImageViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.locationImageView.image = [self.locationImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];

    self.coordinateLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.coordinateLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.coordinateLabel.font = Design.FONT_MEDIUM30;
    self.coordinateLabel.textColor = [UIColor whiteColor];
    
    self.locationInfoLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.locationInfoLabelBottomConstraint.constant *= Design.HEIGHT_RATIO;
    self.locationInfoLabel.font = Design.FONT_MEDIUM30;
    self.locationInfoLabel.textColor = [UIColor whiteColor];
    self.locationInfoLabel.text = TwinmeLocalizedString(@"settings_view_show_location_on_map", nil);
    
    self.showMapImageViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.showMapImageViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.showMapImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.showMapImageView.tintColor = [UIColor whiteColor];
    self.showMapImageView.image = [self.showMapImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    self.overlayView.hidden = YES;
    self.overlayView.backgroundColor = Design.BACKGROUND_COLOR_WHITE_OPACITY85;
    
    self.ephemeralViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.ephemeralViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.ephemeralViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.ephemeralView.tintColor = [UIColor blackColor];
    
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
    
    CGFloat heightPadding = Design.TEXT_HEIGHT_PADDING;
    CGFloat widthPadding = Design.TEXT_WIDTH_PADDING;
    
    self.replyLabel.font = Design.FONT_REGULAR32;
    self.replyLabel.numberOfLines = 3;
    self.replyLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.replyLabel.preferredMaxLayoutWidth = Design.MESSAGE_CELL_MAX_WIDTH;
    self.replyLabel.textColor = Design.REPLY_FONT_COLOR;
    [self.replyLabel setPaddingWithTop:heightPadding left:widthPadding bottom:heightPadding right:widthPadding];
    [self.replyLabel setDecorShadowColor:[UIColor clearColor]];
    [self.replyLabel setDecorColor:[UIColor clearColor]];
    [self.replyLabel setBorderColor:[UIColor clearColor]];
    
    self.replyToImageContentViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.replyToImageContentView.backgroundColor = Design.REPLY_BACKGROUND_COLOR;
    UITapGestureRecognizer *replyToImageContentViewTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTouchUpReplyView:)];
    [self.replyToImageContentView addGestureRecognizer:replyToImageContentViewTapGesture];
    
    self.replyImageViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.replyImageViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.replyImageViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.replyImageViewBottomConstraint.constant *= Design.HEIGHT_RATIO;
    self.replyImageViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.replyImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.replyImageView.clipsToBounds = YES;
    self.replyImageView.layer.cornerRadius = 6.0;
    
    self.contentDeleteView.hidden = YES;
    self.contentDeleteView.alpha = 1.0;
    self.contentDeleteView.backgroundColor = Design.DELETE_COLOR_RED;
    
    self.stateImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.stateImageViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.stateImageViewBottomConstraint.constant *= Design.HEIGHT_RATIO;
    self.stateImageView.layer.cornerRadius = self.stateImageViewHeightConstraint.constant * 0.5;
    self.stateImageView.clipsToBounds = YES;
    
    self.replyActionImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.replyActionImageViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
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
    
    self.infoImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.infoImageViewTrailinConstraint.constant *= Design.WIDTH_RATIO;
    
    self.infoImageView.hidden = YES;
    self.infoImageView.userInteractionEnabled = YES;
    self.infoImageView.tintColor = [UIColor orangeColor];
    
    UITapGestureRecognizer *infoTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleInfoTapGestureRecognizer:)];
    [self.infoImageView addGestureRecognizer:infoTapGesture];
    [infoTapGesture requireGestureRecognizerToFail:longPressGesture];
    
    self.overlayView.hidden = YES;
    self.overlayView.backgroundColor = Design.BACKGROUND_COLOR_WHITE_OPACITY85;
}

- (void)prepareForReuse {
    DDLogVerbose(@"%@ prepareForReuse", LOG_TAG);
    
    [super prepareForReuse];
    
    self.locationDescriptor = nil;
    self.stateImageView.image = nil;
    self.topLeftRadius = 0;
    self.topRightRadius = 0;
    self.bottomRightRadius = 0;
    self.bottomLeftRadius = 0;
    self.contentDeleteView.hidden = YES;
    self.isDeleteAnimationStarted = NO;
    self.infoImageView.hidden = YES;
    [self.contentDeleteView.layer removeAllAnimations];
}

#pragma mark - PanGestureRecognizerDelegate

- (void)onSwipeInsideContentView:(UIPanGestureRecognizer *)panGesture {
    DDLogVerbose(@"%@ onSwipeInsideContentView: %@", LOG_TAG, panGesture);
}

#pragma mark - ItemCell

- (void)bindWithItem:(Item *)item conversationViewController:(ConversationViewController *)conversationViewController {
    DDLogVerbose(@"%@ bindWithItem: %@ conversationViewController: %@", LOG_TAG, item, conversationViewController);
    
    [super bindWithItem:item conversationViewController:conversationViewController];
    
    self.customAppearance = [conversationViewController getCustomAppearance];
    
    [self.contentLocationView setBackgroundColor:[self.customAppearance getMessageBackgroundColor]];
    self.coordinateLabel.textColor = [self.customAppearance getMessageTextColor];
    self.locationInfoLabel.textColor = [self.customAppearance getMessageTextColor];
    self.locationImageView.tintColor = [self.customAppearance getMessageTextColor];
    self.showMapImageView.tintColor = [self.customAppearance getMessageTextColor];
    
    LocationItem *locationItem = (LocationItem *)item;
    self.locationDescriptor = locationItem.geolocationDescriptor;
    
    CGFloat topMargin = [conversationViewController getTopMarginWithMask:locationItem.corners & ITEM_TOP_RIGHT item:item];

    self.contentLocationViewTopConstraint.constant = [conversationViewController getTopMarginWithMask:locationItem.corners & ITEM_TOP_RIGHT item:item];
    self.contentLocationViewBottomConstraint.constant = -[conversationViewController getBottomMarginWithMask:locationItem.corners & ITEM_BOTTOM_RIGHT item:item];
    
    self.coordinateLabel.text = [locationItem getInformation];
    
    if (item.likeDescriptorAnnotations.count > 0 || item.forwarded) {
        self.annotationCollectionView.hidden = NO;
        self.annotationCollectionViewWidthConstraint.constant = [self annotationCollectionWidth];
        [self.annotationCollectionView reloadData];
    } else {
        self.annotationCollectionView.hidden = YES;
    }
    
    self.replyImageViewHeightConstraint.constant = 0;
    self.replyImageViewTopConstraint.constant = 0;
    self.replyImageViewBottomConstraint.constant = 0;
    
    CGFloat heightPadding = Design.TEXT_HEIGHT_PADDING;
    CGFloat widthPadding = Design.TEXT_WIDTH_PADDING;
    [self.replyLabel setPaddingWithTop:0 left:widthPadding bottom:0 right:widthPadding];
    
    if (locationItem.replyToDescriptor) {
        switch ([locationItem.replyToDescriptor getType]) {
            case TLDescriptorTypeObjectDescriptor: {
                self.replyView.hidden = NO;
                self.replyToImageContentView.hidden = YES;
                self.replyViewTopConstraint.constant = topMargin;
                [self.replyLabel setPaddingWithTop:heightPadding left:widthPadding bottom:heightPadding right:widthPadding];
                TLObjectDescriptor *objectDescriptor = (TLObjectDescriptor *)locationItem.replyToDescriptor;
                self.replyLabel.text = objectDescriptor.message;
                break;
            }
                
            case TLDescriptorTypeAudioDescriptor: {
                self.replyView.hidden = NO;
                self.replyToImageContentView.hidden = YES;
                self.replyViewTopConstraint.constant = topMargin;
                [self.replyLabel setPaddingWithTop:heightPadding left:widthPadding bottom:heightPadding right:widthPadding];
                self.replyLabel.text = TwinmeLocalizedString(@"conversation_view_audio_message", nil);
                break;
            }
                
            case TLDescriptorTypeGeolocationDescriptor: {
                self.replyView.hidden = NO;
                self.replyToImageContentView.hidden = YES;
                self.replyViewTopConstraint.constant = topMargin;
                [self.replyLabel setPaddingWithTop:heightPadding left:widthPadding bottom:heightPadding right:widthPadding];
                self.replyLabel.text = TwinmeLocalizedString(@"application_location", nil);
                break;
            }
                
            case TLDescriptorTypeNamedFileDescriptor: {
                self.replyView.hidden = NO;
                self.replyToImageContentView.hidden = YES;
                self.replyViewTopConstraint.constant = topMargin;
                [self.replyLabel setPaddingWithTop:heightPadding left:widthPadding bottom:heightPadding right:widthPadding];
                TLNamedFileDescriptor *namedFileDescriptor = (TLNamedFileDescriptor *)locationItem.replyToDescriptor;
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
                
                TLImageDescriptor *imageDescriptor = (TLImageDescriptor *)locationItem.replyToDescriptor;
                
                UIImage *image;
                if ([imageDescriptor hasThumbnail]) {
                    image = [imageDescriptor getThumbnailWithMaxSize:MAX(Design.REPLY_IMAGE_MAX_WIDTH, Design.REPLY_IMAGE_MAX_HEIGHT)];
                } else {
                    image = [[Cache getInstance] imageFromImageDescriptor:imageDescriptor size:CGSizeMake(Design.REPLY_IMAGE_MAX_WIDTH, Design.REPLY_IMAGE_MAX_HEIGHT)];
                }
                self.replyImageView.image = image;
                
                break;
            }
                
            case TLDescriptorTypeVideoDescriptor: {
                self.replyView.hidden = YES;
                self.replyToImageContentView.hidden = NO;
                self.replyToImageContentViewTopConstraint.constant = topMargin;
                
                self.replyImageViewHeightConstraint.constant = Design.REPLY_IMAGE_MAX_HEIGHT;
                self.replyImageViewTopConstraint.constant = Design.REPLY_VIEW_IMAGE_TOP;
                self.replyImageViewBottomConstraint.constant = Design.REPLY_VIEW_IMAGE_TOP;
                
                TLVideoDescriptor *videoDescriptor = (TLVideoDescriptor *)locationItem.replyToDescriptor;
                
                UIImage *image;
                if ([videoDescriptor hasThumbnail]) {
                    image = [videoDescriptor getThumbnailWithMaxSize:CGSizeMake(Design.REPLY_IMAGE_MAX_WIDTH, Design.REPLY_IMAGE_MAX_HEIGHT)];
                } else {
                    image = [[Cache getInstance] imageFromVideoDescriptor:videoDescriptor size:CGSizeMake(Design.REPLY_IMAGE_MAX_WIDTH, Design.REPLY_IMAGE_MAX_HEIGHT)];
                }
                self.replyImageView.image = image;
                
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
    
    self.contentDeleteView.hidden = YES;
    
    self.stateImageView.backgroundColor = [UIColor clearColor];
    self.stateImageView.tintColor = [UIColor clearColor];
    self.infoImageView.hidden = YES;
    
    int corners = locationItem.corners;
    switch (locationItem.state) {
        case ItemStateDefault:
            self.stateImageView.hidden = YES;
            [self.stateImageView.layer removeAllAnimations];
            self.stateImageView.image = nil;
            break;
            
        case ItemStateSending:
            corners &= ~ITEM_BOTTOM_RIGHT;
            self.stateImageView.hidden = NO;
            [self.stateImageView.layer removeAllAnimations];
            self.stateImageView.image = [UIImage imageNamed:@"ItemStateSending"];
            break;
            
        case ItemStateReceived:
            corners &= ~ITEM_BOTTOM_RIGHT;
            self.stateImageView.hidden = NO;
            [self.stateImageView.layer removeAllAnimations];
            self.stateImageView.image = [UIImage imageNamed:@"ItemStateReceived"];
            break;
            
        case ItemStateRead:
        case ItemStatePeerDeleted:
            corners &= ~ITEM_BOTTOM_RIGHT;
            self.stateImageView.hidden = NO;
            [self.stateImageView.layer removeAllAnimations];
            self.stateImageView.image = [conversationViewController getContactAvatarWithUUID:[locationItem peerTwincodeOutboundId]];
            if ([self.stateImageView.image isEqual:[TLTwinmeAttributes DEFAULT_GROUP_AVATAR]]) {
                self.stateImageView.backgroundColor = [UIColor colorWithHexString:Design.DEFAULT_COLOR alpha:1.0];
                self.stateImageView.tintColor = [UIColor whiteColor];
            }
            break;
            
        case ItemStateNotSent:
            corners &= ~ITEM_BOTTOM_RIGHT;
            self.stateImageView.hidden = NO;
            [self.stateImageView.layer removeAllAnimations];
            self.stateImageView.image = [UIImage imageNamed:@"ItemStateNotSent"];
            
            if (self.item.errorAnnotation && !self.isSelectItemMode) {
                self.infoImageView.hidden = NO;
            }
            
            break;
            
        case ItemStateDeleted:
            corners &= ~ITEM_BOTTOM_RIGHT;
            self.stateImageView.hidden = NO;
            [self.stateImageView.layer removeAllAnimations];
            [self startStateImageAnimation];
            self.stateImageView.image = [UIImage imageNamed:@"ItemStateDeleted"];
            break;
                        
        case ItemStateBothDeleted:
            corners &= ~ITEM_BOTTOM_RIGHT;
            self.stateImageView.hidden = NO;
            [self.stateImageView.layer removeAllAnimations];
            self.stateImageView.image = [UIImage imageNamed:@"ItemStateDeleted"];
            [self startDeleteAnimation];
            break;
    }
    
    if (self.item.isEphemeralItem) {
        self.ephemeralView.hidden = NO;
        
        if (self.updateEphemeralTimer) {
            [self.updateEphemeralTimer invalidate];
            self.updateEphemeralTimer = nil;
        }
        
        [self updateEphemeralView];
        self.updateEphemeralTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateEphemeralView) userInfo:nil repeats:YES];
    } else {
        self.ephemeralView.hidden = YES;
    }
    
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
    
    if ([conversationViewController isMenuOpen]) {
        self.overlayView.hidden = NO;
        [self.contentView bringSubviewToFront:self.overlayView];
        Item *selectedItem = [conversationViewController getSelectedItem];
        if ([selectedItem.descriptorId isEqual:self.item.descriptorId]) {
            [self.contentView bringSubviewToFront:self.replyView];
            [self.contentView bringSubviewToFront:self.replyToImageContentView];
            [self.contentView bringSubviewToFront:self.contentLocationView];
            [self.contentView bringSubviewToFront:self.ephemeralView];
            [self.contentView bringSubviewToFront:self.annotationCollectionView];
        }
    } else {
        self.overlayView.hidden = YES;
        [self.contentView bringSubviewToFront:self.contentDeleteView];
    }
    
    self.checkMarkView.hidden = !self.isSelectItemMode;
    self.checkMarkImageView.hidden = !item.selected;
    
    [self updateFont];
    [self updateColor];
    [self setNeedsDisplay];
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

    if (indexPath.row < self.item.likeDescriptorAnnotations.count) {
        AnnotationWithCount *annotation = [self.item.likeDescriptorAnnotations objectAtIndex:indexPath.row];
        return CGSizeMake([self annotationWidth:annotation], self.annotationCollectionViewHeightConstraint.constant);
    }
    
    return CGSizeZero;
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
        [annotationCell bindWithForwardedAnnotation:NO];
        return annotationCell;
    } else {
        AnnotationWithCount *descriptorAnnotation = [self.item.likeDescriptorAnnotations objectAtIndex:indexPath.row];
        if (descriptorAnnotation.count == 1) {
            AnnotationCell *annotationCell = [collectionView dequeueReusableCellWithReuseIdentifier:ANNOTATION_CELL_IDENTIFIER forIndexPath:indexPath];
            annotationCell.annotationActionDelegate = self;
            [annotationCell bindWithAnnotation:descriptorAnnotation.annotation descriptorId:self.item.descriptorId isPeerItem:NO];
            return annotationCell;
        } else {
            AnnotationCountCell *annotationCountCell = [collectionView dequeueReusableCellWithReuseIdentifier:ANNOTATION_COUNT_CELL_IDENTIFIER forIndexPath:indexPath];
            annotationCountCell.annotationActionDelegate = self;
            [annotationCountCell bindWithAnnotation:descriptorAnnotation.annotation count:descriptorAnnotation.count descriptorId:self.item.descriptorId isPeerItem:NO];
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

- (void)updateEphemeralView {
    
    if (self.item.state == ItemStateRead) {
        CGFloat timeSinceRead = ([[NSDate date] timeIntervalSince1970] * 1000) - self.item.readTimestamp;
        CGFloat percent = 1.0 - (timeSinceRead / self.item.expireTimeout);
        if (percent < 0) {
            percent = 0.0;
        } else if (percent > 1) {
            percent = 1.0;
        }
        [self.ephemeralView updateWithPercent:percent color:[UIColor blackColor] size:self.ephemeralViewHeightConstraint.constant];
    } else {
        [self.ephemeralView updateWithPercent:1.0 color:[UIColor blackColor] size:self.ephemeralViewHeightConstraint.constant];
    }
}

- (void)deleteEphemeralItem {
    DDLogVerbose(@"%@ deleteEphemeralItem", LOG_TAG);
    
    if ([self.deleteActionDelegate respondsToSelector:@selector(deleteItem:)]) {
        [self.deleteActionDelegate deleteItem:self.item];
    }
}

- (void)startDeleteAnimation {
    DDLogVerbose(@"%@ startDeleteAnimation", LOG_TAG);
    
    if (self.isDeleteAnimationStarted) {
        return;
    }
    
    self.isDeleteAnimationStarted = YES;
    
    CGFloat initialWidth = 0;
    CGFloat animationDuration = DESIGN_DELETE_ANIMATION_DURATION;
    if (self.item.deleteProgress > 0) {
        initialWidth = (self.item.deleteProgress * self.contentLocationView.frame.size.width) / 100.0;
        animationDuration = DESIGN_DELETE_ANIMATION_DURATION - ((self.item.deleteProgress * DESIGN_DELETE_ANIMATION_DURATION) / 100.0);
    }
    
    self.contentDeleteView.hidden = NO;
    CGRect contentDeleteFrame = self.contentDeleteView.frame;
    contentDeleteFrame.size.width = initialWidth;
    self.contentDeleteView.frame = contentDeleteFrame;
    contentDeleteFrame.size.width = self.contentLocationView.frame.size.width;
    
    [UIView animateWithDuration:animationDuration delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        self.contentDeleteView.frame = contentDeleteFrame;
    } completion:^(BOOL finished) {
        if (finished) {
            if ([self.deleteActionDelegate respondsToSelector:@selector(deleteItem:)]) {
                [self.deleteActionDelegate deleteItem:self.item];
            }
        }
    }];
}

- (void)startStateImageAnimation {
    DDLogVerbose(@"%@ startStateImageAnimation", LOG_TAG);
    
    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    rotationAnimation.fromValue = [NSNumber numberWithFloat:0];
    rotationAnimation.toValue = [NSNumber numberWithFloat:2*M_PI];
    rotationAnimation.duration = 0.5;
    rotationAnimation.autoreverses = NO;
    rotationAnimation.repeatCount = HUGE_VALF;
    rotationAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    [self.stateImageView.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

#pragma mark - IBActions

- (void)onTouchUpInsideCall:(UITapGestureRecognizer *)tapGesture {
    DDLogVerbose(@"%@ onTouchUpInsideCall: %@", LOG_TAG, tapGesture);
    
    if (self.isSelectItemMode) {
        if ([self.selectItemDelegate respondsToSelector:@selector(didSelectItem:)]) {
            [self.selectItemDelegate didSelectItem:self.item];
        }
        return;
    }
    
    if (![self.item isDeletedItem] && [self.locationActionDelegate respondsToSelector:@selector(openMap:)]) {
        [self.locationActionDelegate openMap:self.locationDescriptor];
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

- (void)handleInfoTapGestureRecognizer:(UITapGestureRecognizer *)tapGesture {
    DDLogVerbose(@"%@ handleInfoTapGestureRecognizer: %@", LOG_TAG, tapGesture);
    
    if ([self.infoItemDelegate respondsToSelector:@selector(didTapInfoItem:)]) {
        [self.infoItemDelegate didTapInfoItem:self.item];
    }
}

#pragma - mark UIView (UIViewRendering)

- (void)drawRect:(CGRect)rect {
    DDLogVerbose(@"%@ drawRect: %@", LOG_TAG, NSStringFromCGRect(rect));
    
    [super drawRect:rect];
    
    CGFloat width = self.contentLocationView.bounds.size.width;
    CGFloat height = self.contentLocationView.bounds.size.height;
    CGFloat radius = MIN(width / 2, height / 2);
    CGFloat topLeftRadius = MIN(self.topLeftRadius, radius);
    CGFloat topRightRadius = MIN(self.topRightRadius, radius);
    CGFloat bottomRightRadius = MIN(self.bottomRightRadius, radius);
    CGFloat bottomLeftRadius = MIN(self.bottomLeftRadius, radius);
    UIBezierPath *path = [[UIBezierPath alloc] init];
    [path moveToPoint:CGPointMake(topLeftRadius, 0)];
    [path addLineToPoint:CGPointMake(width - topRightRadius, 0)];
    [path addArcWithCenter:CGPointMake(width - topRightRadius, topRightRadius) radius:topRightRadius startAngle:-M_PI_2 endAngle:0 clockwise:YES];
    [path addLineToPoint:CGPointMake(width, height - bottomRightRadius)];
    [path addArcWithCenter:CGPointMake(width - bottomRightRadius, height - bottomRightRadius) radius:bottomRightRadius startAngle:0 endAngle:M_PI_2 clockwise:YES];
    [path addLineToPoint:CGPointMake(bottomLeftRadius, height)];
    [path addArcWithCenter:CGPointMake(bottomLeftRadius, height - bottomLeftRadius) radius:bottomLeftRadius startAngle:M_PI_2 endAngle:M_PI clockwise:YES];
    [path addLineToPoint:CGPointMake(0, topLeftRadius)];
    [path addArcWithCenter:CGPointMake(topLeftRadius, topLeftRadius) radius:topLeftRadius startAngle:M_PI endAngle:-M_PI_2 clockwise:YES];
    CAShapeLayer *mask = [CAShapeLayer layer];
    mask.path = path.CGPath;
    self.contentLocationView.layer.masksToBounds = YES;
    self.contentLocationView.layer.mask = mask;
    
    if (self.borderLayer) {
        [self.borderLayer removeFromSuperlayer];
    }
    
    self.borderLayer = [CAShapeLayer layer];
    self.borderLayer.path = mask.path;
    self.borderLayer.fillColor = [UIColor clearColor].CGColor;
    self.borderLayer.strokeColor = [self.customAppearance getMessageBorderColor].CGColor;
    self.borderLayer.lineWidth = Design.ITEM_BORDER_WIDTH;
    self.borderLayer.frame = self.contentLocationView.bounds;
    [self.contentLocationView.layer addSublayer:self.borderLayer];
    
    CAShapeLayer *maskDelete = [CAShapeLayer layer];
    maskDelete.path = path.CGPath;
    self.contentDeleteView.layer.masksToBounds = YES;
    self.contentDeleteView.layer.mask = maskDelete;
    
    width = self.replyView.bounds.size.width;
    height = self.replyView.bounds.size.height;
    radius = MIN(width / 2, height / 2);
    topLeftRadius = MIN(self.topLeftRadius, radius);
    topRightRadius = MIN(self.topRightRadius, radius);
    bottomRightRadius = MIN(self.bottomRightRadius, radius);
    bottomLeftRadius = MIN(self.bottomLeftRadius, radius);
    path = [[UIBezierPath alloc] init];
    [path moveToPoint:CGPointMake(topLeftRadius, 0)];
    [path addLineToPoint:CGPointMake(width - topRightRadius, 0)];
    [path addArcWithCenter:CGPointMake(width - topRightRadius, topRightRadius) radius:topRightRadius startAngle:-M_PI_2 endAngle:0 clockwise:YES];
    [path addLineToPoint:CGPointMake(width, height - bottomRightRadius)];
    [path addArcWithCenter:CGPointMake(width - bottomRightRadius, height - bottomRightRadius) radius:bottomRightRadius startAngle:0 endAngle:M_PI_2 clockwise:YES];
    [path addLineToPoint:CGPointMake(bottomLeftRadius, height)];
    [path addArcWithCenter:CGPointMake(bottomLeftRadius, height - bottomLeftRadius) radius:bottomLeftRadius startAngle:M_PI_2 endAngle:M_PI clockwise:YES];
    [path addLineToPoint:CGPointMake(0, topLeftRadius)];
    [path addArcWithCenter:CGPointMake(topLeftRadius, topLeftRadius) radius:topLeftRadius startAngle:M_PI endAngle:-M_PI_2 clockwise:YES];
    
    CAShapeLayer *maskReply = [CAShapeLayer layer];
    maskReply.path = path.CGPath;
    self.replyView.layer.masksToBounds = YES;
    self.replyView.layer.mask = maskReply;
    
    width = self.replyToImageContentView.bounds.size.width;
    height = self.replyToImageContentView.bounds.size.height;
    
    radius = MIN(width / 2, height / 2);
    topLeftRadius = MIN(self.topLeftRadius, radius);
    topRightRadius = MIN(self.topRightRadius, radius);
    bottomRightRadius = MIN(self.bottomRightRadius, radius);
    bottomLeftRadius = MIN(self.bottomLeftRadius, radius);
    path = [[UIBezierPath alloc] init];
    [path moveToPoint:CGPointMake(topLeftRadius, 0)];
    [path addLineToPoint:CGPointMake(width - topRightRadius, 0)];
    [path addArcWithCenter:CGPointMake(width - topRightRadius, topRightRadius) radius:topRightRadius startAngle:-M_PI_2 endAngle:0 clockwise:YES];
    [path addLineToPoint:CGPointMake(width, height - bottomRightRadius)];
    [path addArcWithCenter:CGPointMake(width - bottomRightRadius, height - bottomRightRadius) radius:bottomRightRadius startAngle:0 endAngle:M_PI_2 clockwise:YES];
    [path addLineToPoint:CGPointMake(bottomLeftRadius, height)];
    [path addArcWithCenter:CGPointMake(bottomLeftRadius, height - bottomLeftRadius) radius:bottomLeftRadius startAngle:M_PI_2 endAngle:M_PI clockwise:YES];
    [path addLineToPoint:CGPointMake(0, topLeftRadius)];
    [path addArcWithCenter:CGPointMake(topLeftRadius, topLeftRadius) radius:topLeftRadius startAngle:M_PI endAngle:-M_PI_2 clockwise:YES];
    
    CAShapeLayer *maskReplyImage = [CAShapeLayer layer];
    maskReplyImage.path = path.CGPath;
    self.replyToImageContentView.layer.masksToBounds = YES;
    self.replyToImageContentView.layer.mask = maskReplyImage;
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    self.coordinateLabel.font = Design.FONT_MEDIUM30;
    self.locationInfoLabel.font = Design.FONT_REGULAR30;
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    self.overlayView.backgroundColor = Design.BACKGROUND_COLOR_WHITE_OPACITY85;
}

@end
