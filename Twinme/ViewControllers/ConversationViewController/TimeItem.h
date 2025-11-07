/*
 *  Copyright (c) 2017 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Christian Jacquemot (Christian.Jacquemot@twinlife-systems.com)
 *   Chedi Baccari (Chedi.Baccari@twinlife-systems.com)
 */

#import "Item.h"

//
// Interface: TimeItem
//

@interface TimeItem : Item

- (TimeItem *)initWithTimestamp:(int64_t)timestamp;

@end
