/*
 *  Copyright (c) 2020-2024 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <Twinlife/TLAccountService.h>
#import <Twinme/TLProfile.h>
#import <Twinme/TLContact.h>
#import <Twinme/TLCallReceiver.h>

#import <Utils/NSString+Utils.h>

#import "SideMenuViewController.h"

#import "EditProfileViewController.h"
#import "ShowProfileViewController.h"
#import "FeedbackViewController.h"
#import "MessageSettingsViewController.h"
#import "WebViewController.h"
#import "TwinmeSettingsItemCell.h"
#import "SettingsSectionHeaderCell.h"
#import "DefaultProfileCell.h"
#import "AddProfileViewController.h"
#import "AccountViewController.h"
#import "SoundSettingsViewController.h"
#import "PersonalizationViewController.h"
#import "SettingsAdvancedViewController.h"
#import "AddContactViewController.h"
#import "WelcomeViewController.h"
#import "HelpViewController.h"
#import "AboutViewController.h"
#import "PremiumServicesViewController.h"
#import "PrivacyViewController.h"
#import "CoachMarkViewController.h"

#import <TwinmeCommon/ApplicationDelegate.h>
#import <TwinmeCommon/MainViewController.h>
#import <TwinmeCommon/TwinmeNavigationController.h>
#import "TabBarViewController.h"
#import "UIProfile.h"
#import "UIPremiumFeature.h"
#import "PremiumFeatureConfirmView.h"
#import "OnboardingDetailView.h"
#import "MenuAddContactView.h"

#import "LastVersionManager.h"

#import <TwinmeCommon/Design.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

#define DELAY_COACH_MARK 0.5

static const int SETTINGS_VIEW_SECTION_COUNT = 3;

static const int HEADER_VIEW_SECTION = 0;
static const int SETTINGS_VIEW_SECTION = 1;
static const int SUPPORT_VIEW_SECTION = 2;
static const int LOGOUT_VIEW_SECTION = 3;

static CGFloat DESIGN_SECTION_SETTING_HEIGHT = 80;
static CGFloat DESIGN_SECTION_SUPPORT_HEIGHT = 120;
static CGFloat DESIGN_CELL_HEIGHT = 110;
static CGFloat DESIGN_PROFILES_MENU_WIDTH = 160;
static CGFloat DESIGN_PROFILE_CELL_HEIGHT = 260;
static CGFloat DESIGN_LIST_PROFILE_CELL_HEIGHT = 160;

static NSInteger NUMBER_TAP_HIDDEN_MODE = 8;

static NSString *DEFAULT_PROFILE_CELL_IDENTIFIER = @"DefaultProfileCellIdentifier";
static NSString *TWINME_SETTINGS_CELL_IDENTIFIER = @"TwinmeSettingsCellIdentifier";
static NSString *HEADER_SETTINGS_CELL_IDENTIFIER = @"HeaderSettingsCellIdentifier";

//
// Interface: SideMenuViewController ()
//

@interface SideMenuViewController ()<UITableViewDelegate, UITableViewDataSource, DefaultProfileDelegate, CoachMarkDelegate, ConfirmViewDelegate, MenuAddContactViewDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *profilesTableViewWidthConstraint;
@property (weak, nonatomic) IBOutlet UITableView *profilesTableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separatorViewWidthConstraint;
@property (weak, nonatomic) IBOutlet UIView *separatorView;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic) CoachMarkViewController *coachMarkViewController;

@property (nonatomic) NSArray *uiProfiles;
@property (nonatomic) UIProfile *uiProfile;

@property (nonatomic) TLCallReceiver *callReceiver;

@property (nonatomic) BOOL hiddenMode;
@property (nonatomic) BOOL refreshTableScheduled;

@end

//
// Implementation: SideMenuViewController
//

#undef LOG_TAG
#define LOG_TAG @"SideMenuViewController"

@implementation SideMenuViewController

- (void)viewDidLoad {
    DDLogVerbose(@"%@ viewDidLoad", LOG_TAG);
    
    [super viewDidLoad];
    
    [self initViews];
}

- (void)reloadMenu {
    DDLogVerbose(@"%@ reloadMenu", LOG_TAG);
    
    [self.tableView reloadData];
    [self updateColor];
}

- (void)setProfile:(UIProfile *)profile {
    DDLogVerbose(@"%@ setProfile: %@", LOG_TAG, profile);
    
    self.uiProfile = profile;
    [self reloadMenu];
}

- (void)setUIProfiles:(NSArray *)uiProfiles {
    DDLogVerbose(@"%@ setUIProfiles: %@", LOG_TAG, uiProfiles);
    
    self.uiProfiles = uiProfiles;

    if (self.uiProfiles.count > 1) {
        self.profilesTableViewWidthConstraint.constant = DESIGN_PROFILES_MENU_WIDTH * Design.HEIGHT_RATIO;
    } else {
        self.profilesTableViewWidthConstraint.constant = 0;
    }
    
    [self.profilesTableView reloadData];
}

- (void)setTransferCall:(TLCallReceiver *)callReceiver {
    DDLogVerbose(@"%@ setTransferCall: %@", LOG_TAG, callReceiver);
    
    self.callReceiver = callReceiver;
}

- (void)deleteTransferCall:(NSUUID *)callReceiverId {
    DDLogVerbose(@"%@ deleteTransferCall: %@", LOG_TAG, callReceiverId);
    
    if (self.callReceiver && [self.callReceiver.uuid isEqual:callReceiverId]) {
        self.callReceiver = nil;
    }
}

- (void)openSideMenu {
    DDLogVerbose(@"%@ openSideMenu", LOG_TAG);

    [self showCoachMark];
}

- (void)closeSideMenu {
    DDLogVerbose(@"%@ closeSideMenu", LOG_TAG);
    
    if (self.coachMarkViewController) {
        [self.coachMarkViewController closeView];
        self.coachMarkViewController = nil;
    }
}

- (void)refreshTable {
    DDLogVerbose(@"%@ refreshTable", LOG_TAG);

    // Schedule only one table reload for possibly several asynchronous fetch of images.
    if (!self.refreshTableScheduled) {
        self.refreshTableScheduled = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            self.refreshTableScheduled = NO;
            [self.profilesTableView reloadData];
        });
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    DDLogVerbose(@"%@ numberOfSectionsInTableView: %@", LOG_TAG, tableView);
    
    if (tableView == self.tableView) {
        return self.hiddenMode ? SETTINGS_VIEW_SECTION_COUNT : SETTINGS_VIEW_SECTION_COUNT + 1;
    }
    
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath  {
    
    if (tableView == self.tableView) {
        if (indexPath.section == HEADER_VIEW_SECTION && indexPath.row == 0) {
            return round(DESIGN_PROFILE_CELL_HEIGHT * Design.HEIGHT_RATIO);
        }
        return round(DESIGN_CELL_HEIGHT * Design.HEIGHT_RATIO);
    }
    
    return round(DESIGN_LIST_PROFILE_CELL_HEIGHT * Design.HEIGHT_RATIO);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ heightForHeaderInSection: %ld", LOG_TAG, tableView, (long)section);
    
    if (tableView == self.profilesTableView || section == HEADER_VIEW_SECTION) {
        return CGFLOAT_MIN;
    }

    if (section == SETTINGS_VIEW_SECTION) {
        return round(DESIGN_SECTION_SETTING_HEIGHT * Design.HEIGHT_RATIO);
    }
    return round(DESIGN_SECTION_SUPPORT_HEIGHT * Design.HEIGHT_RATIO);
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ heightForFooterInSection: %ld", LOG_TAG, tableView, (long)section);
    
    return CGFLOAT_MIN;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ viewForHeaderInSection: %ld", LOG_TAG, tableView, (long)section);
    
    if (tableView == self.profilesTableView || section == HEADER_VIEW_SECTION) {
        return [[UITableViewCell alloc]init];
    }
    
    SettingsSectionHeaderCell *settingsSectionHeaderCell = (SettingsSectionHeaderCell *)[tableView dequeueReusableCellWithIdentifier:HEADER_SETTINGS_CELL_IDENTIFIER];
    if (!settingsSectionHeaderCell) {
        settingsSectionHeaderCell = [[SettingsSectionHeaderCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:HEADER_SETTINGS_CELL_IDENTIFIER];
    }
    
    NSString *sectionName = @"";
    
    switch (section) {
        case HEADER_VIEW_SECTION:
            sectionName = @"";
            break;
            
        case SETTINGS_VIEW_SECTION:
            sectionName = TwinmeLocalizedString(@"side_menu_view_controller_application_settings", nil);
            break;
            
        case SUPPORT_VIEW_SECTION:
            sectionName = TwinmeLocalizedString(@"side_menu_view_controller_support", nil);
            break;
            
        case LOGOUT_VIEW_SECTION:
            sectionName = TwinmeLocalizedString(@"side_menu_view_controller_sign_out", nil);
            break;
            
        default:
            sectionName = @"";
            break;
    }
    
    [settingsSectionHeaderCell bindWithTitle:sectionName backgroundColor:Design.LIGHT_GREY_BACKGROUND_COLOR hideSeparator:NO uppercaseString:YES];
    
    return settingsSectionHeaderCell;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ numberOfRowsInSection: %ld", LOG_TAG, tableView, (long)section);
    
    if (tableView == self.profilesTableView) {
        if (self.uiProfiles.count > 1) {
            return self.uiProfiles.count;
        }
        
        return 0;
    }
    
    NSInteger numberOfRowsInSection;
    switch (section) {
        case HEADER_VIEW_SECTION:
            numberOfRowsInSection = 1;
            break;
            
        case SETTINGS_VIEW_SECTION:
            numberOfRowsInSection = 6;
            break;
            
        case SUPPORT_VIEW_SECTION:
            numberOfRowsInSection = 4;
            break;
            
        case LOGOUT_VIEW_SECTION:
            numberOfRowsInSection = 1;
            break;
            
        default:
            numberOfRowsInSection = 0;
            break;
    }
    return numberOfRowsInSection;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ cellForRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    if (indexPath.section == HEADER_VIEW_SECTION && indexPath.row == 0) {
        DefaultProfileCell *cell = (DefaultProfileCell *)[tableView dequeueReusableCellWithIdentifier:DEFAULT_PROFILE_CELL_IDENTIFIER];
        if (!cell) {
            cell = [[DefaultProfileCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:DEFAULT_PROFILE_CELL_IDENTIFIER];
        }
        
        cell.delegate = self;
        if (self.uiProfile) {
            [cell bindWithName:self.uiProfile.name avatar:self.uiProfile.avatar];
        } else {
            [cell bindWithName:TwinmeLocalizedString(@"profiles_view_controller_add_profile", nil) avatar:[TLContact ANONYMOUS_AVATAR]];
        }
        
        return cell;
    } else {
        TwinmeSettingsItemCell *cell = [tableView dequeueReusableCellWithIdentifier:TWINME_SETTINGS_CELL_IDENTIFIER];
        if (!cell) {
            cell = [[TwinmeSettingsItemCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:TWINME_SETTINGS_CELL_IDENTIFIER];
        }
        
        NSString *title = @"";
        BOOL hiddenAccessory = NO;
        
        switch (indexPath.section) {
            case SETTINGS_VIEW_SECTION:
                if (indexPath.row == 0) {
                    hiddenAccessory = NO;
                    title = TwinmeLocalizedString(@"application_appearance", nil);
                } else if (indexPath.row == 1) {
                    hiddenAccessory = NO;
                    title = TwinmeLocalizedString(@"settings_view_controller_chat_category_title", nil);
                } else if (indexPath.row == 2) {
                    hiddenAccessory = NO;
                    title = TwinmeLocalizedString(@"application_notifications", nil);
                } else if (indexPath.row == 3) {
                    hiddenAccessory = NO;
                    title = TwinmeLocalizedString(@"privacy_view_controller_title", nil);
                } else if (indexPath.row == 4) {
                    hiddenAccessory = NO;
                    title = TwinmeLocalizedString(@"premium_services_view_controller_transfert_title", nil);
                } else if (indexPath.row == 5) {
                    hiddenAccessory = NO;
                    title = TwinmeLocalizedString(@"settings_advanced_view_controller_title", nil);
                }
                break;
                
            case SUPPORT_VIEW_SECTION:
                if (indexPath.row == 0) {
                    hiddenAccessory = NO;
                    title = TwinmeLocalizedString(@"side_menu_view_controller_help", nil);
                } else if (indexPath.row == 1) {
                    hiddenAccessory = NO;
                    title = TwinmeLocalizedString(@"side_menu_view_controller_about", nil);
                } else if (indexPath.row == 2) {
                    hiddenAccessory = NO;
                    title = TwinmeLocalizedString(@"account_view_controller_title", nil);
                } else if (indexPath.row == 3) {
                    hiddenAccessory = NO;
                    title = TwinmeLocalizedString(@"migration_twinme_plus_view_controller_upgrade_title", nil);
                }
                break;
                
            case LOGOUT_VIEW_SECTION:
                hiddenAccessory = YES;
                title = TwinmeLocalizedString(@"side_menu_view_controller_sign_out", nil);
                break;
                
            default:
                break;
        }
        
        if (indexPath.section == SUPPORT_VIEW_SECTION && indexPath.row == 1) {
            [cell bindWithTitle:title hiddenAccessory:hiddenAccessory disableSetting:NO updateAvailable:[self.twinmeApplication.lastVersionManager isNewVersionAvailable] color:Design.FONT_COLOR_DEFAULT];
        } else {
            [cell bindWithTitle:title hiddenAccessory:hiddenAccessory disableSetting:NO color:Design.FONT_COLOR_DEFAULT];
        }
        
        return cell;
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ didSelectRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    [self openSideMenu:NO];
    
    ApplicationDelegate *delegate = (ApplicationDelegate *)[[UIApplication sharedApplication] delegate];
    MainViewController *mainViewController = delegate.mainViewController;
    TwinmeNavigationController *twinmeNavigationController = [mainViewController selectedViewController];
    
    if (tableView == self.tableView) {
        if (indexPath.section == SETTINGS_VIEW_SECTION) {
            if (indexPath.row == 0) {
                PersonalizationViewController *personalizationViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PersonalizationViewController"];
                [twinmeNavigationController pushViewController:personalizationViewController animated:YES];
            } else if (indexPath.row == 1) {
                MessageSettingsViewController *messageSettingsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"MessageSettingsViewController"];
                [twinmeNavigationController pushViewController:messageSettingsViewController animated:YES];
            } else if (indexPath.row == 2) {
                SoundSettingsViewController *soundSettingsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SoundSettingsViewController"];
                [twinmeNavigationController pushViewController:soundSettingsViewController animated:YES];
            } else if (indexPath.row == 3) {
                PrivacyViewController *privacyViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PrivacyViewController"];
                [twinmeNavigationController pushViewController:privacyViewController animated:YES];
            } else if (indexPath.row == 4) {
                [self showOnboarding];
            } else if (indexPath.row == 5) {
                SettingsAdvancedViewController *settingsAdvancedViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SettingsAdvancedViewController"];
                [twinmeNavigationController pushViewController:settingsAdvancedViewController animated:YES];
            }
        } else if (indexPath.section == SUPPORT_VIEW_SECTION) {
            if (indexPath.row == 0) {
                HelpViewController *helpViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"HelpViewController"];
                [twinmeNavigationController pushViewController:helpViewController animated:YES];
            } else if (indexPath.row == 1) {
                AboutViewController *aboutViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AboutViewController"];
                [twinmeNavigationController pushViewController:aboutViewController animated:YES];
            }  else if (indexPath.row == 2) {
                AccountViewController *accountViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AccountViewController"];
                [twinmeNavigationController pushViewController:accountViewController animated:YES];
            } else if (indexPath.row == 3) {
                PremiumServicesViewController *premiumServicesViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PremiumServicesViewController"];
                premiumServicesViewController.hideDoNotShow = YES;
                TwinmeNavigationController *upgradeNavigationController = [[TwinmeNavigationController alloc]initWithRootViewController:premiumServicesViewController];
                [self presentViewController:upgradeNavigationController animated:YES completion:nil];
            }
        } else if (indexPath.section == LOGOUT_VIEW_SECTION) {
            [[self.twinmeContext getAccountService] signOut];
            [self.twinmeApplication stop];
        }
    }
}

#pragma mark - ConfirmViewDelegate

- (void)didTapConfirm:(nonnull AbstractConfirmView *)abstractConfirmView {
    DDLogVerbose(@"%@ didTapConfirm: %@", LOG_TAG, abstractConfirmView);
    
    if ([abstractConfirmView isKindOfClass:[PremiumFeatureConfirmView class]]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:TwinmeLocalizedString(@"twinme_plus_link", nil)] options:@{} completionHandler:nil];
    } else {
        [self showPremiumFeatureView];
    }

    [abstractConfirmView closeConfirmView];
}

- (void)didTapCancel:(nonnull AbstractConfirmView *)abstractConfirmView {
    DDLogVerbose(@"%@ didTapCancel: %@", LOG_TAG, abstractConfirmView);
    
    [abstractConfirmView closeConfirmView];
    
    if ([abstractConfirmView isKindOfClass:[OnboardingDetailView class]]) {
        [self.twinmeApplication setShowOnboardingType:OnboardingTypeTransferCall state:NO];
    }
}

- (void)didClose:(nonnull AbstractConfirmView *)abstractConfirmView {
    DDLogVerbose(@"%@ didClose: %@", LOG_TAG, abstractConfirmView);
    
    [abstractConfirmView closeConfirmView];
}

- (void)didFinishCloseAnimation:(nonnull AbstractConfirmView *)abstractConfirmView {
    DDLogVerbose(@"%@ didFinishCloseAnimation: %@", LOG_TAG, abstractConfirmView);
    
    [abstractConfirmView removeFromSuperview];
}

#pragma mark - DefaultProfileDelegate

- (void)addContact {
    DDLogVerbose(@"%@ addContact", LOG_TAG);
    
    [self openSideMenu:NO];
    
    ApplicationDelegate *delegate = (ApplicationDelegate *)[[UIApplication sharedApplication] delegate];
    MainViewController *mainViewController = delegate.mainViewController;
    TwinmeNavigationController *twinmeNavigationController = [mainViewController selectedViewController];
    
    if (!self.defaultProfile) {
        AddProfileViewController *addProfileViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AddProfileViewController"];
        addProfileViewController.firstProfile = YES;
        [twinmeNavigationController pushViewController:addProfileViewController animated:YES];
    } else {
        MenuAddContactView *menuAddContactView = [[MenuAddContactView alloc]init];
        menuAddContactView.menuAddContactViewDelegate = self;
        [twinmeNavigationController.tabBarController.view addSubview:menuAddContactView];
        [menuAddContactView openMenu];
    }
}

- (void)showProfile {
    DDLogVerbose(@"%@ showProfile", LOG_TAG);
    
    [self openSideMenu:NO];
    
    ApplicationDelegate *delegate = (ApplicationDelegate *)[[UIApplication sharedApplication] delegate];
    MainViewController *mainViewController = delegate.mainViewController;
    TwinmeNavigationController *twinmeNavigationController = [mainViewController selectedViewController];
    
    if (self.defaultProfile) {
        if ([mainViewController getSelectedTab] != 0) {
            ShowProfileViewController *showProfileViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ShowProfileViewController"];
            [showProfileViewController initWithProfile:self.defaultProfile isActive:YES];
            [twinmeNavigationController pushViewController:showProfileViewController animated:YES];
        }
    } else {
        AddProfileViewController *addProfileViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AddProfileViewController"];
        addProfileViewController.firstProfile = YES;
        [twinmeNavigationController pushViewController:addProfileViewController animated:YES];
    }
}

#pragma mark - CoachMarkDelegate

- (void)didTapCoachMarkOverlay:(CoachMarkViewController *)coachMarkViewController {
    DDLogVerbose(@"%@ didTapCoachMarkOverlay: %@", LOG_TAG, coachMarkViewController);
    
    [coachMarkViewController closeView];
    self.coachMarkViewController = nil;
}

- (void)didTapCoachMarkFeature:(CoachMarkViewController *)coachMarkViewController {
    DDLogVerbose(@"%@ didTapCoachMarkFeature: %@", LOG_TAG, coachMarkViewController);
    
    [self.twinmeApplication hideCoachMark:[[coachMarkViewController getCoachMark] coachMarkTag]];
    [coachMarkViewController closeView];
    self.coachMarkViewController = nil;
    
    [self openSideMenu:NO];
    
    ApplicationDelegate *delegate = (ApplicationDelegate *)[[UIApplication sharedApplication] delegate];
    MainViewController *mainViewController = delegate.mainViewController;
    TwinmeNavigationController *twinmeNavigationController = [mainViewController selectedViewController];
    PrivacyViewController *privacyViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PrivacyViewController"];
    [twinmeNavigationController pushViewController:privacyViewController animated:YES];
}

- (void)didLongPressCoachMarkFeature:(CoachMarkViewController *)coachMarkViewController {
    DDLogVerbose(@"%@ didLongPressCoachMarkFeature: %@", LOG_TAG, coachMarkViewController);
    
}

#pragma mark - MenuAddContactViewDelegate

- (void)menuAddContactDidSelectScan:(MenuAddContactView *)menuAddContactView {
    DDLogVerbose(@"%@ menuAddContactDidSelectScan: %@", LOG_TAG, menuAddContactView);
    
    [menuAddContactView removeFromSuperview];
    
    ApplicationDelegate *delegate = (ApplicationDelegate *)[[UIApplication sharedApplication] delegate];
    MainViewController *mainViewController = delegate.mainViewController;
    TwinmeNavigationController *twinmeNavigationController = [mainViewController selectedViewController];
    
    AddContactViewController *addContactViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AddContactViewController"];
    [addContactViewController initWithProfile:self.defaultProfile invitationMode:InvitationModeScan];
    [twinmeNavigationController pushViewController:addContactViewController animated:YES];
}

- (void)menuAddContactDidSelectInvite:(MenuAddContactView *)menuAddContactView {
    DDLogVerbose(@"%@ menuAddContactDidSelectInvite: %@", LOG_TAG, menuAddContactView);
    
    [menuAddContactView removeFromSuperview];
    
    ApplicationDelegate *delegate = (ApplicationDelegate *)[[UIApplication sharedApplication] delegate];
    MainViewController *mainViewController = delegate.mainViewController;
    TwinmeNavigationController *twinmeNavigationController = [mainViewController selectedViewController];
    
    AddContactViewController *addContactViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AddContactViewController"];
    [addContactViewController initWithProfile:self.defaultProfile invitationMode:InvitationModeInvite];
    [twinmeNavigationController pushViewController:addContactViewController animated:YES];
}

- (void)cancelMenuAddContactView:(MenuAddContactView *)menuAddContactView {
    DDLogVerbose(@"%@ cancelMenuAddContactView: %@", LOG_TAG, menuAddContactView);
    
    [menuAddContactView removeFromSuperview];
}

#pragma mark - Private methods

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    self.view.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
    
    [self setNavigationTitle:TwinmeLocalizedString(@"side_menu_view_controller_title", nil).capitalizedString];
    
    self.navigationItem.titleView.userInteractionEnabled = YES;
    UITapGestureRecognizer *titleLabelGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleHiddenModeTapGesture:)];
    titleLabelGesture.numberOfTapsRequired = NUMBER_TAP_HIDDEN_MODE;
    [self.navigationController.navigationBar addGestureRecognizer:titleLabelGesture];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Design.DISPLAY_WIDTH, CGFLOAT_MIN)];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Design.DISPLAY_WIDTH, CGFLOAT_MIN)];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.sectionHeaderHeight = 0;
    self.tableView.sectionFooterHeight = 0;
    self.tableView.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
    [self.tableView registerNib:[UINib nibWithNibName:@"TwinmeSettingsItemCell" bundle:nil] forCellReuseIdentifier:TWINME_SETTINGS_CELL_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"SettingsSectionHeaderCell" bundle:nil] forCellReuseIdentifier:HEADER_SETTINGS_CELL_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"DefaultProfileCell" bundle:nil] forCellReuseIdentifier:DEFAULT_PROFILE_CELL_IDENTIFIER];
    
    self.profilesTableViewWidthConstraint.constant = DESIGN_PROFILES_MENU_WIDTH * Design.HEIGHT_RATIO;
    self.profilesTableView.delegate = self;
    self.profilesTableView.dataSource = self;
    self.profilesTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.profilesTableView.sectionHeaderHeight = 0;
    self.profilesTableView.sectionFooterHeight = 0;
    self.profilesTableView.showsVerticalScrollIndicator = NO;
    self.profilesTableView.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
    
    self.separatorView.backgroundColor = Design.SEPARATOR_COLOR_GREY;
    self.separatorViewWidthConstraint.constant = Design.SEPARATOR_HEIGHT;
    
    self.hiddenMode = YES;
}

- (void)handleHiddenModeTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleHiddenModeTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        self.hiddenMode = NO;
        [self.tableView reloadData];
    }
}

- (void)showCoachMark {
    DDLogVerbose(@"%@ showCoachMark", LOG_TAG);
    
    if ([self.twinmeApplication showCoachMark:TAG_COACH_MARK_PRIVACY]) {
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(DELAY_COACH_MARK * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            CGRect rectCell = [self.tableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:SETTINGS_VIEW_SECTION]];
            self.coachMarkViewController = (CoachMarkViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"CoachMarkViewController"];
            
            UIWindow *window = UIApplication.sharedApplication.keyWindow;
            CGFloat safeAreaInset = window.safeAreaInsets.top;
            CGRect clipRect = CGRectMake(self.tableView.frame.origin.x + rectCell.origin.x, self.tableView.frame.origin.y + rectCell.origin.y + safeAreaInset, rectCell.size.width, rectCell.size.height);
            CoachMark *coachMark = [[CoachMark alloc]initWithMessage:TwinmeLocalizedString(@"side_menu_view_controller_privacy_coach_mark", nil) tag:TAG_COACH_MARK_PRIVACY alignLeft:YES onTop:NO featureRect:clipRect featureRadius:0];
            [self.coachMarkViewController initWithCoachMark:coachMark];
            self.coachMarkViewController.delegate = self;
            [self.coachMarkViewController showInView:self];
        });
    }
}

- (void)showOnboarding {
    DDLogVerbose(@"%@ showOnboarding", LOG_TAG);
    
    ApplicationDelegate *delegate = (ApplicationDelegate *)[[UIApplication sharedApplication] delegate];
    MainViewController *mainViewController = delegate.mainViewController;
    TwinmeNavigationController *twinmeNavigationController = [mainViewController selectedViewController];
    
    if ([self.twinmeApplication startOnboarding:OnboardingTypeTransferCall]) {
        OnboardingDetailView *onboardingDetailView = [[OnboardingDetailView alloc] init];
        onboardingDetailView.confirmViewDelegate = self;
        [onboardingDetailView initWithPremiumFeature:[[UIPremiumFeature alloc]initWithFeatureType:FeatureTypeTransfertCall]];
        [twinmeNavigationController.tabBarController.view addSubview:onboardingDetailView];
        [onboardingDetailView showConfirmView];
    } else {
        [self showPremiumFeatureView];
    }
}

- (void)showPremiumFeatureView {
    DDLogVerbose(@"%@ showPremiumFeatureView", LOG_TAG);
    
    ApplicationDelegate *delegate = (ApplicationDelegate *)[[UIApplication sharedApplication] delegate];
    MainViewController *mainViewController = delegate.mainViewController;
    TwinmeNavigationController *twinmeNavigationController = [mainViewController selectedViewController];
    
    PremiumFeatureConfirmView *premiumFeatureConfirmView = [[PremiumFeatureConfirmView alloc] init];
    premiumFeatureConfirmView.confirmViewDelegate = self;
    [premiumFeatureConfirmView initWithPremiumFeature:[[UIPremiumFeature alloc]initWithFeatureType:FeatureTypeTransfertCall] parentViewController:twinmeNavigationController.tabBarController];
    [twinmeNavigationController.tabBarController.view addSubview:premiumFeatureConfirmView];
    [premiumFeatureConfirmView showConfirmView];
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    self.view.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
    self.tableView.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
}

@end
