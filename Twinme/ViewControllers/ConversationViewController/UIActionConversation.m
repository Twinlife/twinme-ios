/*
 *  Copyright (c) 2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "UIActionConversation.h"

#import <Twinme/TLTwinmeContext.h>
#import <Twinme/TLSpace.h>
#import <Twinme/TLSpaceSettings.h>

#import <Utils/NSString+Utils.h>
#import <TwinmeCommon/Design.h>

#import <TwinmeCommon/ApplicationDelegate.h>
#import <TwinmeCommon/TwinmeApplication.h>

//
// Implementation: UIActionConversation
//

@implementation UIActionConversation

- (nonnull instancetype)initWithConversationActionType:(ConversationActionType)conversationActionType spaceSettings:(nullable TLSpaceSettings *)spaceSettings {
    
    self = [super init];
    
    if (self) {
        _conversationActionType = conversationActionType;
        _spaceSettings = spaceSettings;
        [self initAction];
    }
    return self;
}

- (void)initAction {
    
    ApplicationDelegate *delegate = (ApplicationDelegate *)[[UIApplication sharedApplication] delegate];
    TwinmeApplication *twinmeApplication = [delegate twinmeApplication];
     
    BOOL darkMode = [twinmeApplication darkModeEnable:self.spaceSettings];
    
    switch (self.conversationActionType) {
        case ConversationActionTypeCamera:
            self.title = TwinmeLocalizedString(@"application_camera", nil);
            self.icon = [UIImage imageNamed:@"GreyCamera"];
            self.iconColor = [UIColor colorWithRed:112./255. green:212./255. blue:174./255. alpha:1];
            break;
            
        case ConversationActionTypeGallery:
            self.title = TwinmeLocalizedString(@"application_photo_gallery", nil);
            self.icon = [UIImage imageNamed:@"ToolbarPictureGrey"];
            self.iconColor = [UIColor colorWithRed:241./255. green:154./255. blue:55./255. alpha:1];
            break;
            
        case ConversationActionTypeFile:
            self.title = TwinmeLocalizedString(@"export_view_controller_files", nil).capitalizedString;
            self.icon = [UIImage imageNamed:@"ToolbarFileGrey"];
            self.iconColor = [UIColor colorWithRed:200./255. green:200./255. blue:200./255. alpha:1];
            break;
            
        case ConversationActionTypeManageConversation:
            self.title = TwinmeLocalizedString(@"conversation_view_controller_manage_conversation", nil);
            self.icon = [UIImage imageNamed:@"SettingsIcon"];
            self.iconColor = darkMode ? [UIColor colorWithRed:230./255. green:230./255. blue:230./255. alpha:1] : [UIColor colorWithRed:110./255. green:110./255. blue:110./255. alpha:1];
            break;
            
        case ConversationActionTypeLocation:
            self.title = TwinmeLocalizedString(@"call_view_controller_location_share", nil).capitalizedString;
            self.icon = [UIImage imageNamed:@"ToolbarLocationGrey"];
            self.iconColor = [UIColor colorWithRed:210./255. green:218./255. blue:119./255. alpha:1];
            break;
            
        case ConversationActionTypeMediasAndFiles:
            self.title = TwinmeLocalizedString(@"conversation_files_view_controller_title", nil);
            self.icon = [UIImage imageNamed:@"SelectFile"];
            self.iconColor = [UIColor colorWithRed:78./255. green:171./255. blue:241./255. alpha:1];
            break;
            
        case ConversationActionTypeReset:
            self.title = TwinmeLocalizedString(@"main_view_controller_reset_conversation_title", nil);
            self.icon = [UIImage imageNamed:@"ActionBarDelete"];
            self.iconColor = Design.DELETE_COLOR_RED;
            break;
            
        default:
            break;
    }
}

@end
