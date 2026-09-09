/*
 *  Copyright (c) 2026 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <Twinlife/TLManagementService.h>
#import <Twinlife/TLConnectivityService.h>

#import <TwinmeCommon/AbstractTwinmeService.h>
#import <TwinmeCommon/AbstractTwinmeService+Protected.h>

#import <UserNotifications/UserNotifications.h>

#import "DiagnosticsViewController.h"

#import "DeviceAuthorization.h"
#import "DiagnosticCell.h"
#import "UIDiagnosticSection.h"
#import "UIDiagnosticItem.h"

#import <TwinmeCommon/Design.h>
#import <TwinmeCommon/SettingsSectionHeaderCell.h>

#import <Utils/NSString+Utils.h>


#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static NSString *HEADER_SETTINGS_CELL_IDENTIFIER = @"HeaderSettingsCellIdentifier";
static NSString *DIAGNOSTIC_ICON_CELL_IDENTIFIER = @"DiagnosticIconCellIdentifier";

//
// Interface: DiagnosticsViewController
//

@interface DiagnosticsViewController ()<UITableViewDelegate, UITableViewDataSource, AbstractTwinmeDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) NSMutableArray<UIDiagnosticSection *> *sections;

@property (nonatomic, nullable) AbstractTwinmeService *twinmeService;
@property (nonatomic, nullable) AbstractTwinmeContextDelegate *twinmeServiceDelegate;

- (void)updateDiagnosticItemCell:(UIDiagnosticItem *)item inSection:(UIDiagnosticSection *)section;

@end

//
// Implementation: DiagnosticsViewController
//

#undef LOG_TAG
#define LOG_TAG @"DiagnosticsViewController"

@implementation DiagnosticsViewController

- (instancetype)initWithCoder:(NSCoder *)coder {
    DDLogVerbose(@"%@ initWithCoder: %@", LOG_TAG, coder);
    
    self = [super initWithCoder:coder];
    
    if (self) {
        _twinmeService = [[AbstractTwinmeService alloc] initWithTwinmeContext:self.twinmeContext tag:LOG_TAG delegate:self];
        _twinmeServiceDelegate = [[AbstractTwinmeContextDelegate alloc] initWithService:self.twinmeService];
        [self.twinmeContext addDelegate:self.twinmeServiceDelegate];
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
    
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

#pragma mark - AbstractTwinmeServiceDelegate

- (void)onConnectionStatusChange:(TLConnectionStatus)connectionStatus {
    DDLogVerbose(@"%@ onConnectionStatusChange: %u", LOG_TAG, connectionStatus);
    
    [self updateConnection:self.twinmeContext.connectionStatus];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    DDLogVerbose(@"%@ numberOfSectionsInTableView: %@", LOG_TAG, tableView);
    
    return self.sections.count;
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ numberOfRowsInSection: %ld", LOG_TAG, tableView, (long)section);
    
    UIDiagnosticSection *diagnosticSection = [self.sections objectAtIndex:section];
    return diagnosticSection.items.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ viewForHeaderInSection: %ld", LOG_TAG, tableView, (long)section);
    
    UIDiagnosticSection *diagnosticSection = [self.sections objectAtIndex:section];
    if ([diagnosticSection.title isEqual:@""]) {
        return [[UIView alloc]init];
    }
    
    SettingsSectionHeaderCell *settingsSectionHeaderCell = (SettingsSectionHeaderCell *)[tableView dequeueReusableCellWithIdentifier:HEADER_SETTINGS_CELL_IDENTIFIER];
    if (!settingsSectionHeaderCell) {
        settingsSectionHeaderCell = [[SettingsSectionHeaderCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:HEADER_SETTINGS_CELL_IDENTIFIER];
    }
    
    [settingsSectionHeaderCell bindWithTitle:diagnosticSection.title backgroundColor:Design.LIGHT_GREY_BACKGROUND_COLOR hideSeparator:NO uppercaseString:YES];
    
    return settingsSectionHeaderCell;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ cellForRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    UIDiagnosticSection *section = [self.sections objectAtIndex:indexPath.section];
    UIDiagnosticItem *item = [section.items objectAtIndex:indexPath.row];
    
    DiagnosticCell *cell = [tableView dequeueReusableCellWithIdentifier:DIAGNOSTIC_ICON_CELL_IDENTIFIER];
    if (!cell) {
        cell = [[DiagnosticCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:DIAGNOSTIC_ICON_CELL_IDENTIFIER];
    }
    
    [cell bind:item];
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ didSelectRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
}

#pragma mark - Private methods

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    self.view.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
    
    [self setNavigationTitle:TwinmeLocalizedString(@"diagnostics_view_title", nil)];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerNib:[UINib nibWithNibName:@"DiagnosticCell" bundle:nil] forCellReuseIdentifier:DIAGNOSTIC_ICON_CELL_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"SettingsSectionHeaderCell" bundle:nil] forCellReuseIdentifier:HEADER_SETTINGS_CELL_IDENTIFIER];
    self.tableView.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
    
    [self initSections];
}

- (void)finish {
    DDLogVerbose(@"%@ finish", LOG_TAG);
    
    if (self.twinmeService) {
        [self.twinmeService dispose];
        self.twinmeService = nil;
    }
    if (self.twinmeServiceDelegate) {
        [self.twinmeContext removeDelegate:self.twinmeServiceDelegate];
        self.twinmeServiceDelegate = nil;
    }
}

- (void)initSections {
    DDLogVerbose(@"%@ initSections", LOG_TAG);
    
    self.sections = [[NSMutableArray alloc] init];
    [self.sections addObject:[[UIDiagnosticSection alloc]initWithType:DiagnosticSectionTypeConnection]];
    [self.sections addObject:[[UIDiagnosticSection alloc]initWithType:DiagnosticSectionTypePermission]];
    [self.sections addObject:[[UIDiagnosticSection alloc]initWithType:DiagnosticSectionTypePush]];
    
    AVAuthorizationStatus cameraAuthorizationStatus = [DeviceAuthorization deviceCameraAuthorizationStatus];
    switch (cameraAuthorizationStatus) {
        case AVAuthorizationStatusNotDetermined: {
            [self updatePermission:DiagnosticItemTypePermissionCamera status:DiagnosticItemStateUnknown];
            break;
        }
        case AVAuthorizationStatusRestricted:
        case AVAuthorizationStatusDenied: {
            [self updatePermission:DiagnosticItemTypePermissionCamera status:DiagnosticItemStateKO];
            break;
        }
        case AVAuthorizationStatusAuthorized: {
            [self updatePermission:DiagnosticItemTypePermissionCamera status:DiagnosticItemStateOK];
            break;
        }
    }
    
    AVAudioSessionRecordPermission audioSessionRecordPermission = [DeviceAuthorization deviceMicrophonePermissionStatus];
    switch (audioSessionRecordPermission) {
        case AVAudioSessionRecordPermissionUndetermined: {
            [self updatePermission:DiagnosticItemTypePermissionMicro status:DiagnosticItemStateUnknown];
            break;
        }
            
        case AVAudioSessionRecordPermissionDenied: {
            [self updatePermission:DiagnosticItemTypePermissionMicro status:DiagnosticItemStateKO];
            break;
        }
            
        case AVAudioSessionRecordPermissionGranted: {
            [self updatePermission:DiagnosticItemTypePermissionMicro status:DiagnosticItemStateOK];
            break;
        }
    }
    
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings *settings){
        switch(settings.authorizationStatus) {
            case UNAuthorizationStatusNotDetermined: {
                [self updatePermission:DiagnosticItemTypePermissionNotification status:DiagnosticItemStateUnknown];
                break;
            }
            case UNAuthorizationStatusDenied: {
                [self updatePermission:DiagnosticItemTypePermissionNotification status:DiagnosticItemStateKO];
                break;
            }
            case UNAuthorizationStatusAuthorized:
            case UNAuthorizationStatusProvisional:
            case UNAuthorizationStatusEphemeral: {
                [self updatePermission:DiagnosticItemTypePermissionNotification status:DiagnosticItemStateOK];
                break;
            }
        };
    }];
    
    CLAuthorizationStatus locationPermission = [DeviceAuthorization deviceLocationAuthorizationStatus];
    switch (locationPermission) {
        case kCLAuthorizationStatusNotDetermined:
            [self updatePermission:DiagnosticItemTypePermissionLocation status:DiagnosticItemStateUnknown];
            break;
            
        case kCLAuthorizationStatusDenied:
        case kCLAuthorizationStatusRestricted:
            [self updatePermission:DiagnosticItemTypePermissionLocation status:DiagnosticItemStateKO];
            break;
            
        case kCLAuthorizationStatusAuthorizedAlways:
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            [self updatePermission:DiagnosticItemTypePermissionLocation status:DiagnosticItemStateOK];
            break;
    }
    
    [self updateConnection:self.twinmeContext.connectionStatus];
    [self updateNotifications];
}

- (void)updateConnection:(TLConnectionStatus)connectionStatus {
    DDLogVerbose(@"%@ updateConnection: %ld", LOG_TAG, (long)connectionStatus);
    
    for (UIDiagnosticSection *section in self.sections) {
        if (section.sectionType == DiagnosticSectionTypeConnection) {
            for (UIDiagnosticItem *item in section.items) {
                if (item.diagnosticItemType == DiagnosticItemTypeConnection) {
                    
                    switch (connectionStatus) {
                        case TLConnectionStatusConnected:
                            item.title = TwinmeLocalizedString(@"application_connected", nil);
                            item.diagnosticItemState = DiagnosticItemStateOK;
                            
                            if ([[self.twinmeContext getConnectivityService] isMobileConnected]) {
                                item.subTitle = TwinmeLocalizedString(@"diagnostics_view_cellular_network", nil);
                            } else if ([[self.twinmeContext getConnectivityService] isWifiConnected]) {
                                item.subTitle = TwinmeLocalizedString(@"diagnostics_view_wifi", nil);
                            } else {
                                item.subTitle = @"";
                            }
                            
                            break;
                            
                        case TLConnectionStatusConnecting:
                            item.title = TwinmeLocalizedString(@"application_not_connected", nil);
                            item.subTitle = @"";
                            item.diagnosticItemState = DiagnosticItemStateUnknown;
                            break;
                            
                        case TLConnectionStatusNoInternet:
                            item.title = TwinmeLocalizedString(@"application_connection_status_no_network", nil);
                            item.subTitle = TwinmeLocalizedString(@"application_connection_status_no_network_message", nil);
                            item.diagnosticItemState = DiagnosticItemStateKO;
                            break;
        
                        case TLConnectionStatusNoService:
                        case TLConnectionStatusDisconnecting:
                            item.title = TwinmeLocalizedString(@"application_connection_status_no_services", nil);
                            item.subTitle = TwinmeLocalizedString(@"application_connection_status_no_services_message", nil);
                            item.diagnosticItemState = DiagnosticItemStateKO;
                            break;
                            
                        default:
                            break;
                    }
                                        
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self updateDiagnosticItemCell:item inSection:section];
                    });
                    break;
                }
            }
            break;
        }
    }
}

- (void)updatePermission:(DiagnosticItemType)permissionType status:(DiagnosticItemState)state {
    DDLogVerbose(@"%@ updatePermission: %ld status: %ld", LOG_TAG, (long)permissionType, (long)state);
    
    for (UIDiagnosticSection *section in self.sections) {
        if (section.sectionType == DiagnosticSectionTypePermission) {
            for (UIDiagnosticItem *item in section.items) {
                if (item.diagnosticItemType == permissionType) {
                    item.diagnosticItemState = state;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self updateDiagnosticItemCell:item inSection:section];
                    });
                    break;
                }
            }
            break;
        }
    }
}

- (void)updateNotifications {
    DDLogVerbose(@"%@ updateNotifications", LOG_TAG);
    
    for (UIDiagnosticSection *section in self.sections) {
        if (section.sectionType == DiagnosticSectionTypePush) {
            for (UIDiagnosticItem *item in section.items) {
                if (item.diagnosticItemType == DiagnosticItemTypePush) {
                    if ([[self.twinmeContext getManagementService] hasPushNotification]) {
                        item.diagnosticItemState = DiagnosticItemStateOK;
                        item.subTitle = TwinmeLocalizedString(@"diagnostics_view_available", nil);
                    } else {
                        item.diagnosticItemState = DiagnosticItemStateKO;
                        item.subTitle = TwinmeLocalizedString(@"diagnostics_view_unavailable", nil);
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self updateDiagnosticItemCell:item inSection:section];
                    });
                    break;
                }
            }
            break;
        }
    }
}

- (void)updateDiagnosticItemCell:(UIDiagnosticItem *)item inSection:(UIDiagnosticSection *)section {
    DDLogVerbose(@"%@ updateDiagnosticItemCell: %@ inSection: %@", LOG_TAG, item, section);
    
    NSUInteger row = [section.items indexOfObject:item];
    NSUInteger sectionIndex = [self.sections indexOfObject:section];
    if (row == NSNotFound || sectionIndex == NSNotFound) {
        return;
    }
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:sectionIndex];
    DiagnosticCell *diagnosticCell = [self.tableView cellForRowAtIndexPath:indexPath];
    [diagnosticCell bind:item];
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    [self.tableView reloadData];
}

@end
