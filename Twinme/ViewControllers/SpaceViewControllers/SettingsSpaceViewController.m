/*
 *  Copyright (c) 2022 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <Twinlife/TLAccountService.h>

#import <Twinme/TLSpace.h>

#import <Utils/NSString+Utils.h>

#import "EditSpaceViewController.h"
#import "SettingsSpaceViewController.h"
#import "MessageSettingsViewController.h"
#import "MessageSettingsSpaceViewController.h"
#import "NotificationSpaceViewController.h"
#import "SpaceAppearanceViewController.h"
#import "SettingsItemCell.h"
#import "SettingsInformationCell.h"
#import "SettingsValueItemCell.h"
#import <TwinmeCommon/EditSpaceService.h>
#import "AppearanceColorCell.h"
#import "TwinmeSettingsItemCell.h"
#import <TwinmeCommon/TwinmeNavigationController.h>
#import "DisplayModeCell.h"

#import <TwinmeCommon/Design.h>
#import "SwitchView.h"
#import "AlertView.h"
#import "CustomAppearance.h"
#import "UIColor+Hex.h"
#import "SpaceSetting.h"
#import "UIPremiumFeature.h"

#import "MenuSelectColorView.h"

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static NSString *SETTINGS_CELL_IDENTIFIER = @"SettingsCellIdentifier";
static NSString *SETTINGS_VALUE_CELL_IDENTIFIER = @"SettingsValueCellIdentifier";
static NSString *SETTINGS_INFORMATION_CELL_IDENTIFIER = @"SettingsInformationCellIdentifier";
static NSString *TWINME_SETTINGS_CELL_IDENTIFIER = @"TwinmeSettingsCellIdentifier";

static const CGFloat DESIGN_SECTION_HEIGHT = 100;

//
// Interface: SettingsSpaceViewController ()
//

@interface SettingsSpaceViewController () <EditSpaceServiceDelegate, SettingsActionDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic) EditSpaceService *editSpaceService;
@property (nonatomic) TLSpace *space;

@property (nonatomic) BOOL defaultAppearanceSettings;
@property (nonatomic) BOOL defaultMessageSettings;
@property (nonatomic) BOOL defaultNotificationSettings;

@property (nonatomic) BOOL canSave;

@end

typedef enum {
    SECTION_INFORMATION,
    SECTION_APPEARANCE,
    SECTION_MESSAGES,
    SECTION_NOTIFICATIONS,
    SECTION_PERMISSIONS,
    SECTION_COUNT
} TLTSpaceSettingSection;

typedef enum {
    TAG_DEFAULT_APPEARANCE,
    TAG_DEFAULT_MESSAGES,
    TAG_DEFAULT_NOTIFICATIONS,
    TAG_PERMISSION_SHARE_SPACE_CARD,
    TAG_PERMISSION_CREATE_CONTACT,
    TAG_PERMISSION_MOVE_CONTACT,
    TAG_PERMISSION_CREATE_GROUP,
    TAG_PERMISSION_MOVE_GROUP,
    TAG_PERMISSION_UPDATE_IDENITY
} TLTSpaceSettingTag;

//
// Implementation: SettingsSpaceViewController
//

#undef LOG_TAG
#define LOG_TAG @"SettingsSpaceViewController"

@implementation SettingsSpaceViewController

- (instancetype)initWithCoder:(NSCoder *)coder {
    DDLogVerbose(@"%@ initWithCoder: %@", LOG_TAG, coder);
    
    self = [super initWithCoder:coder];
    
    if (self) {
        _canSave = NO;
        _defaultAppearanceSettings = YES;
        _defaultMessageSettings = YES;
        _defaultNotificationSettings = YES;
    }
    return self;
}

- (void)viewDidLoad {
    DDLogVerbose(@"%@ viewDidLoad", LOG_TAG);
    
    [super viewDidLoad];
    
    [self initViews];
    self.editSpaceService = [[EditSpaceService alloc]initWithTwinmeContext:self.twinmeContext delegate:self space:self.space];
}

- (void)viewWillAppear:(BOOL)animated {
    DDLogVerbose(@"%@ viewWillAppear: %@", LOG_TAG, animated ? @"YES" : @"NO");
    
    [super viewWillAppear:animated];
    
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (void)initWithSpace:(TLSpace *)space {
    DDLogVerbose(@"%@ initWithSpace: %@", LOG_TAG, space);
    
    self.space = space;
    self.defaultAppearanceSettings = [self.space.settings getBooleanWithName:PROPERTY_DEFAULT_APPEARANCE_SETTINGS defaultValue:YES];
    self.defaultMessageSettings = [self.space.settings getBooleanWithName:PROPERTY_DEFAULT_MESSAGE_SETTINGS defaultValue:YES];
    self.defaultNotificationSettings = [self.space.settings getBooleanWithName:PROPERTY_DEFAULT_NOTIFICATION_SETTINGS defaultValue:YES];
}

#pragma mark - EditSpaceServiceDelegate

- (void)onGetGroups:(nonnull NSArray<TLGroup *> *)groups {
    DDLogVerbose(@"%@ onGetGroups: %@", LOG_TAG, groups);
}

- (void)onGetContacts:(nonnull NSArray<TLContact *> *)contacts {
    DDLogVerbose(@"%@ onGetContacts: %@", LOG_TAG, contacts);
}

- (void)onCreateProfile:(nonnull TLProfile *)profile {
    DDLogVerbose(@"%@ onCreateProfile: %@", LOG_TAG, profile);
}

- (void)onDeleteSpace:(nonnull NSUUID *)spaceId {
    DDLogVerbose(@"%@ onDeleteSpace: %@", LOG_TAG, spaceId);
}

- (void)onGetSpace:(nonnull TLSpace *)space avatar:(nullable UIImage *)avatar {
    DDLogVerbose(@"%@ onGetCurrentSpace: %@", LOG_TAG, space);
}

- (void)onUpdateProfile:(nonnull TLProfile *)profile {
    DDLogVerbose(@"%@ onUpdateProfile: %@", LOG_TAG, profile);
}

- (void)onCreateSpace:(TLSpace *)space {
    DDLogVerbose(@"%@ onCreateSpace: %@", LOG_TAG, space);
    
}

- (void)onUpdateSpace:(nonnull TLSpace *)space {
    DDLogVerbose(@"%@ onUpdateSpace: %@", LOG_TAG, space);

    if ([space.uuid isEqual:self.currentSpace.uuid]) {
        TLSpaceSettings *spaceSettings = space.settings;
        if ([space.settings getBooleanWithName:PROPERTY_DEFAULT_APPEARANCE_SETTINGS defaultValue:YES]) {
            spaceSettings = self.twinmeContext.defaultSpaceSettings;
        }
        
        if (![Design.MAIN_STYLE isEqualToString:spaceSettings.style]) {
            [Design setMainColor:spaceSettings.style];
        }
        
        TwinmeNavigationController *twinmeNavigationController = (TwinmeNavigationController *)self.navigationController;
        [twinmeNavigationController setNavigationBarStyle];
    }
}

- (void)onUpdateSpaceAvatar:(UIImage *)avatar {
    DDLogVerbose(@"%@ onUpdateSpaceAvatar: %@", LOG_TAG, avatar);
    
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    DDLogVerbose(@"%@ numberOfSectionsInTableView: %@", LOG_TAG, tableView);
    
    return SECTION_COUNT;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ heightForHeaderInSection: %ld", LOG_TAG, tableView, (long)section);
    
    if (section == SECTION_INFORMATION) {
        return CGFLOAT_MIN;
    }
    
    return DESIGN_SECTION_HEIGHT * Design.HEIGHT_RATIO;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ willDisplayHeaderView: %@ forSection: %ld", LOG_TAG, tableView, view, (long)section);
    
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    NSString *sectionName;
    header.textLabel.textColor = Design.FONT_COLOR_DEFAULT;
    header.textLabel.font = Design.FONT_BOLD28;
    
    switch (section) {
        case SECTION_NOTIFICATIONS:
            sectionName = TwinmeLocalizedString(@"application_notifications", nil).uppercaseString;
            break;
            
        case SECTION_MESSAGES:
            sectionName = TwinmeLocalizedString(@"settings_view_controller_chat_category_title", nil).uppercaseString;
            break;
                        
        case SECTION_APPEARANCE:
            sectionName = TwinmeLocalizedString(@"application_appearance", nil).uppercaseString;
            break;
            
        case SECTION_PERMISSIONS:
            if (self.space && self.space.isManagedSpace) {
                sectionName = TwinmeLocalizedString(@"settings_space_view_controller_permissions_title", nil).uppercaseString;
            } else {
                sectionName = @"";
            }
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
        case SECTION_NOTIFICATIONS:
            sectionName = TwinmeLocalizedString(@"application_notifications", nil).uppercaseString;
            break;
            
        case SECTION_MESSAGES:
            sectionName = TwinmeLocalizedString(@"settings_view_controller_chat_category_title", nil).uppercaseString;
            break;
            
        case SECTION_APPEARANCE:
            sectionName = TwinmeLocalizedString(@"application_appearance", nil).uppercaseString;
            break;
            
        case SECTION_PERMISSIONS:
            if (self.space && self.space.isManagedSpace) {
                sectionName = TwinmeLocalizedString(@"settings_space_view_controller_permissions_title", nil).uppercaseString;
            } else {
                sectionName = @"";
            }
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
        case SECTION_INFORMATION:
            numberOfRowsInSection = 1;
            break;
            
        case SECTION_NOTIFICATIONS:
        case SECTION_APPEARANCE:
        case SECTION_MESSAGES:
            numberOfRowsInSection = 2;
            break;
            
        case SECTION_PERMISSIONS:
            if (!self.space || (self.space && !self.space.isManagedSpace)) {
                numberOfRowsInSection = 0;
            } else {
                numberOfRowsInSection = 6;
            }
            break;
            
        default:
            numberOfRowsInSection = 0;
            break;
    }
    return numberOfRowsInSection;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ heightForRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    if ([self isInformationPath:indexPath]) {
        return UITableViewAutomaticDimension;
    }
    return Design.SETTING_CELL_HEIGHT;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ cellForRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);

    if ([self isInformationPath:indexPath]) {
        SettingsInformationCell *cell = [tableView dequeueReusableCellWithIdentifier:SETTINGS_INFORMATION_CELL_IDENTIFIER];
        if (!cell) {
            cell = [[SettingsInformationCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:SETTINGS_INFORMATION_CELL_IDENTIFIER];
        }
        
        [cell bindWithText:TwinmeLocalizedString(@"settings_space_view_controller_header_message", nil)];
        
        return cell;
    } else if ([self isDefaultValueSwitchPath:indexPath]) {
        SettingsItemCell *cell = [tableView dequeueReusableCellWithIdentifier:SETTINGS_CELL_IDENTIFIER];
        if (!cell) {
            cell = [[SettingsItemCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:SETTINGS_CELL_IDENTIFIER];
        }
        cell.settingsActionDelegate = self;
        
        BOOL stateSwitch = NO;
        int tag = 0;
        
        switch (indexPath.section) {
            case SECTION_NOTIFICATIONS:
                tag = TAG_DEFAULT_NOTIFICATIONS;
                stateSwitch = self.defaultNotificationSettings;
                break;
                
            case SECTION_APPEARANCE:
                tag = TAG_DEFAULT_APPEARANCE;
                stateSwitch = self.defaultAppearanceSettings;
                break;
                
            case SECTION_MESSAGES:
                tag = TAG_DEFAULT_MESSAGES;
                stateSwitch = self.defaultMessageSettings;
                break;
            
            default:
                break;
        }
        
        [cell bindWithTitle:TwinmeLocalizedString(@"side_menu_view_controller_application_settings", nil) icon:nil stateSwitch:stateSwitch tagSwitch:tag hiddenSwitch:NO disableSwitch:NO backgroundColor:Design.WHITE_COLOR hiddenSeparator:NO];
        
        return cell;
    } else if ([self isUdpateDefaultValuePath:indexPath]) {
        TwinmeSettingsItemCell *cell = [tableView dequeueReusableCellWithIdentifier:TWINME_SETTINGS_CELL_IDENTIFIER];
        if (!cell) {
            cell = [[TwinmeSettingsItemCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:TWINME_SETTINGS_CELL_IDENTIFIER];
        }
    
        BOOL disableSetting = NO;
        
        switch (indexPath.section) {
            case SECTION_NOTIFICATIONS:
                disableSetting = self.defaultNotificationSettings;
                break;
                
            case SECTION_APPEARANCE:
                disableSetting = self.defaultAppearanceSettings;
                break;
                
            case SECTION_MESSAGES:
                disableSetting = self.defaultMessageSettings;
                break;
            
            default:
                break;
        }
        
        [cell bindWithTitle:TwinmeLocalizedString(@"settings_space_view_controller_default_value_title", nil) hiddenAccessory:NO disableSetting:disableSetting color:Design.FONT_COLOR_DEFAULT];
        
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
        BOOL disableSwitch = NO;
        
        switch (indexPath.section) {
            case SECTION_PERMISSIONS:
                hiddenSwitch = NO;
                disableSwitch = YES;
                if (indexPath.row == 0) {
                    switchState = [self.space hasPermission:TLSpacePermissionTypeShareSpaceCard];
                    tag = TAG_PERMISSION_SHARE_SPACE_CARD;
                    title = TwinmeLocalizedString(@"settings_space_view_controller_permission_share_space_card", nil);
                } else if (indexPath.row == 1) {
                    switchState = [self.space hasPermission:TLSpacePermissionTypeCreateContact];
                    tag = TAG_PERMISSION_CREATE_CONTACT;
                    title = TwinmeLocalizedString(@"settings_space_view_controller_permission_create_contact", nil);
                } else if (indexPath.row == 2) {
                    switchState = [self.space hasPermission:TLSpacePermissionTypeMoveContact];
                    tag = TAG_PERMISSION_MOVE_CONTACT;
                    title = TwinmeLocalizedString(@"settings_space_view_controller_permission_move_contact", nil);
                } else if (indexPath.row == 3) {
                    switchState = [self.space hasPermission:TLSpacePermissionTypeCreateGroup];
                    tag = TAG_PERMISSION_CREATE_GROUP;
                    title = TwinmeLocalizedString(@"settings_space_view_controller_permission_create_group", nil);
                } else if (indexPath.row == 4) {
                    switchState = [self.space hasPermission:TLSpacePermissionTypeMoveGroup];
                    tag = TAG_PERMISSION_MOVE_GROUP;
                    title = TwinmeLocalizedString(@"settings_space_view_controller_permission_move_group", nil);
                } else if (indexPath.row == 5) {
                    switchState = [self.space hasPermission:TLSpacePermissionTypeUpdateIdentity];
                    tag = TAG_PERMISSION_UPDATE_IDENITY;
                    title = TwinmeLocalizedString(@"settings_space_view_controller_permission_update_identity", nil);
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
    
    if (indexPath.section == SECTION_APPEARANCE && indexPath.row == 1 && !self.defaultAppearanceSettings) {
        SpaceAppearanceViewController *spaceAppearanceViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SpaceAppearanceViewController"];
        [spaceAppearanceViewController initWithSpace:self.space];
        [self.navigationController pushViewController:spaceAppearanceViewController animated:YES];
    } else if (indexPath.section == SECTION_MESSAGES && indexPath.row == 1 && !self.defaultMessageSettings) {
        MessageSettingsSpaceViewController *settingsSpaceViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"MessageSettingsSpaceViewController"];
        [settingsSpaceViewController initWithSpace:self.space];
        [self.navigationController pushViewController:settingsSpaceViewController animated:YES];
    } else if (indexPath.section == SECTION_NOTIFICATIONS && indexPath.row == 1  && !self.defaultNotificationSettings) {
        NotificationSpaceViewController *notificationSpaceViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"NotificationSpaceViewController"];
        [notificationSpaceViewController initWithSpace:self.space];
        [self.navigationController pushViewController:notificationSpaceViewController animated:YES];
    }
}

#pragma mark - SettingsActionDelegate

- (void)switchChangeValue:(SwitchView *)updatedSwitch {
    DDLogVerbose(@"%@ switchChangeValue: %@", LOG_TAG, updatedSwitch);
    
    switch (updatedSwitch.tag) {
        case TAG_DEFAULT_APPEARANCE:
            self.defaultAppearanceSettings = !self.defaultAppearanceSettings;
            break;
            
        case TAG_DEFAULT_MESSAGES:
            self.defaultMessageSettings = !self.defaultMessageSettings;
            break;
            
        case TAG_DEFAULT_NOTIFICATIONS:
            self.defaultNotificationSettings = !self.defaultNotificationSettings;
            break;
        default:
            break;
    }
    
     TLSpaceSettings *spaceSettings = self.space.settings;
     if (self.defaultAppearanceSettings) {
         spaceSettings = self.twinmeContext.defaultSpaceSettings;
     }
     
     [Design setupColors:[[spaceSettings getStringWithName:PROPERTY_DISPLAY_MODE defaultValue:[NSString stringWithFormat:@"%d",DisplayModeSystem]]intValue]];
    
    [self saveSpaceSettings];
    [self.tableView reloadData];
    [self updateColor];
}

#pragma mark - Private methods

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    self.view.backgroundColor = Design.WHITE_COLOR;
    
    [self setNavigationTitle:TwinmeLocalizedString(@"settings_view_controller_title", nil)];
        
    [self.tableView registerNib:[UINib nibWithNibName:@"SettingsItemCell" bundle:nil] forCellReuseIdentifier:SETTINGS_CELL_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"SettingsValueItemCell" bundle:nil] forCellReuseIdentifier:SETTINGS_VALUE_CELL_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"SettingsInformationCell" bundle:nil] forCellReuseIdentifier:SETTINGS_INFORMATION_CELL_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"SettingsInformationCell" bundle:nil] forCellReuseIdentifier:SETTINGS_INFORMATION_CELL_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"TwinmeSettingsItemCell" bundle:nil] forCellReuseIdentifier:TWINME_SETTINGS_CELL_IDENTIFIER];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = Design.SETTING_CELL_HEIGHT * Design.HEIGHT_RATIO;
    self.tableView.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)handleBackTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleBackTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        [self finish];
    }
}

- (void)saveSpaceSettings {
    DDLogVerbose(@"%@ saveSpaceSettings", LOG_TAG);
    
    if (self.space) {
        TLSpaceSettings *spaceSettings = self.space.settings;
        [spaceSettings setBooleanWithName:PROPERTY_DEFAULT_APPEARANCE_SETTINGS value:self.defaultAppearanceSettings];
        [spaceSettings setBooleanWithName:PROPERTY_DEFAULT_MESSAGE_SETTINGS value:self.defaultMessageSettings];
        [spaceSettings setBooleanWithName:PROPERTY_DEFAULT_NOTIFICATION_SETTINGS value:self.defaultNotificationSettings];
        [self.editSpaceService updateSpace:spaceSettings avatar:nil largeAvatar:nil];
    }
}

- (void)finish {
    DDLogVerbose(@"%@ finish", LOG_TAG);
    
    [self.editSpaceService dispose];
    
    [self.navigationController popViewControllerAnimated:YES];
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

- (BOOL)isInformationPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == SECTION_INFORMATION) {
        return YES;
    }
    
    return NO;
}

- (BOOL)isDefaultValueSwitchPath:(NSIndexPath *)indexPath {

    if ((indexPath.section == SECTION_APPEARANCE || indexPath.section == SECTION_MESSAGES || indexPath.section == SECTION_NOTIFICATIONS) && indexPath.row == 0) {
        return YES;
    }
    
    return NO;
}

- (BOOL)isUdpateDefaultValuePath:(NSIndexPath *)indexPath {

    if ((indexPath.section == SECTION_APPEARANCE || indexPath.section == SECTION_MESSAGES || indexPath.section == SECTION_NOTIFICATIONS) && indexPath.row == 1) {
        return YES;
    }
    
    return NO;
}
    
@end
