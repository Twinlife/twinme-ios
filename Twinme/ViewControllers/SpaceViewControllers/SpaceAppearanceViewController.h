/*
 *  Copyright (c) 2022 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <TwinmeCommon/AbstractTwinmeViewController.h>

//
// Interface: SpaceAppearanceViewController
//

@class TLSpace;
@protocol SettingsSpaceDelegate;

@interface SpaceAppearanceViewController : AbstractTwinmeViewController

@property (weak, nonatomic) id<SettingsSpaceDelegate> settingsSpaceDelegate;

- (void)initWithSpace:(TLSpace *)space;

@end
