/*
 *  Copyright (c) 2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <Twinme/TLTwinmeContext.h>
#import <Twinlife/TLConnectivityService.h>
#import <Twinlife/TLProxyDescriptor.h>

#import <TwinmeCommon/AbstractTwinmeService.h>
#import <TwinmeCommon/AbstractTwinmeService+Protected.h>
#import <TwinmeCommon/Design.h>

#import <Utils/NSString+Utils.h>

#import "SettingsAdvancedViewController.h"
#import "MessageSettingsViewController.h"
#import "AddProxyViewController.h"
#import "ProxyViewController.h"
#import "DebugSettingsViewController.h"

#import "SettingsItemCell.h"
#import "SettingsSectionHeaderCell.h"
#import "SettingsInformationCell.h"
#import "TwinmeSettingsItemCell.h"
#import "ProxyCell.h"
#import "ConnexionStatusCell.h"

#import "SwitchView.h"
#import "AlertMessageView.h"
#import "UIAppInfo.h"

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static NSString *SETTINGS_CELL_IDENTIFIER = @"SettingsCellIdentifier";
static NSString *HEADER_SETTINGS_CELL_IDENTIFIER = @"HeaderSettingsCellIdentifier";
static NSString *SETTINGS_INFORMATION_CELL_IDENTIFIER = @"SettingsInformationCellIdentifier";
static NSString *TWINME_SETTINGS_CELL_IDENTIFIER = @"TwinmeSettingsCellIdentifier";
static NSString *CONNEXION_STATUS_CELL_IDENTIFIER = @"ConnexionStatusCellIdentifier";
static NSString *PROXY_CELL_IDENTIFIER = @"ProxyCellIdentifier";

//
// Interface: SettingsAdvancedViewController ()
//

@interface SettingsAdvancedViewController () <SettingsActionDelegate, AlertMessageViewDelegate, AbstractTwinmeDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic) NSMutableArray *proxies;

@property (nonatomic, nullable) AbstractTwinmeService *twinmeService;
@property (nonatomic, nullable) AbstractTwinmeContextDelegate *twinmeServiceDelegate;

@end

typedef enum {
    SECTION_CONNEXION_STATUS,
    SECTION_PROXIES,
    SECTION_DEBUG,
    SECTION_COUNT
} SettingAdvancedSection;

//
// Implementation: SettingsAdvancedViewController
//

#undef LOG_TAG
#define LOG_TAG @"SettingsAdvancedViewController"

@implementation SettingsAdvancedViewController

- (instancetype)initWithCoder:(NSCoder *)coder {
    DDLogVerbose(@"%@ initWithCoder: %@", LOG_TAG, coder);
    
    self = [super initWithCoder:coder];
    
    if (self) {
        _proxies = [[NSMutableArray alloc]init];
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
    
    [self reloadData];
}

#pragma mark - AbstractTwinmeServiceDelegate

- (void)onConnectionStatusChange:(TLConnectionStatus)connectionStatus {
    DDLogVerbose(@"%@ onConnectionStatusChange: %u", LOG_TAG, connectionStatus);
    
    [self reloadData];
}

#pragma mark - SettingsActionDelegate

- (void)switchChangeValue:(SwitchView *)updatedSwitch {
    DDLogVerbose(@"%@ switchChangeValue: %@", LOG_TAG, updatedSwitch);
    
    [[self.twinmeContext getConnectivityService] saveWithProxyEnabled:updatedSwitch.isOn];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    DDLogVerbose(@"%@ numberOfSectionsInTableView: %@", LOG_TAG, tableView);
    
    #if defined(DEBUG) && DEBUG == 1
        return SECTION_COUNT;
    #endif
    
    return SECTION_COUNT - 1;
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
    BOOL hideSeparator = YES;
    switch (section) {
        case SECTION_CONNEXION_STATUS:
            sectionName = TwinmeLocalizedString(@"settings_advanced_view_controller_status_connection_title", nil);
            break;
            
        case SECTION_PROXIES:
            sectionName = TwinmeLocalizedString(@"proxy_view_controller_title", nil);
            hideSeparator = YES;
            break;
            
        case SECTION_DEBUG:
            sectionName = TwinmeLocalizedString(@"settings_advanced_view_controller_debug", nil);
            break;
            
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
        case SECTION_CONNEXION_STATUS:
            numberOfRowsInSection = 2;
            break;
            
        case SECTION_PROXIES:
            numberOfRowsInSection = 3 + self.proxies.count;
            break;
            
        case SECTION_DEBUG:
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
    
    if ([self isInformationPath:indexPath]) {
        SettingsInformationCell *cell = [tableView dequeueReusableCellWithIdentifier:SETTINGS_INFORMATION_CELL_IDENTIFIER];
        if (!cell) {
            cell = [[SettingsInformationCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:SETTINGS_INFORMATION_CELL_IDENTIFIER];
        }
        
        NSString *text = @"";
        if (indexPath.section == SECTION_CONNEXION_STATUS) {
            text = TwinmeLocalizedString(@"settings_advanced_view_controller_status_connection_message", nil);
        } else if (indexPath.section == SECTION_PROXIES) {
            if (self.proxies.count > 0) {
                text = TwinmeLocalizedString(@"proxy_view_controller_list_information", nil);
            } else {
                text = TwinmeLocalizedString(@"proxy_view_controller_information", nil);
            }
        }
        
        [cell bindWithText:text];
        
        return cell;
    } else if (indexPath.section == SECTION_CONNEXION_STATUS) {
        ConnexionStatusCell *cell = [tableView dequeueReusableCellWithIdentifier:CONNEXION_STATUS_CELL_IDENTIFIER];
        if (!cell) {
            cell = [[ConnexionStatusCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CONNEXION_STATUS_CELL_IDENTIFIER];
        }
        
        UIAppInfo *uiAppInfo = nil;
        switch (self.twinmeContext.connectionStatus) {
            case TLConnectionStatusConnected:
                uiAppInfo = [[UIAppInfo alloc]initWithInfoType:InfoFloatingViewTypeConnected];
                break;
                
            case TLConnectionStatusNoInternet:
                uiAppInfo = [[UIAppInfo alloc]initWithInfoType:InfoFloatingViewTypeOffline];
                break;
                
            case TLConnectionStatusNoService:
                uiAppInfo = [[UIAppInfo alloc]initWithInfoType:InfoFloatingViewTypeNoServices];
                break;
                
            case TLConnectionStatusConnecting:
                uiAppInfo = [[UIAppInfo alloc]initWithInfoType:InfoFloatingViewTypeConnectionInProgress];
                break;
                
            default:
                break;
        }
        
        TLProxyDescriptor *currentProxy = [[self.twinmeContext getConnectivityService] currentProxyDescriptor];
        [cell bind:uiAppInfo proxy:currentProxy && currentProxy.isUserProxy ? currentProxy.host : nil];
        
        return cell;
    } else if (indexPath.section == SECTION_PROXIES) {
        if (indexPath.row == 1) {
            SettingsItemCell *cell = [tableView dequeueReusableCellWithIdentifier:SETTINGS_CELL_IDENTIFIER];
            if (!cell) {
                cell = [[SettingsItemCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:SETTINGS_CELL_IDENTIFIER];
            }
            
            cell.settingsActionDelegate = self;
                        
            [cell bindWithTitle:TwinmeLocalizedString(@"proxy_view_controller_enable", nil) icon:nil stateSwitch:[[self.twinmeContext getConnectivityService] isProxyEnabled] tagSwitch:0 hiddenSwitch:NO disableSwitch:self.proxies.count == 0 backgroundColor:Design.WHITE_COLOR hiddenSeparator:NO];
            
            return cell;
        } else if (indexPath.row == self.proxies.count + 2) {
            TwinmeSettingsItemCell *cell = [tableView dequeueReusableCellWithIdentifier:TWINME_SETTINGS_CELL_IDENTIFIER];
            if (!cell) {
                cell = [[TwinmeSettingsItemCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:TWINME_SETTINGS_CELL_IDENTIFIER];
            }
            
            [cell bindWithTitle:TwinmeLocalizedString(@"proxy_view_controller_add", nil) hiddenAccessory:NO disableSetting:NO color:Design.FONT_COLOR_DEFAULT];
            
            return cell;
        } else {
            ProxyCell *cell = [tableView dequeueReusableCellWithIdentifier:PROXY_CELL_IDENTIFIER];
            if (!cell) {
                cell = [[ProxyCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:PROXY_CELL_IDENTIFIER];
            }
            
            TLProxyDescriptor *proxyDescriptor = self.proxies[indexPath.row - 2];
            [cell bindWithProxy:proxyDescriptor.proxyDescription showError:proxyDescriptor.proxyStatus != TLConnectionErrorNone hideSeparator:NO];
            
            return cell;
        }
    } else {
        TwinmeSettingsItemCell *cell = [tableView dequeueReusableCellWithIdentifier:TWINME_SETTINGS_CELL_IDENTIFIER];
        if (!cell) {
            cell = [[TwinmeSettingsItemCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:TWINME_SETTINGS_CELL_IDENTIFIER];
        }
        
        [cell bindWithTitle:TwinmeLocalizedString(@"settings_advanced_view_controller_developers_settings", nil) hiddenAccessory:NO disableSetting:NO color:Design.FONT_COLOR_DEFAULT];
        
        return cell;
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ didSelectRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    if (indexPath.section == SECTION_PROXIES  && indexPath.row > 1) {
        
        if (indexPath.row == self.proxies.count + 2 && self.proxies.count >= [TLConnectivityService MAX_PROXIES]) {
            AlertMessageView *alertMessageView = [[AlertMessageView alloc] init];
            alertMessageView.alertMessageViewDelegate = self;
            [alertMessageView initWithTitle:TwinmeLocalizedString(@"delete_account_view_controller_warning", nil) message:[NSString stringWithFormat:TwinmeLocalizedString(@"proxy_view_controller_limit", nil), [TLConnectivityService MAX_PROXIES]]];
            [self.navigationController.view addSubview:alertMessageView];
            [alertMessageView showAlertView];
            return;
        }
        
        if (indexPath.row == self.proxies.count + 2) {
            AddProxyViewController *addProxyViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AddProxyViewController"];
            [self.navigationController pushViewController:addProxyViewController animated:YES];
        } else {
            ProxyViewController *proxyViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ProxyViewController"];
            proxyViewController.proxyPosition = (int) (indexPath.row - 2);
            [self.navigationController pushViewController:proxyViewController animated:YES];
        }
    } else if (indexPath.section == SECTION_DEBUG) {
        DebugSettingsViewController *debugSettingsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"DebugSettingsViewController"];
        [self.navigationController pushViewController:debugSettingsViewController animated:YES];
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

#pragma mark - Private methods

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    self.view.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
    
    [self setNavigationTitle:TwinmeLocalizedString(@"settings_advanced_view_controller_title", nil)];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = Design.SETTING_CELL_HEIGHT * Design.HEIGHT_RATIO;
    [self.tableView registerNib:[UINib nibWithNibName:@"SettingsItemCell" bundle:nil] forCellReuseIdentifier:SETTINGS_CELL_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"SettingsSectionHeaderCell" bundle:nil] forCellReuseIdentifier:HEADER_SETTINGS_CELL_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"SettingsInformationCell" bundle:nil] forCellReuseIdentifier:SETTINGS_INFORMATION_CELL_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"TwinmeSettingsItemCell" bundle:nil] forCellReuseIdentifier:TWINME_SETTINGS_CELL_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"ConnexionStatusCell" bundle:nil] forCellReuseIdentifier:CONNEXION_STATUS_CELL_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"ProxyCell" bundle:nil] forCellReuseIdentifier:PROXY_CELL_IDENTIFIER];
    
    self.tableView.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
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

- (void)reloadData {
    DDLogVerbose(@"%@ reloadData", LOG_TAG);
    
    self.proxies = [[self.twinmeContext getConnectivityService] getUserProxies];
    
    if (self.proxies.count == 0 && [[self.twinmeContext getConnectivityService] isProxyEnabled]) {
        [[self.twinmeContext getConnectivityService] saveWithProxyEnabled:NO];
    }
    
    [self.tableView reloadData];
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    self.tableView.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    [self.tableView reloadData];
}

- (BOOL)isInformationPath:(NSIndexPath *)indexPath {
    
    if ((indexPath.section == SECTION_CONNEXION_STATUS || indexPath.section == SECTION_PROXIES) && indexPath.row == 0) {
        return YES;
    }
    
    return NO;
}

@end
