/*
 *  Copyright (c) 2020-2021 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <Twinlife/TLAccountService.h>

#import <Utils/NSString+Utils.h>

#import "SoundSettingsViewController.h"
#import "MessageSettingsViewController.h"
#import "SettingsItemCell.h"
#import "SettingsSectionHeaderCell.h"
#import "TwinmeSettingsItemCell.h"

#import <TwinmeCommon/Design.h>
#import <TwinmeCommon/NotificationSound.h>
#import "SelectNotificationSoundViewController.h"
#import "SwitchView.h"

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static NSString *SETTINGS_CELL_IDENTIFIER = @"SettingsCellIdentifier";
static NSString *HEADER_SETTINGS_CELL_IDENTIFIER = @"HeaderSettingsCellIdentifier";
static NSString *TWINME_SETTINGS_CELL_IDENTIFIER = @"TwinmeSettingsCellIdentifier";

//
// Interface: SoundSettingsViewController ()
//

@interface SoundSettingsViewController () <SettingsActionDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

typedef enum {
    SECTION_SOUNDS,
    SECTION_CHAT,
    SECTION_AUDIO_CALL,
    SECTION_VIDEO_CALL,
    SECTION_COUNT
} TLTSoundSettingSection;

typedef enum {
    TAG_SOUND_ENABLE,
    TAG_CHAT_NOTIFICATION,
    TAG_CHAT_VIBRATION,
    TAG_AUDIO_CALL_NOTIFICATION,
    TAG_AUDIO_CALL_VIBRATION,
    TAG_VIDEO_CALL_NOTIFICATION,
    TAG_VIDEO_CALL_VIBRATION
} TLTSoundSettingTag;

//
// Implementation: SoundSettingsViewController
//

#undef LOG_TAG
#define LOG_TAG @"SoundSettingsViewController"

@implementation SoundSettingsViewController

- (void)viewDidLoad {
    DDLogVerbose(@"%@ viewDidLoad", LOG_TAG);
    
    [super viewDidLoad];
    
    [self initViews];
}

- (void)viewWillAppear:(BOOL)animated {
    DDLogVerbose(@"%@ viewWillAppear: %@", LOG_TAG, animated ? @"YES" : @"NO");
    
    [super viewWillAppear:animated];
    
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

#pragma mark - SettingsActionDelegate

- (void)switchChangeValue:(SwitchView *)updatedSwitch {
    DDLogVerbose(@"%@ switchChangeValue: %@", LOG_TAG, updatedSwitch);
    
    switch (updatedSwitch.tag) {
        case TAG_SOUND_ENABLE:
            [self.twinmeApplication setSoundEnableWithState:updatedSwitch.isOn];
            break;
            
        case TAG_CHAT_VIBRATION:
            [self.twinmeApplication setVibrationWithType:NotificationSoundTypeNotification state:updatedSwitch.isOn];
            break;
            
        case TAG_CHAT_NOTIFICATION:
            [self.twinmeApplication setNotificationSoundWithType:NotificationSoundTypeNotification state:updatedSwitch.isOn];
            break;
            
        case TAG_AUDIO_CALL_NOTIFICATION:
            [self.twinmeApplication setNotificationSoundWithType:NotificationSoundTypeAudioCall state:updatedSwitch.isOn];
            break;
            
        case TAG_AUDIO_CALL_VIBRATION:
            [self.twinmeApplication setVibrationWithType:NotificationSoundTypeAudioCall state:updatedSwitch.isOn];
            break;
            
        case TAG_VIDEO_CALL_NOTIFICATION:
            [self.twinmeApplication setNotificationSoundWithType:NotificationSoundTypeVideoCall state:updatedSwitch.isOn];
            break;
            
        case TAG_VIDEO_CALL_VIBRATION:
            [self.twinmeApplication setVibrationWithType:NotificationSoundTypeVideoCall state:updatedSwitch.isOn];
            break;
            
        default:
            break;
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    DDLogVerbose(@"%@ numberOfSectionsInTableView: %@", LOG_TAG, tableView);
    
    return SECTION_COUNT;
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
    
    return CGFLOAT_MIN;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ viewForHeaderInSection: %ld", LOG_TAG, tableView, (long)section);
    
    SettingsSectionHeaderCell *settingsSectionHeaderCell = (SettingsSectionHeaderCell *)[tableView dequeueReusableCellWithIdentifier:HEADER_SETTINGS_CELL_IDENTIFIER];
    if (!settingsSectionHeaderCell) {
        settingsSectionHeaderCell = [[SettingsSectionHeaderCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:HEADER_SETTINGS_CELL_IDENTIFIER];
    }
    
    NSString *sectionName = @"";
    switch (section) {
        case SECTION_SOUNDS:
            sectionName = TwinmeLocalizedString(@"settings_view_controller_sound_enabled_title", nil).capitalizedString;
            break;
            
        case SECTION_CHAT:
            sectionName = TwinmeLocalizedString(@"settings_view_controller_chat_category_title", nil);
            break;
            
        case SECTION_AUDIO_CALL:
            sectionName =  TwinmeLocalizedString(@"settings_view_controller_audio_call_category_title", nil);
            break;
            
        case SECTION_VIDEO_CALL:
            sectionName =  TwinmeLocalizedString(@"settings_view_controller_video_call_category_title", nil);
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
    
    NSInteger numberOfRowsInSection;
    switch (section) {
        case SECTION_SOUNDS:
            numberOfRowsInSection = 1;
            break;
            
        case SECTION_CHAT:
            numberOfRowsInSection = 3;
            break;
            
        case SECTION_AUDIO_CALL:
            numberOfRowsInSection = 3;
            break;
            
        case SECTION_VIDEO_CALL:
            numberOfRowsInSection = 3;
            break;
            
        default:
            numberOfRowsInSection = 0;
            break;
    }
    return numberOfRowsInSection;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ cellForRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    if (indexPath.row == 2) {
        TwinmeSettingsItemCell *cell = [tableView dequeueReusableCellWithIdentifier:TWINME_SETTINGS_CELL_IDENTIFIER];
        if (!cell) {
            cell = [[TwinmeSettingsItemCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:TWINME_SETTINGS_CELL_IDENTIFIER];
        }
        
        NSString *title = @"";        
        switch (indexPath.section) {
            case SECTION_CHAT:
                title = TwinmeLocalizedString(@"settings_view_controller_chat_ringtone_title", nil);
                break;
                
            case SECTION_AUDIO_CALL:
                title = TwinmeLocalizedString(@"settings_view_controller_audio_call_notification_ringtone_title", nil);
                break;
                
            case SECTION_VIDEO_CALL:
                title = TwinmeLocalizedString(@"settings_view_controller_video_call_notification_ringtone_title", nil);
                break;
                
            default:
                break;
        }
        
        [cell bindWithTitle:title hiddenAccessory:NO disableSetting:NO color:Design.FONT_COLOR_DEFAULT];
        
        return cell;
    }
    
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
        case SECTION_SOUNDS:
            title = TwinmeLocalizedString(@"settings_view_controller_sound_enabled_subtitle", nil);
            if ([self.twinmeApplication hasSoundEnable]) {
                switchState = YES;
            } else {
                switchState = NO;
            }
            hiddenSwitch = NO;
            tag= TAG_SOUND_ENABLE;
            break;
            
        case SECTION_CHAT:
            if (indexPath.row == 0) {
                if ([self.twinmeApplication hasVibrationWithType:NotificationSoundTypeNotification]) {
                    switchState = YES;
                } else {
                    switchState = NO;
                }
                hiddenSwitch = NO;
                tag = TAG_CHAT_VIBRATION;
                title = TwinmeLocalizedString(@"settings_view_controller_chat_vibration_title", nil);
            } else if (indexPath.row == 1) {
                if ([self.twinmeApplication hasNotificationSoundWithType:NotificationSoundTypeNotification]) {
                    switchState = YES;
                } else {
                    switchState = NO;
                }
                hiddenSwitch = NO;
                tag = TAG_CHAT_NOTIFICATION;
                title = TwinmeLocalizedString(@"settings_view_controller_chat_title", nil);
            }
            break;
            
        case SECTION_AUDIO_CALL:
            if (indexPath.row == 0) {
                if ([self.twinmeApplication hasVibrationWithType:NotificationSoundTypeAudioCall]) {
                    switchState = YES;
                } else {
                    switchState = NO;
                }
                hiddenSwitch = NO;
                tag = TAG_AUDIO_CALL_VIBRATION;
                title = TwinmeLocalizedString(@"settings_view_controller_audio_call_vibration_title", nil);
                
            } else if (indexPath.row == 1) {
                if ([self.twinmeApplication hasNotificationSoundWithType:NotificationSoundTypeAudioCall]) {
                    switchState = YES;
                } else {
                    switchState = NO;
                }
                hiddenSwitch = NO;
                tag = TAG_AUDIO_CALL_NOTIFICATION;
                title = TwinmeLocalizedString(@"settings_view_controller_audio_call_notification_title", nil);
                
            }
            break;
            
        case SECTION_VIDEO_CALL:
            if (indexPath.row == 0) {
                if ([self.twinmeApplication hasVibrationWithType:NotificationSoundTypeVideoCall]) {
                    switchState = YES;
                } else {
                    switchState = NO;
                }
                hiddenSwitch = NO;
                tag = TAG_VIDEO_CALL_VIBRATION;
                title = TwinmeLocalizedString(@"settings_view_controller_video_call_vibration_title", nil);
                
            } else if (indexPath.row == 1) {
                if ([self.twinmeApplication hasNotificationSoundWithType:NotificationSoundTypeVideoCall]) {
                    switchState = YES;
                } else {
                    switchState = NO;
                }
                hiddenSwitch = NO;
                tag = TAG_VIDEO_CALL_NOTIFICATION;
                title = TwinmeLocalizedString(@"settings_view_controller_video_call_notification_title", nil);
                
            }
            break;
            
        default:
            break;
    }
    
    [cell bindWithTitle:title icon:nil stateSwitch:switchState tagSwitch:tag hiddenSwitch:hiddenSwitch disableSwitch:NO backgroundColor:Design.WHITE_COLOR hiddenSeparator:NO];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ didSelectRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    SelectNotificationSoundViewController* selectNotificationSoundViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SelectNotificationSoundViewController"];
    
    switch (indexPath.section) {
        case SECTION_CHAT:
            if (indexPath.row == 2) {
                selectNotificationSoundViewController.notificationSoundType = NotificationSoundTypeNotification;
                [self.navigationController pushViewController:selectNotificationSoundViewController animated:YES];
            }
            break;
            
        case SECTION_AUDIO_CALL:
            if (indexPath.row == 2) {
                selectNotificationSoundViewController.notificationSoundType = NotificationSoundTypeAudioCall;
                [self.navigationController pushViewController:selectNotificationSoundViewController animated:YES];
            }
            break;
            
        case SECTION_VIDEO_CALL:
            if (indexPath.row == 2) {
                selectNotificationSoundViewController.notificationSoundType = NotificationSoundTypeVideoCall;
                [self.navigationController pushViewController:selectNotificationSoundViewController animated:YES];
            }
            break;
            
        default:
            break;
    }
}

#pragma mark - Private methods

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    self.view.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
    
    [self setNavigationTitle:TwinmeLocalizedString(@"application_notifications", nil)];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerNib:[UINib nibWithNibName:@"SettingsItemCell" bundle:nil] forCellReuseIdentifier:SETTINGS_CELL_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"SettingsSectionHeaderCell" bundle:nil] forCellReuseIdentifier:HEADER_SETTINGS_CELL_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"TwinmeSettingsItemCell" bundle:nil] forCellReuseIdentifier:TWINME_SETTINGS_CELL_IDENTIFIER];
    self.tableView.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    [self.tableView reloadData];
}

@end
