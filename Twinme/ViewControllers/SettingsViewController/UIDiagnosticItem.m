/*
 *  Copyright (c) 2026 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "UIDiagnosticItem.h"

//
// Implementation: UIDiagnosticItem
//

@implementation UIDiagnosticItem

- (nonnull instancetype)initWithType:(DiagnosticItemType)diagnosticItemType {
    
    self = [super init];
    
    if (self) {
        _diagnosticItemType = diagnosticItemType;
        _diagnosticItemState = DiagnosticItemStateUnknown;
        [self initInfo];
    }
    return self;
}

- (void)initInfo {
    
    switch (self.diagnosticItemType) {
        case DiagnosticItemTypeConnection:
            self.title = NSLocalizedString(@"application_connected", @"");
            self.icon = [UIImage imageNamed:@"ConnectedIcon"];
            break;
         
        case DiagnosticItemTypePermissionNotification:
            self.title = NSLocalizedString(@"application_notifications", @"");
            self.icon = [UIImage imageNamed:@"NotificationsIcon"];
            break;
            
        case DiagnosticItemTypePermissionMicro:
            self.title = NSLocalizedString(@"call_view_tag_microphone", @"");
            self.icon = [UIImage imageNamed:@"ToolbarMicrophoneGrey"];
            break;
            
        case DiagnosticItemTypePermissionCamera:
            self.title = NSLocalizedString(@"application_camera", @"");
            self.icon = [UIImage imageNamed:@"VideoCall"];
            break;
            
        case DiagnosticItemTypePermissionLocation:
            self.title = NSLocalizedString(@"application_location", @"");
            self.icon = [UIImage imageNamed:@"CallLocationIcon"];
            break;
            
        case DiagnosticItemTypePush:
            self.title = NSLocalizedString(@"diagnostics_view_push_token", @"");;
            self.icon = [UIImage imageNamed:@"NotificationsIcon"];
            break;
            
        default:
            self.title = @"";
            break;
    }
}


@end
