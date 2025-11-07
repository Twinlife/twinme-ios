/*
 *  Copyright (c) 2019-2021 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "Item.h"

//
// Interface: PeerLocationItem
//

@interface PeerLocationItem : Item

@property TLGeolocationDescriptor *geolocationDescriptor;

- (instancetype)initWithGeolocationDescriptor:(TLGeolocationDescriptor *)geolocationDescriptor replyToDescriptor:(TLDescriptor *)replyToDescriptor;

- (void)updateGeolocationDescriptor:(TLGeolocationDescriptor *)geolocationDescriptor;

@end
