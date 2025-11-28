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
#import "SpaceAppearanceViewController.h"
#import "MessageSettingsViewController.h"
#import "MessageSettingsSpaceViewController.h"
#import "ConversationAppearanceViewController.h"
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
static NSString *APPEARANCE_COLOR_CELL_IDENTIFIER = @"AppearanceColorCellIdentifier";
static NSString *DISPLAY_MODE_CELL_IDENTIFIER = @"DisplayModeCellIdentifier";

static const CGFloat DESIGN_SECTION_HEIGHT = 100;
static CGFloat DESIGN_DISPLAY_CELL_HEIGHT = 540;

//
// Interface: SpaceAppearanceViewController ()
//

@interface SpaceAppearanceViewController () <EditSpaceServiceDelegate, SettingsActionDelegate, MenuSelectColorDelegate, DisplayModeDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic) MenuSelectColorView *menuSelectColorView;

@property (nonatomic) EditSpaceService *editSpaceService;
@property (nonatomic) TLSpace *space;
@property (nonatomic) CustomAppearance *customAppearance;
@property (nonatomic) DisplayMode displayMode;

@property (nonatomic) BOOL canSave;

@property (nonatomic) BOOL keyboardHidden;

@end

typedef enum {
    SECTION_INFORMATION,
    SECTION_MODE,
    SECTION_APPEARANCE,
    SECTION_COUNT
} TLTSpaceSettingSection;

typedef enum {
    TAG_DISPLAY_MODE
} TLTSpaceSettingTag;

//
// Implementation: SpaceAppearanceViewController
//

#undef LOG_TAG
#define LOG_TAG @"SpaceAppearanceViewController"

@implementation SpaceAppearanceViewController

