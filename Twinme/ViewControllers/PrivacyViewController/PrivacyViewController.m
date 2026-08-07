/*
 *  Copyright (c) 2021 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <LocalAuthentication/LocalAuthentication.h>

#import "PrivacyViewController.h"
#import "MessageSettingsViewController.h"

#import <TwinmeCommon/Design.h>
#import "InsideBorderView.h"
#import "MenuSelectValueView.h"
#import "SwitchView.h"
#import "UIPremiumFeature.h"
#import "PremiumFeatureConfirmView.h"
#import <TwinmeCommon/SettingsSectionHeaderCell.h>
#import "SettingsItemCell.h"
#import "SettingsInformationCell.h"
#import "SettingsValueItemCell.h"

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

@interface PrivacyViewController ()<BottomSheetViewDelegate, SettingsActionDelegate, MenuSelectValueDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

//
// Implementation: PrivacyViewController
//

#undef LOG_TAG
#define LOG_TAG @"PrivacyViewController"

@implementation PrivacyViewController

- (void)viewDidLoad {
    DDLogVerbose(@"%@ viewDidLoad", LOG_TAG);
    
    [super viewDidLoad];
    
    [self initViews];
}

#pragma mark - SettingsActionDelegate

- (void)switchChangeValue:(SwitchView *)updatedSwitch {
    DDLogVerbose(@"%@ switchChangeValue: %@", LOG_TAG, updatedSwitch);
    
    PremiumFeatureConfirmView *premiumFeatureConfirmView = [[PremiumFeatureConfirmView alloc] init];
    premiumFeatureConfirmView.bottomSheetViewDelegate = self;
    [premiumFeatureConfirmView initWithPremiumFeature:[[UIPremiumFeature alloc]initWithFeatureType:FeatureTypePrivacy spaceSettings:[self currentSpaceSettings]] parentViewController:self.navigationController];
    [self.navigationController.view addSubview:premiumFeatureConfirmView];
    [premiumFeatureConfirmView showConfirmView];
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
        
        [cell bindWithTitle:TwinmeLocalizedString(@"privacy_view_share_invitation_setting", nil) value:value icon:nil];
        return cell;
    } else {
        SettingsItemCell *cell = [tableView dequeueReusableCellWithIdentifier:SETTINGS_CELL_IDENTIFIER];
        if (!cell) {
            cell = [[SettingsItemCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:SETTINGS_CELL_IDENTIFIER];
        }
                
        cell.settingsActionDelegate = self;
        
        NSString *title = @"";
        
        switch (indexPath.section) {
            case SECTION_SECURITY:
                title = TwinmeLocalizedString(@"privacy_view_lock_screen_title", nil);
                break;
                
            case SECTION_BACKGROUND:
                title = TwinmeLocalizedString(@"privacy_view_hide_last_screen_title", nil);
                break;
                
            case SECTION_CALLS:
                title = TwinmeLocalizedString(@"privacy_view_display_recent_call", nil);
                break;
                
            default:
                break;
        }
        
        [cell bindWithTitle:title subTitle:nil icon:nil stateSwitch:NO tagSwitch:0 hiddenSwitch:NO disableSwitch:YES backgroundColor:Design.WHITE_COLOR hiddenSeparator:NO];
                
        return cell;
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ didSelectRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    if (indexPath.section == SECTION_SHARE_CONTACT && indexPath.row ==  0) {
        [self selectShareInvitationMode];
    }
}

#pragma mark - BottomSheetViewDelegate

- (void)didTapConfirm:(nonnull AbstractBottomSheetView *)abstractBottomSheetView {
    DDLogVerbose(@"%@ didTapConfirm: %@", LOG_TAG, abstractBottomSheetView);
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:TwinmeLocalizedString(@"twinme_plus_link", nil)] options:@{} completionHandler:nil];

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

- (void)selectShareInvitationMode {
    DDLogVerbose(@"%@ selectShareInvitationMode", LOG_TAG);
    
    MenuSelectValueView *menuSelectValueView = [[MenuSelectValueView alloc]init];
    menuSelectValueView.menuSelectValueDelegate = self;
    [self.tabBarController.view addSubview:menuSelectValueView];
    [menuSelectValueView setMenuSelectValueTypeWithType:MenuSelectValueTypeShareInvitation defaultValue:(int)self.twinmeApplication.shareInvitationMode];
    [menuSelectValueView openMenu];
}

- (BOOL)isInformationPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 1) {
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
