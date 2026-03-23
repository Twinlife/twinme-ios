/*
 *  Copyright (c) 2025-2026 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

@class UIBackupContent;

//
// Interface: BackupContentCell
//

@class UIRestoreItem;

@interface BackupContentCell : UITableViewCell

- (void)bind:(UIBackupContent *)backupContent hideSeparator:(BOOL)hideSeparator;

- (void)bind:(UIRestoreItem *)restoreItem backgroundColor:(UIColor *)backgroundColor hideSeparator:(BOOL)hideSeparator;

@end
