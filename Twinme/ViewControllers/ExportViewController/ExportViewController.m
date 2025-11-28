/*
 *  Copyright (c) 2023 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <Twinlife/TLConversationService.h>
#import <Twinme/TLContact.h>
#import <Twinme/TLGroup.h>
#import <Twinme/TLSpace.h>

#import "ExportViewController.h"
#import "InAppSubscriptionViewController.h"
#import <TwinmeCommon/TwinmeNavigationController.h>

#import "SettingsInformationCell.h"
#import "SettingsSectionHeaderCell.h"
#import "ExportActionCell.h"
#import "ExportContentCell.h"
#import "ExportProgressCell.h"

#import <Utils/NSString+Utils.h>

#import <TwinmeCommon/Design.h>
#import <TwinmeCommon/ExportService.h>

#import "UIExport.h"
#import "PremiumFeatureConfirmView.h"
#import "UIPremiumFeature.h"

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static const int CONTENT_VIEW_SECTION = 0;
static const int EXPORT_VIEW_SECTION = 1;

static const int CONTENT_INFO_ROW = 0;
static const int CONTENT_FOOTER_ROW = 6;

static const CGFloat DESIGN_EXPORT_SECTION_HEIGHT = 40;

static NSString *SETTINGS_INFORMATION_CELL_IDENTIFIER = @"SettingsInformationCellIdentifier";
static NSString *HEADER_SETTINGS_CELL_IDENTIFIER = @"HeaderSettingsCellIdentifier";
static NSString *EXPORT_CONTENT_CELL_IDENTIFIER = @"ExportContentCellIdentifier";
static NSString *EXPORT_PROGRESS_CELL_IDENTIFIER = @"ExportProgressCellIdentifier";
static NSString *EXPORT_ACTION_CELL_IDENTIFIER = @"ExportActionCellIdentifier";

static NSString *EXPORT_ALL_SHORT_NAME = @"all";
static NSString *EXPORT_FILE_SHORT_NAME = @"file";
static NSString *EXPORT_MEDIA_SHORT_NAME = @"media";
static NSString *EXPORT_MESSAGE_SHORT_NAME = @"msg";
static NSString *EXPORT_VOICE_SHORT_NAME = @"voice";

//
// Interface: ExportViewController ()
//

@interface ExportViewController ()<UITableViewDelegate, UITableViewDataSource, ExportActionDelegate, ExportServiceDelegate, ConfirmViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic) ExportService *exportService;

@property (nonatomic) NSMutableArray *exports;
@property (nonatomic) NSString *prefixFileName;

@property BOOL exportAllConversations;
@property BOOL isExportInProgress;
@property BOOL isContentToExport;

@end

//
// Implementation: ExportViewController
//

#undef LOG_TAG
#define LOG_TAG @"ExportViewController"

@implementation ExportViewController

- (instancetype)initWithCoder:(NSCoder *)coder {
    DDLogVerbose(@"%@ initWithCoder: %@", LOG_TAG, coder);
    
    self = [super initWithCoder:coder];
    
    if (self) {
        _isExportInProgress = NO;
        _exportAllConversations = NO;
        _isContentToExport = NO;
        _exports = [[NSMutableArray alloc]init];
        _prefixFileName = @"";
    }
    return self;
}

- (void)viewDidLoad {
    DDLogVerbose(@"%@ viewDidLoad", LOG_TAG);
    
    [super viewDidLoad];
    
    [self initViews];
    [self initExport];
}

- (void)initExportWithContact:(TLContact *)contact {
    DDLogVerbose(@"%@ initExportWithContact: %@", LOG_TAG, contact);
    
    self.exportAllConversations = NO;
    self.prefixFileName = [TLExportExecutor exportWithName:contact.name];
    self.exportService = [[ExportService alloc] initWithTwinmeContext:self.twinmeContext delegate:self space:nil contact:contact group:nil];
}

- (void)initExportWithGroup:(TLGroup *)group {
    DDLogVerbose(@"%@ initExportWithGroup: %@", LOG_TAG, group);
    
    self.exportAllConversations = NO;
    self.prefixFileName = [TLExportExecutor exportWithName:group.name];
    self.exportService = [[ExportService alloc] initWithTwinmeContext:self.twinmeContext delegate:self space:nil contact:nil group:group];
}

- (void)initExportWithSpace:(TLSpace *)space {
    DDLogVerbose(@"%@ initExportWithSpace: %@", LOG_TAG, space);
    
    self.exportAllConversations = YES;
    self.prefixFileName = [TLExportExecutor exportWithName:space.settings.name];
    self.exportService = [[ExportService alloc] initWithTwinmeContext:self.twinmeContext delegate:self space:space contact:nil group:nil];
}

- (void)initExportWithCurrentSpace {
    DDLogVerbose(@"%@ initExportWithCurrentSpace", LOG_TAG);
    
    self.exportAllConversations = YES;
    self.prefixFileName = TwinmeLocalizedString(@"application_name", nil);
    self.exportService = [[ExportService alloc] initWithTwinmeContext:self.twinmeContext delegate:self space:nil contact:nil group:nil];
}

#pragma mark - ExportServiceDelegate

- (void)onErrorWithMessage:(nonnull NSString *)message {
    DDLogVerbose(@"%@ onErrorWithMessage: %@", LOG_TAG, message);
    
}

- (void)onProgressWithState:(TLExportState)state stats:(nonnull TLExportStats *)stats {
    DDLogVerbose(@"%@ onProgressWithState: %u stats: %@", LOG_TAG, state, stats);
    
    if (state == TLExportStateScanning || state == TLExportStateExporting) {
        self.isExportInProgress = YES;
    } else {
        self.isExportInProgress = NO;
    }
    
    [self updateContent:stats];
}

- (void)onReadyToExport:(NSString *)path {
    DDLogVerbose(@"%@ onReadyToExport: %@", LOG_TAG, path);
    
    self.isExportInProgress = NO;
    [self.tableView reloadData];
    
    if (path) {
        UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[[NSURL fileURLWithPath:path]] applicationActivities:nil];
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

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    DDLogVerbose(@"%@ numberOfSectionsInTableView: %@", LOG_TAG, tableView);
    
    if (self.isContentToExport) {
        return 2;
    }
    
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath  {
    DDLogVerbose(@"%@ tableView: %@ heightForRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    if ([self isInformationPath:indexPath]) {
        return UITableViewAutomaticDimension;
    }
    
    return Design.SETTING_CELL_HEIGHT;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ heightForHeaderInSection: %ld", LOG_TAG, tableView, (long)section);
    
    if (section == EXPORT_VIEW_SECTION) {
        return DESIGN_EXPORT_SECTION_HEIGHT * Design.HEIGHT_RATIO;
    }
    
    return Design.SETTING_CELL_HEIGHT;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ heightForFooterInSection: %ld", LOG_TAG, tableView, (long)section);
    
    return CGFLOAT_MIN;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ numberOfRowsInSection: %ld", LOG_TAG, tableView, (long)section);
    
    if (section == CONTENT_VIEW_SECTION) {
        return CONTENT_FOOTER_ROW + 1;
    }
    
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ viewForHeaderInSection: %ld", LOG_TAG, tableView, (long)section);
    
    if (section == EXPORT_VIEW_SECTION) {
        return [[UIView alloc]init];
    }
    
    SettingsSectionHeaderCell *settingsSectionHeaderCell = (SettingsSectionHeaderCell *)[tableView dequeueReusableCellWithIdentifier:HEADER_SETTINGS_CELL_IDENTIFIER];
    if (!settingsSectionHeaderCell) {
        settingsSectionHeaderCell = [[SettingsSectionHeaderCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:HEADER_SETTINGS_CELL_IDENTIFIER];
    }
    
    [settingsSectionHeaderCell bindWithTitle:TwinmeLocalizedString(@"export_view_controller_content_title", nil) backgroundColor:Design.LIGHT_GREY_BACKGROUND_COLOR hideSeparator:YES uppercaseString:YES];
    
    return settingsSectionHeaderCell;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ viewForFooterInSection: %ld", LOG_TAG, tableView, (long)section);
    
    return [[UIView alloc]init];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ cellForRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    if ([self isInformationPath:indexPath]) {
        SettingsInformationCell *cell = [tableView dequeueReusableCellWithIdentifier:SETTINGS_INFORMATION_CELL_IDENTIFIER];
        if (!cell) {
            cell = [[SettingsInformationCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:SETTINGS_INFORMATION_CELL_IDENTIFIER];
        }
        
        NSString *text = @"";
        if (indexPath.section == CONTENT_VIEW_SECTION && indexPath.row == CONTENT_INFO_ROW) {
            text = TwinmeLocalizedString(@"export_view_controller_select_content", nil);
        } else {
            text = [self getExportInformation];
        }
        
        [cell bindWithText:text];
        
        return cell;
    } else if (indexPath.section == CONTENT_VIEW_SECTION) {
        ExportContentCell *cell = [tableView dequeueReusableCellWithIdentifier:EXPORT_CONTENT_CELL_IDENTIFIER];
        if (!cell) {
            cell = [[ExportContentCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:EXPORT_CONTENT_CELL_IDENTIFIER];
        }
        
        [cell bindWithExport:[self.exports objectAtIndex:indexPath.row - 1]];
        
        return cell;
    } else if (self.isExportInProgress) {
        ExportProgressCell *cell = [tableView dequeueReusableCellWithIdentifier:EXPORT_PROGRESS_CELL_IDENTIFIER];
        if (!cell) {
            cell = [[ExportProgressCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:EXPORT_PROGRESS_CELL_IDENTIFIER];
        }
        
        [cell bindWithProgress:0 message:TwinmeLocalizedString(@"export_view_controller_do_not_leave_screen", nil)];
        
        return cell;
    } else {
        ExportActionCell *cell = [tableView dequeueReusableCellWithIdentifier:EXPORT_ACTION_CELL_IDENTIFIER];
        if (!cell) {
            cell = [[ExportActionCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:EXPORT_ACTION_CELL_IDENTIFIER];
        }
        
        cell.exportActionDelegate = self;
        
        if (self.isExportInProgress) {
            [cell bindWithAction:ExportActionTypeCancel enable:YES];
        } else {
            [cell bindWithAction:ExportActionTypeExport enable:[self canExport]];
        }
        
        return cell;
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ didSelectRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    if (indexPath.section == CONTENT_VIEW_SECTION && ![self isInformationPath:indexPath]) {
        UIExport *export = [self.exports objectAtIndex:indexPath.row - 1];
        if (export.count > 0) {
            export.checked = !export.checked;
            
            ExportContentCell *exportContentCell = (ExportContentCell *)[self.tableView cellForRowAtIndexPath:indexPath];
            [exportContentCell bindWithExport:export];
            
            SettingsInformationCell *settingsInformationCell = (SettingsInformationCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:CONTENT_FOOTER_ROW inSection:CONTENT_VIEW_SECTION]];
            [settingsInformationCell bindWithText:[self getExportInformation]];
            
            if (!self.isExportInProgress) {
                ExportActionCell *exportActionCell = (ExportActionCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:EXPORT_VIEW_SECTION]];
                [exportActionCell bindWithAction:ExportActionTypeExport enable:[self canExport]];
            }
        }
    }
}

#pragma mark - ExportActionDelegate

- (void)didTapAction:(ExportActionType)exportActionType {
    DDLogVerbose(@"%@ didTapAction: %u", LOG_TAG, exportActionType);
    
    if (exportActionType == ExportActionTypeCancel) {
        [self finish];
    } else if ([self canExport]) {
        ApplicationDelegate *delegate = (ApplicationDelegate *)[[UIApplication sharedApplication] delegate];
        if ([delegate.twinmeApplication isSubscribedWithFeature:TLTwinmeApplicationFeatureGroupCall]) {
            [self.exportService runExport:[self getExportTypeFilter] fileName:[self getExportFileName]];
        } else {
            PremiumFeatureConfirmView *premiumFeatureConfirmView = [[PremiumFeatureConfirmView alloc] init];
            premiumFeatureConfirmView.confirmViewDelegate = self;
            [premiumFeatureConfirmView initWithPremiumFeature:[[UIPremiumFeature alloc]initWithFeatureType:FeatureTypeConversation spaceSettings:[self currentSpaceSettings]] parentViewController:self.navigationController];
            [self.navigationController.view addSubview:premiumFeatureConfirmView];
            [premiumFeatureConfirmView showConfirmView];
        }
    }
}

#pragma mark - ConfirmViewDelegate

- (void)didTapConfirm:(nonnull AbstractConfirmView *)abstractConfirmView {
    DDLogVerbose(@"%@ didTapConfirm: %@", LOG_TAG, abstractConfirmView);
    
    InAppSubscriptionViewController *inAppSubscriptionViewController = [[UIStoryboard storyboardWithName:@"iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"InAppSubscriptionViewController"];
    TwinmeNavigationController *navigationController = [[TwinmeNavigationController alloc]initWithRootViewController:inAppSubscriptionViewController];
    [self.navigationController presentViewController:navigationController animated:YES completion:nil];
    
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
    
    [self setNavigationTitle:TwinmeLocalizedString(@"export_view_controller_title", nil)];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerNib:[UINib nibWithNibName:@"ExportActionCell" bundle:nil] forCellReuseIdentifier:EXPORT_ACTION_CELL_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"ExportContentCell" bundle:nil] forCellReuseIdentifier:EXPORT_CONTENT_CELL_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"ExportProgressCell" bundle:nil] forCellReuseIdentifier:EXPORT_PROGRESS_CELL_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"SettingsSectionHeaderCell" bundle:nil] forCellReuseIdentifier:HEADER_SETTINGS_CELL_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"SettingsInformationCell" bundle:nil] forCellReuseIdentifier:SETTINGS_INFORMATION_CELL_IDENTIFIER];
    
    self.tableView.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = Design.SETTING_CELL_HEIGHT;
}

- (void)initExport {
    DDLogVerbose(@"%@ initExport", LOG_TAG);
    
    [self.exports addObject:[[UIExport alloc]initWithExportContentType:ExportContentTypeMessage image:[UIImage imageNamed:@"TabBarChatGrey"] checked:YES]];
    [self.exports addObject:[[UIExport alloc]initWithExportContentType:ExportContentTypeImage image:[UIImage imageNamed:@"ToolbarPictureGrey"] checked:YES]];
    [self.exports addObject:[[UIExport alloc]initWithExportContentType:ExportContentTypeVideo image:[UIImage imageNamed:@"HistoryVideoCall"] checked:YES]];
    [self.exports addObject:[[UIExport alloc]initWithExportContentType:ExportContentTypeAudio image:[UIImage imageNamed:@"ToolbarMicrophoneGrey"] checked:YES]];
    [self.exports addObject:[[UIExport alloc]initWithExportContentType:ExportContentTypeFile image:[UIImage imageNamed:@"ToolbarFileGrey"] checked:YES]];
}

- (void)updateContent:(nonnull TLExportStats *)stats {
    DDLogVerbose(@"%@ updateContent: %@", LOG_TAG, stats);
    
    for (UIExport *uiExport in self.exports) {
        
        switch (uiExport.exportContentType) {
            case ExportContentTypeMessage:
                uiExport.count = stats.msgCount;
                uiExport.size = 0;
                break;
                
            case ExportContentTypeImage:
                uiExport.count = stats.imageCount;
                uiExport.size = stats.imageSize;
                break;
                
            case ExportContentTypeVideo:
                uiExport.count = stats.videoCount;
                uiExport.size = stats.videoSize;
                break;
                
            case ExportContentTypeFile:
                uiExport.count = stats.fileCount;
                uiExport.size = stats.fileSize;
                break;
                
            case ExportContentTypeAudio:
                uiExport.count = stats.audioCount;
                uiExport.size = stats.audioSize;
                break;
                
            default:
                break;
        }
        
        if (uiExport.count > 0) {
            self.isContentToExport = YES;
        }
    }
    
    [self.tableView reloadData];
}

- (BOOL)canExport {
    DDLogVerbose(@"%@ canExport", LOG_TAG);
    
    for (UIExport *uiExport in self.exports) {
        if (uiExport.checked && uiExport.count > 0) {
            return YES;
        }
    }
    
    return NO;
}

- (NSString *)getExportInformation {
    DDLogVerbose(@"%@ getExportInformation", LOG_TAG);
    
    if (!self.isContentToExport) {
        return TwinmeLocalizedString(@"export_view_controller_no_content_to_export", nil);
    }
    
    BOOL isOneContentToExportIsChecked = NO;
    
    int64_t totalSize = 0;
    int64_t totalCountFile = 0;
    int64_t totalCountMessage = 0;
    for (UIExport *uiExport in self.exports) {
        if (uiExport.checked && uiExport.count > 0) {
            isOneContentToExportIsChecked = YES;
            if (uiExport.exportContentType == ExportContentTypeMessage) {
                totalCountMessage = uiExport.count;
            } else {
                totalSize += uiExport.size;
                totalCountFile += uiExport.count;
            }
        }
    }
    
    NSMutableString *exportInfo = [[NSMutableString alloc] init];

    if (self.exportAllConversations) {
        [exportInfo appendString:TwinmeLocalizedString(@"export_view_controller_all_conversations_zip_file", nil)];
    } else {
        [exportInfo appendString:TwinmeLocalizedString(@"export_view_controller_one_conversation_zip_file", nil)];
    }
    
    if (isOneContentToExportIsChecked) {
        [exportInfo appendString:@"\n"];
        [exportInfo appendString:TwinmeLocalizedString(@"export_view_controller_content_to_export", nil)];
        [exportInfo appendString:@" : "];
        if (totalCountMessage > 0) {
            [exportInfo appendString:[NSString stringWithFormat:@"%lld %@%@", totalCountMessage, totalCountMessage > 1 ? TwinmeLocalizedString(@"settings_view_controller_chat_category_title", nil).lowercaseString : TwinmeLocalizedString(@"feedback_view_controller_message", nil).lowercaseString, totalCountFile > 0 ? @" - " : @""]];
        }
        
        if (totalCountFile > 0) {
            NSByteCountFormatter *byteCountFormatter = [[NSByteCountFormatter alloc] init];
            byteCountFormatter.countStyle = NSByteCountFormatterCountStyleFile;
            [exportInfo appendString:[NSString stringWithFormat:@"%lld %@ - %@", totalCountFile, totalCountFile > 1 ? TwinmeLocalizedString(@"export_view_controller_files", nil).lowercaseString : TwinmeLocalizedString(@"export_view_controller_file", nil).lowercaseString, [byteCountFormatter stringFromByteCount:totalSize]]];
        }
    }
    
    return exportInfo;
}

- (NSString *)getExportFileName {
    DDLogVerbose(@"%@ getExportFileName", LOG_TAG);
    
    NSMutableString *exportFileName = [[NSMutableString alloc] initWithString:self.prefixFileName];
    [exportFileName appendString:@"-"];
    
    if ([self isAllContentChecked]) {
        [exportFileName appendString:EXPORT_ALL_SHORT_NAME];
        [exportFileName appendString:@"-"];
    } else {
        for (UIExport *export in self.exports) {
            if (export.checked && export.count > 0) {
                NSString *shortTypeName = [self getContentTypeShortName:export.exportContentType];
                if (![shortTypeName isEqualToString:@""] && ![exportFileName containsString:shortTypeName]) {
                    [exportFileName appendString:shortTypeName];
                    [exportFileName appendString:@"-"];
                }
            }
        }
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd"];
    [exportFileName appendString:[dateFormatter stringFromDate:[NSDate date]]];
    [exportFileName appendString:@".zip"];
    
    return exportFileName;
}

- (NSString *)getContentTypeShortName:(ExportContentType)exportContentType {
    DDLogVerbose(@"%@ getContentTypeShortName", LOG_TAG);
    
    switch (exportContentType) {
        case ExportContentTypeMessage:
            return EXPORT_MESSAGE_SHORT_NAME;
            
        case ExportContentTypeImage:
        case ExportContentTypeVideo:
            return EXPORT_MEDIA_SHORT_NAME;
            
        case ExportContentTypeFile:
            return EXPORT_FILE_SHORT_NAME;
            
        case ExportContentTypeAudio:
            return EXPORT_VOICE_SHORT_NAME;
            
        default:
            return @"";
    }
}

- (BOOL)isAllContentChecked {
    DDLogVerbose(@"%@ isAllContentChecked", LOG_TAG);
    
    for (UIExport *export in self.exports) {
        if (!export.checked) {
            return NO;
        }
    }
    
    return YES;
}

- (NSArray *)getExportTypeFilter {
    DDLogVerbose(@"%@ getExportTypeFilter", LOG_TAG);
    
    NSMutableArray *typeFilter = [[NSMutableArray alloc]init];
    
    for (UIExport *export in self.exports) {
        if (export.checked && export.count > 0) {
            NSNumber *descriptorType = [self getDescriptorType:export.exportContentType];
            if (descriptorType) {
                [typeFilter addObject:[self getDescriptorType:export.exportContentType]];
            }
        }
    }
    
    return typeFilter;
}

- (NSNumber *)getDescriptorType:(ExportContentType)exportContentType {
    DDLogVerbose(@"%@ getDescriptorType", LOG_TAG);
    
    switch (exportContentType) {
        case ExportContentTypeMessage:
            return [NSNumber numberWithInt:TLDescriptorTypeObjectDescriptor];
            
        case ExportContentTypeImage:
            return [NSNumber numberWithInt:TLDescriptorTypeImageDescriptor];
            
        case ExportContentTypeVideo:
            return [NSNumber numberWithInt:TLDescriptorTypeVideoDescriptor];
            
        case ExportContentTypeFile:
            return [NSNumber numberWithInt:TLDescriptorTypeNamedFileDescriptor];
            
        case ExportContentTypeAudio:
            return [NSNumber numberWithInt:TLDescriptorTypeAudioDescriptor];
            
        default:
            return NULL;
    }
}

- (void)finish {
    DDLogVerbose(@"%@ finish", LOG_TAG);
    
    if (self.exportService) {
        [self.exportService dispose];
        self.exportService = nil;
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)isInformationPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == CONTENT_VIEW_SECTION && (indexPath.row == CONTENT_INFO_ROW || indexPath.row == CONTENT_FOOTER_ROW)) {
        return YES;
    }
    
    return NO;
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    [self.tableView reloadData];
}

@end
