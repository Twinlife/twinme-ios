/*
 *  Copyright (c) 2019-2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "AbstractMenuView.h"
#import "SwitchView.h"

//
// Protocol: MenuSendOptionsDelegate
//

@class MenuSendOptionsView;

@protocol MenuSendOptionsDelegate <NSObject>

- (void)cancelMenuSendOptions:(MenuSendOptionsView *)menuSendOptionsView;

- (void)sendFromOptionsMenu:(MenuSendOptionsView *)menuSendOptionsView allowCopy:(BOOL)allowCopy allowEphemeral:(BOOL)allowEphemeral expireTimeout:(int)expireTimeout;

@end

//
// Interface: MenuSendOptionsView
//

@interface MenuSendOptionsView : AbstractMenuView

@property (weak, nonatomic) id<MenuSendOptionsDelegate> menuSendOptionsDelegate;

- (void)openMenu:(BOOL)allowCopy;

@end
