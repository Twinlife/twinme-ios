/*
 *  Copyright (c) 2024 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

//
// Protocol: CallMapDelegate
//

@protocol MapViewDelegate <NSObject>

- (void)touchMap;

@end

#import <MapKit/MapKit.h>

@interface MapView : MKMapView

@property (weak, nonatomic) id<MapViewDelegate> mapDelegate;

@end
