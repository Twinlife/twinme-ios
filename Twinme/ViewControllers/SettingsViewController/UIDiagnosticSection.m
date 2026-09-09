/*
 *  Copyright (c) 2026 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "UIDiagnosticSection.h"
#import "UIDiagnosticItem.h"

//
// Implementation: UIDiagnosticSection
//

@implementation UIDiagnosticSection

- (nonnull instancetype)initWithType:(UIDiagnosticSectionType)sectionType {
    
    self = [super init];
    
    if (self) {
        _sectionType = sectionType;
        _items = [[NSMutableArray alloc]init];
        [self initInfo];
    }
    return self;
}

- (void)initInfo {
    
    switch (self.sectionType) {
        case DiagnosticSectionTypeConnection:
            self.title = NSLocalizedString(@"settings_advanced_view_status_connection_title", @"");
            [self.items addObject:[[UIDiagnosticItem alloc] initWithType:DiagnosticItemTypeConnection]];
            break;
            
        case DiagnosticSectionTypePermission:
            self.title = NSLocalizedString(@"settings_view_authorization_title", @"");
            [self.items addObject:[[UIDiagnosticItem alloc] initWithType:DiagnosticItemTypePermissionNotification]];
            [self.items addObject:[[UIDiagnosticItem alloc] initWithType:DiagnosticItemTypePermissionMicro]];
            [self.items addObject:[[UIDiagnosticItem alloc] initWithType:DiagnosticItemTypePermissionCamera]];
            break;
            
        case DiagnosticSectionTypePush:
            self.title = NSLocalizedString(@"application_notifications", @"");
            [self.items addObject:[[UIDiagnosticItem alloc] initWithType:DiagnosticItemTypePush]];
            break;
            
        default:
            self.title = @"";
            break;
    }
}

@end
