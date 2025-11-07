/*
 *  Copyright (c) 2022 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "AbstractShowViewController.h"

//
// Interface: ShowProfileViewController
//

@class TLProfile;

@interface ShowProfileViewController : AbstractShowViewController

- (void)initWithProfile:(TLProfile *)profile;

@end
