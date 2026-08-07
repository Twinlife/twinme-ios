/*
 *  Copyright (c) 2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <Twinlife/TLBackupInfo.h>

#import "BackupsViewController.h"
#import "BackupViewController.h"

#import <Utils/NSString+Utils.h>

#import <TwinmeCommon/Design.h>
#import "DefaultConfirmView.h"
#import <TwinmeCommon/OnboardingConfirmView.h>

#import "BackupCell.h"
#import "UIBackupInfo.h"

#import <TwinmeCommon/BackupService.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static NSString *BACKUP_CELL_IDENTIFIER = @"BackupCellIdentifier";

//
// Interface: BackupsViewController ()
//

@interface BackupsViewController () <UITableViewDataSource, UITableViewDelegate, BottomSheetViewDelegate, BackupServiceDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *noBackupView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *noBackupImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *noBackupImageViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *noBackupImageViewTopConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *noBackupImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *noBackupLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *noBackupLabelTopConstraint;
@property (weak, nonatomic) IBOutlet UILabel *noBackupLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *startBackupViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *startBackupViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *startBackupViewBottomConstraint;
@property (weak, nonatomic) IBOutlet UIView *startBackupView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *startBackupLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet UILabel *startBackupLabel;

@property (nonatomic) UIBarButtonItem *invalidBackupBarButtonItem;

@property (nonatomic) NSMutableArray *backups;
@property (nonatomic) BackupService *backupService;
@property (nonatomic) BOOL isGetBackupsDone;

@end

//
// Implementation: BackupsViewController
//

#undef LOG_TAG
#define LOG_TAG @"BackupsViewController"

@implementation BackupsViewController

- (instancetype)initWithCoder:(NSCoder *)coder {
    DDLogVerbose(@"%@ initWithCoder: %@", LOG_TAG, coder);
    
    self = [super initWithCoder:coder];
    
    if (self) {
        _isGetBackupsDone = NO;
        _backups = [[NSMutableArray alloc]init];
        _backupService = [[BackupService alloc] initWithTwinmeContext:self.twinmeContext delegate:self];
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
    
    [self.backupService getAllBackups];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    [self reloadData];
}

#pragma mark - UITableViewDataSource

- (void)onBackupErrorWithBackupErrorCode:(TLBackupServiceErrorCode)backupErrorCode baseErrorCode:(TLBaseServiceErrorCode)baseErrorCode {
    DDLogVerbose(@"%@ onBackupErrorWithErrorCode: %ld parameter: %ld", LOG_TAG, (long)backupErrorCode, (long)baseErrorCode);
}

- (void)onBackupHeaderInfoWithHeaderInfo:(nonnull TLBackupHeaderInfo *)headerInfo lastBackupId:(nullable NSUUID *)lastBackupId lastBackupTimestamp:(int64_t)lastBackupTimestamp {
    DDLogVerbose(@"%@ onBackupHeaderInfoWithHeaderInfo: %@", LOG_TAG, headerInfo);
}

- (void)onBackupStateChangeWithBackupId:(nonnull NSUUID *)backupId state:(TLBackupState)state {
    DDLogVerbose(@"%@ onBackupStateChangeWithBackupId: %@ state: %ld", LOG_TAG, backupId, (long)state);
}

- (void)onDeleteBackupsWithErrorCode:(TLBaseServiceErrorCode)errorCode {
    DDLogVerbose(@"%@ onDeleteBackupsWithErrorCode: %ld", LOG_TAG, (long)errorCode);
    
    if (errorCode == TLBaseServiceErrorCodeSuccess) {
        [self.twinmeApplication clearLastBackupDate];
        [self.backups removeAllObjects];
        [self reloadData];
    }
}

- (void)onGetAllBackupsWithErrorCode:(TLBaseServiceErrorCode)errorCode backups:(nonnull NSArray<TLBackupInfo *> *)backups {
    DDLogVerbose(@"%@ onGetAllBackupsWithErrorCode: %ld backups: %@", LOG_TAG, (long)errorCode, backups);
    
    self.isGetBackupsDone = YES;
    
    NSMutableArray *allBackups = [[NSMutableArray alloc] init];
    if (errorCode == TLBaseServiceErrorCodeSuccess) {
        for (TLBackupInfo *backupInfo in backups) {
            UIBackupInfo *uiBackupInfo = [[UIBackupInfo alloc] initWithBackupId:backupInfo.uuid backupDate:backupInfo.creationDate];
            [allBackups insertObject:uiBackupInfo atIndex:0];
        }
    }
    
    [self.backups addObjectsFromArray:[allBackups sortedArrayUsingComparator:^NSComparisonResult(UIBackupInfo *backupInfo1, UIBackupInfo *backupInfo2) {
        
        if (backupInfo1.backupDate > backupInfo2.backupDate) {
            return NSOrderedAscending;
        } else if (backupInfo1.backupDate < backupInfo2.backupDate) {
            return NSOrderedDescending;
        }
        return NSOrderedSame;
    }]];
    
    [self reloadData];
}

- (void)onRestoreErrorWithBackupErrorCode:(TLBackupServiceErrorCode)backupErrorCode baseErrorCode:(TLBaseServiceErrorCode)baseErrorCode {
    DDLogVerbose(@"%@ onRestoreErrorWithErrorCode: %ld parameter: %ld", LOG_TAG, (long)backupErrorCode, (long)baseErrorCode);
}

- (void)onRestoreStateChangeWithState:(TLRestoreState)state restoreReport:(nullable RestoreReport *)restoreReport {
    DDLogVerbose(@"%@ onRestoreStateChangeWithState: %ld restoreReport: %@", LOG_TAG, (long)state, restoreReport);
}

- (void)onTerminateBackupWithBackupId:(nonnull NSUUID *)backupId backupFilePath:(nullable NSString *)backupFilePath stats:(nonnull NSDictionary<NSUUID *,NSNumber *> *)stats done:(BOOL)done {
    DDLogVerbose(@"%@ onTerminateBackupWithBackupId: %@ backupFilePath: %@ stats: %@ done: %@", LOG_TAG, backupId, backupFilePath, stats, done ? @"YES" : @"NO");
}

- (void)onTerminateRestoreWithTerminateReason:(TLBackupServiceTerminateReason)terminateReason {
    DDLogVerbose(@"%@ onTerminateRestoreWithTerminateReason: %ld", LOG_TAG, (long)terminateReason);
}

- (void)onWordsGeneratedWithWords:(nonnull NSArray<NSString *> *)words {
    DDLogVerbose(@"%@ onWordsGeneratedWithWords: %@", LOG_TAG, words);
}

- (void)onCheckFileCompatibilityWithResult:(TLBackupServiceErrorCode)result {
    DDLogVerbose(@"%@ onCheckFileCompatibilityWithResult: %d", LOG_TAG, result);
}

- (void)onTerminateVerifyWithReport:(nonnull RestoreReport *)report { 
    DDLogVerbose(@"%@ onTerminateVerifyWithReport: %@", LOG_TAG, report);
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    DDLogVerbose(@"%@ numberOfSectionsInTableView: %@", LOG_TAG, tableView);
    
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath  {
    DDLogVerbose(@"%@ tableView: %@ heightForRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    return Design.SETTING_CELL_HEIGHT;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ heightForFooterInSection: %ld", LOG_TAG, tableView, (long)section);
    
    return CGFLOAT_MIN;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ numberOfRowsInSection: %ld", LOG_TAG, tableView, (long)section);
    
    return self.backups.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ heightForHeaderInSection: %ld", LOG_TAG, tableView, (long)section);
    
    return CGFLOAT_MIN;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ cellForRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    BackupCell *cell = [tableView dequeueReusableCellWithIdentifier:BACKUP_CELL_IDENTIFIER];
    if (!cell) {
        cell = [[BackupCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:BACKUP_CELL_IDENTIFIER];
    }
    
    [cell bindWithBackupInfo:self.backups[indexPath.row] hiddenSeparator:indexPath.row == self.backups.count - 1];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ didSelectRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
}

#pragma mark - BottomSheetViewDelegate

- (void)didTapConfirm:(nonnull AbstractBottomSheetView *)abstractConfirmView {
    DDLogVerbose(@"%@ didTapConfirm: %@", LOG_TAG, abstractConfirmView);
    
    if ([abstractConfirmView isKindOfClass:[DefaultConfirmView class]]) {
        [self invalidateBackup];
    } else {
        [self startBackup];
    }
    
    [abstractConfirmView closeConfirmView];
}

- (void)didTapCancel:(nonnull AbstractBottomSheetView *)abstractConfirmView {
    DDLogVerbose(@"%@ didTapCancel: %@", LOG_TAG, abstractConfirmView);
    
    if ([abstractConfirmView isKindOfClass:[OnboardingConfirmView class]]) {
        [self.twinmeApplication setShowOnboardingType:OnboardingTypeBackup state:NO];
    }
    
    
    [abstractConfirmView closeConfirmView];
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
    
    [self setNavigationTitle:TwinmeLocalizedStringFromTable(@"account_view_backup_list", @"LocalizableBackup", nil)];
    
    self.invalidBackupBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"ActionBarDelete"] style:UIBarButtonItemStylePlain target:self action:@selector(invalidBackupsAction:)];
    self.invalidBackupBarButtonItem.accessibilityLabel = TwinmeLocalizedStringFromTable(@"backups_view_invalidate_backup", @"LocalizableBackup", nil);
    self.navigationItem.rightBarButtonItem = self.invalidBackupBarButtonItem;
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"BackupCell" bundle:nil] forCellReuseIdentifier:BACKUP_CELL_IDENTIFIER];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = Design.WHITE_COLOR;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = Design.SETTING_CELL_HEIGHT;
    
    self.noBackupView.hidden = NO;
    
    self.noBackupImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.noBackupImageViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.noBackupImageViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.noBackupLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.noBackupLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.noBackupLabel.font = Design.FONT_MEDIUM34;
    self.noBackupLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.noBackupLabel.text =  TwinmeLocalizedStringFromTable(@"backups_view_no_backup_message", @"LocalizableBackup", nil);
    
    self.startBackupViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.startBackupViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.startBackupViewBottomConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.startBackupView.backgroundColor = Design.MAIN_COLOR;
    self.startBackupView.userInteractionEnabled = YES;
    self.startBackupView.layer.cornerRadius = Design.CONTAINER_RADIUS;
    self.startBackupView.clipsToBounds = YES;
    self.startBackupView.isAccessibilityElement = YES;
    self.startBackupView.accessibilityLabel = TwinmeLocalizedStringFromTable(@"backup_view_new_backup", @"LocalizableBackup", nil);
    [self.startBackupView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleStartBackupTapGesture:)]];
    
    self.startBackupLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.startBackupLabel.font = Design.FONT_BOLD36;
    self.startBackupLabel.textColor = [UIColor whiteColor];
    self.startBackupLabel.text = TwinmeLocalizedStringFromTable(@"backup_view_new_backup", @"LocalizableBackup", nil);
}

- (void)finish {
    DDLogVerbose(@"%@ finish", LOG_TAG);
    
    if (self.backupService) {
        [self.backupService dispose];
    }
    
    [super finish];
}

- (IBAction)invalidBackupsAction:(id)sender {
    DDLogVerbose(@"%@ invalidBackupsAction: %@", LOG_TAG, sender);

    NSString *message = [NSString stringWithFormat:@"%@\n\n%@", TwinmeLocalizedStringFromTable(@"backups_view_invalidate_backup_message_part_one", @"LocalizableBackup", nil), TwinmeLocalizedStringFromTable(@"backups_view_invalidate_backup_message_part_two", @"LocalizableBackup", nil)];
    
    DefaultConfirmView *defaultConfirmView = [[DefaultConfirmView alloc] init];
    defaultConfirmView.bottomSheetViewDelegate = self;
    [defaultConfirmView initWithTitle:TwinmeLocalizedStringFromTable(@"backups_view_invalidate_backup", @"LocalizableBackup", nil) message:message image:nil avatar:nil action:TwinmeLocalizedString(@"application_delete", nil) actionColor:Design.DELETE_COLOR_RED cancel:TwinmeLocalizedString(@"application_cancel", nil)];
    [self.navigationController.view addSubview:defaultConfirmView];
    [defaultConfirmView showConfirmView];
}

- (void)handleStartBackupTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleStartBackupTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        
        if ([self.twinmeApplication startOnboarding:OnboardingTypeBackup]) {
            OnboardingConfirmView *onboardingConfirmView = [[OnboardingConfirmView alloc] init];
            onboardingConfirmView.bottomSheetViewDelegate = self;
            
            UIImage *image = [UIImage imageNamed:@"OnboardingBackup"];
            NSString *title = TwinmeLocalizedStringFromTable(@"account_view_backup", @"LocalizableBackup", nil);
            NSString *message = TwinmeLocalizedStringFromTable(@"backup_view_onboarding", @"LocalizableBackup", nil);
            NSString *action = TwinmeLocalizedStringFromTable(@"backup_view_backup", @"LocalizableBackup", nil);
            
            [onboardingConfirmView initWithTitle:title message:message image:image action:action actionColor:nil cancel:TwinmeLocalizedString(@"application_do_not_display", nil)];
            
            [self.navigationController.view addSubview:onboardingConfirmView];
            [onboardingConfirmView showConfirmView];
        } else {
            [self startBackup];
        }
    }
}

- (void)startBackup {
    DDLogVerbose(@"%@ startBackup", LOG_TAG);
    
    [self.navigationController popViewControllerAnimated:YES];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        BackupViewController *backupViewController = (BackupViewController *)[[UIStoryboard storyboardWithName:@"Backup" bundle:nil] instantiateViewControllerWithIdentifier:@"BackupViewController"];
        [self.navigationController pushViewController:backupViewController animated:YES];
    });
}

- (void)invalidateBackup {
    DDLogVerbose(@"%@ invalidateBackup", LOG_TAG);
    
    [self.backupService deleteBackups];
}

- (void)reloadData {
    DDLogVerbose(@"%@ invalidateBackup", LOG_TAG);
    
    if (self.backups.count == 0) {
        self.noBackupView.hidden = NO;
        
        if (!self.isGetBackupsDone) {
            self.startBackupView.hidden = YES;
            self.noBackupLabel.text = TwinmeLocalizedString(@"application_processing_please_wait", nil);
        } else {
            self.startBackupView.hidden = NO;
            self.noBackupLabel.text = TwinmeLocalizedStringFromTable(@"backups_view_no_backup_message", @"LocalizableBackup", nil);
        }
        
        self.tableView.hidden = YES;
        self.invalidBackupBarButtonItem.enabled = NO;
    } else {
        self.noBackupView.hidden = YES;
        self.tableView.hidden = NO;
        self.invalidBackupBarButtonItem.enabled = YES;
    }
    
    [self.tableView reloadData];
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    self.tableView.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
    self.noBackupLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.startBackupView.backgroundColor = Design.MAIN_COLOR;
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    [self.tableView reloadData];
    self.noBackupLabel.font = Design.FONT_MEDIUM34;
    self.startBackupLabel.font = Design.FONT_BOLD36;
}

@end
