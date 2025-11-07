/*
 *  Copyright (c) 2024 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import "CallMapView.h"

#import <Twinlife/TLConversationService.h>

#import "LocationAnnotation.h"
#import "LocationAnnotationView.h"

#import <TwinmeCommon/CallParticipant.h>
#import <TwinmeCommon/Design.h>
#import <Utils/NSString+Utils.h>

#import "DeviceAuthorization.h"
#import "UICallParticipantLocation.h"
#import "MapView.h"

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static const CGFloat DESIGN_ANNOTATION_CELL_MAX_HEIGHT = 86.0f;

static const CGFloat DESIGN_CORNER_RADIUS = 14;
static const CGFloat DESIGN_MIN_MARGIN_ACTION = 34;

//
// Interface: CallMapView ()
//

@interface CallMapView()<MKMapViewDelegate, CLLocationManagerDelegate, MapViewDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet MapView *mapView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *closeImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *closeImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *closeViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *closeViewWidthConstraint;
@property (weak, nonatomic) IBOutlet UIView *closeView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *shareLocationViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *shareLocationViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *shareLocationViewBottomConstraint;
@property (weak, nonatomic) IBOutlet UIView *shareLocationView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *shareLocationImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *shareLocationImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fullScreenViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fullScreenViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fullScreenViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *fullScreenView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fullScreenImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *fullScreenImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *resetViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *resetViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *resetViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *resetView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *resetImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *resetImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mapTypeViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mapTypeViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mapTypeViewBottomConstraint;
@property (weak, nonatomic) IBOutlet UIView *mapTypeView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mapTypeImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *mapTypeImageView;

@property (nonatomic) NSMutableArray *locationsArray;

@property (nonatomic) BOOL showBackgroundLocationAlert;
@property (nonatomic) BOOL showFineLocationAlert;
@property (nonatomic) BOOL isFullScreen;
@property (nonatomic) BOOL moveMapAutomatically;

@end

//
// Implementation: CallMapView
//

#undef LOG_TAG
#define LOG_TAG @"CallMapView"

@implementation CallMapView

- (instancetype)init {
    DDLogVerbose(@"%@ init", LOG_TAG);
    
    self = [super init];
    
    self.frame = CGRectMake(0, 0, Design.DISPLAY_WIDTH, Design.DISPLAY_HEIGHT);
        
    if (self) {
        _isLocationShared = NO;
        _canShareLocation = NO;
        _moveMapAutomatically = YES;
        _isFullScreen = NO;
        _canShareBackgroundLocation = NO;
        _showBackgroundLocationAlert = NO;
        _canShareFineLocation = NO;
        _showFineLocationAlert = NO;
        _locationsArray = [[NSMutableArray alloc]init];
    }
    return self;
}

- (void)loadViews {
    DDLogVerbose(@"%@ loadViews", LOG_TAG);
    
    [self initViews];
}

- (void)initMapView {
    DDLogVerbose(@"%@ initMapView", LOG_TAG);
    
    if (self.isLocationShared) {
        self.shareLocationView.accessibilityLabel = TwinmeLocalizedString(@"call_view_controller_location_stop", nil);
        self.shareLocationImageView.image = [UIImage imageNamed:@"ShareLocationIcon"];
    } else {
        self.shareLocationView.accessibilityLabel = TwinmeLocalizedString(@"call_view_controller_location_share", nil);
        self.shareLocationImageView.image = [UIImage imageNamed:@"CallLocationIcon"];
    }
    
    if (self.canShareLocation) {
        self.shareLocationView.alpha = 1.0f;
    } else {
        self.shareLocationView.alpha = 0.5f;
    }
    
    if (self.isLocationShared) {
        if (self.canShareLocation && !self.canShareBackgroundLocation && !self.showBackgroundLocationAlert) {
            self.showBackgroundLocationAlert = YES;
            
            if ([self.callMapDelegate respondsToSelector:@selector(showBackgroundAlert)]) {
                [self.callMapDelegate showBackgroundAlert];
            }
        } else if (self.canShareLocation && !self.canShareFineLocation && !self.showFineLocationAlert) {
            self.showFineLocationAlert = YES;
            
            if ([self.callMapDelegate respondsToSelector:@selector(showExactLocationAlert)]) {
                [self.callMapDelegate showExactLocationAlert];
            }
        }
    }
}

- (void)zoomToParticipant:(int)participantId {
    DDLogVerbose(@"%@ zoomToParticipant", LOG_TAG);
    
    for (UICallParticipantLocation *uiCallParticipantLocation in self.locationsArray) {
        
        if (uiCallParticipantLocation.participantId == participantId && uiCallParticipantLocation.annotationView) {
            [self.mapView showAnnotations:@[uiCallParticipantLocation.annotationView.annotation] animated:YES];
        }
    }
}

- (void)updateLocaleLocation:(double)latitude longitude:(double)longitude {
    DDLogVerbose(@"%@ updateLocaleLocation", LOG_TAG);
    
    [self addlocation:-1 name:self.name avatar:self.avatar latitude:latitude longitude:longitude];
}

- (void)updateLocation:(CallParticipant *)callParticipant geolocationDescriptor:(TLGeolocationDescriptor *)geolocationDescriptor {
    DDLogVerbose(@"%@ updateLocation: %@ geolocationDescriptor: %@", LOG_TAG, callParticipant, geolocationDescriptor);
    
    [self addlocation:callParticipant.participantId name:callParticipant.name avatar:callParticipant.avatar latitude:geolocationDescriptor.latitude longitude:geolocationDescriptor.longitude];
}

- (void)addlocation:(int)participantId name:(NSString *)name avatar:(UIImage *)avatar latitude:(double)latitude longitude:(double)longitude {
    DDLogVerbose(@"%@ addlocation: %d name: %@ avatar: %@ latitude: %f longitude: %f", LOG_TAG, participantId, name, avatar, latitude, longitude);
    
    BOOL added = NO;
    
    for (UICallParticipantLocation *uiCallParticipantLocation in self.locationsArray) {
        
        if (uiCallParticipantLocation.participantId == participantId) {
            added = YES;
            [uiCallParticipantLocation updateName:name avatar:avatar];
            [uiCallParticipantLocation updateLatitude:latitude longitude:longitude];
            break;
        }
    }
    
    if (!added) {
        UICallParticipantLocation *uiCallParticipantLocation = [[UICallParticipantLocation alloc]initWithCallParticipant:participantId name:name avatar:avatar latitude:latitude longitude:longitude];
        [self.locationsArray addObject:uiCallParticipantLocation];
    }
    
    [self updateMap];
}

- (void)deleteLocation:(int)participantId {
    DDLogVerbose(@"%@ deleteLocation: %d", LOG_TAG, participantId);
    
    for (UICallParticipantLocation *uiCallParticipantLocation in self.locationsArray) {
        
        if (uiCallParticipantLocation.participantId == participantId) {
            [self.locationsArray removeObject:uiCallParticipantLocation];
            break;
        }
    }
    
    [self updateMap];
}

- (void)updateMap {
    DDLogVerbose(@"%@ updateMap", LOG_TAG);
    
    [self.mapView removeAnnotations:[self.mapView annotations]];
    
    BOOL addAnnotation = NO;
    
    for (UICallParticipantLocation *uiCallParticipantLocation in self.locationsArray) {
        LocationAnnotation *locationAnnotation = [[LocationAnnotation alloc] init];
        locationAnnotation.uiCallParticipantLocation = uiCallParticipantLocation;
        locationAnnotation.coordinate = CLLocationCoordinate2DMake(uiCallParticipantLocation.latitude, uiCallParticipantLocation.longitude);
        
        if (uiCallParticipantLocation.annotationView) {
            [self.mapView removeAnnotation:uiCallParticipantLocation.annotationView.annotation];
        } else {
            addAnnotation = YES;
            self.moveMapAutomatically = YES;
        }
        
        [self.mapView addAnnotation:locationAnnotation];
    }
    
    if (addAnnotation || self.moveMapAutomatically) {
        [self.mapView showAnnotations:self.mapView.annotations animated:YES];
    }
}

#pragma mark - MapViewDelegate

- (void)touchMap {
    DDLogVerbose(@"%@ touchMap", LOG_TAG);
    
    self.moveMapAutomatically = NO;
}

#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    DDLogVerbose(@"%@ mapView: %@ viewForAnnotation:%@", LOG_TAG, mapView, annotation);
    
    if ([annotation isKindOfClass:[LocationAnnotation class]]) {
        LocationAnnotation *locationAnnotation = (LocationAnnotation *)annotation;
        UICallParticipantLocation *callParticipantLocation = locationAnnotation.uiCallParticipantLocation;
        locationAnnotation.title = callParticipantLocation.name;
        
        static NSString * const identifier = @"LocationAnnotationView";
        
        MKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        
        if (annotationView) {
            annotationView.annotation = locationAnnotation;
        } else {
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:locationAnnotation reuseIdentifier:identifier];
        }
        
        annotationView.canShowCallout = NO;
        
        for (UIView *view in annotationView.subviews) {
            if ([view isKindOfClass:[LocationAnnotationView class]]) {
                [view removeFromSuperview];
            }
        }
        
        NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"LocationAnnotationView" owner:self options:nil];
        LocationAnnotationView  *locationAnnotationView = [objects objectAtIndex:0];
        locationAnnotationView.frame = CGRectMake(-(DESIGN_ANNOTATION_CELL_MAX_HEIGHT * Design.HEIGHT_RATIO) / 2, -(DESIGN_ANNOTATION_CELL_MAX_HEIGHT * Design.HEIGHT_RATIO) / 2, DESIGN_ANNOTATION_CELL_MAX_HEIGHT * Design.HEIGHT_RATIO, DESIGN_ANNOTATION_CELL_MAX_HEIGHT * Design.HEIGHT_RATIO);
        
        [annotationView addSubview:locationAnnotationView];
        
        [locationAnnotationView bindWithAvatar:locationAnnotation.uiCallParticipantLocation.avatar];
        
        [callParticipantLocation updateAnnotation:annotationView];
        
        return annotationView;
    }
    
    return nil;
}

- (MKCoordinateRegion)getMapRegion {
    
    return self.mapView.region;
}

#pragma mark - Private methods

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
        
    self.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"CallMapView" owner:self options:nil];
    UIView *view = [objects objectAtIndex:0];
    view.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:[objects objectAtIndex:0]];
    
    self.backgroundColor = [UIColor clearColor];
    
    self.containerViewLeadingConstraint.constant = DESIGN_MIN_MARGIN_ACTION * Design.WIDTH_RATIO;
    self.containerViewTrailingConstraint.constant = DESIGN_MIN_MARGIN_ACTION * Design.WIDTH_RATIO;

    self.containerView.backgroundColor = [UIColor colorWithRed:60./255. green:60./255. blue:60./255. alpha:1];
    self.containerView.clipsToBounds = YES;
    self.containerView.layer.cornerRadius = DESIGN_CORNER_RADIUS;
    
    self.mapView.delegate = self;
    self.mapView.clipsToBounds = YES;
    self.mapView.mapType = MKMapTypeStandard;
    self.mapView.mapDelegate = self;
        
    self.closeImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.closeViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.closeViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    
    self.closeView.userInteractionEnabled = YES;
    self.closeView.isAccessibilityElement = YES;
    self.closeView.accessibilityLabel = TwinmeLocalizedString(@"application_cancel", nil);
    UITapGestureRecognizer *closeGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleCloseTapGesture:)];
    [self.closeView addGestureRecognizer:closeGestureRecognizer];
    
    self.shareLocationViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.shareLocationViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.shareLocationViewBottomConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.shareLocationView.backgroundColor = [UIColor whiteColor];
    self.shareLocationView.userInteractionEnabled = YES;
    self.shareLocationView.layer.shadowOpacity = Design.SHADOW_OPACITY;
    self.shareLocationView.layer.shadowOffset = Design.SHADOW_OFFSET;
    self.shareLocationView.layer.shadowRadius = Design.SHADOW_RADIUS;
    self.shareLocationView.layer.shadowColor = Design.SHADOW_COLOR_DEFAULT.CGColor;
    self.shareLocationView.layer.cornerRadius = self.shareLocationViewHeightConstraint.constant * 0.5;
    self.shareLocationView.layer.masksToBounds = NO;
    [self.shareLocationView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleShareLocationTapGesture:)]];
    
    self.shareLocationImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.shareLocationImageView.userInteractionEnabled = NO;
        
    self.fullScreenViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.fullScreenViewBottomConstraint.constant *= Design.HEIGHT_RATIO;
    self.fullScreenViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.fullScreenView.backgroundColor = [UIColor whiteColor];
    self.fullScreenView.userInteractionEnabled = YES;
    self.fullScreenView.isAccessibilityElement = YES;
    self.fullScreenView.layer.shadowOpacity = Design.SHADOW_OPACITY;
    self.fullScreenView.layer.shadowOffset = Design.SHADOW_OFFSET;
    self.fullScreenView.layer.shadowRadius = Design.SHADOW_RADIUS;
    self.fullScreenView.layer.shadowColor = Design.SHADOW_COLOR_DEFAULT.CGColor;
    self.fullScreenView.layer.cornerRadius = self.fullScreenViewHeightConstraint.constant * 0.5;
    self.fullScreenView.layer.masksToBounds = NO;
    [self.fullScreenView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleFullScreenTapGesture:)]];
    
    self.fullScreenImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
        
    self.resetViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.resetViewBottomConstraint.constant *= Design.HEIGHT_RATIO;
    self.resetViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.resetView.backgroundColor = [UIColor whiteColor];
    self.resetView.userInteractionEnabled = YES;
    self.resetView.isAccessibilityElement = YES;
    self.resetView.layer.shadowOpacity = Design.SHADOW_OPACITY;
    self.resetView.layer.shadowOffset = Design.SHADOW_OFFSET;
    self.resetView.layer.shadowRadius = Design.SHADOW_RADIUS;
    self.resetView.layer.shadowColor = Design.SHADOW_COLOR_DEFAULT.CGColor;
    self.resetView.layer.cornerRadius = self.resetViewHeightConstraint.constant * 0.5;
    self.resetView.layer.masksToBounds = NO;
    [self.resetView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleResetZoomTapGesture:)]];
    
    self.resetImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.mapTypeViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.mapTypeViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.mapTypeViewBottomConstraint.constant *= Design.HEIGHT_RATIO;

    self.mapTypeView.backgroundColor = [UIColor whiteColor];
    self.mapTypeView.userInteractionEnabled = YES;
    self.mapTypeView.isAccessibilityElement = YES;
    
    self.mapTypeView.layer.shadowOpacity = Design.SHADOW_OPACITY;
    self.mapTypeView.layer.shadowOffset = Design.SHADOW_OFFSET;
    self.mapTypeView.layer.shadowRadius = Design.SHADOW_RADIUS;
    self.mapTypeView.layer.shadowColor = Design.SHADOW_COLOR_DEFAULT.CGColor;
    self.mapTypeView.layer.cornerRadius = self.mapTypeViewHeightConstraint.constant * 0.5;
    self.mapTypeView.layer.masksToBounds = NO;
        
    [self.mapTypeView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleMapTypeTapGesture:)]];
    
    self.mapTypeImageView.layer.borderWidth = 4.0f;
    self.mapTypeImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.mapTypeImageView.layer.cornerRadius = self.mapTypeViewHeightConstraint.constant * 0.5;
    self.mapTypeImageView.clipsToBounds = YES;
    self.mapTypeImageView.image = [UIImage imageNamed:@"SatelliteIcon"];
}

- (void)handleShareLocationTapGesture:(UITapGestureRecognizer *)recognizer {
    DDLogVerbose(@"%@ handleShareLocationTapGesture", LOG_TAG);
        
    if (recognizer.state == UIGestureRecognizerStateEnded && self.canShareLocation) {
        
        self.moveMapAutomatically = YES;
        [self.mapView showAnnotations:self.mapView.annotations animated:YES];
        
        if (self.isLocationShared) {
            self.isLocationShared = NO;
            [self.callMapDelegate stopShareLocation];

            self.shareLocationView.accessibilityLabel = TwinmeLocalizedString(@"call_view_controller_location_share", nil);
            self.shareLocationImageView.image = [UIImage imageNamed:@"CallLocationIcon"];
        } else {
            self.isLocationShared = YES;
            
            [self.callMapDelegate startShareLocation:self.mapView.region.span.latitudeDelta mapLongitudeDelta:self.mapView.region.span.longitudeDelta];
            
            self.shareLocationView.accessibilityLabel = TwinmeLocalizedString(@"call_view_controller_location_stop", nil);
            self.shareLocationImageView.image = [UIImage imageNamed:@"ShareLocationIcon"];
        }
    }
}

- (void)handleMapTypeTapGesture:(UITapGestureRecognizer *)recognizer {
    DDLogVerbose(@"%@ handleMapTypeTapGesture", LOG_TAG);
    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        if (self.mapView.mapType == MKMapTypeStandard) {
            self.mapView.mapType = MKMapTypeSatellite;
            self.mapTypeImageView.image = [UIImage imageNamed:@"MapIcon"];
        } else {
            self.mapView.mapType = MKMapTypeStandard;
            self.mapTypeImageView.image = [UIImage imageNamed:@"SatelliteIcon"];
        }
    }
}

- (void)handleCloseTapGesture:(UITapGestureRecognizer *)recognizer {
    DDLogVerbose(@"%@ handleCloseTapGesture", LOG_TAG);
    
    if (recognizer.state == UIGestureRecognizerStateEnded && [self.callMapDelegate respondsToSelector:@selector(closeMap)]) {
        [self.callMapDelegate closeMap];
    }
}

- (void)handleFullScreenTapGesture:(UITapGestureRecognizer *)recognizer {
    DDLogVerbose(@"%@ handleFullScreenTapGesture", LOG_TAG);
    
    if (recognizer.state == UIGestureRecognizerStateEnded && [self.callMapDelegate respondsToSelector:@selector(fullScreenMap:)]) {
        
        if (self.isFullScreen) {
            self.isFullScreen = NO;
            self.closeView.hidden = NO;
            self.closeImageView.hidden = NO;
            self.fullScreenImageView.image = [UIImage imageNamed:@"FullScreenIcon"];
            self.containerViewLeadingConstraint.constant = DESIGN_MIN_MARGIN_ACTION * Design.WIDTH_RATIO;
            self.containerViewTrailingConstraint.constant = DESIGN_MIN_MARGIN_ACTION * Design.WIDTH_RATIO;
        } else {
            self.isFullScreen = YES;
            self.closeView.hidden = YES;
            self.closeImageView.hidden = YES;
            self.fullScreenImageView.image = [UIImage imageNamed:@"MinimizeIcon"];
            self.containerViewLeadingConstraint.constant = 0;
            self.containerViewTrailingConstraint.constant = 0;
        }
        
        [self.callMapDelegate fullScreenMap:self.isFullScreen];
    }
}

- (void)handleResetZoomTapGesture:(UITapGestureRecognizer *)recognizer {
    DDLogVerbose(@"%@ handleResetZoomTapGesture", LOG_TAG);
    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        self.moveMapAutomatically = YES;
        [self.mapView showAnnotations:self.mapView.annotations animated:YES];
    }
}

@end
