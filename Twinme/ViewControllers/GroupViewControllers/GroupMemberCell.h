/*
 *  Copyright (c) 2018-2020 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

//
// Interface: GroupMemberCell
//

@class UIContact;
@class UIInvitation;

@interface GroupMemberCell : UITableViewCell

- (void)bindWithContact:(UIContact *)uiContact invitation:(UIInvitation *)invitation hideSeparator:(BOOL)hideSeparator;

@property (nonatomic) BOOL checked;

@end
