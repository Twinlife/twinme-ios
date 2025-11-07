/*
 *  Copyright (c) 2018 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "ItemCell.h"

//
// Interface: PeerInvitationItemCell
//

@protocol GroupActionDelegate;

@interface PeerInvitationItemCell  : ItemCell

@property (weak, nonatomic) id<GroupActionDelegate> groupActionDelegate;

@end
