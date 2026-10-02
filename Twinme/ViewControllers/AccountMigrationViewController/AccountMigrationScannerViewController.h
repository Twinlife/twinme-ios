/*
 *  Copyright (c) 2020-2026 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <TwinmeCommon/AbstractTwinmeViewController.h>

typedef enum {
    AccountMigrationScannerModeCode,
    AccountMigrationScannerModeScan
} AccountMigrationScannerMode;

//
// Interface: AccountMigrationScannerViewController
//

@interface AccountMigrationScannerViewController : AbstractTwinmeViewController

@property (nonatomic) AccountMigrationScannerMode accountMigrationScannerMode;

@end
