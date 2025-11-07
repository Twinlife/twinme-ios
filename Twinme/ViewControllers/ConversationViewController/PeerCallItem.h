/*
 *  Copyright (c) 2020 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "Item.h"

//
// Interface: PeerCallItem
//

@class TLCallDescriptor;

@interface PeerCallItem : Item

@property TLCallDescriptor *peerCallDescriptor;

- (instancetype)initWithCallDescriptor:(TLCallDescriptor *)callDescriptor;

- (NSString *)getInformation:(NSString *)contactName;

@end
