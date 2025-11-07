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
#import "InAppSubscriptionViewController.h"

#import "SettingsItemCell.h"
#import "ScheduleCell.h"
#import "SettingsSectionHeaderCell.h"
#import "SettingsInformationCell.h"
#import "SettingsValueItemCell.h"
#import "PremiumFeatureConfirmView.h"
#import "OnboardingConfirmView.h"
#import "UIPremiumFeature.h"

#import <TwinmeCommon/Design.h>
#import <TwinmeCommon/EditContactCapabilitiesService.h>
#import <TwinmeCommon/TwinmeNavigationController.h>

#import "SwitchView.h"
#import "MenuDateTimeView.h"

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static NSString *SETTINGS_CELL_IDENTIFIER = @"SettingsCellIdentifier";
static NSString *HEADER_SETTINGS_CELL_IDENTIFIER = @"HeaderSettingsCellIdentifier";
static NSString *SETTINGS_INFORMATION_CELL_IDENTIFIER = @"SettingsInformationCellIdentifier";
static NSString *SCHEDULE_CELL_IDENTIFIER = @"ScheduleCellIdentifier";
static NSString *SETTINGS_VALUE_CELL_IDENTIFIER = @"SettingsValueCellIdentifier";

//
// Interface: AbstractCapabilitiesViewController ()
//

@interface AbstractCapabilitiesViewController () <SettingsActionDelegate, EditContactCapabilitiesServiceDelegate, ScheduleDelegate, MenuDateTimeViewDelegate, ConfirmViewDelegate, SettingsSectionHeaderDelegate>

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
        _canSave = NO;
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

- (void)viewWillDisappear:(BOOL)animated {
    DDLogVerbose(@"%@ viewWillDisappear: %@", LOG_TAG, animated ? @"YES" : @"NO");
    
    [super viewWillDisappear:animated];
    
    [self saveCapabilities];
}

- (BOOL)isGroupCapabilities {
    DDLogVerbose(@"%@ isGroupCapabilities", LOG_TAG);
    
    return NO;
}

- (void)saveCapabilities {
    DDLogVerbose(@"%@ saveCapabilities", LOG_TAG);
    
}

- (void)openMenuSelectValue {
    DDLogVerbose(@"%@ openMenuSelectValue", LOG_TAG);
    
}

- (void)setUpdated {
    DDLogVerbose(@"%@ setUpdated", LOG_TAG);
    
}

#pragma mark - SettingsActionDelegate

