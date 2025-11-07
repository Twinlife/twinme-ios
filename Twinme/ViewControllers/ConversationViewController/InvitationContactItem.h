/*
 *  Copyright (c) 2020 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "Item.h"

//
// Interface: InvitationContactItem
//

@class TLTwincodeDescriptor;

@interface InvitationContactItem : Item

@property TLTwincodeDescriptor *twincodeDescriptor;

- (instancetype)initWithTwincodeDescriptor:(TLTwincodeDescriptor *)twincodeDescriptor;

@end
