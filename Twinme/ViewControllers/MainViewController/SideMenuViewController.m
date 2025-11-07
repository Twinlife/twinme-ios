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
#import <Twinme/TLSpace.h>
#import <Twinme/TLContact.h>
#import <Twinme/TLCallReceiver.h>

#import <Utils/NSString+Utils.h>

#import "SideMenuViewController.h"

#import "ShowSpaceViewController.h"
#import "FeedbackViewController.h"
#import "AccountViewController.h"
#import "WelcomeViewController.h"
#import "MessageSettingsViewController.h"
#import "SoundSettingsViewController.h"
#import "PersonalizationViewController.h"
#import "ShowProfileViewController.h"
#import "EditProfileViewController.h"
#import "AddProfileViewController.h"
#import "EditSpaceViewController.h"
#import "OnboardingSpaceViewController.h"
#import "TemplateSpaceViewController.h"
#import "PrivacyViewController.h"
#import "SettingsAdvancedViewController.h"
#import "CoachMarkViewController.h"
#import "WebViewController.h"
#import "HelpViewController.h"
#import "AboutViewController.h"
#import "AddContactViewController.h"
#import "TwinmeSettingsItemCell.h"
#import "SettingsSectionHeaderCell.h"
#import "DefaultProfileCell.h"
#import "SideSpaceCell.h"
#import "SearchSpaceView.h"

#import "SubscribeCell.h"
#import "InAppSubscriptionViewController.h"

#import "TabBarViewController.h"
#import "UIProfile.h"
#import "UISpace.h"
#import "UIPremiumFeature.h"
#import "CreateExternalCallViewController.h"
#import "TransferCallViewController.h"
#import "PremiumFeatureConfirmView.h"
#import "OnboardingDetailView.h"
#import "MenuAddContactView.h"

#import "LastVersionManager.h"

#import <TwinmeCommon/ApplicationDelegate.h>
#import <TwinmeCommon/CoachMark.h>
#import <TwinmeCommon/Design.h>
#import <TwinmeCommon/MainViewController.h>
#import <TwinmeCommon/TwinmeNavigationController.h>

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

static CGFloat DESIGN_PROFILE_CELL_HEIGHT = 260;
static CGFloat DESIGN_SPACES_MENU_WIDTH = 160;
static CGFloat DESIGN_SPACE_CELL_HEIGHT = 160;
static CGFloat DESIGN_CELL_HEIGHT = 110;

static NSInteger NUMBER_TAP_HIDDEN_MODE = 8;

static NSString *DEFAULT_PROFILE_CELL_IDENTIFIER = @"DefaultProfileCellIdentifier";
static NSString *TWINME_SETTINGS_CELL_IDENTIFIER = @"TwinmeSettingsCellIdentifier";
static NSString *SUBSCRIBE_CELL_IDENTIFIER = @"SubscribeCellIdentifier";
static NSString *HEADER_SETTINGS_CELL_IDENTIFIER = @"HeaderSettingsCellIdentifier";
static NSString *SIDE_SPACE_CELL_IDENTIFIER = @"SideSpaceCellIdentifier";

//
// Interface: SideMenuViewController ()
//

@interface SideMenuViewController ()<UITableViewDelegate, UITableViewDataSource, DefaultProfileDelegate, SideSpaceDelegate, CoachMarkDelegate, MenuAddContactViewDelegate, ConfirmViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerSpacesViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *headerSpacesView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *spacesTableViewWidthConstraint;
@property (weak, nonatomic) IBOutlet UITableView *spacesTableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separatorViewWidthConstraint;
@property (weak, nonatomic) IBOutlet UIView *separatorView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *createSpaceImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *createSpaceImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *createSpaceViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *createSpaceView;

@property (nonatomic) NSMutableArray *uiSpaces;
@property (nonatomic) UISpace *uiSpace;
@property (nonatomic) CoachMarkViewController *coachMarkViewController;
@property SearchSpaceView *searchSpaceView;
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

