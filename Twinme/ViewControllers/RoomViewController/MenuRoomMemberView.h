/*
 *  Copyright (c) 2020-2021 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

//
// Interface: MenuRoomMemberView
//

@class UIRoomMember;
@protocol MenuRoomMembersDelegate;

@interface MenuRoomMemberView : UIView

@property (weak, nonatomic) id<MenuRoomMembersDelegate> menuRoomMemberDelegate;

- (void)openMenu:(UIRoomMember *)uiMember showAdminAction:(BOOL)showAdminAction showInviteAction:(BOOL)showInviteAction removeAdminAction:(BOOL)removeAdminAction;

@end
