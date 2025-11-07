/*
 *  Copyright (c) 2021 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <TwinmeCommon/AbstractTwinmeViewController.h>

//
// Interface: SettingsRoomViewController
//

@class TLContact;

@interface SettingsRoomViewController : AbstractTwinmeViewController

- (void)initWithRoom:(TLContact *)room;

@end