- (instancetype)initWithCoder:(NSCoder *)coder {
    DDLogVerbose(@"%@ initWithCoder: %@", LOG_TAG, coder);
    
    self = [super initWithCoder:coder];
    
    if (self) {
        _uiSpaces = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    DDLogVerbose(@"%@ viewDidLoad", LOG_TAG);
    
    [super viewDidLoad];
    
    [self initViews];
}

- (void)reloadMenu {
    DDLogVerbose(@"%@ reloadMenu", LOG_TAG);
    
    [self.spacesTableView reloadData];
    [self.tableView reloadData];
    [self updateColor];
}

- (void)setUISpaces:(NSArray *)uiSpaces {
    DDLogVerbose(@"%@ setUISpaces: %@", LOG_TAG, uiSpaces);
    
    [self.uiSpaces removeAllObjects];
    
    for (UISpace *uiSpace in uiSpaces) {
        if (!uiSpace.space.settings.isSecret || uiSpace.isCurrentSpace) {
            [self.uiSpaces addObject:uiSpace];
        }
    }
    
    if (self.uiSpaces.count > 0) {
        self.spacesTableViewWidthConstraint.constant = DESIGN_SPACES_MENU_WIDTH * Design.HEIGHT_RATIO;
    } else {
        self.spacesTableViewWidthConstraint.constant = 0;
    }
    
    [self.spacesTableView reloadData];
    [self resetContentOffset];
}

- (void)setSpace:(UISpace *)space {
    DDLogVerbose(@"%@ setSpace: %@", LOG_TAG, space);
    
    self.uiSpace = space;
}

- (void)resetContentOffset {
    DDLogVerbose(@"%@ resetContentOffset", LOG_TAG);
    
    CGFloat footerHeight = Design.DISPLAY_HEIGHT - (self.uiSpaces.count * (DESIGN_SPACE_CELL_HEIGHT * Design.HEIGHT_RATIO));
    if (footerHeight < 0) {
        footerHeight = CGFLOAT_MIN;
    }
    self.spacesTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Design.WIDTH_RATIO * DESIGN_SPACES_MENU_WIDTH, footerHeight)];
    
    CGFloat statusBarHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
    CGFloat offset = (DESIGN_SPACE_CELL_HEIGHT * Design.HEIGHT_RATIO) - statusBarHeight;
    [self.spacesTableView setContentOffset:CGPointMake(0, offset) animated:YES];
    
    if (self.coachMarkViewController) {
        [self.coachMarkViewController closeView];
        self.coachMarkViewController = nil;
    }
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
    
    return round(DESIGN_SPACE_CELL_HEIGHT * Design.HEIGHT_RATIO);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ heightForHeaderInSection: %ld", LOG_TAG, tableView, (long)section);
    
    if (tableView == self.spacesTableView || section == HEADER_VIEW_SECTION) {
        return CGFLOAT_MIN;
    }
    
    return Design.SETTING_SECTION_HEIGHT;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ heightForFooterInSection: %ld", LOG_TAG, tableView, (long)section);
    
    return CGFLOAT_MIN;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ viewForHeaderInSection: %ld", LOG_TAG, tableView, (long)section);
    
    if (tableView == self.spacesTableView || section == HEADER_VIEW_SECTION) {
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
    
    if (tableView == self.spacesTableView) {
        return self.uiSpaces.count;
    }
    
    NSInteger numberOfRowsInSection;
    switch (section) {
        case HEADER_VIEW_SECTION:
        case LOGOUT_VIEW_SECTION:
            numberOfRowsInSection = 1;
            break;
            
        case SETTINGS_VIEW_SECTION:
            numberOfRowsInSection = 6;
            break;
            
        case SUPPORT_VIEW_SECTION:
            numberOfRowsInSection = 4;
            break;
            
        default:
            numberOfRowsInSection = 0;
            break;
    }
    return numberOfRowsInSection;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ cellForRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    if (tableView == self.tableView) {
        if (indexPath.section == HEADER_VIEW_SECTION && indexPath.row == 0) {
            DefaultProfileCell *cell = (DefaultProfileCell *)[tableView dequeueReusableCellWithIdentifier:DEFAULT_PROFILE_CELL_IDENTIFIER];
            if (!cell) {
                cell = [[DefaultProfileCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:DEFAULT_PROFILE_CELL_IDENTIFIER];
            }
            
            cell.delegate = self;
            if (self.uiSpace.space.profile) {
                [cell bindWithName:self.uiSpace.space.profile.name avatar:self.uiSpace.avatar];
            } else {
                [cell bindWithName:TwinmeLocalizedString(@"profiles_view_controller_add_profile", nil) avatar:[TLContact ANONYMOUS_AVATAR]];
            }
            
            return cell;
        } else if (indexPath.section == SUPPORT_VIEW_SECTION && indexPath.row == 0) {
            SubscribeCell *cell = [tableView dequeueReusableCellWithIdentifier:SUBSCRIBE_CELL_IDENTIFIER];
            if (!cell) {
                cell = [[SubscribeCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:SUBSCRIBE_CELL_IDENTIFIER];
            }
            
            ApplicationDelegate *delegate = (ApplicationDelegate *)[[UIApplication sharedApplication] delegate];
            [cell bind:[delegate.twinmeApplication isSubscribedWithFeature:TLTwinmeApplicationFeatureGroupCall]];
            
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
                    if (indexPath.row == 1) {
                        hiddenAccessory = NO;
                        title = TwinmeLocalizedString(@"side_menu_view_controller_help", nil);
                    } else if (indexPath.row == 2) {
                        hiddenAccessory = NO;
                        title = TwinmeLocalizedString(@"side_menu_view_controller_about", nil);
                    } else if (indexPath.row == 3) {
                        hiddenAccessory = NO;
                        title = TwinmeLocalizedString(@"account_view_controller_title", nil);
                    }
                    break;
                    
                case LOGOUT_VIEW_SECTION:
                    hiddenAccessory = YES;
                    title = TwinmeLocalizedString(@"side_menu_view_controller_sign_out", nil);
                    break;
                    
                default:
                    break;
            }
            
            if (indexPath.section == SUPPORT_VIEW_SECTION && indexPath.row == 2) {
                [cell bindWithTitle:title hiddenAccessory:hiddenAccessory disableSetting:NO updateAvailable:[self.twinmeApplication.lastVersionManager isNewVersionAvailable] color:Design.FONT_COLOR_DEFAULT];
            } else {
                [cell bindWithTitle:title hiddenAccessory:hiddenAccessory disableSetting:NO color:Design.FONT_COLOR_DEFAULT];
            }
            
            return cell;
        }
    } else {
        SideSpaceCell *cell = (SideSpaceCell *)[tableView dequeueReusableCellWithIdentifier:SIDE_SPACE_CELL_IDENTIFIER];
        if (!cell) {
            cell = [[SideSpaceCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:SIDE_SPACE_CELL_IDENTIFIER];
        }
        
        cell.sideSpaceDelegate = self;
        UISpace *uiSpace = [self.uiSpaces objectAtIndex:indexPath.row];
        [cell bindWithSpace:uiSpace isCurrentSpace:uiSpace.isCurrentSpace isSecretSpace:NO];
        
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
                InAppSubscriptionViewController *inAppSubscriptionViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"InAppSubscriptionViewController"];
                TwinmeNavigationController *inAppNavigationController = [[TwinmeNavigationController alloc]initWithRootViewController:inAppSubscriptionViewController];
                [twinmeNavigationController presentViewController:inAppNavigationController animated:YES completion:nil];
            } else if (indexPath.row == 1) {
                HelpViewController *helpViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"HelpViewController"];
                [twinmeNavigationController pushViewController:helpViewController animated:YES];
            } else if (indexPath.row == 2) {
                AboutViewController *aboutViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AboutViewController"];
                [twinmeNavigationController pushViewController:aboutViewController animated:YES];
            }  else if (indexPath.row == 3) {
                AccountViewController *accountViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AccountViewController"];
                [twinmeNavigationController pushViewController:accountViewController animated:YES];
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
        ApplicationDelegate *delegate = (ApplicationDelegate *)[[UIApplication sharedApplication] delegate];
        MainViewController *mainViewController = delegate.mainViewController;
        TwinmeNavigationController *twinmeNavigationController = [mainViewController selectedViewController];
        
        InAppSubscriptionViewController *inAppSubscriptionViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"InAppSubscriptionViewController"];
        TwinmeNavigationController *inAppNavigationController = [[TwinmeNavigationController alloc]initWithRootViewController:inAppSubscriptionViewController];
        [twinmeNavigationController presentViewController:inAppNavigationController animated:YES completion:nil];
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
    
    if (!self.currentSpace.profile) {
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
    
    if (self.currentSpace.profile) {
        ShowProfileViewController *showProfileViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ShowProfileViewController"];
        [showProfileViewController initWithProfile:self.currentSpace.profile];
        [twinmeNavigationController pushViewController:showProfileViewController animated:YES];
    } else {
        AddProfileViewController *addProfileViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AddProfileViewController"];
        addProfileViewController.firstProfile = YES;
        [twinmeNavigationController pushViewController:addProfileViewController animated:YES];
    }
}
    
#pragma mark - SideSpaceDelegate

- (void)showSpace:(UISpace *)uiSpace {
    DDLogVerbose(@"%@ showSpace: %@", LOG_TAG, uiSpace);
    
    [self openSideMenu:NO];
    
    ApplicationDelegate *delegate = (ApplicationDelegate *)[[UIApplication sharedApplication] delegate];
    MainViewController *mainViewController = delegate.mainViewController;
    TwinmeNavigationController *twinmeNavigationController = [mainViewController selectedViewController];
    
    ShowSpaceViewController *showSpaceViewController = [[UIStoryboard storyboardWithName:@"Space" bundle:nil] instantiateViewControllerWithIdentifier:@"ShowSpaceViewController"];
    [showSpaceViewController initWithSpace:uiSpace.space];
    [twinmeNavigationController pushViewController:showSpaceViewController animated:YES];
}

- (void)setCurrentSpace:(UISpace *)uiSpace {
    DDLogVerbose(@"%@ editSpace: %@", LOG_TAG, uiSpace);
    
    [self openSideMenu:NO];
    
    ApplicationDelegate *delegate = (ApplicationDelegate *)[[UIApplication sharedApplication] delegate];
    MainViewController *mainViewController = delegate.mainViewController;
    [mainViewController setCurrentSpace:uiSpace.space];
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
    [addContactViewController initWithProfile:self.currentSpace.profile invitationMode:InvitationModeScan];
    [twinmeNavigationController pushViewController:addContactViewController animated:YES];
}

- (void)menuAddContactDidSelectInvite:(MenuAddContactView *)menuAddContactView {
    DDLogVerbose(@"%@ menuAddContactDidSelectInvite: %@", LOG_TAG, menuAddContactView);
    
    [menuAddContactView removeFromSuperview];
    
    ApplicationDelegate *delegate = (ApplicationDelegate *)[[UIApplication sharedApplication] delegate];
    MainViewController *mainViewController = delegate.mainViewController;
    TwinmeNavigationController *twinmeNavigationController = [mainViewController selectedViewController];
    
    AddContactViewController *addContactViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AddContactViewController"];
    [addContactViewController initWithProfile:self.currentSpace.profile invitationMode:InvitationModeInvite];
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
    [self.tableView registerNib:[UINib nibWithNibName:@"SubscribeCell" bundle:nil] forCellReuseIdentifier:SUBSCRIBE_CELL_IDENTIFIER];
    
    self.searchSpaceView = [[SearchSpaceView alloc]init];
    UITapGestureRecognizer *tapSearchGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSearchTapGesture:)];
    [self.searchSpaceView addGestureRecognizer:tapSearchGesture];
    
    self.spacesTableViewWidthConstraint.constant = DESIGN_SPACES_MENU_WIDTH * Design.HEIGHT_RATIO;
    self.spacesTableView.tableHeaderView = self.searchSpaceView;
    self.spacesTableView.delegate = self;
    self.spacesTableView.dataSource = self;
    self.spacesTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.spacesTableView.sectionHeaderHeight = 0;
    self.spacesTableView.sectionFooterHeight = 0;
    self.spacesTableView.showsVerticalScrollIndicator = NO;
    self.spacesTableView.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
    [self.spacesTableView registerNib:[UINib nibWithNibName:@"SideSpaceCell" bundle:nil] forCellReuseIdentifier:SIDE_SPACE_CELL_IDENTIFIER];
    
    self.separatorView.backgroundColor = Design.SEPARATOR_COLOR_GREY;
    self.separatorViewWidthConstraint.constant = Design.SEPARATOR_HEIGHT;
    self.hiddenMode = YES;
    
    self.headerSpacesViewHeightConstraint.constant = [[UIApplication sharedApplication] statusBarFrame].size.height;
    self.headerSpacesView.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
    
    self.createSpaceImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.createSpaceImageView.tintColor = Design.BLACK_COLOR;
    
    self.createSpaceViewHeightConstraint.constant *= Design.HEIGHT_RATIO;

    self.createSpaceView.userInteractionEnabled = YES;
    self.createSpaceView.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
    
    UITapGestureRecognizer *tapCreateSpaceGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleCreateSpaceTapGesture:)];
    [self.createSpaceView addGestureRecognizer:tapCreateSpaceGesture];
    
    self.hiddenMode = YES;
}

