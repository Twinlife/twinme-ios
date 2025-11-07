/*
 *  Copyright (c) 2019 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "Item.h"
#import "ConversationViewController.h"

//
// Interface: CopyItemCell
//

@interface CopyItemCell : UITableViewCell

- (void)bindWithItem:(Item *)item;

@end
