/*
 *  Copyright (c) 2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import "RestoreViewController.h"

#import "RestoreWordsCell.h"
#import "BackupInfoCell.h"
#import "BackupContentCell.h"
#import "BackupFooterCell.h"
#import "RestoreStateCell.h"
#import "SettingsSectionHeaderCell.h"
#import "SettingsInformationCell.h"
#import "WordCompletionView.h"
#import "DefaultConfirmView.h"
#import "AlertMessageView.h"
#import "BackupContentConfirmView.h"
#import "TwinmeTextField.h"
#import "BackupViewController.h"

#import <TwinmeCommon/BackupService.h>
#import <TwinmeCommon/MainViewController.h>
#import <TwinmeCommon/MnemonicCodeUtils.h>
#import <TwinmeCommon/TwinmeNavigationController.h>

#import <Twinlife/TLRestoreContent.h>

#import <Utils/NSString+Utils.h>

#import <TwinmeCommon/Design.h>

#import "UIBackupWord.h"
#import "UIBackupContent.h"
#import "UIRestoreItem.h"
#import "UIView+Toast.h"

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static NSString *BACKUP_FOOTER_CELL_IDENTIFIER = @"BackupFooterCellIdentifier";
static NSString *BACKUP_INFO_CELL_IDENTIFIER = @"BackupInfoCellIdentifier";
static NSString *RESTORE_WORDS_CELL_IDENTIFIER = @"RestoreWordsCellIdentifier";
static NSString *RESTORE_STATE_CELL_IDENTIFIER = @"RestoreStateCellIdentifier";
static NSString *BACKUP_CONTENT_CELL_IDENTIFIER = @"BackupContentCellIdentifier";
static NSString *SETTINGS_INFORMATION_CELL_IDENTIFIER = @"SettingsInformationCellIdentifier";
static NSString *HEADER_SETTINGS_CELL_IDENTIFIER = @"HeaderSettingsCellIdentifier";

static float DESIGN_INFO_CELL_HEIGHT = 190;
static const CGFloat COUNT_WORDS = 12;

static NSInteger HEADER_INFO_VIEW_TAG = 1001;

//
// Interface: RestoreViewController ()
//

@interface RestoreViewController () <BackupServiceDelegate, UITableViewDelegate, UITableViewDataSource, BackupFooterDelegate, RestoreWordsDelegate, BottomSheetViewDelegate, AlertMessageViewDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewBottomConstraintLayout;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cancelViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cancelViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cancelViewWidthConstraint;
@property (weak, nonatomic) IBOutlet UIView *cancelView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cancelLabelLeadingConstraintLayout;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cancelLabelTrailingConstraintLayout;
@property (weak, nonatomic) IBOutlet UILabel *cancelLabel;
@property (nonatomic) UIBarButtonItem *cancelBarButtonItem;

@property (nonatomic) NSMutableArray *restoreItems;
@property (nonatomic) BackupService *backupService;
@property (nonatomic) NSMutableArray *backupWords;
@property (nonatomic, nonnull, readonly) MnemonicCodeUtils *mnemonicCodeUtils;
@property (nonatomic) NSURL *backupURL;
@property (nonatomic) TLRestoreState restoreState;
@property (nonatomic) TLBackupServiceTerminateReason terminateReason;
@property (nonatomic, nullable) RestoreReport *restoreReport;
@property (nonatomic) BOOL canRestore;
@property (nonatomic) BOOL restoreInProgress;
@property (nonatomic) BOOL resetSearch;
@property (nonatomic) BOOL keyboardHidden;
@property (nonatomic) BOOL verifyMode;
@property (nonatomic) BOOL isVerifyBackupTerminated;
@property (nonatomic) BOOL startBackup;
@property (nonatomic) BOOL isBackupHeaderInfoOK;
@property (nonatomic) BOOL isLastBackup;
@property (nonatomic) BOOL checkFileSignature;

@end

//
// Implementation: RestoreViewController
//

#undef LOG_TAG
#define LOG_TAG @"RestoreViewController"

@implementation RestoreViewController

- (instancetype)initWithCoder:(NSCoder *)coder {
    DDLogVerbose(@"%@ initWithCoder: %@", LOG_TAG, coder);
    
    self = [super initWithCoder:coder];
    
    if (self) {
        _restoreItems = [[NSMutableArray alloc]init];
        _backupService = [[BackupService alloc] initWithTwinmeContext:self.twinmeContext delegate:self];
        _backupWords = [[NSMutableArray alloc]initWithCapacity:12];
        _mnemonicCodeUtils = [[MnemonicCodeUtils alloc] init];
        _canRestore = NO;
        _resetSearch = NO;
        _restoreInProgress = NO;
        _isVerifyBackupTerminated = NO;
        _isBackupHeaderInfoOK = NO;
        _keyboardHidden = YES;
        _checkFileSignature = NO;
        _verifyMode = NO;
        _startBackup = NO;
        _isLastBackup = NO;
    }
    return self;
}

- (void)viewDidLoad {
    DDLogVerbose(@"%@ viewDidLoad", LOG_TAG);
    
    [super viewDidLoad];
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
    [self initViews];
}

- (void)viewWillAppear:(BOOL)animated {
    DDLogVerbose(@"%@ viewWillAppear: %@", LOG_TAG, animated ? @"YES" : @"NO");
    
    [super viewWillAppear:animated];
    
    if (self.backupURL && !self.checkFileSignature) {
        self.checkFileSignature = YES;
        [self.backupService checkFileCompatibilityWithBackupPath:self.backupURL.path];
    }
    
    [self updateContent];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didPasteItemNotification:) name:TwinmeTextFieldDidPasteItemNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    DDLogVerbose(@"%@ viewWillDisappear: %@", LOG_TAG, animated ? @"YES" : @"NO");
    
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter]  removeObserver:self name:TwinmeTextFieldDidPasteItemNotification object:nil];
    
}

- (void)keyboardWillShow:(NSNotification *)notification {
    DDLogVerbose(@"%@ keyboardWillShow: %@", LOG_TAG, notification);
    
    if (!self.keyboardHidden) {
        return;
    }
    
    self.keyboardHidden = NO;
    NSDictionary *info = [notification userInfo];
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    self.tableViewBottomConstraintLayout.constant = self.view.frame.size.height - [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].origin.y;
    
    if ([self.twinmeApplication getDefaultKeyboardHeight] != keyboardSize.height) {
        [self.twinmeApplication setDefaultKeyboardHeight:keyboardSize.height];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification {
    DDLogVerbose(@"%@ keyboardWillHide: %@", LOG_TAG, notification);
    
    self.keyboardHidden = YES;
    
    self.tableViewBottomConstraintLayout.constant = 0;
}

- (void)keyboardWillChangeFrame:(NSNotification *)notification {
    DDLogVerbose(@"%@ keyboardWillChangeFrame: %@", LOG_TAG, notification);
    
    NSDictionary *info = [notification userInfo];
    self.tableViewBottomConstraintLayout.constant = self.view.frame.size.height - [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].origin.y;
}

- (void)didPasteItemNotification:(NSNotification *)notification {
    DDLogVerbose(@"%@ didPasteItemNotification: %@", LOG_TAG, notification);
    
    NSString *pastedContent = (NSString *)notification.object;
    if (pastedContent) {
        [self pasteWords:pastedContent];
    }
}

- (void)initWithFileURL:(NSURL *)fileURL verifyMode:(BOOL)verifyMode pickFileInApp:(BOOL)pickFileInApp {
    DDLogVerbose(@"%@ initWithFileURL: %@ verifyMode: %@ pickFileInApp: %@", LOG_TAG, fileURL, verifyMode ? @"YES" : @"NO", pickFileInApp ? @"YES" : @"NO");
    
    if (!pickFileInApp) {
        [self copyFile:fileURL];
    } else {
        self.backupURL = fileURL;
    }
    
    self.verifyMode = verifyMode;
}

#pragma mark -BackupServiceDelegate

- (void)onBackupErrorWithErrorCode:(TLBackupServiceErrorCode)errorCode parameter:(nullable NSString *)parameter {
    DDLogVerbose(@"%@ onBackupErrorWithErrorCode:%d parameter:%@", LOG_TAG, errorCode, parameter);
}

- (void)onBackupHeaderInfoWithHeaderInfo:(nonnull TLBackupHeaderInfo *)headerInfo lastBackupId:(nullable NSUUID *)lastBackupId lastBackupTimestamp:(int64_t)lastBackupTimestamp {
    DDLogVerbose(@"%@ onBackupHeaderInfoWithHeaderInfo:%@", LOG_TAG, headerInfo);
        
    self.isBackupHeaderInfoOK = headerInfo != nil && [headerInfo.applicationName isEqualToString:@"twinme"];
    self.isLastBackup = lastBackupId != nil && [lastBackupId isEqual:headerInfo.backupId];
}

- (void)onBackupStateChangeWithBackupId:(nonnull NSUUID *)backupId state:(TLBackupState)state {
    DDLogVerbose(@"%@ onBackupStateChangeWithBackupId:%@ state:%d", LOG_TAG, backupId.UUIDString, state);
}

- (void)onRestoreErrorWithBackupErrorCode:(TLBackupServiceErrorCode)backupErrorCode baseErrorCode:(TLBaseServiceErrorCode)baseErrorCode {
    DDLogVerbose(@"%@ onRestoreErrorWithBackupErrorCode:%d parameter:%d", LOG_TAG, backupErrorCode, baseErrorCode);
    
    if (backupErrorCode == TLBackupServiceErrorCodeSyncFailed) {
        return;
    }
    
    [self showErrorMessage:backupErrorCode];
}

- (void)onRestoreStateChangeWithState:(TLRestoreState)restoreState restoreReport:(nullable RestoreReport *)restoreReport {
    DDLogVerbose(@"%@ onRestoreStateChangeWithState:%d restoreReport:%@", LOG_TAG, restoreState, restoreReport);
    
    self.restoreState = restoreState;
    
    if (self.restoreState == TLRestoreStateWaitConfirm && restoreReport) {
        self.restoreReport = restoreReport;
    }
    
    [self updateRestoreState];
}

- (void)onTerminateBackupWithBackupId:(nonnull NSUUID *)backupId backupFilePath:(nullable NSString *)backupFilePath stats:(nonnull NSDictionary<NSUUID *, NSNumber *> *)stats done:(BOOL)done {
    DDLogVerbose(@"%@ onTerminateBackupWithBackupId:%@ backupFilePath:%@ stats: %@ done:%@", LOG_TAG, backupId, backupFilePath, stats, done ? @"YES" : @"NO");
}

- (void)onTerminateRestoreWithTerminateReason:(TLBackupServiceTerminateReason)terminateReason {
    DDLogVerbose(@"%@ onTerminateRestoreWithTerminateReason: %d", LOG_TAG, terminateReason);
    
    if (terminateReason != TLBackupServiceTerminateReasonError) {
        if (terminateReason == TLBackupServiceTerminateReasonCancel && !self.verifyMode) {
            self.restoreState = TLRestoreStateCancel;
        } else {
            self.restoreState = TLRestoreStateTerminated;
        }
    }
    
    self.terminateReason = terminateReason;
    [self updateRestoreState];
}

- (void)onWordsGeneratedWithWords:(nonnull NSArray<NSString *> *)words {
    DDLogVerbose(@"%@ onWordsGeneratedWithWords: %@", LOG_TAG, words);
}

- (void)onDeleteBackupsWithErrorCode:(TLBaseServiceErrorCode)errorCode { 
    DDLogVerbose(@"%@ onDeleteBackupsWithErrorCode:%d", LOG_TAG, errorCode);
}

- (void)onGetAllBackupsWithErrorCode:(TLBaseServiceErrorCode)errorCode backups:(nonnull NSArray<TLBackupInfo *> *)backups { 
    DDLogVerbose(@"%@ onGetAllBackupsWithErrorCode:%d backups:%@", LOG_TAG, errorCode, backups);
}

- (void)onBackupErrorWithBackupErrorCode:(TLBackupServiceErrorCode)backupErrorCode baseErrorCode:(TLBaseServiceErrorCode)baseErrorCode {
    DDLogVerbose(@"%@ onBackupErrorWithBackupErrorCode:%d backups:%d", LOG_TAG, backupErrorCode, baseErrorCode);
    
}

- (void)onTerminateVerifyWithReport:(nonnull RestoreReport *)report {
    DDLogVerbose(@"%@ onTerminateVerifyWithReport: %@", LOG_TAG, report);
    
    self.restoreState = TLRestoreStateTerminated;
    self.restoreReport = report;

    [self updateRestoreState];
}

- (void)onCheckFileCompatibilityWithResult:(TLBackupServiceErrorCode)result {
    DDLogVerbose(@"%@ onCheckFileCompatibilityWithResult:%d", LOG_TAG, result);
    
    if (result != TLBackupServiceErrorCodeSuccess) {
        // TODO BKP handle TLBackupServiceErrorCodeWrongVersion and TLBackupServiceErrorCodeWrongApp.
        [self showErrorMessage:TLBackupServiceErrorCodeInvalidFile];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    DDLogVerbose(@"%@ numberOfSectionsInTableView: %@", LOG_TAG, tableView);
    
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath  {
    DDLogVerbose(@"%@ tableView: %@ heightForRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    UIRestoreItem *restoreItem = [self.restoreItems objectAtIndex:indexPath.row];
    
    if ([restoreItem getRestoreItemType] == UIRestoreItemTypeHeader) {
        return roundf(DESIGN_INFO_CELL_HEIGHT * Design.HEIGHT_RATIO);
    } else if ([restoreItem getRestoreItemType] == UIRestoreItemTypeSection || [restoreItem getRestoreItemType] == UIRestoreItemTypeFooter) {
        return Design.SETTING_SECTION_HEIGHT;
    } else if ([restoreItem getRestoreItemType] == UIRestoreItemTypeContent) {
        return Design.SETTING_CELL_HEIGHT;
    } else {
        return UITableViewAutomaticDimension;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ heightForHeaderInSection: %ld", LOG_TAG, tableView, (long)section);
    
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ heightForFooterInSection: %ld", LOG_TAG, tableView, (long)section);
    
    return CGFLOAT_MIN;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ numberOfRowsInSection: %ld", LOG_TAG, tableView, (long)section);
    
    return self.restoreItems.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ viewForHeaderInSection: %ld", LOG_TAG, tableView, (long)section);
    
    return [[UIView alloc]init];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ cellForRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    UIRestoreItem *restoreItem = [self.restoreItems objectAtIndex:indexPath.row];
    
    switch ([restoreItem getRestoreItemType]) {
        case UIRestoreItemTypeHeader: {
            BackupInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:BACKUP_INFO_CELL_IDENTIFIER];
            if (!cell) {
                cell = [[BackupInfoCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:BACKUP_INFO_CELL_IDENTIFIER];
            }
            
            NSString *fileName = self.backupURL.lastPathComponent;
            [cell bindWithTitle:fileName];
            return cell;
        }
            
        case UIRestoreItemTypeFooter: {
            BackupFooterCell *cell = (BackupFooterCell *)[tableView dequeueReusableCellWithIdentifier:BACKUP_FOOTER_CELL_IDENTIFIER];
            if (!cell) {
                cell = [[BackupFooterCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:BACKUP_FOOTER_CELL_IDENTIFIER];
            }
            
            cell.backupFooterDelegate = self;
            
            if (self.verifyMode) {
                if (self.isVerifyBackupTerminated && self.restoreReport && ![self.restoreReport isRestoreUpToDate]) {
                    [cell bindWithTitle:TwinmeLocalizedStringFromTable(@"backup_view_new_backup", @"LocalizableBackup", nil) enable:self.canRestore backgroundColor:Design.LIGHT_GREY_BACKGROUND_COLOR];
                } else {
                    [cell bindWithTitle:TwinmeLocalizedStringFromTable(@"account_view_backup_verify", @"LocalizableBackup", nil) enable:self.canRestore backgroundColor:Design.LIGHT_GREY_BACKGROUND_COLOR];
                }
            } else {
                [cell bindWithTitle:TwinmeLocalizedStringFromTable(@"restore_view_restore", @"LocalizableBackup", nil) enable:self.canRestore backgroundColor:Design.LIGHT_GREY_BACKGROUND_COLOR];
            }
            
            return cell;
        }
            
        case UIRestoreItemTypeWords: {
            RestoreWordsCell *cell = [tableView dequeueReusableCellWithIdentifier:RESTORE_WORDS_CELL_IDENTIFIER];
            if (!cell) {
                cell = [[RestoreWordsCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:RESTORE_WORDS_CELL_IDENTIFIER];
            }
            
            cell.restoreWordsDelegate = self;
            [cell bind:self.mnemonicCodeUtils words:self.backupWords];
            
            return cell;
        }
            
        case UIRestoreItemTypeState: {
            RestoreStateCell *cell = [tableView dequeueReusableCellWithIdentifier:RESTORE_STATE_CELL_IDENTIFIER];
            if (!cell) {
                cell = [[RestoreStateCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:RESTORE_STATE_CELL_IDENTIFIER];
            }
            
            BOOL hideActivityIndicator = self.restoreState == TLRestoreStateTerminated ||  self.restoreState == TLRestoreStateCancel;
            [cell bind:[self getRestoreMessage] hideIndecator:hideActivityIndicator];
            
            return cell;
        }
            
        case UIRestoreItemTypeSection: {
            SettingsSectionHeaderCell *settingsSectionHeaderCell = (SettingsSectionHeaderCell *)[tableView dequeueReusableCellWithIdentifier:HEADER_SETTINGS_CELL_IDENTIFIER];
            if (!settingsSectionHeaderCell) {
                settingsSectionHeaderCell = [[SettingsSectionHeaderCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:HEADER_SETTINGS_CELL_IDENTIFIER];
            }
            
            [settingsSectionHeaderCell bindWithTitle:[restoreItem getText] backgroundColor:Design.LIGHT_GREY_BACKGROUND_COLOR hideSeparator:YES uppercaseString:YES];
            
            return settingsSectionHeaderCell;
        }
            
        case UIRestoreItemTypeContent: {
            BackupContentCell *cell = [tableView dequeueReusableCellWithIdentifier:BACKUP_CONTENT_CELL_IDENTIFIER];
            if (!cell) {
                cell = [[BackupContentCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:BACKUP_CONTENT_CELL_IDENTIFIER];
            }
            
            [cell bind:restoreItem backgroundColor:Design.WHITE_COLOR hideSeparator:NO];
            
            return cell;
        }
            
        case UIRestoreItemTypeInfo: {
            SettingsInformationCell *cell = [tableView dequeueReusableCellWithIdentifier:SETTINGS_INFORMATION_CELL_IDENTIFIER];
            if (!cell) {
                cell = [[SettingsInformationCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:SETTINGS_INFORMATION_CELL_IDENTIFIER];
            }
            
            [cell bindWithText:[restoreItem getText]];
            
            return cell;
        }
            
        default:
            return [[UITableViewCell alloc]init];
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ didSelectRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
}

#pragma mark - BackupFooterDelegate

- (void)didTapFooterAction {
    DDLogVerbose(@"%@ didTapFooterAction", LOG_TAG);
    
    if (self.verifyMode && self.isVerifyBackupTerminated) {
        self.startBackup = YES;
        [self finish];
    } else if (self.canRestore) {
        DefaultConfirmView *defaultConfirmView = [[DefaultConfirmView alloc] init];
        defaultConfirmView.bottomSheetViewDelegate = self;
        
        NSString *title;
        NSString *message;
        NSString *actionTitle;
        
        if (self.verifyMode) {
            title = TwinmeLocalizedStringFromTable(@"account_view_backup_verify", @"LocalizableBackup", nil);
            message = TwinmeLocalizedStringFromTable(@"restore_view_onboarding_verify", @"LocalizableBackup", nil);
            actionTitle = TwinmeLocalizedString(@"application_confirm", nil);
        } else {
            title = TwinmeLocalizedString(@"deleted_account_view_warning", nil);
            message = TwinmeLocalizedStringFromTable(@"restore_view_warning", @"LocalizableBackup", nil);
            actionTitle = TwinmeLocalizedStringFromTable(@"restore_view_restore", @"LocalizableBackup", nil);
        }
        
        [defaultConfirmView initWithTitle:title message:message image:nil avatar:nil action:actionTitle actionColor:nil cancel:TwinmeLocalizedString(@"application_cancel", nil)];
        
        [self.navigationController.view addSubview:defaultConfirmView];
        [defaultConfirmView showConfirmView];
    }
}

#pragma mark - RestoreWordsDelegate

- (void)didTapPasteWords {
    DDLogVerbose(@"%@ didTapPasteWords", LOG_TAG);
    
    if ([[UIPasteboard generalPasteboard] string]) {
        NSString *content = [[UIPasteboard generalPasteboard] string];
        [self pasteWords:content];
    }
}

- (void)didEnterAllWords {
    DDLogVerbose(@"%@ didEnterAllWords", LOG_TAG);
    
    self.canRestore = YES;
    [self.tableView reloadData];
}

- (void)updateWords:(NSArray *)words {
    DDLogVerbose(@"%@ updateWords", LOG_TAG);
    
    [self.backupWords removeAllObjects];
    [self.backupWords addObjectsFromArray:words];
}

#pragma mark - BottomSheetViewDelegate

- (void)didTapConfirm:(nonnull AbstractBottomSheetView *)abstractConfirmView {
    DDLogVerbose(@"%@ didTapConfirm: %@", LOG_TAG, abstractConfirmView);
    
    if ([abstractConfirmView isKindOfClass:[BackupContentConfirmView class]]) {
        [self.backupService commitRestore];
    } else {
        [self startRestore];
    }
    
    [abstractConfirmView closeConfirmView];
}

- (void)didTapCancel:(nonnull AbstractBottomSheetView *)abstractConfirmView {
    DDLogVerbose(@"%@ didTapCancel: %@", LOG_TAG, abstractConfirmView);
    
    if ([abstractConfirmView isKindOfClass:[BackupContentConfirmView class]]) {
        [self.backupService cancelRestore];
    }
    
    [abstractConfirmView closeConfirmView];
}

- (void)didClose:(nonnull AbstractBottomSheetView *)abstractConfirmView {
    DDLogVerbose(@"%@ didClose: %@", LOG_TAG, abstractConfirmView);
    
    if ([abstractConfirmView isKindOfClass:[BackupContentConfirmView class]]) {
        [self.backupService cancelRestore];
    }
    
    [abstractConfirmView closeConfirmView];
}

- (void)didFinishCloseAnimation:(nonnull AbstractBottomSheetView *)abstractConfirmView {
    DDLogVerbose(@"%@ didFinishCloseAnimation: %@", LOG_TAG, abstractConfirmView);
    
    [abstractConfirmView removeFromSuperview];
}

#pragma mark - AlertMessageViewDelegate

- (void)didCloseAlertMessage:(nonnull AlertMessageView *)alertMessageView {
    DDLogVerbose(@"%@ didCloseAlertMessage: %@", LOG_TAG, alertMessageView);
    
    [alertMessageView closeAlertView];
}

- (void)didFinishCloseAlertMessageAnimation:(nonnull AlertMessageView *)alertMessageView {
    DDLogVerbose(@"%@ didFinishCloseAlertMessageAnimation: %@", LOG_TAG, alertMessageView);
    
    [alertMessageView removeFromSuperview];
    
    if (alertMessageView.tag == HEADER_INFO_VIEW_TAG) {
        [self rollbackRestore];
    } else if (alertMessageView.tag != TLBackupServiceErrorCodeKeyGenFailed) {
        [self finish];
    }
}

#pragma mark - Private methods

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    self.view.backgroundColor = Design.WHITE_COLOR;
    
    if (self.verifyMode) {
        [self setNavigationTitle:TwinmeLocalizedStringFromTable(@"account_view_backup_verify", @"LocalizableBackup", nil)];
    } else {
        [self setNavigationTitle:TwinmeLocalizedStringFromTable(@"restore_view_title", @"LocalizableBackup", nil)];
    }
    
    self.cancelBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:TwinmeLocalizedString(@"application_cancel", nil) style:UIBarButtonItemStylePlain target:self action:@selector(cancel:)];
    [self.cancelBarButtonItem setTitleTextAttributes: @{NSFontAttributeName: Design.FONT_BOLD36, NSForegroundColorAttributeName: [UIColor whiteColor]} forState:UIControlStateNormal];
    [self.cancelBarButtonItem setTitleTextAttributes: @{NSFontAttributeName: Design.FONT_BOLD36, NSForegroundColorAttributeName: [UIColor colorWithWhite:1.0 alpha:0.5]} forState:UIControlStateDisabled];
    self.navigationItem.leftBarButtonItem = self.cancelBarButtonItem;
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerNib:[UINib nibWithNibName:@"BackupInfoCell" bundle:nil] forCellReuseIdentifier:BACKUP_INFO_CELL_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"BackupFooterCell" bundle:nil] forCellReuseIdentifier:BACKUP_FOOTER_CELL_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"RestoreWordsCell" bundle:nil] forCellReuseIdentifier:RESTORE_WORDS_CELL_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"RestoreStateCell" bundle:nil] forCellReuseIdentifier:RESTORE_STATE_CELL_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"BackupContentCell" bundle:nil] forCellReuseIdentifier:BACKUP_CONTENT_CELL_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"SettingsSectionHeaderCell" bundle:nil] forCellReuseIdentifier:HEADER_SETTINGS_CELL_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"SettingsInformationCell" bundle:nil] forCellReuseIdentifier:SETTINGS_INFORMATION_CELL_IDENTIFIER];
    
    self.tableView.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = Design.SETTING_CELL_HEIGHT;
    
    self.cancelViewBottomConstraint.constant *= Design.HEIGHT_RATIO;
    self.cancelViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.cancelViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    
    self.cancelView.backgroundColor = Design.BUTTON_RED_COLOR;
    self.cancelView.userInteractionEnabled = YES;
    self.cancelView.isAccessibilityElement = YES;
    self.cancelView.accessibilityLabel = TwinmeLocalizedString(@"application_cancel", nil);
    self.cancelView.layer.cornerRadius = Design.CONTAINER_RADIUS;
    self.cancelView.clipsToBounds = YES;
    [self.cancelView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleCancelTapGesture:)]];
    self.cancelView.hidden = YES;
    
    self.cancelLabelLeadingConstraintLayout.constant *= Design.WIDTH_RATIO;
    self.cancelLabelTrailingConstraintLayout.constant *= Design.WIDTH_RATIO;
    [self.cancelLabel setFont:Design.FONT_MEDIUM34];
    self.cancelLabel.textColor = [UIColor whiteColor];
    self.cancelLabel.text = TwinmeLocalizedString(@"application_cancel", nil);
}

- (IBAction)cancel:(id)sender {
    DDLogVerbose(@"%@ cancel: %@", LOG_TAG, sender);
    
    if (self.restoreInProgress) {
        [self.backupService cancelRestore];
    } else {
        [self finish];
    }
}

- (void)handleCancelTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleCancelTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        [self.backupService cancelRestore];
    }
}

- (void)finish {
    DDLogVerbose(@"%@ finish", LOG_TAG);
    
    if (self.backupService) {
        [self.backupService dispose];
    }
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    
    if (self.startBackup) {
        [self dismissViewControllerAnimated:YES completion:^{
            
            ApplicationDelegate *delegate = (ApplicationDelegate *)[[UIApplication sharedApplication] delegate];
            MainViewController *mainViewController = delegate.mainViewController;
            TwinmeNavigationController *selectedNavigationController = mainViewController.selectedViewController;
            
            [CATransaction begin];
            [CATransaction setCompletionBlock:^{
                BackupViewController *backupViewController = (BackupViewController *)[[UIStoryboard storyboardWithName:@"Backup" bundle:nil] instantiateViewControllerWithIdentifier:@"BackupViewController"];
                [selectedNavigationController pushViewController:backupViewController animated:YES];
            }];
            [CATransaction commit];
        }];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)updateRestoreState {
    DDLogVerbose(@"%@ updateRestoreState", LOG_TAG);
    
    if (self.restoreState == TLRestoreStateStarting) {
        self.restoreInProgress = YES;
        self.cancelView.hidden = NO;
        self.navigationItem.leftBarButtonItem = nil;
    } else if (self.restoreState == TLRestoreStateWaitConfirm) {
        if (!self.isBackupHeaderInfoOK) {
            [self showBackupHeaderInfoError];
        } else if (!self.verifyMode) {
            [self confirmRestore];
        }
    } else if (self.restoreState == TLRestoreStateTerminated || self.restoreState == TLRestoreStateCancel) {
        self.cancelView.hidden = YES;
        self.restoreInProgress = NO;
        if (self.verifyMode) {
            self.isVerifyBackupTerminated = YES;
            self.navigationItem.leftBarButtonItem = self.cancelBarButtonItem;
            self.cancelBarButtonItem.title = TwinmeLocalizedString(@"application_back", nil);
        }
    }

    [self updateContent];
}

- (void)showErrorMessage:(TLBackupServiceErrorCode)errorCode {
    DDLogVerbose(@"%@ showErrorMessage: %d", LOG_TAG, errorCode);
    
    NSString *message;
    if (errorCode == TLBackupServiceErrorCodeNoSpaceLeft) {
        message = TwinmeLocalizedString(@"application_error_no_storage_space", nil);
    } else if (errorCode == TLBackupServiceErrorCodeInvalidKey) {
        message = TwinmeLocalizedStringFromTable(@"backup_view_error_words", @"LocalizableBackup", nil);
    } else if (errorCode == TLBackupServiceErrorCodeDifferentAccount) {
        message = TwinmeLocalizedStringFromTable(@"restore_view_verify_same_account", @"LocalizableBackup", nil);
    } else if (errorCode == TLBackupServiceErrorCodeInvalidFile && !self.isBackupHeaderInfoOK) {
        message = TwinmeLocalizedStringFromTable(@"restore_view_file_not_supported", @"LocalizableBackup", nil);
    } else {
        message = TwinmeLocalizedStringFromTable(@"restore_view_error_message", @"LocalizableBackup", nil);
    }
    
    AlertMessageView *alertMessageView = [[AlertMessageView alloc] init];
    alertMessageView.alertMessageViewDelegate = self;
    alertMessageView.tag = errorCode;
    [alertMessageView initWithTitle:TwinmeLocalizedString(@"deleted_account_view_warning", nil) message:message];
    [self.navigationController.view addSubview:alertMessageView];
    [alertMessageView showAlertView];
}

- (void)showBackupHeaderInfoError {
    DDLogVerbose(@"%@ showBackupHeaderInfoError", LOG_TAG);
    
    AlertMessageView *alertMessageView = [[AlertMessageView alloc] init];
    alertMessageView.alertMessageViewDelegate = self;
    alertMessageView.tag = HEADER_INFO_VIEW_TAG;
    [alertMessageView initWithTitle:TwinmeLocalizedString(@"deleted_account_view_warning", nil) message:TwinmeLocalizedStringFromTable(@"restore_view_application_error", @"LocalizableBackup", nil)];
    [self.navigationController.view addSubview:alertMessageView];
    [alertMessageView showAlertView];
}

- (NSArray *)getWordsList {
    DDLogVerbose(@"%@ getWordsList", LOG_TAG);
    
    NSMutableArray *words = [[NSMutableArray alloc]init];
    
    for (UIBackupWord *backupWord in self.backupWords) {
        [words addObject:[backupWord getWord]];
    }
    
    return words;
}

- (BOOL)isAllWordsCompleted {
    DDLogVerbose(@"%@ isAllWordsCompleted", LOG_TAG);
    
    if (!self.backupWords || self.backupWords.count == 0) {
        return NO;
    }
    
    for (UIBackupWord *backupWord in self.backupWords) {
        if (![backupWord getWord]) {
            return NO;
        }
    }
    
    return YES;
}

- (void)startRestore {
    DDLogVerbose(@"%@ startRestore", LOG_TAG);
    
    NSData *password = [self.mnemonicCodeUtils toEntropyWithWords:[self getWordsList]];
    
    if (password.length == 0){
        [self showErrorMessage:TLBackupServiceErrorCodeInvalidKey];
        return;
    }
    
    if (self.verifyMode) {
        [self.backupService startVerifyWithPassword:password backupPath:self.backupURL.path];
    } else {
        [self.backupService startRestoreWithPassword:password backupPath:self.backupURL.path];
    }
    
    [self updateContent];
}

- (void)confirmRestore {
    DDLogVerbose(@"%@ confirmRestore", LOG_TAG);
    
    BackupContentConfirmView *backupContentConfirmView = [[BackupContentConfirmView alloc] init];
    backupContentConfirmView.bottomSheetViewDelegate = self;
    [backupContentConfirmView initWithTitle:TwinmeLocalizedString(@"deleted_account_view_warning", nil) message:TwinmeLocalizedStringFromTable(@"restore_view_confirm", @"LocalizableBackup", nil) avatar:nil icon:nil];
    [backupContentConfirmView initWithRestoreReport:self.restoreReport isLastBackup:self.isLastBackup];
    [self.navigationController.view addSubview:backupContentConfirmView];
    [backupContentConfirmView showConfirmView];
}

- (void)rollbackRestore {
    DDLogVerbose(@"%@ rollbackRestore", LOG_TAG);
    
    [self.backupService cancelRestore];
}

- (NSMutableAttributedString *)getRestoreMessage {
    DDLogVerbose(@"%@ getRestoreMessage", LOG_TAG);
    
    NSString *restoreStateTitle;
    NSString *restoreStateText = @"";
    switch (self.restoreState) {
        case TLRestoreStateStarting:
            restoreStateText = self.verifyMode ? TwinmeLocalizedStringFromTable(@"restore_view_state_restore_verify_starting", @"LocalizableBackup", nil) : TwinmeLocalizedStringFromTable(@"restore_view_state_restore_starting", @"LocalizableBackup", nil);
            break;
            
        case TLRestoreStateRestoreAccount:
            restoreStateText = self.verifyMode ? TwinmeLocalizedStringFromTable(@"restore_view_state_restore_verify_account", @"LocalizableBackup", nil) : TwinmeLocalizedStringFromTable(@"restore_view_state_restore_account", @"LocalizableBackup", nil);
            break;
            
        case TLRestoreStateRestoreData:
            restoreStateText = self.verifyMode ? TwinmeLocalizedStringFromTable(@"restore_view_state_restore_verify_data", @"LocalizableBackup", nil) : TwinmeLocalizedStringFromTable(@"restore_view_state_restore_data", @"LocalizableBackup", nil);
            break;
            
        case TLRestoreStateWaitConfirm:
            restoreStateText = TwinmeLocalizedStringFromTable(@"restore_view_state_restore_wait_confirm", @"LocalizableBackup", nil);
            break;
            
        case TLRestoreStateTerminated:
            
            if (self.verifyMode) {
                restoreStateTitle = TwinmeLocalizedStringFromTable(@"backup_view_verify_completed", @"LocalizableBackup", nil);
                if (self.restoreReport && self.restoreReport.isRestoreUpToDate) {
                    if (self.isLastBackup) {
                        restoreStateText = TwinmeLocalizedStringFromTable(@"backup_view_verify_up_to_date", @"LocalizableBackup", nil);
                    } else {
                        restoreStateText = [NSString stringWithFormat:@"%@\n\n%@", TwinmeLocalizedStringFromTable(@"restore_view_more_recent_backup", @"LocalizableBackup", nil), TwinmeLocalizedStringFromTable(@"backup_view_verify_up_to_date", @"LocalizableBackup", nil)];
                    }
                } else if (self.restoreReport) {
                    if (self.isLastBackup) {
                        restoreStateText = TwinmeLocalizedStringFromTable(@"backup_view_content_diff_message", @"LocalizableBackup", nil);
                    } else {
                        restoreStateText = [NSString stringWithFormat:@"%@\n\n%@", TwinmeLocalizedStringFromTable(@"restore_view_more_recent_backup", @"LocalizableBackup", nil), TwinmeLocalizedStringFromTable(@"backup_view_content_diff_message", @"LocalizableBackup", nil)];
                    }
                } else {
                    restoreStateTitle = TwinmeLocalizedString(@"application_canceled_operation", nil);
                }
            } else {
                restoreStateTitle = TwinmeLocalizedStringFromTable(@"restore_view_success", @"LocalizableBackup", nil);
                restoreStateText = TwinmeLocalizedStringFromTable(@"restore_view_success_message", @"LocalizableBackup", nil);
            }
            break;
            
        case TLRestoreStateCancel:
            
            if (!self.verifyMode) {
                restoreStateTitle = TwinmeLocalizedString(@"application_canceled_operation", nil);
                restoreStateText = TwinmeLocalizedString(@"account_migration_view_cancel_message", nil);
            }
            
            break;
            
        default:
            break;
    }
    
    NSMutableAttributedString *restoreStateAttributedText = [[NSMutableAttributedString alloc]initWithString:@""];
    
    if (restoreStateTitle) {
        [restoreStateAttributedText appendAttributedString:[[NSMutableAttributedString alloc] initWithString:restoreStateTitle attributes:[NSDictionary dictionaryWithObjectsAndKeys:Design.FONT_MEDIUM34, NSFontAttributeName, Design.FONT_COLOR_DEFAULT, NSForegroundColorAttributeName, nil]]];
        [restoreStateAttributedText appendAttributedString:[[NSMutableAttributedString alloc]initWithString:@"\n\n"]];
    }
    
    [restoreStateAttributedText appendAttributedString:[[NSMutableAttributedString alloc] initWithString:restoreStateText attributes:[NSDictionary dictionaryWithObjectsAndKeys:Design.FONT_REGULAR32, NSFontAttributeName,  Design.FONT_COLOR_DEFAULT, NSForegroundColorAttributeName, nil]]];
    
    return restoreStateAttributedText;
}

- (void)updateContent {
    DDLogVerbose(@"%@ updateContent", LOG_TAG);
    
    [self.restoreItems removeAllObjects];
    [self.restoreItems addObject:[[UIRestoreItem alloc] initWithType:UIRestoreItemTypeHeader text:nil icon:nil value:-1 color:nil]];
    
    if (self.restoreState == TLRestoreStateStarting && !self.restoreInProgress) {
        [self.restoreItems addObject:[[UIRestoreItem alloc] initWithType:UIRestoreItemTypeWords text:nil icon:nil value:-1 color:nil]];
        [self.restoreItems addObject:[[UIRestoreItem alloc] initWithType:UIRestoreItemTypeFooter text:nil icon:nil value:-1 color:nil]];
    } else {
        [self.restoreItems addObject:[[UIRestoreItem alloc] initWithType:UIRestoreItemTypeState text:nil icon:nil value:-1 color:nil]];
        
        if (self.verifyMode && self.isVerifyBackupTerminated && self.restoreReport && ![self.restoreReport isRestoreUpToDate]) {
            
            if (![self.restoreReport.profiles isStatsUpToDate]) {
                [self.restoreItems addObject:[[UIRestoreItem alloc] initWithType:UIRestoreItemTypeSection text:TwinmeLocalizedString(@"application_profile", nil) icon:nil value:-1 color:nil]];
                [self.restoreItems addObject:[[UIRestoreItem alloc] initWithType:UIRestoreItemTypeContent text:TwinmeLocalizedStringFromTable(@"restore_view_content_profile_reset", @"LocalizableBackup", nil) icon:[UIImage imageNamed:@"GenerateCode"] value:-1 color:Design.BLACK_COLOR]];
                [self.restoreItems addObject:[[UIRestoreItem alloc] initWithType:UIRestoreItemTypeInfo text:TwinmeLocalizedStringFromTable(@"restore_view_content_profile_reset_message", @"LocalizableBackup", nil) icon:nil value:-1 color:nil]];
            }
            
            if (![self.restoreReport.contacts isStatsUpToDate]) {
                [self.restoreItems addObject:[[UIRestoreItem alloc] initWithType:UIRestoreItemTypeSection text:TwinmeLocalizedString(@"contacts_view_title", nil) icon:nil value:-1 color:nil]];
                
                if (self.restoreReport.contacts.added != 0) {
                    [self.restoreItems addObject:[[UIRestoreItem alloc] initWithType:UIRestoreItemTypeContent text:TwinmeLocalizedStringFromTable(@"backup_view_content_diff_added", @"LocalizableBackup", nil) icon:[UIImage imageNamed:@"ContactsIcon"] value:self.restoreReport.contacts.added color:Design.BLACK_COLOR]];
                }
                
                if (self.restoreReport.contacts.modified != 0) {
                    [self.restoreItems addObject:[[UIRestoreItem alloc] initWithType:UIRestoreItemTypeContent text:TwinmeLocalizedStringFromTable(@"backup_view_content_diff_updated", @"LocalizableBackup", nil) icon:[UIImage imageNamed:@"ActionEdit"] value:self.restoreReport.contacts.modified color:Design.BLACK_COLOR]];
                }
                
                if (self.restoreReport.contacts.deleted != 0) {
                    [self.restoreItems addObject:[[UIRestoreItem alloc] initWithType:UIRestoreItemTypeContent text:TwinmeLocalizedStringFromTable(@"backup_view_content_diff_deleted", @"LocalizableBackup", nil) icon:[UIImage imageNamed:@"DeleteItem"] value:self.restoreReport.contacts.deleted color:nil]];
                    [self.restoreItems addObject:[[UIRestoreItem alloc] initWithType:UIRestoreItemTypeInfo text:TwinmeLocalizedStringFromTable(@"restore_view_content_contact_deleted_message", @"LocalizableBackup", nil) icon:nil value:-1 color:nil]];
                }
            }
            
            if (![self.restoreReport.groups isStatsUpToDate]) {
                [self.restoreItems addObject:[[UIRestoreItem alloc] initWithType:UIRestoreItemTypeSection text:TwinmeLocalizedString(@"share_view_group_list", nil) icon:nil value:-1 color:nil]];
                
                if (self.restoreReport.groups.added != 0) {
                    [self.restoreItems addObject:[[UIRestoreItem alloc] initWithType:UIRestoreItemTypeContent text:TwinmeLocalizedStringFromTable(@"backup_view_content_diff_added", @"LocalizableBackup", nil) icon:[UIImage imageNamed:@"GroupsIcon"] value:self.restoreReport.groups.added color:Design.BLACK_COLOR]];
                }
                
                if (self.restoreReport.groups.modified != 0) {
                    [self.restoreItems addObject:[[UIRestoreItem alloc] initWithType:UIRestoreItemTypeContent text:TwinmeLocalizedStringFromTable(@"backup_view_content_diff_updated", @"LocalizableBackup", nil) icon:[UIImage imageNamed:@"ActionEdit"] value:self.restoreReport.groups.modified color:Design.BLACK_COLOR]];
                }
                
                if (self.restoreReport.groups.deleted != 0) {
                    [self.restoreItems addObject:[[UIRestoreItem alloc] initWithType:UIRestoreItemTypeContent text:TwinmeLocalizedStringFromTable(@"backup_view_content_diff_deleted", @"LocalizableBackup", nil) icon:[UIImage imageNamed:@"DeleteItem"] value:self.restoreReport.groups.deleted color:nil]];
                    [self.restoreItems addObject:[[UIRestoreItem alloc] initWithType:UIRestoreItemTypeInfo text:TwinmeLocalizedStringFromTable(@"restore_view_content_contact_deleted_message", @"LocalizableBackup", nil) icon:nil value:-1 color:nil]];
                }
            }
            
            [self.restoreItems addObject:[[UIRestoreItem alloc] initWithType:UIRestoreItemTypeFooter text:nil icon:nil value:-1 color:nil]];
        }
    }
    
    [self.tableView reloadData];
}

- (void)pasteWords:(NSString *)pastedContent {
    DDLogVerbose(@"%@ pasteWords: %@", LOG_TAG, pastedContent);
    
    NSArray *words = [pastedContent componentsSeparatedByString:@" "];
    [self.backupWords removeAllObjects];
    
    BOOL incorrectWordToPaste = NO;
    for (int index = 0; index < COUNT_WORDS; index++) {
        
        if (index < words.count) {
            
            NSArray *suggestions = [self.mnemonicCodeUtils getSuggestionsWithPrefix:[words objectAtIndex:index] locale:nil];
            
            if (suggestions && suggestions.count > 0) {
                UIBackupWord *backupWord = [[UIBackupWord alloc]initWithWord:[words objectAtIndex:index] position:index];
                [self.backupWords addObject:backupWord];
            } else {
                incorrectWordToPaste = YES;
                UIBackupWord *backupWord = [[UIBackupWord alloc]initWithWord:nil position:index];
                [self.backupWords addObject:backupWord];
            }
            
        } else {
            UIBackupWord *backupWord = [[UIBackupWord alloc]initWithWord:nil position:index];
            [self.backupWords addObject:backupWord];
        }
    }
    
    if (incorrectWordToPaste) {
        UIWindow *window = [self currentWindow];
        if (window) {
            [window makeToast:TwinmeLocalizedStringFromTable(@"restore_view_paste_error", @"LocalizableBackup", nil)];
        }
    }
    
    self.canRestore = [self isAllWordsCompleted];
    [self.tableView reloadData];
}

- (void)copyFile:(NSURL *)fileURL {
    DDLogVerbose(@"%@ copyFile", LOG_TAG);
    
    BOOL access = [fileURL startAccessingSecurityScopedResource];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *fileName = fileURL.lastPathComponent;
    NSURL *tmpUrl = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:fileName]];
    NSError *error = nil;
    if ([fileManager fileExistsAtPath:tmpUrl.path]) {
        [fileManager removeItemAtPath:tmpUrl.path error:nil];
    }

    BOOL success = [fileManager copyItemAtURL:fileURL toURL:tmpUrl error:&error];
    if (access) {
        [fileURL stopAccessingSecurityScopedResource];
    }
    
    if (success) {
        self.backupURL = tmpUrl;
    } else {
        [self finish];
    }
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    self.cancelLabel.font = Design.FONT_MEDIUM34;
    [self.tableView reloadData];
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    self.view.backgroundColor = Design.WHITE_COLOR;
    self.tableView.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
    [self.cancelView setBackgroundColor:Design.BUTTON_RED_COLOR];
}

@end
