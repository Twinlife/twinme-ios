/*
 *  Copyright (c) 2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import "AccountViewController.h"
#import "BackupViewController.h"
#import "SuccessBackupViewController.h"

#import "BackupFooterCell.h"
#import "BackupConfirmCell.h"
#import "BackupContentCell.h"
#import "BackupActionCell.h"
#import "BackupWordsCell.h"
#import "BackupWaitingCell.h"
#import "SettingsInformationCell.h"
#import "SettingsSectionHeaderCell.h"

#import "BackupContentConfirmView.h"
#import "AlertMessageView.h"

#import "UIBackupContent.h"
#import "UIBackupWord.h"

#import <Utils/NSString+Utils.h>

#import <Twinme/TLContact.h>
#import <Twinme/TLGroup.h>
#import <Twinme/TLCallReceiver.h>
#import <Twinme/TLSpace.h>

#import <TwinmeCommon/Design.h>
#import <TwinmeCommon/BackupService.h>

#import "UIView+Toast.h"

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static NSString *SETTINGS_INFORMATION_CELL_IDENTIFIER = @"SettingsInformationCellIdentifier";
static NSString *HEADER_SETTINGS_CELL_IDENTIFIER = @"HeaderSettingsCellIdentifier";
static NSString *BACKUP_FOOTER_CELL_IDENTIFIER = @"BackupFooterCellIdentifier";
static NSString *BACKUP_ACTION_CELL_IDENTIFIER = @"BackupActionCellIdentifier";
static NSString *BACKUP_CONFIRM_CELL_IDENTIFIER = @"BackupConfirmCellIdentifier";
static NSString *BACKUP_SAVE_FOOTER_IDENTIFIER = @"BackupSaveFooterCellIdentifier";
static NSString *BACKUP_WAITING_CELL_IDENTIFIER = @"BackupWaitingCellIdentifier";
static NSString *BACKUP_WORDS_CELL_IDENTIFIER = @"BackupWordsCellIdentifier";

//
// Interface: BackupViewController ()
//

@interface BackupViewController ()<BackupServiceDelegate, UITableViewDelegate, UITableViewDataSource, BackupActionDelegate, BackupFooterDelegate, BackupConfirmDelegate, BottomSheetViewDelegate, UINavigationControllerDelegate, AlertMessageViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic) UIView *overlayView;
@property (nonatomic) UIActivityIndicatorView *activityIndicatorView;

@property (nonatomic) BackupService *backupService;
@property (nonatomic) NSMutableArray *backupWords;
@property (nonatomic) NSString *backupPath;
@property (nonatomic) NSUUID *backupId;
@property (nonatomic, nullable) NSDictionary<NSUUID *, NSNumber *> *stats;
@property (nonatomic) BOOL confirmBackup;
@property (nonatomic) BOOL successBackup;

@end

//
// Implementation: BackupViewController
//

#undef LOG_TAG
#define LOG_TAG @"BackupViewController"

@implementation BackupViewController

- (instancetype)initWithCoder:(NSCoder *)coder {
    DDLogVerbose(@"%@ initWithCoder: %@", LOG_TAG, coder);
    
    self = [super initWithCoder:coder];
    
    if (self) {
        _backupService = [[BackupService alloc] initWithTwinmeContext:self.twinmeContext delegate:self];
        _backupWords = [[NSMutableArray alloc]init];
        _confirmBackup = NO;
        _successBackup = NO;
    }
    return self;
}

- (void)viewDidLoad {
    DDLogVerbose(@"%@ viewDidLoad", LOG_TAG);
    
    [super viewDidLoad];
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
    self.navigationController.delegate = self;
    [self initViews];
    [self.backupService generateWords];
}

#pragma mark -BackupServiceDelegate

- (void)onBackupErrorWithBackupErrorCode:(TLBackupServiceErrorCode)backupErrorCode baseErrorCode:(TLBaseServiceErrorCode)baseErrorCode {
    DDLogVerbose(@"%@ onBackupErrorWithErrorCode: %ld parameter: %ld", LOG_TAG, (long)backupErrorCode, (long)baseErrorCode);

    self.overlayView.hidden = YES;
    [self.activityIndicatorView stopAnimating];
    
    [self showErrorMessage:backupErrorCode baseErrorCode:baseErrorCode];
}

- (void)onBackupHeaderInfoWithHeaderInfo:(nonnull TLBackupHeaderInfo *)headerInfo lastBackupId:(nullable NSUUID *)lastBackupId lastBackupTimestamp:(int64_t)lastBackupTimestamp {
    DDLogVerbose(@"%@ onBackupHeaderInfoWithHeaderInfo:%@", LOG_TAG, headerInfo);
}

- (void)onBackupStateChangeWithBackupId:(nonnull NSUUID *)backupId state:(TLBackupState)state {
    DDLogVerbose(@"%@ onBackupStateChangeWithBackupId:%@ state:%d", LOG_TAG, backupId.UUIDString, state);
    
    if (state == TLBackupStateStarting) {
        self.overlayView.hidden = NO;
        [self.activityIndicatorView startAnimating];
    }
}

- (void)onRestoreErrorWithBackupErrorCode:(TLBackupServiceErrorCode)backupErrorCode baseErrorCode:(TLBaseServiceErrorCode)baseErrorCode {
    DDLogVerbose(@"%@ onRestoreErrorWithErrorCode: %ld parameter: %ld", LOG_TAG, (long)backupErrorCode, (long)baseErrorCode);
}

- (void)onRestoreStateChangeWithState:(TLRestoreState)restoreState restoreReport:(nullable RestoreReport *)restoreReport {
    DDLogVerbose(@"%@ onRestoreStateChangeWithState:%d restoreReport:%@", LOG_TAG, restoreState, restoreReport);
}

- (void)onTerminateBackupWithBackupId:(nonnull NSUUID *)backupId backupFilePath:(nullable NSString *)backupFilePath stats:(nonnull NSDictionary<NSUUID *, NSNumber *> *)stats done:(BOOL)done {
    DDLogVerbose(@"%@ onTerminateBackupWithBackupId:%@ backupFilePath:%@ done:%@", LOG_TAG, backupId, backupFilePath, done ? @"YES" : @"NO");
    
    if (done) {
        self.backupPath = backupFilePath;
        self.backupId = backupId;
        self.stats = stats;
        [self showBackupContentConfirmView];
    }
}

- (void)onWordsGeneratedWithWords:(nonnull NSArray<NSString *> *)words {
    DDLogVerbose(@"%@ onWordsGeneratedWithWords: %@", LOG_TAG, words);
    
    [self.backupWords removeAllObjects];
    
    int position = 0;
    for (NSString *word in words) {
        UIBackupWord *backupWord = [[UIBackupWord alloc]initWithWord:word position:position];
        [self.backupWords addObject:backupWord];
        position++;
    }
    
    [self.tableView reloadData];
}

- (void)onDeleteBackupsWithErrorCode:(TLBaseServiceErrorCode)errorCode { 
    DDLogVerbose(@"%@ onDeleteBackupsWithErrorCode:%d", LOG_TAG, errorCode);
}


- (void)onGetAllBackupsWithErrorCode:(TLBaseServiceErrorCode)errorCode backups:(nonnull NSArray<TLBackupInfo *> *)backups { 
    DDLogVerbose(@"%@ onGetAllBackupsWithErrorCode:%d backups:%@", LOG_TAG, errorCode, backups);
}


- (void)onTerminateRestoreWithTerminateReason:(TLBackupServiceTerminateReason)terminateReason { 
    DDLogVerbose(@"%@ onTerminateRestoreWithTerminateReason:%d", LOG_TAG, terminateReason);
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    DDLogVerbose(@"%@ numberOfSectionsInTableView: %@", LOG_TAG, tableView);
    
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath  {
    DDLogVerbose(@"%@ tableView: %@ heightForRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ heightForHeaderInSection: %ld", LOG_TAG, tableView, (long)section);
    
    return Design.CELL_HEIGHT;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ heightForFooterInSection: %ld", LOG_TAG, tableView, (long)section);
    
    return Design.SETTING_SECTION_HEIGHT;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ numberOfRowsInSection: %ld", LOG_TAG, tableView, (long)section);
    
    return 4;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ viewForHeaderInSection: %ld", LOG_TAG, tableView, (long)section);
    
    SettingsSectionHeaderCell *settingsSectionHeaderCell = (SettingsSectionHeaderCell *)[tableView dequeueReusableCellWithIdentifier:HEADER_SETTINGS_CELL_IDENTIFIER];
    if (!settingsSectionHeaderCell) {
        settingsSectionHeaderCell = [[SettingsSectionHeaderCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:HEADER_SETTINGS_CELL_IDENTIFIER];
    }
    
    NSString *sectionTitle = TwinmeLocalizedStringFromTable(@"backup_view_controller_security", @"LocalizableBackup", nil);
    [settingsSectionHeaderCell bindWithTitle:sectionTitle backgroundColor:Design.LIGHT_GREY_BACKGROUND_COLOR hideSeparator:YES uppercaseString:YES];
    
    return settingsSectionHeaderCell;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ viewForFooterInSection: %ld", LOG_TAG, tableView, (long)section);
    
    BackupFooterCell *backupFooterCell = (BackupFooterCell *)[tableView dequeueReusableCellWithIdentifier:BACKUP_FOOTER_CELL_IDENTIFIER];
    if (!backupFooterCell) {
        backupFooterCell = [[BackupFooterCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:BACKUP_FOOTER_CELL_IDENTIFIER];
    }
    
    backupFooterCell.backupFooterDelegate = self;
    [backupFooterCell bindWithTitle:TwinmeLocalizedStringFromTable(@"backup_view_controller_backup", @"LocalizableBackup", nil) enable:self.confirmBackup backgroundColor:Design.LIGHT_GREY_BACKGROUND_COLOR];
    
    return backupFooterCell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ cellForRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    if ([self isInformationPath:indexPath]) {
        SettingsInformationCell *cell = [tableView dequeueReusableCellWithIdentifier:SETTINGS_INFORMATION_CELL_IDENTIFIER];
        if (!cell) {
            cell = [[SettingsInformationCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:SETTINGS_INFORMATION_CELL_IDENTIFIER];
        }
        
        [cell bindWithText:TwinmeLocalizedStringFromTable(@"backup_view_controller_security_info", @"LocalizableBackup", nil)];
        
        return cell;
    } else if (indexPath.row == 1) {
        BackupWordsCell *cell = [tableView dequeueReusableCellWithIdentifier:BACKUP_WORDS_CELL_IDENTIFIER];
        if (!cell) {
            cell = [[BackupWordsCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:BACKUP_WORDS_CELL_IDENTIFIER];
        }
        
        [cell bindWithWords:self.backupWords];
        
        return cell;
    } else if (indexPath.row == 2) {
        BackupActionCell *cell = [tableView dequeueReusableCellWithIdentifier:BACKUP_ACTION_CELL_IDENTIFIER];
        if (!cell) {
            cell = [[BackupActionCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:BACKUP_ACTION_CELL_IDENTIFIER];
        }
        
        cell.backupActionDelegate = self;
        
        [cell bindWithTitle:TwinmeLocalizedString(@"conversation_view_controller_menu_item_view_copy_title", nil) rightTitle:TwinmeLocalizedStringFromTable(@"backup_view_controller_generate_word", @"LocalizableBackup", nil) leftImage:[UIImage imageNamed:@"CopyItem"] rightImage:[UIImage imageNamed:@"GenerateIcon"]];
        
        return cell;
    } else {
        BackupConfirmCell *cell = [tableView dequeueReusableCellWithIdentifier:BACKUP_CONFIRM_CELL_IDENTIFIER];
        if (!cell) {
            cell = [[BackupConfirmCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:BACKUP_CONFIRM_CELL_IDENTIFIER];
        }
        
        cell.backupConfirmDelegate = self;
        [cell bind];
        
        return cell;
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ didSelectRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
}

#pragma mark - BackupActionCellDelegate

- (void)didTapLeftBackupAction:(nonnull BackupActionCell *)backupActionCell {
    DDLogVerbose(@"%@ didTapLeftBackupAction: %@", LOG_TAG, backupActionCell);
    
    [[UIPasteboard generalPasteboard] setString:[self getWordsList]];
    [[UIApplication sharedApplication].keyWindow makeToast:TwinmeLocalizedString(@"conversation_view_controller_menu_item_view_copy_message",nil)];
}

- (void)didTapRightBackupAction:(nonnull BackupActionCell *)backupActionCell {
    DDLogVerbose(@"%@ didTapRightBackupAction: %@", LOG_TAG, backupActionCell);
    
    [self.backupService generateWords];
}

#pragma mark - BackupFooterDelegate

- (void)didTapFooterAction {
    DDLogVerbose(@"%@ didTapFooterAction", LOG_TAG);
    
    if (self.confirmBackup) {
        [self.backupService startBackupWithPassword:nil];
    }
}

#pragma mark - BackupFooterCellDelegate

- (void)didTapConfirmBackup:(BOOL)confirm {
    DDLogVerbose(@"%@ didTapConfirmBackup: %@", LOG_TAG, confirm ? @"YES" : @"NO");
    
    self.confirmBackup = confirm;
    
    [self.tableView reloadData];
}

#pragma mark - BottomSheetViewDelegate

- (void)didTapConfirm:(nonnull AbstractBottomSheetView *)abstractConfirmView {
    DDLogVerbose(@"%@ didTapConfirm: %@", LOG_TAG, abstractConfirmView);
    
    [abstractConfirmView closeConfirmView];
    self.successBackup = YES;
}

- (void)didTapCancel:(nonnull AbstractBottomSheetView *)abstractConfirmView {
    DDLogVerbose(@"%@ didTapCancel: %@", LOG_TAG, abstractConfirmView);
    
    [abstractConfirmView closeConfirmView];
    [self deleteBackupFile];
}

- (void)didClose:(nonnull AbstractBottomSheetView *)abstractConfirmView {
    DDLogVerbose(@"%@ didClose: %@", LOG_TAG, abstractConfirmView);
    
    [abstractConfirmView closeConfirmView];
    [self deleteBackupFile];
}

- (void)didFinishCloseAnimation:(nonnull AbstractBottomSheetView *)abstractConfirmView {
    DDLogVerbose(@"%@ didFinishCloseAnimation: %@", LOG_TAG, abstractConfirmView);
    
    [abstractConfirmView removeFromSuperview];
    
    if (self.successBackup) {
        [self finish];
    }
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

#pragma mark - UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    DDLogVerbose(@"%@ navigationController: %@ willShowViewController: %@ animated: %@", LOG_TAG, navigationController, viewController, animated ? @"YES" : @"NO");
    
    if ([viewController isKindOfClass:[AccountViewController class]] && self.successBackup) {
        navigationController.delegate = nil;
        SuccessBackupViewController *successBackupViewController = (SuccessBackupViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"SuccessBackupViewController"];
        [successBackupViewController initWithBackupPath:self.backupPath words:self.backupWords backupId:self.backupId];
        [navigationController pushViewController:successBackupViewController animated:YES];
    }
}

#pragma mark - Private methods

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    self.view.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
    
    [self setNavigationTitle:TwinmeLocalizedStringFromTable(@"backup_view_controller_title", @"LocalizableBackup", nil)];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerNib:[UINib nibWithNibName:@"SettingsSectionHeaderCell" bundle:nil] forCellReuseIdentifier:HEADER_SETTINGS_CELL_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"SettingsInformationCell" bundle:nil] forCellReuseIdentifier:SETTINGS_INFORMATION_CELL_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"BackupFooterCell" bundle:nil] forCellReuseIdentifier:BACKUP_FOOTER_CELL_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"BackupActionCell" bundle:nil] forCellReuseIdentifier:BACKUP_ACTION_CELL_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"BackupSaveFooterView" bundle:nil] forCellReuseIdentifier:BACKUP_SAVE_FOOTER_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"BackupConfirmCell" bundle:nil] forCellReuseIdentifier:BACKUP_CONFIRM_CELL_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"BackupWordsCell" bundle:nil] forCellReuseIdentifier:BACKUP_WORDS_CELL_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"BackupWaitingCell" bundle:nil] forCellReuseIdentifier:BACKUP_WAITING_CELL_IDENTIFIER];
    
    self.tableView.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = Design.SETTING_CELL_HEIGHT;
    
    self.overlayView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, Design.DISPLAY_WIDTH, Design.DISPLAY_HEIGHT)];
    self.overlayView.backgroundColor = Design.OVERLAY_COLOR;
    self.overlayView.hidden = YES;
    
    if (@available(iOS 13.0, *)) {
        self.activityIndicatorView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
        self.activityIndicatorView.color = [UIColor whiteColor];
    } else {
        self.activityIndicatorView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    }
    self.activityIndicatorView.hidesWhenStopped = YES;
    
    [self.overlayView addSubview:self.activityIndicatorView];
    
    [self.activityIndicatorView setCenter:CGPointMake(Design.DISPLAY_WIDTH * 0.5, Design.DISPLAY_HEIGHT * 0.5)];
    [self.navigationController.view addSubview:self.overlayView];
}

- (BOOL)isInformationPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        return YES;
    }
    
    return NO;
}

- (void)finish {
    DDLogVerbose(@"%@ finish", LOG_TAG);
    
    if (self.backupService) {
        [self.backupService dispose];
        self.backupService = nil;
    }
    
    if (self.overlayView) {
        self.overlayView.hidden = NO;
        [self.activityIndicatorView stopAnimating];
        [self.overlayView removeFromSuperview];
    }
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)deleteBackupFile {
    DDLogVerbose(@"%@ deleteBackupFile", LOG_TAG);
    
    if (self.backupPath) {
        if ([[NSFileManager defaultManager]fileExistsAtPath:self.backupPath]) {
            [[NSFileManager defaultManager]removeItemAtPath:self.backupPath error:nil];
        }
    }
    
    self.overlayView.hidden = YES;
    [self.activityIndicatorView stopAnimating];
}

- (void)showBackupContentConfirmView {
    DDLogVerbose(@"%@ showBackupContentConfirmView", LOG_TAG);
    
    BackupContentConfirmView *backupContentConfirmView = [[BackupContentConfirmView alloc] init];
    backupContentConfirmView.bottomSheetViewDelegate = self;
    [backupContentConfirmView initWithStats:self.stats];
    
    [self.navigationController.view addSubview:backupContentConfirmView];
    [backupContentConfirmView showConfirmView];
}

- (NSString *)getWordsList {
    DDLogVerbose(@"%@ getWordsList", LOG_TAG);
    
    NSMutableString *words = [[NSMutableString alloc]initWithString:@""];
    
    for (UIBackupWord *backupWord in self.backupWords) {
        [words appendString:[backupWord getWord]];
        [words appendString:@" "];
    }
    
    return words;
}

- (void)showErrorMessage:(TLBackupServiceErrorCode)errorCode baseErrorCode:(TLBaseServiceErrorCode)baseErrorCode {
    DDLogVerbose(@"%@ showErrorMessage: %d", LOG_TAG, errorCode);
    
    NSString *message;
    if (errorCode == TLBackupServiceErrorCodeNoSpaceLeft) {
        message = TwinmeLocalizedString(@"application_error_no_storage_space", nil);
    } else if (errorCode == TLBackupServiceErrorCodeKeyGenFailed && baseErrorCode == TLBaseServiceErrorCodeTwinlifeOffline) {
        message = TwinmeLocalizedString(@"application_connection_status_no_network_message", nil);
    } else {
        message = TwinmeLocalizedString(@"cleanup_view_controller_error", nil);
    }
    
    AlertMessageView *alertMessageView = [[AlertMessageView alloc] init];
    alertMessageView.alertMessageViewDelegate = self;
    [alertMessageView initWithTitle:TwinmeLocalizedString(@"delete_account_view_controller_warning", nil) message:message];
    [self.navigationController.view addSubview:alertMessageView];
    [alertMessageView showAlertView];
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    self.view.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
    [self.tableView reloadData];
}

@end
