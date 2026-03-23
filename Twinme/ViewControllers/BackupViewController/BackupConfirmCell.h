/*
 *  Copyright (c) 2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

//
// Protocol: BackupConfirmDelegate
//

@protocol BackupConfirmDelegate <NSObject>

- (void)didTapConfirmBackup:(BOOL)confirm;

@end

//
// Interface: BackupConfirmCell
//

@interface BackupConfirmCell : UITableViewCell

@property (weak, nonatomic) id<BackupConfirmDelegate> backupConfirmDelegate;

- (void)bind;

@end
