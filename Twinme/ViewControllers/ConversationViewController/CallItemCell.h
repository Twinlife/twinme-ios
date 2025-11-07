/*
 *  Copyright (c) 2020 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "ItemCell.h"

//
// Interface: CallItemCell
//

@protocol CallActionDelegate;

@interface CallItemCell : ItemCell

@property (weak, nonatomic) id<CallActionDelegate> callActionDelegate;

@end
