/*
 *  Copyright (c) 2019-2020 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

//
// Interface: MoveContactCell
//

@class UIMoveContact;

@interface MoveContactCell : UITableViewCell

- (void)bindWithContact:(UIMoveContact *)contact hideSeparator:(BOOL)hideSeparator;

@end
