/*
 *  Copyright (c) 2020-2021 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "AbstractShowViewController.h"

//
// Interface: EditGroupViewController
//

@class TLGroup;

@interface EditGroupViewController : AbstractShowViewController

- (void)initWithGroup:(TLGroup *)group;

@end
