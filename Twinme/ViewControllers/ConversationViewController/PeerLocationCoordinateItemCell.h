/*
 *  Copyright (c) 2026 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "ItemCell.h"

//
// Interface: PeerLocationCoordinateItemCell
//

@protocol LocationActionDelegate;

@interface PeerLocationCoordinateItemCell  : ItemCell

@property (weak, nonatomic) id<LocationActionDelegate> locationActionDelegate;

@end
