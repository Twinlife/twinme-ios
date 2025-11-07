/*
 *  Copyright (c) 2020 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "AbstractShowViewController.h"

//
// Interface: ShowSpaceViewController
//

@class TLSpace;

@interface ShowSpaceViewController : AbstractShowViewController

- (void)initWithSpace:(TLSpace *)space;

@end
