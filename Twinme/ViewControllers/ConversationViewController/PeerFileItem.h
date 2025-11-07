/*
 *  Copyright (c) 2018-2021 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "Item.h"

//
// Interface: PeerFileItem
//

@interface PeerFileItem : Item

@property TLNamedFileDescriptor *namedFileDescriptor;

- (instancetype)initWithFileDescriptor:(TLNamedFileDescriptor *)namedFileDescriptor replyToDescriptor:(TLDescriptor *)replyToDescriptor;

@end
