/*
 *  Copyright (c) 2022 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

//
// Interface: SelectValueCell
//

@interface SelectValueCell : UITableViewCell

@property (nonatomic) BOOL forceDarkMode;

- (void)bindWithTitle:(NSString *)title subTitle:(NSString *)subtitle checked:(BOOL)checked hideBorder:(BOOL)hideBorder hideSeparator:(BOOL)hideSeparator;

@end

