/*
 *  Copyright (c) 2023-2024 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <Photos/Photos.h>
#import <PhotosUI/PhotosUI.h>

#import <Twinme/TLProfile.h>
#import <Twinme/TLCallReceiver.h>
#import <Twinme/TLSchedule.h>
#import <Twinme/TLSpace.h>
#import <Twinme/UIImage+Resize.h>

#import "CreateExternalCallViewController.h"
#import <TwinmeCommon/TwinmeNavigationController.h>
#import "InvitationExternalCallViewController.h"
#import "TransferCallViewController.h"
#import "MessageSettingsViewController.h"

#import <Utils/NSString+Utils.h>

#import "SwitchView.h"
#import "MenuCallCapabilitiesView.h"
#import "MenuDateTimeView.h"
#import "MenuSelectValueView.h"
#import "DeviceAuthorization.h"
#import "OnboardingDetailView.h"
#import "SettingsSectionHeaderCell.h"
#import "SettingsValueItemCell.h"
#import "ScheduleCell.h"
#import "SettingsItemCell.h"
#import "WeeklyScheduleCell.h"
#import "SettingsInformationCell.h"
#import "AlertMessageView.h"

#import "MenuPhotoView.h"
#import "UIPremiumFeature.h"
#import "UITemplateExternalCall.h"
#import "UIConfigExternalCall.h"
#import "UIConfigExternalCallItem.h"

#import <TwinmeCommon/ApplicationDelegate.h>
#import <TwinmeCommon/CallReceiverService.h>
#import <TwinmeCommon/Design.h>
#import <TwinmeCommon/MainViewController.h>
#import <TwinmeCommon/TwinmeNavigationController.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static NSString *HEADER_SETTINGS_CELL_IDENTIFIER = @"HeaderSettingsCellIdentifier";
static NSString *SCHEDULE_CELL_IDENTIFIER = @"ScheduleCellIdentifier";
static NSString *WEEKLY_SCHEDULE_CELL_IDENTIFIER = @"WeeklyScheduleCellIdentifier";
static NSString *SETTINGS_VALUE_CELL_IDENTIFIER = @"SettingsValueCellIdentifier";
static NSString *SETTINGS_ITEM_CELL_IDENTIFIER = @"SettingsCellIdentifier";
static NSString *SETTINGS_INFORMATION_CELL_IDENTIFIER = @"SettingsInformationCellIdentifier";

static UIColor *DESIGN_AVATAR_PLACEHOLDER_COLOR;

//
// Interface: CreateExternalCallViewController ()
//

@interface CreateExternalCallViewController ()<UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextViewDelegate, UITableViewDelegate, UITableViewDataSource, CallReceiverServiceDelegate, MenuCallCapabilitiesDelegate, MenuDateTimeViewDelegate, UIAdaptivePresentationControllerDelegate, MenuPhotoViewDelegate, BottomSheetViewDelegate, ScheduleDelegate, SettingsActionDelegate, UIGestureRecognizerDelegate, MenuSelectValueDelegate, WeeklyScheduleDelegate, AlertMessageViewDelegate, PHPickerViewControllerDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *avatarPlaceholderImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *avatarPlaceholderImageView;
@property (weak, nonatomic) IBOutlet UIView *editAvatarView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *nameView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameTextFieldLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameTextFieldTrailingConstraint;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *counterNameLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *counterNameLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet UILabel *counterNameLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *descriptionViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *descriptionViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *descriptionViewTopConstraint;
@property (weak, nonatomic) IBOutlet UIView *descriptionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *descriptionTextViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *descriptionTextViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *descriptionTextViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *descriptionTextViewBottomConstraint;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *counterDescriptionLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *counterDescriptionLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet UILabel *counterDescriptionLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *settingsTableViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *settingsTableViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *settingsTableViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UITableView *settingsTableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *saveViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *saveViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *saveViewWidthConstraint;
@property (weak, nonatomic) IBOutlet UIView *saveView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *saveLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet UILabel *saveLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;

@property (nonatomic) BOOL keyboardHidden;
@property (nonatomic) BOOL updated;
@property (nonatomic) BOOL creatingInProgress;
@property (nonatomic) BOOL showOnboardingView;
@property (nonatomic) BOOL showPremiumFeatureDescription;
@property (nonatomic) UIImage *updatedCallReceiverAvatar;
@property (nonatomic) UIImage *updatedCallReceiverLargeAvatar;

@property (nonatomic) CallReceiverService *callReceiverService;
@property (nonatomic) TLCallReceiver *callReceiver;

@property (nonatomic) UIConfigExternalCall *configExternalCall;
@property (nonatomic) UITemplateExternalCall *uiTemplateExternalCall;

@end

//
// Implementation: CreateExternalCallViewController
//

#undef LOG_TAG
#define LOG_TAG @"CreateExternalCallViewController"

@implementation CreateExternalCallViewController

#pragma mark - UIViewController

+ (void)initialize {
    DDLogVerbose(@"%@ initialize", LOG_TAG);
    
    DESIGN_AVATAR_PLACEHOLDER_COLOR = [UIColor colorWithRed:242./255. green:243./255. blue:245./255. alpha:1.0];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    DDLogVerbose(@"%@ initWithCoder: %@", LOG_TAG, coder);
    
    self = [super initWithCoder:coder];
    
    if (self) {
        _updated = NO;
        _isTransfert = NO;
        _creatingInProgress = NO;
        _keyboardHidden = YES;
        _showOnboardingView = NO;
        _showPremiumFeatureDescription = NO;
        _callReceiverService = [[CallReceiverService alloc] initWithTwinmeContext:self.twinmeContext delegate:self];
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
    if (!self.showPremiumFeatureDescription && self.isTransfert && [self.twinmeApplication startOnboarding:OnboardingTypeTransferCall]) {
        self.showPremiumFeatureDescription = YES;
        
        OnboardingDetailView *onboardingDetailView = [[OnboardingDetailView alloc] init];
        onboardingDetailView.bottomSheetViewDelegate = self;
        [onboardingDetailView initWithPremiumFeature:[[UIPremiumFeature alloc]initWithFeatureType:FeatureTypeTransfertCall spaceSettings:[self currentSpaceSettings]]];
        [self.navigationController.view addSubview:onboardingDetailView];
        [onboardingDetailView showConfirmView];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    DDLogVerbose(@"%@ viewWillDisappear: %@", LOG_TAG, animated ? @"YES" : @"NO");
    
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    DDLogVerbose(@"%@ viewDidAppear: %@", LOG_TAG, animated ? @"YES" : @"NO");
    
    [super viewDidAppear:animated];
}

- (int)getActionViewHeight {
    DDLogVerbose(@"%@ getActionViewHeight", LOG_TAG);
    
    UIWindow *window = [self currentWindow];
    CGFloat safeAreaInset;
    if (window) {
        safeAreaInset = window.safeAreaInsets.bottom;
    } else {
        safeAreaInset = self.view.safeAreaInsets.bottom;
    }
    
    return self.messageLabel.frame.origin.y + self.messageLabel.frame.size.height + self.messageLabelTopConstraint.constant + safeAreaInset;
}

- (void)initWithTemplate:(UITemplateExternalCall *)templateExternalCall {
    DDLogVerbose(@"%@ initWithTemplate: %@", LOG_TAG, templateExternalCall);
    
    self.uiTemplateExternalCall = templateExternalCall;
    self.configExternalCall = [[UIConfigExternalCall alloc]initWithCreateExternalCallMode:YES];
    [self.configExternalCall initWithTemplate:templateExternalCall];
    
    if (self.uiTemplateExternalCall.templateType == TemplateExternalCallTypeProfile) {
        [self.callReceiverService getProfileAvatar:self.currentSpace.profile];
    }
}

#pragma mark - CallReceiverServiceDelegate

- (void)onCreateCallReceiver:(nonnull TLCallReceiver *)callReceiver {
    DDLogVerbose(@"%@ onCreateCallReceiver: %@", LOG_TAG, callReceiver);
    
    self.callReceiver = callReceiver;
    [self finish];
}

- (void)onGetCallReceiver:(nullable TLCallReceiver *)callReceiver {
    DDLogVerbose(@"%@ onGetCallReceiver: %@", LOG_TAG, callReceiver);
    
}

- (void)onGetCallReceivers:(nonnull NSArray<TLCallReceiver *> *)callReceiver {
    DDLogVerbose(@"%@ onGetCallReceivers: %@", LOG_TAG, callReceiver);
    
}

- (void)onUpdateCallReceiver:(TLCallReceiver *)callReceiver {
    DDLogVerbose(@"%@ onUpdateCallReceiver: %@", LOG_TAG, callReceiver);
    
}

- (void)onChangeCallReceiverTwincode:(nonnull TLCallReceiver *)callReceiver {
    DDLogVerbose(@"%@ onChangeCallReceiverTwincode: %@", LOG_TAG, callReceiver);
    
}

- (void)onUpdateCallReceiverAvatar:(UIImage *)avatar {
    DDLogVerbose(@"%@ onUpdateCallReceiverAvatar: %@", LOG_TAG, avatar);
    
}

- (void)onDeleteCallReceiver:(nonnull NSUUID *)callReceiverId {
    DDLogVerbose(@"%@ onDeleteCallReceiver: %@", LOG_TAG, callReceiverId);
    
}

- (void)onGetTwincodeURI:(nonnull TLTwincodeURI *)uri {
    DDLogVerbose(@"%@ onGetTwincodeURI: %@", LOG_TAG, uri);

}

- (void)onGetProfileAvatar:(nonnull UIImage *)avatar {
    DDLogVerbose(@"%@ onGetProfileAvatar: %@", LOG_TAG, avatar);
    
    self.updatedCallReceiverLargeAvatar = avatar;
    self.updatedCallReceiverAvatar = [self.updatedCallReceiverLargeAvatar resizeImage];
    self.avatarView.image = self.updatedCallReceiverLargeAvatar;
    self.avatarPlaceholderImageView.hidden = YES;
    [self setUpdated];
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
    
    return Design.SETTING_CELL_HEIGHT;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ heightForFooterInSection: %ld", LOG_TAG, tableView, (long)section);
    
    return CGFLOAT_MIN;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ numberOfRowsInSection: %ld", LOG_TAG, tableView, (long)section);
    
    return self.configExternalCall.configItems.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ viewForHeaderInSection: %ld", LOG_TAG, tableView, (long)section);
        
    SettingsSectionHeaderCell *settingsSectionHeaderCell = (SettingsSectionHeaderCell *)[tableView dequeueReusableCellWithIdentifier:HEADER_SETTINGS_CELL_IDENTIFIER];
    if (!settingsSectionHeaderCell) {
        settingsSectionHeaderCell = [[SettingsSectionHeaderCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:HEADER_SETTINGS_CELL_IDENTIFIER];
    }
    
    [settingsSectionHeaderCell resetMargins];
    
    NSString *title = TwinmeLocalizedString(@"create_external_call_view_call_configuration", nil);
    [settingsSectionHeaderCell bindWithTitle:title backgroundColor:Design.WHITE_COLOR hideSeparator:YES uppercaseString:YES];
    
    return settingsSectionHeaderCell;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ viewForFooterInSection: %ld", LOG_TAG, tableView, (long)section);
    
    return [[UIView alloc]init];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ cellForRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    UIConfigExternalCallItem *configItem = self.configExternalCall.configItems[indexPath.row];
    
    switch (configItem.configExternalCallSettings) {
        case ConfigExternalCallSettingsCallType:
        case ConfigExternalCallSettingsPermissions:
        case ConfigExternalCallSettingsExpiration: {
            SettingsValueItemCell *cell = [tableView dequeueReusableCellWithIdentifier:SETTINGS_VALUE_CELL_IDENTIFIER];
            if (!cell) {
                cell = [[SettingsValueItemCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:SETTINGS_VALUE_CELL_IDENTIFIER];
            }
            
            [cell resetMargins];
            
            NSString *value = @"";
            if (configItem.configExternalCallSettings == ConfigExternalCallSettingsCallType) {
                value = [UIConfigExternalCall getCallType:self.configExternalCall.configTypeCall];
            } else if (configItem.configExternalCallSettings == ConfigExternalCallSettingsExpiration) {
                value = [UIConfigExternalCall getValidity:self.configExternalCall.linkValidity];
            } else {
                value = [UIConfigExternalCall getCallCapabilities:self.configExternalCall.allowVoiceCall allowVideo:self.configExternalCall.allowVideoCall allowGroup:self.configExternalCall.allowGroupCall];
            }
            [cell bindWithTitle:[configItem getTitle] value:value];
            
            return cell;
        }
            
        case ConfigExternalCallSettingsScheduleStart:
        case ConfigExternalCallSettingsScheduleEnd: {
            
            ScheduleCell *cell = [tableView dequeueReusableCellWithIdentifier:SCHEDULE_CELL_IDENTIFIER];
            if (!cell) {
                cell = [[ScheduleCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:SCHEDULE_CELL_IDENTIFIER];
            }
            
            cell.scheduleDelegate = self;
            [cell resetMargins];
            
            if (configItem.configExternalCallSettings == ConfigExternalCallSettingsScheduleStart) {
                [cell bind:ScheduleTypeStart date:self.configExternalCall.scheduleStartDate time:self.configExternalCall.scheduleStartTime isRecurrent:self.configExternalCall.linkValidity == TLLinkValidityPeriodic];
            } else {
                [cell bind:ScheduleTypeEnd date:self.configExternalCall.scheduleEndDate time:self.configExternalCall.scheduleEndTime isRecurrent:self.configExternalCall.linkValidity == TLLinkValidityPeriodic];
            }
            
            return cell;
        }
            
        case ConfigExternalCallSettingsScheduleRecurrent: {
            WeeklyScheduleCell *cell = [tableView dequeueReusableCellWithIdentifier:WEEKLY_SCHEDULE_CELL_IDENTIFIER];
            if (!cell) {
                cell = [[WeeklyScheduleCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:WEEKLY_SCHEDULE_CELL_IDENTIFIER];
            }
            
            cell.weeklyScheduleDelegate = self;
            [cell bind:self.settingsTableViewWidthConstraint.constant days:self.configExternalCall.scheduleRecurrentDays];
        
            return cell;
        }
        case ConfigExternalCallSettingsDelete: {
            SettingsInformationCell *cell = [tableView dequeueReusableCellWithIdentifier:SETTINGS_INFORMATION_CELL_IDENTIFIER];
            if (!cell) {
                cell = [[SettingsInformationCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:SETTINGS_INFORMATION_CELL_IDENTIFIER];
            }
            
            [cell bindWithText:TwinmeLocalizedString(@"create_external_call_view_delete_link_setting", nil) font:Design.FONT_REGULAR30 color:Design.FONT_COLOR_DEFAULT];
            [cell resetMargins];
            
            return cell;
        }
        case ConfigExternalCallSettingsNotification: {
            SettingsItemCell *cell = [tableView dequeueReusableCellWithIdentifier:SETTINGS_ITEM_CELL_IDENTIFIER];
            if (!cell) {
                cell = [[SettingsItemCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:SETTINGS_ITEM_CELL_IDENTIFIER];
            }
            
            cell.settingsActionDelegate = self;
        
            BOOL stateSwitch = NO;
            
            if (configItem.configExternalCallSettings == ConfigExternalCallSettingsDelete) {
                stateSwitch = self.configExternalCall.deleteLinkSetting;
            } else {
                stateSwitch = self.configExternalCall.notificationCallSetting;
            }
            
            [cell bindWithTitle:[configItem getTitle] subTitle:nil  icon:nil stateSwitch:stateSwitch tagSwitch:configItem.configExternalCallSettings hiddenSwitch:NO disableSwitch:NO backgroundColor:Design.WHITE_COLOR hiddenSeparator:YES];
                 
            [cell resetMargins];
            
            return cell;
        }
            
        default:
            return [[UITableViewCell alloc]init];
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ didSelectRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    UIConfigExternalCall *configItem = self.configExternalCall.configItems[indexPath.row];
    
    if (configItem.configExternalCallSettings == ConfigExternalCallSettingsPermissions) {
        [self openMenuCallCapabilities];
    } else if (configItem.configExternalCallSettings == ConfigExternalCallSettingsCallType) {
        [self openMenuSelectValue:MenuSelectValueTypeExternalCallType defaultValue:self.configExternalCall.configTypeCall];
    } else if (configItem.configExternalCallSettings == ConfigExternalCallSettingsExpiration) {
        [self openMenuSelectValue:MenuSelectValueTypeExternalCallExpiration defaultValue:(int)self.configExternalCall.linkValidity];
    }
}

#pragma mark - ScheduleDelegate

- (void)scheduleDate:(ScheduleType)scheduleType {
    DDLogVerbose(@"%@ scheduleDate", LOG_TAG);
    
    if (scheduleType == ScheduleTypeStart) {
        NSDate *date = [NSDate date];
        if (self.configExternalCall.scheduleStartDate) {
            NSDateComponents *startDateComponents = [[NSDateComponents alloc] init];
            startDateComponents.day = self.configExternalCall.scheduleStartDate.day;
            startDateComponents.month = self.configExternalCall.scheduleStartDate.month;
            startDateComponents.year = self.configExternalCall.scheduleStartDate.year;
            startDateComponents.hour = self.configExternalCall.scheduleStartTime.hour;
            startDateComponents.minute = self.configExternalCall.scheduleStartTime.minute;
            
            NSCalendar *calendar = [NSCalendar currentCalendar];
            date = [calendar dateFromComponents:startDateComponents];
        }
        
        [self openMenuDateTime:date minimumDate:[NSDate date] menuDateTimeType:MenuDateTimeTypeStartDate];
    } else {
        if (self.configExternalCall.scheduleStartDate) {
            NSDateComponents *startDateComponents = [[NSDateComponents alloc] init];
            startDateComponents.day = self.configExternalCall.scheduleStartDate.day;
            startDateComponents.month = self.configExternalCall.scheduleStartDate.month;
            startDateComponents.year = self.configExternalCall.scheduleStartDate.year;
            startDateComponents.hour = self.configExternalCall.scheduleStartTime.hour;
            startDateComponents.minute = self.configExternalCall.scheduleStartTime.minute;
            
            NSCalendar *calendar = [NSCalendar currentCalendar];
            NSDate *minimumDate = [calendar dateFromComponents:startDateComponents];
            
            NSDate *date = [minimumDate dateByAddingTimeInterval:3600];
            if (self.configExternalCall.scheduleEndDate) {
                NSDateComponents *startEndComponents = [[NSDateComponents alloc] init];
                startEndComponents.day = self.configExternalCall.scheduleEndDate.day;
                startEndComponents.month = self.configExternalCall.scheduleEndDate.month;
                startEndComponents.year = self.configExternalCall.scheduleEndDate.year;
                startEndComponents.hour = self.configExternalCall.scheduleEndTime.hour;
                startEndComponents.minute = self.configExternalCall.scheduleEndTime.minute;
                
                date = [calendar dateFromComponents:startEndComponents];
            }
        
            [self openMenuDateTime:date minimumDate:minimumDate menuDateTimeType:MenuDateTimeTypeEndDate];
        } else {
            [self openMenuDateTime:[NSDate date] minimumDate:[NSDate date] menuDateTimeType:MenuDateTimeTypeEndDate];
        }
    }
}

- (void)scheduleTime:(ScheduleType)scheduleType {
    DDLogVerbose(@"%@ scheduleTime", LOG_TAG);
    
    if (scheduleType == ScheduleTypeStart) {
        
        NSDate *date = [NSDate date];
        if (self.configExternalCall.scheduleStartDate) {
            NSDateComponents *startDateComponents = [[NSDateComponents alloc] init];
            startDateComponents.day = self.configExternalCall.scheduleStartDate.day;
            startDateComponents.month = self.configExternalCall.scheduleStartDate.month;
            startDateComponents.year = self.configExternalCall.scheduleStartDate.year;
            startDateComponents.hour = self.configExternalCall.scheduleStartTime.hour;
            startDateComponents.minute = self.configExternalCall.scheduleStartTime.minute;
            
            NSCalendar *calendar = [NSCalendar currentCalendar];
            date = [calendar dateFromComponents:startDateComponents];
        }
        
        [self openMenuDateTime:date minimumDate:[NSDate date] menuDateTimeType:MenuDateTimeTypeStartHour];
    } else {
        if (self.configExternalCall.scheduleStartDate) {
            NSDateComponents *startDateComponents = [[NSDateComponents alloc] init];
            startDateComponents.day = self.configExternalCall.scheduleStartDate.day;
            startDateComponents.month = self.configExternalCall.scheduleStartDate.month;
            startDateComponents.year = self.configExternalCall.scheduleStartDate.year;
            startDateComponents.hour = self.configExternalCall.scheduleStartTime.hour;
            startDateComponents.minute = self.configExternalCall.scheduleStartTime.minute;
            
            NSCalendar *calendar = [NSCalendar currentCalendar];
            NSDate *minimumDate = [calendar dateFromComponents:startDateComponents];
            
            NSDate *date = [minimumDate dateByAddingTimeInterval:3600];
            if (self.configExternalCall.scheduleEndDate) {
                NSDateComponents *startEndComponents = [[NSDateComponents alloc] init];
                startEndComponents.day = self.configExternalCall.scheduleEndDate.day;
                startEndComponents.month = self.configExternalCall.scheduleEndDate.month;
                startEndComponents.year = self.configExternalCall.scheduleEndDate.year;
                startEndComponents.hour = self.configExternalCall.scheduleEndTime.hour;
                startEndComponents.minute = self.configExternalCall.scheduleEndTime.minute;
                
                date = [calendar dateFromComponents:startEndComponents];
            }
        
            [self openMenuDateTime:date minimumDate:minimumDate menuDateTimeType:MenuDateTimeTypeEndHour];
        } else {
            [self openMenuDateTime:[NSDate date] minimumDate:[NSDate date] menuDateTimeType:MenuDateTimeTypeEndHour];
        }
    }
}

#pragma mark - WeeklyScheduleDelegate

- (void)didSelectDay:(UIScheduleDay *)scheduleDay {
    DDLogVerbose(@"%@ didSelectDay: %@", LOG_TAG, scheduleDay);
    
}

#pragma mark - SettingsActionDelegate

- (void)switchChangeValue:(SwitchView *)updatedSwitch {
    DDLogVerbose(@"%@ switchChangeValue: %@", LOG_TAG, updatedSwitch);

    if (updatedSwitch.tag == ConfigExternalCallSettingsNotification) {
        self.configExternalCall.notificationCallSetting = updatedSwitch.isOn;
    } else {
        self.configExternalCall.deleteLinkSetting = updatedSwitch.isOn;
    }
    
    [self updateConfig];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    DDLogVerbose(@"%@ textFieldShouldReturn: %@", LOG_TAG, textField);
    
    [textField resignFirstResponder];
    return NO;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    DDLogVerbose(@"%@ textView: %@ shouldChangeCharactersInRange: %lu shouldChangeCharactersInRange: %@", LOG_TAG, textField, (unsigned long)range.length, string);
    
    return textField.text.length + (string.length - range.length) <= MAX_NAME_LENGTH;
}

- (void)textFieldDidChange:(UITextField *)textField{
    DDLogVerbose(@"%@ textFieldDidChange: %@", LOG_TAG, textField);
    
    [self setUpdated];
    
    self.counterNameLabel.text = [NSString stringWithFormat:@"%lu/%d", (unsigned long)self.nameTextField.text.length, MAX_NAME_LENGTH];
}

#pragma mark - UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView {
    DDLogVerbose(@"%@ textViewDidBeginEditing: %@", LOG_TAG, textView);
    
    if ([textView.text isEqualToString:TwinmeLocalizedString(@"navigation_view_about_twinme", nil)]) {
        textView.text = @"";
        textView.textColor = Design.FONT_COLOR_DEFAULT;
    }
    
    self.counterDescriptionLabel.text = [NSString stringWithFormat:@"%lu/%d", (unsigned long)self.descriptionTextView.text.length, MAX_DESCRIPTION_LENGTH];
}

- (void)textViewDidChange:(UITextView *)textView {
    DDLogVerbose(@"%@ textViewDidChange: %@", LOG_TAG, textView);
    
    self.counterDescriptionLabel.text = [NSString stringWithFormat:@"%lu/%d", (unsigned long)self.descriptionTextView.text.length, MAX_DESCRIPTION_LENGTH];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    DDLogVerbose(@"%@ textView: %@ shouldChangeTextInRange: %lu replacementText: %@", LOG_TAG, textView, (unsigned long)range.length, text);
    
    return textView.text.length + (text.length - range.length) <= MAX_DESCRIPTION_LENGTH;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    DDLogVerbose(@"%@ textViewDidEndEditing: %@", LOG_TAG, textView);
    
    if ([textView.text isEqualToString:@""]) {
        textView.text = TwinmeLocalizedString(@"navigation_view_about_twinme", nil);
        textView.textColor = Design.PLACEHOLDER_COLOR;
    }
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)pickerController didFinishPickingMediaWithInfo:(NSDictionary *)info {
    DDLogVerbose(@"%@ imagePickerController: %@ didFinishPickingMediaWithInfo: %@", LOG_TAG, pickerController, info);
    
    self.navigationController.navigationBarHidden = YES;
    
    [pickerController dismissViewControllerAnimated:YES completion:^{
        self.updatedCallReceiverLargeAvatar = info[UIImagePickerControllerEditedImage];
        self.updatedCallReceiverAvatar = [self.updatedCallReceiverLargeAvatar resizeImage];
        self.avatarView.image = self.updatedCallReceiverLargeAvatar;
        self.avatarPlaceholderImageView.hidden = YES;
        
        [self setUpdated];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)pickerController {
    DDLogVerbose(@"%@ imagePickerControllerDidCancel: %@", LOG_TAG, pickerController);
    
    self.navigationController.navigationBarHidden = YES;
    
    [pickerController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - PHPickerViewControllerDelegate

- (void)picker:(PHPickerViewController *)pickerController didFinishPicking:(NSArray<PHPickerResult *> *)results API_AVAILABLE(ios(14)){
    DDLogVerbose(@"%@ picker: %@", LOG_TAG, pickerController);
        
    [self showProgressIndicator];
    
    [pickerController dismissViewControllerAnimated:YES completion:^{
        if (!results || results.count == 0) {
            [self hideProgressIndicator];
            return;
        }
    
        PHPickerResult *result = results.firstObject;
        if ([result.itemProvider hasItemConformingToTypeIdentifier:UTTypeImage.identifier]) {
            [result.itemProvider loadDataRepresentationForTypeIdentifier:UTTypeImage.identifier
                                                       completionHandler:^(NSData * _Nullable data,
                                                                           NSError * _Nullable error) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (!error) {
                        [self hideProgressIndicator];
                        self.updatedCallReceiverLargeAvatar = [UIImage imageWithData:data];
                        self.updatedCallReceiverAvatar = [self.updatedCallReceiverLargeAvatar resizeImage];
                        
                        CATransition *animation = [CATransition animation];
                        animation.type = kCATransitionFade;
                        animation.subtype = kCATransitionFromTop;
                        animation.duration = 0.5;
                        [self.avatarView.layer addAnimation:animation forKey:nil];
                        
                        self.avatarView.image = self.updatedCallReceiverLargeAvatar;
                        
                        self.avatarPlaceholderImageView.hidden = YES;
                        
                        [self setUpdated];
                    }
                });
            }];
        } else {
            [self hideProgressIndicator];
        }
    }];
}

#pragma mark - UIAdaptivePresentationControllerDelegate

- (void)presentationControllerWillDismiss:(UIPresentationController *)presentationController {
    DDLogVerbose(@"%@ presentationControllerWillDismiss: %@", LOG_TAG, presentationController);

    self.navigationController.navigationBarHidden = YES;
}

#pragma mark - BottomSheetViewDelegate

- (void)didTapConfirm:(nonnull AbstractBottomSheetView *)abstractBottomSheetView {
    DDLogVerbose(@"%@ didTapConfirm: %@", LOG_TAG, abstractBottomSheetView);
    
    [abstractBottomSheetView closeConfirmView];
}

- (void)didTapCancel:(nonnull AbstractBottomSheetView *)abstractBottomSheetView {
    DDLogVerbose(@"%@ didTapCancel: %@", LOG_TAG, abstractBottomSheetView);
    
    [abstractBottomSheetView closeConfirmView];
    [self.twinmeApplication setShowOnboardingType:OnboardingTypeTransferCall state:NO];
}

- (void)didClose:(nonnull AbstractBottomSheetView *)abstractBottomSheetView {
    DDLogVerbose(@"%@ didClose: %@", LOG_TAG, abstractBottomSheetView);
    
    [abstractBottomSheetView closeConfirmView];
}

- (void)didFinishCloseAnimation:(nonnull AbstractBottomSheetView *)abstractBottomSheetView {
    DDLogVerbose(@"%@ didFinishCloseAnimation: %@", LOG_TAG, abstractBottomSheetView);
    
    [abstractBottomSheetView removeFromSuperview];
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

- (void)menuDidClosed:(MenuCallCapabilitiesView *)menuCallCapabilitiesView allowVoiceCall:(BOOL)allowVoiceCall allowVideoCall:(BOOL)allowVideoCall allowGroupCall:(BOOL)allowGroupCall {
    DDLogVerbose(@"%@ menuDidClosed", LOG_TAG);

    [menuCallCapabilitiesView removeFromSuperview];
    
    self.configExternalCall.allowVoiceCall = allowVoiceCall;
    self.configExternalCall.allowVideoCall = allowVideoCall;
    self.configExternalCall.allowGroupCall = allowGroupCall;
    
    [self updateConfig];
}

#pragma mark - MenuSelectValueDelegate

- (void)selectValue:(MenuSelectValueView *)menuSelectValueView value:(int)value {
    DDLogVerbose(@"%@ selectValue: %d", LOG_TAG, value);

    [menuSelectValueView removeFromSuperview];
    
    if (menuSelectValueView.menuSelectValueType == MenuSelectValueTypeExternalCallType) {
        [self.configExternalCall setCallType:value];
    } else {
        [self.configExternalCall setValidity:value];
    }
    
    [self updateConfig];
}

- (void)cancelMenuSelectValue:(MenuSelectValueView *)menuSelectValueView {
    DDLogVerbose(@"%@ cancelMenuSelectValue: %@", LOG_TAG, menuSelectValueView);
    
    [menuSelectValueView removeFromSuperview];
}

#pragma mark - MenuDateTimeDelegate

- (void)menuDateTimeDidClosed:(MenuDateTimeView *)menuDateTimeView menuDateTimeType:(MenuDateTimeType)menuDateTimeType date:(NSDate *)date {
    DDLogVerbose(@"%@ menuDateTimeDidClosed", LOG_TAG);
    
    [menuDateTimeView removeFromSuperview];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSCalendarUnit calendarUnit = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute;
    NSDateComponents *dateComponents = [calendar components:calendarUnit fromDate:date];
    
    if (menuDateTimeType == MenuDateTimeTypeStartDate || menuDateTimeType == MenuDateTimeTypeStartHour) {
        self.configExternalCall.scheduleStartDate = [[TLDate alloc]initWithYear:(int)dateComponents.year month:(int)dateComponents.month day:(int)dateComponents.day];
        self.configExternalCall.scheduleStartTime = [[TLTime alloc]initWithHour:(int)dateComponents.hour minute:(int)dateComponents.minute];
    } else if (menuDateTimeType == MenuDateTimeTypeEndDate || menuDateTimeType == MenuDateTimeTypeEndHour) {
        self.configExternalCall.scheduleEndDate = [[TLDate alloc]initWithYear:(int)dateComponents.year month:(int)dateComponents.month day:(int)dateComponents.day];
        self.configExternalCall.scheduleEndTime = [[TLTime alloc]initWithHour:(int)dateComponents.hour minute:(int)dateComponents.minute];
    }
    
    if ([self.configExternalCall.scheduleStartDate compare:self.configExternalCall.scheduleEndDate] ==  NSOrderedDescending || ([self.configExternalCall.scheduleStartDate compare:self.configExternalCall.scheduleEndDate] ==  NSOrderedSame && [self.configExternalCall.scheduleStartTime compare:self.configExternalCall.scheduleEndTime] != NSOrderedAscending)) {
        NSDateComponents *startDateComponents = [[NSDateComponents alloc] init];
        startDateComponents.day = self.configExternalCall.scheduleStartDate.day;
        startDateComponents.month = self.configExternalCall.scheduleStartDate.month;
        startDateComponents.year = self.configExternalCall.scheduleStartDate.year;
        startDateComponents.hour = self.configExternalCall.scheduleStartTime.hour;
        startDateComponents.minute = self.configExternalCall.scheduleStartTime.minute;
        
        NSDate *startDate = [calendar dateFromComponents:startDateComponents];
        NSDate *endDate = [calendar dateByAddingUnit:NSCalendarUnitHour value:1 toDate:startDate options:0];
        dateComponents = [calendar components:calendarUnit fromDate:endDate];
        self.configExternalCall.scheduleEndDate = [[TLDate alloc]initWithYear:(int)dateComponents.year month:(int)dateComponents.month day:(int)dateComponents.day];
        self.configExternalCall.scheduleEndTime = [[TLTime alloc]initWithHour:(int)dateComponents.hour minute:(int)dateComponents.minute];
    }
    
    [self updateConfig];
}

#pragma mark - MenuPhotoViewDelegate

- (void)menuPhotoDidSelectCamera:(MenuPhotoView *)menuPhotoView {
    DDLogVerbose(@"%@ menuPhotoDidSelectCamera", LOG_TAG);
    
    [menuPhotoView removeFromSuperview];
    [self takePhoto];
}

- (void)menuPhotoDidSelectGallery:(MenuPhotoView *)menuPhotoView {
    DDLogVerbose(@"%@ menuPhotoDidSelectGallery", LOG_TAG);
    
    [menuPhotoView removeFromSuperview];
    [self selectPhoto];
}

- (void)cancelMenuPhoto:(MenuPhotoView *)menuPhotoView {
    DDLogVerbose(@"%@ cancelMenu", LOG_TAG);
    
    [menuPhotoView removeFromSuperview];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    DDLogVerbose(@"%@ gestureRecognizer: %@ shouldReceiveTouch: %@", LOG_TAG, gestureRecognizer, touch);
    
    if ([touch.view isDescendantOfView:self.settingsTableView]) {
        return NO;
    }
    
    return YES;
}

#pragma mark - Private methods

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    [super initViews];
    
    self.view.backgroundColor = Design.WHITE_COLOR;

    [self setNavigationTitle:TwinmeLocalizedString(@"premium_services_view_click_to_call_title", nil)];
        
    [self.editAvatarView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleUpdateAvatarTapGesture)]];
    self.editAvatarView.isAccessibilityElement = YES;
    
    self.avatarView.backgroundColor = DESIGN_AVATAR_PLACEHOLDER_COLOR;
    self.avatarPlaceholderImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
        
    self.nameViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.nameViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.nameViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.nameView.backgroundColor = Design.TEXTFIELD_BACKGROUND_COLOR;
    self.nameView.layer.cornerRadius = Design.CONTAINER_RADIUS;
    self.nameView.clipsToBounds = YES;
    
    self.nameTextFieldLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.nameTextFieldTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.nameTextField.font = Design.FONT_REGULAR44;
    self.nameTextField.textColor = Design.FONT_COLOR_DEFAULT;
    self.nameTextField.tintColor = Design.FONT_COLOR_DEFAULT;
    self.nameTextField.placeholder = TwinmeLocalizedString(@"application_name_hint", nil);
    [self.nameTextField setReturnKeyType:UIReturnKeyDone];

    self.nameTextField.delegate = self;
    [self.nameTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    self.counterNameLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.counterNameLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    
    self.counterNameLabel.font = Design.FONT_REGULAR26;
    self.counterNameLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.counterNameLabel.text = [NSString stringWithFormat:@"0/%d", MAX_NAME_LENGTH];
    
    self.descriptionViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.descriptionViewHeightConstraint.constant = Design.DESCRIPTION_HEIGHT;
    self.descriptionViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.descriptionView.backgroundColor = Design.TEXTFIELD_BACKGROUND_COLOR;
    self.descriptionView.layer.cornerRadius = Design.CONTAINER_RADIUS;
    self.descriptionView.clipsToBounds = YES;
    
    self.descriptionTextViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.descriptionTextViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.descriptionTextView.font = Design.FONT_REGULAR28;
    self.descriptionTextView.textColor = Design.PLACEHOLDER_COLOR;
    self.descriptionTextView.tintColor = Design.FONT_COLOR_DEFAULT;
    self.descriptionTextView.delegate = self;
    self.descriptionTextView.text = TwinmeLocalizedString(@"navigation_view_about_twinme", nil);
    self.descriptionTextView.textContainer.lineFragmentPadding = 0;
    self.descriptionTextView.textContainerInset = UIEdgeInsetsZero;
    
    self.counterDescriptionLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.counterDescriptionLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    
    self.counterDescriptionLabel.font = Design.FONT_REGULAR26;
    self.counterDescriptionLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.counterDescriptionLabel.text = [NSString stringWithFormat:@"0/%d", MAX_DESCRIPTION_LENGTH];

    self.settingsTableViewTopConstraint.constant *= Design.WIDTH_RATIO;
    self.settingsTableViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.settingsTableViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.settingsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.settingsTableView.rowHeight = UITableViewAutomaticDimension;
    self.settingsTableView.backgroundColor = Design.WHITE_COLOR;
    self.settingsTableView.delegate = self;
    self.settingsTableView.dataSource = self;
    self.settingsTableView.scrollEnabled = NO;
    self.settingsTableView.estimatedRowHeight = Design.SETTING_CELL_HEIGHT * Design.HEIGHT_RATIO;
    
    [self.settingsTableView registerNib:[UINib nibWithNibName:@"SettingsSectionHeaderCell" bundle:nil] forCellReuseIdentifier:HEADER_SETTINGS_CELL_IDENTIFIER];
    [self.settingsTableView registerNib:[UINib nibWithNibName:@"WeeklyScheduleCell" bundle:nil] forCellReuseIdentifier:WEEKLY_SCHEDULE_CELL_IDENTIFIER];
    [self.settingsTableView registerNib:[UINib nibWithNibName:@"ScheduleCell" bundle:nil] forCellReuseIdentifier:SCHEDULE_CELL_IDENTIFIER];
    [self.settingsTableView registerNib:[UINib nibWithNibName:@"SettingsValueItemCell" bundle:nil] forCellReuseIdentifier:SETTINGS_VALUE_CELL_IDENTIFIER];
    [self.settingsTableView registerNib:[UINib nibWithNibName:@"SettingsItemCell" bundle:nil] forCellReuseIdentifier:SETTINGS_ITEM_CELL_IDENTIFIER];
    [self.settingsTableView registerNib:[UINib nibWithNibName:@"SettingsInformationCell" bundle:nil] forCellReuseIdentifier:SETTINGS_INFORMATION_CELL_IDENTIFIER];

    self.saveViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.saveViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.saveViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    
    self.saveView.backgroundColor = Design.MAIN_COLOR;
    self.saveView.userInteractionEnabled = YES;
    self.saveView.isAccessibilityElement = YES;
    self.saveView.accessibilityLabel = TwinmeLocalizedString(@"application_save", nil);
    self.saveView.layer.cornerRadius = Design.CONTAINER_RADIUS;
    self.saveView.clipsToBounds = YES;
    [self.saveView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSaveTapGesture:)]];
    
    self.saveLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.saveLabel.font = Design.FONT_BOLD36;
    self.saveLabel.textColor = [UIColor whiteColor];
    self.saveLabel.text = TwinmeLocalizedString(@"application_save", nil);
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture)];
    tapGesture.delegate = self;
    tapGesture.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGesture];
    
    self.messageLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.messageLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    
    self.messageLabel.font = Design.FONT_REGULAR32;
    self.messageLabel.textColor = Design.FONT_COLOR_DEFAULT;
    
    [self initCallReceiver];
    [self updateConfig];
}

- (void)finish {
    DDLogVerbose(@"%@ finish", LOG_TAG);
        
    if (self.callReceiverService) {
        [self.callReceiverService dispose];
        self.callReceiverService = nil;
    } else {
        return;
    }
    
    if (self.callReceiver) {
        [self showCallReceiver:self.callReceiver];
        self.callReceiver = nil;
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)setUpdated {
    DDLogVerbose(@"%@ setUpdated", LOG_TAG);
    
    if ([self.nameTextField.text isEqual:@""] || (!self.updatedCallReceiverLargeAvatar  && !self.isTransfert)) {
        self.updated = NO;
        self.saveView.alpha = 0.5;
    } else {
        self.updated = YES;
        self.saveView.alpha = 1.f;
    }
}

- (void)keyboardWillShow:(NSNotification *)notification {
    DDLogVerbose(@"%@ keyboardWillShow: %@", LOG_TAG, notification);
    
    if (!self.keyboardHidden) {
        return;
    }
    
    self.keyboardHidden = NO;
    NSDictionary *info = [notification userInfo];
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    CGRect descriptionViewFrame = self.descriptionView.frame;
    CGRect frame = self.view.frame;
    CGFloat slidePosition = frame.size.height - (keyboardSize.height + descriptionViewFrame.origin.y + descriptionViewFrame.size.height + self.descriptionViewTopConstraint.constant);
    [self moveSlideToPosition:slidePosition];
    
    frame.origin.y = -keyboardSize.height;
    self.view.frame = frame;
    
    if ([self.twinmeApplication getDefaultKeyboardHeight] != keyboardSize.height) {
        [self.twinmeApplication setDefaultKeyboardHeight:keyboardSize.height];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification {
    DDLogVerbose(@"%@ keyboardWillHide: %@", LOG_TAG, notification);
    
    self.keyboardHidden = YES;
    
    CGRect frame = self.view.frame;
    frame.origin.y = 0;
    self.view.frame = frame;
    
    [self moveSlideToInitialPosition];
}

- (void)keyboardWillChangeFrame:(NSNotification *)notification {
    DDLogVerbose(@"%@ keyboardWillChangeFrame: %@", LOG_TAG, notification);
    
    NSDictionary *info = [notification userInfo];
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    CGRect frame = CGRectMake(0, 0, Design.DISPLAY_WIDTH, Design.DISPLAY_HEIGHT);
    frame.origin.y = -keyboardSize.height;
    self.view.frame = frame;
}

- (void)dismissKeyboard {
    DDLogVerbose(@"%@ dismissKeyboard", LOG_TAG);
    
    if (!self.keyboardHidden) {
        [self.nameTextField resignFirstResponder];
        [self.descriptionTextView resignFirstResponder];
    }
}

- (void)handleTapGesture {
    DDLogVerbose(@"%@ handleTapGesture", LOG_TAG);
    
    if ([self.nameTextField isFirstResponder]) {
        [self.nameTextField resignFirstResponder];
    }
    
    if ([self.descriptionTextView isFirstResponder]) {
        [self.descriptionTextView resignFirstResponder];
    }
}

- (void)handleUpdateAvatarTapGesture {
    DDLogVerbose(@"%@ handleUpdateAvatarTapGesture", LOG_TAG);
    
    [self openMenuPhoto];
}

- (void)handleSaveTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleSaveTapGesture: %@", LOG_TAG, sender);
    
    if (self.creatingInProgress) {
        return;
    }
    
    if ([self.nameTextField.text length] == 0) {
        AlertMessageView *alertMessageView = [[AlertMessageView alloc] init];
        alertMessageView.alertMessageViewDelegate = self;
        [alertMessageView initWithTitle:TwinmeLocalizedString(@"deleted_account_view_warning", nil) message:TwinmeLocalizedString(@"create_external_call_view_name_required", nil)];
        [self.navigationController.view addSubview:alertMessageView];
        [alertMessageView showAlertView];
        return;
    } else if (!self.updatedCallReceiverAvatar && !self.isTransfert) {
        [self openMenuPhoto];
        return;
    }
    
    NSString *callReceiverDescription =  [self.descriptionTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([callReceiverDescription isEqualToString:TwinmeLocalizedString(@"navigation_view_about_twinme", nil)]) {
        callReceiverDescription = @"";
    }

    TLCapabilities *capabilities;
    if (self.isTransfert) {
        capabilities = [[TLCapabilities alloc]initWithTwincodeKind:TLTwincodeKindCallReceiver admin:NO];
        [capabilities setCapTransferWithValue:YES];
        
        if (!self.updatedCallReceiverAvatar) {
            self.updatedCallReceiverLargeAvatar = [UIImage imageNamed:@"TransfertCallPlaceholder"];
            self.updatedCallReceiverAvatar = [self.updatedCallReceiverLargeAvatar resizeImage];
        }
    } else {
        capabilities = [[TLCapabilities alloc]initWithTwincodeKind:self.configExternalCall.configTypeCall == ConfigExternalCallTypeCallConference ? TLTwincodeKindConference : TLTwincodeKindCallReceiver admin:NO];
        [capabilities setCapAudioWithValue:self.configExternalCall.allowVoiceCall];
        [capabilities setCapVideoWithValue:self.configExternalCall.allowVideoCall];
        [capabilities setCapGroupCallWithValue:self.configExternalCall.allowGroupCall];
        [capabilities setLinkValidityWithValue:self.configExternalCall.linkValidity];
        [capabilities setCapNotifyJoinWithValue:self.configExternalCall.notificationCallSetting];
        
        if (self.configExternalCall.linkValidity == TLLinkValiditySingleUse && self.configExternalCall.scheduleStartDate) {
            TLDateTime *startDateTime = [[TLDateTime alloc]initWithDate:self.configExternalCall.scheduleStartDate time:self.configExternalCall.scheduleStartTime];
            TLDateTime *endDateTime = [[TLDateTime alloc]initWithDate:self.configExternalCall.scheduleEndDate time:self.configExternalCall.scheduleEndTime];
            TLDateTimeRange *dateTimeRange = [[TLDateTimeRange alloc]initWithStart:startDateTime end:endDateTime];
            
            TLSchedule *schedule = [[TLSchedule alloc]initWithPrivate:NO timeZone:[NSTimeZone localTimeZone] timeRanges:@[dateTimeRange]];
            [schedule setEnabled:YES];
            [capabilities setSchedule:schedule];
        } else if (self.configExternalCall.linkValidity == TLLinkValidityPeriodic) {
            TLWeeklyTimeRange *weeklyTimeRange = [[TLWeeklyTimeRange alloc]initWithDays:[self.configExternalCall getSelectedDaysOfWeek] start:self.configExternalCall.scheduleStartTime end:self.configExternalCall.scheduleEndTime];
            
            TLSchedule *schedule = [[TLSchedule alloc]initWithPrivate:NO timeZone:[NSTimeZone localTimeZone] timeRanges:@[weeklyTimeRange]];
            [schedule setEnabled:YES];
            [capabilities setSchedule:schedule];
        }
    }
    
    [self.callReceiverService createCallReceiver:self.nameTextField.text description:callReceiverDescription avatar:self.updatedCallReceiverAvatar largeAvatar:self.updatedCallReceiverLargeAvatar capabilities:capabilities space:self.currentSpace];
}

- (void)takePhoto {
    DDLogVerbose(@"%@ takePhoto", LOG_TAG);
    
    AVAuthorizationStatus cameraAuthorizationStatus = [DeviceAuthorization deviceCameraAuthorizationStatus];
    switch (cameraAuthorizationStatus) {
        case AVAuthorizationStatusNotDetermined: {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if (granted) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
                        picker.delegate = self;
                        picker.allowsEditing = YES;
                        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                        picker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
                        [self presentViewController:picker animated:YES completion:nil];
                    });
                }
            }];
            break;
        }
            
        case AVAuthorizationStatusRestricted:
        case AVAuthorizationStatusDenied: {
            [DeviceAuthorization showCameraSettingsAlertInController:self];
            break;
        }
            
        case AVAuthorizationStatusAuthorized: {
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.allowsEditing = YES;
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            picker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
            [self presentViewController:picker animated:YES completion:nil];
            break;
        }
    }
}

- (void)selectPhoto {
    DDLogVerbose(@"%@ selectPhoto", LOG_TAG);
    
    PHPickerConfiguration *config = [[PHPickerConfiguration alloc] init];
    config.selectionLimit = 1;
    config.filter = [PHPickerFilter imagesFilter];
    
    PHPickerViewController *pickerViewController = [[PHPickerViewController alloc] initWithConfiguration:config];
    pickerViewController.delegate = self;
    [self presentViewController:pickerViewController animated:YES completion:nil];
}

- (void)showCallReceiver:(nonnull TLCallReceiver *)callReceiver {
    DDLogVerbose(@"%@ showCallReceiver: %@", LOG_TAG, callReceiver);
        
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        self.navigationController.navigationBarHidden = NO;
        ApplicationDelegate *delegate = (ApplicationDelegate *)[[UIApplication sharedApplication] delegate];
        MainViewController *mainViewController = delegate.mainViewController;
        TwinmeNavigationController *selectedNavigationController = mainViewController.selectedViewController;
        if (self.isTransfert) {
            TransferCallViewController *transferCallViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"TransferCallViewController"];
            [transferCallViewController initWithCallReceiver:callReceiver];
            [selectedNavigationController pushViewController:transferCallViewController animated:YES];
        } else {
            InvitationExternalCallViewController *invitationExternalCallViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"InvitationExternalCallViewController"];
            [invitationExternalCallViewController initWithCallReceiver:callReceiver];
            [selectedNavigationController pushViewController:invitationExternalCallViewController animated:YES];
        }
    }];
    
    [self.navigationController popToRootViewControllerAnimated:YES];

    [CATransaction commit];
}

- (void)initCallReceiver {
    DDLogVerbose(@"%@ initCallReceiver", LOG_TAG);
    
    if (self.isTransfert) {
        self.nameLabel.text = TwinmeLocalizedString(@"premium_services_view_transfert_title", nil);
        self.nameTextField.text = TwinmeLocalizedString(@"create_transfert_call_view_name_placeholder", nil);
        self.messageLabel.text = TwinmeLocalizedString(@"create_transfert_call_view_message", nil);
        self.avatarView.image = [UIImage imageNamed:@"TransfertCallPlaceholder"];
    } else {
        self.nameLabel.text = TwinmeLocalizedString(@"premium_services_view_click_to_call_title", nil);
        self.messageLabel.text = TwinmeLocalizedString(@"create_external_call_view_message", nil);
        self.nameTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:[self.uiTemplateExternalCall getPlaceholder] attributes:[NSDictionary dictionaryWithObject:Design.PLACEHOLDER_COLOR forKey:NSForegroundColorAttributeName]];
    }
    
    if (self.uiTemplateExternalCall) {
        if (self.uiTemplateExternalCall.templateType != TemplateExternalCallTypeOther) {
            self.nameTextField.text = [self.uiTemplateExternalCall getName];
        }
        
        if ([self.uiTemplateExternalCall getImage]) {
            self.avatarView.image = [self.uiTemplateExternalCall getImage];
            self.avatarView.backgroundColor = [UIColor clearColor];
            
            if ([self.uiTemplateExternalCall getImageUrl]) {
                NSURL *url = [NSURL URLWithString:[self.uiTemplateExternalCall getImageUrl]];
                NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
                NSURLSessionConfiguration *urlSessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
                NSURLSession *urlSession = [NSURLSession sessionWithConfiguration:urlSessionConfiguration delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
                NSURLSessionDataTask *urlSessionDataTask = [urlSession dataTaskWithRequest:urlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                    if (!error) {
                        UIImage *image = [UIImage imageWithData:data];
                        if (image) {
                            self.avatarView.image = image;
                            self.updatedCallReceiverLargeAvatar = image;
                            self.updatedCallReceiverAvatar = [self.uiTemplateExternalCall getImage];
                            [self setUpdated];
                        }
                    }
                }];
                [urlSessionDataTask resume];
            }
        }
    }
    
    [self setUpdated];
}

- (void)openMenuCallCapabilities {
    DDLogVerbose(@"%@ openMenuCallCapabilities", LOG_TAG);
    
    [self dismissKeyboard];
    
    MenuCallCapabilitiesView *menuCallCapabilitiesView = [[MenuCallCapabilitiesView alloc]init];
    menuCallCapabilitiesView.menuCallCapabilitiesDelegate = self;
    [self.tabBarController.view addSubview:menuCallCapabilitiesView];
    
    TLCapabilities *capabilities = [[TLCapabilities alloc]init];
    [capabilities setCapAudioWithValue:self.configExternalCall.allowVoiceCall];
    [capabilities setCapVideoWithValue:self.configExternalCall.allowVideoCall];
    [capabilities setCapGroupCallWithValue:self.configExternalCall.allowGroupCall];
    
    [menuCallCapabilitiesView openMenu:capabilities];
}

- (void)openMenuSelectValue:(MenuSelectValueType)menuSelectValueType defaultValue:(int)defaultValue {
    DDLogVerbose(@"%@ openMenuSelectValue", LOG_TAG);
    
    [self dismissKeyboard];
    
    MenuSelectValueView *menuSelectValueView = [[MenuSelectValueView alloc]init];
    menuSelectValueView.menuSelectValueDelegate = self;
    [self.tabBarController.view addSubview:menuSelectValueView];
    [menuSelectValueView setMenuSelectValueTypeWithType:menuSelectValueType defaultValue:defaultValue];
    [menuSelectValueView openMenu];
}

- (void)openMenuPhoto {
    DDLogVerbose(@"%@ openMenuPhoto", LOG_TAG);
    
    [self dismissKeyboard];
    
    MenuPhotoView *menuPhotoView = [[MenuPhotoView alloc]init];
    menuPhotoView.menuPhotoViewDelegate = self;
    [self.tabBarController.view addSubview:menuPhotoView];
    [menuPhotoView openMenu:YES];
}

- (void)openMenuDateTime:(NSDate *)date minimumDate:(NSDate *)minimumDate menuDateTimeType:(MenuDateTimeType)menuDateTimeType {
    DDLogVerbose(@"%@ openMenuDateTime", LOG_TAG);
    
    [self dismissKeyboard];
    
    MenuDateTimeView *menuDateTimeView = [[MenuDateTimeView alloc]init];
    menuDateTimeView.menuDateTimeViewDelegate = self;
    [self.tabBarController.view addSubview:menuDateTimeView];
        
    [menuDateTimeView setMenuDateTimeTypeWithType:menuDateTimeType isPeriodic:self.configExternalCall.linkValidity == TLLinkValidityPeriodic];
    [menuDateTimeView openMenu:minimumDate date:date];
}

- (void)updateConfig {
    DDLogVerbose(@"%@ updateConfig", LOG_TAG);
    
    if (self.isTransfert) {
        self.settingsTableView.hidden = YES;
        self.settingsTableViewHeightConstraint.constant = 0;
    }
    
    self.settingsTableViewHeightConstraint.constant = (self.configExternalCall.configItems.count + 1) * Design.SETTING_CELL_HEIGHT;
    [self.settingsTableView reloadData];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3f * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        int actionViewHeight = [self getActionViewHeight];
        if (actionViewHeight != -1) {
            int heightDiff = Design.DISPLAY_HEIGHT - actionViewHeight;
            if (heightDiff < 0) {
                [self.actionView setSlideContactTopMargin:heightDiff];
            }
            self.actionViewHeightConstraint.constant = actionViewHeight;
        }
        self.containerViewHeightConstraint.constant = [self getScrollViewContentHeight];
    });
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    self.nameTextField.font = Design.FONT_REGULAR28;
    self.descriptionTextView.font = Design.FONT_REGULAR28;
    self.saveLabel.font = Design.FONT_BOLD36;
    self.counterNameLabel.font = Design.FONT_REGULAR26;
    self.counterDescriptionLabel.font = Design.FONT_REGULAR26;
    self.messageLabel.font = Design.FONT_REGULAR32;
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    [super updateColor];
    
    self.nameView.backgroundColor = Design.TEXTFIELD_BACKGROUND_COLOR;
    self.saveView.backgroundColor = Design.MAIN_COLOR;
    self.descriptionView.backgroundColor = Design.TEXTFIELD_BACKGROUND_COLOR;
    self.nameTextField.textColor = Design.FONT_COLOR_DEFAULT;
    self.nameTextField.tintColor = Design.FONT_COLOR_DEFAULT;
    self.messageLabel.textColor = Design.FONT_COLOR_DEFAULT;
    if (self.isTransfert) {
        self.nameTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:TwinmeLocalizedString(@"create_transfert_call_view_name_placeholder", nil) attributes:[NSDictionary dictionaryWithObject:Design.PLACEHOLDER_COLOR forKey:NSForegroundColorAttributeName]];
    } else if (self.uiTemplateExternalCall) {
        self.nameTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:[self.uiTemplateExternalCall getPlaceholder] attributes:[NSDictionary dictionaryWithObject:Design.PLACEHOLDER_COLOR forKey:NSForegroundColorAttributeName]];
    }
    
    self.counterDescriptionLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.counterNameLabel.textColor = Design.FONT_COLOR_DEFAULT;
    
    if ([self.descriptionTextView.text isEqualToString:TwinmeLocalizedString(@"navigation_view_about_twinme", nil)]) {
        self.descriptionTextView.textColor = Design.PLACEHOLDER_COLOR;
    } else {
        self.descriptionTextView.textColor = Design.FONT_COLOR_DEFAULT;
    }
    
    if ([self.twinmeApplication darkModeEnable:[self currentSpaceSettings]]) {
        self.nameTextField.keyboardAppearance = UIKeyboardAppearanceDark;
        self.descriptionTextView.keyboardAppearance = UIKeyboardAppearanceDark;
    } else {
        self.nameTextField.keyboardAppearance = UIKeyboardAppearanceLight;
        self.descriptionTextView.keyboardAppearance = UIKeyboardAppearanceLight;
    }
}

@end
