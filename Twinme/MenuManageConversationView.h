/*
 *  Copyright (c) 2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "AbstractMenuView.h"

@class MenuManageConversationView;

//
// Protocol: MenuManageConversationViewDelegate
//

@protocol MenuManageConversationViewDelegate <NSObject>

- (void)cancelMenuManageConversationView:(MenuManageConversationView *)menuManageConversationView;

- (void)menuManageConversationViewDidSelectCleanup:(MenuManageConversationView *)menuManageConversationView;

- (void)menuManageConversationViewDidSelectExport:(MenuManageConversationView *)menuManageConversationView;

@end

//
// Interface: MenuManageConversationViewDelegate
//

@interface MenuManageConversationView : AbstractMenuView

@property (weak, nonatomic) id<MenuManageConversationViewDelegate> menuManageConversationViewDelegate;

@end
