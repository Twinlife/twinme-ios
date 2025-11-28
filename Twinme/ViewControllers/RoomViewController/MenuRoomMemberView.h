/*
 *  Copyright (c) 2020-2021 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "AbstractMenuView.h"

//
// Protocol: MenuRoomMembersDelegate
//

@class MenuRoomMemberView;
@class UIRoomMember;

@protocol MenuRoomMembersDelegate <NSObject>

- (void)changeAdministrator:(MenuRoomMemberView *)menuRoomMemberView uiMember:(UIRoomMember *)uiMember;

- (void)removeAdministrator:(MenuRoomMemberView *)menuRoomMemberView uiMember:(UIRoomMember *)uiMember;

- (void)inviteMemberAsContact:(MenuRoomMemberView *)menuRoomMemberView uiMember:(UIRoomMember *)uiMember canInvite:(BOOL)canInvite;

- (void)removeMember:(MenuRoomMemberView *)menuRoomMemberView uiMember:(UIRoomMember *)uiMember  canRemove:(BOOL)canRemove;

- (void)cancelMenuRoomMember:(MenuRoomMemberView *)menuRoomMemberView;

@end

//
// Interface: MenuRoomMemberView
//

@interface MenuRoomMemberView : AbstractMenuView

@property (weak, nonatomic) id<MenuRoomMembersDelegate> menuRoomMemberDelegate;

- (void)openMenu:(UIRoomMember *)uiMember showAdminAction:(BOOL)showAdminAction showInviteAction:(BOOL)showInviteAction removeAdminAction:(BOOL)removeAdminAction;

@end
