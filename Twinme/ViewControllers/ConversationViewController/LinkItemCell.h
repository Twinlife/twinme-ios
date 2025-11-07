/*
 *  Copyright (c) 2022 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "ItemCell.h"

#import "CopyableContent.h"

//
// Interface: LinkItemCell
//

@protocol LinkActionDelegate;

@interface LinkItemCell : ItemCell <CopyableContent>

@property (weak, nonatomic) id<LinkActionDelegate> linkActionDelegate;

@end
