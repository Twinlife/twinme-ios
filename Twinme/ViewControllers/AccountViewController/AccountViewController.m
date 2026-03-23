/*
 *  Copyright (c) 2020-2024 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <MobileCoreServices/UTCoreTypes.h>
#import <MobileCoreServices/UTType.h>

#import <Twinlife/TLAccountService.h>
#import <Utils/NSString+Utils.h>

#import "AccountViewController.h"
#import "AccountMigrationScannerViewController.h"
#import "ExportViewController.h"
#import "TypeCleanupViewController.h"
#import "DeleteAccountViewController.h"
#import "RestoreViewController.h"
#import "BackupViewController.h"
#import "BackupsViewController.h"

#import "SettingsSectionHeaderCell.h"
#import "SettingsIconCell.h"

#import "AlertMessageView.h"
#import "DefaultConfirmView.h"
#import "OnboardingConfirmView.h"

#import <TwinmeCommon/Design.h>
#import <TwinmeCommon/TwinmeNavigationController.h>

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

@interface AccountViewController ()<BottomSheetViewDelegate, AlertMessageViewDelegate, UINavigationControllerDelegate, UIDocumentPickerDelegate, UIDocumentInteractionControllerDelegate, SettingsSectionHeaderDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) BOOL verifyBackupMode;
@property (nonatomic) BOOL startOnboardingOnViewAppear;

@end

typedef enum {
    SECTION_TRANSFER,
    SECTION_BACKUP,
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

- (instancetype)initWithCoder:(NSCoder *)coder {
    DDLogVerbose(@"%@ initWithCoder: %@", LOG_TAG, coder);
    
    self = [super initWithCoder:coder];
    
    if (self) {
        _verifyBackupMode = NO;
        _startOnboardingOnViewAppear = NO;
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
    
    if (self.startOnboardingOnViewAppear && [self.twinmeApplication startOnboarding:OnboardingTypeBackupBeta]) {
        self.startOnboardingOnViewAppear = NO;
        [self showBackupBetaInfo:YES];
    }
    
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (void)startOnboarding {
    DDLogVerbose(@"%@ startOnboarding", LOG_TAG);
    
    self.startOnboardingOnViewAppear = YES;
}

#pragma mark - DocumentPickerDelegate

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray <NSURL *>*)urls {
    DDLogVerbose(@"%@ documentPicker: %@ didPickDocumentsAtURLs: %@", LOG_TAG, controller, urls);
    
    if (urls.count == 0) {
        return;
    }
    
    NSNumber *value = nil;
    NSURL *url = [urls firstObject];
    [url getResourceValue:&value forKey:NSURLIsPackageKey error:nil];
    
    NSString *fileExtension = [url pathExtension];
    [self unlockBackup:url];
}

#pragma mark - DocumentInteractionControllerDelegate

- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller {
    
    return self;
}

#pragma mark - AlertMessageViewDelegate

- (void)didCloseAlertMessage:(nonnull AlertMessageView *)alertMessageView {
    DDLogVerbose(@"%@ didCloseAlertMessage: %@", LOG_TAG, alertMessageView);
    
    [alertMessageView closeAlertView];
}

- (void)didFinishCloseAlertMessageAnimation:(nonnull AlertMessageView *)alertMessageView {
    DDLogVerbose(@"%@ didFinishCloseAlertMessageAnimation: %@", LOG_TAG, alertMessageView);
    
    [alertMessageView removeFromSuperview];
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
    
    settingsSectionHeaderCell.delegate = self;
    
    NSString *sectionName = @"";
    BOOL hideSeparator = NO;
    NSString *badgeTitle = nil;
    switch (section) {
        case SECTION_TRANSFER:
            sectionName = TwinmeLocalizedString(@"account_view_controller_transfer_between_devices", nil);
            break;
            
        case SECTION_BACKUP:
            sectionName = TwinmeLocalizedStringFromTable(@"account_view_controller_backup_restore", @"LocalizableBackup", nil);
            badgeTitle = TwinmeLocalizedString(@"application_beta", nil);
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
    
    [settingsSectionHeaderCell bindWithTitle:sectionName backgroundColor:Design.LIGHT_GREY_BACKGROUND_COLOR hideSeparator:hideSeparator uppercaseString:YES badgeTitle:badgeTitle];
    
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
            
        case SECTION_BACKUP:
            numberOfRowsInSection = 4;
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
    } else if (indexPath.section == SECTION_BACKUP) {
        if (indexPath.row == 0) {
            title = TwinmeLocalizedStringFromTable(@"account_view_controller_backup", @"LocalizableBackup", nil);
            icon = [UIImage imageNamed:@"BackupIcon"];
        } else if (indexPath.row == 1) {
            title = TwinmeLocalizedStringFromTable(@"account_view_controller_restore", @"LocalizableBackup", nil);
            icon = [UIImage imageNamed:@"RestoreIcon"];
        } else if (indexPath.row == 2) {
            title = TwinmeLocalizedStringFromTable(@"account_view_controller_backup_verify", @"LocalizableBackup", nil);
            icon = [UIImage imageNamed:@"BackupVerifyIcon"];
        } else {
            title = TwinmeLocalizedStringFromTable(@"account_view_controller_backup_list", @"LocalizableBackup", nil);
            icon = [UIImage imageNamed:@"BackupListIcon"];
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
        [self startAccountMigration:indexPath.row == 0];
    } else if (indexPath.section == SECTION_BACKUP) {
        if (indexPath.row == 3) {
            BackupsViewController *backupsViewController = (BackupsViewController *)[[UIStoryboard storyboardWithName:@"Backup" bundle:nil] instantiateViewControllerWithIdentifier:@"BackupsViewController"];
            [self.navigationController pushViewController:backupsViewController animated:YES];
        } else if (indexPath.row == 1) {
            [self showRestoreWarning];
        } else {
            [self showOnboardingBackup:(int)indexPath.row];
        }
        
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

#pragma mark - SettingsSectionHeaderDelegate

- (void)didTapSectionBadge {
    DDLogVerbose(@"%@ didTapSectionBadge", LOG_TAG);
    
    [self showBackupBetaInfo:NO];
}

#pragma mark - BottomSheetViewDelegate

- (void)didTapConfirm:(nonnull AbstractBottomSheetView *)abstractConfirmView {
    DDLogVerbose(@"%@ didTapConfirm: %@", LOG_TAG, abstractConfirmView);
        
    [abstractConfirmView closeConfirmView];
    
    if ([abstractConfirmView isKindOfClass:[OnboardingConfirmView class]]) {
        if (abstractConfirmView.tag != -1) {
            [self startBackupViewController:(int)abstractConfirmView.tag];
        }
    } else {
        [self startAccountMigration:NO];
    }
    
}

- (void)didTapCancel:(nonnull AbstractBottomSheetView *)abstractConfirmView {
    DDLogVerbose(@"%@ didTapCancel: %@", LOG_TAG, abstractConfirmView);

    [abstractConfirmView closeConfirmView];
    
    if ([abstractConfirmView isKindOfClass:[OnboardingConfirmView class]]) {
        if (abstractConfirmView.tag != -1) {
            OnboardingType onboardingType = [self getOnboardingTypeForIndex:(int)abstractConfirmView.tag];
            [self.twinmeApplication setShowOnboardingType:onboardingType state:NO];
            [self startBackupViewController:(int)abstractConfirmView.tag];
        } else {
            [self.twinmeApplication setShowOnboardingType:OnboardingTypeBackupBeta state:NO];
        }
    } else {
        [self showOnboardingBackup:1];
    }
}

- (void)didClose:(nonnull AbstractBottomSheetView *)abstractConfirmView {
    DDLogVerbose(@"%@ didClose: %@", LOG_TAG, abstractConfirmView);
    
    [abstractConfirmView closeConfirmView];
}

- (void)didFinishCloseAnimation:(nonnull AbstractBottomSheetView *)abstractConfirmView {
    DDLogVerbose(@"%@ didFinishCloseAnimation: %@", LOG_TAG, abstractConfirmView);
    
    [abstractConfirmView removeFromSuperview];
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

- (void)showOnboardingBackup:(int)index {
    DDLogVerbose(@"%@ showOnboardingBackup: %d", LOG_TAG, index);
    
    OnboardingType onboardingType = [self getOnboardingTypeForIndex:index];
    
    if ([self.twinmeApplication startOnboarding:onboardingType]) {
        OnboardingConfirmView *onboardingConfirmView = [[OnboardingConfirmView alloc] init];
        onboardingConfirmView.bottomSheetViewDelegate = self;
        onboardingConfirmView.tag = index;

        UIImage *image = [UIImage imageNamed:@"OnboardingBackup"];
        
        NSString *title;
        NSString *message;
        NSString *action;
        
        if (index == 0) {
            title = TwinmeLocalizedStringFromTable(@"account_view_controller_backup", @"LocalizableBackup", nil);
            message = TwinmeLocalizedStringFromTable(@"backup_view_controller_onboarding", @"LocalizableBackup", nil);
            action = TwinmeLocalizedStringFromTable(@"backup_view_controller_backup", @"LocalizableBackup", nil);
        } else if (index == 1) {
            title = TwinmeLocalizedStringFromTable(@"account_view_controller_restore", @"LocalizableBackup", nil);
            message = [NSString stringWithFormat:@"%@\n\n%@", TwinmeLocalizedStringFromTable(@"restore_view_controller_onboarding",  @"LocalizableBackup", nil), TwinmeLocalizedStringFromTable(@"restore_view_controller_onboarding_words",  @"LocalizableBackup", nil)];
            action = TwinmeLocalizedStringFromTable(@"restore_view_controller_restore",  @"LocalizableBackup", nil);
        } else {
            title = TwinmeLocalizedStringFromTable(@"account_view_controller_backup_verify",  @"LocalizableBackup", nil);
            message = [NSString stringWithFormat:@"%@\n\n%@", TwinmeLocalizedStringFromTable(@"restore_view_controller_onboarding_verify",  @"LocalizableBackup", nil), TwinmeLocalizedStringFromTable(@"backup_view_controller_verify_words",  @"LocalizableBackup", nil)];
            action = TwinmeLocalizedStringFromTable(@"restore_view_controller_select_backup",  @"LocalizableBackup", nil);
        }
        
        [onboardingConfirmView initWithTitle:title message:message image:image action:action actionColor:nil cancel:TwinmeLocalizedString(@"application_do_not_display", nil)];
            
        [self.navigationController.view addSubview:onboardingConfirmView];
        [onboardingConfirmView showConfirmView];
    } else {
        [self startBackupViewController:index];
    }
}

- (void)showBackupBetaInfo:(BOOL)fromBadge {
    DDLogVerbose(@"%@ showBackupBetaInfo", LOG_TAG);
    
    OnboardingConfirmView *onboardingConfirmView = [[OnboardingConfirmView alloc] init];
    onboardingConfirmView.bottomSheetViewDelegate = self;
    onboardingConfirmView.tag = -1;

    UIImage *image = [UIImage imageNamed:@"OnboardingBackup"];
    
    NSString *title = TwinmeLocalizedStringFromTable(@"account_view_controller_backup_restore", @"LocalizableBackup", nil);
    
    NSMutableString *message = [[NSMutableString alloc] initWithString:@""];
    [message appendString:TwinmeLocalizedStringFromTable(@"account_view_controller_backup_beta_part_1", @"LocalizableBackup", nil)];
    [message appendString:@"\n\n"];
    [message appendString:TwinmeLocalizedStringFromTable(@"account_view_controller_backup_beta_part_2", @"LocalizableBackup", nil)];
    [message appendString:@"\n\n"];
    [message appendString:TwinmeLocalizedStringFromTable(@"account_view_controller_backup_beta_part_3", @"LocalizableBackup", nil)];
    
    NSString *action = TwinmeLocalizedString(@"application_ok", nil);
    
    [onboardingConfirmView initWithTitle:title message:message image:image action:action actionColor:nil cancel:TwinmeLocalizedString(@"application_do_not_display", nil)];
    
    if (!fromBadge) {
        [onboardingConfirmView hideCancelAction];
    }
    
    [self.navigationController.view addSubview:onboardingConfirmView];
    [onboardingConfirmView showConfirmView];
}

- (void)showRestoreWarning {
    DDLogVerbose(@"%@ showRestoreWarning", LOG_TAG);
    
    DefaultConfirmView *defaultConfirmView = [[DefaultConfirmView alloc] init];
    defaultConfirmView.bottomSheetViewDelegate = self;
    [defaultConfirmView initWithTitle:TwinmeLocalizedString(@"delete_account_view_controller_warning", nil) message:TwinmeLocalizedStringFromTable(@"restore_view_controller_backup_device_always_signed_in_part_three", @"LocalizableBackup", nil) image:nil avatar:nil action:TwinmeLocalizedString(@"account_view_controller_transfer_from_another_device", nil) actionColor:nil cancel:TwinmeLocalizedStringFromTable(@"account_view_controller_restore", @"LocalizableBackup", nil)];
    [self.navigationController.view addSubview:defaultConfirmView];
    [defaultConfirmView showConfirmView];
}

- (void)startBackupViewController:(int)index {
    DDLogVerbose(@"%@ startBackupViewController: %d", LOG_TAG, index);
    
    if (index == 0) {
        BackupViewController *backupViewController = (BackupViewController *)[[UIStoryboard storyboardWithName:@"Backup" bundle:nil] instantiateViewControllerWithIdentifier:@"BackupViewController"];
        [self.navigationController pushViewController:backupViewController animated:YES];
    } else {
        self.verifyBackupMode = index == 2;
        UIDocumentPickerViewController *documentPicker = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:@[(__bridge NSString*)(kUTTypeData),(__bridge NSString*)(kUTTypeContent)] inMode:UIDocumentPickerModeImport];
        documentPicker.delegate = self;
        documentPicker.modalPresentationStyle = UIModalPresentationFormSheet;
        [self presentViewController:documentPicker animated:YES completion:nil];
    }
}

- (void)startAccountMigration:(BOOL)fromCurrentDevice {
    DDLogVerbose(@"%@ startAccountMigration: %@", LOG_TAG, fromCurrentDevice ? @"YES" : @"NO");
    
    AccountMigrationScannerViewController *accountMigrationScannerViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AccountMigrationScannerViewController"];
    accountMigrationScannerViewController.fromCurrentDevice = fromCurrentDevice;
    [self.navigationController pushViewController:accountMigrationScannerViewController animated:YES];
}

- (void)unlockBackup:(NSURL *)filePath {
    DDLogVerbose(@"%@ unlockBackup", LOG_TAG);
    
    RestoreViewController *restoreViewController = [[UIStoryboard storyboardWithName:@"Backup" bundle:nil] instantiateViewControllerWithIdentifier:@"RestoreViewController"];
    [restoreViewController initWithFilePath:filePath verifyMode:self.verifyBackupMode];
    TwinmeNavigationController *navigationController = [[TwinmeNavigationController alloc] initWithRootViewController:restoreViewController];
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (OnboardingType)getOnboardingTypeForIndex:(int)index {
    DDLogVerbose(@"%@ getOnboardingTypeForIndex: %d", LOG_TAG, index);
    
    switch (index) {
        case 0:
            return OnboardingTypeBackup;
            
        case 1:
            return OnboardingTypeRestore;
            
        default:
            return OnboardingTypeVerifyBackup;
    }
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
