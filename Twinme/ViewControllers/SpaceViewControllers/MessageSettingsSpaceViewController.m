/*
 *  Copyright (c) 2019-2024 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <Twinlife/TLAccountService.h>

#import <Twinme/TLSpace.h>

#import <Utils/NSString+Utils.h>

#import "MessageSettingsSpaceViewController.h"
#import "MessageSettingsViewController.h"
#import "SettingsItemCell.h"
#import "SettingsInformationCell.h"
#import "SettingsValueItemCell.h"
#import <TwinmeCommon/EditSpaceService.h>

#import <TwinmeCommon/Design.h>
#import <TwinmeCommon/NotificationSound.h>
#import "SelectNotificationSoundViewController.h"
#import "PrivacyViewController.h"
#import "SwitchView.h"
#import "AlertView.h"
#import "MenuSelectValueView.h"
#import "UITimeout.h"
#import "SpaceSetting.h"

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static NSString *SETTINGS_CELL_IDENTIFIER = @"SettingsCellIdentifier";
static NSString *SETTINGS_VALUE_CELL_IDENTIFIER = @"SettingsValueCellIdentifier";
static NSString *SETTINGS_INFORMATION_CELL_IDENTIFIER = @"SettingsInformationCellIdentifier";

static const CGFloat DESIGN_SECTION_HEIGHT = 100;

//
// Interface: MessageSettingsSpaceViewController ()
//

@interface MessageSettingsSpaceViewController () <EditSpaceServiceDelegate, SettingsActionDelegate, MenuSelectValueDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic) EditSpaceService *editSpaceService;
@property (nonatomic) TLSpace *space;

@property (nonatomic) BOOL allowCopyText;
@property (nonatomic) BOOL allowCopyFile;
@property (nonatomic) BOOL allowEphemeral;
@property (nonatomic) int64_t expireTimeout;

@end

typedef enum {
    SECTION_INFO,
    SECTION_ALLOW_COPY,
    SECTION_EPHEMERAL,
    SECTION_COUNT
} TLTSpaceSettingSection;

typedef enum {
    TAG_ALLOW_COPY_TEXT,
    TAG_ALLOW_COPY_FILE,
    TAG_ALLOW_EPHEMERAL
} TLTSpaceSettingTag;

//
// Implementation: MessageSettingsSpaceViewController
//

#undef LOG_TAG
#define LOG_TAG @"MessageSettingsSpaceViewController"

@implementation MessageSettingsSpaceViewController

- (instancetype)initWithCoder:(NSCoder *)coder {
    DDLogVerbose(@"%@ initWithCoder: %@", LOG_TAG, coder);
    
    self = [super initWithCoder:coder];
    
    if (self) {
        _allowCopyFile = YES;
        _allowCopyText = YES;
        _allowEphemeral = NO;
        _expireTimeout = DEFAULT_TIMEOUT_MESSAGE;
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
    
    self.allowCopyText = self.space.settings.messageCopyAllowed;
    self.allowCopyFile = self.space.settings.fileCopyAllowed;
    self.allowEphemeral = [self.space.settings getBooleanWithName:PROPERTY_ALLOW_EPHEMERAL_MESSAGE defaultValue:NO];
    NSString *expireTimeoutStringValue = [self.space.settings getStringWithName:PROPERTY_TIMEOUT_EPHEMERAL_MESSAGE defaultValue:[NSString stringWithFormat:@"%d", DEFAULT_TIMEOUT_MESSAGE]];
    self.expireTimeout = [expireTimeoutStringValue integerValue];
}

- (void)initWithSettings:(BOOL)allowNotification allowCopyText:(BOOL)allowCopyText allowCopyFile:(BOOL)allowCopyFile allowEphemeral:(BOOL)allowEphemeral expireTimeout:(int64_t)expireTimeout isDefault:(BOOL)isDefault isSecret:(BOOL)isSecret {
    DDLogVerbose(@"%@ initWithSettings:%@ allowCopyText: %@ allowCopyFile: %@ allowEphemeral: %@ expireTimeout: %lld isDefault: %@ isSecret: %@", LOG_TAG, allowNotification ? @"YES" : @"NO", allowCopyText ? @"YES" : @"NO", allowCopyFile ? @"YES" : @"NO", allowEphemeral ? @"YES" : @"NO", expireTimeout, isDefault ? @"YES" : @"NO", isSecret ? @"YES" : @"NO");
    
    self.allowCopyText = allowCopyText;
    self.allowCopyFile = allowCopyFile;
    self.allowEphemeral = allowEphemeral;
    self.expireTimeout = expireTimeout;
}

#pragma mark - EditSpaceServiceDelegate

- (void)onGetContacts:(NSArray *)contacts {
    DDLogVerbose(@"%@ onGetContacts: %@", LOG_TAG, contacts);
    
}

- (void)onGetGroups:(NSArray *)groups {
    DDLogVerbose(@"%@ onGetGroups: %@", LOG_TAG, groups);
    
}

- (void)onCreateProfile:(nonnull TLProfile *)profile {
    DDLogVerbose(@"%@ onCreateProfile: %@", LOG_TAG, profile);
}

- (void)onDeleteSpace:(nonnull NSUUID *)spaceId {
    DDLogVerbose(@"%@ onDeleteSpace: %@", LOG_TAG, spaceId);
}

- (void)onGetSpace:(nonnull TLSpace *)space avatar:(UIImage *)avatar {
    DDLogVerbose(@"%@ onGetSpace: %@", LOG_TAG, space);
}

- (void)onUpdateProfile:(nonnull TLProfile *)profile {
    DDLogVerbose(@"%@ onUpdateProfile: %@", LOG_TAG, profile);
}

- (void)onCreateSpace:(TLSpace *)space {
    DDLogVerbose(@"%@ onCreateSpace: %@", LOG_TAG, space);
    
}

- (void)onUpdateSpace:(nonnull TLSpace *)space {
    DDLogVerbose(@"%@ onUpdateSpace: %@", LOG_TAG, space);

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
    
    if (section == SECTION_INFO) {
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
        case SECTION_ALLOW_COPY:
            sectionName = [NSString stringWithFormat:@"%@", TwinmeLocalizedString(@"settings_view_controller_permissions_title", nil)];
            break;
            
        case SECTION_EPHEMERAL:
            sectionName = [NSString stringWithFormat:@"%@", TwinmeLocalizedString(@"settings_view_controller_ephemeral_section_title", nil)];
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
        case SECTION_ALLOW_COPY:
            sectionName = [NSString stringWithFormat:@"%@", TwinmeLocalizedString(@"settings_view_controller_permissions_title", nil)];
            break;
            
        case SECTION_EPHEMERAL:
            sectionName = [NSString stringWithFormat:@"%@", TwinmeLocalizedString(@"settings_view_controller_ephemeral_section_title", nil)];
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
        case SECTION_INFO:
            numberOfRowsInSection = 1;
            break;
            
        case SECTION_ALLOW_COPY:
            numberOfRowsInSection = 3;
            break;
            
        case SECTION_EPHEMERAL:
            if (self.allowEphemeral) {
                numberOfRowsInSection = 3;
            } else {
                numberOfRowsInSection = 2;
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
        
        NSString *text = @"";
        if (indexPath.section == SECTION_INFO) {
            text = TwinmeLocalizedString(@"settings_space_view_controller_default_value_message", nil);
        } else if (indexPath.section == SECTION_EPHEMERAL) {
            text = TwinmeLocalizedString(@"settings_view_controller_ephemeral_message", nil);
        } else {
            text = TwinmeLocalizedString(@"settings_view_controller_allow_copy_category_title", nil);
        }
        
        [cell bindWithText:text];
        
        return cell;
    } else if (indexPath.section == SECTION_EPHEMERAL && indexPath.row == 2) {
        SettingsValueItemCell *cell = [tableView dequeueReusableCellWithIdentifier:SETTINGS_VALUE_CELL_IDENTIFIER];
        if (!cell) {
            cell = [[SettingsValueItemCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:SETTINGS_VALUE_CELL_IDENTIFIER];
        }
        
        [cell bindWithTitle:TwinmeLocalizedString(@"application_timeout", nil) value:[NSString formatTimeout:self.expireTimeout] hiddenAccessory:YES];
        
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
            case SECTION_ALLOW_COPY:
                if (indexPath.row == 1) {
                    switchState = self.allowCopyText;
                    hiddenSwitch = NO;
                    tag = TAG_ALLOW_COPY_TEXT;
                    title = TwinmeLocalizedString(@"settings_view_controller_allow_copy_text_title", nil);
                    
                    if (self.space && self.space.isManagedSpace) {
                        disableSwitch = YES;
                    }
                } else if (indexPath.row == 2) {
                    switchState = self.allowCopyFile;
                    hiddenSwitch = NO;
                    tag = TAG_ALLOW_COPY_FILE;
                    title = TwinmeLocalizedString(@"settings_view_controller_allow_copy_file_title", nil);
                    if (self.space && self.space.isManagedSpace) {
                        disableSwitch = YES;
                    }
                }
                break;
                
            case SECTION_EPHEMERAL:
                if (indexPath.row == 1) {
                    switchState = self.allowEphemeral;
                    hiddenSwitch = NO;
                    tag = TAG_ALLOW_EPHEMERAL;
                    title = TwinmeLocalizedString(@"settings_view_controller_ephemeral_title", nil);
                    if (self.space && self.space.isManagedSpace) {
                        disableSwitch = YES;
                    }
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
    
    if (indexPath.section == SECTION_EPHEMERAL && self.allowEphemeral && indexPath.row == 2) {
        [self openTimeoutMenu];
    }
}

#pragma mark - SettingsActionDelegate

- (void)switchChangeValue:(SwitchView *)updatedSwitch {
    DDLogVerbose(@"%@ switchChangeValue: %@", LOG_TAG, updatedSwitch);
    
    switch (updatedSwitch.tag) {
        case TAG_ALLOW_COPY_FILE:
            self.allowCopyFile = !self.allowCopyFile;
            break;
            
        case TAG_ALLOW_COPY_TEXT:
            self.allowCopyText = !self.allowCopyText;
            break;
            
        case TAG_ALLOW_EPHEMERAL:
            self.allowEphemeral = !self.allowEphemeral;
            break;
            
        default:
            break;
    }
    
    [self.tableView reloadData];

    [self saveSpaceSettings];
}

#pragma mark - MenuTimeoutDelegate

- (void)cancelMenuSelectValue:(MenuSelectValueView *)menuSelectValueView {
    DDLogVerbose(@"%@ cancelMenu", LOG_TAG);
    
    [menuSelectValueView removeFromSuperview];
}

- (void)selectTimeout:(MenuSelectValueView *)menuSelectValueView uiTimeout:(UITimeout *)uiTimeout {
    DDLogVerbose(@"%@ selectTimeout: %@", LOG_TAG, uiTimeout);
    
    [menuSelectValueView removeFromSuperview];

    self.expireTimeout = uiTimeout.timeout;
    [self.tableView reloadData];
    
    [self saveSpaceSettings];
}

#pragma mark - Private methods

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    self.view.backgroundColor = Design.WHITE_COLOR;
    
    [self setNavigationTitle:TwinmeLocalizedString(@"settings_view_controller_chat_category_title", nil)];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"SettingsItemCell" bundle:nil] forCellReuseIdentifier:SETTINGS_CELL_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"SettingsValueItemCell" bundle:nil] forCellReuseIdentifier:SETTINGS_VALUE_CELL_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"SettingsInformationCell" bundle:nil] forCellReuseIdentifier:SETTINGS_INFORMATION_CELL_IDENTIFIER];
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
        spaceSettings.messageCopyAllowed = self.allowCopyText;
        spaceSettings.fileCopyAllowed = self.allowCopyFile;
        [spaceSettings setBooleanWithName:PROPERTY_ALLOW_EPHEMERAL_MESSAGE value:self.allowEphemeral];
        [spaceSettings setStringWithName:PROPERTY_TIMEOUT_EPHEMERAL_MESSAGE value:[NSString stringWithFormat:@"%lld",self.expireTimeout]];
        [self.editSpaceService updateSpace:spaceSettings avatar:nil largeAvatar:nil];
    }
}

- (void)openTimeoutMenu {
    DDLogVerbose(@"%@ openTimeoutMenu", LOG_TAG);
        
    MenuSelectValueView *menuSelectValueView = [[MenuSelectValueView alloc]init];
    menuSelectValueView.menuSelectValueDelegate = self;
    [self.tabBarController.view addSubview:menuSelectValueView];
    [menuSelectValueView setMenuSelectValueTypeWithType:MenuSelectValueTypeTimeoutEphemeralMessage];
    [menuSelectValueView setSelectedValueWithValue:(int)self.expireTimeout];
    
    [menuSelectValueView openMenu];
}

- (void)finish {
    DDLogVerbose(@"%@ finish", LOG_TAG);
    
    [self.editSpaceService dispose];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)isInformationPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == SECTION_INFO || (indexPath.section == SECTION_ALLOW_COPY && indexPath.row == 0)
        || (indexPath.section == SECTION_EPHEMERAL && indexPath.row == 0)) {
        return YES;
    }
    
    return NO;
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
