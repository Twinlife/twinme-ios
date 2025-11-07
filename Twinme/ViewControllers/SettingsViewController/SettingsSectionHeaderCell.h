/*
 *  Copyright (c) 2019-2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

//
// Protocol: SettingsSectionHeaderDelegate
//

@protocol SettingsSectionHeaderDelegate <NSObject>

- (void)didTapNewFeature;

@end

//
// Interface: SettingsSectionHeaderCell
//

@interface SettingsSectionHeaderCell : UITableViewCell

@property (nonatomic, weak) id<SettingsSectionHeaderDelegate>delegate;

- (void)bindWithTitle:(NSString *)title backgroundColor:(UIColor *)backgroundColor hideSeparator:(BOOL)hideSeparator uppercaseString:(BOOL)uppercaseString;

- (void)bindWithTitle:(NSString *)title backgroundColor:(UIColor *)backgroundColor hideSeparator:(BOOL)hideSeparator uppercaseString:(BOOL)uppercaseString showNewFeature:(BOOL)showNewFeature;

@end
