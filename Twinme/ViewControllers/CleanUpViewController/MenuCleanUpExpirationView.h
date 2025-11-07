/*
 *  Copyright (c) 2023 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "AbstractMenuView.h"

//
// Protocol: MenuCleanUpExpirationDelegate
//

@class MenuCleanUpExpirationView;
@class UICleanUpExpiration;

@protocol MenuCleanUpExpirationDelegate <NSObject>

- (void)menuCleanUpExpirationCancel:(MenuCleanUpExpirationView *)menuCleanUpExpirationView;

- (void)menuCleanUpExpirationSelectExpiration:(MenuCleanUpExpirationView *)menuCleanUpExpirationView uiCleanUpExpiration:(UICleanUpExpiration *)uiCleanUpExpiration;

@end

//
// Interface: MenuCleanUpExpirationView
//

@interface MenuCleanUpExpirationView : AbstractMenuView

@property (weak, nonatomic) id<MenuCleanUpExpirationDelegate> menuCleanUpExpirationDelegate;

- (void)openMenu:(UICleanUpExpiration *)uiCleanUpExpiration;

@end
