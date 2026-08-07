/*
 *  Copyright (c) 2021-2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <LocalAuthentication/LocalAuthentication.h>

#import "PrivacyViewController.h"
#import "MessageSettingsViewController.h"

#import "MenuSelectValueView.h"
#import "InsideBorderView.h"
#import "MenuSelectValueView.h"
#import "SwitchView.h"
#import "AlertMessageView.h"
#import "UITimeout.h"
#import "SettingsItemCell.h"
#import "SettingsInformationCell.h"
#import "SettingsValueItemCell.h"
#import "SettingsItemCell.h"
#import "SettingsInformationCell.h"

#import <TwinmeCommon/Design.h>
#import <TwinmeCommon/SettingsSectionHeaderCell.h>

#import <Utils/NSString+Utils.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static NSString *HEADER_SETTINGS_CELL_IDENTIFIER = @"HeaderSettingsCellIdentifier";
static NSString *SETTINGS_CELL_IDENTIFIER = @"SettingsCellIdentifier";
static NSString *SETTINGS_INFORMATION_CELL_IDENTIFIER = @"SettingsInformationCellIdentifier";
static NSString *SETTINGS_VALUE_CELL_IDENTIFIER = @"SettingsValueCellIdentifier";

typedef enum {
    SECTION_SECURITY,
    SECTION_BACKGROUND,
    SECTION_CALLS,
    SECTION_SHARE_CONTACT,
    SECTION_COUNT
} PrivacySection;

//
// Interface: PrivacyViewController
//

@interface PrivacyViewController ()<AlertMessageViewDelegate, SettingsActionDelegate, MenuSelectValueDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic) BOOL disableScreenLock;

@end

//
// Implementation: PrivacyViewController
//

#undef LOG_TAG
#define LOG_TAG @"PrivacyViewController"

@implementation PrivacyViewController

- (instancetype)initWithCoder:(NSCoder *)coder {
    DDLogVerbose(@"%@ initWithCoder: %@", LOG_TAG, coder);
    
    self = [super initWithCoder:coder];
    
    if (self) {
        _disableScreenLock = NO;
    }
    return self;
}

- (void)viewDidLoad {
    DDLogVerbose(@"%@ viewDidLoad", LOG_TAG);
    
    [super viewDidLoad];
    
    [self initViews];
}

- (void)viewWillAppear:(BOOL)animated {
    DDLogVerbose(@"%@ viewWillAppear: %@", LOG_TAG, animated ? @"YES" : @"NO");
    
    [super viewWillAppear:animated];
    
    [self updateSettings];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    DDLogVerbose(@"%@ numberOfSectionsInTableView: %@", LOG_TAG, tableView);
    
    return SECTION_COUNT;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath  {
    DDLogVerbose(@"%@ tableView: %@ heightForRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    if ([self isInformationPath:indexPath]) {
        return UITableViewAutomaticDimension;
    }
    
    return Design.SETTING_CELL_HEIGHT;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ heightForHeaderInSection: %ld", LOG_TAG, tableView, (long)section);
    
    return Design.SETTING_SECTION_HEIGHT;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ heightForFooterInSection: %ld", LOG_TAG, tableView, (long)section);
    
    return CGFLOAT_MIN;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ viewForHeaderInSection: %ld", LOG_TAG, tableView, (long)section);
    
    SettingsSectionHeaderCell *settingsSectionHeaderCell = (SettingsSectionHeaderCell *)[tableView dequeueReusableCellWithIdentifier:HEADER_SETTINGS_CELL_IDENTIFIER];
    if (!settingsSectionHeaderCell) {
        settingsSectionHeaderCell = [[SettingsSectionHeaderCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:HEADER_SETTINGS_CELL_IDENTIFIER];
    }
    
    NSString *sectionName = @"";
    BOOL hideSeparator = YES;
    switch (section) {
        case SECTION_SECURITY:
            sectionName = TwinmeLocalizedString(@"settings_advanced_view_security_title", nil);
            break;
            
        case SECTION_BACKGROUND:
            sectionName = TwinmeLocalizedString(@"privacy_view_app_switcher", nil);
            hideSeparator = YES;
            break;
            
        case SECTION_CALLS:
            sectionName = TwinmeLocalizedString(@"calls_view_title", nil);
            break;
            
        case SECTION_SHARE_CONTACT:
            sectionName = TwinmeLocalizedString(@"privacy_view_share_invitation_title", nil);
            break;
                        
        default:
            sectionName = @"";
            break;
    }
    
    [settingsSectionHeaderCell bindWithTitle:sectionName backgroundColor:Design.LIGHT_GREY_BACKGROUND_COLOR hideSeparator:hideSeparator uppercaseString:YES];
    
    return settingsSectionHeaderCell;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ numberOfRowsInSection: %ld", LOG_TAG, tableView, (long)section);
    
    if (section == SECTION_SECURITY && [self.twinmeApplication isScreenLock]) {
        return 3;
    }
    
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ cellForRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    if ([self isInformationPath:indexPath]) {
        SettingsInformationCell *cell = [tableView dequeueReusableCellWithIdentifier:SETTINGS_INFORMATION_CELL_IDENTIFIER];
        if (!cell) {
            cell = [[SettingsInformationCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:SETTINGS_INFORMATION_CELL_IDENTIFIER];
        }
        
        NSString *text = @"";
        
        switch (indexPath.section) {
            case SECTION_SECURITY:
                text = TwinmeLocalizedString(@"privacy_view_lock_screen_message", nil);
                break;
                
            case SECTION_BACKGROUND:
                text = TwinmeLocalizedString(@"privacy_view_hide_last_screen_message", nil);
                break;
                
            case SECTION_CALLS:
                text = TwinmeLocalizedString(@"privacy_view_display_recent_call_message", nil);
                break;
                
            case SECTION_SHARE_CONTACT:
                text = TwinmeLocalizedString(@"privacy_view_share_invitation_info", nil);
                break;
                
            default:
                break;
        }
        
        [cell bindWithText:text];
        
        return cell;
    } else if (indexPath.section == SECTION_SECURITY && indexPath.row == 1) {
        SettingsValueItemCell *cell = [tableView dequeueReusableCellWithIdentifier:SETTINGS_VALUE_CELL_IDENTIFIER];
        if (!cell) {
            cell = [[SettingsValueItemCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:SETTINGS_VALUE_CELL_IDENTIFIER];
        }
        
        int screenLockTimeout = [self.twinmeApplication getTimeoutScreenLock];

        [cell bindWithTitle:TwinmeLocalizedString(@"privacy_view_lock_screen_timeout", nil) value:[NSString formatTimeout:screenLockTimeout] icon:nil backgroundColor:Design.WHITE_COLOR];
        return cell;
    } else if (indexPath.section == SECTION_SHARE_CONTACT) {
        SettingsValueItemCell *cell = [tableView dequeueReusableCellWithIdentifier:SETTINGS_VALUE_CELL_IDENTIFIER];
        if (!cell) {
            cell = [[SettingsValueItemCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:SETTINGS_VALUE_CELL_IDENTIFIER];
        }
        
        NSString *value;
        switch (self.twinmeApplication.shareInvitationMode) {
            case ShareInvitationModeNever:
                value = TwinmeLocalizedString(@"contact_capabilities_view_camera_control_never", nil);
                break;
                
            case ShareInvitationModeAsk:
                value = TwinmeLocalizedString(@"privacy_view_share_invitation_ask", nil);
                break;
                
            case ShareInvitationModeAutomatic:
                value = TwinmeLocalizedString(@"contact_capabilities_view_camera_control_allow", nil);
                break;
                
            default:
                value = @"";
                break;
        }
        
        [cell bindWithTitle:TwinmeLocalizedString(@"privacy_view_share_invitation_setting", nil) value:value icon:nil backgroundColor:Design.WHITE_COLOR];
        return cell;
    } else {
        SettingsItemCell *cell = [tableView dequeueReusableCellWithIdentifier:SETTINGS_CELL_IDENTIFIER];
        if (!cell) {
            cell = [[SettingsItemCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:SETTINGS_CELL_IDENTIFIER];
        }
                
        cell.settingsActionDelegate = self;
        
        BOOL stateSwitch = NO;
        BOOL disableSwitch = NO;
        NSString *title = @"";
        switch (indexPath.section) {
            case SECTION_SECURITY:
                title = TwinmeLocalizedString(@"privacy_view_lock_screen_title", nil);
                stateSwitch = [self.twinmeApplication isScreenLock];
                disableSwitch = self.disableScreenLock;
                break;
                
            case SECTION_BACKGROUND:
                title = TwinmeLocalizedString(@"privacy_view_hide_last_screen_title", nil);
                stateSwitch = [self.twinmeApplication isLastScreenHidden];
                break;
                
            case SECTION_CALLS:
                title = TwinmeLocalizedString(@"privacy_view_display_recent_call", nil);
                stateSwitch = [self.twinmeApplication isRecentCallsHidden];
                break;
                
            default:
                break;
        }
        
        [cell bindWithTitle:title subTitle:nil icon:nil stateSwitch:stateSwitch tagSwitch:(int)indexPath.section hiddenSwitch:NO disableSwitch:disableSwitch backgroundColor:Design.WHITE_COLOR hiddenSeparator:NO];
                
        return cell;
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ didSelectRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    if (indexPath.section == SECTION_SECURITY && indexPath.row == 1) {
        [self selectTimeout];
    } else if (indexPath.section == SECTION_SHARE_CONTACT && indexPath.row ==  0) {
        [self selectShareInvitationMode];
    }
}

#pragma mark - SettingsActionDelegate

- (void)switchChangeValue:(SwitchView *)updatedSwitch {
    DDLogVerbose(@"%@ switchChangeValue: %@", LOG_TAG, updatedSwitch);
    
    if (updatedSwitch.tag == 0) {
        [self.twinmeApplication setScreenLockWithState:updatedSwitch.isOn];
    } else if (updatedSwitch.tag == 1) {
        [self.twinmeApplication setHideLastScreenWithState:updatedSwitch.isOn];
    } else if (updatedSwitch.tag == 2) {
        [self.twinmeApplication setHideRecentCallsWithState:updatedSwitch.isOn];
    }
    
    [self.tableView reloadData];
}

#pragma mark - AlertMessageViewDelegate

- (void)didCloseAlertMessage:(nonnull AlertMessageView *)alertMessageView {
    DDLogVerbose(@"%@ didCloseAlertMessage: %@", LOG_TAG, alertMessageView);
    
    [alertMessageView closeAlertView];
}

- (void)didFinishCloseAlertMessageAnimation:(nonnull AlertMessageView *)alertMessageView {
    DDLogVerbose(@"%@ didFinishCloseAlertMessageAnimation: %@", LOG_TAG, alertMessageView);
    
    [alertMessageView removeFromSuperview];
}

#pragma mark - MenuSelectValueDelegate

- (void)selectValue:(MenuSelectValueView *)menuSelectValueView value:(int)value {
    DDLogVerbose(@"%@ selectValue: %d", LOG_TAG, value);

    [menuSelectValueView removeFromSuperview];

    [self.twinmeApplication setShareInvitationModeWithMode:value];
    [self.tableView reloadData];
}

- (void)selectTimeout:(nonnull MenuSelectValueView *)menuSelectValueView uiTimeout:(nonnull UITimeout *)uiTimeout {
    DDLogVerbose(@"%@ selectTimeout: %@", LOG_TAG, uiTimeout);

    [menuSelectValueView removeFromSuperview];
    
    [self.twinmeApplication setTimeoutScreenLockWithTime:(int)uiTimeout.timeout];
    [self.tableView reloadData];
}

- (void)cancelMenuSelectValue:(MenuSelectValueView *)menuSelectValueView {
    DDLogVerbose(@"%@ cancelMenuSelectValue: %@", LOG_TAG, menuSelectValueView);
    
    [menuSelectValueView removeFromSuperview];
}

#pragma mark - Private methods

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    self.view.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
    
    [self setNavigationTitle:TwinmeLocalizedString(@"privacy_view_title", nil)];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
    self.tableView.estimatedRowHeight = Design.SETTING_CELL_HEIGHT * Design.HEIGHT_RATIO;
    [self.tableView registerNib:[UINib nibWithNibName:@"SettingsItemCell" bundle:nil] forCellReuseIdentifier:SETTINGS_CELL_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"SettingsInformationCell" bundle:nil] forCellReuseIdentifier:SETTINGS_INFORMATION_CELL_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"SettingsValueItemCell" bundle:nil] forCellReuseIdentifier:SETTINGS_VALUE_CELL_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"SettingsSectionHeaderCell" bundle:nil] forCellReuseIdentifier:HEADER_SETTINGS_CELL_IDENTIFIER];
}

- (void)handleLockScreenTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleLockScreenTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        AlertMessageView *alertMessageView = [[AlertMessageView alloc] init];
        alertMessageView.alertMessageViewDelegate = self;
        [alertMessageView initWithTitle:TwinmeLocalizedString(@"deleted_account_view_warning", nil) message:TwinmeLocalizedString(@"lock_screen_view_passcode_not_set", nil)];
        [self.navigationController.view addSubview:alertMessageView];
        [alertMessageView showAlertView];
    }
}

- (void)updateSettings {
    DDLogVerbose(@"%@ updateSettings", LOG_TAG);
    
    LAContext *context = [[LAContext alloc] init];
    
    NSError *error = nil;
    if (![context canEvaluatePolicy:LAPolicyDeviceOwnerAuthentication error:&error]) {
        self.disableScreenLock = YES;
    }
}

- (void)selectTimeout {
    DDLogVerbose(@"%@ selectTimeout", LOG_TAG);
    
    MenuSelectValueView *menuTimeoutView = [[MenuSelectValueView alloc] init];
    [menuTimeoutView setMenuSelectValueTypeWithType:MenuSelectValueTypeTimeoutLockScreen defaultValue:-1];
    menuTimeoutView.menuSelectValueDelegate = self;
    [menuTimeoutView setSelectedValueWithValue:[self.twinmeApplication getTimeoutScreenLock]];
    [self.tabBarController.view addSubview:menuTimeoutView];
    
    [menuTimeoutView openMenu];
}

- (void)selectShareInvitationMode {
    DDLogVerbose(@"%@ selectShareInvitationMode", LOG_TAG);
    
    MenuSelectValueView *menuSelectValueView = [[MenuSelectValueView alloc]init];
    menuSelectValueView.menuSelectValueDelegate = self;
    [self.tabBarController.view addSubview:menuSelectValueView];
    [menuSelectValueView setMenuSelectValueTypeWithType:MenuSelectValueTypeShareInvitation defaultValue:(int)self.twinmeApplication.shareInvitationMode];
    [menuSelectValueView openMenu];
}

- (BOOL)isInformationPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == SECTION_SECURITY) {
        if ([self.twinmeApplication isScreenLock] && indexPath.row == 2) {
            return YES;
        } else if (![self.twinmeApplication isScreenLock] && indexPath.row == 1) {
            return YES;
        }
    } else if(indexPath.row == 1) {
        return YES;
    }
    
    return NO;
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    [self.tableView reloadData];
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    self.view.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
    self.tableView.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
    [self.tableView reloadData];
}

@end
