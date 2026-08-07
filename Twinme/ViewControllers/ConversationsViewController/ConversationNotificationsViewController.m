/*
 *  Copyright (c) 2026 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <Twinlife/TLAccountService.h>

#import <Twinme/TLContact.h>
#import <Twinme/TLGroup.h>

#import <Utils/NSString+Utils.h>

#import "ConversationNotificationsViewController.h"
#import "MessageSettingsViewController.h"

#import "SettingsItemCell.h"
#import "SettingsInformationCell.h"
#import "SettingsValueItemCell.h"
#import "TwinmeSettingsItemCell.h"

#import <TwinmeCommon/Design.h>
#import <TwinmeCommon/NotificationSound.h>
#import <TwinmeCommon/SettingsSectionHeaderCell.h>

#import "SwitchView.h"
#import "UIPremiumFeature.h"
#import "UITimeout.h"
#import "PremiumFeatureConfirmView.h"
#import "MenuSelectValueView.h"
#import "MenuConversationShorcutView.h"

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static NSString *SETTINGS_CELL_IDENTIFIER = @"SettingsCellIdentifier";
static NSString *HEADER_SETTINGS_CELL_IDENTIFIER = @"HeaderSettingsCellIdentifier";
static NSString *SETTINGS_INFORMATION_CELL_IDENTIFIER = @"SettingsInformationCellIdentifier";
static NSString *SETTINGS_VALUE_CELL_IDENTIFIER = @"SettingsValueCellIdentifier";
static NSString *TWINME_SETTINGS_CELL_IDENTIFIER = @"TwinmeSettingsCellIdentifier";

typedef enum {
    SECTION_NOTIFICATION,
    SECTION_DISCREET_RELATION,
    SECTION_COUNT
} ConversationNotificationsSection;

typedef enum {
    TAG_DISPLAY_REACTIONS,
    TAG_SILENT_MODE,
    TAG_DISCREET_RELATION
} ConversationNotificationsTag;

//
// Interface: ConversationNotificationsViewController ()
//

@interface ConversationNotificationsViewController () <SettingsActionDelegate, MenuSelectValueDelegate, BottomSheetViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic) id<TLOriginator> originator;
@property (nonatomic) BOOL discreetRelation;
@property (nonatomic) BOOL silentMode;
@property (nonatomic) BOOL notificationReaction;
@property (nonatomic) int64_t silentExpiration;

@end

//
// Implementation: ConversationNotificationsViewController
//

#undef LOG_TAG
#define LOG_TAG @"ConversationNotificationsViewController"

@implementation ConversationNotificationsViewController

- (instancetype)initWithCoder:(NSCoder *)coder {
    DDLogVerbose(@"%@ initWithCoder: %@", LOG_TAG, coder);
    
    self = [super initWithCoder:coder];
    
    if (self) {
        self.silentMode = NO;
        self.notificationReaction = YES;
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

- (void)initWithOriginator:(id<TLOriginator>)originator {
    DDLogVerbose(@"%@ initWithOriginator: %@", LOG_TAG, originator);
    
    self.originator = originator;
    
    if ([originator isKindOfClass:[TLGroup class]]) {
        TLGroup * group = (TLGroup *)originator;
        self.silentMode = [group getBooleanWithName:PROPERTY_CONVERSATION_SILENT_MODE defaultValue:NO];
        self.notificationReaction = [group getBooleanWithName:PROPERTY_CONVERSATION_NOTIFICATION_REACTION defaultValue:YES];
        self.silentExpiration = [group getNumberWithName:PROPERTY_CONVERSATION_SILENT_MODE_EXPIRATION defaultValue:0];
    } else {
        TLContact *contact = (TLContact *)originator;
        self.silentMode = [contact getBooleanWithName:PROPERTY_CONVERSATION_SILENT_MODE defaultValue:NO];
        self.notificationReaction = [contact getBooleanWithName:PROPERTY_CONVERSATION_NOTIFICATION_REACTION defaultValue:YES];
        self.silentExpiration = [contact getNumberWithName:PROPERTY_CONVERSATION_SILENT_MODE_EXPIRATION defaultValue:0];
    }
    
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970];
    if (self.silentExpiration > 0 && self.silentExpiration < timeInterval) {
        self.silentMode = NO;
    }
}

#pragma mark - SettingsActionDelegate

- (void)switchChangeValue:(SwitchView *)updatedSwitch {
    DDLogVerbose(@"%@ switchChangeValue: %@", LOG_TAG, updatedSwitch);
    
    if (updatedSwitch.tag == TAG_DISPLAY_REACTIONS) {
        self.notificationReaction = updatedSwitch.isOn;
        [self saveSettings];
    } else if (updatedSwitch.tag == TAG_SILENT_MODE) {
        self.silentMode = updatedSwitch.isOn;
        
        if (self.silentMode) {
            [self openMenuSelectValue];
        }
        [self saveSettings];
    } else if (updatedSwitch.tag == TAG_DISCREET_RELATION) {
        [self showPremiumFeature:FeatureTypePrivacy];
    }
    
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    DDLogVerbose(@"%@ numberOfSectionsInTableView: %@", LOG_TAG, tableView);
    
    return SECTION_COUNT;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath  {
    DDLogVerbose(@"%@ tableView: %@ heightForRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    if (indexPath.section == SECTION_DISCREET_RELATION && indexPath.row == 1) {
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
    BOOL hideSeparator = NO;
    switch (section) {
        case SECTION_NOTIFICATION:
            sectionName = TwinmeLocalizedString(@"settings_view_system_notifications_title", nil);
            break;
            
        case SECTION_DISCREET_RELATION:
            sectionName = TwinmeLocalizedString(@"privacy_view_title", nil);
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
        case SECTION_NOTIFICATION:
            numberOfRowsInSection = self.silentMode ? 3 : 2;
            break;
            
        case SECTION_DISCREET_RELATION:
            numberOfRowsInSection = 2;
            break;
            
        default:
            numberOfRowsInSection = 0;
            break;
    }
    return numberOfRowsInSection;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ cellForRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    if (indexPath.section == SECTION_DISCREET_RELATION) {
        if (indexPath.row == 0) {
            SettingsItemCell *cell = [tableView dequeueReusableCellWithIdentifier:SETTINGS_CELL_IDENTIFIER];
            if (!cell) {
                cell = [[SettingsItemCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:SETTINGS_CELL_IDENTIFIER];
            }
            
            cell.settingsActionDelegate = self;
            
            NSString *title = TwinmeLocalizedString(@"contact_capabilities_view_discreet_relation", nil);
            BOOL switchState = self.discreetRelation;
            int tag = TAG_DISCREET_RELATION;
            BOOL hiddenSwitch = NO;
            BOOL disableSwitch = NO;
            
            [cell bindWithTitle:title subTitle:nil icon:nil stateSwitch:switchState tagSwitch:tag hiddenSwitch:hiddenSwitch disableSwitch:disableSwitch backgroundColor:Design.WHITE_COLOR hiddenSeparator:NO];
            
            return cell;
        } else {
            SettingsInformationCell *cell = [tableView dequeueReusableCellWithIdentifier:SETTINGS_INFORMATION_CELL_IDENTIFIER];
            if (!cell) {
                cell = [[SettingsInformationCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:SETTINGS_INFORMATION_CELL_IDENTIFIER];
            }
                    
            [cell bindWithText:TwinmeLocalizedString(@"contact_capabilities_view_information_discreet_relation", nil)];
            
            return cell;
        }
    }  else {
        if (indexPath.row > 1) {
            SettingsValueItemCell *cell = [tableView dequeueReusableCellWithIdentifier:SETTINGS_VALUE_CELL_IDENTIFIER];
            if (!cell) {
                cell = [[SettingsValueItemCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:SETTINGS_VALUE_CELL_IDENTIFIER];
            }
            
            NSString *title = TwinmeLocalizedString(@"settings_view_turn_off_notification_sounds", nil);
            NSString *value = @"";
            if (self.silentExpiration > 0) {
                value = [NSString stringWithFormat:TwinmeLocalizedString(@"application_until", nil), [NSString formatItemTimeInterval:self.silentExpiration]];
            } else if (self.silentExpiration == -1) {
                value = TwinmeLocalizedString(@"contact_capabilities_view_camera_control_allow", nil);
            }
            
            [cell bindWithTitle:title value:value icon:nil];
            
            return cell;
        } else {
            SettingsItemCell *cell = [tableView dequeueReusableCellWithIdentifier:SETTINGS_CELL_IDENTIFIER];
            if (!cell) {
                cell = [[SettingsItemCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:SETTINGS_CELL_IDENTIFIER];
            }
            
            cell.settingsActionDelegate = self;
            
            NSString *title;
            BOOL switchState = NO;
            int tag = 0;
            BOOL disableSwitch = NO;
            BOOL hideSeparator = NO;
            
            if (indexPath.row == 1) {
                title = TwinmeLocalizedString(@"settings_view_silent_mode", nil);
                switchState = self.silentMode;
                tag = TAG_SILENT_MODE;
            } else {
                title = TwinmeLocalizedString(@"settings_view_message_reactions_notification", nil);
                switchState = self.notificationReaction;
                tag = TAG_DISPLAY_REACTIONS;
            }
                    
            [cell bindWithTitle:title subTitle:nil  icon:nil stateSwitch:switchState tagSwitch:tag hiddenSwitch:NO disableSwitch:disableSwitch backgroundColor:Design.POPUP_BACKGROUND_COLOR hiddenSeparator:hideSeparator];
            
            return cell;
        }
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ didSelectRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);

    if (indexPath.section == SECTION_NOTIFICATION && indexPath.row == 2) {
        [self openMenuSelectValue];
    }
}

#pragma mark - MenuSelectValueDelegate

- (void)selectValue:(MenuSelectValueView *)menuSelectValueView value:(int)value {
    DDLogVerbose(@"%@ selectValue: %d", LOG_TAG, value);

    [menuSelectValueView removeFromSuperview];

    [self.tableView reloadData];
}

- (void)selectTimeout:(MenuSelectValueView *)menuSelectValueView uiTimeout:(UITimeout *)uiTimeout {
    DDLogVerbose(@"%@ selectTimeout: %@", LOG_TAG, uiTimeout);

    [menuSelectValueView removeFromSuperview];

    int64_t expiration = 0;
    if (uiTimeout.timeout > 0) {
        NSDate *expirationDate = [[NSDate date] dateByAddingTimeInterval:(NSTimeInterval)uiTimeout.timeout];
        expiration = (int64_t)[expirationDate timeIntervalSince1970];
    } else {
        expiration = uiTimeout.timeout;
    }

    if ([self.originator isKindOfClass:[TLGroup class]]) {
        TLGroup * group = (TLGroup *)self.originator;
        [group setBooleanWithName:PROPERTY_CONVERSATION_SILENT_MODE value:YES twinmeContext:self.twinmeContext];
        [group setNumberWithName:PROPERTY_CONVERSATION_SILENT_MODE_EXPIRATION value:expiration twinmeContext:self.twinmeContext];
    } else {
        TLContact *contact = (TLContact *)self.originator;
        [contact setBooleanWithName:PROPERTY_CONVERSATION_SILENT_MODE value:YES twinmeContext:self.twinmeContext];
        [contact setNumberWithName:PROPERTY_CONVERSATION_SILENT_MODE_EXPIRATION value:expiration twinmeContext:self.twinmeContext];
    }
    
    self.silentExpiration = expiration;
    
    [self.tableView reloadData];
}

- (void)cancelMenuSelectValue:(MenuSelectValueView *)menuSelectValueView {
    DDLogVerbose(@"%@ cancelMenuSelectValue: %@", LOG_TAG, menuSelectValueView);
    
    [menuSelectValueView removeFromSuperview];
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

#pragma mark - Private methods

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    self.view.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
    
    [self setNavigationTitle:TwinmeLocalizedString(@"application_notifications", nil)];
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

- (void)openMenuSelectValue {
    DDLogVerbose(@"%@ openMenuSelectValue", LOG_TAG);
    
    MenuSelectValueView *menuSelectValueView = [[MenuSelectValueView alloc]init];
    menuSelectValueView.menuSelectValueDelegate = self;
    [self.navigationController.view addSubview:menuSelectValueView];
    [menuSelectValueView setMenuSelectValueTypeWithType:MenuSelectValueTypeSilentModeDuration defaultValue:0];
    [menuSelectValueView openMenu];
}

- (void)saveSettings {
    DDLogVerbose(@"%@ saveSettings", LOG_TAG);
    
    if ([self.originator isKindOfClass:[TLGroup class]]) {
        TLGroup * group = (TLGroup *)self.originator;
        [group setBooleanWithName:PROPERTY_CONVERSATION_SILENT_MODE value:self.silentMode twinmeContext:self.twinmeContext];
        [group setBooleanWithName:PROPERTY_CONVERSATION_NOTIFICATION_REACTION value:self.notificationReaction twinmeContext:self.twinmeContext];
    } else {
        TLContact *contact = (TLContact *)self.originator;
        [contact setBooleanWithName:PROPERTY_CONVERSATION_SILENT_MODE value:self.silentMode twinmeContext:self.twinmeContext];
        [contact setBooleanWithName:PROPERTY_CONVERSATION_NOTIFICATION_REACTION value:self.notificationReaction twinmeContext:self.twinmeContext];
    }
}

- (void)showPremiumFeature:(FeatureType)featureType {
    DDLogVerbose(@"%@ showPremiumFeature", LOG_TAG);
    
    PremiumFeatureConfirmView *premiumFeatureConfirmView = [[PremiumFeatureConfirmView alloc] init];
    premiumFeatureConfirmView.bottomSheetViewDelegate = self;
    [premiumFeatureConfirmView initWithPremiumFeature:[[UIPremiumFeature alloc]initWithFeatureType:featureType spaceSettings:[self currentSpaceSettings]] parentViewController:self.navigationController];
    [self.navigationController.view addSubview:premiumFeatureConfirmView];
    [premiumFeatureConfirmView showConfirmView];
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
