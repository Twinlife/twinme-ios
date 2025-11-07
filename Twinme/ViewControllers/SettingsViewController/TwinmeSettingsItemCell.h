/*
 *  Copyright (c) 2019-2021 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

//
// Interface: TwinmeSettingsItemCell
//

@interface TwinmeSettingsItemCell : UITableViewCell

- (void)bindWithTitle:(NSString *)title hiddenAccessory:(BOOL)hiddenAccessory disableSetting:(BOOL)disableSetting color:(UIColor *)color;

- (void)bindWithTitle:(NSString *)title hiddenAccessory:(BOOL)hiddenAccessory disableSetting:(BOOL)disableSetting updateAvailable:(BOOL)updateAvailable color:(UIColor *)color;

@end
