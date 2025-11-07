/*
 *  Copyright (c) 2020-2024 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <TwinmeCommon/AbstractTwinmeViewController.h>

//
// Interface: AccountMigrationViewController
//

@interface AccountMigrationViewController : AbstractTwinmeViewController

@property (nonatomic) BOOL startFromSplashScreen;

- (void)initWithAccountMigration:(nonnull TLAccountMigration *)accountMigration;



@end
