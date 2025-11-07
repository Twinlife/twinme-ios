/*
 *  Copyright (c) 2017-2021 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Christian Jacquemot (Christian.Jacquemot@twinlife-systems.com)
 *   Chedi Baccari (Chedi.Baccari@twinlife-systems.com)
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "Item.h"

//
// Interface: PeerAudioItem
//

@interface PeerAudioItem : Item

@property TLAudioDescriptor *audioDescriptor;

- (instancetype)initWithAudioDescriptor:(TLAudioDescriptor *)audioDescriptor replyToDescriptor:(TLDescriptor *)replyToDescriptor;

@end
