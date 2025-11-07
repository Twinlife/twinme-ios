/*
 *  Copyright (c) 2022 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import "ConversationSettingsViewController.h"
#import "MessageSettingsViewController.h"
#import "ConversationAppearanceViewController.h"

#import "SettingsSectionHeaderCell.h"
#import "PersonalizationCell.h"
#import "SettingsItemCell.h"
#import "TwinmeSettingsItemCell.h"
#import "EmojiSizeCell.h"

#import "SwitchView.h"
#import <TwinmeCommon/Design.h>

#import <Utils/NSString+Utils.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static NSString *SETTINGS_CELL_IDENTIFIER = @"SettingsCellIdentifier";
static NSString *EMOJI_SIZE_CELL_IDENTIFIER = @"EmojiSizeCellIdentifier";
static NSString *PERSONALIZATION_CELL_IDENTIFIER = @"PersonalizationCellIdentifier";
static NSString *HEADER_SETTINGS_CELL_IDENTIFIER = @"HeaderSettingsCellIdentifier";
static NSString *TWINME_SETTINGS_CELL_IDENTIFIER = @"TwinmeSettingsCellIdentifier";

//
// Interface: ConversationSettingsViewController ()
//

@interface ConversationSettingsViewController () <UITableViewDelegate, UITableViewDataSource, SettingsActionDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic) int SECTION_COUNT;
@property (nonatomic) int COLORS_SECTION;
@property (nonatomic) int EMOJI_SECTION;

@end


//
// Implementation: ConversationSettingsViewController
//

#undef LOG_TAG
#define LOG_TAG @"ConversationSettingsViewController"

@implementation ConversationSettingsViewController

- (void)viewDidLoad {
    DDLogVerbose(@"%@ viewDidLoad", LOG_TAG);
    
    [super viewDidLoad];
    
    _COLORS_SECTION = 0;
    _EMOJI_SECTION = 1;
    _SECTION_COUNT = 2;
    
    [self initViews];
}

#pragma mark - SettingsActionDelegate

- (void)switchChangeValue:(SwitchView *)updatedSwitch {
    DDLogVerbose(@"%@ switchChangeValue: %@", LOG_TAG, updatedSwitch);

    [self.twinmeApplication setVisualizationLinkWithState:updatedSwitch.isOn];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    DDLogVerbose(@"%@ numberOfSectionsInTableView: %@", LOG_TAG, tableView);
    
    return _SECTION_COUNT;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath  {
    DDLogVerbose(@"%@ tableView: %@ heightForRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    if (indexPath.section == _EMOJI_SECTION) {
        return UITableViewAutomaticDimension;
    }
    return Design.SETTING_CELL_HEIGHT;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ heightForHeaderInSection: %ld", LOG_TAG, tableView, (long)section);
    
    if (section == _COLORS_SECTION) {
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
    if (section == _EMOJI_SECTION) {
        sectionName = TwinmeLocalizedString(@"conversation_settings_view_controller_emoji_size", nil);
    }
    
    [settingsSectionHeaderCell bindWithTitle:sectionName backgroundColor:Design.LIGHT_GREY_BACKGROUND_COLOR hideSeparator:NO uppercaseString:YES];
    
    return settingsSectionHeaderCell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ numberOfRowsInSection: %ld", LOG_TAG, tableView, (long)section);
    
    NSInteger numberOfRowsInSection = 0;
    
    if (section == _COLORS_SECTION) {
        numberOfRowsInSection = 1;
    } else if (section == _EMOJI_SECTION) {
        numberOfRowsInSection = 3;
    }
    
    return numberOfRowsInSection;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ cellForRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    if (indexPath.section == _EMOJI_SECTION) {
        EmojiSizeCell *cell = [tableView dequeueReusableCellWithIdentifier:EMOJI_SIZE_CELL_IDENTIFIER];
        if (!cell) {
            cell = [[EmojiSizeCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:EMOJI_SIZE_CELL_IDENTIFIER];
        }
        
        NSString *title = @"";
        BOOL checked = NO;
        EmojiSize emojiSize = EmojiSizeStandard;
        if (indexPath.row == 0) {
            checked = self.twinmeApplication.emojiSize == EmojiSizeSmall;
            emojiSize = EmojiSizeSmall;
            title = TwinmeLocalizedString(@"personalization_view_controller_font_small", nil);
        } else if (indexPath.row == 1) {
            checked = self.twinmeApplication.emojiSize == EmojiSizeStandard;
            emojiSize = EmojiSizeStandard;
            title = TwinmeLocalizedString(@"conversation_view_controller_reduce_menu_lower", nil);
        } else if (indexPath.row == 2) {
            checked = self.twinmeApplication.emojiSize == EmojiSizeLarge;
            emojiSize = EmojiSizeLarge;
            title = TwinmeLocalizedString(@"personalization_view_controller_font_large", nil);
        }
        
        [cell bindWithTitle:title emojiSize:emojiSize checked:checked];
        
        return cell;
    } else {
        TwinmeSettingsItemCell *cell = [tableView dequeueReusableCellWithIdentifier:TWINME_SETTINGS_CELL_IDENTIFIER];
        if (!cell) {
            cell = [[TwinmeSettingsItemCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:TWINME_SETTINGS_CELL_IDENTIFIER];
        }
        
        [cell bindWithTitle:TwinmeLocalizedString(@"conversation_settings_view_controller_background_colors", nil) hiddenAccessory:NO disableSetting:NO color:Design.FONT_COLOR_DEFAULT];
        
        return cell;
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ didSelectRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    if (indexPath.section == _COLORS_SECTION) {
        ConversationAppearanceViewController *conversationAppearanceViewController = (ConversationAppearanceViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"ConversationAppearanceViewController"];
        [conversationAppearanceViewController initWithDefaultSpaceSettings];
        [self.navigationController pushViewController:conversationAppearanceViewController animated:YES];
    } else if (indexPath.section == _EMOJI_SECTION) {
        [self.twinmeApplication setEmojiSizeWithSize:(int)indexPath.row];
        [Design setupFont];
        [self.tableView reloadData];
    }
}

#pragma mark - Private methods

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    self.view.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
    
    [self setNavigationTitle:TwinmeLocalizedString(@"application_appearance", nil)];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = Design.SETTING_CELL_HEIGHT * Design.HEIGHT_RATIO;
    [self.tableView registerNib:[UINib nibWithNibName:@"SettingsItemCell" bundle:nil] forCellReuseIdentifier:SETTINGS_CELL_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"SettingsSectionHeaderCell" bundle:nil] forCellReuseIdentifier:HEADER_SETTINGS_CELL_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"PersonalizationCell" bundle:nil] forCellReuseIdentifier:PERSONALIZATION_CELL_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"TwinmeSettingsItemCell" bundle:nil] forCellReuseIdentifier:TWINME_SETTINGS_CELL_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"EmojiSizeCell" bundle:nil] forCellReuseIdentifier:EMOJI_SIZE_CELL_IDENTIFIER];
    self.tableView.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    [self.tableView reloadData];
}

@end
