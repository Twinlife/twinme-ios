/*
 *  Copyright (c) 2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (fabrice.trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <MapKit/MapKit.h>

#import "PreviewLocationViewController.h"
#import "ConversationViewController.h"

#import "LocationAnnotation.h"
#import "LocationAnnotationView.h"

#import "DeviceAuthorization.h"

#import <Utils/NSString+Utils.h>

#import <TwinmeCommon/Design.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static const CGFloat DESIGN_ANNOTATION_CELL_MAX_HEIGHT = 86.0f;

static const CGFloat DESIGN_CORNER_RADIUS = 14;

//
// Interface: PreviewLocationViewController ()
//

@interface PreviewLocationViewController ()<MKMapViewDelegate, CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mapTypeViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mapTypeViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mapTypeViewBottomConstraint;
@property (weak, nonatomic) IBOutlet UIView *mapTypeView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mapTypeImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *mapTypeImageView;

@property (nonatomic) UIImage *annotationAvatar;

@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic) CLLocation *userLocation;

@end

//
// Implementation: PreviewLocationViewController
//

#undef LOG_TAG
#define LOG_TAG @"PreviewLocationViewController"

@implementation PreviewLocationViewController

- (instancetype)initWithCoder:(NSCoder *)coder {
    DDLogVerbose(@"%@ initWithCoder: %@", LOG_TAG, coder);
    
    self = [super initWithCoder:coder];
    
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    DDLogVerbose(@"%@ viewDidLoad", LOG_TAG);
    
    [super viewDidLoad];
}

- (void)close {
    DDLogVerbose(@"%@ close", LOG_TAG);
        
    [self finish];
}

- (void)send:(BOOL)allowCopyText allowCopyFile:(BOOL)allowCopyFile timeout:(int64_t)timeout {
    DDLogVerbose(@"%@ send: %@ allowCopyFile: %@ timeout: %lld", LOG_TAG, allowCopyText ? @"YES" : @"NO", allowCopyFile ? @"YES" : @"NO", timeout);
    
    NSString *message = self.messageTextView.text;
    if ([self.messageTextView.text isEqualToString:TwinmeLocalizedString(@"conversation_view_controller_message", nil)]) {
        message = @"";
    }
    
    if (self.userLocation) {
        [self.previewViewDelegate sendLocation:self.mapView.region.span.latitudeDelta longitudeDelta:self.mapView.region.span.longitudeDelta location:self.userLocation text:message allowCopyText:allowCopyText allowCopyFile:allowCopyFile expireTimeout:timeout];
    }
    
    [self finish];
}

- (void)initWithAvatar:(UIImage *)avatar {
    DDLogVerbose(@"%@ initWithAvatar: %@", LOG_TAG, avatar);
    
    self.annotationAvatar = avatar;
    
    if (!self.locationManager) {
        self.locationManager = [[CLLocationManager alloc]init];
        
        if (self.locationManager.location) {
            self.userLocation = self.locationManager.location;
            [self addLocation:self.userLocation];
        }
        
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    }
    
    CLAuthorizationStatus locationPermission = [DeviceAuthorization deviceLocationAuthorizationStatus];
    switch (locationPermission) {
        case kCLAuthorizationStatusNotDetermined:
            [self.locationManager requestWhenInUseAuthorization];
            break;
            
        case kCLAuthorizationStatusDenied:
        case kCLAuthorizationStatusRestricted:
            [DeviceAuthorization showLocationSettingsAlertInController:self];
            break;
            
        case kCLAuthorizationStatusAuthorizedAlways:
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            [self.locationManager startUpdatingLocation];
            break;
    }
}

#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    DDLogVerbose(@"%@ mapView: %@ viewForAnnotation:%@", LOG_TAG, mapView, annotation);
    
    if ([annotation isKindOfClass:[LocationAnnotation class]]) {
        LocationAnnotation *locationAnnotation = (LocationAnnotation *)annotation;
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
        
        [locationAnnotationView bindWithAvatar:self.annotationAvatar];
                
        return annotationView;
    }
    
    return nil;
}

- (MKCoordinateRegion)getMapRegion {
    
    return self.mapView.region;
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    DDLogVerbose(@"%@ locationManager: %@ didChangeAuthorizationStatus: %d", LOG_TAG, manager, status);
    
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse || status == kCLAuthorizationStatusAuthorizedAlways) {
        [self.locationManager startUpdatingLocation];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    DDLogVerbose(@"%@ locationManager: %@ didUpdateLocations: %@", LOG_TAG, manager, locations);
    
    if (locations.count > 0) {
        self.userLocation = [locations objectAtIndex:0];
        [self addLocation:self.userLocation];
        [self.locationManager stopUpdatingLocation];
    }
}


#pragma mark - Private methods

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    [self.view setBackgroundColor:[UIColor blackColor]];
        
    self.containerViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.containerViewBottomConstraint.constant *= Design.HEIGHT_RATIO;
    self.containerViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.containerViewTrailingConstraint.constant *= Design.WIDTH_RATIO;

    self.containerView.backgroundColor = [UIColor colorWithRed:60./255. green:60./255. blue:60./255. alpha:1];
    self.containerView.clipsToBounds = YES;
    self.containerView.layer.cornerRadius = DESIGN_CORNER_RADIUS;
    
    self.mapView.delegate = self;
    self.mapView.clipsToBounds = YES;
    self.mapView.delegate = self;
    self.mapView.mapType = MKMapTypeStandard;
    
    self.sendView.alpha = 0.5f;
    
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
    
    [super initViews];
}

- (void)finish {
    DDLogVerbose(@"%@ finish", LOG_TAG);
    
    if (self.locationManager) {
        [self.locationManager stopUpdatingLocation];
        self.locationManager = nil;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)addLocation:(CLLocation *)location  {
    DDLogVerbose(@"%@ addLocation: %@", LOG_TAG, location);
    
    [self.mapView removeAnnotations:[self.mapView annotations]];
    
    LocationAnnotation *locationAnnotation = [[LocationAnnotation alloc] init];
    locationAnnotation.coordinate = location.coordinate;
    
    [self.mapView addAnnotation:locationAnnotation];
    
    MKCoordinateSpan span = MKCoordinateSpanMake(0.05, 0.05);
    MKCoordinateRegion region = MKCoordinateRegionMake(location.coordinate, span);
    
    [self.mapView setRegion:region animated:YES];
    [self.mapView regionThatFits:region];
    [self.mapView setShowsUserLocation:NO];
    
    self.sendView.alpha = 1.0;
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

@end
