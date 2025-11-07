/*
 *  Copyright (c) 2019 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "ItemCell.h"

//
// Interface: PeerLocationItemCell
//

@protocol LocationActionDelegate;

@interface PeerLocationItemCell  : ItemCell

@property (weak, nonatomic) id<LocationActionDelegate> locationActionDelegate;

@end
