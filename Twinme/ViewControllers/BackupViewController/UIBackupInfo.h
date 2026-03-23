/*
 *  Copyright (c) 2026 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

//
// Interface: UIBackupInfo
//

@interface UIBackupInfo : NSObject

@property (nonnull, nonatomic) NSUUID *backupId;
@property (nonatomic) int64_t backupDate;

- (nonnull instancetype)initWithBackupId:(nonnull NSUUID *)backupId backupDate:(int64_t)backupDate;

- (nonnull NSString *)getId;

- (nonnull NSString *)getDate;

@end
