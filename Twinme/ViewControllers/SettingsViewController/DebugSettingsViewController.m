/*
 *  Copyright (c) 2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <Twinme/TLTwinmeContext.h>
#import <TwinmeCommon/Design.h>

#import <Utils/NSString+Utils.h>

#import "DebugSettingsViewController.h"
#import "MessageSettingsViewController.h"

#import "SettingsItemCell.h"
#import "SettingsSectionHeaderCell.h"
#import "ResetSettingsCell.h"

#import "SwitchView.h"
#import "AlertMessageView.h"

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static CGFloat DESIGN_RESET_HEIGHT = 160;

static NSString *SETTINGS_CELL_IDENTIFIER = @"SettingsCellIdentifier";
static NSString *HEADER_SETTINGS_CELL_IDENTIFIER = @"HeaderSettingsCellIdentifier";
static NSString *RESET_SETTINGS_CELL_IDENTIFIER = @"ResetSettingsCellIdentifier";

//
// Interface: DebugSettingsViewController ()
//

@interface DebugSettingsViewController ()<SettingsActionDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

//
// Implementation: DebugSettingsViewController
//

#undef LOG_TAG
#define LOG_TAG @"DebugSettingsViewController"

@implementation DebugSettingsViewController

- (void)viewDidLoad {
    DDLogVerbose(@"%@ viewDidLoad", LOG_TAG);
    
    [super viewDidLoad];
    
    [self initViews];
}

#pragma mark - SettingsActionDelegate

- (void)switchChangeValue:(SwitchView *)updatedSwitch {
    DDLogVerbose(@"%@ switchChangeValue: %@", LOG_TAG, updatedSwitch);
    
    [self.twinmeApplication setShowOnboardingType:(int)updatedSwitch.tag state:updatedSwitch.isOn];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    DDLogVerbose(@"%@ numberOfSectionsInTableView: %@", LOG_TAG, tableView);
    
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath  {
    DDLogVerbose(@"%@ tableView: %@ heightForRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);

    return Design.SETTING_CELL_HEIGHT;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ heightForHeaderInSection: %ld", LOG_TAG, tableView, (long)section);
    
    return Design.SETTING_SECTION_HEIGHT;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ heightForFooterInSection: %ld", LOG_TAG, tableView, (long)section);
    
    return DESIGN_RESET_HEIGHT * Design.HEIGHT_RATIO;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ viewForHeaderInSection: %ld", LOG_TAG, tableView, (long)section);
    
    SettingsSectionHeaderCell *settingsSectionHeaderCell = (SettingsSectionHeaderCell *)[tableView dequeueReusableCellWithIdentifier:HEADER_SETTINGS_CELL_IDENTIFIER];
    if (!settingsSectionHeaderCell) {
        settingsSectionHeaderCell = [[SettingsSectionHeaderCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:HEADER_SETTINGS_CELL_IDENTIFIER];
    }
    
    [settingsSectionHeaderCell bindWithTitle:TwinmeLocalizedString(@"application_do_not_display", nil) backgroundColor:Design.LIGHT_GREY_BACKGROUND_COLOR hideSeparator:NO uppercaseString:YES];
    
    return settingsSectionHeaderCell;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ viewForFooterInSection: %ld", LOG_TAG, tableView, (long)section);
    
    ResetSettingsCell *resetSettingsCell = (ResetSettingsCell *)[tableView dequeueReusableCellWithIdentifier:RESET_SETTINGS_CELL_IDENTIFIER];
    if (!resetSettingsCell) {
        resetSettingsCell = [[ResetSettingsCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:RESET_SETTINGS_CELL_IDENTIFIER];
    }
    
    UITapGestureRecognizer *resetViewGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleResetTapGesture:)];
    [resetSettingsCell.contentView addGestureRecognizer:resetViewGestureRecognizer];
    
    return resetSettingsCell;
    
    return [[UIView alloc]init];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ numberOfRowsInSection: %ld", LOG_TAG, tableView, (long)section);
            
    return OnboardingTypeCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ cellForRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    SettingsItemCell *cell = [tableView dequeueReusableCellWithIdentifier:SETTINGS_CELL_IDENTIFIER];
    if (!cell) {
        cell = [[SettingsItemCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:SETTINGS_CELL_IDENTIFIER];
    }
    
    cell.settingsActionDelegate = self;
                
    int onboardingType = (int)indexPath.row;
    [cell bindWithTitle:[self getOnboardingTitle:onboardingType] icon:nil stateSwitch:[self.twinmeApplication startOnboarding:onboardingType] tagSwitch:onboardingType hiddenSwitch:NO disableSwitch:NO backgroundColor:Design.WHITE_COLOR hiddenSeparator:NO];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ didSelectRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
}

#pragma mark - Private methods

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    self.view.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
    
    [self setNavigationTitle:TwinmeLocalizedString(@"settings_advanced_view_controller_developers_settings", nil)];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = Design.SETTING_CELL_HEIGHT * Design.HEIGHT_RATIO;
    [self.tableView registerNib:[UINib nibWithNibName:@"SettingsItemCell" bundle:nil] forCellReuseIdentifier:SETTINGS_CELL_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"SettingsSectionHeaderCell" bundle:nil] forCellReuseIdentifier:HEADER_SETTINGS_CELL_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"ResetSettingsCell" bundle:nil] forCellReuseIdentifier:RESET_SETTINGS_CELL_IDENTIFIER];
    
    self.tableView.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
}

- (void)handleResetTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleResetTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        [self hapticFeedBack:UIImpactFeedbackStyleMedium];
        
        [self.twinmeApplication resetOnboarding];
        [self.tableView reloadData];
    }
}

- (NSString *)getOnboardingTitle:(int)onboardingType {
    
    switch (onboardingType) {
        case OnboardingTypeCertifiedRelation:
            return TwinmeLocalizedString(@"authentified_relation_view_controller_title", nil);
            
        case OnboardingTypeExternalCall:
            return TwinmeLocalizedString(@"premium_services_view_controller_click_to_call_title", nil);
            
        case OnboardingTypeProfile:
            return TwinmeLocalizedString(@"application_profile", nil);
            
        case OnboardingTypeSpace:
            return TwinmeLocalizedString(@"premium_services_view_controller_space_title", nil);
            
        case OnboardingTypeTransfer:
            return TwinmeLocalizedString(@"account_view_controller_transfer_between_devices", nil);
            
        case OnboardingTypeEnterMiniCode:
            return TwinmeLocalizedString(@"enter_invitation_code_view_controller_enter_code", nil);
            
        case OnboardingTypeMiniCode:
            return TwinmeLocalizedString(@"invitation_code_view_controller_create_code", nil);
            
        case OnboardingTypeRemoteCamera:
            return TwinmeLocalizedString(@"call_view_controller_camera_control", nil);
            
        case OnboardingTypeRemoteCameraSettings:
            return [NSString stringWithFormat:@"%@ - %@", TwinmeLocalizedString(@"call_view_controller_camera_control", nil), TwinmeLocalizedString(@"settings_view_controller_title", nil)];
            
        case OnboardingTypeTransferCall:
            return TwinmeLocalizedString(@"premium_services_view_controller_transfert_title", nil);
            
        case OnboardingTypeProxy:
            return TwinmeLocalizedString(@"proxy_view_controller_title", nil);
            
        default:
            return @"";
    }
}
    
- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    self.tableView.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    [self.tableView reloadData];
}

@end
