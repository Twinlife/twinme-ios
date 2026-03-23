/*
 *  Copyright (c) 2026 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "UIBackupInfo.h"

#import <Utils/NSString+Utils.h>

//
// Interface: UIBackupInfo ()
//

@interface UIBackupInfo ()

@end

//
// Implementation: UIBackupInfo
//

@implementation UIBackupInfo

- (nonnull instancetype)initWithBackupId:(NSUUID *)backupId backupDate:(int64_t)backupDate {
    
    self = [super init];
    
    if (self) {
        _backupId = backupId;
        _backupDate = backupDate;
    }
    return self;
}

- (nonnull NSString *)getId {
    
    NSString *uuidString = [self.backupId UUIDString];
    NSString *shortUUID = uuidString.length >= 8 ? [uuidString substringToIndex:8] : uuidString;
    
    return shortUUID;
}

- (nonnull NSString *)getDate {
 
    return [NSString formatBackupTimeInterval:self.backupDate / 1000];
}

@end
