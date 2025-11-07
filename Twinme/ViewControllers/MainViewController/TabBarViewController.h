/*
 *  Copyright (c) 2020 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

//
// Interface: TabBarViewController
//

@interface TabBarViewController : UITabBarController

- (void)updateNotifications:(BOOL)hasPendingNotifications;

- (void)updateColor;

- (NSUInteger)getSelectedIndex;

- (void)updateSpace;

- (void)setCurrentSpace;

@end
