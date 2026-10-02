/*
 *  Copyright (c) 2026 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

//
// Interface: MigrationHeaderCell ()
//

@class UIMigrationStateItem;

@interface MigrationHeaderCell : UITableViewCell

- (void)bindWithItem:(nonnull UIMigrationStateItem *)migrationStateItem;

@end
