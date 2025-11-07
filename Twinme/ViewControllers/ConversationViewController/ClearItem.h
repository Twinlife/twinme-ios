/*
 *  Copyright (c) 2022 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "Item.h"

@class TLClearDescriptor;

//
// Interface: ClearItem
//

@interface ClearItem : Item

@property TLClearDescriptor *clearDescriptor;

- (instancetype)initWithClearDescriptor:(TLClearDescriptor *)clearDescriptor;

@end
