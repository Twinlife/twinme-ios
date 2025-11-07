/*
 *  Copyright (c) 2019-2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "AbstractMenuView.h"
#import "SwitchView.h"

@protocol MenuSendOptionsDelegate;

//
// Protocol: MenuSendOptionsDelegate
//

@class MenuSendOptionsView;

@protocol MenuSendOptionsDelegate <NSObject>

- (void)cancelMenuSendOptions:(MenuSendOptionsView *)menuSendOptionsView;

- (void)sendFromOptionsMenu:(MenuSendOptionsView *)menuSendOptionsView allowCopy:(BOOL)allowCopy allowEphemeral:(BOOL)allowEphemeral expireTimeout:(int64_t)expireTimeout;

@end

//
// Interface: MenuSendOptionsView
//

@interface MenuSendOptionsView : AbstractMenuView

@property (weak, nonatomic) id<MenuSendOptionsDelegate> menuSendOptionsDelegate;

- (void)openMenu:(BOOL)allowCopy allowEphemeralMessage:(BOOL)allowEphemeralMessage timeout:(int64_t)timeout;

- (void)updateTimeout:(int64_t)timeout;

@end
