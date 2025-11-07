/*
 *  Copyright (c) 2024 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

//
// Interface: SettingsIconCell
//

@interface SettingsIconCell : UITableViewCell

- (void)bindWithTitle:(NSString *)title icon:(UIImage *)icon textColor:(UIColor *)textColor iconTintColor:(UIColor *)iconTintColor hideSeparator:(BOOL)hideSeparator;

@end

