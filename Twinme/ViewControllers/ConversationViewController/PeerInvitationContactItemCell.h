/*
 *  Copyright (c) 2020 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "ItemCell.h"

//
// Interface: PeerInvitationContactItemCell
//

@protocol TwincodeActionDelegate;

@interface PeerInvitationContactItemCell : ItemCell

@property (weak, nonatomic) id<TwincodeActionDelegate> twincodeActionDelegate;

@end
