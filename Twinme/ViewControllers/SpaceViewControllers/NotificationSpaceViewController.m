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
#import "NotificationSpaceViewController.h"
#import "MessageSettingsViewController.h"
#import "MessageSettingsSpaceViewController.h"
#import "SpaceAppearanceViewController.h"
#import "SettingsItemCell.h"
#import "SettingsInformationCell.h"
#import "SettingsValueItemCell.h"
#import <TwinmeCommon/EditSpaceService.h>
#import "TwinmeSettingsItemCell.h"
#import <TwinmeCommon/TwinmeNavigationController.h>

#import <TwinmeCommon/Design.h>
#import "SwitchView.h"
#import "AlertView.h"
#import "UIColor+Hex.h"
#import "SpaceSetting.h"

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
// Interface: NotificationSpaceViewController ()
//

@interface NotificationSpaceViewController () <EditSpaceServiceDelegate, SettingsActionDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic) EditSpaceService *editSpaceService;
@property (nonatomic) TLSpace *space;

@property (nonatomic) BOOL displayNotifications;

@property (nonatomic) BOOL canSave;

@end

typedef enum {
    SECTION_INFORMATION,
    SECTION_NOTIFICATIONS,
    SECTION_COUNT
} TLTSpaceSettingSection;

typedef enum {
    TAG_ALLOW_NOTIFICATIONS
} TLTSpaceSettingTag;

//
// Implementation: NotificationSpaceViewController
//

#undef LOG_TAG
#define LOG_TAG @"NotificationSpaceViewController"

@implementation NotificationSpaceViewController

- (instancetype)initWithCoder:(NSCoder *)coder {
    DDLogVerbose(@"%@ initWithCoder: %@", LOG_TAG, coder);
    
    self = [super initWithCoder:coder];
    
    if (self) {
        _displayNotifications = YES;
        _canSave = NO;
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
    self.displayNotifications = [self.space.settings getBooleanWithName:PROPERTY_DISPLAY_NOTIFICATIONS defaultValue:YES];
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
            numberOfRowsInSection = 2;
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
        if (indexPath.section == SECTION_INFORMATION) {
            text = TwinmeLocalizedString(@"settings_space_view_controller_header_message", nil);
        } else {
            text = TwinmeLocalizedString(@"settings_space_view_controller_allow_notifications_message", nil);
        }
        
        [cell bindWithText:text];
        
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
            case SECTION_NOTIFICATIONS:
                switchState = self.displayNotifications;
                hiddenSwitch = NO;
                tag = TAG_ALLOW_NOTIFICATIONS;
                title = TwinmeLocalizedString(@"settings_space_view_controller_allow_notifications", nil);
                if (self.space && self.space.isManagedSpace) {
                    disableSwitch = YES;
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
    
}



#pragma mark - SettingsActionDelegate

- (void)switchChangeValue:(SwitchView *)updatedSwitch {
    DDLogVerbose(@"%@ switchChangeValue: %@", LOG_TAG, updatedSwitch);
    
    switch (updatedSwitch.tag) {
        case TAG_ALLOW_NOTIFICATIONS:
            self.displayNotifications = !self.displayNotifications;
            break;
            
        default:
            break;
    }
    
    [self.tableView reloadData];
    [self updateColor];
    
    [self saveSpaceSettings];
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
        [spaceSettings setBooleanWithName:PROPERTY_DISPLAY_NOTIFICATIONS value:self.displayNotifications];
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
    
    if (indexPath.section == SECTION_INFORMATION || (indexPath.section == SECTION_NOTIFICATIONS && indexPath.row == 1)) {
        return YES;
    }
    
    return NO;
}

@end
