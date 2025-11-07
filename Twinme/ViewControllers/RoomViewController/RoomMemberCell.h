/*
 *  Copyright (c) 2020 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

//
// Interface: RoomMemberCell
//

@class UIRoomMember;

@interface RoomMemberCell : UITableViewCell

- (void)bindWithMember:(UIRoomMember *)uiMember hideSeparator:(BOOL)hideSeparator;

@end
