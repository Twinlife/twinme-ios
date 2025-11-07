/*
 *  Copyright (c) 2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "AbstractMenuView.h"

//
// Protocol: MenuPropagatingProfileDelegate
//

@class MenuPropagatingProfileView;

@protocol MenuPropagatingProfileDelegate <NSObject>

- (void)cancelMenuPropagatingProfileView:(MenuPropagatingProfileView *)menuPropagatingProfileView;

- (void)saveProfileWithUpdateMode:(MenuPropagatingProfileView *)menuPropagatingProfileView profileUpdateMode:(TLProfileUpdateMode)profileUpdateMode;

@end

//
// Interface: MenuPropagatingProfileView
//

@interface MenuPropagatingProfileView : AbstractMenuView

@property (weak, nonatomic) id<MenuPropagatingProfileDelegate> menuPropagatingProfileDelegate;

@end
