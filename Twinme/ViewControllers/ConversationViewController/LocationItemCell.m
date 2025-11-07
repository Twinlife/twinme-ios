/*
 *  Copyright (c) 2019-2021 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <MapKit/MapKit.h>

#import <Twinlife/TLConversationService.h>

#import <Twinme/TLTwinmeAttributes.h>
#import <Twinme/TLMessage.h>

#import "LocationItemCell.h"

#import "AnnotationCell.h"
#import "AnnotationCountCell.h"

#import "LocationItem.h"
#import "ImageItem.h"
#import "LocationAnnotation.h"
#import "LocationAnnotationView.h"
#import "ConversationViewController.h"

#import <TwinmeCommon/Cache.h>
#import <TwinmeCommon/Design.h>

#import "DecoratedLabel.h"
#import "UIView+Toast.h"
#import "EphemeralView.h"
#import <Utils/NSString+Utils.h>
#import "UIColor+Hex.h"

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static const CGFloat DESIGN_ANNOTATION_CELL_MAX_HEIGHT = 86.0f;

static NSString *ANNOTATION_CELL_IDENTIFIER = @"AnnotationCellIdentifier";
static NSString *ANNOTATION_COUNT_CELL_IDENTIFIER = @"AnnotationCountCellIdentifier";

//
// Interface: LocationItemCell ()
//

@interface LocationItemCell () <MKMapViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, AnnotationActionDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mapViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mapViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mapViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mapViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mapViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *contentImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ephemeralViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ephemeralViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ephemeralViewBottomConstraint;
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
@property (weak, nonatomic) IBOutlet UIView *overlayView;

@property (nonatomic) TLGeolocationDescriptor *geolocationDescriptor;
@property (nonatomic) CGFloat topLeftRadius;
@property (nonatomic) CGFloat topRightRadius;
@property (nonatomic) CGFloat bottomRightRadius;
@property (nonatomic) CGFloat bottomLeftRadius;

@property (nonatomic) UIImage *avatarImage;
@property (nonatomic) CLLocation *userLocation;

@property (nonatomic) NSTimer *updateEphemeralTimer;

@end

//
// Implementation: LocationItemCell
//

#undef LOG_TAG
#define LOG_TAG @"LocationItemCell"

@implementation LocationItemCell

- (void)awakeFromNib {
    DDLogVerbose(@"%@ awakeFromNib", LOG_TAG);
    
    [super awakeFromNib];
    
    self.userInteractionEnabled = YES;
    self.contentView.userInteractionEnabled = YES;
    self.contentImageView.userInteractionEnabled = YES;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UITapGestureRecognizer *tapContentGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTouchUpInsideContentView:)];
    [self.contentView addGestureRecognizer:tapContentGesture];
    
    self.mapViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.mapViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.mapViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.mapViewBottomConstraint.constant *= Design.HEIGHT_RATIO;
    self.mapViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.mapView.delegate = self;
    self.mapView.clipsToBounds = YES;
    self.mapView.scrollEnabled = NO;
    self.mapView.zoomEnabled = NO;
    self.mapView.rotateEnabled = NO;
    self.mapView.pitchEnabled = NO;
    
    UITapGestureRecognizer *tapImageGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTouchUpInsideImage:)];
    [self.contentImageView addGestureRecognizer:tapImageGesture];
    
    UITapGestureRecognizer *tapMapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTouchUpInsideMap:)];
    [self.mapView addGestureRecognizer:tapMapGesture];
    
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onLongPressInsideContent:)];
    longPressGesture.delegate = self;
    [self.contentImageView addGestureRecognizer:longPressGesture];
    [tapImageGesture requireGestureRecognizerToFail:longPressGesture];
    
    UILongPressGestureRecognizer *longPressMapGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onLongPressInsideContent:)];
    longPressMapGesture.delegate = self;
    [self.mapView addGestureRecognizer:longPressMapGesture];
    [tapMapGesture requireGestureRecognizerToFail:longPressMapGesture];
    
    self.ephemeralViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.ephemeralViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.ephemeralViewBottomConstraint.constant *= Design.HEIGHT_RATIO;
    
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
    
    self.overlayView.hidden = YES;
    self.overlayView.backgroundColor = Design.BACKGROUND_COLOR_WHITE_OPACITY85;
}

- (void)prepareForReuse {
    DDLogVerbose(@"%@ prepareForReuse", LOG_TAG);
    
    [super prepareForReuse];
    
    self.contentImageView.image = nil;
    self.geolocationDescriptor = nil;
    self.stateImageView.image = nil;
    
    self.replyView.hidden = YES;
    self.replyToImageContentView.hidden = YES;
    self.replyLabel.text = nil;
}

#pragma mark - ItemCell

- (void)bindWithItem:(Item *)item conversationViewController:(ConversationViewController *)conversationViewController {
    DDLogVerbose(@"%@ bindWithItem: %@ conversationViewController: %@", LOG_TAG, item, conversationViewController);
    
    [super bindWithItem:item conversationViewController:conversationViewController];
    
    LocationItem *locationItem = (LocationItem *)item;
    self.geolocationDescriptor = locationItem.geolocationDescriptor;
    
    CGFloat topMargin = [conversationViewController getTopMarginWithMask:locationItem.corners & ITEM_TOP_RIGHT item:item];
    
    self.mapViewTopConstraint.constant = topMargin;
    self.mapViewBottomConstraint.constant = -[conversationViewController getBottomMarginWithMask:locationItem.corners & ITEM_BOTTOM_RIGHT item:item];
    
    [self.mapView removeAnnotations:[self.mapView annotations]];
    self.mapView.delegate = self;
    
    self.avatarImage = [conversationViewController getContactAvatarForMap:NULL];
    
    if (item.likeDescriptorAnnotations.count > 0 || item.forwarded) {
        self.annotationCollectionView.hidden = NO;
        self.annotationCollectionViewWidthConstraint.constant = [self annotationCollectionWidth];
        [self.annotationCollectionView reloadData];
    } else {
        self.annotationCollectionView.hidden = YES;
    }
    
    if (self.geolocationDescriptor.isValidLocalMap) {
        self.mapView.hidden = YES;
        self.contentImageView.hidden = NO;
        self.contentImageView.image = [UIImage imageWithContentsOfFile:[self.geolocationDescriptor.getURL path]];
    } else {
        self.mapView.hidden = NO;
        self.contentImageView.hidden = YES;
        
        CLLocation *location = [[CLLocation alloc]initWithLatitude:self.geolocationDescriptor.latitude longitude:self.geolocationDescriptor.longitude];
        self.userLocation = location;
        
        [self addLocation:location];
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
                self.replyLabel.text = TwinmeLocalizedString(@"conversation_view_controller_audio_message", nil);
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
    
    self.topLeftRadius = [conversationViewController getRadiusWithMask:corners & ITEM_TOP_LEFT];
    self.topRightRadius = [conversationViewController getRadiusWithMask:corners & ITEM_TOP_RIGHT];
    self.bottomRightRadius = [conversationViewController getRadiusWithMask:corners & ITEM_BOTTOM_RIGHT];
    self.bottomLeftRadius = [conversationViewController getRadiusWithMask:corners & ITEM_BOTTOM_LEFT];
    
    if ([conversationViewController isMenuOpen]) {
        self.overlayView.hidden = NO;
        [self.contentView bringSubviewToFront:self.overlayView];
        Item *selectedItem = [conversationViewController getSelectedItem];
        if ([selectedItem.descriptorId isEqual:self.item.descriptorId]) {
            [self.contentView bringSubviewToFront:self.replyView];
            [self.contentView bringSubviewToFront:self.replyToImageContentView];
            [self.contentView bringSubviewToFront:self.contentImageView];
            [self.contentView bringSubviewToFront:self.mapView];
            [self.contentView bringSubviewToFront:self.ephemeralView];
            [self.contentView bringSubviewToFront:self.annotationCollectionView];
        }
    } else {
        self.overlayView.hidden = YES;
        [self.contentView bringSubviewToFront:self.contentDeleteView];
    }
    
    self.checkMarkView.hidden = !self.isSelectItemMode;
    self.checkMarkImageView.hidden = !item.selected;
    
    [self setNeedsDisplay];
}

- (void)addLocation:(CLLocation *)location  {
    DDLogVerbose(@"%@ addLocation: %@", LOG_TAG, location);
    
    [self.mapView removeAnnotations:[self.mapView annotations]];
    
    LocationAnnotation *locationAnnotation = [[LocationAnnotation alloc] init];
    locationAnnotation.coordinate = location.coordinate;
    
    [self.mapView addAnnotation:locationAnnotation];
    [self.mapView setShowsUserLocation:NO];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self centerMap];
    });
}

- (void)centerMap {
    DDLogVerbose(@"%@ centerMap", LOG_TAG);
    
    CGFloat deltaLongitude = self.geolocationDescriptor.mapLongitudeDelta;
    CGFloat deltaLatitude = self.geolocationDescriptor.mapLatitudeDelta;
    
    CLLocationCoordinate2D northWestCorner = CLLocationCoordinate2DMake(self.userLocation.coordinate.latitude + (deltaLatitude / 2), self.userLocation.coordinate.longitude - (deltaLongitude / 2));
    CLLocationCoordinate2D southEastCorner = CLLocationCoordinate2DMake(self.userLocation.coordinate.latitude - (deltaLatitude / 2), self.userLocation.coordinate.longitude + (deltaLongitude / 2));
    
    MKMapPoint pointNorthWestCorner = MKMapPointForCoordinate (northWestCorner);
    MKMapPoint pointSouthEastCorner = MKMapPointForCoordinate (southEastCorner);
    
    MKMapRect mapRect = MKMapRectMake(pointNorthWestCorner.x, pointNorthWestCorner.y, pointSouthEastCorner.x - pointNorthWestCorner.x, pointSouthEastCorner.y - pointNorthWestCorner.y);
    [self.mapView setVisibleMapRect:mapRect animated:NO];
    
    if (!self.geolocationDescriptor.isValidLocalMap) {
        [self saveMapSnapshot];
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

#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    DDLogVerbose(@"%@ mapView: %@ viewForAnnotation:%@", LOG_TAG, mapView, annotation);
    
    if ([annotation isKindOfClass:[LocationAnnotation class]]) {
        static NSString * const identifier = @"LocationAnnotationView";
        
        MKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        
        if (annotationView) {
            annotationView.annotation = annotation;
        } else {
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        }
        
        for (UIView *view in annotationView.subviews) {
            if ([view isKindOfClass:[LocationAnnotationView class]]) {
                [view removeFromSuperview];
            }
        }
        
        annotationView.canShowCallout = NO;
        
        NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"LocationAnnotationView" owner:self options:nil];
        LocationAnnotationView  *locationAnnotationView = [objects objectAtIndex:0];
        locationAnnotationView.frame = CGRectMake(-(DESIGN_ANNOTATION_CELL_MAX_HEIGHT * Design.HEIGHT_RATIO) / 2, -(DESIGN_ANNOTATION_CELL_MAX_HEIGHT * Design.HEIGHT_RATIO) / 2, DESIGN_ANNOTATION_CELL_MAX_HEIGHT * Design.HEIGHT_RATIO, DESIGN_ANNOTATION_CELL_MAX_HEIGHT * Design.HEIGHT_RATIO);
        [annotationView addSubview:locationAnnotationView];
        [locationAnnotationView bindWithAvatar:self.avatarImage];
        
        return annotationView;
    }
    
    return nil;
}

- (void)saveMapSnapshot {
    DDLogVerbose(@"%@ saveMapSnapshot", LOG_TAG);
    
    MKMapSnapshotOptions *options = [[MKMapSnapshotOptions alloc] init];
    options.region = self.mapView.region;
    options.size = self.mapView.frame.size;
    options.scale = [[UIScreen mainScreen] scale];
    
    MKMapSnapshotter *snapshotter = [[MKMapSnapshotter alloc] initWithOptions:options];
    [snapshotter startWithCompletionHandler:^(MKMapSnapshot *snapshot, NSError *error) {
        if (error) {
            return;
        }
    
        UIImage *image = snapshot.image;
        
        UIView *mapSnapshotView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
        UIImageView *mapSnapshotImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
        mapSnapshotImageView.image = image;
        [mapSnapshotView addSubview:mapSnapshotImageView];
        
        LocationAnnotation *locationAnnotation = [[LocationAnnotation alloc] init];
        locationAnnotation.coordinate = self.userLocation.coordinate;
        
        CGFloat containerWidth =  (DESIGN_ANNOTATION_CELL_MAX_HEIGHT * Design.HEIGHT_RATIO) + (40 * Design.HEIGHT_RATIO);
        CGFloat containerHeight = (DESIGN_ANNOTATION_CELL_MAX_HEIGHT * Design.HEIGHT_RATIO) + (40 * Design.HEIGHT_RATIO);
        
        UIView *containerLocation = [[UIView alloc]initWithFrame:CGRectMake(0, 0, containerWidth, containerHeight)];
        containerLocation.backgroundColor = [UIColor clearColor];
        
        NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"LocationAnnotationView" owner:self options:nil];
        LocationAnnotationView  *locationAnnotationView = [objects objectAtIndex:0];
        locationAnnotationView.frame = CGRectMake(0, 0, DESIGN_ANNOTATION_CELL_MAX_HEIGHT * Design.HEIGHT_RATIO, DESIGN_ANNOTATION_CELL_MAX_HEIGHT * Design.HEIGHT_RATIO);
        locationAnnotationView.center = containerLocation.center;
        [locationAnnotationView bindWithAvatar:self.avatarImage];
        locationAnnotationView.backgroundColor = [UIColor clearColor];
        
        [containerLocation addSubview:locationAnnotationView];
        containerLocation.frame = CGRectMake([snapshot pointForCoordinate:self.userLocation.coordinate].x - (containerLocation.frame.size.width / 2), [snapshot pointForCoordinate:self.userLocation.coordinate].y - (containerLocation.frame.size.height / 2), containerLocation.frame.size.width, containerLocation.frame.size.height);
        [mapSnapshotView addSubview:containerLocation];
                
        UIGraphicsBeginImageContextWithOptions(image.size, YES, image.scale);
        [mapSnapshotView drawViewHierarchyInRect:mapSnapshotView.bounds afterScreenUpdates:YES];
        UIImage *mapImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        NSData *data = UIImageJPEGRepresentation(mapImage, 1.0);
        
        NSString *fileName = [NSString stringWithFormat:@"%@_%@", [[NSProcessInfo processInfo] globallyUniqueString], @".jpg"];
        NSURL *url = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:fileName]];
        [data writeToURL:url options:NSDataWritingAtomic error:nil];
        
        if ([self.locationActionDelegate respondsToSelector:@selector(saveMapWithPath:geolocationDescriptor:)]) {
            [self.locationActionDelegate saveMapWithPath:url.path geolocationDescriptor:self.geolocationDescriptor];
        }
    }];
}

- (void)startDeleteAnimation {
    DDLogVerbose(@"%@ startDeleteAnimation", LOG_TAG);
    
    self.contentDeleteView.hidden = NO;
    CGRect contentDeleteFrame = self.contentDeleteView.frame;
    contentDeleteFrame.size.width = 0;
    self.contentDeleteView.frame = contentDeleteFrame;
    contentDeleteFrame.size.width = self.contentImageView.frame.size.width;
    [UIView animateWithDuration:DESIGN_DELETE_ANIMATION_DURATION
                     animations:^{
        self.contentDeleteView.frame = contentDeleteFrame;
    } completion:^(BOOL finished) {
        if ([self.deleteActionDelegate respondsToSelector:@selector(deleteItem:)]) {
            [self.deleteActionDelegate deleteItem:self.item];
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

- (void)onTouchUpInsideImage:(UITapGestureRecognizer *)tapGesture {
    DDLogVerbose(@"%@ onTouchUpInsideImage: %@", LOG_TAG, tapGesture);
    
    if (self.isSelectItemMode) {
        if ([self.selectItemDelegate respondsToSelector:@selector(didSelectItem:)]) {
            [self.selectItemDelegate didSelectItem:self.item];
        }
        return;
    }
    
    if (![self.item isDeletedItem] && self.contentImageView.image && [self.locationActionDelegate respondsToSelector:@selector(fullscreenMapWithGeolocationDescriptor:avatar:)]) {
        [self.locationActionDelegate fullscreenMapWithGeolocationDescriptor:self.geolocationDescriptor avatar:self.avatarImage];
    }
}

- (void)onTouchUpInsideMap:(UITapGestureRecognizer *)tapGesture {
    DDLogVerbose(@"%@ onTouchUpInsideMap: %@", LOG_TAG, tapGesture);
    
    if (self.isSelectItemMode) {
        if ([self.selectItemDelegate respondsToSelector:@selector(didSelectItem:)]) {
            [self.selectItemDelegate didSelectItem:self.item];
        }
        return;
    }
    
    if (![self.item isDeletedItem] && [self.locationActionDelegate respondsToSelector:@selector(fullscreenMapWithGeolocationDescriptor:avatar:)]) {
        [self.locationActionDelegate fullscreenMapWithGeolocationDescriptor:self.geolocationDescriptor avatar:self.avatarImage];
    }
}

- (void)onTouchUpReplyView:(UITapGestureRecognizer *)tapGesture {
    DDLogVerbose(@"%@ onTouchUpReplyView: %@", LOG_TAG, tapGesture);
    
    if ([self.replyItemDelegate respondsToSelector:@selector(didSelectReplyTo:)]) {
        [self.replyItemDelegate didSelectReplyTo:self.item.replyTo];
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

#pragma - mark UIView (UIViewRendering)

- (void)drawRect:(CGRect)rect {
    DDLogVerbose(@"%@ drawRect: %@", LOG_TAG, NSStringFromCGRect(rect));
    
    [super drawRect:rect];
    
    CGFloat width = self.contentImageView.bounds.size.width;
    CGFloat shadowOffset = 2;
    CGFloat height = self.contentImageView.bounds.size.height - shadowOffset;
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
    self.contentImageView.layer.masksToBounds = YES;
    self.contentImageView.layer.mask = mask;
    
    CAShapeLayer *maskDelete = [CAShapeLayer layer];
    maskDelete.path = path.CGPath;
    self.contentDeleteView.layer.masksToBounds = YES;
    self.contentDeleteView.layer.mask = maskDelete;
    
    CAShapeLayer *maskMap = [CAShapeLayer layer];
    maskMap.path = path.CGPath;
    self.mapView.layer.masksToBounds = YES;
    self.mapView.layer.mask = maskMap;
    
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

@end
