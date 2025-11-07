/*
 *  Copyright (c) 2020 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <TwinmeCommon/AbstractTwinmeViewController.h>

//
// Interface: LastCallsViewController
//

@class TLContact;

@interface LastCallsViewController : AbstractTwinmeViewController

- (void)initWithOriginator:(id<TLOriginator>)originator callReceiver:(BOOL)callReceiver;

@end
