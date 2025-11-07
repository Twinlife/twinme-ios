/*
 *  Copyright (c) 2020-2021 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <TwinmeCommon/AbstractTwinmeViewController.h>

@class TLContact;
@class UIRoomMember;

//
// Protocol: MenuRoomMembersDelegate
//

@protocol MenuRoomMembersDelegate <NSObject>

- (void)cancelMenu;

- (void)changeAdministrator:(UIRoomMember *)uiMember;

- (void)removeAdministrator:(UIRoomMember *)uiMember;

- (void)inviteMember:(UIRoomMember *)uiMember;

- (void)removeFromRoom:(UIRoomMember *)uiMember;

@end

//
// Interface: RoomMembersViewController
//

@interface RoomMembersViewController : AbstractTwinmeViewController

- (void)initWithRoom:(TLContact *)room;

@end
