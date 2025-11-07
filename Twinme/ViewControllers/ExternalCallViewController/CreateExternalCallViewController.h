/*
 *  Copyright (c) 2023 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "AbstractShowViewController.h"

//
// Interface: CreateExternalCallViewController
//

@class UITemplateExternalCall;

@interface CreateExternalCallViewController : AbstractShowViewController

@property (nonatomic) BOOL isTransfert;

- (void)initWithTemplate:(UITemplateExternalCall *)templateExternalCall;

@end
