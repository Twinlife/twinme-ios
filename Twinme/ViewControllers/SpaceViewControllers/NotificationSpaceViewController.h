/*
 *  Copyright (c) 2022 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <TwinmeCommon/AbstractTwinmeViewController.h>

//
// Interface: NotficationSpaceViewController
//

@class TLSpace;
@protocol SettingsSpaceDelegate;

@interface NotificationSpaceViewController : AbstractTwinmeViewController

@property (weak, nonatomic) id<SettingsSpaceDelegate> settingsSpaceDelegate;

- (void)initWithSpace:(TLSpace *)space;

@end
