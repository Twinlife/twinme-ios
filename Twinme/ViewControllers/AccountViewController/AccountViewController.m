/*
 *  Copyright (c) 2020-2024 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <Twinlife/TLAccountService.h>

#import <Utils/NSString+Utils.h>

#import "AccountViewController.h"
#import "AccountMigrationScannerViewController.h"
#import "ExportViewController.h"
#import "TypeCleanupViewController.h"
#import "DeleteAccountViewController.h"

#import "SettingsSectionHeaderCell.h"
#import "SettingsIconCell.h"

#import <TwinmeCommon/Design.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static NSString *HEADER_SETTINGS_CELL_IDENTIFIER = @"HeaderSettingsCellIdentifier";
static NSString *SETTINGS_ICON_CELL_IDENTIFIER = @"SettingsIconCellIdentifier";

//
// Interface: AccountViewController ()
//

@interface AccountViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

typedef enum {
    SECTION_TRANSFER,
    SECTION_CONVERSATIONS,
    SECTION_DELETE,
    SECTION_COUNT
} TLAccountSection;

//
// Implementation: AccountViewController
//

#undef LOG_TAG
#define LOG_TAG @"AccountViewController"

@implementation AccountViewController

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
    
    return SECTION_COUNT;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath  {
    DDLogVerbose(@"%@ tableView: %@ heightForRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
        
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
        case SECTION_TRANSFER:
            sectionName = TwinmeLocalizedString(@"account_view_controller_transfer_between_devices", nil);
            break;
            
        case SECTION_CONVERSATIONS:
            sectionName = TwinmeLocalizedString(@"account_view_controller_conversations_content_title", nil);
            hideSeparator = YES;
            break;
            
        case SECTION_DELETE:
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
        case SECTION_TRANSFER:
        case SECTION_CONVERSATIONS:
            numberOfRowsInSection = 2;
            break;
            
        case SECTION_DELETE:
            numberOfRowsInSection = 1;
            break;
            
        default:
            numberOfRowsInSection = 0;
            break;
    }
    return numberOfRowsInSection;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ cellForRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    SettingsIconCell *cell = [tableView dequeueReusableCellWithIdentifier:SETTINGS_ICON_CELL_IDENTIFIER];
    if (!cell) {
        cell = [[SettingsIconCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:SETTINGS_ICON_CELL_IDENTIFIER];
    }
            
    NSString *title;
    UIImage *icon;
    UIColor *textColor = Design.FONT_COLOR_DEFAULT;
    UIColor *iconTintColor = Design.UNSELECTED_TAB_COLOR;
    
    if (indexPath.section == SECTION_TRANSFER) {
        if (indexPath.row == 0) {
            title = TwinmeLocalizedString(@"account_view_controller_transfer_from_device", nil);
            icon = [UIImage imageNamed:@"MigrationMyDeviceIcon"];
        } else {
            title = TwinmeLocalizedString(@"account_view_controller_transfer_from_another_device", nil);
            icon = [UIImage imageNamed:@"MigrationAnotherDeviceIcon"];
        }
    } else if (indexPath.section == SECTION_CONVERSATIONS) {
        if (indexPath.row == 0) {
            title = TwinmeLocalizedString(@"account_view_controller_export_content", nil);
            icon = [UIImage imageNamed:@"ShareIcon"];
        } else {
            title = TwinmeLocalizedString(@"show_contact_view_controller_cleanup", nil);
            icon = [UIImage imageNamed:@"CleanUpIcon"];
        }
    } else {
        title = TwinmeLocalizedString(@"delete_account_view_controller_delete", nil);
        icon = [UIImage imageNamed:@"DeleteIcon"];
        textColor = Design.DELETE_COLOR_RED;
        iconTintColor = Design.DELETE_COLOR_RED;
    }
    
    [cell bindWithTitle:title icon:icon textColor:textColor iconTintColor:iconTintColor hideSeparator:NO];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ didSelectRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    if (indexPath.section == SECTION_TRANSFER) {
        AccountMigrationScannerViewController *accountMigrationScannerViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AccountMigrationScannerViewController"];
        accountMigrationScannerViewController.fromCurrentDevice = indexPath.row == 0;
        [self.navigationController pushViewController:accountMigrationScannerViewController animated:YES];
    } else if (indexPath.section == SECTION_CONVERSATIONS) {
        if (indexPath.row == 0) {
            ExportViewController *exportViewController = (ExportViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"ExportViewController"];
            [exportViewController initExportWithCurrentSpace];
            [self.navigationController pushViewController:exportViewController animated:YES];
        } else {
            TypeCleanUpViewController *typeCleanupViewController = (TypeCleanUpViewController *)[[UIStoryboard storyboardWithName:@"iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"TypeCleanUpViewController"];
            [self.navigationController pushViewController:typeCleanupViewController animated:YES];
        }
    } else {
        DeleteAccountViewController *deleteAccountViewController = (DeleteAccountViewController *)[[UIStoryboard storyboardWithName:@"iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"DeleteAccountViewController"];
        [self.navigationController pushViewController:deleteAccountViewController animated:YES];
    }
}

#pragma mark - Private methods

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    self.view.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
    
    [self setNavigationTitle:TwinmeLocalizedString(@"account_view_controller_title", nil)];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = Design.SETTING_CELL_HEIGHT * Design.HEIGHT_RATIO;
    [self.tableView registerNib:[UINib nibWithNibName:@"SettingsSectionHeaderCell" bundle:nil] forCellReuseIdentifier:HEADER_SETTINGS_CELL_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"SettingsIconCell" bundle:nil] forCellReuseIdentifier:SETTINGS_ICON_CELL_IDENTIFIER];
    self.tableView.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
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
