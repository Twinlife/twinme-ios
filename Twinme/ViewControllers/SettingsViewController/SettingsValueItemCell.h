/*
 *  Copyright (c) 2021 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

//
// Interface: SettingsValueItemCell
//

@interface SettingsValueItemCell : UITableViewCell

@property (nonatomic) BOOL forceDarkMode;

- (void)bindWithTitle:(nonnull NSString *)title value:(nonnull NSString *)value hiddenAccessory:(BOOL)hiddenAccessory;

- (void)bindWithTitle:(nullable NSString *)title value:(nonnull NSString *)value backgroundColor:(nonnull UIColor *)backgroundColor;

@end
