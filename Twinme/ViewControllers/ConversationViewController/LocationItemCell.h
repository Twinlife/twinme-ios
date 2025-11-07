/*
 *  Copyright (c) 2019 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "ItemCell.h"

//
// Interface: LocationItemCell
//

@protocol LocationActionDelegate;

@interface LocationItemCell : ItemCell

@property (weak, nonatomic) id<LocationActionDelegate> locationActionDelegate;

@end
