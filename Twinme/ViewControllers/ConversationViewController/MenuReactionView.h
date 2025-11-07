/*
 *  Copyright (c) 2023 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

//
// Protocol: MenuReactionDelegate
//

@class UIReaction;

@protocol MenuReactionDelegate <NSObject>

- (void)selectReaction:(UIReaction *)uiReaction;

@end

//
// Interface: MenuReactionView
//

@protocol MenuReactionDelegate;

@interface MenuReactionView : UIView

@property (weak, nonatomic) id<MenuReactionDelegate> menuReactionDelegate;

- (void)openMenu:(BOOL)isPeerItem;

@end
