/*
 *  Copyright (c) 2024 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <MapKit/MapKit.h>

@class TLGeolocationDescriptor;
@class CallParticipant;

//
// Protocol: CallMapDelegate
//

@protocol CallMapDelegate <NSObject>

- (void)closeMap;

- (void)fullScreenMap:(BOOL)isFullScreen;

- (void)showBackgroundAlert;

- (void)showExactLocationAlert;

- (void)stopShareLocation;

- (void)startShareLocation:(double)mapLatitudeDelta mapLongitudeDelta:(double)mapLongitudeDelta;

@end

//
// Interface: CallMapView
//

@interface CallMapView : UIView

@property (weak, nonatomic) id<CallMapDelegate> callMapDelegate;
@property (nonatomic) NSString *name;
@property (nonatomic) UIImage *avatar;
@property (nonatomic) BOOL isLocationShared;
@property (nonatomic) BOOL canShareLocation;
@property (nonatomic) BOOL canShareBackgroundLocation;
@property (nonatomic) BOOL canShareFineLocation;

- (void)loadViews;

- (void)initMapView;

- (void)zoomToParticipant:(int)participantId;

- (void)updateLocaleLocation:(double)latitude longitude:(double)longitude;

- (void)updateLocation:(CallParticipant *)callParticipant geolocationDescriptor:(TLGeolocationDescriptor *)geolocationDescriptor;

- (void)deleteLocation:(int)participantId;

- (MKCoordinateRegion)getMapRegion;

@end
