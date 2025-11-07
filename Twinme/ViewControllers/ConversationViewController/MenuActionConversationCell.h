/*
 *  Copyright (c) 2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

//
// Interface: MenuActionConversationCell
//

@class UIActionConversation;

@interface MenuActionConversationCell : UITableViewCell

- (void)bindWithAction:(UIActionConversation *)actionConversation delay:(CGFloat)delay;

@end
