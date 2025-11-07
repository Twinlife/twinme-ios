/*
 *  Copyright (c) 2019 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <MapKit/MapKit.h>

#import <Twinlife/TLConversationService.h>

#import "LocationViewController.h"

#import "LocationAnnotation.h"
#import "LocationAnnotationView.h"

#import <TwinmeCommon/Design.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static const CGFloat DESIGN_ANNOTATION_CELL_MAX_HEIGHT  = 86.0f;

//
// Interface: LocationViewController ()
//

@interface LocationViewController () <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *closeViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *closeViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *closeViewTopConstraint;
@property (weak, nonatomic) IBOutlet UIView *closeView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *closeImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *closeImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mapTypeViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mapTypeViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mapTypeViewBottomConstraint;
@property (weak, nonatomic) IBOutlet UIView *mapTypeView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mapTypeImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *mapTypeImageView;

@property UIImage *avatar;
@property TLGeolocationDescriptor *geolocationDescriptor;

@property CLLocation *userLocation;

@end

//
// Implementation: LocationViewController
//

#undef LOG_TAG
#define LOG_TAG @"LocationViewController"

@implementation LocationViewController

- (instancetype)initWithCoder:(NSCoder *)coder {
    DDLogVerbose(@"%@ initWithCoder: %@", LOG_TAG, coder);
    
    self = [super initWithCoder:coder];
    
    return self;
}

- (void)viewDidLoad {
    DDLogVerbose(@"%@ viewDidLoad", LOG_TAG);
    
    [super viewDidLoad];
    
    [self initViews];
}

- (void)viewWillAppear:(BOOL)animated {
    DDLogVerbose(@"%@ viewDidLoad", LOG_TAG);
    
    [super viewWillAppear:animated];
    
    CLLocation *location = [[CLLocation alloc]initWithLatitude:self.geolocationDescriptor.latitude longitude:self.geolocationDescriptor.longitude];
    
    [self addLocation:location];
}

- (void)initWithAvatar:(UIImage *)avatar descriptor:(TLGeolocationDescriptor *)geolocationDescriptor {
    DDLogVerbose(@"%@ initWithContact: %@ descriptor: %@", LOG_TAG, avatar, geolocationDescriptor);
    
    self.avatar = avatar;
    self.geolocationDescriptor = geolocationDescriptor;
}

- (void)addLocation:(CLLocation *)location  {
    DDLogVerbose(@"%@ addLocation: %@", LOG_TAG, location);
    
    self.userLocation = location;
    
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
    [self.mapView setVisibleMapRect:mapRect animated:YES];
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
        
        [locationAnnotationView bindWithAvatar:self.avatar];
        
        return annotationView;
    }
    
    return nil;
}

#pragma mark - Actions

- (IBAction)onTouchInsideDimiss:(id)sender {
    DDLogVerbose(@"%@ onTouchInsideDimiss: %@", LOG_TAG, sender);
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Private methods

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    self.mapView.delegate = self;
    self.mapView.mapType = MKMapTypeStandard;
    
    UITapGestureRecognizer *singleTapGesture = [[UITapGestureRecognizer alloc] init];
    [singleTapGesture addTarget:self action:@selector(hideButtons)];
    singleTapGesture.numberOfTapsRequired = 1;
    
    [self.mapView addGestureRecognizer:singleTapGesture];
    
    self.closeViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.closeViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.closeViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.closeView.backgroundColor = [UIColor whiteColor];
    self.closeView.userInteractionEnabled = YES;
    self.closeView.layer.shadowOpacity = Design.SHADOW_OPACITY;
    self.closeView.layer.shadowOffset = Design.SHADOW_OFFSET;
    self.closeView.layer.shadowRadius = Design.SHADOW_RADIUS;
    self.closeView.layer.shadowColor = Design.SHADOW_COLOR_DEFAULT.CGColor;
    self.closeView.layer.cornerRadius = self.closeViewHeightConstraint.constant * 0.5;
    self.closeView.layer.masksToBounds = NO;
    [self.closeView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleCloseTapGesture:)]];
    
    self.closeImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.closeImageView.userInteractionEnabled = NO;
    self.closeImageView.tintColor = [UIColor blackColor];
    
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

- (void)hideButtons {
    DDLogVerbose(@"%@ hideButtons", LOG_TAG);
    
    if ([self.closeView isHidden]) {
        self.closeView.hidden = NO;
        self.mapTypeView.hidden = NO;
    } else {
        self.closeView.hidden = YES;
        self.mapTypeView.hidden = YES;
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
    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

@end
