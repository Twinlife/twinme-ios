/*
 *  Copyright (c) 2019-2020 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "Item.h"
#import "ConversationViewController.h"

//
// Interface: InfoFileItemCell
//

@interface InfoFileItemCell : UITableViewCell

- (void)bindWithItem:(Item *)item originator:(id<TLOriginator>)originator;

@end