- (void)handleHiddenModeTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleHiddenModeTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        self.hiddenMode = NO;
        [self.tableView reloadData];
    }
}

- (void)handleSearchTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleHiddenModeTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        [self openSideMenu:NO];
        ApplicationDelegate *delegate = (ApplicationDelegate *)[[UIApplication sharedApplication] delegate];
        MainViewController *mainViewController = delegate.mainViewController;
        [mainViewController searchSecretSpace];
    }
}

- (void)handleCreateSpaceTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleCreateSpaceTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        [self openSideMenu:NO];
        
        ApplicationDelegate *delegate = (ApplicationDelegate *)[[UIApplication sharedApplication] delegate];
       
        if ([self.twinmeApplication startOnboarding:OnboardingTypeSpace]) {
            MainViewController *mainViewController = delegate.mainViewController;
            OnboardingSpaceViewController *onboardingSpaceViewController = [[UIStoryboard storyboardWithName:@"Space" bundle:nil] instantiateViewControllerWithIdentifier:@"OnboardingSpaceViewController"];
            [onboardingSpaceViewController showInView:mainViewController hideFirstPart:NO];
        } else {
            MainViewController *mainViewController = delegate.mainViewController;
            TwinmeNavigationController *selectedNavigationController = mainViewController.selectedViewController;
            TemplateSpaceViewController *templateSpaceViewController = [[UIStoryboard storyboardWithName:@"Space" bundle:nil] instantiateViewControllerWithIdentifier:@"TemplateSpaceViewController"];
            [selectedNavigationController pushViewController:templateSpaceViewController animated:YES];
        }
    }
}
    
