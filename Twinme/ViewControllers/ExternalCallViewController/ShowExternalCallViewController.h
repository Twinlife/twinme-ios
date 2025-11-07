/*
 *  Copyright (c) 2023 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "AbstractShowViewController.h"

@class TLCallReceiver;

//
// Interface: ShowExternalCallViewController
//

@interface ShowExternalCallViewController : AbstractShowViewController

- (void)initWithCallReceiver:(TLCallReceiver *)callReceiver;

@end
