/*
 *  Copyright (c) 2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

//
// Interface: BackupCell
//

@class UIBackupInfo;

@interface BackupCell : UITableViewCell

- (void)bindWithBackupInfo:(UIBackupInfo *)backupInfo hiddenSeparator:(BOOL)hiddenSeparator;

@end
