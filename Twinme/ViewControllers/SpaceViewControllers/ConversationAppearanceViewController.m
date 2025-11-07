/*
 *  Copyright (c) 2020-2021 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <Twinme/TLSpace.h>
#import <Twinme/UIImage+Resize.h>

#import "ConversationAppearanceViewController.h"

#import "SettingsSectionHeaderCell.h"
#import "AppearanceColorCell.h"
#import "PreviewAppearanceCell.h"
#import "SubSectionCell.h"
#import "ResetSettingsCell.h"
#import "SettingsInformationCell.h"
#import "PremiumFeatureConfirmView.h"

#import "DeviceAuthorization.h"

#import <Utils/NSString+Utils.h>
#import "UIColor+Hex.h"
#import "UIPremiumFeature.h"

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static const int APPEARANCE_SECTION_COUNT = 1;

static const int CONVERSATIONS_SECTION = 0;

static const int PREVIEW_APPEARANCE_TITLE_ROW = 0;
static const int PREVIEW_APPEARANCE_ROW = 1;
static const int BACKGROUND_APPEARANCE_TITLE_ROW = 2;
static const int BACKGROUND_APPEARANCE_INFO_ROW = 3;
static const int BACKGROUND_COLOR_ROW = 4;
static const int BACKGROUND_TEXT_ROW = 5;
static const int ITEM_APPEARANCE_TITLE_ROW = 6;
static const int ITEM_BACKGROUND_COLOR_ROW = 7;
static const int PEER_ITEM_BACKGROUND_COLOR_ROW = 8;
static const int ITEM_BORDER_COLOR_ROW = 9;
static const int PEER_ITEM_BORDER_COLOR_ROW = 10;
static const int ITEM_TEXT_COLOR_ROW = 11;
static const int PEER_ITEM_TEXT_COLOR_ROW = 12;

static NSString *SUB_SECTION_CELL_IDENTIFIER = @"SubSectionCellIdentifier";
static NSString *PREVIEW_APPEARANCE_CELL_IDENTIFIER = @"PreviewAppearanceCellIdentifier";
static NSString *APPEARANCE_COLOR_CELL_IDENTIFIER = @"AppearanceColorCellIdentifier";
static NSString *HEADER_SETTINGS_CELL_IDENTIFIER = @"HeaderSettingsCellIdentifier";
static NSString *RESET_SETTINGS_CELL_IDENTIFIER = @"ResetSettingsCellIdentifier";
static NSString *SETTINGS_INFORMATION_CELL_IDENTIFIER = @"SettingsInformationCellIdentifier";

static CGFloat DESIGN_SUBSECTION_HEIGHT = 120;
static CGFloat DESIGN_PREVIEW_HEIGHT = 300;
static CGFloat DESIGN_RESET_HEIGHT = 160;

//
// Interface: ConversationAppearanceViewController  ()
//

@interface ConversationAppearanceViewController ()<ConfirmViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic) DisplayMode displayMode;


@end

//
// Implementation: ConversationAppearanceViewController
//

#undef LOG_TAG
#define LOG_TAG @"ConversationAppearanceViewController "

@implementation ConversationAppearanceViewController

- (void)viewDidLoad {
    DDLogVerbose(@"%@ viewDidLoad", LOG_TAG);
    
    [super viewDidLoad];
    
    [self initViews];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    DDLogVerbose(@"%@ numberOfSectionsInTableView: %@", LOG_TAG, tableView);
    
    return APPEARANCE_SECTION_COUNT;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath  {
    DDLogVerbose(@"%@ tableView: %@ heightForRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    if (indexPath.section == CONVERSATIONS_SECTION) {
        if (indexPath.row == PREVIEW_APPEARANCE_TITLE_ROW || indexPath.row == BACKGROUND_APPEARANCE_TITLE_ROW || indexPath.row == ITEM_APPEARANCE_TITLE_ROW) {
            return round(DESIGN_SUBSECTION_HEIGHT * Design.HEIGHT_RATIO);
        } else if (indexPath.row == PREVIEW_APPEARANCE_ROW || indexPath.row == BACKGROUND_APPEARANCE_INFO_ROW) {
            return  UITableViewAutomaticDimension;
        }
    }
    
    return Design.SETTING_CELL_HEIGHT;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ heightForHeaderInSection: %ld", LOG_TAG, tableView, (long)section);
    
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ heightForFooterInSection: %ld", LOG_TAG, tableView, (long)section);
    
    if (section == CONVERSATIONS_SECTION) {
        return DESIGN_RESET_HEIGHT * Design.HEIGHT_RATIO;
    }
    return CGFLOAT_MIN;;
}


- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ viewForFooterInSection: %ld", LOG_TAG, tableView, (long)section);
    
    if (section == CONVERSATIONS_SECTION) {
        ResetSettingsCell *resetAppearanceCell = (ResetSettingsCell *)[tableView dequeueReusableCellWithIdentifier:RESET_SETTINGS_CELL_IDENTIFIER];
        if (!resetAppearanceCell) {
            resetAppearanceCell = [[ResetSettingsCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:RESET_SETTINGS_CELL_IDENTIFIER];
        }
        
        UITapGestureRecognizer *resetViewGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleResetTapGesture:)];
        [resetAppearanceCell.contentView addGestureRecognizer:resetViewGestureRecognizer];
        
        return resetAppearanceCell;
    }
    
    return [[UIView alloc]init];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ numberOfRowsInSection: %ld", LOG_TAG, tableView, (long)section);
    
    NSInteger numberOfRowsInSection;
    switch (section) {
        case CONVERSATIONS_SECTION:
            numberOfRowsInSection = PEER_ITEM_TEXT_COLOR_ROW + 1;
            break;
            
        default:
            numberOfRowsInSection = 0;
            break;
    }
    return numberOfRowsInSection;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ cellForRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    if (indexPath.section == CONVERSATIONS_SECTION) {
        if (indexPath.row == PREVIEW_APPEARANCE_TITLE_ROW || indexPath.row == BACKGROUND_APPEARANCE_TITLE_ROW || indexPath.row == ITEM_APPEARANCE_TITLE_ROW) {
            SubSectionCell *cell = [tableView dequeueReusableCellWithIdentifier:SUB_SECTION_CELL_IDENTIFIER];
            if (!cell) {
                cell = [[SubSectionCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:APPEARANCE_COLOR_CELL_IDENTIFIER];
            }
            
            BOOL hideSeparator = indexPath.row == BACKGROUND_APPEARANCE_TITLE_ROW;            
            [cell bindWithTitle:[self getTitle:indexPath.row].uppercaseString hideSeparator:hideSeparator];
            
            return cell;
        } else if (indexPath.row == PREVIEW_APPEARANCE_ROW) {
            PreviewAppearanceCell *cell = [tableView dequeueReusableCellWithIdentifier:PREVIEW_APPEARANCE_CELL_IDENTIFIER];
            if (!cell) {
                cell = [[PreviewAppearanceCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:PREVIEW_APPEARANCE_CELL_IDENTIFIER];
            }
            
            [cell bind];
            
            return cell;
        } else if (indexPath.row == BACKGROUND_APPEARANCE_INFO_ROW) {
            SettingsInformationCell *cell = [tableView dequeueReusableCellWithIdentifier:SETTINGS_INFORMATION_CELL_IDENTIFIER];
            if (!cell) {
                cell = [[SettingsInformationCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:SETTINGS_INFORMATION_CELL_IDENTIFIER];
            }
            
            [cell bindWithText:TwinmeLocalizedString(@"space_appearance_view_controller_background_message", nil)];
            
            return cell;
        } else {
            AppearanceColorCell *cell = [tableView dequeueReusableCellWithIdentifier:APPEARANCE_COLOR_CELL_IDENTIFIER];
            if (!cell) {
                cell = [[AppearanceColorCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:APPEARANCE_COLOR_CELL_IDENTIFIER];
            }
            
            [cell bindWithColor:[self getColor:indexPath.row] nameColor:[self getTitle:indexPath.row] image:nil];
            
            return cell;
        }
    }
    
    return [[UITableViewCell alloc]init];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ didSelectRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    if ([self isSelectableRow:indexPath]) {
        PremiumFeatureConfirmView *premiumFeatureConfirmView = [[PremiumFeatureConfirmView alloc] init];
        premiumFeatureConfirmView.confirmViewDelegate = self;
        [premiumFeatureConfirmView initWithPremiumFeature:[[UIPremiumFeature alloc]initWithFeatureType:FeatureTypeSpaces] parentViewController:self.navigationController];
        
        NSMutableAttributedString *attributedTitle = [[NSMutableAttributedString alloc] initWithString:TwinmeLocalizedString(@"personalization_view_controller_title", nil) attributes:[NSDictionary dictionaryWithObjectsAndKeys:Design.FONT_BOLD44, NSFontAttributeName, Design.FONT_COLOR_DEFAULT, NSForegroundColorAttributeName, nil]];
        [premiumFeatureConfirmView updateTitle:attributedTitle];
        [self.navigationController.view addSubview:premiumFeatureConfirmView];
        [premiumFeatureConfirmView showConfirmView];
    }
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
    
    self.view.backgroundColor = Design.WHITE_COLOR;
    
    [self setNavigationTitle:TwinmeLocalizedString(@"application_appearance", nil)];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.estimatedRowHeight = round(DESIGN_PREVIEW_HEIGHT * Design.HEIGHT_RATIO);
    [self.tableView registerNib:[UINib nibWithNibName:@"SubSectionCell" bundle:nil] forCellReuseIdentifier:SUB_SECTION_CELL_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"PreviewAppearanceCell" bundle:nil] forCellReuseIdentifier:PREVIEW_APPEARANCE_CELL_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"AppearanceColorCell" bundle:nil] forCellReuseIdentifier:APPEARANCE_COLOR_CELL_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"SettingsSectionHeaderCell" bundle:nil] forCellReuseIdentifier:HEADER_SETTINGS_CELL_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"ResetSettingsCell" bundle:nil] forCellReuseIdentifier:RESET_SETTINGS_CELL_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"SettingsInformationCell" bundle:nil] forCellReuseIdentifier:SETTINGS_INFORMATION_CELL_IDENTIFIER];

    self.tableView.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
}

- (void)handleResetTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleResetTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        [self hapticFeedBack:UIImpactFeedbackStyleMedium];
        
        PremiumFeatureConfirmView *premiumFeatureConfirmView = [[PremiumFeatureConfirmView alloc] init];
        premiumFeatureConfirmView.confirmViewDelegate = self;
        [premiumFeatureConfirmView initWithPremiumFeature:[[UIPremiumFeature alloc]initWithFeatureType:FeatureTypeSpaces] parentViewController:self.navigationController];
        [self.navigationController.view addSubview:premiumFeatureConfirmView];
        [premiumFeatureConfirmView showConfirmView];
    }
}

- (NSString *)getTitle:(NSInteger)row {
    DDLogVerbose(@"%@ getTitle: %ld", LOG_TAG, (long)row);
    
    NSString *title = @"";
    
    switch (row) {
        case PREVIEW_APPEARANCE_TITLE_ROW:
            title = TwinmeLocalizedString(@"space_appearance_view_controller_preview_title", nil);
            break;
            
        case BACKGROUND_APPEARANCE_TITLE_ROW:
            title = TwinmeLocalizedString(@"space_appearance_view_controller_background_title", nil);
            break;
            
        case BACKGROUND_COLOR_ROW:
            title = TwinmeLocalizedString(@"application_color", nil);
            break;
            
        case BACKGROUND_TEXT_ROW:
            title = TwinmeLocalizedString(@"space_appareance_view_controller_background_text_title", nil);
            break;
            
        case ITEM_APPEARANCE_TITLE_ROW:
            title = TwinmeLocalizedString(@"space_appearance_view_controller_container_title", nil);
            break;
            
        case ITEM_BACKGROUND_COLOR_ROW:
            title = TwinmeLocalizedString(@"space_appearance_view_controller_container_background_message", nil);
            break;
            
        case PEER_ITEM_BACKGROUND_COLOR_ROW:
            title = TwinmeLocalizedString(@"space_appearance_view_controller_container_background_peer_message", nil);
            break;
            
        case ITEM_BORDER_COLOR_ROW:
            title = TwinmeLocalizedString(@"space_appearance_view_controller_container_border_message", nil);
            break;
            
        case PEER_ITEM_BORDER_COLOR_ROW:
            title = TwinmeLocalizedString(@"space_appearance_view_controller_container_border_peer_message", nil);
            break;
            
        case ITEM_TEXT_COLOR_ROW:
            title = TwinmeLocalizedString(@"space_appearance_view_controller_container_text_message", nil);
            break;
            
        case PEER_ITEM_TEXT_COLOR_ROW:
            title = TwinmeLocalizedString(@"space_appearance_view_controller_container_text_peer_message", nil);
            break;
            
        default:
            break;
    }
    
    return title;
}

- (UIColor *)getColor:(NSInteger)row {
    DDLogVerbose(@"%@ getColor: %ld", LOG_TAG, (long)row);
    
    UIColor *color = [UIColor clearColor];
    
    switch (row) {
        case BACKGROUND_COLOR_ROW:
            color = Design.CONVERSATION_BACKGROUND_COLOR;
            break;
            
        case BACKGROUND_TEXT_ROW:
            color = Design.TIME_COLOR;
            break;
            
        case ITEM_BACKGROUND_COLOR_ROW:
            color = Design.MAIN_COLOR;
            break;
            
        case PEER_ITEM_BACKGROUND_COLOR_ROW:
            color = Design.GREY_ITEM;
            break;
            
        case ITEM_BORDER_COLOR_ROW:
            color = [UIColor clearColor];
            break;
            
        case PEER_ITEM_BORDER_COLOR_ROW:
            color = [UIColor clearColor];
            break;
            
        case ITEM_TEXT_COLOR_ROW:
            color = [UIColor whiteColor];
            break;
            
        case PEER_ITEM_TEXT_COLOR_ROW:
            color = Design.FONT_COLOR_DEFAULT;
            break;
            
        default:
            break;
    }
    
    return color;
}

- (BOOL)isSelectableRow:(NSIndexPath *)indexPath {
    
    if (indexPath.row < BACKGROUND_COLOR_ROW || indexPath.row == ITEM_APPEARANCE_TITLE_ROW) {
        return NO;
    }
    
    return YES;
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    [self.tableView reloadData];
}

@end
