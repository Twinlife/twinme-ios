/*
 *  Copyright (c) 2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "AbstractMenuView.h"

//
// Protocol: MenuAddContactViewDelegate
//

@class MenuAddContactView;

@protocol MenuAddContactViewDelegate <NSObject>

- (void)cancelMenuAddContactView:(MenuAddContactView *)menuAddContactView;

- (void)menuAddContactDidSelectScan:(MenuAddContactView *)menuAddContactView;

- (void)menuAddContactDidSelectInvite:(MenuAddContactView *)menuAddContactView;

@end

//
// Interface: MenuAddContactView
//

@interface MenuAddContactView : AbstractMenuView

@property (weak, nonatomic) id<MenuAddContactViewDelegate> menuAddContactViewDelegate;

@end