- (instancetype)initWithCoder:(NSCoder *)coder {
    DDLogVerbose(@"%@ initWithCoder: %@", LOG_TAG, coder);
    
    self = [super initWithCoder:coder];
    
    if (self) {
        _canSave = NO;
        _keyboardHidden = NO;
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    DDLogVerbose(@"%@ viewWillDisappear: %@", LOG_TAG, animated ? @"YES" : @"NO");
    
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    DDLogVerbose(@"%@ keyboardWillShow: %@", LOG_TAG, notification);
    
    if (!self.keyboardHidden) {
        return;
    }
    
    self.keyboardHidden = NO;
    NSDictionary *info = [notification userInfo];
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    if ([self.twinmeApplication getDefaultKeyboardHeight] != keyboardSize.height) {
        [self.twinmeApplication setDefaultKeyboardHeight:keyboardSize.height];
    }
    
    if (self.menuSelectColorView) {
        [self.menuSelectColorView updateKeyboard:keyboardSize.height];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification {
    DDLogVerbose(@"%@ keyboardWillHide: %@", LOG_TAG, notification);
    
    self.keyboardHidden = YES;
    
    if (self.menuSelectColorView) {
        [self.menuSelectColorView updateKeyboard:0];
    }
}

- (void)initWithSpace:(TLSpace *)space {
    DDLogVerbose(@"%@ initWithSpace: %@", LOG_TAG, space);
    
    self.space = space;
    self.customAppearance = [[CustomAppearance alloc]initWithSpaceSettings:self.space.settings];

    self.displayMode = [[self.space.settings getStringWithName:PROPERTY_DISPLAY_MODE defaultValue:[self.twinmeContext.defaultSpaceSettings getStringWithName:PROPERTY_DISPLAY_MODE defaultValue:[NSString stringWithFormat:@"%d",DisplayModeSystem]]] intValue];
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

    if ([space.uuid isEqual:self.currentSpace.uuid]) {
        if (![Design.MAIN_STYLE isEqualToString:space.settings.style]) {
            [Design setMainColor:space.settings.style];
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
        case SECTION_MODE:
            sectionName = TwinmeLocalizedString(@"personalization_view_controller_mode", nil).uppercaseString;
            break;
            
        case SECTION_APPEARANCE:
            sectionName = TwinmeLocalizedString(@"application_appearance", nil).uppercaseString;
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
        case SECTION_MODE:
            sectionName = TwinmeLocalizedString(@"personalization_view_controller_mode", nil).uppercaseString;
            break;
            
        case SECTION_APPEARANCE:
            sectionName = TwinmeLocalizedString(@"application_appearance", nil).uppercaseString;
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
            
        case SECTION_MODE:
        case SECTION_APPEARANCE:
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
    } else if (indexPath.section == SECTION_MODE && indexPath.row == 1) {
        return DESIGN_DISPLAY_CELL_HEIGHT * Design.HEIGHT_RATIO;
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
    } else if (indexPath.section == SECTION_MODE) {
        
        if (indexPath.row == 1) {
            DisplayModeCell *cell = [tableView dequeueReusableCellWithIdentifier:DISPLAY_MODE_CELL_IDENTIFIER];
            if (!cell) {
                cell = [[DisplayModeCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:DISPLAY_MODE_CELL_IDENTIFIER];
            }
            
            cell.delegate = self;
            
            [cell bind:self.displayMode defaultColor:[self.customAppearance getMainColor]];
            
            return cell;
        } else {
            SettingsItemCell *cell = [tableView dequeueReusableCellWithIdentifier:SETTINGS_CELL_IDENTIFIER];
            if (!cell) {
                cell = [[SettingsItemCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:SETTINGS_CELL_IDENTIFIER];
            }
            
            cell.settingsActionDelegate = self;
            
            [cell bindWithTitle:TwinmeLocalizedString(@"personalization_view_controller_system", nil) icon:nil stateSwitch:self.displayMode == DisplayModeSystem tagSwitch:TAG_DISPLAY_MODE hiddenSwitch:NO disableSwitch:NO backgroundColor:Design.WHITE_COLOR hiddenSeparator:NO];
            
            return cell;
        }
    } else {
        if (indexPath.row == 0) {
            AppearanceColorCell *cell = [tableView dequeueReusableCellWithIdentifier:APPEARANCE_COLOR_CELL_IDENTIFIER];
            if (!cell) {
                cell = [[AppearanceColorCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:APPEARANCE_COLOR_CELL_IDENTIFIER];
            }
            
            UIColor *color;
            if (self.space.settings.style) {
                color = [UIColor colorWithHexString:self.space.settings.style alpha:1.0];
            } else {
                color = Design.MAIN_COLOR;
            }
            
            [cell bindWithColor:color nameColor:TwinmeLocalizedString(@"space_appearance_view_controller_theme", nil) image:nil];
            
            return cell;
        } else {
            TwinmeSettingsItemCell *cell = [tableView dequeueReusableCellWithIdentifier:TWINME_SETTINGS_CELL_IDENTIFIER];
            if (!cell) {
                cell = [[TwinmeSettingsItemCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:TWINME_SETTINGS_CELL_IDENTIFIER];
            }
        
            [cell bindWithTitle:TwinmeLocalizedString(@"conversations_view_controller_title", nil) hiddenAccessory:NO disableSetting:NO color:Design.FONT_COLOR_DEFAULT];
            
            return cell;
        }
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ didSelectRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    if (indexPath.section == SECTION_APPEARANCE) {
        if (indexPath.row == 0) {
            [self openMenuColor:TwinmeLocalizedString(@"space_appearance_view_controller_theme", nil)];
        } else {
            ConversationAppearanceViewController *conversationAppearanceViewController = (ConversationAppearanceViewController *)[[UIStoryboard storyboardWithName:@"iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"ConversationAppearanceViewController"];
            [conversationAppearanceViewController initWithSpace:self.space];
            [self.navigationController pushViewController:conversationAppearanceViewController animated:YES];
        }
    }
}

#pragma mark - DisplayModeDelegate

- (void)didSelectMode:(DisplayMode)displayMode {
    DDLogVerbose(@"%@ didSelectMode: %u", LOG_TAG, displayMode);
    
    self.displayMode = displayMode;
    
    if ([self.currentSpace.uuid isEqual:self.space.uuid]) {
        [Design setupColors:self.displayMode];
    }
    
    [self.tableView reloadData];
    [self updateColor];
    [self saveSpaceSettings];
}

#pragma mark - MenuSelectColorDelegate

- (void)cancelMenuSelectColor:(MenuSelectColorView *)menuSelectColorView {
    DDLogVerbose(@"%@ cancelMenuSelectColor", LOG_TAG);
    
    [menuSelectColorView removeFromSuperview];
    self.menuSelectColorView = nil;
}

- (void)selectColor:(MenuSelectColorView *)menuSelectColorView color:(NSString *)color {
    DDLogVerbose(@"%@ selectColor", LOG_TAG);
    
    [menuSelectColorView removeFromSuperview];
    self.menuSelectColorView = nil;
    
    [self.customAppearance setMainColor:color];
    [self.customAppearance setDefaultMessageBackgroundColor:[UIColor colorWithHexString:color alpha:1.0]];
    [self.editSpaceService updateSpace:[self.customAppearance getSpaceSettings] avatar:nil largeAvatar:nil];
    
    [self.tableView reloadData];
    [self updateColor];
}

- (void)resetColor:(MenuSelectColorView *)menuSelectColorView {
    DDLogVerbose(@"%@ resetColor", LOG_TAG);
    
    [self selectColor:menuSelectColorView color:Design.DEFAULT_COLOR];
}

#pragma mark - SettingsActionDelegate

- (void)switchChangeValue:(SwitchView *)updatedSwitch {
    DDLogVerbose(@"%@ switchChangeValue: %@", LOG_TAG, updatedSwitch);
    
    switch (updatedSwitch.tag) {
        case TAG_DISPLAY_MODE:
            if (updatedSwitch.isOn) {
                self.displayMode = DisplayModeSystem;
            } else {
                if (@available(iOS 13.0, *)) {
                    if ([UIScreen mainScreen].traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark){
                        self.displayMode = DisplayModeDark;
                    } else {
                        self.displayMode = DisplayModeLight;
                    }
                }
                else {
                    self.displayMode = DisplayModeLight;
                }
            }
            
            if ([self.currentSpace.uuid isEqual:self.space.uuid]) {
                [Design setupColors:self.displayMode];
            }
            
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
    [self.tableView registerNib:[UINib nibWithNibName:@"AppearanceColorCell" bundle:nil] forCellReuseIdentifier:APPEARANCE_COLOR_CELL_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"TwinmeSettingsItemCell" bundle:nil] forCellReuseIdentifier:TWINME_SETTINGS_CELL_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"DisplayModeCell" bundle:nil] forCellReuseIdentifier:DISPLAY_MODE_CELL_IDENTIFIER];
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
        TLSpaceSettings *spaceSettings = [self.customAppearance getSpaceSettings];
        [spaceSettings setStringWithName:PROPERTY_DISPLAY_MODE value:[NSString stringWithFormat:@"%d", self.displayMode]];
        [self.editSpaceService updateSpace:spaceSettings avatar:nil largeAvatar:nil];
    }
}

- (void)finish {
    DDLogVerbose(@"%@ finish", LOG_TAG);
    
    [self.editSpaceService dispose];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)openMenuColor:(NSString *)color {
    DDLogVerbose(@"%@ openMenuColor: %@", LOG_TAG, color);
    
    if (!self.menuSelectColorView) {
        self.menuSelectColorView = [[MenuSelectColorView alloc]init];
        self.menuSelectColorView.menuSelectColorDelegate = self;
        [self.tabBarController.view addSubview:self.menuSelectColorView];
        
        UIColor *mainColor = Design.MAIN_COLOR;
        if (self.space.settings.style) {
            mainColor = [UIColor colorWithHexString:self.space.settings.style alpha:1.0];
        }
        
        [self.menuSelectColorView openMenu:mainColor title:color defaultColor:Design.DEFAULT_COLOR spaceSettings:self.currentSpaceSettings];
    }
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

@end
