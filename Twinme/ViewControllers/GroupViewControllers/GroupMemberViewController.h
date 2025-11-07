/*
 *  Copyright (c) 2018-2020 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <TwinmeCommon/AbstractTwinmeViewController.h>
#import "CreateGroupViewController.h"

//
// Protocol: MenuGroupMemberDelegate
//

@class UIContact;

//
// Interface: GroupMemberViewController
//

@class TLGroup;

@interface GroupMemberViewController : AbstractTwinmeViewController

- (void)initWithGroup:(TLGroup *)group;

@end
