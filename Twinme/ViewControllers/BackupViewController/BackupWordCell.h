/*
 *  Copyright (c) 2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

//
// Interface: BackupWordCell
//

@class UIBackupWord;

@interface BackupWordCell : UICollectionViewCell

- (void)bind:(UIBackupWord *)backupWord;

@end
