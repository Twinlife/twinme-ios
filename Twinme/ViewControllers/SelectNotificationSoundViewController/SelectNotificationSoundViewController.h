/*
 *  Copyright (c) 2016-2019 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Chedi Baccari (Chedi.Baccari@twinlife-systems.com)
 *   Christian Jacquemot (Christian.Jacquemot@twinlife-systems.com)
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <TwinmeCommon/AbstractTwinmeViewController.h>
#import <TwinmeCommon/NotificationSound.h>

//
// Interface: SelectNotificationSoundViewController
//

@interface SelectNotificationSoundViewController : AbstractTwinmeViewController

@property (nonatomic) NotificationSoundType notificationSoundType;

@end
