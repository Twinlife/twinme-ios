/*
 *  Copyright (c) 2020-2024 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "GroupMemberViewController.h"
#import "AbstractMenuView.h"

@class UIContact;
@class MenuGroupMemberView;

@protocol MenuGroupMemberDelegate <NSObject>

- (void)inviteMemberAsContact:(MenuGroupMemberView *)menuGroupMemberView member:(UIContact *)member canInvite:(BOOL)canInvite;

- (void)removeMember:(MenuGroupMemberView *)menuGroupMemberView uiContact:(UIContact *)uiContact  canRemove:(BOOL)canRemove;

- (void)cancelMenuGroupMember:(MenuGroupMemberView *)menuGroupMemberView;

@end

//
// Interface: MenuGroupMemberView
//

@interface MenuGroupMemberView : AbstractMenuView

@property (weak, nonatomic) id<MenuGroupMemberDelegate> menuGroupMemberDelegate;

- (void)openMenu:(UIContact *)uiMember canInvite:(BOOL)canInvite canRemove:(BOOL)canRemove;

@end
