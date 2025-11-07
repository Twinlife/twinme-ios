/*
 *  Copyright (c) 2020 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <TwinmeCommon/AbstractTwinmeViewController.h>

//
// Interface: AdminRoomViewController
//

@class TLContact;

@interface AdminRoomViewController : AbstractTwinmeViewController

- (void)initWithRoom:(TLContact *)room;

@end
