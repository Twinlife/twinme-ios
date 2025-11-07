/*
 *  Copyright (c) 2018-2019 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

//
// Interface: SettingsItemCell
//

@protocol SettingsActionDelegate;

@interface SettingsItemCell : UITableViewCell

@property (weak, nonatomic) id<SettingsActionDelegate> settingsActionDelegate;
@property (nonatomic) BOOL forceDarkMode;

- (void)bindWithTitle:(NSString *)title icon:(UIImage *)icon stateSwitch:(BOOL)switchState tagSwitch:(int)tagSwitch hiddenSwitch:(BOOL)hiddenSwitch disableSwitch:(BOOL)disableSwitch backgroundColor:(UIColor *)backgroundColor hiddenSeparator:(BOOL)hiddenSeparator;

@end
