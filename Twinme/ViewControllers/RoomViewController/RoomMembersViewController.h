/*
 *  Copyright (c) 2020-2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <TwinmeCommon/AbstractTwinmeViewController.h>

@class TLContact;

//
// Interface: RoomMembersViewController
//

@interface RoomMembersViewController : AbstractTwinmeViewController

- (void)initWithRoom:(TLContact *)room;

@end
