/*
 *  Copyright (c) 2020 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "Item.h"

//
// Interface: CallItem
//

@class TLCallDescriptor;

@interface CallItem : Item

@property TLCallDescriptor *callDescriptor;

- (instancetype)initWithCallDescriptor:(TLCallDescriptor *)callDescriptor;

- (NSString *)getInformation:(NSString *)contactName;

@end
