/*
 *  Copyright (c) 2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <TwinmeCommon/AbstractTwinmeViewController.h>

//
// Interface: SuccessBackupViewController
//

@interface SuccessBackupViewController : AbstractTwinmeViewController

- (void)initWithBackupPath:(NSString *)backupPath words:(NSArray *)words backupId:(NSUUID *)backupId;

@end
