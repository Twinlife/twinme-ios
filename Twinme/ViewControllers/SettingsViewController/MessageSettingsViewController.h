/*
 *  Copyright (c) 2020 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <TwinmeCommon/AbstractTwinmeViewController.h>

//
// Protocol: SettingsActionDelegate
//

@class SwitchView;

@protocol SettingsActionDelegate

- (void)switchChangeValue:(SwitchView *)updatedSwitch;

@end

//
// Interface: MessageSettingsViewController
//

@interface MessageSettingsViewController : AbstractTwinmeViewController

@end
