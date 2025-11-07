/*
 *  Copyright (c) 2018-2021 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "Item.h"

//
// Interface: PeerVideoItem
//

@interface PeerVideoItem : Item

@property TLVideoDescriptor *videoDescriptor;

- (instancetype)initWithVideoDescriptor:(TLVideoDescriptor *)videoDescriptor replyToDescriptor:(TLDescriptor *)replyToDescriptor;

@end
