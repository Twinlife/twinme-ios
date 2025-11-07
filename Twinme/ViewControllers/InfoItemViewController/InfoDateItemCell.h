/*
 *  Copyright (c) 2019 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "Item.h"
#import "ConversationViewController.h"

typedef enum {
    InfoItemTypeSent,
    InfoItemTypeReceived,
    InfoItemTypeSeen,
    InfoItemTypeDeleted,
    InfoItemTypeEphemeral,
    InfoItemTypeUpdated,
} InfoItemType;

//
// Interface: InfoDateItemCell
//

@interface InfoDateItemCell : UITableViewCell

- (void)bindWithItem:(Item *)item infoItemType:(InfoItemType)infoItemType conversationViewController:(ConversationViewController *)conversationViewController;

@end
