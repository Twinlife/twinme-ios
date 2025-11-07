/*
 *  Copyright (c) 2022 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <LinkPresentation/LinkPresentation.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import <MobileCoreServices/UTType.h>

#import <Twinme/TLMessage.h>
#import <Twinme/TLTwinmeAttributes.h>

#import <Utils/NSString+Utils.h>

#import "LinkItemCell.h"

#import "AnnotationCell.h"
#import "AnnotationCountCell.h"

#import "LinkItem.h"
#import "ConversationViewController.h"

#import <TwinmeCommon/AsyncImageLoader.h>
#import <TwinmeCommon/AsyncVideoLoader.h>
#import <TwinmeCommon/Design.h>
#import "DecoratedLabel.h"
#import "UIView+Toast.h"
#import "EphemeralView.h"
#import "CustomAppearance.h"
#import "UIColor+Hex.h"

#import <TwinmeCommon/AsyncLinkLoader.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static const CGFloat DESIGN_LINK_IMAGE_MAX_HEIGHT = 600;
static const CGFloat DESIGN_LINK_IMAGE_MAX_WIDTH = 400;
static const CGFloat DESIGN_LINK_VIEW_MARGIN = 20;

static NSString *ANNOTATION_CELL_IDENTIFIER = @"AnnotationCellIdentifier";
static NSString *ANNOTATION_COUNT_CELL_IDENTIFIER = @"AnnotationCountCellIdentifier";

//
// Interface: LinkItemCell ()
//

@interface LinkItemCell ()<UIGestureRecognizerDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, AnnotationActionDelegate>

@property (weak, nonatomic) IBOutlet UIView *linkView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *linkViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *linkViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *linkViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *linkViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *linkViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *linkImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *linkImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLinkViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *titleLinkView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLinkLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLinkLabelBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLinkLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLinkLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *titleLinkLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentLabelBottomConstraint;
@property (weak, nonatomic) IBOutlet DecoratedLabel *contentLabel;
@property (weak, nonatomic) IBOutlet UIView *contentDeleteView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *stateImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *stateImageViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *stateImageViewBottomConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *stateImageView;
@property (weak, nonatomic) IBOutlet UIView *overlayView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ephemeralViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ephemeralViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ephemeralViewLeadingConstraint;
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
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *replyActionImageViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *replyActionImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *annotationCollectionViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *annotationCollectionViewWidthConstraint;
@property (weak, nonatomic) IBOutlet UICollectionView *annotationCollectionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *checkMarkViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *checkMarkViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet UIView *checkMarkView;
@property (weak, nonatomic) IBOutlet UIImageView *checkMarkImageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;

@property (nonatomic) CGFloat topLeftRadius;
@property (nonatomic) CGFloat topRightRadius;
@property (nonatomic) CGFloat bottomRightRadius;
@property (nonatomic) CGFloat bottomLeftRadius;
@property (nonatomic) BOOL isDeleteAnimationStarted;
@property (nonatomic) NSTimer *updateEphemeralTimer;

@property (nonatomic) AsyncLinkLoader *linkLoader;

@property (weak, nonatomic) UIFont *messageFont;
@property (nonatomic) NSURL *url;

@property (nonatomic) CustomAppearance *customAppearance;

@end

//
// Implementation: LinkItemCell
//

#undef LOG_TAG
#define LOG_TAG @"LinkItemCell"

@implementation LinkItemCell

- (void)awakeFromNib {
    DDLogVerbose(@"%@ awakeFromNib", LOG_TAG);
    
    [super awakeFromNib];
    
    self.isDeleteAnimationStarted = NO;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.messageFont = Design.FONT_REGULAR32;
    
    UITapGestureRecognizer *tapContentGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTouchUpInsideContentView:)];
    tapContentGesture.cancelsTouchesInView = NO;
    [self.contentView addGestureRecognizer:tapContentGesture];
    
    self.linkViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.linkViewBottomConstraint.constant *= Design.HEIGHT_RATIO;
    self.linkViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.linkViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.linkView.backgroundColor = Design.GREY_ITEM;
    self.linkView.clipsToBounds = YES;
    self.linkView.layer.cornerRadius = Design.CONTAINER_RADIUS;
    self.linkView.userInteractionEnabled = YES;
    UITapGestureRecognizer *linkViewTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTouchUpInsideLinkView:)];
    [self.linkView addGestureRecognizer:linkViewTapGesture];
    
    UILongPressGestureRecognizer *longPressLinkGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onLongPressInsideContent:)];
    longPressLinkGesture.delegate = self;
    longPressLinkGesture.cancelsTouchesInView = NO;
    [self.linkView addGestureRecognizer:longPressLinkGesture];
    [linkViewTapGesture requireGestureRecognizerToFail:longPressLinkGesture];
    
    self.linkImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.titleLinkViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.titleLinkView.backgroundColor = [UIColor clearColor];
    
    self.linkViewHeightConstraint.constant = self.titleLinkViewHeightConstraint.constant;
    
    self.activityIndicatorView.color = Design.FONT_COLOR_DEFAULT;

    self.titleLinkLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.titleLinkLabelBottomConstraint.constant *= Design.HEIGHT_RATIO;
    self.titleLinkLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.titleLinkLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.titleLinkLabel.numberOfLines = 2;
    self.titleLinkLabel.text = @"";
    self.titleLinkLabel.font = Design.FONT_MEDIUM32;
    self.titleLinkLabel.textColor = Design.FONT_COLOR_DEFAULT;
    
    self.contentLabel.font = self.messageFont;
    self.contentLabel.numberOfLines = 0;
    self.contentLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.contentLabel.preferredMaxLayoutWidth = Design.MESSAGE_CELL_MAX_WIDTH;
    self.contentLabel.textColor = [UIColor whiteColor];
    CGFloat heightPadding = Design.TEXT_HEIGHT_PADDING;
    CGFloat widthPadding = Design.TEXT_WIDTH_PADDING;
    [self.contentLabel setPaddingWithTop:heightPadding left:widthPadding bottom:heightPadding right:widthPadding];
    [self.contentLabel setDecorShadowColor:[UIColor clearColor]];
    [self.contentLabel setDecorColor:Design.MAIN_COLOR];
    [self.contentLabel setBorderColor:[UIColor clearColor]];
    [self.contentLabel setBorderWidth:0];
    self.contentLabel.longPressGestureRecognizer.cancelsTouchesInView = NO;
    
    NSMutableDictionary *mutableLinkAttributes = [NSMutableDictionary dictionary];
    [mutableLinkAttributes setObject:[NSNumber numberWithBool:YES] forKey:(NSString *)kCTUnderlineStyleAttributeName];
    [mutableLinkAttributes setObject:(__bridge id)[[UIColor whiteColor] CGColor] forKey:(NSString *)kCTForegroundColorAttributeName];
    self.contentLabel.linkAttributes = [NSDictionary dictionaryWithDictionary:mutableLinkAttributes];
    
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onLongPressInsideContent:)];
    longPressGesture.delegate = self;
    longPressGesture.cancelsTouchesInView = NO;
    [self.contentLabel addGestureRecognizer:longPressGesture];
    [tapContentGesture requireGestureRecognizerToFail:longPressGesture];
    
    self.contentLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.contentLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.contentLabelBottomConstraint.constant *= Design.HEIGHT_RATIO;
    
    [self.contentDeleteView setBackgroundColor:Design.DELETE_COLOR_RED];
    self.contentDeleteView.hidden = YES;
    
    self.ephemeralViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.ephemeralViewBottomConstraint.constant = heightPadding;
    self.ephemeralViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    
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
    
    self.replyLabel.font = self.messageFont;
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
        
    self.stateImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.stateImageViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.stateImageViewBottomConstraint.constant *= Design.HEIGHT_RATIO;
    self.stateImageView.layer.cornerRadius = self.stateImageViewHeightConstraint.constant * 0.5;
    self.stateImageView.clipsToBounds = YES;
    
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
    
    self.contentLabel.text = nil;
    self.stateImageView.image = nil;
    self.contentDeleteView.hidden = YES;
    self.isDeleteAnimationStarted = NO;
    self.replyView.hidden = YES;
    self.replyToImageContentView.hidden = YES;
    self.replyLabel.text = nil;
    self.linkImageView.image = nil;
    self.titleLinkLabel.text = nil;
    
    if (self.linkLoader) {
        [self.linkLoader cancel];
        self.linkLoader = nil;
    }
    
    self.url = nil;
    
    [self.contentDeleteView.layer removeAllAnimations];
}

- (void)dealloc {
    DDLogVerbose(@"%@ dealloc", LOG_TAG);
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UILongPressGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    
    return YES;
}

#pragma mark - ItemCell

- (void)bindWithItem:(Item *)item conversationViewController:(ConversationViewController *)conversationViewController asyncManager:(AsyncManager *)asyncManager {
    DDLogVerbose(@"%@ bindWithItem: %@ conversationViewController: %@", LOG_TAG, item, conversationViewController);
    
    [super bindWithItem:item conversationViewController:conversationViewController];
    
    self.customAppearance = [conversationViewController getCustomAppearance];
    self.messageFont = [conversationViewController getMessageFont];
    [self.titleLinkView setBackgroundColor:Design.POPUP_BACKGROUND_COLOR];
    [self.titleLinkLabel setTextColor:Design.FONT_COLOR_DEFAULT];
    [self.contentLabel setDecorColor:[self.customAppearance getMessageBackgroundColor]];
    [self.contentLabel setTextColor:[self.customAppearance getMessageTextColor]];
    [self.contentLabel setBorderColor:[self.customAppearance getMessageBorderColor]];
    
    LinkItem *linkItem = (LinkItem *)item;
    CGFloat topMargin = [conversationViewController getTopMarginWithMask:linkItem.corners & ITEM_TOP_RIGHT item:item];
    self.linkViewTopConstraint.constant = topMargin;
    self.contentLabelTopConstraint.constant = topMargin;
    self.replyViewTopConstraint.constant = topMargin;
    self.contentLabelBottomConstraint.constant = -[conversationViewController getBottomMarginWithMask:linkItem.corners & ITEM_BOTTOM_RIGHT item:item];
        
    if (item.likeDescriptorAnnotations.count > 0 || item.forwarded) {
        self.annotationCollectionView.hidden = NO;
        self.annotationCollectionViewWidthConstraint.constant = [self annotationCollectionWidth];
        [self.annotationCollectionView reloadData];
    } else {
        self.annotationCollectionView.hidden = YES;
    }
    
    self.contentLabel.font = self.messageFont;
    
    NSMutableDictionary *mutableLinkAttributes = [NSMutableDictionary dictionary];
    [mutableLinkAttributes setObject:[NSNumber numberWithBool:YES] forKey:(NSString *)kCTUnderlineStyleAttributeName];
    [mutableLinkAttributes setObject:(__bridge id)[[UIColor blackColor] CGColor] forKey:(NSString *)kCTForegroundColorAttributeName];
    [mutableLinkAttributes setObject:[UIFont systemFontOfSize:self.messageFont.pointSize weight:UIFontWeightSemibold] forKey:NSFontAttributeName];
    self.contentLabel.linkAttributes = [NSDictionary dictionaryWithDictionary:mutableLinkAttributes];
    
    @try {
        NSAttributedString *attributedString = [NSString formatText:linkItem.content fontSize:self.messageFont.pointSize fontColor:[self.customAppearance getMessageTextColor] fontSearch:nil];
        self.contentLabel.text = attributedString;
    } @catch (NSException *exception) {
        self.contentLabel.text = linkItem.content;
    }

    self.contentDeleteView.hidden = YES;
    
    // Use an async loader to get url metadata
    if (!self.linkLoader) {
        self.linkLoader = [[AsyncLinkLoader alloc] initWithItem:self.item objectDescriptor:linkItem.objectDescriptor];
        if (!self.linkLoader.image && !self.linkLoader.title) {
            [self.activityIndicatorView startAnimating];
            [asyncManager addItemWithAsyncLoader:self.linkLoader];
        }
    }
    
    self.linkImageViewHeightConstraint.constant = 0;
    self.linkViewWidthConstraint.constant = DESIGN_LINK_IMAGE_MAX_WIDTH * Design.WIDTH_RATIO;
    self.linkViewHeightConstraint.constant = self.titleLinkViewHeightConstraint.constant;
    self.linkImageView.image = nil;
    
    UIImage *image = self.linkLoader.image;
    NSString *title = self.linkLoader.title;
    
    if (self.linkLoader.url) {
        self.url = self.linkLoader.url;
    }
    
    if (title) {
        [self.activityIndicatorView stopAnimating];
        self.titleLinkLabel.text = title;
    }
    
    if (image) {
        float linkViewWidth = 0;
        float linkViewHeight = 0;
        
        if (image.size.width >= image.size.height) {
            linkViewWidth = DESIGN_LINK_IMAGE_MAX_WIDTH * Design.WIDTH_RATIO;
            linkViewHeight = (linkViewWidth * image.size.height) / image.size.width;
        } else {
            linkViewHeight = DESIGN_LINK_IMAGE_MAX_HEIGHT * Design.HEIGHT_RATIO;
            linkViewWidth = (linkViewHeight * image.size.width) / image.size.height;
        }
        
        self.linkImageViewHeightConstraint.constant = linkViewHeight;
        self.linkViewWidthConstraint.constant = linkViewWidth;
        self.linkViewHeightConstraint.constant = linkViewHeight + self.titleLinkViewHeightConstraint.constant;

        self.linkImageView.image = image;
    }
    
    if (!title && !image && self.linkLoader.isFinished) {
        [self.activityIndicatorView stopAnimating];
        self.linkViewHeightConstraint.constant = 0;
    }
    
    self.replyImageViewHeightConstraint.constant = 0;
    self.replyImageViewTopConstraint.constant = 0;
    self.replyImageViewBottomConstraint.constant = 0;
    
    CGFloat heightPadding = Design.TEXT_HEIGHT_PADDING;
    CGFloat widthPadding = Design.TEXT_WIDTH_PADDING;
    [self.replyLabel setPaddingWithTop:0 left:widthPadding bottom:0 right:widthPadding];
    
    if (linkItem.replyToDescriptor) {
        switch ([linkItem.replyToDescriptor getType]) {
            case TLDescriptorTypeObjectDescriptor: {
                self.replyView.hidden = NO;
                self.replyToImageContentView.hidden = YES;
                self.replyViewTopConstraint.constant = topMargin;
                [self.replyLabel setPaddingWithTop:heightPadding left:widthPadding bottom:heightPadding right:widthPadding];
                TLObjectDescriptor *objectDescriptor = (TLObjectDescriptor *)linkItem.replyToDescriptor;
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
                TLNamedFileDescriptor *namedFileDescriptor = (TLNamedFileDescriptor *)linkItem.replyToDescriptor;
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
                    TLImageDescriptor *imageDescriptor = (TLImageDescriptor *)linkItem.replyToDescriptor;
                                        
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
                    TLVideoDescriptor *videoDescriptor = (TLVideoDescriptor *)linkItem.replyToDescriptor;
                    
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
        
        if (!self.replyToImageContentView.hidden) {
            self.linkViewBottomConstraint.constant = self.replyImageViewHeightConstraint.constant + DESIGN_LINK_VIEW_MARGIN * Design.HEIGHT_RATIO;
        } else {
            self.linkViewBottomConstraint.constant = DESIGN_LINK_VIEW_MARGIN * Design.HEIGHT_RATIO;
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
        
        CGFloat heightPadding = Design.TEXT_HEIGHT_PADDING;
        CGFloat widthPadding = Design.TEXT_WIDTH_PADDING;
        [self.contentLabel setPaddingWithTop:heightPadding left:widthPadding + self.ephemeralViewHeightConstraint.constant bottom:heightPadding right:widthPadding];
        
    } else {
        self.ephemeralView.hidden = YES;
        
        CGFloat heightPadding = Design.TEXT_HEIGHT_PADDING;
        CGFloat widthPadding = Design.TEXT_WIDTH_PADDING;
        [self.contentLabel setPaddingWithTop:heightPadding left:widthPadding bottom:heightPadding right:widthPadding];
    }
    
    
    int corners = linkItem.corners;
    
    self.stateImageView.backgroundColor = [UIColor clearColor];
    self.stateImageView.tintColor = [UIColor clearColor];
    
    switch (linkItem.state) {
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
            self.stateImageView.image = [conversationViewController getContactAvatarWithUUID:[linkItem peerTwincodeOutboundId]];
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
            break;
            
        case ItemStateDeleted:
            corners &= ~ITEM_BOTTOM_RIGHT;
            self.stateImageView.hidden = NO;
            [self.stateImageView.layer removeAllAnimations];
            self.stateImageView.image = [UIImage imageNamed:@"ItemStateDeleted"];
            [self startStateImageAnimation];
            break;
            
        case ItemStateBothDeleted:
            corners &= ~ITEM_BOTTOM_RIGHT;
            self.stateImageView.hidden = NO;
            [self.stateImageView.layer removeAllAnimations];
            self.stateImageView.image = [UIImage imageNamed:@"ItemStateDeleted"];
            self.contentDeleteView.hidden = NO;
            if (self.item.deleteProgress == 0) {
                [self.item startDeleteItem];
            }
            [self startDeleteAnimation];
            break;
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
    
    [self.contentLabel setCornerRadiusWithTopLeft:self.topLeftRadius topRight:self.topRightRadius bottomRight: self.bottomRightRadius bottomLeft:self.bottomLeftRadius];
    
    if ([conversationViewController isMenuOpen]) {
        self.overlayView.hidden = NO;
        [self.contentView bringSubviewToFront:self.overlayView];
        Item *selectedItem = [conversationViewController getSelectedItem];
        if ([selectedItem.descriptorId isEqual:self.item.descriptorId]) {
            [self.contentView bringSubviewToFront:self.replyView];
            [self.contentView bringSubviewToFront:self.replyToImageContentView];
            [self.contentView bringSubviewToFront:self.contentLabel];
            [self.contentView bringSubviewToFront:self.linkView];
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

- (void)updateEphemeralView {
    
    if (self.item.state == ItemStateRead) {
        CGFloat timeSinceRead = ([[NSDate date] timeIntervalSince1970] * 1000) - self.item.readTimestamp;
        CGFloat percent = 1.0 - (timeSinceRead / self.item.expireTimeout);
        if (percent < 0) {
            percent = 0.0;
        } else if (percent > 1) {
            percent = 1.0;
        }
    
        [self.ephemeralView updateWithPercent:percent color:[self.customAppearance getMessageTextColor] size:self.ephemeralViewHeightConstraint.constant];
    } else {
        [self.ephemeralView updateWithPercent:1.0 color:[self.customAppearance getMessageTextColor] size:self.ephemeralViewHeightConstraint.constant];
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
        initialWidth = (self.item.deleteProgress * self.contentLabel.frame.size.width) / 100.0;
        animationDuration = DESIGN_DELETE_ANIMATION_DURATION - ((self.item.deleteProgress * DESIGN_DELETE_ANIMATION_DURATION) / 100.0);
    }
    
    self.contentDeleteView.hidden = NO;
    CGRect contentDeleteFrame = self.contentDeleteView.frame;
    contentDeleteFrame.size.width = initialWidth;
    self.contentDeleteView.frame = contentDeleteFrame;
    contentDeleteFrame.size.width = self.contentLabel.frame.size.width;
    
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
    
    self.stateImageView.hidden = NO;
    [self.stateImageView.layer removeAllAnimations];
    
    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    rotationAnimation.fromValue = [NSNumber numberWithFloat:0];
    rotationAnimation.toValue = [NSNumber numberWithFloat:2*M_PI];
    rotationAnimation.duration = 0.5;
    rotationAnimation.autoreverses = NO;
    rotationAnimation.repeatCount = HUGE_VALF;
    rotationAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    [self.stateImageView.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

- (void)deleteEphemeralItem {
    DDLogVerbose(@"%@ deleteEphemeralItem", LOG_TAG);
    
    if ([self.deleteActionDelegate respondsToSelector:@selector(deleteItem:)]) {
        
        if (self.updateEphemeralTimer) {
            [self.updateEphemeralTimer invalidate];
            self.updateEphemeralTimer = nil;
        }
        
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
    
    if (self.item.forwarded && section == 1) {
        return 1;
    }
    return self.item.likeDescriptorAnnotations.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ collectionView: %@ layout: %@ sizeForItemAtIndexPath: %@", LOG_TAG, collectionView, collectionViewLayout, indexPath);
    
    if (self.item.forwarded && indexPath.section == 1) {
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
    
    if (self.item.forwarded && indexPath.section == 1) {
        AnnotationCell *annotationCell = [collectionView dequeueReusableCellWithReuseIdentifier:ANNOTATION_CELL_IDENTIFIER forIndexPath:indexPath];
        [annotationCell bindWithForwardedAnnotation:NO];
        return annotationCell;
    } else {
        TLDescriptorAnnotation *descriptorAnnotation = [self.item.likeDescriptorAnnotations objectAtIndex:indexPath.row];
        if (descriptorAnnotation.count == 1) {
            AnnotationCell *annotationCell = [collectionView dequeueReusableCellWithReuseIdentifier:ANNOTATION_CELL_IDENTIFIER forIndexPath:indexPath];
            annotationCell.annotationActionDelegate = self;
            [annotationCell bindWithAnnotation:descriptorAnnotation descriptorId:self.item.descriptorId isPeerItem:NO];
            return annotationCell;
        } else {
            AnnotationCountCell *annotationCountCell = [collectionView dequeueReusableCellWithReuseIdentifier:ANNOTATION_COUNT_CELL_IDENTIFIER forIndexPath:indexPath];
            annotationCountCell.annotationActionDelegate = self;
            [annotationCountCell bindWithAnnotation:descriptorAnnotation descriptorId:self.item.descriptorId isPeerItem:NO];
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

#pragma mark - CopyableContent

- (NSString *)copyableContent {
    DDLogVerbose(@"%@ copyableContent", LOG_TAG);
    
    return self.contentLabel.text;
}

#pragma mark - IBActions

- (void)onTouchUpInsideLinkView:(UITapGestureRecognizer *)tapGesture {
    DDLogVerbose(@"%@ onTouchUpInsideLinkView: %@", LOG_TAG, tapGesture);
    
    if (self.isSelectItemMode) {
        if ([self.selectItemDelegate respondsToSelector:@selector(didSelectItem:)]) {
            [self.selectItemDelegate didSelectItem:self.item];
        }
        return;
    }
    
    if (![self.item isDeletedItem] && self.url && [self.linkActionDelegate respondsToSelector:@selector(openLinkWithURL:)]) {
        [self.linkActionDelegate openLinkWithURL:self.url];
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
    DDLogVerbose(@"%@ drawRect: %@", LOG_TAG, NSStringFromCGRect(rect));
    
    [super drawRect:rect];
    
    CGFloat width = self.contentLabel.bounds.size.width;
    CGFloat height = self.contentLabel.bounds.size.height;
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
    
    self.replyLabel.font = self.messageFont;
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    self.overlayView.backgroundColor = Design.BACKGROUND_COLOR_WHITE_OPACITY85;
}

@end
