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

@class UIAccountMigrationItem;

@interface AccountMigrationCell : UITableViewCell

- (void)bindWithItem:(nonnull UIAccountMigrationItem *)accountMigrationItem;

@end
