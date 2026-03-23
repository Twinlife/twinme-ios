/*
 *  Copyright (c) 2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <TwinmeCommon/AbstractTwinmeViewController.h>

//
// Interface: RestoreViewController
//

@interface RestoreViewController : AbstractTwinmeViewController

- (void)initWithFilePath:(NSURL *)filePath verifyMode:(BOOL)verifyMode;

@end
