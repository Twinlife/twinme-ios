/*
 *  Copyright (c) 2023 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <TwinmeCommon/AbstractTwinmeViewController.h>

@class TLOriginator;

//
// Interface: ConversationFilesViewController
//

@interface ConversationFilesViewController : AbstractTwinmeViewController

- (void)initWithOriginator:(id<TLOriginator>)originator;

@end
