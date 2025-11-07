/*
 *  Copyright (c) 2017-2019 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "Item.h"

//
// Interface: NameItemCell
//

@class NameItem;
@class ConversationViewController;
@protocol MenuActionDelegate;

@interface NameItemCell : UITableViewCell

@property (weak, nonatomic) Item *item;
@property (weak, nonatomic) id<MenuActionDelegate> menuActionDelegate;

- (void)bindWithItem:(Item *)item conversationViewController:(ConversationViewController *)conversationViewController;

@end
