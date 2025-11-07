/*
 *  Copyright (c) 2024 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "AbstractMenuView.h"

@class MenuCertifyView;

//
// Protocol: MenuCertifyViewDelegate
//

@protocol MenuCertifyViewDelegate <NSObject>

- (void)menuCertifyCancel:(MenuCertifyView *)menuCertifyView;

- (void)menuCertifyStartScan:(MenuCertifyView *)menuCertifyView;

- (void)menuCertifyStartVideoCall:(MenuCertifyView *)menuCertifyView;

@end

//
// Interface: MenuCertifyView
//

@interface MenuCertifyView : AbstractMenuView

@property (weak, nonatomic) id<MenuCertifyViewDelegate> menuCertifyViewDelegate;

- (void)openMenu:(BOOL)hideTitle;

@end
