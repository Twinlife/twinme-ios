/*
 *  Copyright (c) 2017-2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Chedi Baccari (Chedi.Baccari@twinlife-systems.com)
 *   Christian Jacquemot (Christian.Jacquemot@twinlife-systems.com)
 */

#import "ItemCell.h"

//
// Interface: PeerAudioItemCell
//

@protocol AudioActionDelegate;

@interface PeerAudioItemCell : ItemCell

@property (weak, nonatomic) id<AudioActionDelegate> audioActionDelegate;

@end
