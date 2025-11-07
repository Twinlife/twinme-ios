/*
 *  Copyright (c) 2018-2020 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "AbstractShowViewController.h"

//
// Interface: ShowGroupViewController
//

#import <TwinmeCommon/GroupService.h>

@class TLGroup;

@interface ShowGroupViewController : AbstractShowViewController

@property (nonatomic) TLGroup *group;

- (void)initWithGroup:(TLGroup *)group;

@end
