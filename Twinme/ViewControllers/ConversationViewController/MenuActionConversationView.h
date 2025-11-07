/*
 *  Copyright (c) 2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

//
// Protocol: MenuActionConversationDelegate
//

@class UIActionConversation;

@protocol MenuActionConversationDelegate <NSObject>

- (void)cancelMenuAction;

- (void)didSelectAction:(UIActionConversation *)uiActionConversation;

@end

//
// Interface: MenuActionConversationView
//

@interface MenuActionConversationView : UIView

@property (weak, nonatomic) id<MenuActionConversationDelegate> menuActionConversationDelegate;

- (void)openMenu;

@end
