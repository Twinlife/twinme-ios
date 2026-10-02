/*
 *  Copyright (c) 2026 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

//
// Interface: AccountMigrationCell
//

@class UIMigrationStateItem;

//
// Interface: MigrationStateCell ()
//

@interface MigrationStateCell : UITableViewCell

- (void)bindWithItem:(nonnull UIMigrationStateItem *)migrationStateItem previousStateDone:(BOOL)previousStateDone;

- (void)setMinimumHeight:(CGFloat)minimumHeight;

@end
