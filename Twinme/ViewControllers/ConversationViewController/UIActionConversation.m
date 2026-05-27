/*
 *  Copyright (c) 2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "UIActionConversation.h"

#import <Utils/NSString+Utils.h>
#import <TwinmeCommon/Design.h>

#import <TwinmeCommon/ApplicationDelegate.h>
#import <TwinmeCommon/TwinmeApplication.h>

//
// Builds the menu icon for the GIF action at runtime so no extra asset is
// required. The menu cell renders icons as a template tinted with iconColor,
// so we just need the "GIF" glyph shape on a transparent background.
//
static UIImage *TwinmeGifIconImage(void) {
    CGSize size = CGSizeMake(30, 30);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    NSString *text = @"GIF";
    UIFont *font = [UIFont systemFontOfSize:13 weight:UIFontWeightHeavy];
    NSDictionary *attributes = @{ NSFontAttributeName: font,
                                  NSForegroundColorAttributeName: [UIColor blackColor] };
    CGSize textSize = [text sizeWithAttributes:attributes];
    CGRect rect = CGRectMake((size.width - textSize.width) / 2.0,
                             (size.height - textSize.height) / 2.0,
                             textSize.width, textSize.height);
    [text drawInRect:rect withAttributes:attributes];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

//
// Implementation: UIActionConversation
//

@implementation UIActionConversation

- (nonnull instancetype)initWithConversationActionType:(ConversationActionType)conversationActionType spaceSettings:(nullable TLSpaceSettings *)spaceSettings enabled:(BOOL)enabled {
    
    self = [super init];
    
    if (self) {
        _conversationActionType = conversationActionType;
        _spaceSettings = spaceSettings;
        _enabled = enabled;
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

        case ConversationActionTypeGif:
            self.title = @"GIF";
            self.icon = TwinmeGifIconImage();
            self.iconColor = [UIColor colorWithRed:120./255. green:120./255. blue:236./255. alpha:1];
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
