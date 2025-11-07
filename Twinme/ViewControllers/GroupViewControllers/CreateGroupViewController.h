/*
 *  Copyright (c) 2018-2019 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "AbstractShowViewController.h"

//
// Protocol: AddGroupMemberDelegate
//

@class AddGroupMemberViewController;

@protocol AddGroupMemberDelegate <NSObject>

- (void)addGroupMemberViewController:(AddGroupMemberViewController *)addGroupMemberViewController didFinishPickingMembers:(NSMutableArray *)groupMembers;

@end

//
// Interface: CreateGroupViewController
//

@interface CreateGroupViewController : AbstractShowViewController

@end
