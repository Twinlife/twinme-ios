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

- (void)bindWithTitle:(nonnull NSString *)title hiddenAccessory:(BOOL)hiddenAccessory disableSetting:(BOOL)disableSetting color:(nonnull UIColor *)color;

- (void)bindWithTitle:(nonnull NSString *)title subTitle:(nullable NSString *)subTitle hiddenAccessory:(BOOL)hiddenAccessory disableSetting:(BOOL)disableSetting color:(nonnull UIColor *)color;

- (void)bindWithTitle:(nonnull NSString *)title hiddenAccessory:(BOOL)hiddenAccessory disableSetting:(BOOL)disableSetting updateAvailable:(BOOL)updateAvailable color:(nonnull UIColor *)color;

- (void)bindWithTitle:(nonnull NSString *)title hiddenAccessory:(BOOL)hiddenAccessory disableSetting:(BOOL)disableSetting color:(nonnull UIColor *)color badgeTitle:(nullable NSString *)badgeTitle showNotification:(BOOL)showNotification;

@end
