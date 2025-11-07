/*
 *  Copyright (c) 2018 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (fabrice.trescartes@twin.life)
 */

#import "ItemCell.h"

//
// Interface: PeerVideoItemCell
//

@protocol VideoActionDelegate;

@interface PeerVideoItemCell : ItemCell

@property (weak, nonatomic) id<VideoActionDelegate> videoActionDelegate;

@end
