/*
 *  Copyright (c) 2019 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <MapKit/MapKit.h>

@class UICallParticipantLocation;

@interface LocationAnnotation : MKPointAnnotation

@property(nonatomic, nullable) UICallParticipantLocation *uiCallParticipantLocation;

@end
