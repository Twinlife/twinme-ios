/*
 *  Copyright (c) 2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import "SuccessBackupViewController.h"

#import "BackupWordsCell.h"
#import "BackupInfoCell.h"
#import "BackupActionCell.h"
#import "SettingsInformationCell.h"
#import "SettingsSectionHeaderCell.h"

#import "UIBackupWord.h"

#import <Utils/NSString+Utils.h>

#import <TwinmeCommon/Design.h>

#import "UIView+Toast.h"
#import "DefaultConfirmView.h"
#import "OnboardingConfirmView.h"

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static NSString *SETTINGS_INFORMATION_CELL_IDENTIFIER = @"SettingsInformationCellIdentifier";
static NSString *HEADER_SETTINGS_CELL_IDENTIFIER = @"HeaderSettingsCellIdentifier";
static NSString *BACKUP_WORDS_CELL_IDENTIFIER = @"BackupWordsCellIdentifier";
static NSString *BACKUP_INFO_CELL_IDENTIFIER = @"BackupInfoCellIdentifier";
static NSString *BACKUP_ACTION_CELL_IDENTIFIER = @"BackupActionCellIdentifier";

static float DESIGN_INFO_CELL_HEIGHT = 190;

typedef enum {
    SECTION_INFO,
    SECTION_WORDS,
    SECTION_COUNT
} SuccessBackupSection;

//
// Interface: SuccessBackupViewController ()
//

@interface SuccessBackupViewController ()<UITableViewDelegate, UITableViewDataSource, UIDocumentPickerDelegate, BottomSheetViewDelegate, BackupActionDelegate>

@property (nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic) NSArray *backupWords;
@property (nonatomic) NSString *backupPath;
@property (nonatomic) NSUUID *backupId;

@property BOOL isShowSucessView;

@end

//
// Implementation: SuccessBackupViewController
//

#undef LOG_TAG
#define LOG_TAG @"SuccessBackupViewController"

@implementation SuccessBackupViewController

- (instancetype)initWithCoder:(NSCoder *)coder {
    DDLogVerbose(@"%@ initWithCoder: %@", LOG_TAG, coder);
    
    self = [super initWithCoder:coder];
    
    if (self) {
        _isShowSucessView = NO;
    }
    return self;
}

- (void)viewDidLoad {
    DDLogVerbose(@"%@ viewDidLoad", LOG_TAG);
    
    [super viewDidLoad];
    
    [self initViews];
}

- (void)viewWillAppear:(BOOL)animated {
    DDLogVerbose(@"%@ viewWillAppear", LOG_TAG);
    
    [super viewWillAppear:animated];
    
    if (!self.isShowSucessView) {
        [self.twinmeApplication setLastBackupDate];
        self.isShowSucessView = YES;
        [self showSuccessView];
    }
}

- (void)initWithBackupPath:(NSString *)backupPath words:(NSArray *)words backupId:(NSUUID *)backupId {
    DDLogVerbose(@"%@ initWithBackupPath: %@ words: %@ backupId: %@", LOG_TAG, backupPath, words, backupId);
    
    self.backupPath = backupPath;
    self.backupId = backupId;
    self.backupWords = words;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    DDLogVerbose(@"%@ numberOfSectionsInTableView: %@", LOG_TAG, tableView);
    
    return SECTION_COUNT;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath  {
    DDLogVerbose(@"%@ tableView: %@ heightForRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    if (indexPath.row == 0) {
        return roundf(DESIGN_INFO_CELL_HEIGHT * Design.HEIGHT_RATIO);
    }
    
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ heightForHeaderInSection: %ld", LOG_TAG, tableView, (long)section);
    
    if (section == SECTION_INFO) {
        return CGFLOAT_MIN;
    }
    
    return Design.CELL_HEIGHT;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ heightForFooterInSection: %ld", LOG_TAG, tableView, (long)section);
    
    return CGFLOAT_MIN;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ numberOfRowsInSection: %ld", LOG_TAG, tableView, (long)section);
    
    if (section == SECTION_INFO) {
        return 2;
    } else {
        return 3;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ viewForHeaderInSection: %ld", LOG_TAG, tableView, (long)section);
    
    if (section == SECTION_INFO) {
        return [[UIView alloc]init];
    }
    
    SettingsSectionHeaderCell *settingsSectionHeaderCell = (SettingsSectionHeaderCell *)[tableView dequeueReusableCellWithIdentifier:HEADER_SETTINGS_CELL_IDENTIFIER];
    if (!settingsSectionHeaderCell) {
        settingsSectionHeaderCell = [[SettingsSectionHeaderCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:HEADER_SETTINGS_CELL_IDENTIFIER];
    }
    
    NSString *sectionTitle = TwinmeLocalizedStringFromTable(@"backup_view_controller_security", @"LocalizableBackup", nil);
    [settingsSectionHeaderCell bindWithTitle:sectionTitle backgroundColor:Design.LIGHT_GREY_BACKGROUND_COLOR hideSeparator:YES uppercaseString:YES];
    
    return settingsSectionHeaderCell;
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
    } else if ([self isActionPath:indexPath]) {
        BackupActionCell *cell = [tableView dequeueReusableCellWithIdentifier:BACKUP_ACTION_CELL_IDENTIFIER];
        if (!cell) {
            cell = [[BackupActionCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:BACKUP_ACTION_CELL_IDENTIFIER];
        }
        
        cell.tag = indexPath.section;
        cell.backupActionDelegate = self;
        
        if (indexPath.section == SECTION_INFO) {
            [cell bindWithTitle:TwinmeLocalizedString(@"application_save", nil) rightTitle:TwinmeLocalizedString(@"share_view_controller_title", nil) leftImage:[UIImage imageNamed:@"SaveItem"] rightImage:[UIImage imageNamed:@"ShareItem"]];
        } else {
            [cell bindWithTitle:TwinmeLocalizedString(@"conversation_view_controller_menu_item_view_copy_title", nil) rightTitle:nil leftImage:[UIImage imageNamed:@"CopyItem"] rightImage:nil];
        }
        
        return cell;
        
    } else if (indexPath.row == 0) {
        BackupInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:BACKUP_INFO_CELL_IDENTIFIER];
        if (!cell) {
            cell = [[BackupInfoCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:BACKUP_INFO_CELL_IDENTIFIER];
        }
        
        NSString *fileName = self.backupPath.lastPathComponent;
        [cell bindWithTitle:fileName];
        return cell;
    } else {
        BackupWordsCell *cell = [tableView dequeueReusableCellWithIdentifier:BACKUP_WORDS_CELL_IDENTIFIER];
        if (!cell) {
            cell = [[BackupWordsCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:BACKUP_WORDS_CELL_IDENTIFIER];
        }
        
        [cell bindWithWords:self.backupWords];
        
        return cell;
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ didSelectRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
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
    if (controller.documentPickerMode == UIDocumentPickerModeExportToService) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication].keyWindow makeToast:TwinmeLocalizedString(@"conversation_view_controller_menu_item_view_save_message", nil)];
        });
    }
}

- (void)documentPickerWasCancelled:(UIDocumentPickerViewController *)controller {
    DDLogVerbose(@"%@ documentPickerWasCancelled: %@", LOG_TAG, controller);
}

#pragma mark - BackupActionDelegate

- (void)didTapLeftBackupAction:(BackupActionCell *)backupActionCell {
    DDLogVerbose(@"%@ didTapLeftBackupAction: %@", LOG_TAG, backupActionCell);
    
    if (backupActionCell.tag == SECTION_INFO) {
        [self saveBackup];
    } else {
        [self copyWords];
    }
}

- (void)didTapRightBackupAction:(BackupActionCell *)backupActionCell {
    DDLogVerbose(@"%@ didTapRightBackupAction: %@", LOG_TAG, backupActionCell);
    
    if (backupActionCell.tag == SECTION_INFO) {
        [self shareBackup];
    }
}

#pragma mark - BottomSheetViewDelegate

- (void)didTapConfirm:(nonnull AbstractBottomSheetView *)abstractConfirmView {
    DDLogVerbose(@"%@ didTapConfirm: %@", LOG_TAG, abstractConfirmView);
    
    [abstractConfirmView closeConfirmView];
    [self saveBackup];
}

- (void)didTapCancel:(nonnull AbstractBottomSheetView *)abstractConfirmView {
    DDLogVerbose(@"%@ didTapCancel: %@", LOG_TAG, abstractConfirmView);
    
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
    
    self.view.backgroundColor = Design.WHITE_COLOR;
    
    [self setNavigationTitle:TwinmeLocalizedStringFromTable(@"backup_view_controller_title", @"LocalizableBackup", nil)];
    
    UIBarButtonItem *infoBarButtonItem =  [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"OnboardingInfoIcon"] style:UIBarButtonItemStylePlain target:self action:@selector(infoAction:)];
    infoBarButtonItem.tintColor = [UIColor whiteColor];
    infoBarButtonItem.accessibilityLabel = TwinmeLocalizedString(@"conversation_view_controller_menu_item_view_info_title", nil);
    self.navigationItem.rightBarButtonItem = infoBarButtonItem;
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"BackupInfoCell" bundle:nil] forCellReuseIdentifier:BACKUP_INFO_CELL_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"BackupActionCell" bundle:nil] forCellReuseIdentifier:BACKUP_ACTION_CELL_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"SettingsSectionHeaderCell" bundle:nil] forCellReuseIdentifier:HEADER_SETTINGS_CELL_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"SettingsInformationCell" bundle:nil] forCellReuseIdentifier:SETTINGS_INFORMATION_CELL_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"BackupWordsCell" bundle:nil] forCellReuseIdentifier:BACKUP_WORDS_CELL_IDENTIFIER];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = Design.WHITE_COLOR;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = Design.SETTING_CELL_HEIGHT;
}

- (IBAction)infoAction:(UIButton *)sender {
    DDLogVerbose(@"%@ handleCopyWordsTapGesture: %@", LOG_TAG, sender);
    
    [self showSuccessView];
}

- (void)finish {
    DDLogVerbose(@"%@ finish", LOG_TAG);
    
    if ([[NSFileManager defaultManager]fileExistsAtPath:self.backupPath]) {
        [[NSFileManager defaultManager]removeItemAtPath:self.backupPath error:nil];
    }
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

- (void)copyWords {
    DDLogVerbose(@"%@ copyWords", LOG_TAG);
    
    [[UIPasteboard generalPasteboard] setString:[self getWordsList]];
    [[UIApplication sharedApplication].keyWindow makeToast:TwinmeLocalizedString(@"conversation_view_controller_menu_item_view_copy_message",nil)];
}

- (void)shareBackup {
    DDLogVerbose(@"%@ shareBackup", LOG_TAG);
    
    if (self.backupPath) {
        UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[[NSURL fileURLWithPath:self.backupPath]] applicationActivities:nil];
        activityViewController.excludedActivityTypes = @[UIActivityTypePrint,
                                                         UIActivityTypeAssignToContact,
                                                         UIActivityTypeSaveToCameraRoll,
                                                         UIActivityTypeAddToReadingList,
                                                         UIActivityTypePostToFlickr,
                                                         UIActivityTypePostToVimeo];
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            [self presentViewController:activityViewController animated:YES completion:nil];
        } else {
            activityViewController.modalPresentationStyle = UIModalPresentationPopover;
            activityViewController.popoverPresentationController.sourceView = self.view;
            activityViewController.popoverPresentationController.sourceRect = CGRectMake(self.view.frame.size.width/2, self.view.frame.size.height/4, 0, 0);
            activityViewController.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionAny;
            [self presentViewController:activityViewController animated:YES completion:nil];
        }
    }
}

- (void)saveBackup {
    DDLogVerbose(@"%@ saveBackup", LOG_TAG);
    
    NSURL *urlToSave = [NSURL fileURLWithPath:self.backupPath];
    if (urlToSave) {
        UIDocumentPickerViewController *documentPickerViewController;
        
        if (@available(iOS 14.0, *)) {
            documentPickerViewController = [[UIDocumentPickerViewController alloc]initForExportingURLs:@[urlToSave] asCopy:YES];
        } else {
            documentPickerViewController = [[UIDocumentPickerViewController alloc]initWithURL:urlToSave inMode:UIDocumentPickerModeExportToService];
        }
        
        documentPickerViewController.delegate = self;
        documentPickerViewController.modalPresentationStyle = UIModalPresentationFormSheet;
        [self presentViewController:documentPickerViewController animated:YES completion:nil];
    }
}

- (BOOL)isInformationPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ isInformationPath: %@", LOG_TAG, indexPath);
    
    if (indexPath.section == SECTION_WORDS && indexPath.row == 0) {
        return YES;
    }
    
    return NO;
}

- (BOOL)isActionPath:(NSIndexPath *)indexPath {
    
    if ((indexPath.section == SECTION_INFO && indexPath.row == 1) || (indexPath.section == SECTION_WORDS && indexPath.row == 2)) {
        return YES;
    }
    
    return NO;
}

- (void)showSuccessView {
    DDLogVerbose(@"%@ showSuccessView", LOG_TAG);
    
    OnboardingConfirmView *onboardingConfirmView = [[OnboardingConfirmView alloc] init];
    onboardingConfirmView.bottomSheetViewDelegate = self;

    UIImage *image = [UIImage imageNamed:@"OnboardingBackup"];
    NSString *title = TwinmeLocalizedStringFromTable(@"backup_view_controller_success", @"LocalizableBackup", nil);
    NSString *message = [NSString stringWithFormat:@"%@\n\n%@", TwinmeLocalizedStringFromTable(@"backup_view_controller_save_file_message", @"LocalizableBackup", nil), TwinmeLocalizedStringFromTable(@"backup_view_controller_verify_message", @"LocalizableBackup", nil)];
    NSString *action = TwinmeLocalizedString(@"application_save", nil);
    
    [onboardingConfirmView initWithTitle:title message:message image:image action:action actionColor:nil cancel:nil];
    
    [self.navigationController.view addSubview:onboardingConfirmView];
    [onboardingConfirmView showConfirmView];
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
}

@end
