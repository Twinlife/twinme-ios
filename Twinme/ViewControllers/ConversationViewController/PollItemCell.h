/*
 *  Copyright (c) 2026 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "ItemCell.h"

//
// Interface: PollItemCell
//

@protocol PollActionDelegate;

@interface PollItemCell : ItemCell

@property (weak, nonatomic) id<PollActionDelegate> pollActionDelegate;

@end
