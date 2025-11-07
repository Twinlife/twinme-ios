/*
 *  Copyright (c) 2022 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "Item.h"

@class TLClearDescriptor;

@interface PeerClearItem : Item

@property TLClearDescriptor *clearDescriptor;

@property NSString *name;

- (instancetype)initWithClearDescriptor:(TLClearDescriptor *)clearDescriptor;

@end
