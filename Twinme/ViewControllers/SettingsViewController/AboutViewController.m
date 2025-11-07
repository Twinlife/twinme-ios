/*
 *  Copyright (c) 2021 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <Utils/NSString+Utils.h>

#import "AboutViewController.h"
#import "WebViewController.h"
#import "WhatsNewViewController.h"

#import "AboutCell.h"
#import "SettingsInformationCell.h"
#import "TwinmeSettingsItemCell.h"
#import "SettingsSectionHeaderCell.h"
#import "SettingsSectionFooterCell.h"
#import "SettingsValueItemCell.h"
#import "UpdateAvailableCell.h"

#import "LastVersionManager.h"

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static CGFloat DESIGN_UPDTAE_AVAILABLE_HEIGHT = 160;

static const int ABOUT_VIEW_SECTION = 0;
static const int LEGAL_VIEW_SECTION = 1;
static const int OPEN_SOURCE_VIEW_SECTION = 2;

static const int TERMS_OF_SERVICE_ROW = 0;
static const int PRIVACY_POLICY_ROW = 1;

static const int OPEN_SOURCE_ROW = 0;
static const int LICENCES_ROW = 2;

static NSString *HEADER_SETTINGS_CELL_IDENTIFIER = @"HeaderSettingsCellIdentifier";
static NSString *FOOTER_SETTINGS_CELL_IDENTIFIER = @"SettingsSectionFooterCellIdentifier";
static NSString *ABOUT_CELL_IDENTIFIER = @"AboutCellIdentifier";
static NSString *TWINME_SETTINGS_CELL_IDENTIFIER = @"TwinmeSettingsCellIdentifier";
static NSString *SETTINGS_VALUE_CELL_IDENTIFIER = @"SettingsValueCellIdentifier";
static NSString *UPDATE_AVAILABLE_CELL_IDENTIFIER = @"UpdateAvailableCellIdentifier";
static NSString *SETTINGS_INFORMATION_CELL_IDENTIFIER = @"SettingsInformationCellIdentifier";

//
// Interface: AboutViewController
//

@interface AboutViewController ()<UITableViewDelegate, UITableViewDataSource, UpdateVersionDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

//
// Implementation: AboutViewController
//

#undef LOG_TAG
#define LOG_TAG @"AboutViewController"

@implementation AboutViewController

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

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    DDLogVerbose(@"%@ numberOfSectionsInTableView: %@", LOG_TAG, tableView);
    
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath  {
    DDLogVerbose(@"%@ tableView: %@ heightForRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    if (indexPath.section == ABOUT_VIEW_SECTION && indexPath.row == 0) {
        return UITableViewAutomaticDimension;
    } else if (indexPath.section == ABOUT_VIEW_SECTION && indexPath.row == 2) {
        return DESIGN_UPDTAE_AVAILABLE_HEIGHT * Design.HEIGHT_RATIO;
    }
    return Design.SETTING_CELL_HEIGHT;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ heightForHeaderInSection: %ld", LOG_TAG, tableView, (long)section);
    
    if (section == ABOUT_VIEW_SECTION) {
        return CGFLOAT_MIN;
    }
    return Design.SETTING_SECTION_HEIGHT;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ heightForFooterInSection: %ld", LOG_TAG, tableView, (long)section);
    
    if (section == ABOUT_VIEW_SECTION || section == LEGAL_VIEW_SECTION) {
        return CGFLOAT_MIN;
    }
    return Design.SETTING_SECTION_HEIGHT;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ numberOfRowsInSection: %ld", LOG_TAG, tableView, (long)section);
    
    if (section == ABOUT_VIEW_SECTION) {
        return [self.twinmeApplication.lastVersionManager isNewVersionAvailable] ? 3 : 2;
    } else if (section == OPEN_SOURCE_VIEW_SECTION) {
        return 3;
    }
    
    return 2;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ viewForHeaderInSection: %ld", LOG_TAG, tableView, (long)section);
    
    if (section == ABOUT_VIEW_SECTION) {
        return [[UIView alloc]init];
    }
    
    SettingsSectionHeaderCell *settingsSectionHeaderCell = (SettingsSectionHeaderCell *)[tableView dequeueReusableCellWithIdentifier:HEADER_SETTINGS_CELL_IDENTIFIER];
    if (!settingsSectionHeaderCell) {
        settingsSectionHeaderCell = [[SettingsSectionHeaderCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:HEADER_SETTINGS_CELL_IDENTIFIER];
    }
    
    NSString *title = @"";
    
    if (section == LEGAL_VIEW_SECTION) {
        title = TwinmeLocalizedString(@"about_view_controller_legal", nil);
    } else {
        title = TwinmeLocalizedString(@"about_view_controller_open_source", nil);
    }
    
    [settingsSectionHeaderCell bindWithTitle:title backgroundColor:Design.LIGHT_GREY_BACKGROUND_COLOR hideSeparator:NO uppercaseString:YES];
    
    return settingsSectionHeaderCell;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ viewForFooterInSection: %ld", LOG_TAG, tableView, (long)section);
    
    if (section == ABOUT_VIEW_SECTION || section == LEGAL_VIEW_SECTION) {
        return [[UIView alloc]init];
    }
    
    SettingsSectionFooterCell *settingsSectionFooterCell = (SettingsSectionFooterCell *)[tableView dequeueReusableCellWithIdentifier:FOOTER_SETTINGS_CELL_IDENTIFIER];
    if (!settingsSectionFooterCell) {
        settingsSectionFooterCell = [[SettingsSectionFooterCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:FOOTER_SETTINGS_CELL_IDENTIFIER];
    }
    
    [settingsSectionFooterCell bindWithTitle:TwinmeLocalizedString(@"about_view_controller_copyright", nil)];
    
    return settingsSectionFooterCell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ cellForRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    if (indexPath.section == ABOUT_VIEW_SECTION) {
        if (indexPath.row == 0) {
            AboutCell *cell = [tableView dequeueReusableCellWithIdentifier:ABOUT_CELL_IDENTIFIER];
            if (!cell) {
                cell = [[AboutCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ABOUT_CELL_IDENTIFIER];
            }
            
            [cell bindWithText:TwinmeLocalizedString(@"about_view_controller_message", nil)];
            return cell;
        } else if (indexPath.row == 1) {
            SettingsValueItemCell *cell = [tableView dequeueReusableCellWithIdentifier:SETTINGS_VALUE_CELL_IDENTIFIER];
            if (!cell) {
                cell = [[SettingsValueItemCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:SETTINGS_VALUE_CELL_IDENTIFIER];
            }
            
            NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
            [cell bindWithTitle:TwinmeLocalizedString(@"about_view_controller_version", nil) value:version hiddenAccessory:![self.twinmeApplication.lastVersionManager isCurrentVersion]];
            
            return cell;
        } else {
            UpdateAvailableCell *cell = [tableView dequeueReusableCellWithIdentifier:UPDATE_AVAILABLE_CELL_IDENTIFIER];
            if (!cell) {
                cell = [[UpdateAvailableCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:UPDATE_AVAILABLE_CELL_IDENTIFIER];
            }
            
            cell.updateVersionDelegate = self;
            [cell bind];
            
            return cell;
        }
    } else if (indexPath.section == OPEN_SOURCE_VIEW_SECTION && indexPath.row == 1) {
        SettingsInformationCell *cell = [tableView dequeueReusableCellWithIdentifier:SETTINGS_INFORMATION_CELL_IDENTIFIER];
        if (!cell) {
            cell = [[SettingsInformationCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:SETTINGS_INFORMATION_CELL_IDENTIFIER];
        }
                
        [cell bindWithText:TwinmeLocalizedString(@"about_view_controller_open_source_information", nil)];
        
        return cell;
    } else {
        TwinmeSettingsItemCell *cell = [tableView dequeueReusableCellWithIdentifier:TWINME_SETTINGS_CELL_IDENTIFIER];
        if (!cell) {
            cell = [[TwinmeSettingsItemCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:TWINME_SETTINGS_CELL_IDENTIFIER];
        }
        
        NSString *title = @"";
        
        if (indexPath.section == LEGAL_VIEW_SECTION) {
            switch (indexPath.row) {
                case TERMS_OF_SERVICE_ROW:
                    title = TwinmeLocalizedString(@"about_view_controller_terms_of_use", nil);
                    break;
                    
                case PRIVACY_POLICY_ROW:
                    title = TwinmeLocalizedString(@"about_view_controller_privacy_policy", nil);
                    break;
                    
                default:
                    break;
            }
        } else {
            switch (indexPath.row) {
                case OPEN_SOURCE_ROW:
                    title = TwinmeLocalizedString(@"about_view_controller_application_code", nil);
                    break;
                    
                case LICENCES_ROW:
                    title = TwinmeLocalizedString(@"about_view_controller_open_sources_licences", nil);
                    break;
                    
                default:
                    break;
            }
        }
        
        [cell bindWithTitle:title hiddenAccessory:NO disableSetting:NO color:Design.FONT_COLOR_DEFAULT];
        
        return cell;
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ didSelectRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    if (indexPath.section == ABOUT_VIEW_SECTION && indexPath.row == 1) {
        if ([self.twinmeApplication.lastVersionManager isCurrentVersion]) {
            WhatsNewViewController *whatsNewViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"WhatsNewViewController"];
            [whatsNewViewController showInView:self.navigationController];
        }
    } else if (indexPath.section == LEGAL_VIEW_SECTION) {
        if (indexPath.row == TERMS_OF_SERVICE_ROW) {
            WebViewController *webViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"WebViewController"];
            webViewController.fileName = TwinmeLocalizedString(@"terms_of_use_url", nil);
            webViewController.name = TwinmeLocalizedString(@"about_view_controller_terms_of_use", nil);
            [self.navigationController pushViewController:webViewController animated:YES];
        } else if (indexPath.row == PRIVACY_POLICY_ROW) {
            WebViewController *webViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"WebViewController"];
            webViewController.fileName = TwinmeLocalizedString(@"privacy_policy_url", nil);
            webViewController.name = TwinmeLocalizedString(@"about_view_controller_privacy_policy", nil);
            [self.navigationController pushViewController:webViewController animated:YES];
        }
    } else if (indexPath.section == OPEN_SOURCE_VIEW_SECTION) {
        if (indexPath.row == OPEN_SOURCE_ROW) {
            WebViewController *webViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"WebViewController"];
            webViewController.fileName = TwinmeLocalizedString(@"opensource_url", nil);
            webViewController.name = TwinmeLocalizedString(@"about_view_controller_application_code", nil);
            [self.navigationController pushViewController:webViewController animated:YES];
        } else if (indexPath.row == LICENCES_ROW) {
            WebViewController *webViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"WebViewController"];
            webViewController.fileName = TwinmeLocalizedString(@"licenses_url", nil);
            webViewController.name = TwinmeLocalizedString(@"about_view_controller_open_sources_licences", nil);
            [self.navigationController pushViewController:webViewController animated:YES];
        }
    }
}

#pragma mark - UpdateVersionDelegate

- (void)updateAppVersion {
    DDLogVerbose(@"%@ updateAppVersion", LOG_TAG);
    
    WhatsNewViewController *whatsNewViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"WhatsNewViewController"];
    whatsNewViewController.updateMode = YES;
    [whatsNewViewController showInView:self.navigationController];
}

#pragma mark - Private methods

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    self.view.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
    
    [self setNavigationTitle:TwinmeLocalizedString(@"side_menu_view_controller_about", nil)];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerNib:[UINib nibWithNibName:@"AboutCell" bundle:nil] forCellReuseIdentifier:ABOUT_CELL_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"TwinmeSettingsItemCell" bundle:nil] forCellReuseIdentifier:TWINME_SETTINGS_CELL_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"SettingsValueItemCell" bundle:nil] forCellReuseIdentifier:SETTINGS_VALUE_CELL_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"SettingsSectionHeaderCell" bundle:nil] forCellReuseIdentifier:HEADER_SETTINGS_CELL_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"SettingsSectionFooterCell" bundle:nil] forCellReuseIdentifier:FOOTER_SETTINGS_CELL_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"UpdateAvailableCell" bundle:nil] forCellReuseIdentifier:UPDATE_AVAILABLE_CELL_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"SettingsInformationCell" bundle:nil] forCellReuseIdentifier:SETTINGS_INFORMATION_CELL_IDENTIFIER];

    
    self.tableView.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = Design.SETTING_CELL_HEIGHT;
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    [self.tableView reloadData];
}

@end
