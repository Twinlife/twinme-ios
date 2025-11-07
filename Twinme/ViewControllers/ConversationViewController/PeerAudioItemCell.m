/*
 *  Copyright (c) 2016-2024 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Christian Jacquemot (Christian.Jacquemot@twinlife-systems.com)
 *   Chedi Baccari (Chedi.Baccari@twinlife-systems.com)
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 *   Stephane Carrez (Stephane.Carrez@twin.life)
 */

#import <CocoaLumberjack.h>

#import <Twinlife/TLConversationService.h>

#import <Twinme/TLMessage.h>
#import <Twinme/TLTwinmeAttributes.h>

#import <Utils/NSString+Utils.h>

#import "PeerAudioItemCell.h"

#import "AnnotationCell.h"
#import "AnnotationCountCell.h"
#import "PeerAudioItem.h"
#import "ConversationViewController.h"
#import "Cache.h"
#import "CustomAppearance.h"
#import "DecoratedLabel.h"
#import "EphemeralView.h"
#import "AudioTrackView.h"
#import "UIColor+Hex.h"

#import <TwinmeCommon/AudioPlayerManager.h>
#import <TwinmeCommon/AsyncAudioTrackLoader.h>
#import <TwinmeCommon/AsyncImageLoader.h>
#import <TwinmeCommon/AsyncVideoLoader.h>
#import <TwinmeCommon/AudioPlayerManager.h>
#import <TwinmeCommon/Design.h>
#import <TwinmeCommon/Utils.h>


#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static NSString *ANNOTATION_CELL_IDENTIFIER = @"AnnotationCellIdentifier";
static NSString *ANNOTATION_COUNT_CELL_IDENTIFIER = @"AnnotationCountCellIdentifier";

//
// Interface: PeerAudioItemCell ()
//

@interface PeerAudioItemCell ()<AudioTrackViewDelegate, UIGestureRecognizerDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, AnnotationActionDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *avatarViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *avatarViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *avatarViewTopConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *avatarView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentAudioViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentAudioViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentAudioViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentAudioViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentAudioViewTopConstraint;
@property (weak, nonatomic) IBOutlet UIView *contentAudioView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *playerButtonViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *playerButtonViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet UIView *playerButtonView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *playerImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *playerImageViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *playerImageViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *playerImageViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *playerImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pauseImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *pauseImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *audioTrackViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *audioTrackViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *audioTrackViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *audioTrackViewWidthConstraint;
@property (weak, nonatomic) IBOutlet AudioTrackView *audioTrackView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *durationLabelBottomConstraint;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
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
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ephemeralViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ephemeralViewTrailingConstraint;
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

@property (nonatomic) CGFloat topLeftRadius;
@property (nonatomic) CGFloat topRightRadius;
@property (nonatomic) CGFloat bottomRightRadius;
@property (nonatomic) CGFloat bottomLeftRadius;
@property (nonatomic) CAShapeLayer *borderLayer;

@property (nonatomic) NSString *path;
@property (nonatomic) NSURL *url;
@property (nonatomic) int64_t duration;

@property float currentTime;
@property NSTimer *timer;
@property BOOL isPaused;
@property BOOL sliding;
@property (nonatomic) AsyncAudioTrackLoader *audioTrackLoader;

@property (nonatomic) CustomAppearance *customAppearance;

@property (nonatomic) NSTimer *updateEphemeralTimer;
@property (nonatomic) PeerAudioItem *peerAudioItem;

@end

//
// Implementation: PeerAudioItemCell
//

#undef LOG_TAG
#define LOG_TAG @"PeerAudioItemCell"

@implementation PeerAudioItemCell

