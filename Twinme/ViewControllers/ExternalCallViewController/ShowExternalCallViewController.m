/*
 *  Copyright (c) 2023 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <Twinme/TLCallReceiver.h>
#import <Twinme/TLCapabilities.h>
#import <Twinme/TLSchedule.h>

#import "ShowExternalCallViewController.h"
#import "InvitationExternalCallViewController.h"
#import "EditExternalCallViewController.h"
#import "EditIdentityViewController.h"
#import "LastCallsViewController.h"
#import "MessageSettingsViewController.h"

#import <TwinmeCommon/CallReceiverService.h>
#import <TwinmeCommon/CallViewController.h>
#import <TwinmeCommon/Design.h>
#import <TwinmeCommon/SettingsSectionHeaderCell.h>

#import <Utils/NSString+Utils.h>

#import "SettingsValueItemCell.h"
#import "ScheduleCell.h"
#import "SettingsItemCell.h"
#import "WeeklyScheduleCell.h"
#import "SettingsInformationCell.h"

#import "AlertMessageView.h"
#import "DeviceAuthorization.h"
#import "MenuCallCapabilitiesView.h"
#import "MenuDateTimeView.h"
#import "MenuSelectValueView.h"
#import "SwitchView.h"
#import "UIScheduleDay.h"
#import "UIConfigExternalCall.h"
#import "UIConfigExternalCallItem.h"
#import "UIView+Toast.h"

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

//
// Interface: ShowExternalCallViewController ()
//

@interface ShowExternalCallViewController ()<CallReceiverServiceDelegate, SwitchViewDelegate, MenuCallCapabilitiesDelegate, MenuDateTimeViewDelegate, WeeklyScheduleDelegate, ScheduleDelegate, SettingsActionDelegate, MenuSelectValueDelegate, UITableViewDelegate, UITableViewDataSource, AlertMessageViewDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *shareViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *shareViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *shareViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *shareViewTopConstraint;
@property (weak, nonatomic) IBOutlet UIView *shareView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *shareImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *shareRoundedView;
@property (weak, nonatomic) IBOutlet UILabel *shareLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *videoViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *videoViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *videoViewTopConstraint;
@property (weak, nonatomic) IBOutlet UIView *videoRoundedView;
@property (weak, nonatomic) IBOutlet UIView *videoView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *videoImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UILabel *videoLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *audioViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *audioViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *audioViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *audioViewTopConstraint;
@property (weak, nonatomic) IBOutlet UIView *audioRoundedView;
@property (weak, nonatomic) IBOutlet UIView *audioView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *audioImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UILabel *audioLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *settingsTableViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *settingsTableViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UITableView *settingsTableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *historyTitleLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *historyTitleLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *historyTitleLabelTopConstraint;
@property (weak, nonatomic) IBOutlet UILabel *historyTitleLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lastCallViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lastCallViewTopConstraint;
@property (weak, nonatomic) IBOutlet InsideBorderView *lastCallView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lastCallImageViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lastCallImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lastCallLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lastCallLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *lastCallLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lastCallAccessoryViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lastCallAccessoryViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *lastCallAccessoryView;

@property (nonatomic) NSString *name;
@property (nonatomic) NSString *callReceiverDescription;
@property (nonatomic) NSString *identityDescription;
@property (nonatomic) UIImage *avatar;

@property (nonatomic) CallReceiverService *callReceiverService;
@property (nonatomic) TLCallReceiver *callReceiver;

@property (nonatomic) UIConfigExternalCall *configExternalCall;
@property (nonatomic) BOOL initCapabilities;

@end

//
// Implementation: ShowExternalCallViewController
//

#undef LOG_TAG
#define LOG_TAG @"ShowExternalCallViewController"

@implementation ShowExternalCallViewController

- (instancetype)initWithCoder:(NSCoder *)coder {
    DDLogVerbose(@"%@ initWithCoder: %@", LOG_TAG, coder);
    
    self = [super initWithCoder:coder];
    
    if (self) {
        _callReceiverService = [[CallReceiverService alloc] initWithTwinmeContext:self.twinmeContext delegate:self];
        _initCapabilities = NO;
    }
    return self;
}

- (void)viewDidLoad {
    DDLogVerbose(@"%@ viewDidLoad", LOG_TAG);
    
    [super viewDidLoad];
    
    [self initViews];
}

- (void)viewDidAppear:(BOOL)animated {
    DDLogVerbose(@"%@ viewDidAppear: %@", LOG_TAG, animated ? @"YES" : @"NO");
    
    [super viewDidAppear:animated];
}

- (void)initWithCallReceiver:(TLCallReceiver *)callReceiver {
    DDLogVerbose(@"%@ initWithCallReceiver: %@", LOG_TAG, callReceiver);
    
    self.callReceiver = callReceiver;
    self.configExternalCall = [[UIConfigExternalCall alloc] initWithCreateExternalCallMode:NO];
    
    self.name = self.callReceiver.name;
    [self.callReceiverService getImageWithCallReceiver:callReceiver withBlock:^(UIImage *image) {
        self.avatar = image;
    }];
    self.identityName = self.callReceiver.identityName;
    
    if (self.callReceiver.objectDescription) {
        self.callReceiverDescription = self.callReceiver.objectDescription;
    } else {
        self.callReceiverDescription = self.callReceiver.peerDescription;
    }
    [self.callReceiverService initWithCallReceiver:callReceiver];
}

- (void)backTap {
    DDLogVerbose(@"%@ backTap", LOG_TAG);
    
    [super backTap];
}

- (void)editTap {
    DDLogVerbose(@"%@ editTap", LOG_TAG);
    
    EditExternalCallViewController *editExternalCallViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"EditExternalCallViewController"];
    [editExternalCallViewController initWithCallReceiver:self.callReceiver];
    [self.navigationController pushViewController:editExternalCallViewController animated:YES];
}

- (void)identityTap {
    DDLogVerbose(@"%@ identityTap", LOG_TAG);
    
    self.navigationController.navigationBarHidden = NO;
    EditIdentityViewController *editIdentityViewController = (EditIdentityViewController *)[[UIStoryboard storyboardWithName:@"iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"EditIdentityViewController"];
    [editIdentityViewController initWithCallReceiver:self.callReceiver];
    [self.navigationController pushViewController:editIdentityViewController animated:YES];
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

    return self.lastCallView.frame.origin.y + self.lastCallViewHeightConstraint.constant + safeAreaInset;
}

#pragma mark - CallReceiverServiceDelegate

- (void)onCreateCallReceiver:(nonnull TLCallReceiver *)callReceiver {
    DDLogVerbose(@"%@ onCreateCallReceiver: %@", LOG_TAG, callReceiver);
    
}

- (void)onGetCallReceiver:(nullable TLCallReceiver *)callReceiver {
    DDLogVerbose(@"%@ onGetCallReceiver: %@", LOG_TAG, callReceiver);
    
}

- (void)onGetCallReceivers:(nonnull NSArray<TLCallReceiver *> *)callReceiver {
    DDLogVerbose(@"%@ onGetCallReceivers: %@", LOG_TAG, callReceiver);
    
}

- (void)onUpdateCallReceiver:(TLCallReceiver *)callReceiver {
    DDLogVerbose(@"%@ onUpdateCallReceiver: %@", LOG_TAG, callReceiver);
    
    if ([callReceiver.uuid isEqual:self.callReceiver.uuid]) {
        self.callReceiver = callReceiver;
        
        self.name = self.callReceiver.name;
        [self.callReceiverService getImageWithCallReceiver:callReceiver withBlock:^(UIImage *image) {
            self.avatar = image;
        }];
        self.identityName = self.callReceiver.identityName;
        
        if (self.callReceiver.objectDescription) {
            self.callReceiverDescription = self.callReceiver.objectDescription;
        } else {
            self.callReceiverDescription = self.callReceiver.peerDescription;
        }

        [self updateCallReceiver];
    }
}

- (void)onUpdateCallReceiverAvatar:(UIImage *)avatar {
    DDLogVerbose(@"%@ onUpdateCallReceiverAvatar: %@", LOG_TAG, avatar);
    
    self.avatar = avatar;
    
    [self updateCallReceiver];
}

- (void)onChangeCallReceiverTwincode:(nonnull TLCallReceiver *)callReceiver {
    DDLogVerbose(@"%@ onChangeCallReceiverTwincode: %@", LOG_TAG, callReceiver);
    
}

- (void)onDeleteCallReceiver:(nonnull NSUUID *)callReceiverId {
    DDLogVerbose(@"%@ onDeleteCallReceiver: %@", LOG_TAG, callReceiverId);
    
    if ([callReceiverId isEqual:self.callReceiver.uuid]) {
        [self finish];
    }
}

- (void)onGetTwincodeURI:(nonnull TLTwincodeURI *)uri { 
    DDLogVerbose(@"%@ onGetTwincodeURI: %@", LOG_TAG, uri);

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
                        
            NSString *value = @"";
            if (configItem.configExternalCallSettings == ConfigExternalCallSettingsExpiration) {
                value = [UIConfigExternalCall getValidity:self.configExternalCall.linkValidity];
            } else {
                value = [UIConfigExternalCall getCallCapabilities:self.configExternalCall.allowVoiceCall allowVideo:self.configExternalCall.allowVideoCall allowGroup:self.configExternalCall.allowGroupCall];
            }
            [cell bindWithTitle:[configItem getTitle] value:value icon:nil];
            
            return cell;
        }
            
        case ConfigExternalCallSettingsScheduleStart:
        case ConfigExternalCallSettingsScheduleEnd: {
            
            ScheduleCell *cell = [tableView dequeueReusableCellWithIdentifier:SCHEDULE_CELL_IDENTIFIER];
            if (!cell) {
                cell = [[ScheduleCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:SCHEDULE_CELL_IDENTIFIER];
            }
            
            cell.scheduleDelegate = self;
            
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
            [cell bind:Design.DISPLAY_WIDTH days:self.configExternalCall.scheduleRecurrentDays];
            
            return cell;
        }
        case ConfigExternalCallSettingsDelete: {
            SettingsInformationCell *cell = [tableView dequeueReusableCellWithIdentifier:SETTINGS_INFORMATION_CELL_IDENTIFIER];
            if (!cell) {
                cell = [[SettingsInformationCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:SETTINGS_INFORMATION_CELL_IDENTIFIER];
            }
            
            [cell bindWithText:TwinmeLocalizedString(@"create_external_call_view_delete_link_setting", nil) font:Design.FONT_REGULAR30 color:Design.FONT_COLOR_DEFAULT];
            
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
            
            [cell bindWithTitle:[configItem getTitle] subTitle:nil icon:nil stateSwitch:stateSwitch tagSwitch:configItem.configExternalCallSettings hiddenSwitch:NO disableSwitch:NO backgroundColor:Design.WHITE_COLOR hiddenSeparator:YES];
                             
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
    } else if (configItem.configExternalCallSettings == ConfigExternalCallSettingsExpiration) {
        [self openMenuSelectValue:MenuSelectValueTypeExternalCallExpiration defaultValue:(int)self.configExternalCall.linkValidity];
    }
}


#pragma mark - MenuSelectValueDelegate

- (void)menuDidClosed:(MenuCallCapabilitiesView *)menuCallCapabilitiesView allowVoiceCall:(BOOL)allowVoiceCall allowVideoCall:(BOOL)allowVideoCall allowGroupCall:(BOOL)allowGroupCall {
    DDLogVerbose(@"%@ menuDidClosed", LOG_TAG);

    [menuCallCapabilitiesView removeFromSuperview];
    
    self.configExternalCall.allowVoiceCall = allowVoiceCall;
    self.configExternalCall.allowVideoCall = allowVideoCall;
    self.configExternalCall.allowGroupCall = allowGroupCall;
    
    [self saveCapabilities];
    [self reloadData];
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
    
    [self saveCapabilities];
    [self reloadData];
}

#pragma mark - WeeklyScheduleDelegate

- (void)didSelectDay:(UIScheduleDay *)scheduleDay {
    DDLogVerbose(@"%@ didSelectDay: %@", LOG_TAG, scheduleDay);
        
    [self.configExternalCall updateDaySelected:scheduleDay.dayOfWeek selected:scheduleDay.isSelected];
    [self saveCapabilities];
}

#pragma mark - SettingsActionDelegate

- (void)switchChangeValue:(SwitchView *)updatedSwitch {
    DDLogVerbose(@"%@ switchChangeValue: %@", LOG_TAG, updatedSwitch);

    if (updatedSwitch.tag == ConfigExternalCallSettingsNotification) {
        self.configExternalCall.notificationCallSetting = updatedSwitch.isOn;
    } else {
        self.configExternalCall.deleteLinkSetting = updatedSwitch.isOn;
    }

    [self saveCapabilities];
    [self reloadData];
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

#pragma mark - MenuSelectValueDelegate

- (void)selectValue:(MenuSelectValueView *)menuSelectValueView value:(int)value {
    DDLogVerbose(@"%@ selectValue: %d", LOG_TAG, value);

    [menuSelectValueView removeFromSuperview];
    
    if (menuSelectValueView.menuSelectValueType == MenuSelectValueTypeExternalCallExpiration) {
        [self.configExternalCall setValidity:value];
    }
    
    [self saveCapabilities];
    [self reloadData];
}

- (void)cancelMenuSelectValue:(MenuSelectValueView *)menuSelectValueView {
    DDLogVerbose(@"%@ cancelMenuSelectValue: %@", LOG_TAG, menuSelectValueView);
    
    [menuSelectValueView removeFromSuperview];
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
    
    [super initViews];
    
    self.view.backgroundColor = Design.WHITE_COLOR;
    
    self.shareViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.shareViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.shareViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.shareViewLeadingConstraint.constant *= Design.WIDTH_RATIO;

    self.shareView.isAccessibilityElement = YES;
    UITapGestureRecognizer *shareViewGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTwincodeTapGesture:)];
    [self.shareView addGestureRecognizer:shareViewGestureRecognizer];
    [self.shareView setAccessibilityLabel:TwinmeLocalizedString(@"conversation_view_menu_item_view_share_title", nil)];
    
    self.shareRoundedView.backgroundColor = Design.FONT_COLOR_GREY;
    self.shareRoundedView.layer.cornerRadius = self.shareViewWidthConstraint.constant * 0.5;
    
    self.shareImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.shareLabel.font = Design.FONT_REGULAR28;
    self.shareLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.shareLabel.text = TwinmeLocalizedString(@"conversation_view_menu_item_view_share_title", nil);
    
    self.videoViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.videoViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.videoViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.videoView.isAccessibilityElement = YES;
    UITapGestureRecognizer *videoViewGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleVideoTapGesture:)];
    [self.videoView addGestureRecognizer:videoViewGestureRecognizer];
    [self.videoView setAccessibilityLabel:TwinmeLocalizedString(@"conversation_view_video_call", nil)];
    
    self.videoRoundedView.backgroundColor = Design.VIDEO_CALL_COLOR;
    self.videoRoundedView.layer.cornerRadius = self.videoViewWidthConstraint.constant * 0.5;
    
    self.videoImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.videoLabel.font = Design.FONT_REGULAR28;
    self.videoLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.videoLabel.text = TwinmeLocalizedString(@"show_contact_view_video", nil);
    
    self.audioViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.audioViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.audioViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.audioViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.audioView.isAccessibilityElement = YES;
    UITapGestureRecognizer *audioViewGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleAudioTapGesture:)];
    [self.audioView addGestureRecognizer:audioViewGestureRecognizer];
    [self.audioView setAccessibilityLabel:TwinmeLocalizedString(@"conversation_view_audio_call", nil)];
    
    self.audioRoundedView.backgroundColor = Design.AUDIO_CALL_COLOR;
    self.audioRoundedView.layer.cornerRadius = self.audioViewWidthConstraint.constant * 0.5;
    
    self.audioImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.audioLabel.font = Design.FONT_REGULAR28;
    self.audioLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.audioLabel.text = TwinmeLocalizedString(@"show_contact_view_audio", nil);
    
    self.nameLabel.text = TwinmeLocalizedString(@"application_profile", nil);
    
    self.identityTitleLabel.text = TwinmeLocalizedString(@"show_call_view_meeting_organizer", nil).uppercaseString;
    
    self.settingsTableViewTopConstraint.constant *= Design.WIDTH_RATIO;
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

    self.historyTitleLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.historyTitleLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.historyTitleLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.historyTitleLabel.font = Design.FONT_BOLD26;
    self.historyTitleLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.historyTitleLabel.text = TwinmeLocalizedString(@"show_contact_view_history_title", nil).uppercaseString;
    
    self.lastCallAccessoryViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.lastCallAccessoryViewHeightConstraint.constant = Design.ACCESSORY_HEIGHT;
    self.lastCallAccessoryView.tintColor = Design.ACCESSORY_COLOR;
    self.lastCallAccessoryView.image = [self.lastCallAccessoryView.image imageFlippedForRightToLeftLayoutDirection];
    
    self.lastCallViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.lastCallViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    UITapGestureRecognizer *lastCallViewGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleLastCallsTapGesture:)];
    [self.lastCallView addGestureRecognizer:lastCallViewGestureRecognizer];
    
    [self.lastCallView setBorder:Design.SEPARATOR_COLOR_GREY borderWidth:Design.SEPARATOR_HEIGHT width:Design.DISPLAY_WIDTH height:self.lastCallViewHeightConstraint.constant left:false right:false top:true bottom:true];
    
    self.lastCallImageViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.lastCallImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.lastCallLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.lastCallLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.lastCallLabel.text = TwinmeLocalizedString(@"show_contact_view_last_calls", nil);
    self.lastCallLabel.font = Design.FONT_REGULAR34;
    self.lastCallLabel.textColor = Design.FONT_COLOR_DEFAULT;
    
    [self updateCallReceiver];
}

- (void)finish {
    DDLogVerbose(@"%@ finish", LOG_TAG);
    
    if (self.callReceiverService) {
        [self.callReceiverService dispose];
        self.callReceiverService = nil;
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)handleTwincodeTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleTwincodeTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        self.navigationController.navigationBarHidden = NO;
        InvitationExternalCallViewController *invitationExternalCallViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"InvitationExternalCallViewController"];
        [invitationExternalCallViewController initWithCallReceiver:self.callReceiver];
        [self.navigationController pushViewController:invitationExternalCallViewController animated:YES];
    }
}

- (void)handleLastCallsTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleLastCallsTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        LastCallsViewController *lastCallsViewController = (LastCallsViewController *)[[UIStoryboard storyboardWithName:@"Contact" bundle:nil] instantiateViewControllerWithIdentifier:@"LastCallsViewController"];
        [lastCallsViewController initWithOriginator:self.callReceiver callReceiver:YES];
        [self.navigationController pushViewController:lastCallsViewController animated:YES];
    }
}

- (void)handleVideoTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleVideoTapGesture: %@", LOG_TAG, sender);
    
    if (self.callReceiver && sender.state == UIGestureRecognizerStateEnded && !self.twinmeApplication.inCall && self.callReceiver.capabilities.hasVideo && ![self hasSchedule]) {
        [self startVideoCallWithPermissionCheck:NO];
    } else if (!self.configExternalCall.allowVideoCall) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIWindow *window = [self currentWindow];
            if (window) {
                [window makeToast:TwinmeLocalizedString(@"application_not_authorized_operation_by_your_contact",nil)];
            }
        });
    } else if ([self hasSchedule]) {
        [self showSchedule];
    }
}

- (void)startVideoCallWithPermissionCheck:(BOOL)videoBell {
    DDLogVerbose(@"%@ startVideoCallWithPermissionCheck: %d", LOG_TAG, videoBell);
        
    AVAuthorizationStatus cameraAuthorizationStatus = [DeviceAuthorization deviceCameraAuthorizationStatus];
    switch (cameraAuthorizationStatus) {
        case AVAuthorizationStatusNotDetermined: {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if (granted) {
                    AVAudioSessionRecordPermission audioSessionRecordPermission = [DeviceAuthorization deviceMicrophonePermissionStatus];
                    switch (audioSessionRecordPermission) {
                        case AVAudioSessionRecordPermissionUndetermined: {
                            [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
                                if (granted) {
                                    dispatch_async(dispatch_get_main_queue(), ^(void) {
                                        [self startVideoCallViewController:videoBell];
                                    });
                                }
                            }];
                            break;
                        }
                            
                        case AVAudioSessionRecordPermissionDenied:
                            [DeviceAuthorization showMicrophoneCameraSettingsAlertInController:self];
                            break;
                            
                        case AVAudioSessionRecordPermissionGranted: {
                            dispatch_async(dispatch_get_main_queue(), ^(void) {
                                [self startVideoCallViewController:videoBell];
                            });
                            break;
                        }
                    }
                }
            }];
            break;
        }
            
        case AVAuthorizationStatusRestricted:
        case AVAuthorizationStatusDenied:
            [DeviceAuthorization showMicrophoneCameraSettingsAlertInController:self];
            break;
            
        case AVAuthorizationStatusAuthorized: {
            AVAudioSessionRecordPermission audioSessionRecordPermission = [DeviceAuthorization deviceMicrophonePermissionStatus];
            switch (audioSessionRecordPermission) {
                case AVAudioSessionRecordPermissionUndetermined: {
                    [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
                        if (granted) {
                            dispatch_async(dispatch_get_main_queue(), ^(void) {
                                [self startVideoCallViewController:videoBell];
                            });
                        }
                    }];
                    break;
                }
                    
                case AVAudioSessionRecordPermissionDenied:
                    [DeviceAuthorization showMicrophoneCameraSettingsAlertInController:self];
                    break;
                    
                case AVAudioSessionRecordPermissionGranted: {
                    dispatch_async(dispatch_get_main_queue(), ^(void) {
                        [self startVideoCallViewController:videoBell];
                    });
                    break;
                }
            }
            break;
        }
    }
}

- (void)startVideoCallViewController:(BOOL)videoBell {
    DDLogVerbose(@"%@ startVideoCallViewController: %d", LOG_TAG, videoBell);
    
    if (self.callReceiver) {
        CallViewController *callViewController = (CallViewController *)[[UIStoryboard storyboardWithName:@"Call" bundle:nil] instantiateViewControllerWithIdentifier:@"CallViewController"];
        [callViewController startCallWithOriginator:self.callReceiver videoBell:NO isVideoCall:YES isCertifyCall:NO];
        [self.navigationController pushViewController:callViewController animated:YES];
    }
}

- (void)handleAudioTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleAudioTapGesture: %@", LOG_TAG, sender);
    
    if (self.callReceiver && sender.state == UIGestureRecognizerStateEnded && !self.twinmeApplication.inCall && self.callReceiver.capabilities.hasAudio && ![self hasSchedule]) {
        AVAudioSessionRecordPermission audioSessionRecordPermission = [DeviceAuthorization deviceMicrophonePermissionStatus];
        switch (audioSessionRecordPermission) {
            case AVAudioSessionRecordPermissionUndetermined: {
                [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
                    if (granted) {
                        dispatch_async(dispatch_get_main_queue(), ^(void) {
                            [self startAudioCallViewController];
                        });
                    }
                }];
                break;
            }
                
            case AVAudioSessionRecordPermissionDenied:
                [DeviceAuthorization showMicrophoneSettingsAlertInController:self];
                break;
                
            case AVAudioSessionRecordPermissionGranted: {
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    [self startAudioCallViewController];
                });
                break;
            }
        }
    } else if (!self.callReceiver.capabilities.hasAudio) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIWindow *window = [self currentWindow];
            if (window) {
                [window makeToast:TwinmeLocalizedString(@"application_not_authorized_operation_by_your_contact",nil)];
            }
        });
    } else if ([self hasSchedule]) {
        [self showSchedule];
    }
}

- (void)startAudioCallViewController {
    DDLogVerbose(@"%@ startAudioCallViewController", LOG_TAG);
    
    if (self.callReceiver) {
        CallViewController *callViewController = (CallViewController *)[[UIStoryboard storyboardWithName:@"Call" bundle:nil] instantiateViewControllerWithIdentifier:@"CallViewController"];
        [callViewController startCallWithOriginator:self.callReceiver videoBell:NO isVideoCall:NO isCertifyCall:NO];
        [self.navigationController pushViewController:callViewController animated:YES];
    }
}


- (void)updateCallReceiver {
    DDLogVerbose(@"%@ updateCallReceiver", LOG_TAG);
    
    self.avatarView.image = self.avatar;
    self.nameLabel.text =  self.name;
    
    if (![self.callReceiver isConference]) {
        self.identityTitleLabel.hidden = YES;
        self.identityView.hidden = YES;
        self.identityViewTopConstraint.constant = 0;
        self.identityViewHeightConstraint.constant = 0;
        self.identityTitleLabelTopConstraint.constant = 0;
        self.audioView.hidden = YES;
        self.videoView.hidden = YES;
        self.shareViewLeadingConstraint.constant = 0;
    }
    
    if ([self.callReceiverDescription isEqual:TwinmeLocalizedString(@"navigation_view_about_twinme", nil)]) {
        self.descriptionLabel.text = @"";
    } else {
        self.descriptionLabel.text = self.callReceiverDescription;
    }
    
    self.identityLabel.text = self.identityName;
    [self.callReceiverService getIdentityImageWithCallReceiver:self.callReceiver withBlock:^(UIImage *image) {
        self.identityAvatarView.image = image;
    }];
    
    if (!self.initCapabilities) {
        self.initCapabilities = YES;
        [self updateCallCapabilities];
    }
}

- (void)updateCallCapabilities {
    DDLogVerbose(@"%@ updateCallCapabilities", LOG_TAG);
    
    TLCapabilities *capabilities;
    
    if (!self.callReceiver.capabilities) {
        capabilities = [[TLCapabilities alloc]init];
    } else {
        capabilities = [[TLCapabilities alloc] initWithCapabilities:[self.callReceiver.capabilities attributeValue]];
    }
        
    [self.configExternalCall updateWithCapabilities:capabilities isConferenceCall:[self.callReceiver isConference]];
    [self reloadData];
}

- (void)saveCapabilities {
    DDLogVerbose(@"%@ saveCallCapabilities", LOG_TAG);
    
    TLCapabilities *capabilities;
    if (!self.callReceiver.capabilities) {
        capabilities = [[TLCapabilities alloc]init];
    } else {
        capabilities = [[TLCapabilities alloc] initWithCapabilities:[self.callReceiver.capabilities attributeValue]];
    }

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
        [schedule setEnabled:true];
        [capabilities setSchedule:schedule];
    } else if (self.configExternalCall.linkValidity == TLLinkValidityPeriodic) {
        TLWeeklyTimeRange *weeklyTimeRange = [[TLWeeklyTimeRange alloc]initWithDays:[self.configExternalCall getSelectedDaysOfWeek] start:self.configExternalCall.scheduleStartTime end:self.configExternalCall.scheduleEndTime];
        
        TLSchedule *schedule = [[TLSchedule alloc]initWithPrivate:NO timeZone:[NSTimeZone localTimeZone] timeRanges:@[weeklyTimeRange]];
        [schedule setEnabled:YES];
        [capabilities setSchedule:schedule];
    } else if (capabilities.schedule) {
        [capabilities setSchedule:nil];
    }
    
    [self.callReceiver setNumberWithName:PROPERTY_CALL_RECEIVER_UPDATE_COUNTER value:1 + [self.callReceiver getNumberWithName:PROPERTY_CALL_RECEIVER_UPDATE_COUNTER defaultValue:0] twinmeContext:self.twinmeContext];
    
    [self.callReceiverService updateCallReceiverWithCallReceiver:self.callReceiver name:self.callReceiver.name description:self.callReceiver.objectDescription avatar:nil largeAvatar:nil capabilities:capabilities];
}
    
- (void)openMenuCallCapabilities {
    DDLogVerbose(@"%@ openMenuCallCapabilities", LOG_TAG);
    
    MenuCallCapabilitiesView *menuCallCapabilitiesView = [[MenuCallCapabilitiesView alloc]init];
    menuCallCapabilitiesView.menuCallCapabilitiesDelegate = self;
    [self.tabBarController.view addSubview:menuCallCapabilitiesView];
    
    TLCapabilities *capabilities;
    if (!self.callReceiver.capabilities) {
        capabilities = [[TLCapabilities alloc]init];
    } else {
        capabilities = [[TLCapabilities alloc] initWithCapabilities:[self.callReceiver.capabilities attributeValue]];
    }
    
    [menuCallCapabilitiesView openMenu:capabilities];
}

- (void)openMenuDateTime:(NSDate *)date minimumDate:(NSDate *)minimumDate menuDateTimeType:(MenuDateTimeType)menuDateTimeType {
    DDLogVerbose(@"%@ openMenuDateTime", LOG_TAG);
    
     MenuDateTimeView *menuDateTimeView = [[MenuDateTimeView alloc]init];
     menuDateTimeView.menuDateTimeViewDelegate = self;
     [self.tabBarController.view addSubview:menuDateTimeView];
     
     [menuDateTimeView setMenuDateTimeTypeWithType:menuDateTimeType isPeriodic:self.configExternalCall.linkValidity == TLLinkValidityPeriodic];
     [menuDateTimeView openMenu:minimumDate date:date];
}

- (void)openMenuSelectValue:(MenuSelectValueType)menuSelectValueType defaultValue:(int)defaultValue {
    DDLogVerbose(@"%@ openMenuSelectValue", LOG_TAG);
        
    MenuSelectValueView *menuSelectValueView = [[MenuSelectValueView alloc]init];
    menuSelectValueView.menuSelectValueDelegate = self;
    [self.tabBarController.view addSubview:menuSelectValueView];
    [menuSelectValueView setMenuSelectValueTypeWithType:menuSelectValueType defaultValue:defaultValue];
    [menuSelectValueView openMenu];
}

- (BOOL)hasSchedule {
    DDLogVerbose(@"%@ hasSchedule", LOG_TAG);
    
    if (self.callReceiver.capabilities.schedule && self.callReceiver.capabilities.schedule.enabled) {
        return ![self.callReceiver.capabilities.schedule isNowInRange];
    }
    
    return NO;
}

- (void)showSchedule {
    DDLogVerbose(@"%@ showSchedule", LOG_TAG);
    
    NSString *message = @"";
    
    TLSchedule *schedule = self.callReceiver.capabilities.schedule;
    
    if (schedule && schedule.timeRanges.count > 0) {
        if ([schedule.timeRanges[0] isKindOfClass:[TLWeeklyTimeRange class]]) {
            TLWeeklyTimeRange *weeklyTimeRange = (TLWeeklyTimeRange *)[schedule.timeRanges objectAtIndex:0];
                     
            TLTime *scheduleStartTime = weeklyTimeRange.start;
            TLTime *scheduleEndTime = weeklyTimeRange.end;
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
            NSMutableString *validityMessage = [[NSMutableString alloc] initWithString:@""];
            [validityMessage appendString:TwinmeLocalizedString(@"show_call_view_settings_start", nil)];
            [validityMessage appendString:@" : "];
            [validityMessage appendString:[scheduleStartTime formatTime]];
            [validityMessage appendString:@"\n"];
            [validityMessage appendString:TwinmeLocalizedString(@"show_call_view_settings_end", nil)];
            [validityMessage appendString:@" : "];
            [validityMessage appendString:[scheduleEndTime formatTime]];
            [validityMessage appendString:@"\n\n"];
            
            NSArray<NSString *> *symbols = dateFormatter.weekdaySymbols;
            
            for (NSNumber *dayOfWeek in weeklyTimeRange.days) {
                NSString *dayString = @"";
                switch ([dayOfWeek intValue]) {
                    case MONDAY:
                        dayString = symbols[1];
                        break;
                    case TUESDAY:
                        dayString = symbols[2];
                        break;
                    case WEDNESDAY:
                        dayString = symbols[3];
                        break;
                    case THURSDAY:
                        dayString = symbols[4];
                        break;
                    case FRIDAY:
                        dayString = symbols[5];
                        break;
                    case SATURDAY:
                        dayString = symbols[6];
                        break;
                    case SUNDAY:
                        dayString = symbols[0];
                        break;
                }
                
                if (![dayString isEqualToString:@""]) {
                    [validityMessage appendString:dayString];
                    [validityMessage appendString:@"\n"];
                }
                
                message = [validityMessage description];
            }
        } else {
            TLDateTimeRange *dateTimeRange = (TLDateTimeRange *)[schedule.timeRanges objectAtIndex:0];
                    
            TLDateTime *start = dateTimeRange.start;
            TLDateTime *end = dateTimeRange.end;
            if ([start.date isEqual:end.date]) {
                message = [NSString stringWithFormat:TwinmeLocalizedString(@"show_call_view_schedule_from_to", nil), [start.date formatDate], [start.time formatTime], [end.time formatTime]];
            } else {
                message = [NSString stringWithFormat:@"%@ %@", [start formatDateTime], [end formatDateTime]];
            }
        }
    } else {
        message = TwinmeLocalizedString(@"show_call_view_schedule_message", nil);
    }
                
    AlertMessageView *alertMessageView = [[AlertMessageView alloc] init];
    alertMessageView.alertMessageViewDelegate = self;
    [alertMessageView initWithTitle:TwinmeLocalizedString(@"show_call_view_schedule_call", nil) message:message];
    [self.tabBarController.view addSubview:alertMessageView];
    [alertMessageView showAlertView];
}

- (void)reloadData {
    DDLogVerbose(@"%@ reloadData", LOG_TAG);
    
    [self.settingsTableView reloadData];
    
    self.settingsTableViewHeightConstraint.constant = (self.configExternalCall.configItems.count + 1) * Design.SETTING_CELL_HEIGHT;
    
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
    
    [super updateFont];
    
    self.descriptionLabel.font = Design.FONT_MEDIUM34;
    self.shareLabel.font = Design.FONT_REGULAR28;
    self.videoLabel.font = Design.FONT_REGULAR28;
    self.audioLabel.font = Design.FONT_REGULAR28;
    self.historyTitleLabel.font = Design.FONT_BOLD26;
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    [super updateColor];
    
    self.view.backgroundColor = Design.WHITE_COLOR;
    self.descriptionLabel.textColor = Design.FONT_COLOR_DESCRIPTION;
    self.shareLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.videoLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.audioLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.historyTitleLabel.textColor = Design.FONT_COLOR_DEFAULT;
    
    [self updateCallCapabilities];
}

@end
