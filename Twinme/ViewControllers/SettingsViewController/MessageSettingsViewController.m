/*
 *  Copyright (c) 2020-2022 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <Twinme/TLSpaceSettings.h>

#import <Twinlife/TLAccountService.h>

#import <Utils/NSString+Utils.h>

#import "MessageSettingsViewController.h"

#import "SettingsItemCell.h"
#import "SettingsInformationCell.h"
#import "SettingsSectionHeaderCell.h"
#import "SettingsValueItemCell.h"
#import "TwinmeSettingsItemCell.h"

#import <TwinmeCommon/SpaceSettingsService.h>

#import "SpaceSetting.h"
#import <TwinmeCommon/Design.h>
#import <TwinmeCommon/NotificationSound.h>

#import "SelectNotificationSoundViewController.h"
#import "SwitchView.h"
#import "UITimeout.h"
#import "AlertView.h"
#import "MenuSelectValueView.h"

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static NSString *SETTINGS_CELL_IDENTIFIER = @"SettingsCellIdentifier";
static NSString *SETTINGS_VALUE_CELL_IDENTIFIER = @"SettingsValueCellIdentifier";
static NSString *SETTINGS_INFORMATION_CELL_IDENTIFIER = @"SettingsInformationCellIdentifier";
static NSString *HEADER_SETTINGS_CELL_IDENTIFIER = @"HeaderSettingsCellIdentifier";
static NSString *TWINME_SETTINGS_CELL_IDENTIFIER = @"TwinmeSettingsCellIdentifier";

//
// Interface: MessageSettingsViewController ()
//

@interface MessageSettingsViewController () <SettingsActionDelegate, SpaceSettingsServiceDelegate, AlertViewDelegate, MenuSelectValueDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic) SpaceSettingsService *spaceSettingsService;
@property (nonatomic) TLSpaceSettings *defaultSpaceSettings;

@end

typedef enum {
    SECTION_INFO,
    SECTION_NOTIFICATION,
    SECTION_ALLOW_COPY,
    SECTION_CALLS,
    SECTION_EPHEMERAL,
    SECTION_CONTENT,
    SECTION_LINK,
    SECTION_COUNT
} TLTSettingSection;

typedef enum {
    TAG_DISPLAY_NOTIFCATION_SENDER,
    TAG_DISPLAY_NOTIFCATION_CONTENT,
    TAG_DISPLAY_NOTIFCATION_LIKE,
    TAG_ALLOW_COPY_TEXT,
    TAG_ALLOW_COPY_FILE,
    TAG_ALLOW_COPY_INFORMATION,
    TAG_EPHEMERAL_MESSAGE,
    TAG_EPHEMERAL_MESSAGE_INFORMATION,
    TAG_LINK_PREVIEW
} TLTSettingTag;

//
// Implementation: MessageSettingsViewController
//

#undef LOG_TAG
#define LOG_TAG @"MessageSettingsViewController"

@implementation MessageSettingsViewController

- (void)viewDidLoad {
    DDLogVerbose(@"%@ viewDidLoad", LOG_TAG);
    
    [super viewDidLoad];
    
    self.spaceSettingsService = [[SpaceSettingsService alloc]initWithTwinmeContext:self.twinmeContext delegate:self];
    self.defaultSpaceSettings = [self.twinmeContext defaultSpaceSettings];
    
    [self initViews];
}

- (void)viewWillAppear:(BOOL)animated {
    DDLogVerbose(@"%@ viewWillAppear: %@", LOG_TAG, animated ? @"YES" : @"NO");
    
    [super viewWillAppear:animated];
    
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

#pragma mark - SpaceSettingsServiceDelegate

- (void)onUpdateSpaceDefaultSettings:(TLSpaceSettings *)spaceSettings {
    DDLogVerbose(@"%@ onUpdateSpaceDefaultSettings: %@", LOG_TAG, spaceSettings);
    
    self.defaultSpaceSettings = spaceSettings;
    [self.tableView reloadData];
}

#pragma mark - SettingsActionDelegate

- (void)switchChangeValue:(SwitchView *)updatedSwitch {
    DDLogVerbose(@"%@ switchChangeValue: %@", LOG_TAG, updatedSwitch);
    
    switch (updatedSwitch.tag) {
        case TAG_DISPLAY_NOTIFCATION_SENDER:
            [self.twinmeApplication setDisplayNotificationSenderWithState:updatedSwitch.isOn];
            break;
            
        case TAG_DISPLAY_NOTIFCATION_CONTENT:
            [self.twinmeApplication setDisplayNotificationContentWithState:updatedSwitch.isOn];
            break;
            
        case TAG_DISPLAY_NOTIFCATION_LIKE:
            [self.twinmeApplication setDisplayNotificationLikeWithState:updatedSwitch.isOn];
            break;
            
        case TAG_ALLOW_COPY_TEXT:
            [self.defaultSpaceSettings setMessageCopyAllowed:updatedSwitch.isOn];
            break;
            
        case TAG_ALLOW_COPY_FILE:
            [self.defaultSpaceSettings setFileCopyAllowed:updatedSwitch.isOn];
            break;
            
        case TAG_EPHEMERAL_MESSAGE:
            [self.defaultSpaceSettings setBooleanWithName:PROPERTY_ALLOW_EPHEMERAL_MESSAGE value:updatedSwitch.isOn];
            break;
            
        case TAG_LINK_PREVIEW:
            [self.twinmeApplication setVisualizationLinkWithState:updatedSwitch.isOn];
            break;
            
        default:
            break;
    }
    
    [self saveDefaultSpaceSettings];
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
    
    if (section == SECTION_INFO) {
        return CGFLOAT_MIN;
    } else if (section == SECTION_LINK) {
        if (@available(iOS 13.0, *)) {
            return Design.SETTING_SECTION_HEIGHT;
        }
        
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
    
    SettingsSectionHeaderCell *settingsSectionHeaderCell = (SettingsSectionHeaderCell *)[tableView dequeueReusableCellWithIdentifier:HEADER_SETTINGS_CELL_IDENTIFIER];
    if (!settingsSectionHeaderCell) {
        settingsSectionHeaderCell = [[SettingsSectionHeaderCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:HEADER_SETTINGS_CELL_IDENTIFIER];
    }
    
    NSString *sectionName = @"";
    BOOL hideSeparator = NO;
    switch (section) {
        case SECTION_NOTIFICATION:
            sectionName = TwinmeLocalizedString(@"settings_view_controller_system_notifications_title", nil);
            break;
            
        case SECTION_ALLOW_COPY:
            sectionName = TwinmeLocalizedString(@"settings_view_controller_permissions_title", nil);
            hideSeparator = YES;
            break;
            
        case SECTION_CALLS:
            sectionName = TwinmeLocalizedString(@"history_view_controller_title", nil).uppercaseString;;
            hideSeparator = YES;
            break;
            
        case SECTION_EPHEMERAL:
            sectionName = [NSString stringWithFormat:@"%@", TwinmeLocalizedString(@"settings_view_controller_ephemeral_section_title", nil)];
            hideSeparator = YES;
            break;
            
        case SECTION_CONTENT:
            sectionName = TwinmeLocalizedString(@"settings_view_controller_content_title", nil).uppercaseString;
            hideSeparator = YES;
            break;
            
        case SECTION_LINK:
            sectionName = TwinmeLocalizedString(@"conversation_settings_view_controller_link_title", nil).uppercaseString;;
            hideSeparator = YES;
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
    
    NSInteger numberOfRowsInSection;
    switch (section) {
        case SECTION_INFO:
            numberOfRowsInSection = 1;
            break;
            
        case SECTION_NOTIFICATION:
            numberOfRowsInSection = 3;
            break;
            
        case SECTION_ALLOW_COPY:
            numberOfRowsInSection = 3;
            break;
            
        case SECTION_EPHEMERAL: {
            BOOL allowEphemeral = [self.defaultSpaceSettings getBooleanWithName:PROPERTY_ALLOW_EPHEMERAL_MESSAGE defaultValue:NO];
            if (allowEphemeral) {
                numberOfRowsInSection = 3;
            } else {
                numberOfRowsInSection = 2;
            }
            break;
        }

        case SECTION_CALLS:
            numberOfRowsInSection = 2;
            break;
            
        case SECTION_CONTENT:
            numberOfRowsInSection = 3;
            break;
            
        case SECTION_LINK:
            if (@available(iOS 13.0, *)) {
                numberOfRowsInSection = 2;
            } else {
                numberOfRowsInSection = 0;
            }
            
            break;
            
        default:
            numberOfRowsInSection = 0;
            break;
    }
    return numberOfRowsInSection;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ cellForRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    if ([self isInformationPath:indexPath]) {
        SettingsInformationCell *cell = [tableView dequeueReusableCellWithIdentifier:SETTINGS_INFORMATION_CELL_IDENTIFIER];
        if (!cell) {
            cell = [[SettingsInformationCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:SETTINGS_INFORMATION_CELL_IDENTIFIER];
        }
        
        NSString *text = @"";
        if (indexPath.section == SECTION_INFO) {
            text = TwinmeLocalizedString(@"settings_view_controller_default_value_message", nil);
        } else if (indexPath.section == SECTION_ALLOW_COPY) {
            text = TwinmeLocalizedString(@"settings_view_controller_allow_copy_category_title", nil);
        } else if (indexPath.section == SECTION_CALLS) {
            text = TwinmeLocalizedString(@"settings_view_controller_display_call_title", nil);
        } else if (indexPath.section == SECTION_CONTENT) {
            text = TwinmeLocalizedString(@"settings_view_controller_content_information", nil);
        } else if (indexPath.section == SECTION_LINK) {
            text = TwinmeLocalizedString(@"conversation_settings_view_controller_link_preview_message", nil);
        } else {
            text = TwinmeLocalizedString(@"settings_view_controller_ephemeral_message", nil);
        }
        
        [cell bindWithText:text];
        
        return cell;
    } else if ((indexPath.section == SECTION_EPHEMERAL && indexPath.row == 2) || indexPath.section == SECTION_CONTENT || indexPath.section == SECTION_CALLS) {
        SettingsValueItemCell *cell = [tableView dequeueReusableCellWithIdentifier:SETTINGS_VALUE_CELL_IDENTIFIER];
        if (!cell) {
            cell = [[SettingsValueItemCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:SETTINGS_VALUE_CELL_IDENTIFIER];
        }
        
        NSString *title;
        NSString *value;
        
        if (indexPath.section == SECTION_CONTENT) {
            if (indexPath.row == 1) {
                title = TwinmeLocalizedString(@"settings_view_controller_image_title", nil);
                
                if ([self.twinmeApplication sendImageSize] == SendImageSizeSmall) {
                    value = TwinmeLocalizedString(@"conversation_view_controller_reduce_menu_minimal", nil);
                } else if ([self.twinmeApplication sendImageSize] == SendImageSizeMedium) {
                    value = TwinmeLocalizedString(@"conversation_view_controller_reduce_menu_lower", nil);
                } else {
                    value = TwinmeLocalizedString(@"conversation_view_controller_reduce_menu_original", nil);
                }
            } else {
                title = TwinmeLocalizedString(@"show_contact_view_controller_video", nil);
                if ([self.twinmeApplication sendVideoSize] == SendVideoSizeLower) {
                    value = TwinmeLocalizedString(@"conversation_view_controller_reduce_menu_minimal", nil);
                } else {
                    value = TwinmeLocalizedString(@"conversation_view_controller_reduce_menu_original", nil);
                }
            }
            [cell bindWithTitle:title value:value backgroundColor:Design.WHITE_COLOR];
        } else if (indexPath.section == SECTION_CALLS) {
            title = TwinmeLocalizedString(@"settings_view_controller_display_call_title", nil);
            
            if ([self.twinmeApplication displayCallsMode] == TLDisplayCallsModeNone) {
                value = TwinmeLocalizedString(@"settings_view_controller_display_call_none", nil);;
            } else if ([self.twinmeApplication displayCallsMode] == TLDisplayCallsModeMissed) {
                value = TwinmeLocalizedString(@"history_view_controller_missed_call_segmented_control", nil);
            } else {
                value = TwinmeLocalizedString(@"history_view_controller_all_call_segmented_control", nil);;
            }
            [cell bindWithTitle:title value:value backgroundColor:Design.WHITE_COLOR];
        } else {
            NSString *expireTimeoutStringValue = [self.defaultSpaceSettings getStringWithName:PROPERTY_TIMEOUT_EPHEMERAL_MESSAGE defaultValue:[NSString stringWithFormat:@"%d", DEFAULT_TIMEOUT_MESSAGE]];
            NSInteger expireTimeout = [expireTimeoutStringValue integerValue];
            [cell bindWithTitle:TwinmeLocalizedString(@"application_timeout", nil) value:[NSString formatTimeout:expireTimeout] hiddenAccessory:YES];
        }
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
            case SECTION_NOTIFICATION:
                if (indexPath.row == 0) {
                    if ([self.twinmeApplication hasDisplayNotificationSender]) {
                        switchState = YES;
                    } else {
                        switchState = NO;
                    }
                    hiddenSwitch = NO;
                    tag = TAG_DISPLAY_NOTIFCATION_SENDER;
                    title = TwinmeLocalizedString(@"settings_view_controller_display_notification_sender_title", nil);
                } else if (indexPath.row == 1) {
                    if ([self.twinmeApplication hasDisplayNotificationContent]) {
                        switchState = YES;
                    } else {
                        switchState = NO;
                    }
                    hiddenSwitch = NO;
                    tag = TAG_DISPLAY_NOTIFCATION_CONTENT;
                    title = TwinmeLocalizedString(@"settings_view_controller_display_notification_content_title", nil);
                } else if (indexPath.row == 2) {
                    if ([self.twinmeApplication hasDisplayNotificationLike]) {
                        switchState = YES;
                    } else {
                        switchState = NO;
                    }
                    hiddenSwitch = NO;
                    tag = TAG_DISPLAY_NOTIFCATION_LIKE;
                    title = TwinmeLocalizedString(@"settings_view_controller_display_notification_like_title", nil);
                }
                break;
                
            case SECTION_ALLOW_COPY:
                if (indexPath.row == 1) {
                    if ([self.defaultSpaceSettings messageCopyAllowed]) {
                        switchState = YES;
                    } else {
                        switchState = NO;
                    }
                    hiddenSwitch = NO;
                    tag = TAG_ALLOW_COPY_TEXT;
                    title = TwinmeLocalizedString(@"settings_view_controller_allow_copy_text_title", nil);
                } else if (indexPath.row == 2) {
                    if ([self.defaultSpaceSettings fileCopyAllowed]) {
                        switchState = YES;
                    } else {
                        switchState = NO;
                    }
                    hiddenSwitch = NO;
                    tag = TAG_ALLOW_COPY_FILE;
                    title = TwinmeLocalizedString(@"settings_view_controller_allow_copy_file_title", nil);
                }
                break;
                
            case SECTION_EPHEMERAL:
                if (indexPath.row == 1) {
                    BOOL allowEphemeral = [self.defaultSpaceSettings getBooleanWithName:PROPERTY_ALLOW_EPHEMERAL_MESSAGE defaultValue:NO];
                    switchState = allowEphemeral;
                    hiddenSwitch = NO;
                    tag = TAG_EPHEMERAL_MESSAGE;
                    title = TwinmeLocalizedString(@"settings_view_controller_ephemeral_title", nil);
                }
                break;
                
            case SECTION_LINK:
                switchState =  self.twinmeApplication.visualizationLink;
                hiddenSwitch = NO;
                tag = TAG_LINK_PREVIEW;
                title = TwinmeLocalizedString(@"conversation_settings_view_controller_link_preview", nil);
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
    
    BOOL allowEphemeral = [self.defaultSpaceSettings getBooleanWithName:PROPERTY_ALLOW_EPHEMERAL_MESSAGE defaultValue:NO];
    if (indexPath.section == SECTION_EPHEMERAL && allowEphemeral && indexPath.row == 2) {
        [self openMenuSelectValue:MenuSelectValueTypeTimeoutEphemeralMessage];
    } else if (indexPath.section == SECTION_CONTENT) {
        if (indexPath.row == 1) {
            [self openMenuSelectValue:MenuSelectValueTypeImageSize];
        } else if (indexPath.row == 2) {
            [self openMenuSelectValue:MenuSelectValueTypeVideoSize];
        }
    } else if (indexPath.section == SECTION_CALLS) {
        [self openMenuSelectValue:MenuSelectValueTypeDisplayCallsMode];
    }
}

#pragma mark - MenuSelectValueDelegate

- (void)cancelMenuSelectValue:(MenuSelectValueView *)menuSelectValueView {
    DDLogVerbose(@"%@ cancelMenu", LOG_TAG);
    
    [menuSelectValueView removeFromSuperview];
}

- (void)selectValue:(MenuSelectValueView *)menuSelectValueView value:(int)value {
    DDLogVerbose(@"%@ selectValue: %d", LOG_TAG, value);

    [menuSelectValueView removeFromSuperview];
    
    if (menuSelectValueView.menuSelectValueType == MenuSelectValueTypeImageSize) {
        [self.twinmeApplication setSendImageSizeWithSize:value];
    } else if (menuSelectValueView.menuSelectValueType == MenuSelectValueTypeVideoSize) {
        [self.twinmeApplication setSendVideoSizeWithSize:value];
    } else {
        [self.twinmeApplication setDisplayCallsModeWithMode:value];
    }
    
    [self.tableView reloadData];
}

- (void)selectTimeout:(MenuSelectValueView *)menuSelectValueView uiTimeout:(UITimeout *)uiTimeout {
    DDLogVerbose(@"%@ selectTimeout: %@", LOG_TAG, uiTimeout);
    
    [menuSelectValueView removeFromSuperview];
    
    [self.defaultSpaceSettings setStringWithName:PROPERTY_TIMEOUT_EPHEMERAL_MESSAGE value:[NSString stringWithFormat:@"%lld", uiTimeout.timeout]];
    
    [self saveDefaultSpaceSettings];
}

#pragma mark - Private methods

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    self.view.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
    
    [self setNavigationTitle:TwinmeLocalizedString(@"settings_view_controller_chat_category_title", nil)];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = Design.SETTING_CELL_HEIGHT * Design.HEIGHT_RATIO;
    [self.tableView registerNib:[UINib nibWithNibName:@"SettingsItemCell" bundle:nil] forCellReuseIdentifier:SETTINGS_CELL_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"SettingsSectionHeaderCell" bundle:nil] forCellReuseIdentifier:HEADER_SETTINGS_CELL_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"SettingsInformationCell" bundle:nil] forCellReuseIdentifier:SETTINGS_INFORMATION_CELL_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"SettingsValueItemCell" bundle:nil] forCellReuseIdentifier:SETTINGS_VALUE_CELL_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"TwinmeSettingsItemCell" bundle:nil] forCellReuseIdentifier:TWINME_SETTINGS_CELL_IDENTIFIER];
    self.tableView.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
}

- (void)finish {
    DDLogVerbose(@"%@ finish", LOG_TAG);
    
    [self.spaceSettingsService dispose];
}

- (void)saveDefaultSpaceSettings {
    DDLogVerbose(@"%@ saveDefaultSpaceSettings", LOG_TAG);
    
    [self.spaceSettingsService updateDefaultSpaceSettings:self.defaultSpaceSettings];
}

- (void)openMenuSelectValue:(MenuSelectValueType)menuSelectValueType {
    DDLogVerbose(@"%@ openMenuSelectValue", LOG_TAG);
    
    MenuSelectValueView *menuSelectValueView = [[MenuSelectValueView alloc]init];
    menuSelectValueView.menuSelectValueDelegate = self;
    [self.tabBarController.view addSubview:menuSelectValueView];
    [menuSelectValueView setMenuSelectValueTypeWithType:menuSelectValueType];
    
    if (menuSelectValueType == MenuSelectValueTypeTimeoutEphemeralMessage) {
        NSString *expireTimeoutStringValue = [self.defaultSpaceSettings getStringWithName:PROPERTY_TIMEOUT_EPHEMERAL_MESSAGE defaultValue:[NSString stringWithFormat:@"%d", DEFAULT_TIMEOUT_MESSAGE]];
        int expireTimeout = [expireTimeoutStringValue intValue];
        [menuSelectValueView setSelectedValueWithValue:expireTimeout];
    }
    
    [menuSelectValueView openMenu];
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    self.tableView.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    [self.tableView reloadData];
}

- (BOOL)isInformationPath:(NSIndexPath *)indexPath {
    
    if ((indexPath.section == SECTION_INFO || indexPath.section == SECTION_ALLOW_COPY || indexPath.section == SECTION_EPHEMERAL || indexPath.section == SECTION_CONTENT || indexPath.section == SECTION_LINK) && indexPath.row == 0) {
        return YES;
    }
    
    return NO;
}

@end
