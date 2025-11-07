/*
 *  Copyright (c) 2018 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "Item.h"

//
// Interface: NameItem
//

@interface NameItem : Item

@property NSString *name;

- (NameItem *)initWithTimestamp:(int64_t)timestamp name:(NSString *)name;

@end
