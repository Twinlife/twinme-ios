/*
 *  Copyright (c) 2023 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "AbstractMenuView.h"

//
// Protocol: MenuCallCapabilitiesDelegate
//

@class MenuCallCapabilitiesView;

@protocol MenuCallCapabilitiesDelegate <NSObject>

- (void)menuDidClosed:(MenuCallCapabilitiesView *)menuCallCapabilitiesView allowVoiceCall:(BOOL)allowVoiceCall allowVideoCall:(BOOL)allowVideoCall allowGroupCall:(BOOL)allowGroupCall;

@end

//
// Interface: MenuCallCapabilitiesView
//

@class TLCapabilities;

@interface MenuCallCapabilitiesView : AbstractMenuView

@property (weak, nonatomic) id<MenuCallCapabilitiesDelegate> menuCallCapabilitiesDelegate;

- (void)openMenu:(TLCapabilities *)capabilities;

@end
