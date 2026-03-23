/*
 *  Copyright (c) 2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

typedef enum {
    BackupContentTypeClickToCall,
    BackupContentTypeContacts,
    BackupContentTypeGroups,
    BackupContentTypeSpaces
} BackupContentType;

//
// Interface: UIBackupContent
//

@interface UIBackupContent : NSObject

- (nonnull instancetype)initWithType:(BackupContentType)backupContentType;

- (nonnull NSString *)getContentTitle;

- (nullable UIImage *)getContentIcon;

- (int)getContentCount;

- (void)setContentCount:(int)count;

@end
