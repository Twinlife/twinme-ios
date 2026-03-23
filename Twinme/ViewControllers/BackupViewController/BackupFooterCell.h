/*
 *  Copyright (c) 2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

@class BackupFooterCell;

//
// Protocol: BackupFooterDelegate
//

@protocol BackupFooterDelegate <NSObject>

- (void)didTapFooterAction;

@end

//
// Interface: BackupFooterCell
//

@interface BackupFooterCell : UITableViewCell

@property (weak, nonatomic) id<BackupFooterDelegate> backupFooterDelegate;

- (void)bindWithTitle:(NSString *)title enable:(BOOL)enable backgroundColor:(UIColor *)backgroundColor;

@end
