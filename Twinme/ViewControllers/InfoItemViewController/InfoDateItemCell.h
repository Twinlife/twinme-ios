/*
 *  Copyright (c) 2019-2026 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "Item.h"
#import "InfoDateItem.h"

#import "ConversationViewController.h"

//
// Interface: InfoDateItemCell
//

@interface InfoDateItemCell : UITableViewCell

- (void)bindWithItem:(Item *)item infoDateItem:(InfoDateItem *)infoDateItem conversationViewController:(ConversationViewController *)conversationViewController;

@end
