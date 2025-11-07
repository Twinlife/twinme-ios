/*
 *  Copyright (c) 2017-2023 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Christian Jacquemot (Christian.Jacquemot@twinlife-systems.com)
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "ConversationsViewController.h"

@class UIConversation;

//
// Interface: ConversationCell
//

@interface ConversationCell : UITableViewCell

@property (weak, nonatomic) id<ConversationsActionDelegate> conversationsActionDelegate;

- (void)bindWithConversation:(UIConversation *)uiConversation topMargin:(CGFloat)topMargin hideSeparator:(BOOL)hideSeparator;

@end
