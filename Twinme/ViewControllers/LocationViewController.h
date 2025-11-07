/*
 *  Copyright (c) 2019 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <TwinmeCommon/AbstractTwinmeViewController.h>

//
// Interface: LocationViewController
//

@class TLGeolocationDescriptor;

@interface LocationViewController : AbstractTwinmeViewController

- (void)initWithAvatar:(UIImage *)avatar descriptor:(TLGeolocationDescriptor *)geolocationDescriptor;

@end