- (void)awakeFromNib {
    DDLogVerbose(@"%@ awakeFromNib", LOG_TAG);
    
    [super awakeFromNib];
    
    self.currentTime = 0;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UITapGestureRecognizer *tapContentGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTouchUpInsideContentView:)];
    [self.contentView addGestureRecognizer:tapContentGesture];
    
    self.avatarViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.avatarViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.avatarViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.avatarView.layer.cornerRadius = self.avatarViewHeightConstraint.constant * 0.5;
    self.avatarView.layer.masksToBounds = YES;
    
    self.contentAudioViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.contentAudioViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.contentAudioViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    [self.contentAudioView setBackgroundColor:Design.GREY_ITEM];
    self.contentAudioView.userInteractionEnabled = YES;
    self.contentAudioView.clipsToBounds = YES;
    
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onLongPressInsideContent:)];
    longPressGesture.delegate = self;
    [self.contentAudioView addGestureRecognizer:longPressGesture];
    
    self.playerButtonViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.playerButtonViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.playerButtonView.clipsToBounds = YES;
    self.playerButtonView.backgroundColor =  Design.LIGHT_GREY_BACKGROUND_COLOR;
    self.playerButtonView.layer.cornerRadius = self.playerButtonViewHeightConstraint.constant * 0.5;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleplayerButtonViewTapGestureRecognizer:)];
    [self.playerButtonView addGestureRecognizer:tapGesture];
    
    [tapGesture requireGestureRecognizerToFail:longPressGesture];
    [tapContentGesture requireGestureRecognizerToFail:longPressGesture];
    
    self.playerImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.playerImageViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.playerImageViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.playerImageViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.playerImageView.tintColor = Design.MAIN_COLOR;
    
    self.pauseImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.pauseImageView.tintColor = Design.MAIN_COLOR;
    self.pauseImageView.hidden = YES;
    
    self.audioTrackViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.audioTrackViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.audioTrackViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.audioTrackViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    
    self.audioTrackView.audioTrackViewDelegate = self;
    self.audioTrackView.userInteractionEnabled = YES;
    
    UILongPressGestureRecognizer *longPressAudioGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onLongPressInsideContent:)];
    longPressGesture.delegate = self;
    [self.audioTrackView addGestureRecognizer:longPressAudioGesture];
    
    self.durationLabelBottomConstraint.constant *= Design.HEIGHT_RATIO;
    self.durationLabel.font = Design.FONT_MEDIUM26;
    self.durationLabel.textColor = Design.FONT_COLOR_DEFAULT;
    
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
    
    self.ephemeralViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.ephemeralViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.ephemeralView.tintColor = [UIColor blackColor];
    
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(proximityChanged) name:UIDeviceProximityStateDidChangeNotification object:nil];
}

- (void)prepareForReuse {
    DDLogVerbose(@"%@ prepareForReuse", LOG_TAG);
    
    [super prepareForReuse];
    
    [AudioPlayerManager stopPlaying];
    
    self.avatarView.hidden = YES;
    self.avatarView.image = nil;
    
    if (self.audioTrackLoader) {
        [self.audioTrackLoader cancel];
        self.audioTrackLoader = nil;
    }
    
    self.replyView.hidden = YES;
    self.replyToImageContentView.hidden = YES;
    self.replyLabel.text = nil;
    
    self.currentTime = 0;
    
    if ([UIDevice currentDevice].proximityMonitoringEnabled) {
        [UIDevice currentDevice].proximityMonitoringEnabled = NO;
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceProximityStateDidChangeNotification object:nil];
    }
}

#pragma mark - ItemCell

