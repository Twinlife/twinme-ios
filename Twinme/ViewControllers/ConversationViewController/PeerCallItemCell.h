/*
 *  Copyright (c) 2020 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "ItemCell.h"

//
// Interface: PeerCallItemCell
//

@protocol CallActionDelegate;

@interface PeerCallItemCell : ItemCell

@property (weak, nonatomic) id<CallActionDelegate> callActionDelegate;

@end
