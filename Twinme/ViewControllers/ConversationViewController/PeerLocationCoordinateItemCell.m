/*
 *  Copyright (c) 2026 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (fabrice.trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <Twinme/TLTwinmeAttributes.h>
#import <Twinlife/TLConversationService.h>

#import "PeerLocationCoordinateItemCell.h"

#import "ConversationViewController.h"

#import "CustomAppearance.h"

#import <TwinmeCommon/Cache.h>
#import <TwinmeCommon/Design.h>
#import <TwinmeCommon/Utils.h>

#import "AnnotationCell.h"
#import "AnnotationCountCell.h"

#import "PeerLocationItem.h"
#import "UIColor+Hex.h"

#import "EphemeralView.h"
#import "DecoratedLabel.h"

#import <Utils/NSString+Utils.h>


#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static NSString *ANNOTATION_CELL_IDENTIFIER = @"AnnotationCellIdentifier";
static NSString *ANNOTATION_COUNT_CELL_IDENTIFIER = @"AnnotationCountCellIdentifier";

//
// Interface: PeerLocationCoordinateItemCell ()
//

@interface PeerLocationCoordinateItemCell () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, AnnotationActionDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *avatarViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *avatarViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *avatarView;
@property (weak, nonatomic) IBOutlet UIView *contentLocationView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentLocationViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentLocationViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentLocationViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentLocationViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentLocationViewLeadingConstraint;
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
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ephemeralViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ephemeralViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ephemeralViewTopConstraint;
@property (weak, nonatomic) IBOutlet EphemeralView *ephemeralView;
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
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *replyActionImageViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *replyActionImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *annotationCollectionViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *annotationCollectionViewWidthConstraint;
@property (weak, nonatomic) IBOutlet UICollectionView *annotationCollectionView;
@property (weak, nonatomic) IBOutlet UIImageView *showMapImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *showMapImageViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *showMapImageViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *showMapImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *checkMarkViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *checkMarkViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet UIView *checkMarkView;
@property (weak, nonatomic) IBOutlet UIImageView *checkMarkImageView;
@property (weak, nonatomic) IBOutlet UIView *overlayView;

@property (nonatomic) TLGeolocationDescriptor *locationDescriptor;
@property (nonatomic) CGFloat topLeftRadius;
@property (nonatomic) CGFloat topRightRadius;
@property (nonatomic) CGFloat bottomRightRadius;
@property (nonatomic) CGFloat bottomLeftRadius;
@property (nonatomic) CAShapeLayer *borderLayer;

@property (nonatomic) CustomAppearance *customAppearance;
@property (nonatomic) NSTimer *updateEphemeralTimer;

@end

//
// Implementation: PeerLocationCoordinateItemCell
//

#undef LOG_TAG
#define LOG_TAG @"PeerLocationCoordinateItemCell"

@implementation PeerLocationCoordinateItemCell

- (void)awakeFromNib {
    DDLogVerbose(@"%@ awakeFromNib", LOG_TAG);
    
    [super awakeFromNib];
    
    self.userInteractionEnabled = YES;
    self.contentView.userInteractionEnabled = YES;
    self.contentLocationView.userInteractionEnabled = YES;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UITapGestureRecognizer *tapContentGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTouchUpInsideContentView:)];
    [self.contentView addGestureRecognizer:tapContentGesture];
    
    self.avatarViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.avatarViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.avatarView.layer.cornerRadius = self.avatarViewHeightConstraint.constant * 0.5;
    self.avatarView.layer.masksToBounds = YES;
    
    self.contentLocationViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.contentLocationViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.contentLocationViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.contentLocationViewBottomConstraint.constant *= Design.HEIGHT_RATIO;
    self.contentLocationViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTouchUpInsideCall:)];
    [self.contentLocationView addGestureRecognizer:tapGesture];
    
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onLongPressInsideContent:)];
    longPressGesture.delegate = self;
    [self.contentLocationView addGestureRecognizer:longPressGesture];
    [tapGesture requireGestureRecognizerToFail:longPressGesture];
    
    self.contentLocationView.backgroundColor = Design.GREY_ITEM;
    
    self.locationImageViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.locationImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.locationImageViewLeadingConstraint.constant *= Design.WIDTH_RATIO;

    self.locationImageView.image = [self.locationImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];

    self.coordinateLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.coordinateLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.coordinateLabel.font = Design.FONT_MEDIUM30;
    self.coordinateLabel.textColor = Design.FONT_COLOR_DEFAULT;
    
    self.locationInfoLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.locationInfoLabelBottomConstraint.constant *= Design.HEIGHT_RATIO;
    self.locationInfoLabel.font = Design.FONT_MEDIUM30;
    self.locationInfoLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.locationInfoLabel.text = TwinmeLocalizedString(@"settings_view_show_location_on_map", nil);
    
    self.showMapImageViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.showMapImageViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.showMapImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.showMapImageView.tintColor = Design.FONT_COLOR_DEFAULT;
    self.showMapImageView.image = [self.showMapImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
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
    
    self.overlayView.hidden = YES;
    self.overlayView.backgroundColor = Design.BACKGROUND_COLOR_WHITE_OPACITY85;
}

- (void)prepareForReuse {
    DDLogVerbose(@"%@ prepareForReuse", LOG_TAG);
    
    [super prepareForReuse];
    
    self.locationDescriptor = nil;
    self.avatarView.hidden = YES;
    self.avatarView.image = nil;
    self.replyView.hidden = YES;
    self.replyToImageContentView.hidden = YES;
    self.replyLabel.text = nil;
    self.topLeftRadius = 0;
    self.topRightRadius = 0;
    self.bottomRightRadius = 0;
    self.bottomLeftRadius = 0;
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
    
    [self.contentLocationView setBackgroundColor:[self.customAppearance getPeerMessageBackgroundColor]];
    self.coordinateLabel.textColor = [self.customAppearance getPeerMessageTextColor];
    self.locationInfoLabel.textColor = [self.customAppearance getPeerMessageTextColor];
    self.locationImageView.tintColor = [self.customAppearance getPeerMessageTextColor];
    self.showMapImageView.tintColor = [self.customAppearance getPeerMessageTextColor];
    
    PeerLocationItem *peerLocationItem = (PeerLocationItem *)item;
    CGFloat topMargin = [conversationViewController getTopMarginWithMask:peerLocationItem.corners & ITEM_TOP_LEFT item:item];
    
    self.locationDescriptor = peerLocationItem.geolocationDescriptor;
        
    self.contentLocationViewTopConstraint.constant = [conversationViewController getTopMarginWithMask:peerLocationItem.corners & ITEM_TOP_LEFT item:item];
    self.contentLocationViewBottomConstraint.constant = -[conversationViewController getBottomMarginWithMask:peerLocationItem.corners & ITEM_BOTTOM_LEFT item:item];
    
    self.coordinateLabel.text = [peerLocationItem getInformation];
    
    self.replyImageViewHeightConstraint.constant = 0;
    self.replyImageViewTopConstraint.constant = 0;
    self.replyImageViewBottomConstraint.constant = 0;
    
    CGFloat heightPadding = Design.TEXT_HEIGHT_PADDING;
    CGFloat widthPadding = Design.TEXT_WIDTH_PADDING;
    [self.replyLabel setPaddingWithTop:0 left:widthPadding bottom:0 right:widthPadding];
    
    if (peerLocationItem.replyToDescriptor) {
        switch ([peerLocationItem.replyToDescriptor getType]) {
            case TLDescriptorTypeObjectDescriptor: {
                self.replyView.hidden = NO;
                self.replyToImageContentView.hidden = YES;
                self.replyViewTopConstraint.constant = topMargin;
                [self.replyLabel setPaddingWithTop:heightPadding left:widthPadding bottom:heightPadding right:widthPadding];
                TLObjectDescriptor *objectDescriptor = (TLObjectDescriptor *)peerLocationItem.replyToDescriptor;
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
                TLNamedFileDescriptor *namedFileDescriptor = (TLNamedFileDescriptor *)peerLocationItem.replyToDescriptor;
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
                
                TLImageDescriptor *imageDescriptor = (TLImageDescriptor *)peerLocationItem.replyToDescriptor;
                
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
                
                TLVideoDescriptor *videoDescriptor = (TLVideoDescriptor *)peerLocationItem.replyToDescriptor;
                
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
    
    int corners = peerLocationItem.corners;
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
    
    if (peerLocationItem.visibleAvatar && !conversationViewController.displayPeerItemAvatar) {
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
        
        if (conversationViewController.displayPeerItemAvatar) {
            self.avatarViewLeadingConstraint.constant = 0;
            self.avatarViewHeightConstraint.constant = 0;
            
            if ([conversationViewController isSelectItemMode]) {
                self.contentLocationViewLeadingConstraint.constant = self.checkMarkViewLeadingConstraint.constant + self.checkMarkViewLeadingConstraint.constant + Design.AVATAR_CONVERSATION_LEADING;
            } else {
                self.contentLocationViewLeadingConstraint.constant = Design.AVATAR_CONVERSATION_LEADING;
            }            
        }
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
            
            if ([[[conversationViewController getCustomAppearance] getPeerMessageBackgroundColor] isEqual:[UIColor whiteColor]]) {
                [self.contentLocationView setBackgroundColor:Design.GREY_ITEM];
            }
        }
    } else {
        self.overlayView.hidden = YES;
    }
    
    self.checkMarkView.hidden = !self.isSelectItemMode;
    self.checkMarkImageView.hidden = !item.selected;
    
    if (self.isSelectItemMode) {
        self.avatarView.hidden = YES;
    }
    
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
        [annotationCell bindWithForwardedAnnotation:YES];
        return annotationCell;
    } else {
        AnnotationWithCount *descriptorAnnotation = [self.item.likeDescriptorAnnotations objectAtIndex:indexPath.row];
        if (descriptorAnnotation.count == 1) {
            AnnotationCell *annotationCell = [collectionView dequeueReusableCellWithReuseIdentifier:ANNOTATION_CELL_IDENTIFIER forIndexPath:indexPath];
            annotationCell.annotationActionDelegate = self;
            [annotationCell bindWithAnnotation:descriptorAnnotation.annotation descriptorId:self.item.descriptorId isPeerItem:YES];
            return annotationCell;
        } else {
            AnnotationCountCell *annotationCountCell = [collectionView dequeueReusableCellWithReuseIdentifier:ANNOTATION_COUNT_CELL_IDENTIFIER forIndexPath:indexPath];
            annotationCountCell.annotationActionDelegate = self;
            [annotationCountCell bindWithAnnotation:descriptorAnnotation.annotation count:descriptorAnnotation.count descriptorId:self.item.descriptorId isPeerItem:YES];
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
        CGFloat percent = 1.0 - [Utils progressWithTime:timeSinceRead duration:self.item.expireTimeout];
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

#pragma - mark UIView (UIViewRendering)

- (void)drawRect:(CGRect)rect {
    
    [super drawRect:rect];
    
    CGFloat width = self.contentLocationView.bounds.size.width;
    CGFloat height = self.contentLocationView.bounds.size.height;
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
    self.contentLocationView.layer.masksToBounds = YES;
    self.contentLocationView.layer.mask = mask;
    
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
    
    if (self.borderLayer) {
        [self.borderLayer removeFromSuperlayer];
    }
    
    self.borderLayer = [CAShapeLayer layer];
    self.borderLayer.path = mask.path;
    self.borderLayer.fillColor = [UIColor clearColor].CGColor;
    self.borderLayer.strokeColor = [self.customAppearance getPeerMessageBorderColor].CGColor;
    self.borderLayer.lineWidth = Design.ITEM_BORDER_WIDTH;
    self.borderLayer.frame = self.contentLocationView.bounds;
    [self.contentLocationView.layer addSublayer:self.borderLayer];
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    self.coordinateLabel.font = Design.FONT_MEDIUM30;
    self.locationInfoLabel.font = Design.FONT_MEDIUM30;
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    self.overlayView.backgroundColor = Design.BACKGROUND_COLOR_WHITE_OPACITY85;
}

@end
