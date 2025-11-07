/*
 *  Copyright (c) 2024 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "AbstractCapabilitiesViewController.h"

#import <CocoaLumberjack.h>

#import <Twinme/TLContact.h>
#import <Twinme/TLSchedule.h>

#import <Utils/NSString+Utils.h>

#import "MessageSettingsViewController.h"
#import "ContactCapabilitiesViewController.h"
#import "SettingsItemCell.h"
#import "SettingsSectionHeaderCell.h"
#import "SettingsInformationCell.h"
#import "SettingsValueItemCell.h"
#import "PremiumFeatureConfirmView.h"
#import "OnboardingConfirmView.h"

#import <TwinmeCommon/Design.h>
#import <TwinmeCommon/EditContactCapabilitiesService.h>

#import "SwitchView.h"
#import "UIPremiumFeature.h"

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static NSString *SETTINGS_CELL_IDENTIFIER = @"SettingsCellIdentifier";
static NSString *HEADER_SETTINGS_CELL_IDENTIFIER = @"HeaderSettingsCellIdentifier";
static NSString *SETTINGS_INFORMATION_CELL_IDENTIFIER = @"SettingsInformationCellIdentifier";
static NSString *SETTINGS_VALUE_CELL_IDENTIFIER = @"SettingsValueCellIdentifier";

//
// Interface: AbstractCapabilitiesViewController ()
//

@interface AbstractCapabilitiesViewController () <SettingsActionDelegate, EditContactCapabilitiesServiceDelegate, ConfirmViewDelegate, SettingsSectionHeaderDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

typedef enum {
    SECTION_CALL_PERMISSIONS,
    SECTION_CONTROL_CAMERA,
    SECTION_DISCREET_RELATION,
    SECTION_PROGRAMMED_CALL,
    SECTION_COUNT
} TLCapabilitiesSection;

typedef enum {
    TAG_ALLOW_AUDIO_CALL,
    TAG_ALLOW_VIDEO_CALL,
    TAG_DISCREET_RELATION,
    TAG_ENABLE_SCHEDULE
} TLCapabitiesTag;

//
// Implementation: AbstractCapabilitiesViewController
//

#undef LOG_TAG
#define LOG_TAG @"AbstractCapabilitiesViewController"

@implementation AbstractCapabilitiesViewController

- (instancetype)initWithCoder:(NSCoder *)coder {
    DDLogVerbose(@"%@ initWithCoder: %@", LOG_TAG, coder);
    
    self = [super initWithCoder:coder];
    
    if (self) {
        _allowAudioCall = YES;
        _allowVideoCall = YES;
        _zoomable = TLVideoZoomableAsk;
        _discreetRelation = NO;
        _scheduleEnable = NO;
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
    
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    [self.tableView reloadData];
}

- (BOOL)isGroupCapabilities {
    DDLogVerbose(@"%@ isGroupCapabilities", LOG_TAG);
    
    return NO;
}

#pragma mark - SettingsActionDelegate

- (void)switchChangeValue:(SwitchView *)updatedSwitch {
    DDLogVerbose(@"%@ switchChangeValue: %@", LOG_TAG, updatedSwitch);
    
    [self showPremiumFeature:FeatureTypePrivacy];
}

#pragma mark - EditContactCapabilitiesServiceDelegate

- (void)onUpdateContact:(nonnull TLContact *)contact avatar:(nullable UIImage *)avatar {
    DDLogVerbose(@"%@ onUpdateContact: %@", LOG_TAG, contact);
    
    [self finish];
}

- (void)onDeleteContact:(nonnull NSUUID *)contactId {
    DDLogVerbose(@"%@ onDeleteContact: %@", LOG_TAG, contactId);

    [self finish];
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
    
    if ((section == SECTION_DISCREET_RELATION || section == SECTION_CONTROL_CAMERA) && [self isGroupCapabilities]) {
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
    
    if ((section == SECTION_DISCREET_RELATION || section == SECTION_CONTROL_CAMERA) && [self isGroupCapabilities]) {
        return 0;
    } else if (section == SECTION_CONTROL_CAMERA) {
        return 2;
    }
    return 2;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ viewForHeaderInSection: %ld", LOG_TAG, tableView, (long)section);
    
    SettingsSectionHeaderCell *settingsSectionHeaderCell = (SettingsSectionHeaderCell *)[tableView dequeueReusableCellWithIdentifier:HEADER_SETTINGS_CELL_IDENTIFIER];
    if (!settingsSectionHeaderCell) {
        settingsSectionHeaderCell = [[SettingsSectionHeaderCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:HEADER_SETTINGS_CELL_IDENTIFIER];
    }
    
    settingsSectionHeaderCell.delegate = self;
    
    NSString *sectionName = @"";
    BOOL hideSeparator = NO;
    BOOL showNewFeature = NO;
    switch (section) {
        case SECTION_CALL_PERMISSIONS:
            sectionName = TwinmeLocalizedString(@"settings_view_controller_authorization_title", nil);
            break;
            
        case SECTION_CONTROL_CAMERA:
            sectionName = TwinmeLocalizedString(@"call_view_controller_camera_control", nil);
            hideSeparator = YES;
            showNewFeature = YES;
            break;
            
        case SECTION_DISCREET_RELATION:
            sectionName = TwinmeLocalizedString(@"privacy_view_controller_title", nil);
            break;
            
        case SECTION_PROGRAMMED_CALL:
            sectionName = TwinmeLocalizedString(@"show_call_view_controller_schedule_call", nil).uppercaseString;;
            hideSeparator = YES;
            break;
            
        default:
            sectionName = @"";
            break;
    }
    
    [settingsSectionHeaderCell bindWithTitle:sectionName backgroundColor:Design.LIGHT_GREY_BACKGROUND_COLOR hideSeparator:hideSeparator uppercaseString:YES showNewFeature:showNewFeature];
    
    return settingsSectionHeaderCell;
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
            case SECTION_CONTROL_CAMERA:
                text = TwinmeLocalizedString(@"contact_capabilities_view_controller_information_camera_control", nil);
                break;
                
            case SECTION_DISCREET_RELATION:
                text = TwinmeLocalizedString(@"contact_capabilities_view_controller_information_discreet_relation", nil);
                break;
                
            case SECTION_PROGRAMMED_CALL:
                text = [self isGroupCapabilities] ? TwinmeLocalizedString(@"group_capabilities_view_controller_information_programmed_call", nil) : TwinmeLocalizedString(@"contact_capabilities_view_controller_information_programmed_call", nil);
                break;
                
            default:
                break;
        }
        
        [cell bindWithText:text];
        
        return cell;
    } else if (indexPath.section == SECTION_CONTROL_CAMERA) {
        SettingsValueItemCell *cell = [tableView dequeueReusableCellWithIdentifier:SETTINGS_VALUE_CELL_IDENTIFIER];
        if (!cell) {
            cell = [[SettingsValueItemCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:SETTINGS_VALUE_CELL_IDENTIFIER];
        }
        
        NSString *value;
        if (self.zoomable == TLVideoZoomableNever) {
            value = TwinmeLocalizedString(@"contact_capabilities_view_controller_camera_control_never", nil);
        } else if (self.zoomable  == TLVideoZoomableAsk) {
            value = TwinmeLocalizedString(@"contact_capabilities_view_controller_camera_control_ask", nil);
        } else {
            value = TwinmeLocalizedString(@"contact_capabilities_view_controller_camera_control_allow", nil);
        }
        
        [cell bindWithTitle:nil value:value];
        
        return cell;
    } else {
        SettingsItemCell *cell = [tableView dequeueReusableCellWithIdentifier:SETTINGS_CELL_IDENTIFIER];
        if (!cell) {
            cell = [[SettingsItemCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:SETTINGS_CELL_IDENTIFIER];
        }
        
        cell.settingsActionDelegate = self;
        
        NSString *title = @"";
        BOOL switchState = NO;
        int tag = 0;
        BOOL hiddenSwitch = NO;
        switch (indexPath.section) {
            case SECTION_CALL_PERMISSIONS:
                if (indexPath.row == 0) {
                    switchState = self.allowAudioCall;
                    hiddenSwitch = NO;
                    tag = TAG_ALLOW_AUDIO_CALL;
                    title = [self isGroupCapabilities] ? TwinmeLocalizedString(@"group_capabilities_view_controller_information_audio_call", nil) : TwinmeLocalizedString(@"contact_capabilities_view_controller_information_audio_call", nil);
                } else {
                    switchState = self.allowVideoCall;
                    hiddenSwitch = NO;
                    tag = TAG_ALLOW_VIDEO_CALL;
                    title = [self isGroupCapabilities] ? TwinmeLocalizedString(@"group_capabilities_view_controller_information_video_call", nil) : TwinmeLocalizedString(@"contact_capabilities_view_controller_information_video_call", nil);
                }
                
                break;
                
            case SECTION_DISCREET_RELATION:
                switchState = self.discreetRelation;
                hiddenSwitch = NO;
                tag = TAG_DISCREET_RELATION;
                title = TwinmeLocalizedString(@"contact_capabilities_view_controller_discreet_relation", nil);
                break;
                
            case SECTION_PROGRAMMED_CALL:
                switchState = self.scheduleEnable;
                hiddenSwitch = NO;
                tag = TAG_ENABLE_SCHEDULE;
                title = TwinmeLocalizedString(@"show_call_view_controller_setting_limited", nil);
                break;
                
            default:
                break;
        }
        
        [cell bindWithTitle:title icon:nil stateSwitch:switchState tagSwitch:tag hiddenSwitch:hiddenSwitch disableSwitch:YES backgroundColor:Design.WHITE_COLOR hiddenSeparator:NO];
        
        return cell;
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ didSelectRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    if (indexPath.section == SECTION_CONTROL_CAMERA) {
        [self showOnboarding:NO];
    }
}

#pragma mark - SettingsSectionHeaderDelegate

- (void)didTapNewFeature {
    DDLogVerbose(@"%@ didTapNewFeature", LOG_TAG);
    
    [self showOnboarding:YES];
}

#pragma mark - ConfirmViewDelegate

- (void)didTapConfirm:(nonnull AbstractConfirmView *)abstractConfirmView {
    DDLogVerbose(@"%@ didTapConfirm: %@", LOG_TAG, abstractConfirmView);
    
    if ([abstractConfirmView isKindOfClass:[PremiumFeatureConfirmView class]]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:TwinmeLocalizedString(@"twinme_plus_link", nil)] options:@{} completionHandler:nil];
    } else if (!abstractConfirmView.cancelView.hidden) {
        [self showPremiumFeature:FeatureTypeRemoteControl];
    }

    [abstractConfirmView closeConfirmView];
}

- (void)didTapCancel:(nonnull AbstractConfirmView *)abstractConfirmView {
    DDLogVerbose(@"%@ didTapCancel: %@", LOG_TAG, abstractConfirmView);
    
    [abstractConfirmView closeConfirmView];
    
    if ([abstractConfirmView isKindOfClass:[OnboardingConfirmView class]]) {
        [self.twinmeApplication setShowOnboardingType:OnboardingTypeRemoteCameraSettings state:NO];
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

#pragma mark - Private methods

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    self.view.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
    
    [self setNavigationTitle:TwinmeLocalizedString(@"contact_capabilities_view_controller_call_settings", nil)];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    [self.tableView registerNib:[UINib nibWithNibName:@"SettingsSectionHeaderCell" bundle:nil] forCellReuseIdentifier:HEADER_SETTINGS_CELL_IDENTIFIER];
    self.tableView.estimatedRowHeight = Design.SETTING_CELL_HEIGHT * Design.HEIGHT_RATIO;
    [self.tableView registerNib:[UINib nibWithNibName:@"SettingsItemCell" bundle:nil] forCellReuseIdentifier:SETTINGS_CELL_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"SettingsInformationCell" bundle:nil] forCellReuseIdentifier:SETTINGS_INFORMATION_CELL_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"SettingsValueItemCell" bundle:nil] forCellReuseIdentifier:SETTINGS_VALUE_CELL_IDENTIFIER];

    self.tableView.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
}

- (void)handleBackTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleBackTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        [self finish];
    }
}

- (void)finish {
    DDLogVerbose(@"%@ finish", LOG_TAG);
        
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)showOnboarding:(BOOL)hideCancel {
    DDLogVerbose(@"%@ showOnboarding", LOG_TAG);
    
    if (hideCancel || [self.twinmeApplication startOnboarding:OnboardingTypeRemoteCameraSettings]) {
        OnboardingConfirmView *onboardingConfirmView = [[OnboardingConfirmView alloc] init];
        onboardingConfirmView.confirmViewDelegate = self;
        [onboardingConfirmView initWithTitle:TwinmeLocalizedString(@"call_view_controller_camera_control_needs_help", nil) message: TwinmeLocalizedString(@"contact_capabilities_view_controller_camera_control_onboarding", nil) image:[UIImage imageNamed:@"OnboardingControlCamera"] action:TwinmeLocalizedString(@"application_ok", nil) actionColor:nil cancel:TwinmeLocalizedString(@"application_do_not_display", nil)];
        
        if (hideCancel) {
            [onboardingConfirmView hideCancelAction];
        }
        
        [self.navigationController.view addSubview:onboardingConfirmView];
        [onboardingConfirmView showConfirmView];
    } else {
        [self showPremiumFeature:FeatureTypeRemoteControl];
    }
}

- (void)showPremiumFeature:(FeatureType)featureType {
    DDLogVerbose(@"%@ showPremiumFeature", LOG_TAG);
    
    PremiumFeatureConfirmView *premiumFeatureConfirmView = [[PremiumFeatureConfirmView alloc] init];
    premiumFeatureConfirmView.confirmViewDelegate = self;
    [premiumFeatureConfirmView initWithPremiumFeature:[[UIPremiumFeature alloc]initWithFeatureType:featureType] parentViewController:self.navigationController];
    [self.navigationController.view addSubview:premiumFeatureConfirmView];
    [premiumFeatureConfirmView showConfirmView];
}

- (BOOL)isInformationPath:(NSIndexPath *)indexPath {
    
    return (indexPath.section == SECTION_DISCREET_RELATION && indexPath.row == 1) || ((indexPath.section == SECTION_CONTROL_CAMERA || indexPath.section == SECTION_PROGRAMMED_CALL) && indexPath.row == 0);
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    [self.tableView reloadData];
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    self.tableView.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
    self.view.backgroundColor = Design.WHITE_COLOR;
}

@end
