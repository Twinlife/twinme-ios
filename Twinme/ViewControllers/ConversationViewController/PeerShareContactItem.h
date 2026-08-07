/*
 *  Copyright (c) 2026 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "Item.h"

//
// Interface: PeerShareContactItem
//

@class TLContactShareDescriptor;
@class TLTwincodeDescriptor;

@interface PeerShareContactItem : Item

@property (nullable) TLContactShareDescriptor *contactShareDescriptor;
@property (nullable) TLTwincodeDescriptor *twincodeDescriptor;

- (nonnull instancetype)initWithContactShareDescriptor:(nonnull TLContactShareDescriptor *)contactShareDescriptor;

- (nonnull instancetype)initWithTwincodeDescriptor:(nonnull TLTwincodeDescriptor *)twincodeDescriptor;

@end
