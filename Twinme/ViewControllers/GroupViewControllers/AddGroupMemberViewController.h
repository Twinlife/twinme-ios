/*
 *  Copyright (c) 2018-2019 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <TwinmeCommon/AbstractTwinmeViewController.h>
#import "CreateGroupViewController.h"

@class TLGroup;

//
// Interface: AddGroupMemberViewController
//

@interface AddGroupMemberViewController : AbstractTwinmeViewController

@property (weak, nonatomic) id<AddGroupMemberDelegate> addGroupMemberDelegate;

- (void)initWithMembers:(NSMutableArray *)members fromCreateGroup:(BOOL)fromCreateGroup;

- (void)initWithGroup:(TLGroup *)group;

@end
