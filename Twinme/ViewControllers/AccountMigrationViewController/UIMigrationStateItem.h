/*
 *  Copyright (c) 2026 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <Twinlife/TLAccountMigrationService.h>

typedef enum {
    MigrationStateItemTypeHeader,
    MigrationStateItemTypeInit,
    MigrationStateItemTypeTransfer,
    MigrationStateItemTypeSettings,
    MigrationStateItemTypeDatabase,
    MigrationStateItemTypeAcocunt,
    MigrationStateItemTypeTerminated
} MigrationStateItemType;

typedef enum {
    MigrationStateItemStatePending,
    MigrationStateItemStateInProgress,
    MigrationStateItemStateDone
} MigrationStateItemState;

//
// Interface: UIMigrationStateItem
//

@interface UIMigrationStateItem : NSObject

- (nonnull instancetype)initWithType:(MigrationStateItemType)type;

- (MigrationStateItemType)getType;

- (nonnull NSString *)getTitle;

- (nullable NSString *)getInfo;

- (nullable NSAttributedString *)getAttributedInfo;

- (MigrationStateItemState)getState;

- (void)update:(TLAccountMigrationState)migrationState status:(nullable TLAccountMigrationStatus *)status;

@end
