/*
 *  Copyright (c) 2026 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "UIHelpItem.h"

#import <Utils/NSString+Utils.h>

//
// Interface: UIHelpItem ()
//

@interface UIHelpItem ()

@end

//
// Implementation: UIHelpItem
//

@implementation UIHelpItem

- (nonnull instancetype)initWithType:(HelpItemType)helpItemType {
    
    self = [super init];
    
    if (self) {
        _helpItemType = helpItemType;
        [self initInfo];
    }
    return self;
}

- (void)initInfo {
    
    switch (self.helpItemType) {
        case HelpItemTypeGettingStarted:
            self.title = NSLocalizedString(@"navigation_view_getting_started", @"");
            self.icon = [UIImage imageNamed:@"GettingStartedIcon"];
            break;
         
        case HelpItemTypeFAQ:
            self.title = NSLocalizedString(@"navigation_view_faq", @"");
            self.icon = [UIImage imageNamed:@"FAQIcon"];
            break;
            
        case HelpItemTypeBlog:
            self.title = NSLocalizedString(@"navigation_view_blog", @"");
            self.icon = [UIImage imageNamed:@"BlogIcon"];
            break;
            
        case HelpItemTypeFeedback:
            self.title = NSLocalizedString(@"feedback_view_title", @"");
            self.icon = [UIImage imageNamed:@"FeedbackIcon"];
            break;
            
        case HelpItemTypeWelcome:
            self.title = [NSString capitalizeFirstCharacter:NSLocalizedString(@"settings_view_welcome_screen_category_title", @"")];
            self.icon = [UIImage imageNamed:@"PlaceholderLogo"];
            break;
            
        case HelpItemTypeProfile:
            self.title = NSLocalizedString(@"application_profile", @"");
            self.icon = [UIImage imageNamed:@"ProfileIcon"];
            break;
            
        case HelpItemTypeCertifiedRelation:
            self.title = NSLocalizedString(@"authentified_relation_view_title", @"");
            self.icon = [UIImage imageNamed:@"CertifiedIcon"];
            break;
            
        case HelpItemTypeQualityOfServices:
            self.title = NSLocalizedString(@"about_view_quality_of_service", @"");
            self.icon = [UIImage imageNamed:@"QualityOfServicesIcon"];
            break;
            
        case HelpItemTypeAccountTransfer:
            self.title = NSLocalizedString(@"account_view_transfer_between_devices", @"");
            self.icon = [UIImage imageNamed:@"MigrationIcon"];
            break;
            
        case HelpItemTypeAdditionalFunctions:
            self.title = NSLocalizedString(@"help_view_additional_features", @"");
            self.icon = [UIImage imageNamed:@"PremiumServicesIcon"];
            break;
            
        case HelpItemTypeSpaces:
            self.title = NSLocalizedString(@"premium_services_view_space_title", @"");
            self.icon = [UIImage imageNamed:@"TabBarSpacesGrey"];
            break;
            
        case HelpItemTypeClickToCall:
            self.title = NSLocalizedString(@"premium_services_view_click_to_call_title", @"");
            self.icon = [UIImage imageNamed:@"AddExternalCall"];
            break;
            
        case HelpItemTypeBackup:
            self.title = TwinmeLocalizedStringFromTable(@"account_view_backup_restore", @"LocalizableBackup", nil);
            self.icon = [UIImage imageNamed:@"BackupRestoreIcon"];
            break;
            
        case HelpItemTypeProxy:
            self.title = NSLocalizedString(@"proxy_view_title", @"");
            self.icon = [UIImage imageNamed:@"ProxyIcon"];
            break;
        
        default:
            self.title = @"";
            break;
    }
}

@end
