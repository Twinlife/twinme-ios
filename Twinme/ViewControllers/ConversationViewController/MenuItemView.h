/*
 *  Copyright (c) 2019-2021 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

//
// Interface: MenuItemView
//

#import "RoundedShadowView.h"
#import "Item.h"

typedef enum {
    MenuTypeText,
    MenuTypeImage,
    MenuTypeAudio,
    MenuTypeVideo,
    MenuTypeFile,
    MenuTypeInvitation,
    MenuTypeCall,
    MenuTypeClear
} MenuType;

typedef enum {
    ActionTypeCopy,
    ActionTypeEdit,
    ActionTypeInfo,
    ActionTypeDelete,
    ActionTypeForward,
    ActionTypeReply,
    ActionTypeSave,
    ActionTypeShare,
    ActionTypeSelectMore
} ActionType;

#import "ConversationViewController.h"

@interface MenuItemView : UIView

@property (weak, nonatomic) id<MenuItemDelegate> menuItemDelegate;

- (void)openMenu:(Item *)item menuType:(MenuType)menuType;

- (void)setEditMessage:(BOOL)edit;

@end