- (void)switchChangeValue:(SwitchView *)updatedSwitch {
    DDLogVerbose(@"%@ switchChangeValue: %@", LOG_TAG, updatedSwitch);
    
    switch (updatedSwitch.tag) {
        case TAG_ALLOW_AUDIO_CALL:
            self.allowAudioCall = updatedSwitch.isOn;
            break;
            
        case TAG_ALLOW_VIDEO_CALL:
            self.allowVideoCall = updatedSwitch.isOn;
            break;
            
        case TAG_DISCREET_RELATION:
            self.discreetRelation = updatedSwitch.isOn;
            break;
            
        case TAG_ENABLE_SCHEDULE:
            self.scheduleEnable = updatedSwitch.isOn;
            break;
            
        default:
            break;
    }
    
    if (self.scheduleEnable && !self.scheduleStartDate) {
        [self initSchedule];
    }
    
    [self setUpdated];
    [self.tableView reloadData];
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
    } else if (section == SECTION_PROGRAMMED_CALL && self.scheduleEnable) {
        return 4;
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
    } else if (indexPath.section == SECTION_PROGRAMMED_CALL && self.scheduleEnable && indexPath.row > 1) {
        ScheduleCell *cell = [tableView dequeueReusableCellWithIdentifier:SCHEDULE_CELL_IDENTIFIER];
        if (!cell) {
            cell = [[ScheduleCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:SCHEDULE_CELL_IDENTIFIER];
        }
        
        cell.scheduleDelegate = self;
        
        if (indexPath.row == 2) {
            [cell bind:ScheduleTypeStart date:self.scheduleStartDate time:self.scheduleStartTime];
        } else {
            [cell bind:ScheduleTypeEnd date:self.scheduleEndDate time:self.scheduleEndTime];
        }
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
        
        [cell bindWithTitle:nil value:value backgroundColor:Design.WHITE_COLOR];
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

        [cell bindWithTitle:title icon:nil stateSwitch:switchState tagSwitch:tag hiddenSwitch:hiddenSwitch disableSwitch:NO backgroundColor:Design.WHITE_COLOR hiddenSeparator:NO];
        
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

#pragma mark - ScheduleDelegate

- (void)scheduleDate:(ScheduleType)scheduleType {
    DDLogVerbose(@"%@ scheduleDate", LOG_TAG);
    
    if (scheduleType == ScheduleTypeStart) {
        NSDate *date = [NSDate date];
        if (self.scheduleStartDate) {
            NSDateComponents *startDateComponents = [[NSDateComponents alloc] init];
            startDateComponents.day = self.scheduleStartDate.day;
            startDateComponents.month = self.scheduleStartDate.month;
            startDateComponents.year = self.scheduleStartDate.year;
            startDateComponents.hour = self.scheduleStartTime.hour;
            startDateComponents.minute = self.scheduleStartTime.minute;
            
            NSCalendar *calendar = [NSCalendar currentCalendar];
            date = [calendar dateFromComponents:startDateComponents];
        }
        
        [self openMenuDateTime:date minimumDate:[NSDate date] menuDateTimeType:MenuDateTimeTypeStartDate];
    } else {
        if (self.scheduleStartDate) {
            NSDateComponents *startDateComponents = [[NSDateComponents alloc] init];
            startDateComponents.day = self.scheduleStartDate.day;
            startDateComponents.month = self.scheduleStartDate.month;
            startDateComponents.year = self.scheduleStartDate.year;
            startDateComponents.hour = self.scheduleStartTime.hour;
            startDateComponents.minute = self.scheduleStartTime.minute;
            
            NSCalendar *calendar = [NSCalendar currentCalendar];
            NSDate *minimumDate = [calendar dateFromComponents:startDateComponents];
            
            NSDate *date = [minimumDate dateByAddingTimeInterval:3600];
            if (self.scheduleEndDate) {
                NSDateComponents *startEndComponents = [[NSDateComponents alloc] init];
                startEndComponents.day = self.scheduleEndDate.day;
                startEndComponents.month = self.scheduleEndDate.month;
                startEndComponents.year = self.scheduleEndDate.year;
                startEndComponents.hour = self.scheduleEndTime.hour;
                startEndComponents.minute = self.scheduleEndTime.minute;
                
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
        if (self.scheduleStartDate) {
            NSDateComponents *startDateComponents = [[NSDateComponents alloc] init];
            startDateComponents.day = self.scheduleStartDate.day;
            startDateComponents.month = self.scheduleStartDate.month;
            startDateComponents.year = self.scheduleStartDate.year;
            startDateComponents.hour = self.scheduleStartTime.hour;
            startDateComponents.minute = self.scheduleStartTime.minute;
            
            NSCalendar *calendar = [NSCalendar currentCalendar];
            date = [calendar dateFromComponents:startDateComponents];
        }
        
        [self openMenuDateTime:date minimumDate:[NSDate date] menuDateTimeType:MenuDateTimeTypeStartHour];
    } else {
        if (self.scheduleStartDate) {
            NSDateComponents *startDateComponents = [[NSDateComponents alloc] init];
            startDateComponents.day = self.scheduleStartDate.day;
            startDateComponents.month = self.scheduleStartDate.month;
            startDateComponents.year = self.scheduleStartDate.year;
            startDateComponents.hour = self.scheduleStartTime.hour;
            startDateComponents.minute = self.scheduleStartTime.minute;
            
            NSCalendar *calendar = [NSCalendar currentCalendar];
            NSDate *minimumDate = [calendar dateFromComponents:startDateComponents];
            
            NSDate *date = [minimumDate dateByAddingTimeInterval:3600];
            if (self.scheduleEndDate) {
                NSDateComponents *startEndComponents = [[NSDateComponents alloc] init];
                startEndComponents.day = self.scheduleEndDate.day;
                startEndComponents.month = self.scheduleEndDate.month;
                startEndComponents.year = self.scheduleEndDate.year;
                startEndComponents.hour = self.scheduleEndTime.hour;
                startEndComponents.minute = self.scheduleEndTime.minute;
                
                date = [calendar dateFromComponents:startEndComponents];
            }
        
            [self openMenuDateTime:date minimumDate:minimumDate menuDateTimeType:MenuDateTimeTypeEndHour];
        } else {
            [self openMenuDateTime:[NSDate date] minimumDate:[NSDate date] menuDateTimeType:MenuDateTimeTypeEndHour];
        }
    }
}

#pragma mark - MenuDateTimeDelegate

- (void)menuDateTimeDidClosed:(MenuDateTimeView *)menuDateTimeView menuDateTimeType:(MenuDateTimeType)menuDateTimeType date:(NSDate *)date {
    DDLogVerbose(@"%@ menuDateTimeDidClosed", LOG_TAG);
    
    [menuDateTimeView removeFromSuperview];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSCalendarUnit calendarUnit = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute;
    NSDateComponents *dateComponents = [calendar components:calendarUnit fromDate:date];
    
    if (menuDateTimeType == MenuDateTimeTypeStartDate || menuDateTimeType == MenuDateTimeTypeStartHour) {
        self.scheduleStartDate = [[TLDate alloc]initWithYear:(int)dateComponents.year month:(int)dateComponents.month day:(int)dateComponents.day];
        self.scheduleStartTime = [[TLTime alloc]initWithHour:(int)dateComponents.hour minute:(int)dateComponents.minute];
    } else if (menuDateTimeType == MenuDateTimeTypeEndDate || menuDateTimeType == MenuDateTimeTypeEndHour) {
        self.scheduleEndDate = [[TLDate alloc]initWithYear:(int)dateComponents.year month:(int)dateComponents.month day:(int)dateComponents.day];
        self.scheduleEndTime = [[TLTime alloc]initWithHour:(int)dateComponents.hour minute:(int)dateComponents.minute];
    }
    
    if ([self.scheduleStartDate compare:self.scheduleEndDate] ==  NSOrderedDescending) {
        NSDateComponents *startDateComponents = [[NSDateComponents alloc] init];
        startDateComponents.day = self.scheduleStartDate.day;
        startDateComponents.month = self.scheduleStartDate.month;
        startDateComponents.year = self.scheduleStartDate.year;
        startDateComponents.hour = self.scheduleStartTime.hour;
        startDateComponents.minute = self.scheduleStartTime.minute;
        
        NSDate *startDate = [calendar dateFromComponents:startDateComponents];
        NSDate *endDate = [calendar dateByAddingUnit:NSCalendarUnitHour value:1 toDate:startDate options:NSCalendarWrapComponents];
        dateComponents = [calendar components:calendarUnit fromDate:endDate];
        self.scheduleEndDate = [[TLDate alloc]initWithYear:(int)dateComponents.year month:(int)dateComponents.month day:(int)dateComponents.day];
        self.scheduleEndTime = [[TLTime alloc]initWithHour:(int)dateComponents.hour minute:(int)dateComponents.minute];
    }
    
    [self.tableView reloadData];
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
        InAppSubscriptionViewController *inAppSubscriptionViewController = [[UIStoryboard storyboardWithName:@"iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"InAppSubscriptionViewController"];
        TwinmeNavigationController *navigationController = [[TwinmeNavigationController alloc]initWithRootViewController:inAppSubscriptionViewController];
        [self.navigationController presentViewController:navigationController animated:YES completion:nil];
    } else {
        ApplicationDelegate *delegate = (ApplicationDelegate *)[[UIApplication sharedApplication] delegate];
        if (!abstractConfirmView.cancelView.hidden) {
            if (![delegate.twinmeApplication isSubscribedWithFeature:TLTwinmeApplicationFeatureGroupCall]) {
                [self showPremiumFeature:FeatureTypeRemoteControl];
            } else {
                [self openMenuSelectValue];
            }
        }
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
    [self.tableView registerNib:[UINib nibWithNibName:@"ScheduleCell" bundle:nil] forCellReuseIdentifier:SCHEDULE_CELL_IDENTIFIER];
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

- (void)reloadData {
    DDLogVerbose(@"%@ reloadData ", LOG_TAG);
    
    [self.tableView reloadData];
}

- (void)initSchedule {
    DDLogVerbose(@"%@ initSchedule", LOG_TAG);
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSCalendarUnit calendarUnit = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute;
    NSDate *date = [NSDate date];
    NSDateComponents *dateComponents = [calendar components:calendarUnit fromDate:date];
    self.scheduleStartDate = [[TLDate alloc]initWithYear:(int)dateComponents.year month:(int)dateComponents.month day:(int)dateComponents.day];
    
    date = [calendar dateByAddingUnit:NSCalendarUnitHour value:1 toDate:date options:NSCalendarWrapComponents];
    dateComponents = [calendar components:calendarUnit fromDate:date];
    self.scheduleStartTime = [[TLTime alloc]initWithHour:(int)dateComponents.hour minute:0];
    
    date = [calendar dateByAddingUnit:NSCalendarUnitHour value:1 toDate:date options:NSCalendarWrapComponents];
    dateComponents = [calendar components:calendarUnit fromDate:date];
    self.scheduleEndDate = [[TLDate alloc]initWithYear:(int)dateComponents.year month:(int)dateComponents.month day:(int)dateComponents.day];
    self.scheduleEndTime = [[TLTime alloc]initWithHour:(int)dateComponents.hour minute:0];
}

- (void)openMenuDateTime:(NSDate *)date minimumDate:(NSDate *)minimumDate menuDateTimeType:(MenuDateTimeType)menuDateTimeType {
    DDLogVerbose(@"%@ openMenuDateTime", LOG_TAG);
    
    MenuDateTimeView *menuDateTimeView = [[MenuDateTimeView alloc]init];
    menuDateTimeView.menuDateTimeViewDelegate = self;
    [self.tabBarController.view addSubview:menuDateTimeView];
    
    [menuDateTimeView setMenuDateTimeTypeWithType:menuDateTimeType];
    [menuDateTimeView openMenu:minimumDate date:date];
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
        ApplicationDelegate *delegate = (ApplicationDelegate *)[[UIApplication sharedApplication] delegate];
        if (![delegate.twinmeApplication isSubscribedWithFeature:TLTwinmeApplicationFeatureGroupCall]) {
            [self showPremiumFeature:FeatureTypeRemoteControl];
        } else {
            [self openMenuSelectValue];
        }
    }
}
    
- (void)showPremiumFeature:(FeatureType)featureType {
    DDLogVerbose(@"%@ showPremiumFeature", LOG_TAG);
    
    PremiumFeatureConfirmView *premiumFeatureConfirmView = [[PremiumFeatureConfirmView alloc] init];
    premiumFeatureConfirmView.confirmViewDelegate = self;
    [premiumFeatureConfirmView initWithPremiumFeature:[[UIPremiumFeature alloc]initWithFeatureType:featureType spaceSettings:self.currentSpaceSettings] parentViewController:self.navigationController];
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
