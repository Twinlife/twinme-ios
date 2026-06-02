/*
 *  Copyright (c) 2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "UIBackupContent.h"

#import <Utils/NSString+Utils.h>

//
// Interface: UIBackupContent ()
//

@interface UIBackupContent ()

@property (nonatomic) BackupContentType backupContentType;
@property (nonatomic) int count;

@end

//
// Implementation: UIBackupContent
//

@implementation UIBackupContent

- (nonnull instancetype)initWithType:(BackupContentType)backupContentType {
    
    self = [super init];
    
    if (self) {
        _backupContentType = backupContentType;
    }
    return self;
}

- (nonnull NSString *)getContentTitle {
    
    NSString *title = @"";
    
    switch (self.backupContentType) {
        case BackupContentTypeContacts:
            title = TwinmeLocalizedString(@"share_view_contact_list", nil);
            break;
            
        case BackupContentTypeGroups:
            title = TwinmeLocalizedString(@"share_view_group_list", nil);
            break;
            
        case BackupContentTypeSpaces:
            //TODO BKP: i18n
            title = TwinmeLocalizedString(@"spaces_view_title", nil);
            break;
            
        case BackupContentTypeClickToCall:
            //TODO BKP: i18n
            title = TwinmeLocalizedString(@"premium_services_view_click_to_call_title", nil);
            break;
            
        default:
            break;
    }
    
    return title;
}

- (nullable UIImage *)getContentIcon {
    
    UIImage *icon;
    
    switch (self.backupContentType) {
        case BackupContentTypeContacts:
            icon = [UIImage imageNamed:@"ContactsIcon"];
            break;
            
        case BackupContentTypeGroups:
            icon = [UIImage imageNamed:@"GroupsIcon"];
            break;
            
        default:
            break;
    }
    
    return icon;
}

- (int)getContentCount {
    
    return self.count;
}

- (void)setContentCount:(int)count {
    
    self.count = count;
}

@end
