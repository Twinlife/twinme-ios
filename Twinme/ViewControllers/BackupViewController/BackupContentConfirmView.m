/*
 *  Copyright (c) 2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import "BackupContentConfirmView.h"

#import "BackupContentCell.h"
#import "SettingsSectionHeaderCell.h"
#import "SettingsInformationCell.h"

#import "UIRestoreItem.h"
#import "UIBackupContent.h"

#import <Utils/NSString+Utils.h>

#import <Twinme/TLSpace.h>
#import <Twinme/TLContact.h>
#import <Twinme/TLGroup.h>
#import <Twinme/TLCallReceiver.h>

#import <TwinmeCommon/Design.h>
#import <TwinmeCommon/BackupService.h>

#import <Twinlife/TLRestoreContent.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static NSString *BACKUP_CONTENT_CELL_IDENTIFIER = @"BackupContentCellIdentifier";
static NSString *SETTINGS_INFORMATION_CELL_IDENTIFIER = @"SettingsInformationCellIdentifier";
static NSString *HEADER_SETTINGS_CELL_IDENTIFIER = @"HeaderSettingsCellIdentifier";

static const CGFloat DESIGN_CONTENT_HEIGHT = 80;
static const CGFloat DESIGN_INFO_VERTICAL_MARGIN = 10;
static const CGFloat DESIGN_INFO_HORIZONTAL_MARGIN = 34;
//
// Interface: BackupContentConfirmView ()
//

@interface BackupContentConfirmView()<UITableViewDataSource>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentTableViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentTableViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UITableView *contentTableView;

@property (nonatomic) NSMutableArray *items;

@end

//
// Implementation: BackupContentConfirmView
//

#undef LOG_TAG
#define LOG_TAG @"BackupContentConfirmView"

@implementation BackupContentConfirmView

#pragma mark - UIView

- (instancetype)init {
    DDLogVerbose(@"%@ init", LOG_TAG);
    
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"BackupContentConfirmView" owner:self options:nil];
    self = [objects objectAtIndex:0];
    
    self.frame = CGRectMake(0, 0, Design.DISPLAY_WIDTH, Design.DISPLAY_HEIGHT);
    
    if (self) {
        _items = [[NSMutableArray alloc] init];
        [self initViews];
    }
    return self;
}

- (void)initWithStats:(nonnull NSDictionary<NSUUID *, NSNumber *> *)stats {
    DDLogVerbose(@"%@ initWithStats: %@", LOG_TAG, stats);
    
    [self updateWithBackupStats:stats];
}

- (void)initWithRestoreReport:(RestoreReport *)restoreReport isLastBackup:(BOOL)isLastBackup {
    DDLogVerbose(@"%@ initWithRestoreReport: %@", LOG_TAG, restoreReport);
    
    if (![restoreReport isRestoreUpToDate]) {
        NSString *diffMessage = [NSString stringWithFormat:@"%@\n\n%@", TwinmeLocalizedStringFromTable(@"backup_view_verify_not_up_to_date", @"LocalizableBackup", nil), TwinmeLocalizedStringFromTable(@"backup_view_content_diff_message", @"LocalizableBackup", nil)];
        if (isLastBackup) {
            self.messageLabel.text =  diffMessage ;
        } else {
            self.messageLabel.text = [NSString stringWithFormat:@"%@\n%@", TwinmeLocalizedStringFromTable(@"restore_view_more_recent_backup", @"LocalizableBackup", nil), diffMessage];
        }
    } else {
        if (isLastBackup) {
            self.messageLabel.text = TwinmeLocalizedStringFromTable(@"restore_view_confirm", @"LocalizableBackup", nil);
        } else {
            self.messageLabel.text = [NSString stringWithFormat:@"%@\n\n%@", TwinmeLocalizedStringFromTable(@"restore_view_more_recent_backup", @"LocalizableBackup", nil), TwinmeLocalizedStringFromTable(@"restore_view_confirm", @"LocalizableBackup", nil)];
        }
    }
    
    [self updateWithRestoreReport:restoreReport];
}

- (void)setConfirmTitle:(NSString *)confirmTitle {
    DDLogVerbose(@"%@ setConfirmTitle: %@", LOG_TAG, confirmTitle);
    
    self.confirmLabel.text = confirmTitle;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    DDLogVerbose(@"%@ numberOfSectionsInTableView: %@", LOG_TAG, tableView);
    
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath  {
    DDLogVerbose(@"%@ tableView: %@ heightForRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    UIRestoreItem *restoreItem = [self.items objectAtIndex:indexPath.row];
    
    if ([restoreItem getRestoreItemType] == UIRestoreItemTypeInfo) {
        return UITableViewAutomaticDimension;
    } else {
        return roundf(DESIGN_CONTENT_HEIGHT * Design.HEIGHT_RATIO);
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
    
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ cellForRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    UIRestoreItem *restoreItem = [self.items objectAtIndex:indexPath.row];
    
    switch ([restoreItem getRestoreItemType]) {
        case UIRestoreItemTypeSection: {
            SettingsSectionHeaderCell *settingsSectionHeaderCell = (SettingsSectionHeaderCell *)[tableView dequeueReusableCellWithIdentifier:HEADER_SETTINGS_CELL_IDENTIFIER];
            if (!settingsSectionHeaderCell) {
                settingsSectionHeaderCell = [[SettingsSectionHeaderCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:HEADER_SETTINGS_CELL_IDENTIFIER];
            }
            
            [settingsSectionHeaderCell bindWithTitle:[restoreItem getText] backgroundColor:Design.POPUP_BACKGROUND_COLOR hideSeparator:NO uppercaseString:YES];
            
            return settingsSectionHeaderCell;
        }
            
        case UIRestoreItemTypeContent: {
            BackupContentCell *cell = [tableView dequeueReusableCellWithIdentifier:BACKUP_CONTENT_CELL_IDENTIFIER];
            if (!cell) {
                cell = [[BackupContentCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:BACKUP_CONTENT_CELL_IDENTIFIER];
            }
            
            [cell bind:restoreItem backgroundColor:Design.POPUP_BACKGROUND_COLOR hideSeparator:NO];
            
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

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    [super initViews];
    
    self.bulletView.hidden = YES;
    self.iconView.hidden = YES;
    self.avatarContainerView.hidden = YES;
    
    self.contentTableViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.contentTableViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.contentTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.contentTableView registerNib:[UINib nibWithNibName:@"BackupContentCell" bundle:nil] forCellReuseIdentifier:BACKUP_CONTENT_CELL_IDENTIFIER];
    [self.contentTableView registerNib:[UINib nibWithNibName:@"SettingsSectionHeaderCell" bundle:nil] forCellReuseIdentifier:HEADER_SETTINGS_CELL_IDENTIFIER];
    [self.contentTableView registerNib:[UINib nibWithNibName:@"SettingsInformationCell" bundle:nil] forCellReuseIdentifier:SETTINGS_INFORMATION_CELL_IDENTIFIER];
    
    self.contentTableView.backgroundColor = Design.POPUP_BACKGROUND_COLOR;
    self.contentTableView.dataSource = self;
    self.contentTableView.scrollEnabled = YES;
    self.contentTableView.rowHeight = roundf(DESIGN_CONTENT_HEIGHT * Design.HEIGHT_RATIO);
    
    self.titleLabel.text = TwinmeLocalizedStringFromTable(@"backup_view_content", @"LocalizableBackup", nil);
    self.messageLabel.text = TwinmeLocalizedStringFromTable(@"backup_view_content_info", @"LocalizableBackup", nil);
    self.confirmLabel.text = TwinmeLocalizedString(@"application_confirm", nil);
    
    self.iconView.backgroundColor = Design.DELETE_COLOR_RED;
    self.bulletView.backgroundColor = Design.DELETE_COLOR_RED;
    
    self.cancelLabel.textColor = Design.FONT_COLOR_DEFAULT;
}

- (void)updateWithBackupStats:(nonnull NSDictionary<NSUUID *, NSNumber *> *)stats {
    DDLogVerbose(@"%@ updateWithBackupStats", LOG_TAG);
    
    [self.items removeAllObjects];
    
#ifdef TWINME
    NSArray<NSUUID *> *schemaIds = @[TLContact.SCHEMA_ID, TLGroup.SCHEMA_ID];
    NSDictionary<NSUUID *, NSNumber *> *schemaIdToContentType = @{
        TLContact.SCHEMA_ID : @(BackupContentTypeContacts),
        TLGroup.SCHEMA_ID : @(BackupContentTypeGroups)
    };
#else
    NSArray<NSUUID *> *schemaIds = @[TLSpace.SCHEMA_ID, TLContact.SCHEMA_ID, TLGroup.SCHEMA_ID, TLCallReceiver.SCHEMA_ID];
    NSDictionary<NSUUID *, NSNumber *> *schemaIdToContentType = @{
        
        TLSpace.SCHEMA_ID : @(BackupContentTypeSpaces),
        TLContact.SCHEMA_ID : @(BackupContentTypeContacts),
        TLGroup.SCHEMA_ID : @(BackupContentTypeGroups),
        TLCallReceiver.SCHEMA_ID : @(BackupContentTypeClickToCall)
    };
#endif
        
    for (NSUUID *schemaId in schemaIds) {
        BackupContentType type = (BackupContentType)schemaIdToContentType[schemaId].intValue;
        
        NSNumber *count = stats[schemaId];
        
        if (type == BackupContentTypeContacts) {
            [self.items addObject:[[UIRestoreItem alloc] initWithType:UIRestoreItemTypeContent text:TwinmeLocalizedString(@"contacts_view_title", nil) icon:[UIImage imageNamed:@"ContactsIcon"] value:count.intValue color:Design.BLACK_COLOR]];
        } else if (type == BackupContentTypeGroups) {
            [self.items addObject:[[UIRestoreItem alloc] initWithType:UIRestoreItemTypeContent text:TwinmeLocalizedString(@"share_view_group_list", nil) icon:[UIImage imageNamed:@"GroupsIcon"] value:count.intValue color:Design.BLACK_COLOR]];
        } else if (type == BackupContentTypeClickToCall) {
            [self.items addObject:[[UIRestoreItem alloc] initWithType:UIRestoreItemTypeContent text:TwinmeLocalizedString(@"premium_services_view_click_to_call_title", nil) icon:[UIImage imageNamed:@"AddExternalCall"] value:count.intValue color:Design.BLACK_COLOR]];
        } else if (type == BackupContentTypeSpaces) {
            [self.items addObject:[[UIRestoreItem alloc] initWithType:UIRestoreItemTypeContent text:TwinmeLocalizedString(@"spaces_view_title", nil) icon:[UIImage imageNamed:@"TabBarSpacesGrey"] value:count.intValue color:Design.BLACK_COLOR]];
        }
    }
    
    self.contentTableViewHeightConstraint.constant = roundf(DESIGN_CONTENT_HEIGHT * Design.HEIGHT_RATIO) * self.items.count;

    [self.contentTableView reloadData];
}

- (void)updateWithRestoreReport:(RestoreReport *)restoreReport {
    DDLogVerbose(@"%@ updateWithRestoreReport", LOG_TAG);
    
    [self.items removeAllObjects];
    
    CGFloat estimateSize = 0;
    CGFloat contentCellHeight = roundf(DESIGN_CONTENT_HEIGHT * Design.HEIGHT_RATIO);
    
    if (![restoreReport isRestoreUpToDate]) {
        
        if (![restoreReport.profiles isStatsUpToDate]) {
            [self.items addObject:[[UIRestoreItem alloc] initWithType:UIRestoreItemTypeSection text:TwinmeLocalizedString(@"application_profile", nil) icon:nil value:-1 color:nil]];
            estimateSize += contentCellHeight;
            [self.items addObject:[[UIRestoreItem alloc] initWithType:UIRestoreItemTypeContent text:TwinmeLocalizedStringFromTable(@"restore_view_content_profile_reset", @"LocalizableBackup", nil) icon:[UIImage imageNamed:@"GenerateCode"] value:-1 color:Design.BLACK_COLOR]];
            estimateSize += contentCellHeight;
            [self.items addObject:[[UIRestoreItem alloc] initWithType:UIRestoreItemTypeInfo text:TwinmeLocalizedStringFromTable(@"restore_view_content_profile_reset_message", @"LocalizableBackup", nil) icon:nil value:-1 color:nil]];
            estimateSize += [self estimateInfoSize:TwinmeLocalizedStringFromTable(@"restore_view_content_profile_reset_message", @"LocalizableBackup", nil)];
        }
        
        if (![restoreReport.contacts isStatsUpToDate]) {
            [self.items addObject:[[UIRestoreItem alloc] initWithType:UIRestoreItemTypeSection text:TwinmeLocalizedString(@"contacts_view_title", nil) icon:nil value:-1 color:nil]];
            estimateSize += contentCellHeight;
            if (restoreReport.contacts.added != 0) {
                [self.items addObject:[[UIRestoreItem alloc] initWithType:UIRestoreItemTypeContent text:TwinmeLocalizedStringFromTable(@"backup_view_content_diff_added", @"LocalizableBackup", nil) icon:[UIImage imageNamed:@"ContactsIcon"] value:restoreReport.contacts.added color:Design.BLACK_COLOR]];
                estimateSize += contentCellHeight;
            }
            
            if (restoreReport.contacts.modified != 0) {
                [self.items addObject:[[UIRestoreItem alloc] initWithType:UIRestoreItemTypeContent text:TwinmeLocalizedStringFromTable(@"backup_view_content_diff_updated", @"LocalizableBackup", nil) icon:[UIImage imageNamed:@"ActionEdit"] value:restoreReport.contacts.modified color:Design.BLACK_COLOR]];
                estimateSize += contentCellHeight;
            }
            
            if (restoreReport.contacts.deleted != 0) {
                [self.items addObject:[[UIRestoreItem alloc] initWithType:UIRestoreItemTypeContent text:TwinmeLocalizedStringFromTable(@"backup_view_content_diff_deleted", @"LocalizableBackup", nil) icon:[UIImage imageNamed:@"DeleteItem"] value:restoreReport.contacts.deleted color:nil]];
                estimateSize += contentCellHeight;
                [self.items addObject:[[UIRestoreItem alloc] initWithType:UIRestoreItemTypeInfo text:TwinmeLocalizedStringFromTable(@"restore_view_content_contact_deleted_message", @"LocalizableBackup", nil) icon:nil value:-1 color:nil]];
                estimateSize += [self estimateInfoSize:TwinmeLocalizedStringFromTable(@"restore_view_content_contact_deleted_message", @"LocalizableBackup", nil)];
            }
        }
        
        if (![restoreReport.groups isStatsUpToDate]) {
            [self.items addObject:[[UIRestoreItem alloc] initWithType:UIRestoreItemTypeSection text:TwinmeLocalizedString(@"share_view_group_list", nil) icon:nil value:-1 color:nil]];
            estimateSize += contentCellHeight;
            if (restoreReport.groups.added != 0) {
                [self.items addObject:[[UIRestoreItem alloc] initWithType:UIRestoreItemTypeContent text:TwinmeLocalizedStringFromTable(@"backup_view_content_diff_added", @"LocalizableBackup", nil) icon:[UIImage imageNamed:@"GroupsIcon"] value:restoreReport.groups.added color:Design.BLACK_COLOR]];
                estimateSize += contentCellHeight;
            }
            
            if (restoreReport.groups.modified != 0) {
                [self.items addObject:[[UIRestoreItem alloc] initWithType:UIRestoreItemTypeContent text:TwinmeLocalizedStringFromTable(@"backup_view_content_diff_updated", @"LocalizableBackup", nil) icon:[UIImage imageNamed:@"ActionEdit"] value:restoreReport.groups.modified color:Design.BLACK_COLOR]];
                estimateSize += contentCellHeight;
            }
            
            if (restoreReport.groups.deleted != 0) {
                [self.items addObject:[[UIRestoreItem alloc] initWithType:UIRestoreItemTypeContent text:TwinmeLocalizedStringFromTable(@"backup_view_content_diff_deleted", @"LocalizableBackup", nil) icon:[UIImage imageNamed:@"DeleteItem"] value:restoreReport.groups.deleted color:nil]];
                estimateSize += contentCellHeight;
                [self.items addObject:[[UIRestoreItem alloc] initWithType:UIRestoreItemTypeInfo text:TwinmeLocalizedStringFromTable(@"restore_view_content_contact_deleted_message", @"LocalizableBackup", nil) icon:nil value:-1 color:nil]];
                estimateSize += [self estimateInfoSize:TwinmeLocalizedStringFromTable(@"restore_view_content_contact_deleted_message", @"LocalizableBackup", nil)];
            }
        }
        
        if (![restoreReport.clickToCall isStatsUpToDate]) {
            [self.items addObject:[[UIRestoreItem alloc] initWithType:UIRestoreItemTypeSection text:TwinmeLocalizedString(@"premium_services_view_click_to_call_title", nil) icon:nil value:-1 color:nil]];
            estimateSize += contentCellHeight;
            if (restoreReport.clickToCall.added != 0) {
                [self.items addObject:[[UIRestoreItem alloc] initWithType:UIRestoreItemTypeContent text:TwinmeLocalizedStringFromTable(@"backup_view_content_diff_added", @"LocalizableBackup", nil) icon:[UIImage imageNamed:@"AddExternalCall"] value:restoreReport.contacts.added color:Design.BLACK_COLOR]];
                estimateSize += contentCellHeight;
            }
            
            if (restoreReport.clickToCall.modified != 0) {
                [self.items addObject:[[UIRestoreItem alloc] initWithType:UIRestoreItemTypeContent text:TwinmeLocalizedStringFromTable(@"backup_view_content_diff_updated", @"LocalizableBackup", nil) icon:[UIImage imageNamed:@"ActionEdit"] value:restoreReport.clickToCall.modified color:Design.BLACK_COLOR]];
                estimateSize += contentCellHeight;
            }
            
            if (restoreReport.clickToCall.deleted != 0) {
                [self.items addObject:[[UIRestoreItem alloc] initWithType:UIRestoreItemTypeContent text:TwinmeLocalizedStringFromTable(@"backup_view_content_diff_deleted", @"LocalizableBackup", nil) icon:[UIImage imageNamed:@"DeleteItem"] value:restoreReport.clickToCall.deleted color:nil]];
                estimateSize += contentCellHeight;
                [self.items addObject:[[UIRestoreItem alloc] initWithType:UIRestoreItemTypeInfo text:TwinmeLocalizedStringFromTable(@"restore_view_content_contact_deleted_message", @"LocalizableBackup", nil) icon:nil value:-1 color:nil]];
                estimateSize += [self estimateInfoSize:TwinmeLocalizedStringFromTable(@"restore_view_content_contact_deleted_message", @"LocalizableBackup", nil)];
            }
        }
    } else {
        [self.items addObject:[[UIRestoreItem alloc] initWithType:UIRestoreItemTypeContent text:TwinmeLocalizedString(@"contacts_view_title", nil) icon:[UIImage imageNamed:@"ContactsIcon"] value:restoreReport.contacts.upToDate color:Design.BLACK_COLOR]];
        estimateSize += contentCellHeight;
        [self.items addObject:[[UIRestoreItem alloc] initWithType:UIRestoreItemTypeContent text:TwinmeLocalizedString(@"premium_services_view_click_to_call_title", nil) icon:[UIImage imageNamed:@"AddExternalCall"] value:restoreReport.clickToCall.upToDate color:Design.BLACK_COLOR]];
        estimateSize += contentCellHeight;
        [self.items addObject:[[UIRestoreItem alloc] initWithType:UIRestoreItemTypeContent text:TwinmeLocalizedString(@"spaces_view_title", nil) icon:[UIImage imageNamed:@"TabBarSpacesGrey"] value:restoreReport.profiles.upToDate color:Design.BLACK_COLOR]];
        estimateSize += contentCellHeight;
        [self.items addObject:[[UIRestoreItem alloc] initWithType:UIRestoreItemTypeContent text:TwinmeLocalizedString(@"share_view_group_list", nil) icon:[UIImage imageNamed:@"GroupsIcon"] value:restoreReport.groups.upToDate color:Design.BLACK_COLOR]];
        estimateSize += contentCellHeight;
    }
        
    self.contentTableViewHeightConstraint.constant = estimateSize;
    
    [self.contentTableView  reloadData];
}

- (CGFloat)estimateInfoSize:(NSString *)info {
    DDLogVerbose(@"%@ estimateInfoSize", LOG_TAG);
    
    CGFloat maxLabelWidth = Design.DISPLAY_WIDTH - (DESIGN_INFO_HORIZONTAL_MARGIN * 2);
    CGRect infoRect = [info boundingRectWithSize:CGSizeMake(maxLabelWidth, CGFLOAT_MAX) options:NSStringDrawingUsesFontLeading attributes:@{
        NSFontAttributeName : Design.FONT_REGULAR28
    } context:nil];
    
    return infoRect.size.height + (DESIGN_INFO_VERTICAL_MARGIN * 2);
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    [super updateColor];
    
    self.contentTableView.backgroundColor = Design.POPUP_BACKGROUND_COLOR;
}

@end
