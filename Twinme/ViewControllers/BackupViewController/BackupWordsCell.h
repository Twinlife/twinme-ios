/*
 *  Copyright (c) 2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */


//
// Interface: BackupWordsCell
//

@interface BackupWordsCell : UITableViewCell

- (void)bindWithWords:(nonnull NSArray *)words;

@end
