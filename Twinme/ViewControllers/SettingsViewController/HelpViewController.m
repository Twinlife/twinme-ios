/*
 *  Copyright (c) 2021-2026 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <SafariServices/SafariServices.h>
#import <Utils/NSString+Utils.h>
#import <SafariServices/SafariServices.h>

#import "HelpViewController.h"

#import "AccountViewController.h"
#import "FeedbackViewController.h"
#import "WebViewController.h"
#import "FAQViewController.h"
#import "WelcomeHelpViewController.h"
#import "PremiumServicesViewController.h"
#import "QualityOfServicesViewController.h"
#import "MessageSettingsViewController.h"
#import "OnboardingSpaceViewController.h"
#import "OnboardingExternalCallViewController.h"
#import "PremiumServicesViewController.h"

#import "SettingsIconCell.h"
#import "SettingsSectionHeaderCell.h"
#import "OnboardingConfirmView.h"

#import <TwinmeCommon/Design.h>
#import "SwitchView.h"
#import "UIHelpItem.h"
#import "UIHelpSection.h"

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static NSString *HEADER_SETTINGS_CELL_IDENTIFIER = @"HeaderSettingsCellIdentifier";
static NSString *SETTINGS_ICON_CELL_IDENTIFIER = @"SettingsIconCellIdentifier";

//
// Interface: HelpViewController
//

@interface HelpViewController ()<UITableViewDelegate, UITableViewDataSource, SettingsActionDelegate, BottomSheetViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) NSMutableArray<UIHelpSection *> *helpSections;

@end

//
// Implementation: HelpViewController
//

#undef LOG_TAG
#define LOG_TAG @"HelpViewController"

@implementation HelpViewController

- (void)viewDidLoad {
    DDLogVerbose(@"%@ viewDidLoad", LOG_TAG);
    
    [super viewDidLoad];
    
    [self initViews];
}

- (void)viewWillAppear:(BOOL)animated {
    DDLogVerbose(@"%@ viewWillAppear: %@", LOG_TAG, animated ? @"YES" : @"NO");
    
    [super viewWillAppear:animated];
    
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

#pragma mark - SettingsActionDelegate

- (void)switchChangeValue:(SwitchView *)updatedSwitch {
    DDLogVerbose(@"%@ switchChangeValue: %@", LOG_TAG, updatedSwitch);
    
    [self.twinmeApplication setShowCoachMark:updatedSwitch.isOn];
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    DDLogVerbose(@"%@ numberOfSectionsInTableView: %@", LOG_TAG, tableView);
    
    return self.helpSections.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath  {
    DDLogVerbose(@"%@ tableView: %@ heightForRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    return Design.SETTING_CELL_HEIGHT;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ heightForHeaderInSection: %ld", LOG_TAG, tableView, (long)section);
    
    UIHelpSection *helpSection = [self.helpSections objectAtIndex:section];
    if ([helpSection.title isEqual:@""]) {
        return CGFLOAT_MIN;
    }
    return Design.SETTING_SECTION_HEIGHT;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ heightForFooterInSection: %ld", LOG_TAG, tableView, (long)section);
    
    return CGFLOAT_MIN;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ numberOfRowsInSection: %ld", LOG_TAG, tableView, (long)section);
    
    UIHelpSection *helpSection = [self.helpSections objectAtIndex:section];
    return helpSection.items.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ viewForHeaderInSection: %ld", LOG_TAG, tableView, (long)section);
    
    UIHelpSection *helpSection = [self.helpSections objectAtIndex:section];
    if ([helpSection.title isEqual:@""]) {
        return [[UIView alloc]init];
    }
    
    SettingsSectionHeaderCell *settingsSectionHeaderCell = (SettingsSectionHeaderCell *)[tableView dequeueReusableCellWithIdentifier:HEADER_SETTINGS_CELL_IDENTIFIER];
    if (!settingsSectionHeaderCell) {
        settingsSectionHeaderCell = [[SettingsSectionHeaderCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:HEADER_SETTINGS_CELL_IDENTIFIER];
    }
    
    [settingsSectionHeaderCell bindWithTitle:helpSection.title backgroundColor:Design.LIGHT_GREY_BACKGROUND_COLOR hideSeparator:NO uppercaseString:YES];
    
    return settingsSectionHeaderCell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ cellForRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    UIHelpSection *helpSection = [self.helpSections objectAtIndex:indexPath.section];
    UIHelpItem *helpItem = [helpSection.items objectAtIndex:indexPath.row];
    
    SettingsIconCell *cell = [tableView dequeueReusableCellWithIdentifier:SETTINGS_ICON_CELL_IDENTIFIER];
    if (!cell) {
        cell = [[SettingsIconCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:SETTINGS_ICON_CELL_IDENTIFIER];
    }
    
    [cell bindWithTitle:helpItem.title icon:helpItem.icon textColor:Design.FONT_COLOR_DEFAULT iconTintColor:Design.BLACK_COLOR hideSeparator:NO];
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ didSelectRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    UIHelpSection *helpSection = [self.helpSections objectAtIndex:indexPath.section];
    UIHelpItem *helpItem = [helpSection.items objectAtIndex:indexPath.row];
    
    switch (helpItem.helpItemType) {
        case HelpItemTypeGettingStarted: {
            WebViewController *webViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"WebViewController"];
            webViewController.fileName = TwinmeLocalizedString(@"help_url", nil);
            webViewController.name = TwinmeLocalizedString(@"navigation_view_help", nil);
            [self.navigationController pushViewController:webViewController animated:YES];
            break;
        }
            
        case HelpItemTypeFAQ: {
            FAQViewController *faqViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"FAQViewController"];
            [self.navigationController pushViewController:faqViewController animated:YES];
            break;
        }
            
        case HelpItemTypeBlog: {
            SFSafariViewController *safariViewController = [[SFSafariViewController alloc]initWithURL:[NSURL URLWithString: TwinmeLocalizedString(@"blog_url", nil)]];
            [self.navigationController presentViewController:safariViewController animated:YES completion:nil];
            break;
        }
            
        case HelpItemTypeFeedback: {
            FeedbackViewController *feedbackViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"FeedbackViewController"];
            [self.navigationController pushViewController:feedbackViewController animated:YES];
            break;
        }
            
        case HelpItemTypeWelcome: {
            WelcomeHelpViewController *welcomeViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"WelcomeHelpViewController"];
            [welcomeViewController showInView:self.navigationController];
            break;
        }
            
        case HelpItemTypeProfile: {
            [self startOnboarding:HelpItemTypeProfile];
            break;
        }
            
        case HelpItemTypeCertifiedRelation: {
            [self startOnboarding:HelpItemTypeCertifiedRelation];
            break;
        }
            
        case HelpItemTypeQualityOfServices: {
            QualityOfServicesViewController *qualityOfServicesViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"QualityOfServicesViewController"];
            [qualityOfServicesViewController showInView:self.navigationController];
            break;
        }
            
        case HelpItemTypeAccountTransfer: {
            [self startOnboarding:HelpItemTypeAccountTransfer];
            break;
        }
            
        case HelpItemTypeAdditionalFunctions: {
            PremiumServicesViewController *premiumServicesViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PremiumServicesViewController"];
            premiumServicesViewController.hideDoNotShow = YES;
            [self.navigationController presentViewController:premiumServicesViewController animated:YES completion:nil];
            break;
        }
            
        case HelpItemTypeSpaces: {
            OnboardingSpaceViewController *onboardingSpaceViewController = [[UIStoryboard storyboardWithName:@"Space" bundle:nil] instantiateViewControllerWithIdentifier:@"OnboardingSpaceViewController"];
            onboardingSpaceViewController.startFromSupportSection = YES;
            [onboardingSpaceViewController showInView:self.navigationController hideFirstPart:NO];
            break;
        }
            
        case HelpItemTypeClickToCall: {
            OnboardingExternalCallViewController *onboardingExternalCallViewController = [[UIStoryboard storyboardWithName:@"ExternalCall" bundle:nil] instantiateViewControllerWithIdentifier:@"OnboardingExternalCallViewController"];
            onboardingExternalCallViewController.startFromSupportSection = YES;
            [onboardingExternalCallViewController showInView:self.navigationController];
            break;
        }
            
        case HelpItemTypeBackup: {
            [self startOnboarding:HelpItemTypeBackup];
            break;
        }
            
        case HelpItemTypeProxy: {
            [self startOnboarding:HelpItemTypeProxy];
            break;
        }
            
        default:
            break;
    }
}

#pragma mark - BottomSheetViewDelegate

- (void)didTapConfirm:(nonnull AbstractBottomSheetView *)abstractBottomSheetView {
    DDLogVerbose(@"%@ didTapConfirm: %@", LOG_TAG, abstractBottomSheetView);
    
    [abstractBottomSheetView closeConfirmView];
}

- (void)didTapCancel:(nonnull AbstractBottomSheetView *)abstractBottomSheetView {
    DDLogVerbose(@"%@ didTapCancel: %@", LOG_TAG, abstractBottomSheetView);
    
    [abstractBottomSheetView closeConfirmView];
}

- (void)didClose:(nonnull AbstractBottomSheetView *)abstractBottomSheetView {
    DDLogVerbose(@"%@ didClose: %@", LOG_TAG, abstractBottomSheetView);
    
    [abstractBottomSheetView closeConfirmView];
}

- (void)didFinishCloseAnimation:(nonnull AbstractBottomSheetView *)abstractBottomSheetView {
    DDLogVerbose(@"%@ didFinishCloseAnimation: %@", LOG_TAG, abstractBottomSheetView);
        
    [abstractBottomSheetView removeFromSuperview];
}

#pragma mark - Private methods

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    self.view.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
    
    [self setNavigationTitle:TwinmeLocalizedString(@"navigation_view_help", nil)];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerNib:[UINib nibWithNibName:@"SettingsIconCell" bundle:nil] forCellReuseIdentifier:SETTINGS_ICON_CELL_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"SettingsSectionHeaderCell" bundle:nil] forCellReuseIdentifier:HEADER_SETTINGS_CELL_IDENTIFIER];
    self.tableView.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
    
    [self initSections];
}

- (void)initSections {
    DDLogVerbose(@"%@ initSections", LOG_TAG);
    
    self.helpSections = [[NSMutableArray alloc] init];
    [self.helpSections addObject:[[UIHelpSection alloc]initWithType:HelpSectionTypeGeneral]];
    [self.helpSections addObject:[[UIHelpSection alloc]initWithType:HelpSectionTypeStandardServices]];
    [self.helpSections addObject:[[UIHelpSection alloc]initWithType:HelpSectionTypePremiumServices]];
    [self.helpSections addObject:[[UIHelpSection alloc]initWithType:HelpSectionTypeAdvancedServices]];
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    [self.tableView reloadData];
}

- (void)startOnboarding:(HelpItemType)helpItemType {
    DDLogVerbose(@"%@ startOnboarding: %d", LOG_TAG, helpItemType);
    
    OnboardingConfirmView *onboardingConfirmView = [[OnboardingConfirmView alloc] init];
    onboardingConfirmView.bottomSheetViewDelegate = self;
    
    UIImage *image;
    NSString *title;
    NSString *message;
    
    if (helpItemType == HelpItemTypeProfile) {
        
        title =  TwinmeLocalizedString(@"application_profile", nil);
        
        NSMutableString *mutableString = [[NSMutableString alloc] initWithString:TwinmeLocalizedString(@"create_profile_view_onboarding_message_part_1", nil)];
        [mutableString appendString:@"\n\n"];
        [mutableString appendString:TwinmeLocalizedString(@"create_profile_view_onboarding_message_part_2", nil)];
        [mutableString appendString:@"\n\n"];
        [mutableString appendString:TwinmeLocalizedString(@"create_profile_view_onboarding_message_part_3", nil)];
        [mutableString appendString:@"\n\n"];
        [mutableString appendString:TwinmeLocalizedString(@"create_profile_view_onboarding_message_part_4", nil)];
        
        message = mutableString;
        
        image = [self.twinmeApplication darkModeEnable:[self currentSpaceSettings]] ? [UIImage imageNamed:@"OnboardingAddProfileDark"] : [UIImage imageNamed:@"OnboardingAddProfile"];
    } else if (helpItemType == HelpItemTypeCertifiedRelation) {
        title =  TwinmeLocalizedString(@"authentified_relation_view_title", nil);
        message =  TwinmeLocalizedString(@"authentified_relation_view_onboarding_message", nil);
        image = [self.twinmeApplication darkModeEnable:[self currentSpaceSettings]] ? [UIImage imageNamed:@"OnboardingAuthentifiedRelationDark"] : [UIImage imageNamed:@"OnboardingAuthentifiedRelation"];
    } else if (helpItemType == HelpItemTypeAccountTransfer) {
        title =  TwinmeLocalizedString(@"account_view_transfer_between_devices", nil);
        message = TwinmeLocalizedString(@"account_view_migration_message", nil);
        image = [self.twinmeApplication darkModeEnable:[self currentSpaceSettings]] ? [UIImage imageNamed:@"OnboardingMigrationDark"] : [UIImage imageNamed:@"OnboardingMigration"];
    } else if (helpItemType == HelpItemTypeProxy) {
        title =  TwinmeLocalizedString(@"proxy_view_title", nil);
        message = TwinmeLocalizedString(@"proxy_view_onboarding", nil);
        image = [UIImage imageNamed:@"OnboardingProxy"];
    } else if (helpItemType == HelpItemTypeBackup) {
        title = TwinmeLocalizedStringFromTable(@"account_view_backup_restore", @"LocalizableBackup", nil);
        
        NSMutableString *mutableString = [[NSMutableString alloc] initWithString:@""];
        [mutableString appendString:TwinmeLocalizedStringFromTable(@"backup_view_beta_message_part_1", @"LocalizableBackup", nil)];
        [mutableString appendString:@"\n\n"];
        [mutableString appendString:TwinmeLocalizedStringFromTable(@"backup_view_beta_message_part_2", @"LocalizableBackup", nil)];
        [mutableString appendString:@"\n\n"];
        [mutableString appendString:TwinmeLocalizedStringFromTable(@"backup_view_beta_message_part_3", @"LocalizableBackup", nil)];
        message = mutableString;
        
        image = [UIImage imageNamed:@"OnboardingBackup"];
    }
    
    [onboardingConfirmView initWithTitle:title message:message image:image action:TwinmeLocalizedString(@"application_ok", nil) actionColor:nil cancel:nil];
    
    NSMutableAttributedString *attributedTitle = [[NSMutableAttributedString alloc] initWithString:title attributes:[NSDictionary dictionaryWithObjectsAndKeys:Design.FONT_BOLD36, NSFontAttributeName, Design.FONT_COLOR_DEFAULT, NSForegroundColorAttributeName, nil]];
    [onboardingConfirmView updateTitle:attributedTitle];
    
    [onboardingConfirmView hideCancelAction];
    [self.navigationController.view addSubview:onboardingConfirmView];
    [onboardingConfirmView showConfirmView];

}

@end
