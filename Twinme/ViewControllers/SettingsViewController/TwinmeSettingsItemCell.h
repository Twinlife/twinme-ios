/*
 *  Copyright (c) 2019-2026 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */


//
// Protocol: TwinmeSettingsItemDeleagte
//

@protocol TwinmeSettingsItemDeleagte <NSObject>

- (void)didTapSettingsBadge;

@end

//
// Interface: TwinmeSettingsItemCell
//

@interface TwinmeSettingsItemCell : UITableViewCell

@property (nonatomic, weak) id<TwinmeSettingsItemDeleagte>delegate;

- (void)bindWithTitle:(NSString *)title hiddenAccessory:(BOOL)hiddenAccessory disableSetting:(BOOL)disableSetting color:(UIColor *)color;

- (void)bindWithTitle:(NSString *)title hiddenAccessory:(BOOL)hiddenAccessory disableSetting:(BOOL)disableSetting updateAvailable:(BOOL)updateAvailable color:(UIColor *)color;

- (void)bindWithTitle:(NSString *)title hiddenAccessory:(BOOL)hiddenAccessory disableSetting:(BOOL)disableSetting color:(UIColor *)color badgeTitle:(NSString *)badgeTitle;

@end
