/*
 *  Copyright (c) 2017 twinlife SA & Telefun SAS.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Phetsana Phommarinh (pphommarinh@skyrock.com)
 */

#import "ItemCell.h"

//
// Interface: InfoPrivacyCell
//

@interface InfoPrivacyCell : ItemCell

- (void)updatePseudo:(NSString *)pseudo;

- (void)bindWithItem:(Item *)item conversationViewController:(ConversationViewController *)conversationViewController;

@end
