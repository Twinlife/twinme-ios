/*
 *  Copyright (c) 2019 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */


#import <MapKit/MapKit.h>

//
// Interface: LocationAnnotationView
//

@interface LocationAnnotationView : MKAnnotationView

- (void)bindWithAvatar:(UIImage *)avatar;

@end