- (void)showCoachMark {
    DDLogVerbose(@"%@ showCoachMark", LOG_TAG);
    
    if ([self.twinmeApplication showCoachMark:TAG_COACH_MARK_PRIVACY]) {
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(DELAY_COACH_MARK * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            CGRect rectCell = [self.tableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:SETTINGS_VIEW_SECTION]];
            self.coachMarkViewController = (CoachMarkViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"CoachMarkViewController"];
            CGRect clipRect = CGRectMake(self.tableView.frame.origin.x + rectCell.origin.x, self.tableView.frame.origin.y + rectCell.origin.y, rectCell.size.width, rectCell.size.height);
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
    
    if ([self.twinmeApplication startOnboarding:OnboardingTypeTransferCall] && !self.callReceiver) {
        OnboardingDetailView *onboardingDetailView = [[OnboardingDetailView alloc] init];
        onboardingDetailView.confirmViewDelegate = self;
        [onboardingDetailView initWithPremiumFeature:[[UIPremiumFeature alloc]initWithFeatureType:FeatureTypeTransfertCall spaceSettings:self.currentSpaceSettings]];
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
    
    if (![delegate.twinmeApplication isSubscribedWithFeature:TLTwinmeApplicationFeatureGroupCall]) {
        PremiumFeatureConfirmView *premiumFeatureConfirmView = [[PremiumFeatureConfirmView alloc] init];
        premiumFeatureConfirmView.confirmViewDelegate = self;
        [premiumFeatureConfirmView initWithPremiumFeature:[[UIPremiumFeature alloc]initWithFeatureType:FeatureTypeTransfertCall spaceSettings:self.currentSpaceSettings] parentViewController:twinmeNavigationController.tabBarController];
        [twinmeNavigationController.tabBarController.view addSubview:premiumFeatureConfirmView];
        [premiumFeatureConfirmView showConfirmView];
   } else if (!self.callReceiver) {
       CreateExternalCallViewController *createExternalCallViewController = [[UIStoryboard storyboardWithName:@"ExternalCall" bundle:nil] instantiateViewControllerWithIdentifier:@"CreateExternalCallViewController"];
       createExternalCallViewController.isTransfert = YES;
       [twinmeNavigationController pushViewController:createExternalCallViewController animated:YES];
   } else {
       TransferCallViewController *transferCallViewController = [[UIStoryboard storyboardWithName:@"ExternalCall" bundle:nil] instantiateViewControllerWithIdentifier:@"TransferCallViewController"];
       [transferCallViewController initWithCallReceiver:self.callReceiver];
       [twinmeNavigationController pushViewController:transferCallViewController animated:YES];
   }
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    self.view.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
    self.tableView.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
    self.spacesTableView.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
    self.headerSpacesView.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
    self.separatorView.backgroundColor = Design.SEPARATOR_COLOR_GREY;
    self.createSpaceImageView.tintColor = Design.BLACK_COLOR;
    self.createSpaceView.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
    [self.searchSpaceView updateColor];
}

- (void)refreshTable {
    DDLogVerbose(@"%@ refreshTable", LOG_TAG);

    // Schedule only one table reload for possibly several asynchronous fetch of images.
    if (!self.refreshTableScheduled) {
        self.refreshTableScheduled = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            self.refreshTableScheduled = NO;
            [self.tableView reloadData];
        });
    }
}

@end
