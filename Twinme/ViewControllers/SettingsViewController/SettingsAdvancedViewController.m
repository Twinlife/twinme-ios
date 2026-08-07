/*
 *  Copyright (c) 2025-2026 twinlife SA.
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
#import <TwinmeCommon/SettingsSectionHeaderCell.h>

#import <Utils/NSString+Utils.h>

#import "SettingsAdvancedViewController.h"
#import "MessageSettingsViewController.h"
#import "AddProxyViewController.h"
#import "ProxyViewController.h"
#import "DebugSettingsViewController.h"

#import "SettingsItemCell.h"
#import "SettingsInformationCell.h"
#import "TwinmeSettingsItemCell.h"
#import "ProxyCell.h"
#import "ConnexionStatusCell.h"
#import "SettingsValueItemCell.h"

#import "SwitchView.h"
#import "AlertMessageView.h"
#import "MenuSelectValueView.h"
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
static NSString *SETTINGS_VALUE_CELL_IDENTIFIER = @"SettingsValueCellIdentifier";
static NSString *PROXY_CELL_IDENTIFIER = @"ProxyCellIdentifier";

//
// Interface: SettingsAdvancedViewController ()
//

@interface SettingsAdvancedViewController () <SettingsActionDelegate, AlertMessageViewDelegate, AbstractTwinmeDelegate, MenuSelectValueDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic) NSMutableArray *proxies;

@property (nonatomic, nullable) AbstractTwinmeService *twinmeService;
@property (nonatomic, nullable) AbstractTwinmeContextDelegate *twinmeServiceDelegate;

@end

typedef enum {
    SECTION_CONNEXION_STATUS,
    SECTION_PROXIES,
    SECTION_SECURITY,
    SECTION_CONVERSATIONS,
    SECTION_DEBUG,
    SECTION_COUNT
} SettingAdvancedSection;

static const int PROXY_SWITCH_TAG = 0;
static const int LINK_SWITCH_TAG = 1;
static const int MAP_SWITCH_TAG = 2;

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
    
    if (updatedSwitch.tag == PROXY_SWITCH_TAG) {
        [[self.twinmeContext getConnectivityService] saveWithProxyEnabled:updatedSwitch.isOn];
    } else if (updatedSwitch.tag == LINK_SWITCH_TAG || updatedSwitch.tag == MAP_SWITCH_TAG) {
        if (self.twinmeApplication.iceTransportMode == TLPeerConnectionServiceIceTransportModeRelay) {
            AlertMessageView *alertMessageView = [[AlertMessageView alloc] init];
            alertMessageView.alertMessageViewDelegate = self;
            [alertMessageView initWithTitle:TwinmeLocalizedString(@"settings_advanced_view_security_title", nil) message:TwinmeLocalizedString(@"settings_advanced_view_security_unauthorized_update", nil)];
            [self.navigationController.view addSubview:alertMessageView];
            [alertMessageView showAlertView];
        } else if (updatedSwitch.tag == LINK_SWITCH_TAG) {
            [self.twinmeApplication setVisualizationLinkWithState:updatedSwitch.isOn];
        } else {
            [self.twinmeApplication setVisualizationMapWithState:updatedSwitch.isOn];
        }
    }
}

#pragma mark - MenuSelectValueDelegate

- (void)selectValue:(MenuSelectValueView *)menuSelectValueView value:(int)value {
    DDLogVerbose(@"%@ selectValue: %d", LOG_TAG, value);

    [menuSelectValueView removeFromSuperview];
    
    [self.twinmeApplication setIceTransportModeWithMode:value];
    [self.twinmeService updateIceTransportMode:value];
    
    if (value == TLPeerConnectionServiceIceTransportModeRelay) {
        [self.twinmeApplication setVisualizationLinkWithState:NO];
        [self.twinmeApplication setVisualizationMapWithState:NO];
    }
    
    [self.tableView reloadData];
}

- (void)cancelMenuSelectValue:(MenuSelectValueView *)menuSelectValueView {
    DDLogVerbose(@"%@ cancelMenuSelectValue: %@", LOG_TAG, menuSelectValueView);
    
    [menuSelectValueView removeFromSuperview];
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
            sectionName = TwinmeLocalizedString(@"settings_advanced_view_status_connection_title", nil);
            break;
            
        case SECTION_PROXIES:
            sectionName = TwinmeLocalizedString(@"proxy_view_title", nil);
            hideSeparator = YES;
            break;
            
        case SECTION_SECURITY:
            sectionName = TwinmeLocalizedString(@"settings_advanced_view_security_title", nil);
            break;
            
        case SECTION_CONVERSATIONS:
            sectionName = TwinmeLocalizedString(@"conversations_view_title", nil);
            break;
            
        case SECTION_DEBUG:
            sectionName = TwinmeLocalizedString(@"settings_advanced_view_debug", nil);
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
        case SECTION_SECURITY:
            numberOfRowsInSection = 2;
            break;
            
        case SECTION_CONVERSATIONS:
            numberOfRowsInSection = 3;
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
            text = TwinmeLocalizedString(@"settings_advanced_view_status_connection_message", nil);
        } else if (indexPath.section == SECTION_PROXIES) {
            if (self.proxies.count > 0) {
                text = TwinmeLocalizedString(@"proxy_view_list_information", nil);
            } else {
                text = TwinmeLocalizedString(@"proxy_view_information", nil);
            }
        } else if (indexPath.section == SECTION_SECURITY) {
            text = TwinmeLocalizedString(@"settings_advanced_view_security_info", nil);
        } else if (indexPath.section == SECTION_CONVERSATIONS) {
            text = TwinmeLocalizedString(@"settings_advanced_view_conversation_info", nil);
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
            case TLConnectionStatusDisconnecting:
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
                        
            [cell bindWithTitle:TwinmeLocalizedString(@"proxy_view_enable", nil) subTitle:nil icon:nil stateSwitch:[[self.twinmeContext getConnectivityService] isProxyEnabled] tagSwitch:PROXY_SWITCH_TAG hiddenSwitch:NO disableSwitch:self.proxies.count == 0 backgroundColor:Design.WHITE_COLOR hiddenSeparator:NO];
            
            return cell;
        } else if (indexPath.row == self.proxies.count + 2) {
            TwinmeSettingsItemCell *cell = [tableView dequeueReusableCellWithIdentifier:TWINME_SETTINGS_CELL_IDENTIFIER];
            if (!cell) {
                cell = [[TwinmeSettingsItemCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:TWINME_SETTINGS_CELL_IDENTIFIER];
            }
            
            [cell bindWithTitle:TwinmeLocalizedString(@"proxy_view_add", nil) hiddenAccessory:NO disableSetting:NO color:Design.FONT_COLOR_DEFAULT];
            
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
    } else if (indexPath.section == SECTION_SECURITY) {
        SettingsValueItemCell *cell = [tableView dequeueReusableCellWithIdentifier:SETTINGS_VALUE_CELL_IDENTIFIER];
        if (!cell) {
            cell = [[SettingsValueItemCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:SETTINGS_VALUE_CELL_IDENTIFIER];
        }
        
        NSString *value;
        switch (self.twinmeApplication.iceTransportMode) {
            case TLPeerConnectionServiceIceTransportModeAll:
                value = TwinmeLocalizedString(@"settings_advanced_view_security_optimized", nil);
                break;
                
            case TLPeerConnectionServiceIceTransportModeTurns:
                value = TwinmeLocalizedString(@"settings_advanced_view_security_advanced", nil);
                break;
                
            case TLPeerConnectionServiceIceTransportModeRelay:
                value = TwinmeLocalizedString(@"settings_advanced_view_security_expert", nil);
                break;
                
            default:
                value = @"";
                break;
        }
        
        [cell bindWithTitle:TwinmeLocalizedString(@"settings_advanced_view_security_level_title", nil) value:value icon:nil backgroundColor:Design.WHITE_COLOR];
        return cell;
        
    } else if (indexPath.section == SECTION_CONVERSATIONS) {
        SettingsItemCell *cell = [tableView dequeueReusableCellWithIdentifier:SETTINGS_CELL_IDENTIFIER];
        if (!cell) {
            cell = [[SettingsItemCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:SETTINGS_CELL_IDENTIFIER];
        }
        
        cell.settingsActionDelegate = self;
        
        NSString *title = @"";
        NSString *subTitle = @"";
        BOOL stateSwitch = NO;
        int tagSwitch = 0;
        if (indexPath.row == 1) {
            title = TwinmeLocalizedString(@"conversation_settings_view_link_title", nil);
            subTitle = TwinmeLocalizedString(@"conversation_settings_view_link_preview_message", nil);
            stateSwitch = [self.twinmeApplication visualizationLink];
            tagSwitch = LINK_SWITCH_TAG;
        } else {
            title = TwinmeLocalizedString(@"settings_view_show_maps", nil);
            subTitle = TwinmeLocalizedString(@"settings_view_show_location_on_map", nil);
            stateSwitch = [self.twinmeApplication visualizationMap];
            tagSwitch = MAP_SWITCH_TAG;
        }
                    
        [cell bindWithTitle:title subTitle:subTitle icon:nil stateSwitch:stateSwitch tagSwitch:tagSwitch hiddenSwitch:NO disableSwitch:self.twinmeApplication.iceTransportMode == TLPeerConnectionServiceIceTransportModeRelay backgroundColor:Design.WHITE_COLOR hiddenSeparator:NO];
        
        return cell;
    } else {
        TwinmeSettingsItemCell *cell = [tableView dequeueReusableCellWithIdentifier:TWINME_SETTINGS_CELL_IDENTIFIER];
        if (!cell) {
            cell = [[TwinmeSettingsItemCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:TWINME_SETTINGS_CELL_IDENTIFIER];
        }
        
        [cell bindWithTitle:TwinmeLocalizedString(@"settings_advanced_view_developer_settings", nil) hiddenAccessory:NO disableSetting:NO color:Design.FONT_COLOR_DEFAULT];
        
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
            [alertMessageView initWithTitle:TwinmeLocalizedString(@"deleted_account_view_warning", nil) message:[NSString stringWithFormat:TwinmeLocalizedString(@"proxy_view_limit", nil), [TLConnectivityService MAX_PROXIES]]];
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
    } else if (indexPath.section == SECTION_SECURITY && indexPath.row == 1) {
        [self openMenuSecurityLevel];
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
    
    [self setNavigationTitle:TwinmeLocalizedString(@"settings_advanced_view_title", nil)];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = Design.SETTING_CELL_HEIGHT * Design.HEIGHT_RATIO;
    [self.tableView registerNib:[UINib nibWithNibName:@"SettingsItemCell" bundle:nil] forCellReuseIdentifier:SETTINGS_CELL_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"SettingsSectionHeaderCell" bundle:nil] forCellReuseIdentifier:HEADER_SETTINGS_CELL_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"SettingsInformationCell" bundle:nil] forCellReuseIdentifier:SETTINGS_INFORMATION_CELL_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"TwinmeSettingsItemCell" bundle:nil] forCellReuseIdentifier:TWINME_SETTINGS_CELL_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"ConnexionStatusCell" bundle:nil] forCellReuseIdentifier:CONNEXION_STATUS_CELL_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"ProxyCell" bundle:nil] forCellReuseIdentifier:PROXY_CELL_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"SettingsValueItemCell" bundle:nil] forCellReuseIdentifier:SETTINGS_VALUE_CELL_IDENTIFIER];

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

- (void)openMenuSecurityLevel {
    DDLogVerbose(@"%@ openMenuSecurityLevel", LOG_TAG);
    
    MenuSelectValueView *menuSelectValueView = [[MenuSelectValueView alloc]init];
    menuSelectValueView.menuSelectValueDelegate = self;
    [self.tabBarController.view addSubview:menuSelectValueView];
    [menuSelectValueView setMenuSelectValueTypeWithType:MenuSelectValueTypeSecurityLevel defaultValue:(int)self.twinmeApplication.iceTransportMode];
    [menuSelectValueView openMenu];
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
    
    if (indexPath.section != SECTION_DEBUG && indexPath.row == 0) {
        return YES;
    }
    
    return NO;
}

@end
