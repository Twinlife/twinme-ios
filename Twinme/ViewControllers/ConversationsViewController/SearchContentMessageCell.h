/*
 *  Copyright (c) 2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

//
// Interface: SearchContentMessageCell
//

@class UIConversation;

@interface SearchContentMessageCell : UITableViewCell

- (void)bindWithConversation:(UIConversation *)uiConversation search:(NSString *)search;

@end
