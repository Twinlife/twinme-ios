/*
 *  Copyright (c) 2019 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <TwinmeCommon/AbstractTwinmeViewController.h>

//
// Interface: InfoItemViewController
//

@class Item;
@class ConversationViewController;

@interface InfoItemViewController : AbstractTwinmeViewController

@property (weak, nonatomic) ConversationViewController *conversationViewController;
@property (weak, nonatomic) Item *item;

- (void)initWithContact:(id<TLOriginator>)contact andItem:(Item *)item;

@end
