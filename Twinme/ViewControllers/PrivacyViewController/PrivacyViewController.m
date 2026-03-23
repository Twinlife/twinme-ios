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
#import "SwitchView.h"
#import "AlertMessageView.h"
#import "UITimeout.h"
#import "SettingsItemCell.h"
#import "SettingsInformationCell.h"
#import "SettingsValueItemCell.h"

#import <TwinmeCommon/Design.h>

#import <Utils/NSString+Utils.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static NSString *SETTINGS_CELL_IDENTIFIER = @"SettingsCellIdentifier";
static NSString *SETTINGS_INFORMATION_CELL_IDENTIFIER = @"SettingsInformationCellIdentifier";
static NSString *SETTINGS_VALUE_CELL_IDENTIFIER = @"SettingsValueCellIdentifier";

//
// Interface: PrivacyViewController
//

@interface PrivacyViewController ()<SettingsActionDelegate, AlertMessageViewDelegate, MenuSelectValueDelegate>

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
    
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath  {
    DDLogVerbose(@"%@ tableView: %@ heightForRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    if (indexPath.row % 2 != 0) {
        return UITableViewAutomaticDimension;
    }
    
    return Design.SETTING_CELL_HEIGHT;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ heightForHeaderInSection: %ld", LOG_TAG, tableView, (long)section);
    
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ heightForFooterInSection: %ld", LOG_TAG, tableView, (long)section);
    
    return Design.SETTING_CELL_HEIGHT;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ numberOfRowsInSection: %ld", LOG_TAG, tableView, (long)section);
    
    if (section == 0 && [self.twinmeApplication isScreenLock]) {
        return 3;
    }
    
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ cellForRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    if (indexPath.row % 2 != 0) {
        SettingsInformationCell *cell = [tableView dequeueReusableCellWithIdentifier:SETTINGS_INFORMATION_CELL_IDENTIFIER];
        if (!cell) {
            cell = [[SettingsInformationCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:SETTINGS_INFORMATION_CELL_IDENTIFIER];
        }
        
        NSString *text = @"";
        if (indexPath.section == 0) {
            text = TwinmeLocalizedString(@"privacy_view_controller_lock_screen_message", nil);
        } else if (indexPath.section == 1) {
            text = TwinmeLocalizedString(@"privacy_view_controller_hide_last_screen_message", nil);
        } else {
            text = TwinmeLocalizedString(@"privacy_view_controller_display_recent_call_message", nil);
        }
        
        [cell bindWithText:text];
        
        return cell;
    } else if (indexPath.section == 0 && indexPath.row == 2) {
        SettingsValueItemCell *cell = [tableView dequeueReusableCellWithIdentifier:SETTINGS_VALUE_CELL_IDENTIFIER];
        if (!cell) {
            cell = [[SettingsValueItemCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:SETTINGS_VALUE_CELL_IDENTIFIER];
        }
        
        int screenLockTimeout = [self.twinmeApplication getTimeoutScreenLock];

        [cell bindWithTitle:TwinmeLocalizedString(@"privacy_view_controller_lock_screen_timeout", nil) value:[NSString formatTimeout:screenLockTimeout] backgroundColor:Design.WHITE_COLOR];

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
        if (indexPath.section == 0) {
            title = TwinmeLocalizedString(@"privacy_view_controller_lock_screen_title", nil);
            stateSwitch = [self.twinmeApplication isScreenLock];
            disableSwitch = self.disableScreenLock;
        } else if (indexPath.section == 1) {
            title = TwinmeLocalizedString(@"privacy_view_controller_hide_last_screen_title", nil);
            stateSwitch = [self.twinmeApplication isLastScreenHidden];
        } else {
            title = TwinmeLocalizedString(@"privacy_view_controller_display_recent_call", nil);
            stateSwitch = [self.twinmeApplication isRecentCallsHidden];
        }
        
        [cell bindWithTitle:title subTitle:nil icon:nil stateSwitch:stateSwitch tagSwitch:(int)indexPath.section hiddenSwitch:NO disableSwitch:disableSwitch backgroundColor:Design.WHITE_COLOR hiddenSeparator:NO];
                
        return cell;
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ didSelectRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    if (indexPath.section == 0 && indexPath.row == 2) {
        [self openMenu];
    }
}

#pragma mark - MenuSelectValueDelegate

- (void)cancelMenuSelectValue:(MenuSelectValueView *)menuSelectValueView {
    DDLogVerbose(@"%@ cancelMenu", LOG_TAG);
    
    [menuSelectValueView removeFromSuperview];
}

- (void)selectTimeout:(MenuSelectValueView *)menuSelectValueView uiTimeout:(UITimeout *)uiTimeout {
    DDLogVerbose(@"%@ selectTimeout: %@", LOG_TAG, uiTimeout);
    
    [menuSelectValueView removeFromSuperview];

    [self.twinmeApplication setTimeoutScreenLockWithTime:(int)uiTimeout.timeout];
    [self.tableView reloadData];
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

#pragma mark - Private methods

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    self.view.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
    
    [self setNavigationTitle:TwinmeLocalizedString(@"privacy_view_controller_title", nil)];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
    self.tableView.estimatedRowHeight = Design.SETTING_CELL_HEIGHT * Design.HEIGHT_RATIO;
    [self.tableView registerNib:[UINib nibWithNibName:@"SettingsItemCell" bundle:nil] forCellReuseIdentifier:SETTINGS_CELL_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"SettingsInformationCell" bundle:nil] forCellReuseIdentifier:SETTINGS_INFORMATION_CELL_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"SettingsValueItemCell" bundle:nil] forCellReuseIdentifier:SETTINGS_VALUE_CELL_IDENTIFIER];

}

- (void)handleTimeoutTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleTimeoutTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        [self openMenu];
    }
}

- (void)handleLockScreenTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleLockScreenTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        AlertMessageView *alertMessageView = [[AlertMessageView alloc] init];
        alertMessageView.alertMessageViewDelegate = self;
        [alertMessageView initWithTitle:TwinmeLocalizedString(@"delete_account_view_controller_warning", nil) message:TwinmeLocalizedString(@"lock_screen_view_controller_passcode_not_set", nil)];
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

- (void)openMenu {
    DDLogVerbose(@"%@ openMenu", LOG_TAG);
    
    MenuSelectValueView *menuTimeoutView = [[MenuSelectValueView alloc] init];
    [menuTimeoutView setMenuSelectValueTypeWithType:MenuSelectValueTypeTimeoutLockScreen defaultValue:-1];
    menuTimeoutView.menuSelectValueDelegate = self;
    [menuTimeoutView setSelectedValueWithValue:[self.twinmeApplication getTimeoutScreenLock]];
    [self.tabBarController.view addSubview:menuTimeoutView];
    
    [menuTimeoutView openMenu];
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
