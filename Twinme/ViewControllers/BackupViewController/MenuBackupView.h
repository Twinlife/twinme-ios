/*
 *  Copyright (c) 2026 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "AbstractMenuView.h"

//
// Protocol: MenuBackupViewDelegate
//

@class MenuBackupView;

@protocol MenuBackupViewDelegate <NSObject>

- (void)menuBackupDidClose:(nonnull MenuBackupView *)menuBackupView;

- (void)menuBackupDidSelectVerify:(nonnull MenuBackupView *)menuBackupView backupURL:(nonnull NSURL *)backupURL;

- (void)menuBackupDidSelectRestore:(nonnull MenuBackupView *)menuBackupView backupURL:(nonnull NSURL *)backupURL;

@end

@interface MenuBackupView : AbstractMenuView

@property (weak, nonatomic) id<MenuBackupViewDelegate> menuBackupViewDelegate;
@property (nonnull) NSURL *backupURL;

- (void)openMenu:(nonnull NSURL *)backupURL;

@end
