/*
 *  Copyright (c) 2019-2021 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <TwinmeCommon/AbstractTwinmeViewController.h>

//
// Interface: SettingsSpaceViewController
//

@class TLSpace;
@protocol SettingsSpaceDelegate;

@interface MessageSettingsSpaceViewController : AbstractTwinmeViewController

@property (weak, nonatomic) id<SettingsSpaceDelegate> settingsSpaceDelegate;

- (void)initWithSpace:(TLSpace *)space;

- (void)initWithSettings:(BOOL)allowNotification allowCopyText:(BOOL)allowCopyText allowCopyFile:(BOOL)allowCopyFile allowEphemeral:(BOOL)allowEphemeral expireTimeout:(int64_t)expireTimeout isDefault:(BOOL)isDefault isSecret:(BOOL)isSecret;

@end
