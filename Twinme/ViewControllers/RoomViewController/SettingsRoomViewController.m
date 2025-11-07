/*
 *  Copyright (c) 2021 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <Twinme/TLContact.h>
#import <Twinme/TLRoomConfig.h>

#import <Utils/NSString+Utils.h>

#import <TwinmeCommon/EditRoomService.h>

#import "MessageSettingsViewController.h"
#import "SettingsRoomViewController.h"
#import "SettingsItemCell.h"
#import "SettingsInformationCell.h"
#import "PersonalizationCell.h"

#import <TwinmeCommon/Design.h>
#import "SwitchView.h"

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static NSString *SETTINGS_CELL_IDENTIFIER = @"SettingsCellIdentifier";
static NSString *SETTINGS_VALUE_CELL_IDENTIFIER = @"SettingsValueCellIdentifier";
static NSString *SETTINGS_INFORMATION_CELL_IDENTIFIER = @"SettingsInformationCellIdentifier";
static NSString *PERSONALIZATION_CELL_IDENTIFIER = @"PersonalizationCellIdentifier";

static const CGFloat DESIGN_SECTION_HEIGHT = 100;

//
// Interface: SettingsRoomViewController ()
//

@interface SettingsRoomViewController () <SettingsActionDelegate, EditRoomServiceDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic) UIBarButtonItem *saveBarButtonItem;

@property (nonatomic) TLContact *room;
@property (nonatomic) TLRoomConfig *roomConfig;

@property (nonatomic) EditRoomService *editRoomService;

@property (nonatomic) BOOL allowInvitation;
@property (nonatomic) BOOL allowInvitationAsPersonalContact;
@property (nonatomic) TLInvitationMode invitationMode;
@property (nonatomic) TLCallMode callMode;
@property (nonatomic) TLChatMode chatMode;
@property (nonatomic) TLNotificationMode notificationMode;

@property (nonatomic) BOOL canSave;

@end

typedef enum {
    SECTION_PARTCIPANTS,
    SECTION_CHAT,
    SECTION_CALLS,
    SECTION_NOTIFICATIONS,
    SECTION_COUNT
} TLRoomSettingSection;

typedef enum {
    TAG_ALLOW_INVITATION,
    TAG_ALLOW_INVITATION_AS_PERSONAL_CONTACT,
    TAG_ALLOW_AUDIO_CALL,
    TAG_ALLOW_VIDEO_CALL
} TLRoomSettingTag;

//
// Implementation: SettingsRoomViewController
//

#undef LOG_TAG
#define LOG_TAG @"SettingsRoomViewController"

@implementation SettingsRoomViewController

- (instancetype)initWithCoder:(NSCoder *)coder {
    DDLogVerbose(@"%@ initWithCoder: %@", LOG_TAG, coder);
    
    self = [super initWithCoder:coder];
    
    if (self) {
        _allowInvitation = NO;
        _allowInvitationAsPersonalContact = NO;
        _invitationMode = TLInvitationModePublic;
        _chatMode = TLChatModePublic;
        _callMode = TLCallModeVideo;
        _notificationMode = TLNotificationModeInform;
        _canSave = NO;
        _editRoomService = [[EditRoomService alloc] initWithTwinmeContext:self.twinmeContext delegate:self];
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
}

- (void)initWithRoom:(TLContact *)room {
    DDLogVerbose(@"%@ initWithRoom: %@", LOG_TAG, room);
    
    self.room = room;
    
    [self.editRoomService getRoomConfig:room];
}

#pragma mark - EditRoomServiceDelegate

- (void)onGetRoomConfig:(nonnull TLRoomConfig *)roomConfig {
    DDLogVerbose(@"%@ onGetRoomConfig: %@", LOG_TAG, roomConfig);
    
    self.roomConfig = roomConfig;
    
    if (!self.roomConfig) {
        self.roomConfig = [[TLRoomConfig alloc]init];
    }
    
    self.invitationMode = self.roomConfig.invitationMode;
    self.chatMode = self.roomConfig.chatMode;
    self.callMode = self.roomConfig.callMode;
    self.notificationMode = self.roomConfig.notificationMode;
    
    [self.tableView reloadData];
}

- (void)onGetRoomConfigNotFound {
    DDLogVerbose(@"%@ onGetRoomConfigNotFound", LOG_TAG);
    
    self.roomConfig = [[TLRoomConfig alloc]init];
    self.invitationMode = self.roomConfig.invitationMode;
    self.chatMode = self.roomConfig.chatMode;
    self.callMode = self.roomConfig.callMode;
    self.notificationMode = self.roomConfig.notificationMode;
    
    [self.tableView reloadData];
}

- (void)onUpdateRoom:(nonnull TLContact *)room {
    DDLogVerbose(@"%@ onUpdateRoom: %@", LOG_TAG, room);
    
    if ([room.uuid isEqual:self.room.uuid]) {
        [self finish];
    }
}

- (void)onDeleteRoom:(nonnull NSUUID *)roomId {
    DDLogVerbose(@"%@ onDeleteRoom: %@", LOG_TAG, roomId);
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    DDLogVerbose(@"%@ numberOfSectionsInTableView: %@", LOG_TAG, tableView);
    
    return SECTION_COUNT;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ heightForHeaderInSection: %ld", LOG_TAG, tableView, (long)section);
    
    return DESIGN_SECTION_HEIGHT * Design.HEIGHT_RATIO;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ willDisplayHeaderView: %@ forSection: %ld", LOG_TAG, tableView, view, (long)section);
    
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    NSString *sectionName;
    header.textLabel.textColor = Design.FONT_COLOR_DEFAULT;
    header.textLabel.font = Design.FONT_BOLD28;
    
    switch (section) {
        case SECTION_PARTCIPANTS:
            sectionName = TwinmeLocalizedString(@"add_contact_view_controller_title", nil).uppercaseString;
            break;
            
        case SECTION_CHAT:
            sectionName = TwinmeLocalizedString(@"conversations_view_controller_title", nil).uppercaseString;
            break;
            
        case SECTION_CALLS:
            sectionName = TwinmeLocalizedString(@"history_view_controller_title", nil).uppercaseString;
            break;
            
        case SECTION_NOTIFICATIONS:
            sectionName = TwinmeLocalizedString(@"application_notifications", nil).uppercaseString;
            break;
            
        default:
            sectionName = @"";
            break;
    }
    [header.textLabel setText:sectionName];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ titleForHeaderInSection: %ld", LOG_TAG, tableView, (long)section);
    
    NSString *sectionName;
    switch (section) {
        case SECTION_PARTCIPANTS:
            sectionName = TwinmeLocalizedString(@"add_contact_view_controller_title", nil).uppercaseString;
            break;
            
        case SECTION_CHAT:
            sectionName = TwinmeLocalizedString(@"conversations_view_controller_title", nil).uppercaseString;
            break;
            
        case SECTION_CALLS:
            sectionName = TwinmeLocalizedString(@"history_view_controller_title", nil).uppercaseString;
            break;
            
        case SECTION_NOTIFICATIONS:
            sectionName = TwinmeLocalizedString(@"application_notifications", nil).uppercaseString;
            break;
            
        default:
            sectionName = @"";
            break;
    }
    return sectionName;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ numberOfRowsInSection: %ld", LOG_TAG, tableView, (long)section);
    
    NSInteger numberOfRowsInSection;
    switch (section) {
        case SECTION_PARTCIPANTS:
            numberOfRowsInSection = 1;
            break;
            
        case SECTION_CHAT:
            numberOfRowsInSection = 4;
            break;
            
        case SECTION_CALLS:
            numberOfRowsInSection = 2;
            break;
            
        case SECTION_NOTIFICATIONS:
            numberOfRowsInSection = 3;
            break;
            
        default:
            numberOfRowsInSection = 0;
            break;
    }
    return numberOfRowsInSection;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ heightForRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    if (indexPath.section == SECTION_CHAT && indexPath.row == 3) {
        return UITableViewAutomaticDimension;
    }
    
    return Design.SETTING_CELL_HEIGHT;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ cellForRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    if (indexPath.section == SECTION_CHAT || indexPath.section == SECTION_NOTIFICATIONS) {
        
        if (indexPath.row < 3) {
            PersonalizationCell *cell = [tableView dequeueReusableCellWithIdentifier:PERSONALIZATION_CELL_IDENTIFIER];
            if (!cell) {
                cell = [[PersonalizationCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:PERSONALIZATION_CELL_IDENTIFIER];
            }
            
            NSString *title = @"";
            BOOL checked = NO;
            
            switch (indexPath.section) {
                case SECTION_CHAT:
                    if (indexPath.row == 0) {
                        checked = self.chatMode == TLChatModeChannel;
                        title = TwinmeLocalizedString(@"settings_room_view_controller_room_type_channel", nil);
                    } else if (indexPath.row == 1) {
                        checked = self.chatMode == TLChatModeFeedback;
                        title = TwinmeLocalizedString(@"settings_room_view_controller_room_type_feedback", nil);
                    } else if (indexPath.row == 2) {
                        checked = self.chatMode == TLChatModePublic;
                        title = TwinmeLocalizedString(@"settings_room_view_controller_room_type_forum", nil);
                    }
                    break;
                    
                case SECTION_NOTIFICATIONS:
                    if (indexPath.row == 0) {
                        checked = self.notificationMode == TLNotificationModeInform;
                        title = TwinmeLocalizedString(@"settings_room_view_controller_conference_notifications_inform", nil);
                    } else if (indexPath.row == 1) {
                        checked = self.notificationMode == TLNotificationModeNoisy;
                        title = TwinmeLocalizedString(@"settings_room_view_controller_conference_notifications_noisy", nil);
                    } else if (indexPath.row == 2) {
                        checked = self.notificationMode == TLNotificationModeQuiet;
                        title = TwinmeLocalizedString(@"settings_room_view_controller_conference_notifications_quiet", nil);
                    }
                    break;
                    
                default:
                    break;
            }
            
            [cell bindWithTitle:title checked:checked];
            
            return cell;
        } else {
            SettingsInformationCell *cell = [tableView dequeueReusableCellWithIdentifier:SETTINGS_INFORMATION_CELL_IDENTIFIER];
            if (!cell) {
                cell = [[SettingsInformationCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:SETTINGS_INFORMATION_CELL_IDENTIFIER];
            }
            
            NSString *title = @"";
            switch (indexPath.section) {
                case SECTION_CHAT:
                    if (self.chatMode == TLChatModeChannel) {
                        title = TwinmeLocalizedString(@"settings_room_view_controller_room_type_channel_information", nil);
                    } else if (self.chatMode == TLChatModeFeedback) {
                        title = TwinmeLocalizedString(@"settings_room_view_controller_room_type_feedback_information", nil);
                    } else if (self.chatMode == TLChatModePublic) {
                        title = TwinmeLocalizedString(@"settings_room_view_controller_room_type_forum_information", nil);
                    }
                    break;
                    
                default:
                    break;
            }
            
            [cell bindWithText:title];
            
            return cell;
        }
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
        BOOL disableSwitch = NO;
        
        switch (indexPath.section) {
            case SECTION_PARTCIPANTS:
                if (indexPath.row == 0) {
                    switchState = self.allowInvitation;
                    hiddenSwitch = NO;
                    tag = TAG_ALLOW_INVITATION;
                    title = TwinmeLocalizedString(@"settings_room_view_controller_allow_invite_contact", nil);
                } else if (indexPath.row == 1) {
                    switchState = self.allowInvitationAsPersonalContact;
                    hiddenSwitch = NO;
                    tag = TAG_ALLOW_INVITATION_AS_PERSONAL_CONTACT;
                    title = TwinmeLocalizedString(@"settings_room_view_controller_allow_invite_as_personal_contact", nil);
                }
                break;
                
            case SECTION_CALLS:
                if (indexPath.row == 0) {
                    switchState = self.callMode != TLCallModeDisabled;
                    hiddenSwitch = NO;
                    tag = TAG_ALLOW_AUDIO_CALL;
                    title = TwinmeLocalizedString(@"conversation_view_controller_audio_call", nil);
                } else if (indexPath.row == 1) {
                    switchState = self.callMode == TLCallModeVideo;
                    hiddenSwitch = NO;
                    tag = TAG_ALLOW_VIDEO_CALL;
                    title = TwinmeLocalizedString(@"conversation_view_controller_video_call", nil);
                }
                break;
                
            default:
                break;
        }
        
        [cell bindWithTitle:title icon:nil stateSwitch:switchState tagSwitch:tag hiddenSwitch:hiddenSwitch disableSwitch:disableSwitch backgroundColor:Design.WHITE_COLOR hiddenSeparator:NO];
        
        return cell;
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ didSelectRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    if (indexPath.section == SECTION_CHAT) {
        if (indexPath.row == 0) {
            self.chatMode = TLChatModeChannel;
        } else if (indexPath.row == 1) {
            self.chatMode = TLChatModeFeedback;
        } else {
            self.chatMode = TLChatModePublic;
        }
    } else if (indexPath.section == SECTION_NOTIFICATIONS) {
        if (indexPath.row == 0) {
            self.notificationMode = TLNotificationModeInform;
        } else if (indexPath.row == 1) {
            self.notificationMode = TLNotificationModeNoisy;
        } else {
            self.notificationMode = TLNotificationModeQuiet;
        }
    }
    
    [self.tableView reloadData];
    
    [self setUpdated];
}

#pragma mark - SettingsActionDelegate

- (void)switchChangeValue:(SwitchView *)updatedSwitch {
    DDLogVerbose(@"%@ switchChangeValue: %@", LOG_TAG, updatedSwitch);
    
    switch (updatedSwitch.tag) {
        case TAG_ALLOW_INVITATION:
            self.allowInvitation = !self.allowInvitation;
            break;
            
        case TAG_ALLOW_INVITATION_AS_PERSONAL_CONTACT:
            self.allowInvitationAsPersonalContact = !self.allowInvitationAsPersonalContact;
            break;
            
        case TAG_ALLOW_AUDIO_CALL:
            if (updatedSwitch.isOn) {
                self.callMode = TLCallModeAudio;
            } else {
                self.callMode = TLCallModeDisabled;
            }
            break;
            
        case TAG_ALLOW_VIDEO_CALL:
            if (updatedSwitch.isOn) {
                self.callMode = TLCallModeVideo;
            } else {
                self.callMode = TLCallModeAudio;
            }
            break;
            
        default:
            break;
    }
    
    [self.tableView reloadData];
    
    [self setUpdated];
}

- (void)switchLongPress:(SwitchView *)switchView {
    DDLogVerbose(@"%@ switchLongPress: %@", LOG_TAG, switchView);
    
}

#pragma mark - Private methods

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    self.view.backgroundColor = Design.WHITE_COLOR;
    
    [self setNavigationTitle:TwinmeLocalizedString(@"settings_view_controller_title", nil)];
    
    self.saveBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:TwinmeLocalizedString(@"application_save", nil) style:UIBarButtonItemStylePlain target:self action:@selector(handleSaveTapGesture:)];
    [self.saveBarButtonItem setTitleTextAttributes: @{NSFontAttributeName : Design.FONT_BOLD36, NSForegroundColorAttributeName: [UIColor whiteColor]} forState:UIControlStateNormal];
    [self.saveBarButtonItem setTitleTextAttributes: @{NSFontAttributeName : Design.FONT_BOLD36, NSForegroundColorAttributeName: [UIColor colorWithWhite:1.0 alpha:0.5]} forState:UIControlStateDisabled];
    self.saveBarButtonItem.enabled = NO;
    self.navigationItem.rightBarButtonItem = self.saveBarButtonItem;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"SettingsItemCell" bundle:nil] forCellReuseIdentifier:SETTINGS_CELL_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"SettingsValueItemCell" bundle:nil] forCellReuseIdentifier:SETTINGS_VALUE_CELL_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"SettingsInformationCell" bundle:nil] forCellReuseIdentifier:SETTINGS_INFORMATION_CELL_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"PersonalizationCell" bundle:nil] forCellReuseIdentifier:PERSONALIZATION_CELL_IDENTIFIER];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = Design.SETTING_CELL_HEIGHT;
    self.tableView.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)handleBackTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleBackTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        [self finish];
    }
}

- (void)handleSaveTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleSaveTapGesture: %@", LOG_TAG, sender);
    
    if (!self.canSave) {
        return;
    }
    
    self.roomConfig.callMode = self.callMode;
    self.roomConfig.invitationMode = self.invitationMode;
    self.roomConfig.chatMode = self.chatMode;
    self.roomConfig.notificationMode = self.notificationMode;
    
    [self.editRoomService updateRoomConfig:self.room roomConfig:self.roomConfig];
}

- (void)finish {
    DDLogVerbose(@"%@ finish", LOG_TAG);
    
    if (self.editRoomService) {
        [self.editRoomService dispose];
        self.editRoomService = nil;
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setUpdated {
    DDLogVerbose(@"%@ setUpdated", LOG_TAG);
    
    if (self.roomConfig && self.roomConfig.notificationMode == self.notificationMode && self.roomConfig.callMode == self.callMode && self.roomConfig.invitationMode == self.invitationMode && self.roomConfig.chatMode == self.chatMode) {
        if (!self.canSave) {
            return;
        }
        self.canSave = NO;
        self.saveBarButtonItem.enabled = NO;
        
    } else {
        if (self.canSave) {
            return;
        }
        self.canSave = YES;
        self.saveBarButtonItem.enabled = YES;
    }
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    [self.saveBarButtonItem setTitleTextAttributes: @{NSFontAttributeName : Design.FONT_BOLD36, NSForegroundColorAttributeName: [UIColor whiteColor]} forState:UIControlStateNormal];
    [self.saveBarButtonItem setTitleTextAttributes: @{NSFontAttributeName : Design.FONT_BOLD36, NSForegroundColorAttributeName: [UIColor colorWithWhite:1.0 alpha:0.5]} forState:UIControlStateDisabled];
    
    [self.tableView reloadData];
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    self.tableView.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
    self.view.backgroundColor = Design.WHITE_COLOR;
}

@end
