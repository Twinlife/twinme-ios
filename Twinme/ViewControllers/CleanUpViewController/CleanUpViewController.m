/*
 *  Copyright (c) 2023 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <Twinlife/TLTwinlife.h>
#import <Twinlife/TLConversationService.h>
#import <Twinme/TLContact.h>
#import <Twinme/TLGroup.h>
#import <Twinme/TLSpace.h>

#import "CleanUpViewController.h"
#import "InAppSubscriptionViewController.h"
#import <TwinmeCommon/TwinmeNavigationController.h>
#import "MessageSettingsViewController.h"

#import "SettingsInformationCell.h"
#import "SettingsSectionHeaderCell.h"
#import "ExportActionCell.h"
#import "ExportContentCell.h"
#import "SettingsItemCell.h"
#import "StorageCell.h"
#import "StorageChartCell.h"
#import "SettingsValueItemCell.h"
#import "MenuCleanUpExpirationView.h"
#import "PremiumFeatureConfirmView.h"
#import "DeleteConfirmView.h"
#import "DeleteSpaceConfirmView.h"
#import "SwitchView.h"

#import <TwinmeCommon/CleanUpService.h>

#import <Utils/NSString+Utils.h>

#import <TwinmeCommon/Design.h>
#import "UIView+Toast.h"

#import "UIStorage.h"
#import "UIExport.h"
#import "UICleanUpExpiration.h"
#import "UIPremiumFeature.h"

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static const int DESIGN_STORAGE_CELL_HEIGHT = 50;
static const int DESIGN_STORAGE_CHART_CELL_HEIGHT = 190;

static const int STORAGE_VIEW_SECTION = 0;
static const int CONTENT_VIEW_SECTION = 1;
static const int EXPIRATION_VIEW_SECTION = 2;
static const int CLEAN_VIEW_SECTION = 3;

static NSString *SETTINGS_INFORMATION_CELL_IDENTIFIER = @"SettingsInformationCellIdentifier";
static NSString *HEADER_SETTINGS_CELL_IDENTIFIER = @"HeaderSettingsCellIdentifier";
static NSString *EXPORT_CONTENT_CELL_IDENTIFIER = @"ExportContentCellIdentifier";
static NSString *EXPORT_ACTION_CELL_IDENTIFIER = @"ExportActionCellIdentifier";
static NSString *STORAGE_CELL_IDENTIFIER = @"StorageCellIdentifier";
static NSString *STORAGE_CHART_CELL_IDENTIFIER = @"StorageChartCellIdentifier";
static NSString *SETTINGS_VALUE_CELL_IDENTIFIER = @"SettingsValueCellIdentifier";
static NSString *SETTINGS_ITEM_CELL_IDENTIFIER = @"SettingsCellIdentifier";

//
// Interface: CleanUpViewController ()
//

@interface CleanUpViewController ()<UITableViewDelegate, UITableViewDataSource, ExportActionDelegate, MenuCleanUpExpirationDelegate, CleanUpServiceDelegate, ConfirmViewDelegate, SettingsActionDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic) MenuCleanUpExpirationView *menuCleanUpExpirationView;

@property (nonatomic) NSMutableArray *storages;
@property (nonatomic) NSMutableArray *contents;

@property (nonatomic) NSString *conversationName;

@property (nonatomic) CleanUpService *cleanUpService;

@property (nonatomic) UICleanUpExpiration *cleanUpExpiration;
@property (nonatomic) ExpirationType lastExpirationType;
@property (nonatomic) ExpirationPeriod lastExpirationPeriod;
@property (nonatomic) NSDate *lastExpirationDate;

@property BOOL initContentToClean;
@property BOOL isContentToClean;

@property (nonatomic) TLContact *contact;
@property (nonatomic) TLGroup *group;
@property (nonatomic) TLSpace *space;

@end

//
// Implementation: CleanUpViewController
//

#undef LOG_TAG
#define LOG_TAG @"CleanUpViewController"

@implementation CleanUpViewController

- (instancetype)initWithCoder:(NSCoder *)coder {
    DDLogVerbose(@"%@ initWithCoder: %@", LOG_TAG, coder);
    
    self = [super initWithCoder:coder];
    
    if (self) {
        _isContentToClean = NO;
        _initContentToClean = NO;
        _storages = [[NSMutableArray alloc]init];
        _contents = [[NSMutableArray alloc]init];
        _cleanUpExpiration = [[UICleanUpExpiration alloc]initWithExpirationType:ExpirationTypeValue expirationPeriod:ExpirationPeriodThreeMonths];
        _lastExpirationType = ExpirationTypeValue;
        _lastExpirationPeriod = ExpirationPeriodThreeMonths;
        _lastExpirationDate = [NSDate date];
    }
    
    return self;
}

- (void)viewDidLoad {
    DDLogVerbose(@"%@ viewDidLoad", LOG_TAG);
    
    [super viewDidLoad];
    
    [self initViews];
    [self initContent];
    [self initStorage];
}

- (void)initCleanUpWithContact:(TLContact *)contact {
    DDLogVerbose(@"%@ initCleanUpWithContact: %@", LOG_TAG, contact);
    
    self.contact = contact;
    self.cleanUpService = [[CleanUpService alloc] initWithTwinmeContext:self.twinmeContext delegate:self space:nil contact:contact group:nil];
    self.conversationName = contact.name;
}

- (void)initCleanUpWithGroup:(TLGroup *)group {
    DDLogVerbose(@"%@ initCleanUpWithGroup: %@", LOG_TAG, group);
    
    self.group = group;
    self.cleanUpService = [[CleanUpService alloc] initWithTwinmeContext:self.twinmeContext delegate:self space:nil contact:nil group:group];
    self.conversationName = group.name;
}

- (void)initCleanUpWithSpace:(TLSpace *)space {
    DDLogVerbose(@"%@ initCleanUpWithSpace: %@", LOG_TAG, space);
    
    self.space = space;
    self.cleanUpService = [[CleanUpService alloc] initWithTwinmeContext:self.twinmeContext delegate:self space:space contact:nil group:nil];
}

- (void)initCleanUpApplication {
    DDLogVerbose(@"%@ initCleanUpApplication", LOG_TAG);
    
    self.cleanUpService = [[CleanUpService alloc] initWithTwinmeContext:self.twinmeContext delegate:self space:nil contact:nil group:nil];
}

#pragma mark - SettingsActionDelegate

- (void)switchChangeValue:(SwitchView *)updatedSwitch {
    DDLogVerbose(@"%@ switchChangeValue: %@", LOG_TAG, updatedSwitch);
    
    if (updatedSwitch.isOn) {
        self.lastExpirationType = self.cleanUpExpiration.expirationType;
        self.lastExpirationPeriod = self.cleanUpExpiration.expirationPeriod;
        self.lastExpirationDate = self.cleanUpExpiration.expirationDate;
        
        [self.cleanUpExpiration setExpirationType:ExpirationTypeAll];
    } else {
        [self.cleanUpExpiration setExpirationType:self.lastExpirationType];
        [self.cleanUpExpiration setExpirationPeriod:self.lastExpirationPeriod];
        [self.cleanUpExpiration setExpirationDate:self.lastExpirationDate];
    }
    
    [self.cleanUpService setDateFilter:[self.cleanUpExpiration clearDate]];
    [self.tableView reloadData];
}

#pragma mark - CleanUpServiceDelegate

- (void)onErrorWithMessage:(nonnull NSString *)message {
    DDLogVerbose(@"%@ onErrorWithMessage: %@", LOG_TAG, message);
    
}

- (void)onProgressWithState:(TLExportState)state stats:(nonnull TLExportStats *)stats {
    DDLogVerbose(@"%@ onProgressWithState: %u stats: %@", LOG_TAG, state, stats);
    
    [self updateContent:stats];
}

- (void)onClearConversation {
    DDLogVerbose(@"%@ onClearConversation", LOG_TAG);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication].keyWindow makeToast:TwinmeLocalizedString(@"cleanup_view_controller_success",nil)];
    });
    
    [self finish];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    DDLogVerbose(@"%@ numberOfSectionsInTableView: %@", LOG_TAG, tableView);
    
    return CLEAN_VIEW_SECTION + 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath  {
    DDLogVerbose(@"%@ tableView: %@ heightForRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    if ([self isInformationPath:indexPath]) {
        return UITableViewAutomaticDimension;
    }
    
    if (indexPath.section == STORAGE_VIEW_SECTION) {
        if (indexPath.row == 0) {
            return DESIGN_STORAGE_CHART_CELL_HEIGHT * Design.HEIGHT_RATIO;
        } else {
            return DESIGN_STORAGE_CELL_HEIGHT * Design.HEIGHT_RATIO;
        }
    }
    
    return Design.SETTING_CELL_HEIGHT;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ heightForHeaderInSection: %ld", LOG_TAG, tableView, (long)section);
    
    if (section == CLEAN_VIEW_SECTION) {
        return CGFLOAT_MIN;
    }
    
    return Design.SETTING_CELL_HEIGHT;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ heightForFooterInSection: %ld", LOG_TAG, tableView, (long)section);
    
    return CGFLOAT_MIN;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ numberOfRowsInSection: %ld", LOG_TAG, tableView, (long)section);
    
    if (section == STORAGE_VIEW_SECTION) {
        return 5;
    } else if (section == CONTENT_VIEW_SECTION) {
        return 5;
    } else if (section == EXPIRATION_VIEW_SECTION) {
        return self.cleanUpExpiration.expirationType == ExpirationTypeAll ? 1 : 2;
    }
    
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ viewForHeaderInSection: %ld", LOG_TAG, tableView, (long)section);
    
    if (section == CLEAN_VIEW_SECTION) {
        return [[UIView alloc]init];
    }
    
    SettingsSectionHeaderCell *settingsSectionHeaderCell = (SettingsSectionHeaderCell *)[tableView dequeueReusableCellWithIdentifier:HEADER_SETTINGS_CELL_IDENTIFIER];
    if (!settingsSectionHeaderCell) {
        settingsSectionHeaderCell = [[SettingsSectionHeaderCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:HEADER_SETTINGS_CELL_IDENTIFIER];
    }
    
    NSString *title = @"";
    
    if (section == STORAGE_VIEW_SECTION) {
        title = TwinmeLocalizedString(@"cleanup_view_controller_storage_title", nil);
    } else if (section == CONTENT_VIEW_SECTION) {
        title = TwinmeLocalizedString(@"export_view_controller_content_title", nil);
    } else if (section == EXPIRATION_VIEW_SECTION) {
        title = TwinmeLocalizedString(@"cleanup_view_controller_expiration", nil);
    }
    
    [settingsSectionHeaderCell bindWithTitle:title backgroundColor:Design.LIGHT_GREY_BACKGROUND_COLOR hideSeparator:YES uppercaseString:YES];
    
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
        if (indexPath.row == 0) {
            text = TwinmeLocalizedString(@"cleanup_view_controller_select_content", nil);
        } else if (indexPath.row == 2) {
            if (self.cleanUpType == CleanUpTypeLocal) {
                text = TwinmeLocalizedString(@"cleanup_view_controller_medias_and_files_info", nil);
            } else {
                text = TwinmeLocalizedString(@"cleanup_view_controller_medias_and_files_info_both", nil);
            }
        } else if (indexPath.row == 4) {
            text = TwinmeLocalizedString(@"cleanup_view_controller_messages_info", nil);
        }
        
        [cell bindWithText:text];
        
        return cell;
    } else if (indexPath.section == STORAGE_VIEW_SECTION) {
        if (indexPath.row == 0) {
            StorageChartCell *cell = [tableView dequeueReusableCellWithIdentifier:STORAGE_CHART_CELL_IDENTIFIER];
            if (!cell) {
                cell = [[StorageChartCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:STORAGE_CHART_CELL_IDENTIFIER];
            }
                        
            [cell bindWithStorage:self.storages];
            
            return cell;
        } else {
            StorageCell *cell = [tableView dequeueReusableCellWithIdentifier:STORAGE_CELL_IDENTIFIER];
            if (!cell) {
                cell = [[StorageCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:STORAGE_CELL_IDENTIFIER];
            }
            
            UIStorage *storage = [self.storages objectAtIndex:indexPath.row - 1];
            
            [cell bindWithStorage:storage];
                        
            return cell;
        }
    } else if (indexPath.section == CONTENT_VIEW_SECTION) {
        ExportContentCell *cell = [tableView dequeueReusableCellWithIdentifier:EXPORT_CONTENT_CELL_IDENTIFIER];
        if (!cell) {
            cell = [[ExportContentCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:EXPORT_CONTENT_CELL_IDENTIFIER];
        }
        
        if (indexPath.row == 1) {
            [cell bindWithExport:[self.contents firstObject]];
        } else {
            [cell bindWithExport:[self.contents lastObject]];
        }
    
        return cell;
    } else if (indexPath.section == EXPIRATION_VIEW_SECTION) {
        if (indexPath.row == 0) {
            SettingsItemCell *cell = [tableView dequeueReusableCellWithIdentifier:SETTINGS_ITEM_CELL_IDENTIFIER];
            if (!cell) {
                cell = [[SettingsItemCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:SETTINGS_ITEM_CELL_IDENTIFIER];
            }
            
            cell.settingsActionDelegate = self;
            
            [cell bindWithTitle:TwinmeLocalizedString(@"cleanup_view_controller_all", nil) icon:nil stateSwitch:self.cleanUpExpiration.expirationType == ExpirationTypeAll tagSwitch:0 hiddenSwitch:NO disableSwitch:NO backgroundColor:Design.WHITE_COLOR hiddenSeparator:NO];
            
            return cell;
        } else {
            SettingsValueItemCell *cell = [tableView dequeueReusableCellWithIdentifier:SETTINGS_VALUE_CELL_IDENTIFIER];
            if (!cell) {
                cell = [[SettingsValueItemCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:SETTINGS_VALUE_CELL_IDENTIFIER];
            }
            
            [cell bindWithTitle:[self.cleanUpExpiration getTitle] value:[self.cleanUpExpiration getValue] hiddenAccessory:YES];
            
            return cell;
        }
    } else {
        ExportActionCell *cell = [tableView dequeueReusableCellWithIdentifier:EXPORT_ACTION_CELL_IDENTIFIER];
        if (!cell) {
            cell = [[ExportActionCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:EXPORT_ACTION_CELL_IDENTIFIER];
        }
        
        cell.exportActionDelegate = self;
        
        [cell bindWithAction:ExportActionTypeCleanup enable:[self canCleanup]];
        
        return cell;
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ didSelectRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    if (indexPath.section == CONTENT_VIEW_SECTION && ![self isInformationPath:indexPath]) {
        UIExport *export;
        if (indexPath.row == 1) {
            export = [self.contents firstObject];
        } else {
            export = [self.contents lastObject];
        }
    
        if (export.count > 0) {
            export.checked = !export.checked;
            
            ExportContentCell *exportContentCell = (ExportContentCell *)[self.tableView cellForRowAtIndexPath:indexPath];
            [exportContentCell bindWithExport:export];
            
            if (export.exportContentType == ExportContentTypeAll && export.checked) {
                UIExport *contentMedia = [self.contents firstObject];
                contentMedia.checked = NO;
                ExportContentCell *exportMediaCell = (ExportContentCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:CONTENT_VIEW_SECTION]];
                [exportMediaCell bindWithExport:contentMedia];
            } else if (export.exportContentType == ExportContentTypeMediaAndFile && export.checked) {
                UIExport *contentAll = [self.contents lastObject];
                contentAll.checked = NO;
                ExportContentCell *exportMediaCell = (ExportContentCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:CONTENT_VIEW_SECTION]];
                [exportMediaCell bindWithExport:contentAll];
            }
        }
        
        ExportActionCell *exportActionCell = (ExportActionCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:CLEAN_VIEW_SECTION]];
        [exportActionCell bindWithAction:ExportActionTypeCleanup enable:[self canCleanup]];
    } else if (indexPath.section == EXPIRATION_VIEW_SECTION && indexPath.row == 1) {
        [self openExpirationMenu];
    }
}

#pragma mark - ExportActionDelegate

- (void)didTapAction:(ExportActionType)exportActionType {
    DDLogVerbose(@"%@ didTapAction: %u", LOG_TAG, exportActionType);
    
    if (exportActionType == ExportActionTypeCancel) {
        [self finish];
    } else if ([self canCleanup]) {
        ApplicationDelegate *delegate = (ApplicationDelegate *)[[UIApplication sharedApplication] delegate];
        if ([delegate.twinmeApplication isSubscribedWithFeature:TLTwinmeApplicationFeatureGroupCall]) {
            if (self.contact) {
                [self.cleanUpService getImageWithContact:self.contact withBlock:^(UIImage *image) {
                    [self openDeleteConfirmView:image];
                }];
            } else if (self.group) {
                [self.cleanUpService getImageWithGroup:self.group withBlock:^(UIImage *image) {
                    [self openDeleteConfirmView:image];
                }];
            } else if (self.space) {
                if (self.space.avatarId) {
                    [self.cleanUpService getImageWithSpace:self.space withBlock:^(UIImage *image) {
                        [self openDeleteConfirmView:image];
                    }];
                } else {
                    [self openDeleteConfirmView:nil];
                }
            } else {
                [self openDeleteConfirmView:nil];
            }
        } else {
            PremiumFeatureConfirmView *premiumFeatureConfirmView = [[PremiumFeatureConfirmView alloc] init];
            premiumFeatureConfirmView.confirmViewDelegate = self;
            [premiumFeatureConfirmView initWithPremiumFeature:[[UIPremiumFeature alloc]initWithFeatureType:FeatureTypeConversation spaceSettings:[self currentSpaceSettings]] parentViewController:self.tabBarController];
            [self.tabBarController.view addSubview:premiumFeatureConfirmView];
            [premiumFeatureConfirmView showConfirmView];
        }
    }
}

#pragma mark - MenuCleanUpExpirationDelegate

- (void)menuCleanUpExpirationCancel:(MenuCleanUpExpirationView *)menuCleanUpExpirationView {
    DDLogVerbose(@"%@ menuCleanUpExpirationCancel ", LOG_TAG);
    
    [menuCleanUpExpirationView removeFromSuperview];
    self.menuCleanUpExpirationView = nil;
}

- (void)menuCleanUpExpirationSelectExpiration:(MenuCleanUpExpirationView *)menuCleanUpExpirationView uiCleanUpExpiration:(UICleanUpExpiration *)uiCleanUpExpiration {
    DDLogVerbose(@"%@ menuCleanUpExpirationSelectExpiration: %@", LOG_TAG, uiCleanUpExpiration);
    
    self.cleanUpExpiration = uiCleanUpExpiration;
    [self.cleanUpService setDateFilter:[self.cleanUpExpiration clearDate]];
    [self.tableView reloadData];
    
    [menuCleanUpExpirationView removeFromSuperview];
    self.menuCleanUpExpirationView = nil;
}

#pragma mark - ConfirmViewDelegate

- (void)didTapConfirm:(nonnull AbstractConfirmView *)abstractConfirmView {
    DDLogVerbose(@"%@ didTapConfirm: %@", LOG_TAG, abstractConfirmView);
    
    if ([abstractConfirmView isKindOfClass:[PremiumFeatureConfirmView class]]) {
        InAppSubscriptionViewController *inAppSubscriptionViewController = [[UIStoryboard storyboardWithName:@"iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"InAppSubscriptionViewController"];
        TwinmeNavigationController *navigationController = [[TwinmeNavigationController alloc]initWithRootViewController:inAppSubscriptionViewController];
        [self.navigationController presentViewController:navigationController animated:YES completion:nil];
    } else {
        UIExport *allContent = [self.contents lastObject];
        if (allContent.checked) {
            if (self.cleanUpType == CleanUpTypeLocal) {
                [self.cleanUpService startCleanUpFrom:[self.cleanUpExpiration clearDate] clearMode:TLConversationServiceClearLocal];
            } else {
                [self.cleanUpService startCleanUpFrom:[self.cleanUpExpiration clearDate] clearMode:TLConversationServiceClearBoth];
            }
        } else {
            if (self.cleanUpType == CleanUpTypeLocal) {
                [self.cleanUpService startCleanUpFrom:[self.cleanUpExpiration clearDate] clearMode:TLConversationServiceClearMedia];
            } else {
                [self.cleanUpService startCleanUpFrom:[self.cleanUpExpiration clearDate] clearMode:TLConversationServiceClearBothMedia];
            }
        }
    }
    
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
    
    if (self.cleanUpType == CleanUpTypeLocal) {
        [self setNavigationTitle:TwinmeLocalizedString(@"cleanup_view_controller_local_cleanup_title", nil)];
    } else {
        [self setNavigationTitle:TwinmeLocalizedString(@"cleanup_view_controller_both_clean_title", nil)];
    }
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerNib:[UINib nibWithNibName:@"ExportActionCell" bundle:nil] forCellReuseIdentifier:EXPORT_ACTION_CELL_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"ExportContentCell" bundle:nil] forCellReuseIdentifier:EXPORT_CONTENT_CELL_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"StorageCell" bundle:nil] forCellReuseIdentifier:STORAGE_CELL_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"StorageChartCell" bundle:nil] forCellReuseIdentifier:STORAGE_CHART_CELL_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"SettingsSectionHeaderCell" bundle:nil] forCellReuseIdentifier:HEADER_SETTINGS_CELL_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"SettingsInformationCell" bundle:nil] forCellReuseIdentifier:SETTINGS_INFORMATION_CELL_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"SettingsValueItemCell" bundle:nil] forCellReuseIdentifier:SETTINGS_VALUE_CELL_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"SettingsItemCell" bundle:nil] forCellReuseIdentifier:SETTINGS_ITEM_CELL_IDENTIFIER];
    
    self.tableView.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = Design.SETTING_CELL_HEIGHT;
}

- (void)initStorage {
    DDLogVerbose(@"%@ initStorage", LOG_TAG);
        
    int64_t totalSpace = 0;
    int64_t totalFreeSpace = 0;
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error: &error];

    if (dictionary) {
        NSNumber *fileSystemSizeInBytes = [dictionary objectForKey: NSFileSystemSize];
        NSNumber *freeFileSystemSizeInBytes = [dictionary objectForKey:NSFileSystemFreeSize];
        totalSpace = [fileSystemSizeInBytes unsignedLongLongValue];
        totalFreeSpace = [freeFileSystemSizeInBytes unsignedLongLongValue];
    }
    
    int64_t conversationSize = [self getConversationSize];
    
    [self.storages addObject:[[UIStorage alloc]initWithStorageType:StorageTypeUsed size:totalSpace - totalFreeSpace name:nil]];
    [self.storages addObject:[[UIStorage alloc]initWithStorageType:StorageTypeFree size:totalFreeSpace name:nil]];
    [self.storages addObject:[[UIStorage alloc]initWithStorageType:StorageTypeApp size:conversationSize name:nil]];
    [self.storages addObject:[[UIStorage alloc]initWithStorageType:StorageTypeConversation size:0 name:self.conversationName]];
    [self.storages addObject:[[UIStorage alloc]initWithStorageType:StorageTypeTotal size:totalSpace name:nil]];
}

- (int64_t)getConversationSize {
    DDLogVerbose(@"%@ getConversationSize", LOG_TAG);
    
    NSError *error = nil;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *groupURL = [fileManager containerURLForSecurityApplicationGroupIdentifier:[TLTwinlife APP_GROUP_NAME]];
    NSURL *url = [groupURL URLByAppendingPathComponent:@"Conversations"];
    NSArray *bundleArray = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:url.path error:nil];
    NSEnumerator *filesEnumerator = [bundleArray objectEnumerator];
    
    NSString *fileName;
    int64_t conversationSize = 0;
    while (fileName = [filesEnumerator nextObject]) {
        NSDictionary *fileDictionary = [[NSFileManager defaultManager] attributesOfItemAtPath:[url.path stringByAppendingPathComponent:fileName] error:&error];
        conversationSize += [fileDictionary fileSize];
    }
    
    return conversationSize;
}

- (void)initContent {
    DDLogVerbose(@"%@ initStorage", LOG_TAG);
    
    [self.contents addObject:[[UIExport alloc]initWithExportContentType:ExportContentTypeMediaAndFile image:[UIImage imageNamed:@"ToolbarPictureGrey"] checked:NO]];
    [self.contents addObject:[[UIExport alloc]initWithExportContentType:ExportContentTypeAll image:[UIImage imageNamed:@"TabBarChatGrey"] checked:NO]];
}

- (void)updateContent:(nonnull TLExportStats *)stats {
    DDLogVerbose(@"%@ updateContent: %@", LOG_TAG, stats);
    
    UIExport *mediaContent = [self.contents firstObject];
    UIExport *allContent = [self.contents lastObject];
        
    mediaContent.count = stats.imageCount + stats.videoCount + stats.audioCount + stats.fileCount;
    mediaContent.size = stats.imageSize + stats.videoSize + stats.audioSize + stats.fileSize;

    allContent.count = stats.msgCount + stats.imageCount + stats.videoCount + stats.audioCount + stats.fileCount;
    allContent.size = 0;
    
    if (!self.initContentToClean) {
        self.initContentToClean = YES;
        UIStorage *storageConversation;
        for (UIStorage *storage in self.storages) {
            if (storage.storageType == StorageTypeConversation) {
                storageConversation = storage;
                break;
            }
        }
        
        if (storageConversation) {
            storageConversation.size = mediaContent.size;
        }
        
        [self.cleanUpService setDateFilter:[self.cleanUpExpiration clearDate]];
    }
    
    
    [self.tableView reloadData];
}

- (BOOL)canCleanup {
    DDLogVerbose(@"%@ canCleanup", LOG_TAG);
    
    for (UIExport *uiExport in self.contents) {
        if (uiExport.checked && uiExport.count > 0) {
            return YES;
        }
    }
    
    return NO;
}

- (void)openExpirationMenu {
    DDLogVerbose(@"%@ openExpirationMenu", LOG_TAG);
    
    if (!self.menuCleanUpExpirationView) {
        self.menuCleanUpExpirationView = [[MenuCleanUpExpirationView alloc]init];
        self.menuCleanUpExpirationView.menuCleanUpExpirationDelegate = self;
        [self.navigationController.view addSubview:self.menuCleanUpExpirationView];
        [self.menuCleanUpExpirationView openMenu:self.cleanUpExpiration];
    }
}

- (void)finish {
    DDLogVerbose(@"%@ finish", LOG_TAG);
    
    if (self.cleanUpService) {
        [self.cleanUpService dispose];
        self.cleanUpService = nil;
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)openDeleteConfirmView:(UIImage *)avatar {
    DDLogVerbose(@"%@ openDeleteConfirmView", LOG_TAG);
    
    if (self.space) {
        DeleteSpaceConfirmView *deleteConfirmView = [[DeleteSpaceConfirmView alloc] init];
        deleteConfirmView.confirmViewDelegate = self;
        [deleteConfirmView initWithTitle:TwinmeLocalizedString(@"delete_account_view_controller_warning", nil) message:TwinmeLocalizedString(@"cleanup_view_controller_delete_confirmation_message", nil) spaceName:self.space.settings.name spaceStyle:self.space.settings.style avatar:avatar icon:[UIImage imageNamed:@"ActionBarDelete"]];
        [self.tabBarController.view addSubview:deleteConfirmView];
        [deleteConfirmView showConfirmView];
    } else {
        DeleteConfirmView *deleteConfirmView = [[DeleteConfirmView alloc] init];
        deleteConfirmView.confirmViewDelegate = self;
        deleteConfirmView.deleteConfirmType = DeleteConfirmTypeFile;
        [deleteConfirmView initWithTitle:TwinmeLocalizedString(@"delete_account_view_controller_warning", nil) message:TwinmeLocalizedString(@"cleanup_view_controller_delete_confirmation_message", nil) avatar:avatar icon:[UIImage imageNamed:@"ActionBarDelete"]];
        
        if (!avatar) {
            [deleteConfirmView hideAvatar];
        }
       
        [self.tabBarController.view addSubview:deleteConfirmView];
        [deleteConfirmView showConfirmView];
    }
}

- (BOOL)isInformationPath:(NSIndexPath *)indexPath {
    
    if ((indexPath.row == 0 || indexPath.row == 2 || indexPath.row == 4) && indexPath.section == CONTENT_VIEW_SECTION) {
        return YES;
    }
    
    return NO;
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    [self.tableView reloadData];
}

@end
