/*
 *  Copyright (c) 2026 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "Item.h"
#import "InfoDateItem.h"

#import "ConversationViewController.h"

//
// Interface: InfoIconItemCell
//

@interface InfoIconItemCell : UITableViewCell

- (void)bindWithItem:(Item *)item infoItemType:(InfoItemType)infoItemType conversationViewController:(ConversationViewController *)conversationViewController;

@end
