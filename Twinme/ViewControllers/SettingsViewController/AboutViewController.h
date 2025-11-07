/*
 *  Copyright (c) 2021 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <TwinmeCommon/AbstractTwinmeViewController.h>

//
// Protocol: UpdateVersionDelegate
//

@protocol UpdateVersionDelegate <NSObject>

- (void)updateAppVersion;

@end

//
// Interface: AboutViewController
//

@interface AboutViewController : AbstractTwinmeViewController

@end
