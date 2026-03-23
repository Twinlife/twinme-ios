/*
 *  Copyright (c) 2021-2026 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

//
// Interface: SettingsInformationCell
//

@interface SettingsInformationCell : UITableViewCell

- (void)bindWithText:(NSString *)text;

- (void)bindWithText:(NSString *)text font:(UIFont *)font color:(UIColor *)color;

- (void)resetMargins;

@end
