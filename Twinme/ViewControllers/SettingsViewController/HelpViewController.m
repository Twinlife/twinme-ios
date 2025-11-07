/*
 *  Copyright (c) 2021 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <Utils/NSString+Utils.h>
#import <SafariServices/SafariServices.h>

#import "HelpViewController.h"

#import "AccountViewController.h"
#import "FeedbackViewController.h"
#import "WebViewController.h"
#import "WelcomeHelpViewController.h"
#import "PremiumServicesViewController.h"
#import "QualityOfServicesViewController.h"
#import "MessageSettingsViewController.h"
#import "OnboardingSpaceViewController.h"
#import "OnboardingExternalCallViewController.h"

#import "TwinmeSettingsItemCell.h"
#import "SettingsSectionHeaderCell.h"
#import "SettingsItemCell.h"
#import "OnboardingConfirmView.h"

#import <TwinmeCommon/Design.h>
#import "SwitchView.h"

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static NSString *HEADER_SETTINGS_CELL_IDENTIFIER = @"HeaderSettingsCellIdentifier";
static NSString *TWINME_SETTINGS_CELL_IDENTIFIER = @"TwinmeSettingsCellIdentifier";
static NSString *SETTINGS_CELL_IDENTIFIER = @"SettingsCellIdentifier";

static const int HELP_VIEW_SECTION = 0;
static const int INFORMATION_VIEW_SECTION = 1;

static const int HELP_ROW = 0;
static const int FAQ_ROW = 1;
static const int BLOG_ROW = 2;
static const int FEEDBACK_ROW = 3;

static const int WELCOME_ROW = 0;
static const int QUALITY_OF_SERVICES_ROW = 1;
static const int PREMIUM_SERVICES_ROW = 2;
static const int ONBOARDING_SPACES_ROW = 3;
static const int ONBOARDING_PROFILE_ROW = 4;
static const int ONBOARDING_CLICK_TO_CALL_ROW = 5;
static const int ONBOARDING_CERTIFIED_RELATION_ROW = 6;
static const int ONBOARDING_TRANSFER_ROW = 7;
static const int ONBOARDING_PROXY_ROW = 8;
static const int COACH_MARK_ROW = 9;

//
// Interface: HelpViewController
//

@interface HelpViewController ()<UITableViewDelegate, UITableViewDataSource, SettingsActionDelegate, ConfirmViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

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
    
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath  {
    DDLogVerbose(@"%@ tableView: %@ heightForRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    return Design.SETTING_CELL_HEIGHT;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ heightForHeaderInSection: %ld", LOG_TAG, tableView, (long)section);
    
    if (section == HELP_VIEW_SECTION) {
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
    
    if (section == HELP_VIEW_SECTION) {
        return 4;
    }
    
    return 9;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ viewForHeaderInSection: %ld", LOG_TAG, tableView, (long)section);
    
    if (section == HELP_VIEW_SECTION) {
        return [[UIView alloc]init];
    }
    
    SettingsSectionHeaderCell *settingsSectionHeaderCell = (SettingsSectionHeaderCell *)[tableView dequeueReusableCellWithIdentifier:HEADER_SETTINGS_CELL_IDENTIFIER];
    if (!settingsSectionHeaderCell) {
        settingsSectionHeaderCell = [[SettingsSectionHeaderCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:HEADER_SETTINGS_CELL_IDENTIFIER];
    }
    
    [settingsSectionHeaderCell bindWithTitle:TwinmeLocalizedString(@"about_view_controller_information", nil) backgroundColor:Design.LIGHT_GREY_BACKGROUND_COLOR hideSeparator:NO uppercaseString:YES];
    
    return settingsSectionHeaderCell;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ cellForRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    if (indexPath.section == INFORMATION_VIEW_SECTION && indexPath.row == COACH_MARK_ROW) {
        SettingsItemCell *cell = [tableView dequeueReusableCellWithIdentifier:SETTINGS_CELL_IDENTIFIER];
        if (!cell) {
            cell = [[SettingsItemCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:SETTINGS_CELL_IDENTIFIER];
        }
        
        cell.settingsActionDelegate = self;
        
        [cell bindWithTitle:TwinmeLocalizedString(@"coach_mark_view_controller_setting_title", nil) icon:nil stateSwitch:[self.twinmeApplication showCoachMark] tagSwitch:0 hiddenSwitch:NO disableSwitch:NO backgroundColor:Design.WHITE_COLOR hiddenSeparator:NO];
        return cell;
    } else {
        TwinmeSettingsItemCell *cell = [tableView dequeueReusableCellWithIdentifier:TWINME_SETTINGS_CELL_IDENTIFIER];
        if (!cell) {
            cell = [[TwinmeSettingsItemCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:TWINME_SETTINGS_CELL_IDENTIFIER];
        }
        
        NSString *title = @"";
        
        if (indexPath.section == HELP_VIEW_SECTION) {
            switch (indexPath.row) {
                case HELP_ROW:
                    title = TwinmeLocalizedString(@"side_menu_view_controller_getting_started", nil);
                    break;
                    
                case FAQ_ROW:
                    title = TwinmeLocalizedString(@"side_menu_view_controller_faq", nil);
                    break;
                    
                case BLOG_ROW:
                    title = TwinmeLocalizedString(@"side_menu_view_controller_blog", nil);
                    break;
                    
                case FEEDBACK_ROW:
                    title = TwinmeLocalizedString(@"feedback_view_controller_title", nil);
                    break;
                    
                default:
                    break;
            }
        } else {
            switch (indexPath.row) {
                case WELCOME_ROW:
                    title = TwinmeLocalizedString(@"settings_view_controller_welcome_screen_category_title", nil).capitalizedString;
                    break;
                    
                case QUALITY_OF_SERVICES_ROW:
                    title = TwinmeLocalizedString(@"about_view_controller_quality_of_service", nil);
                    break;
                    
                case PREMIUM_SERVICES_ROW:
                    title = TwinmeLocalizedString(@"about_view_controller_premium_services", nil);
                    break;
                    
                case ONBOARDING_SPACES_ROW:
                    title = TwinmeLocalizedString(@"premium_services_view_controller_space_title", nil);
                    break;
                    
                case ONBOARDING_PROFILE_ROW:
                    title = TwinmeLocalizedString(@"application_profile", nil);
                    break;
                    
                case ONBOARDING_CLICK_TO_CALL_ROW:
                    title = TwinmeLocalizedString(@"premium_services_view_controller_click_to_call_title", nil);
                    break;
                    
                case ONBOARDING_CERTIFIED_RELATION_ROW:
                    title = TwinmeLocalizedString(@"authentified_relation_view_controller_title", nil);
                    break;
                    
                case ONBOARDING_TRANSFER_ROW:
                    title = TwinmeLocalizedString(@"account_view_controller_transfer_between_devices", nil);
                    break;
                    
                case ONBOARDING_PROXY_ROW:
                    title = TwinmeLocalizedString(@"proxy_view_controller_title", nil);
                    break;
                    
                default:
                    break;
            }
        }
        
        [cell bindWithTitle:title hiddenAccessory:NO disableSetting:NO color:Design.FONT_COLOR_DEFAULT];
        
        return cell;
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ didSelectRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    if (indexPath.section == HELP_VIEW_SECTION) {
        if (indexPath.row == HELP_ROW) {
            WebViewController *webViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"WebViewController"];
            webViewController.fileName = TwinmeLocalizedString(@"help_url", nil);
            webViewController.name = TwinmeLocalizedString(@"side_menu_view_controller_help", nil);
            [self.navigationController pushViewController:webViewController animated:YES];
        } else if (indexPath.row == FAQ_ROW) {
            SFSafariViewController *safariViewController = [[SFSafariViewController alloc]initWithURL:[NSURL URLWithString: TwinmeLocalizedString(@"faq_url", nil)]];
            [self.navigationController presentViewController:safariViewController animated:YES completion:nil];
        } else if (indexPath.row == BLOG_ROW) {
            SFSafariViewController *safariViewController = [[SFSafariViewController alloc]initWithURL:[NSURL URLWithString: TwinmeLocalizedString(@"blog_url", nil)]];
            [self.navigationController presentViewController:safariViewController animated:YES completion:nil];
        } else if (indexPath.row == FEEDBACK_ROW) {
            FeedbackViewController *feedbackViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"FeedbackViewController"];
            [self.navigationController pushViewController:feedbackViewController animated:YES];
        }
    } else {
        if (indexPath.row == WELCOME_ROW) {
            WelcomeHelpViewController *welcomeViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"WelcomeHelpViewController"];
            [welcomeViewController showInView:self.navigationController];
        } else if (indexPath.row == QUALITY_OF_SERVICES_ROW) {
            QualityOfServicesViewController *qualityOfServicesViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"QualityOfServicesViewController"];
            [qualityOfServicesViewController showInView:self.navigationController];
        } else if (indexPath.row == PREMIUM_SERVICES_ROW) {
            PremiumServicesViewController *premiumServicesViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PremiumServicesViewController"];
            premiumServicesViewController.hideDoNotShow = YES;
            [self.navigationController presentViewController:premiumServicesViewController animated:YES completion:nil];
        } else if (indexPath.row == ONBOARDING_PROFILE_ROW) {
            [self startOnboarding:ONBOARDING_PROFILE_ROW];
        } else if (indexPath.row == ONBOARDING_SPACES_ROW) {
            OnboardingSpaceViewController *onboardingSpaceViewController = [[UIStoryboard storyboardWithName:@"iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"OnboardingSpaceViewController"];
            onboardingSpaceViewController.startFromSupportSection = YES;
            [onboardingSpaceViewController showInView:self.navigationController hideFirstPart:NO];
        } else if (indexPath.row == ONBOARDING_CLICK_TO_CALL_ROW) {
            OnboardingExternalCallViewController *onboardingExternalCallViewController = [[UIStoryboard storyboardWithName:@"ExternalCall" bundle:nil] instantiateViewControllerWithIdentifier:@"OnboardingExternalCallViewController"];
            onboardingExternalCallViewController.startFromSupportSection = YES;
            [onboardingExternalCallViewController showInView:self.navigationController];
        } else if (indexPath.row == ONBOARDING_CERTIFIED_RELATION_ROW) {
            [self startOnboarding:ONBOARDING_CERTIFIED_RELATION_ROW];
        } else if (indexPath.row == ONBOARDING_TRANSFER_ROW) {
            [self startOnboarding:ONBOARDING_TRANSFER_ROW];
        } else if (indexPath.row == ONBOARDING_PROXY_ROW) {
            [self startOnboarding:ONBOARDING_PROXY_ROW];
        }
    }
}

#pragma mark - ConfirmViewDelegate

- (void)didTapConfirm:(nonnull AbstractConfirmView *)abstractConfirmView {
    DDLogVerbose(@"%@ didTapConfirm: %@", LOG_TAG, abstractConfirmView);
    
    [abstractConfirmView closeConfirmView];
}

- (void)didTapCancel:(nonnull AbstractConfirmView *)abstractConfirmView {
    DDLogVerbose(@"%@ didTapCancel: %@", LOG_TAG, abstractConfirmView);
    
    [abstractConfirmView closeConfirmView];
}

- (void)didClose:(nonnull AbstractConfirmView *)abstractConfirmView {
    DDLogVerbose(@"%@ didClose: %@", LOG_TAG, abstractConfirmView);
    
    [abstractConfirmView closeConfirmView];
}

- (void)didFinishCloseAnimation:(nonnull AbstractConfirmView *)abstractConfirmView {
    DDLogVerbose(@"%@ didFinishCloseAnimation: %@", LOG_TAG, abstractConfirmView);
        
    [abstractConfirmView removeFromSuperview];
}

#pragma mark - Private methods

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    self.view.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
    
    [self setNavigationTitle:TwinmeLocalizedString(@"side_menu_view_controller_help", nil)];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerNib:[UINib nibWithNibName:@"TwinmeSettingsItemCell" bundle:nil] forCellReuseIdentifier:TWINME_SETTINGS_CELL_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"SettingsItemCell" bundle:nil] forCellReuseIdentifier:SETTINGS_CELL_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"SettingsSectionHeaderCell" bundle:nil] forCellReuseIdentifier:HEADER_SETTINGS_CELL_IDENTIFIER];
    self.tableView.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    [self.tableView reloadData];
}

- (void)startOnboarding:(int)row {
    DDLogVerbose(@"%@ startOnboarding: %d", LOG_TAG, row);
    
    OnboardingConfirmView *onboardingConfirmView = [[OnboardingConfirmView alloc] init];
    onboardingConfirmView.confirmViewDelegate = self;
    
    UIImage *image;
    NSString *title;
    NSString *message;
    
    if (row == ONBOARDING_PROFILE_ROW) {
        
        title =  TwinmeLocalizedString(@"application_profile", nil);
        
        NSMutableString *mutableString = [[NSMutableString alloc] initWithString:TwinmeLocalizedString(@"create_profile_view_controller_onboarding_message_part_1", nil)];
        [mutableString appendString:@"\n\n"];
        [mutableString appendString:TwinmeLocalizedString(@"create_profile_view_controller_onboarding_message_part_2", nil)];
        [mutableString appendString:@"\n\n"];
        [mutableString appendString:TwinmeLocalizedString(@"create_profile_view_controller_onboarding_message_part_3", nil)];
        [mutableString appendString:@"\n\n"];
        [mutableString appendString:TwinmeLocalizedString(@"create_profile_view_controller_onboarding_message_part_4", nil)];
        
        message = mutableString;
        
        image = [self.twinmeApplication darkModeEnable] ? [UIImage imageNamed:@"OnboardingAddProfileDark"] : [UIImage imageNamed:@"OnboardingAddProfile"];
    } else if (row == ONBOARDING_CERTIFIED_RELATION_ROW) {
        title =  TwinmeLocalizedString(@"authentified_relation_view_controller_title", nil);
        message =  TwinmeLocalizedString(@"authentified_relation_view_controller_onboarding_message", nil);
        image = [self.twinmeApplication darkModeEnable] ? [UIImage imageNamed:@"OnboardingAuthentifiedRelationDark"] : [UIImage imageNamed:@"OnboardingAuthentifiedRelation"];
    } else if (row == ONBOARDING_TRANSFER_ROW) {
        title =  TwinmeLocalizedString(@"account_view_controller_transfer_between_devices", nil);
        message = TwinmeLocalizedString(@"account_view_controller_migration_message", nil);
        image = [self.twinmeApplication darkModeEnable] ? [UIImage imageNamed:@"OnboardingMigrationDark"] : [UIImage imageNamed:@"OnboardingMigration"];
    } else if (row == ONBOARDING_PROXY_ROW) {
        title =  TwinmeLocalizedString(@"proxy_view_controller_title", nil);
        message = TwinmeLocalizedString(@"proxy_view_controller_onboarding", nil);
        image = [UIImage imageNamed:@"OnboardingProxy"];
    }
    
    [onboardingConfirmView initWithTitle:title message:message image:image action:TwinmeLocalizedString(@"application_ok", nil) actionColor:nil cancel:nil];
    
    NSMutableAttributedString *attributedTitle = [[NSMutableAttributedString alloc] initWithString:title attributes:[NSDictionary dictionaryWithObjectsAndKeys:Design.FONT_BOLD36, NSFontAttributeName, Design.FONT_COLOR_DEFAULT, NSForegroundColorAttributeName, nil]];
    [onboardingConfirmView updateTitle:attributedTitle];
    
    [onboardingConfirmView hideCancelAction];
    [self.navigationController.view addSubview:onboardingConfirmView];
    [onboardingConfirmView showConfirmView];

}

@end
