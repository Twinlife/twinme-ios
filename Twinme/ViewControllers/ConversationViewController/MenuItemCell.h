/*
 *  Copyright (c) 2021 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

//
// Interface: MenuItemCell
//

@class UIMenuItemAction;

@interface MenuItemCell : UITableViewCell

- (void)bindWithMenuItem:(UIMenuItemAction *)menuItemAction enabled:(BOOL)enabled hideSeparator:(BOOL)hideSeparator;

@end
