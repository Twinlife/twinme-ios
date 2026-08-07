/*
 *  Copyright (c) 2024-2026 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

//
// Interface: MenuIconCell
//

@interface MenuIconCell : UITableViewCell

- (void)bindWithTitle:(NSString *)title icon:(NSString *)icon iconColor:(UIColor *)iconColor hideSeparator:(BOOL)hideSeparator;

@end

