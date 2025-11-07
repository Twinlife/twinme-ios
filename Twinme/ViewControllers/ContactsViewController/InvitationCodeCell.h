/*
 *  Copyright (c) 2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

//
// Interface: InvitationCodeCell
//

@class UIInvitationCode;

@interface InvitationCodeCell : UITableViewCell

- (void)bindWithInvitation:(UIInvitationCode *)invitationCode hideSeparator:(BOOL)hideSeparator;

@end
