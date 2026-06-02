/*
 *  Copyright (c) 2026 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "UIConfigExternalCallItem.h"

#import <Utils/NSString+Utils.h>

//
// Interface: UIConfigExternalCallItem
//

@interface UIConfigExternalCallItem ()

@property (nonatomic) NSString *title;

@end

//
// Implementation : UIConfigExternalCallItem
//

@implementation UIConfigExternalCallItem

- (nonnull instancetype)initWithConfigExternalCallSettings:(ConfigExternalCallSettings)configExternalCallSettings {
    
    self = [super init];
    
    if (self) {
        _configExternalCallSettings = configExternalCallSettings;
        [self setup];
    }
    
    return self;
}

- (nonnull NSString *)getTitle {
    
    return self.title;
}

    
- (void)setup {
    
    switch (self.configExternalCallSettings) {
        case ConfigExternalCallSettingsCallType:
            self.title = TwinmeLocalizedString(@"create_external_call_view_call_type", nil);
            break;
            
        case ConfigExternalCallSettingsPermissions:
            self.title = TwinmeLocalizedString(@"settings_view_authorization_title", nil);
            break;
            
        case ConfigExternalCallSettingsExpiration:
            self.title = TwinmeLocalizedString(@"create_external_call_view_link_validity", nil);
            break;
            
        case ConfigExternalCallSettingsScheduleStart:
        case ConfigExternalCallSettingsScheduleEnd:
        case ConfigExternalCallSettingsScheduleRecurrent:
            self.title = @"";
            break;

        case ConfigExternalCallSettingsDelete:
            self.title = TwinmeLocalizedString(@"create_external_call_view_delete_link_setting", nil);
            break;
            
        case ConfigExternalCallSettingsNotification:
            self.title = TwinmeLocalizedString(@"create_external_call_view_notification_setting", nil);
            break;
            
        default:
            self.title = @"";
            break;
    }
}

@end
