/*
 *  Copyright (c) 2017-2021 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Christian Jacquemot (Christian.Jacquemot@twinlife-systems.com)
 *   Chedi Baccari (Chedi.Baccari@twinlife-systems.com)
 *   Thibaud David (contact@thibauddavid.com)
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "Item.h"

//
// Interface: PeerImageItem
//

@interface PeerImageItem : Item

@property TLImageDescriptor *imageDescriptor;

- (instancetype)initWithImageDescriptor:(TLImageDescriptor *)imageDescriptor replyToDescriptor:(TLDescriptor *)replyToDescriptor;

@end
