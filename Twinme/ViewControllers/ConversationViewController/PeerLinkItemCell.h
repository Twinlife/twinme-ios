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
// Interface: PeerLinkItemCell
//

@protocol LinkActionDelegate;

@class PeerMessageItem;
@class ConversationViewController;

@interface PeerLinkItemCell : ItemCell <CopyableContent>

@property (weak, nonatomic) id<LinkActionDelegate> linkActionDelegate;

@end
