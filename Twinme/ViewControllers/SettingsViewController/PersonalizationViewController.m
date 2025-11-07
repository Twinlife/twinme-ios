/*
 *  Copyright (c) 2020-2021 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <Utils/NSString+Utils.h>

#import "PersonalizationViewController.h"
#import <TwinmeCommon/TwinmeNavigationController.h>
#import "PersonalizationCell.h"
#import "ColorsCell.h"
#import "DefaultTabCell.h"
#import "SettingsInformationCell.h"
#import "SettingsSectionHeaderCell.h"
#import "SettingsItemCell.h"
#import "DisplayModeCell.h"
#import "AppearanceColorCell.h"
#import "TwinmeSettingsItemCell.h"
#import "MessageSettingsViewController.h"
#import "ConversationSettingsViewController.h"
#import "MenuSelectColorView.h"

#import <TwinmeCommon/Design.h>
#import "SwitchView.h"
#import <TwinmeCommon/MainViewController.h>
#import "UIPremiumFeature.h"
#import "PremiumFeatureConfirmView.h"

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static CGFloat DESIGN_DISPLAY_CELL_HEIGHT = 540;

static const int PERSONALIZATION_SECTION_COUNT = 5;

static const int DEFAULT_TAB_SECTION = 0;
static const int MODE_SECTION = 1;
static const int COLOR_SECTION = 2;
static const int FONT_SECTION = 3;
static const int HAPTIC_FEEDBACK_SECTION = 4;

static NSString *SETTINGS_CELL_IDENTIFIER = @"SettingsCellIdentifier";
static NSString *PERSONALIZATION_CELL_IDENTIFIER = @"PersonalizationCellIdentifier";
static NSString *COLORS_CELL_IDENTIFIER = @"ColorsCellIdentifier";
static NSString *HEADER_SETTINGS_CELL_IDENTIFIER = @"HeaderSettingsCellIdentifier";
static NSString *SETTINGS_INFORMATION_CELL_IDENTIFIER = @"SettingsInformationCellIdentifier";
static NSString *DEFAULT_TAB_CELL_IDENTIFIER = @"DefaultTabCellIdentifier";
static NSString *DISPLAY_MODE_CELL_IDENTIFIER = @"DisplayModeCellIdentifier";
static NSString *APPEARANCE_COLOR_CELL_IDENTIFIER = @"AppearanceColorCellIdentifier";
static NSString *TWINME_SETTINGS_CELL_IDENTIFIER = @"TwinmeSettingsCellIdentifier";

//
// Interface: PersonalizationViewController ()
//

@interface PersonalizationViewController () <PersonalizationDelegate, SettingsActionDelegate, DisplayModeDelegate, MenuSelectColorDelegate, ConfirmViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic) DisplayMode displayMode;
@property (nonatomic) FontSize fontSize;

@property (nonatomic) MenuSelectColorView *menuSelectColorView;

@property (nonatomic) BOOL keyboardHidden;

@end

//
// Implementation: PersonalizationViewController
//

#undef LOG_TAG
#define LOG_TAG @"PersonalizationViewController"

@implementation PersonalizationViewController

- (instancetype)initWithCoder:(NSCoder *)coder {
    DDLogVerbose(@"%@ initWithCoder: %@", LOG_TAG, coder);
    
    self = [super initWithCoder:coder];
    
    if (self) {
        _keyboardHidden = YES;
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


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    DDLogVerbose(@"%@ numberOfSectionsInTableView: %@", LOG_TAG, tableView);
    
    return PERSONALIZATION_SECTION_COUNT;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath  {
    DDLogVerbose(@"%@ tableView: %@ heightForRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    if ([self isInformationPath:indexPath]) {
        return UITableViewAutomaticDimension;
    } else if (indexPath.section == MODE_SECTION && indexPath.row == 1) {
        return DESIGN_DISPLAY_CELL_HEIGHT * Design.HEIGHT_RATIO;
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
        case COLOR_SECTION:
            sectionName = TwinmeLocalizedString(@"application_color", nil);
            break;
            
        case DEFAULT_TAB_SECTION:
            sectionName = TwinmeLocalizedString(@"personalization_view_controller_start_tab_title", nil);
            hideSeparator = YES;
            break;
            
        case MODE_SECTION:
            sectionName = TwinmeLocalizedString(@"personalization_view_controller_mode", nil);
            break;
            
        case HAPTIC_FEEDBACK_SECTION:
            sectionName = TwinmeLocalizedString(@"personalization_view_controller_haptic_feedback", nil);
            hideSeparator = YES;
            break;
            
        case FONT_SECTION:
            sectionName = TwinmeLocalizedString(@"personalization_view_controller_font", nil);
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
        case COLOR_SECTION:
        case DEFAULT_TAB_SECTION:
        case MODE_SECTION:
            numberOfRowsInSection = 2;
            break;
            
        case HAPTIC_FEEDBACK_SECTION:
            numberOfRowsInSection = 4;
            break;
            
        case FONT_SECTION:
            numberOfRowsInSection = 4;
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
        if (indexPath.section == DEFAULT_TAB_SECTION) {
            text = TwinmeLocalizedString(@"personalization_view_controller_start_tab_information", nil);
        } else {
            text = TwinmeLocalizedString(@"personalization_view_controller_haptic_feedback_message", nil);
        }
        [cell bindWithText:text];
        return cell;
    }
    if (indexPath.section == DEFAULT_TAB_SECTION) {
        DefaultTabCell *cell = [tableView dequeueReusableCellWithIdentifier:DEFAULT_TAB_CELL_IDENTIFIER];
        if (!cell) {
            cell = [[DefaultTabCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:DEFAULT_TAB_CELL_IDENTIFIER];
        }
        
        [cell bind];
        return cell;
    } else if (indexPath.section == FONT_SECTION) {
        PersonalizationCell *cell = [tableView dequeueReusableCellWithIdentifier:PERSONALIZATION_CELL_IDENTIFIER];
        if (!cell) {
            cell = [[PersonalizationCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:PERSONALIZATION_CELL_IDENTIFIER];
        }
        
        NSString *title = @"";
        BOOL checked = NO;
        if (indexPath.row == 0) {
            checked = self.twinmeApplication.fontSize == FontSizeSystem;
            title = TwinmeLocalizedString(@"personalization_view_controller_system", nil);
        } else if (indexPath.row == 1) {
            checked = self.twinmeApplication.fontSize == FontSizeSmall;
            title = TwinmeLocalizedString(@"personalization_view_controller_font_small", nil);
        } else if (indexPath.row == 2) {
            checked = self.twinmeApplication.fontSize == FontSizeLarge;
            title = TwinmeLocalizedString(@"personalization_view_controller_font_large", nil);
        } else if (indexPath.row == 3) {
            checked = self.twinmeApplication.fontSize == FontSizeExtraLarge;
            title = TwinmeLocalizedString(@"personalization_view_controller_font_extra_large", nil);
        }
        
        [cell bindWithTitle:title checked:checked];
        
        return cell;
    } else if (indexPath.section == COLOR_SECTION) {
        if (indexPath.row == 0) {
            AppearanceColorCell *cell = [tableView dequeueReusableCellWithIdentifier:APPEARANCE_COLOR_CELL_IDENTIFIER];
            if (!cell) {
                cell = [[AppearanceColorCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:APPEARANCE_COLOR_CELL_IDENTIFIER];
            }
            
            [cell bindWithColor:Design.MAIN_COLOR nameColor:TwinmeLocalizedString(@"application_theme", nil) image:nil];
            
            return cell;
        } else {
            TwinmeSettingsItemCell *cell = [tableView dequeueReusableCellWithIdentifier:TWINME_SETTINGS_CELL_IDENTIFIER];
            if (!cell) {
                cell = [[TwinmeSettingsItemCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:TWINME_SETTINGS_CELL_IDENTIFIER];
            }
            
            [cell bindWithTitle:TwinmeLocalizedString(@"conversations_view_controller_title", nil) hiddenAccessory:NO disableSetting:NO color:Design.FONT_COLOR_DEFAULT];
            
            return cell;
        }
    } else if (indexPath.section == MODE_SECTION) {
        
        if (indexPath.row == 1) {
            DisplayModeCell *cell = [tableView dequeueReusableCellWithIdentifier:DISPLAY_MODE_CELL_IDENTIFIER];
            if (!cell) {
                cell = [[DisplayModeCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:DISPLAY_MODE_CELL_IDENTIFIER];
            }
            
            cell.delegate = self;
            
            [cell bind:self.twinmeApplication.displayMode];
            
            return cell;
        } else {
            SettingsItemCell *cell = [tableView dequeueReusableCellWithIdentifier:SETTINGS_CELL_IDENTIFIER];
            if (!cell) {
                cell = [[SettingsItemCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:SETTINGS_CELL_IDENTIFIER];
            }
            
            cell.settingsActionDelegate = self;
            
            [cell bindWithTitle:TwinmeLocalizedString(@"personalization_view_controller_system", nil) icon:nil stateSwitch:self.twinmeApplication.displayMode == DisplayModeSystem tagSwitch:0 hiddenSwitch:NO disableSwitch:NO backgroundColor:Design.WHITE_COLOR hiddenSeparator:NO];
            return cell;
        }
    } else {
        PersonalizationCell *cell = [tableView dequeueReusableCellWithIdentifier:PERSONALIZATION_CELL_IDENTIFIER];
        if (!cell) {
            cell = [[PersonalizationCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:PERSONALIZATION_CELL_IDENTIFIER];
        }
        
        NSString *title = @"";
        BOOL checked = NO;
        if (indexPath.row == 1) {
            checked = self.twinmeApplication.hapticFeedbackMode == HapticFeedbackModeSystem;
            title = TwinmeLocalizedString(@"personalization_view_controller_system", nil);
        } else if (indexPath.row == 2) {
            checked = self.twinmeApplication.hapticFeedbackMode == HapticFeedbackModeOn;
            title = TwinmeLocalizedString(@"application_on", nil);
        } else if (indexPath.row == 3) {
            checked = self.twinmeApplication.hapticFeedbackMode == HapticFeedbackModeOff;
            title = TwinmeLocalizedString(@"application_off", nil);
        }
        
        [cell bindWithTitle:title checked:checked];
        
        return cell;
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ didSelectRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    if (indexPath.section == HAPTIC_FEEDBACK_SECTION && indexPath.row != 0) {
        [self.twinmeApplication setHapticFeedbackModeWithMode:(int)indexPath.row - 1];
        [self hapticFeedBack:UIImpactFeedbackStyleHeavy];
        [self.tableView reloadData];
    } else if (indexPath.section == FONT_SECTION) {
        [self.twinmeApplication setFontSizeWithSize:(int)indexPath.row];
        [Design setupFont];
        [self.tableView reloadData];
    } else if (indexPath.section == COLOR_SECTION) {
        if (indexPath.row == 0) {
            [self openMenuColor:TwinmeLocalizedString(@"application_theme", nil)];
        } else {
            ConversationSettingsViewController *conversationSettingsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ConversationSettingsViewController"];
            [self.navigationController pushViewController:conversationSettingsViewController animated:YES];
        }
    }
}

#pragma mark - SettingsActionDelegate

- (void)switchChangeValue:(SwitchView *)updatedSwitch {
    DDLogVerbose(@"%@ switchChangeValue: %@", LOG_TAG, updatedSwitch);
    
    if (updatedSwitch.isOn) {
        [self.twinmeApplication setDisplayModeWithMode:DisplayModeSystem];
    } else {
        if (@available(iOS 13.0, *)) {
            if ([UIScreen mainScreen].traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark){
                [self.twinmeApplication setDisplayModeWithMode:DisplayModeDark];
            } else {
                [self.twinmeApplication setDisplayModeWithMode:DisplayModeLight];
            }
        }
        else {
            [self.twinmeApplication setDisplayModeWithMode:DisplayModeLight];
        }
    }
    
    [Design setupColors];
    [self updateColor];
    [self.tableView reloadData];
}

#pragma mark - DisplayModeDelegate

- (void)didSelectMode:(DisplayMode)displayMode {
    DDLogVerbose(@"%@ didSelectMode: %u", LOG_TAG, displayMode);
    
    [self.twinmeApplication setDisplayModeWithMode:displayMode];
    [Design setupColors];
    [self updateColor];
    [self.tableView reloadData];
}

#pragma mark - PersonalizationDelegate

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    TwinmeNavigationController *twinmeNavigationController = (TwinmeNavigationController *)self.navigationController;
    [twinmeNavigationController setNavigationBarStyle];
    
    ApplicationDelegate *delegate = (ApplicationDelegate *)[[UIApplication sharedApplication] delegate];
    MainViewController *mainViewController = delegate.mainViewController;
    [mainViewController updateColor];
    [mainViewController refreshTab];
    
    self.view.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
    self.tableView.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
    
    [self.tableView reloadData];
}

#pragma mark - MenuSelectColorDelegate

- (void)enterColor:(MenuSelectColorView *)menuSelectColorView {
    DDLogVerbose(@"%@ enterColor", LOG_TAG);
        
    PremiumFeatureConfirmView *premiumFeatureConfirmView = [[PremiumFeatureConfirmView alloc] init];
    premiumFeatureConfirmView.confirmViewDelegate = self;
    [premiumFeatureConfirmView initWithPremiumFeature:[[UIPremiumFeature alloc]initWithFeatureType:FeatureTypeSpaces] parentViewController:self.navigationController];
    [self.tabBarController.view addSubview:premiumFeatureConfirmView];
    [premiumFeatureConfirmView showConfirmView];
}

- (void)cancelMenuSelectColor:(MenuSelectColorView *)menuSelectColorView {
    DDLogVerbose(@"%@ cancelMenuSelectColor", LOG_TAG);
    
    [menuSelectColorView removeFromSuperview];
    self.menuSelectColorView = nil;
}

- (void)selectColor:(MenuSelectColorView *)menuSelectColorView color:(NSString *)color {
    DDLogVerbose(@"%@ selectColor", LOG_TAG);
    
    [menuSelectColorView removeFromSuperview];
    self.menuSelectColorView = nil;
    
    [Design setMainColor:color];
    [self updateColor];
}

- (void)resetColor:(MenuSelectColorView *)menuSelectColorView {
    DDLogVerbose(@"%@ resetColor", LOG_TAG);
    
    [menuSelectColorView removeFromSuperview];
    self.menuSelectColorView = nil;
    
    [Design setMainColor:Design.DEFAULT_COLOR];
    [self updateColor];
}

#pragma mark - ConfirmViewDelegate

- (void)didTapConfirm:(nonnull AbstractConfirmView *)abstractConfirmView {
    DDLogVerbose(@"%@ didTapConfirm: %@", LOG_TAG, abstractConfirmView);
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:TwinmeLocalizedString(@"twinme_plus_link", nil)] options:@{} completionHandler:nil];

    [abstractConfirmView closeConfirmView];
}

- (void)didTapCancel:(nonnull AbstractConfirmView *)abstractConfirmView {
    DDLogVerbose(@"%@ didTapCancel: %@", LOG_TAG, abstractConfirmView);
    
    [abstractConfirmView closeConfirmView];
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
    
    [self setNavigationTitle:TwinmeLocalizedString(@"application_appearance", nil)];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = Design.SETTING_CELL_HEIGHT;
    [self.tableView registerNib:[UINib nibWithNibName:@"PersonalizationCell" bundle:nil] forCellReuseIdentifier:PERSONALIZATION_CELL_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"ColorsCell" bundle:nil] forCellReuseIdentifier:COLORS_CELL_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"SettingsSectionHeaderCell" bundle:nil] forCellReuseIdentifier:HEADER_SETTINGS_CELL_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"DefaultTabCell" bundle:nil] forCellReuseIdentifier:DEFAULT_TAB_CELL_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"SettingsInformationCell" bundle:nil] forCellReuseIdentifier:SETTINGS_INFORMATION_CELL_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"DisplayModeCell" bundle:nil] forCellReuseIdentifier:DISPLAY_MODE_CELL_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"SettingsItemCell" bundle:nil] forCellReuseIdentifier:SETTINGS_CELL_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"AppearanceColorCell" bundle:nil] forCellReuseIdentifier:APPEARANCE_COLOR_CELL_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"TwinmeSettingsItemCell" bundle:nil] forCellReuseIdentifier:TWINME_SETTINGS_CELL_IDENTIFIER];
    self.tableView.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
}

- (void)openMenuColor:(NSString *)color {
    DDLogVerbose(@"%@ openMenuColor: %@", LOG_TAG, color);
        
    if (!self.menuSelectColorView) {
        self.menuSelectColorView = [[MenuSelectColorView alloc]init];
        self.menuSelectColorView.menuSelectColorDelegate = self;
        [self.tabBarController.view addSubview:self.menuSelectColorView];
        [self.menuSelectColorView openMenu:Design.MAIN_COLOR title:color defaultColor:Design.DEFAULT_COLOR];
    }
}

- (BOOL)isInformationPath:(NSIndexPath *)indexPath {
    
    if ((indexPath.section == HAPTIC_FEEDBACK_SECTION || indexPath.section == DEFAULT_TAB_SECTION) && indexPath.row == 0) {
        return YES;
    }
    
    return NO;
}

- (void)closeMenu {
    DDLogVerbose(@"%@ closeMenu", LOG_TAG);
    
    self.menuSelectColorView.hidden = YES;
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    [self.tableView reloadData];
}

@end
