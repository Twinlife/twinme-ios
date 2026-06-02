/*
 *  Copyright (c) 2026 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "ItemCell.h"

//
// Interface: PeerPollItemCell
//

@protocol PollActionDelegate;

@interface PeerPollItemCell : ItemCell

@property (weak, nonatomic) id<PollActionDelegate> pollActionDelegate;

@end
