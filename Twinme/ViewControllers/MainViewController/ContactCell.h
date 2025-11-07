/*
 *  Copyright (c) 2017-2023 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Christian Jacquemot (Christian.Jacquemot@twinlife-systems.com)
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

//
// Interface: ContactCell
//

@class UIContact;

@interface ContactCell : UITableViewCell

- (void)bindWithContact:(UIContact *)uiContact hideSeparator:(BOOL)hideSeparator;

- (void)bindWithName:(NSString *)name avatar:(UIImage *)avatar hideSeparator:(BOOL)hideSeparator hideSchedule:(BOOL)hideSchedule;

@end
