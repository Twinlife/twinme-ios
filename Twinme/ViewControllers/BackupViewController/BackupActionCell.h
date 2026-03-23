/*
 *  Copyright (c) 2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

@class BackupActionCell;

//
// Protocol: BackupActionDelegate
//

@protocol BackupActionDelegate <NSObject>

- (void)didTapLeftBackupAction:(nonnull BackupActionCell *)backupActionCell;

@optional
- (void)didTapRightBackupAction:(nonnull BackupActionCell *)backupActionCell;

@end


//
// Interface: BackupActionCell
//

@interface BackupActionCell : UITableViewCell

@property (weak, nonatomic) id<BackupActionDelegate> backupActionDelegate;

- (void)bindWithTitle:(nonnull NSString *)leftTitle rightTitle:(nullable NSString *)rightTitle leftImage:(nonnull UIImage *)leftImage rightImage:(nullable UIImage *)rightImage;

@end