- (void)bindWithItem:(Item *)item conversationViewController:(ConversationViewController *)conversationViewController asyncManager:(AsyncManager *)asyncManager {
    DDLogVerbose(@"%@ bindWithItem: %@ conversationViewController: %@", LOG_TAG, item, conversationViewController);
    
    [super bindWithItem:item conversationViewController:conversationViewController];
    
    self.customAppearance = [conversationViewController getCustomAppearance];
    
    [self.contentAudioView setBackgroundColor:[self.customAppearance getPeerMessageBackgroundColor]];
    
    self.durationLabel.textColor = [self.customAppearance getPeerMessageTextColor];
    
    PeerAudioItem *peerAudioItem = (PeerAudioItem *)item;
    self.peerAudioItem = peerAudioItem;
    
    CGFloat topMargin = [conversationViewController getTopMarginWithMask:peerAudioItem.corners & ITEM_TOP_LEFT item:item];
    self.contentAudioViewTopConstraint.constant = topMargin;
    self.replyViewTopConstraint.constant = topMargin;
    CGFloat leadingMargin = (self.contentAudioViewHeightConstraint.constant - self.playerButtonViewHeightConstraint.constant) * 0.5;
    self.playerButtonViewLeadingConstraint.constant = leadingMargin;
    self.audioTrackViewLeadingConstraint.constant = leadingMargin;
    self.contentAudioViewBottomConstraint.constant = -[conversationViewController getBottomMarginWithMask:peerAudioItem.corners & ITEM_BOTTOM_LEFT item:item];
        
    if (item.likeDescriptorAnnotations.count > 0 || item.forwarded) {
        self.annotationCollectionView.hidden = NO;
        self.annotationCollectionViewWidthConstraint.constant = [self annotationCollectionWidth];
        [self.annotationCollectionView reloadData];
    } else {
        self.annotationCollectionView.hidden = YES;
    }
    
    self.avatarViewTopConstraint.constant = topMargin;
    
    self.url = [peerAudioItem.audioDescriptor getURL];
    int nbLines = self.audioTrackViewWidthConstraint.constant / 2;
    if (!self.audioTrackLoader) {
        self.audioTrackLoader = [[AsyncAudioTrackLoader alloc] initWithItem:item audioDescriptor:peerAudioItem.audioDescriptor nbLines:nbLines];
        [asyncManager addItemWithAsyncLoader:self.audioTrackLoader];
    }
    
    AudioTrack *audioTrack = self.audioTrackLoader.audioTrack;
    if (audioTrack) {
        [self.audioTrackView drawTrack:audioTrack lineColor:Design.PEER_AUDIO_TRACK_COLOR progressColor:Design.MAIN_COLOR];
    }
    
    int hour = 60 * 60;
    NSString *format = @"mm:ss";
    if (peerAudioItem.audioDescriptor.duration > hour) {
        format = @"hh:mm:ss";
    }
    self.durationLabel.text = [NSString convertWithInterval:peerAudioItem.audioDescriptor.duration format:format];
    
    self.replyImageViewHeightConstraint.constant = 0;
    self.replyImageViewTopConstraint.constant = 0;
    self.replyImageViewBottomConstraint.constant = 0;
    
    CGFloat heightPadding = Design.TEXT_HEIGHT_PADDING;
    CGFloat widthPadding = Design.TEXT_WIDTH_PADDING;
    [self.replyLabel setPaddingWithTop:0 left:widthPadding bottom:0 right:widthPadding];
    
    if (peerAudioItem.replyToDescriptor) {
        switch ([peerAudioItem.replyToDescriptor getType]) {
            case TLDescriptorTypeObjectDescriptor: {
                self.replyView.hidden = NO;
                self.replyToImageContentView.hidden = YES;
                self.replyViewTopConstraint.constant = topMargin;
                [self.replyLabel setPaddingWithTop:heightPadding left:widthPadding bottom:heightPadding right:widthPadding];
                TLObjectDescriptor *objectDescriptor = (TLObjectDescriptor *)peerAudioItem.replyToDescriptor;
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
                TLNamedFileDescriptor *namedFileDescriptor = (TLNamedFileDescriptor *)peerAudioItem.replyToDescriptor;
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
                    TLImageDescriptor *imageDescriptor = (TLImageDescriptor *)peerAudioItem.replyToDescriptor;
                    
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
                    TLVideoDescriptor *videoDescriptor = (TLVideoDescriptor *)peerAudioItem.replyToDescriptor;
                    
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
    
    int corners = peerAudioItem.corners;
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
    
    if (peerAudioItem.visibleAvatar) {
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
            [self.contentView bringSubviewToFront:self.contentAudioView];
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

#pragma mark - PanGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    
    CGPoint touchpoint = [gestureRecognizer locationInView:self];
    if (CGRectContainsPoint(self.audioTrackView.frame, touchpoint)) {
        return NO;
    }
    
    return [super gestureRecognizerShouldBegin:gestureRecognizer];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    
    CGPoint touchpoint = [gestureRecognizer locationInView:self];
    if (CGRectContainsPoint(self.audioTrackView.frame, touchpoint)) {
        return NO;
    }
    
    return [super gestureRecognizer:gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:otherGestureRecognizer];
}

#pragma mark - AudioTrackViewDelegate

- (void)audioTrackViewTouchEnd:(float)progress {
    DDLogVerbose(@"%@ audioTrackViewTouchEnd: %f", LOG_TAG, progress);
    
    if (self.peerAudioItem) {
        float currentTime = progress * self.peerAudioItem.audioDescriptor.duration;
        self.currentTime = currentTime;
        
        int remainingTime = self.peerAudioItem.audioDescriptor.duration - currentTime;
        int hour = 60 * 60;
        NSString *format = @"mm:ss";
        if (remainingTime > hour) {
            format = @"hh:mm:ss";
        }
        
        self.durationLabel.text = [NSString convertWithInterval:remainingTime format:format];
        
        if ([AudioPlayerManager sharedInstance].descriptorId == self.item.descriptorId) {
            [[AudioPlayerManager sharedInstance] setCurrentTime:currentTime];
        }
    }
}


- (void)updateEphemeralView {
    
    if (self.item.state == ItemStateRead) {
        CGFloat timeSinceRead = ([[NSDate date] timeIntervalSince1970] * 1000) - self.item.readTimestamp;
        CGFloat percent = 1.0 - [Utils progressWithTime:timeSinceRead duration:self.item.expireTimeout];
        [self.ephemeralView updateWithPercent:percent color:[self.customAppearance getPeerMessageTextColor] size:self.ephemeralViewHeightConstraint.constant];
    } else {
        [self.ephemeralView updateWithPercent:1.0 color:[self.customAppearance getPeerMessageTextColor] size:self.ephemeralViewHeightConstraint.constant];
    }
}

- (void)deleteEphemeralItem {
    DDLogVerbose(@"%@ deleteEphemeralItem", LOG_TAG);
    
    if ([self.deleteActionDelegate respondsToSelector:@selector(deleteItem:)]) {
        [self.deleteActionDelegate deleteItem:self.item];
    }
}

#pragma mark - IBActions

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

- (void)onSwipeInsideContentView:(UIPanGestureRecognizer *)panGesture {
    DDLogVerbose(@"%@ onSwipeInsideContentView: %@", LOG_TAG, panGesture);
    
    if (!self.audioTrackView.isTouch) {
        [super onSwipeInsideContentView:panGesture];
    }
}

#pragma - mark UIView(UIViewRendering)

- (void)drawRect:(CGRect)rect {
    DDLogVerbose(@"%@ drawRect: %@", LOG_TAG, NSStringFromCGRect(rect));
    
    [super drawRect:rect];
    
    CGFloat width = self.contentAudioView.bounds.size.width;
    CGFloat height = self.contentAudioView.bounds.size.height;
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
    self.contentAudioView.layer.masksToBounds = YES;
    self.contentAudioView.layer.mask = mask;
    
    if (self.borderLayer) {
        [self.borderLayer removeFromSuperlayer];
    }
    
    self.borderLayer = [CAShapeLayer layer];
    self.borderLayer.path = mask.path;
    self.borderLayer.fillColor = [UIColor clearColor].CGColor;
    self.borderLayer.strokeColor = [self.customAppearance getPeerMessageBorderColor].CGColor;
    self.borderLayer.lineWidth = Design.ITEM_BORDER_WIDTH;
    self.borderLayer.frame = self.contentAudioView.bounds;
    [self.contentAudioView.layer addSublayer:self.borderLayer];
    
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
}

#pragma - mark Player

- (void)handleplayerButtonViewTapGestureRecognizer:(UITapGestureRecognizer *)recognizer {
    DDLogVerbose(@"%@ handleplayerButtonViewTapGestureRecognizer: %@",LOG_TAG, recognizer);
    
    if (self.isSelectItemMode) {
        if ([self.selectItemDelegate respondsToSelector:@selector(didSelectItem:)]) {
            [self.selectItemDelegate didSelectItem:self.item];
        }
        return;
    }
    
    [self.timer invalidate];
    
    AudioPlayerManager *audioPlayerManager = [AudioPlayerManager sharedInstance];
    audioPlayerManager.descriptorId = self.item.descriptorId;

    if (!self.isPaused) {
        self.pauseImageView.hidden = NO;
        self.playerImageView.hidden = YES;
        [UIDevice currentDevice].proximityMonitoringEnabled = YES;
        [audioPlayerManager playWithURL:self.url currentTime:self.currentTime startPlayingBlock:^() {
            self.timer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(updateTime:) userInfo:nil repeats:YES];
        }];
        self.isPaused = YES;
        
        if ([self.audioActionDelegate respondsToSelector:@selector(readAudioDescriptor:)]) {
            [self.audioActionDelegate readAudioDescriptor:self.peerAudioItem.audioDescriptor];
        }
    } else {
        self.pauseImageView.hidden = YES;
        self.playerImageView.hidden = NO;
        [UIDevice currentDevice].proximityMonitoringEnabled = NO;
        [audioPlayerManager pause];
        self.currentTime = [audioPlayerManager currentPlaybackTime];
        self.isPaused = NO;
    }
}

- (void)proximityChanged {
    DDLogVerbose(@"%@ proximityChanged", LOG_TAG);
    
    AudioPlayerManager *audioPlayerManager = [AudioPlayerManager sharedInstance];
    [audioPlayerManager proximityChanged];
}

- (void)updateTime:(NSTimer *)timer {
    
    AudioPlayerManager *audioPlayerManager = [AudioPlayerManager sharedInstance];
    if (audioPlayerManager.descriptorId == self.item.descriptorId) {
        float duration = [audioPlayerManager duration];
        float playbackTime = [audioPlayerManager currentPlaybackTime];
        float progress = [Utils progressWithTime:playbackTime duration:duration];
        [self.audioTrackView updateProgressView:progress];
        
        int hour = 60 * 60;
        NSString *format = @"mm:ss";
        if (duration - playbackTime > hour) {
            format = @"hh:mm:ss";
        }
        
        self.durationLabel.text = [NSString convertWithInterval:duration - playbackTime format:format];
        
        if (![audioPlayerManager isPlaying]) {
            self.pauseImageView.hidden = YES;
            self.playerImageView.hidden = NO;
            [audioPlayerManager pause];
            self.isPaused = NO;
            [self.timer invalidate];
            self.currentTime = 0;
            
            if ([UIDevice currentDevice].proximityMonitoringEnabled) {
                [UIDevice currentDevice].proximityMonitoringEnabled = NO;
                [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceProximityStateDidChangeNotification object:nil];
            }
        }
    } else {
        [self.timer invalidate];
        self.currentTime = 0;
        self.pauseImageView.hidden = YES;
        self.playerImageView.hidden = NO;
    }
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    self.durationLabel.font = Design.FONT_MEDIUM26;
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    self.playerImageView.tintColor = Design.MAIN_COLOR;
    self.pauseImageView.tintColor = Design.MAIN_COLOR;
    self.overlayView.backgroundColor = Design.BACKGROUND_COLOR_WHITE_OPACITY85;
}

@end
