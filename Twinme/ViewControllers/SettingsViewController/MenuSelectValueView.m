/*
 *  Copyright (c) 2022 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <Twinme/TLCapabilities.h>

#import <Utils/NSString+Utils.h>

#import "MenuSelectValueView.h"
#import "SelectValueCell.h"
#import "MessageSettingsViewController.h"

#import "TimeoutCell.h"
#import "UITimeout.h"
#import "UIConfigExternalCall.h"
#import "ColorCell.h"
#import "UIMenuSelectValueItem.h"

#import <TwinmeCommon/Design.h>
#import <TwinmeCommon/UIViewController+Utils.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static NSString *SELECT_VALUE_CELL_IDENTIFIER = @"SelectValueCellIdentifier";
static NSString *TIMEOUT_CELL_IDENTIFIER = @"TimeoutCellIdentifier";

static const CGFloat TYPE_EXTERNAL_CALL_HEIGHT = 180;
static const CGFloat MIN_HEIGHT = 132;

//
// Interface: MenuSelectValueView ()
//

@interface MenuSelectValueView ()<CAAnimationDelegate, UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewBottomConstraint;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic) int selectedValue;
@property (nonatomic) NSMutableArray *uiTimeouts;
@property (nonatomic) NSMutableArray<UIMenuSelectValueItem *> *items;

@end

//
// Implementation: MenuSelectValueView
//

#undef LOG_TAG
#define LOG_TAG @"MenuSelectValueView"

@implementation MenuSelectValueView

#pragma mark - UIView

- (instancetype)init {
    DDLogVerbose(@"%@ init", LOG_TAG);
    
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"MenuSelectValueView" owner:self options:nil];
    self = [objects objectAtIndex:0];
    
    self.frame = CGRectMake(0, 0, Design.DISPLAY_WIDTH, Design.DISPLAY_HEIGHT);
    self.menuSelectValueType = MenuSelectValueTypeQualityMedia;
    
    if (self) {
        [self initViews];
    }
    return self;
}

- (void)setSelectedValueWithValue:(int)value {
    DDLogVerbose(@"%@ setSelectedValueWithValue: %d", LOG_TAG, value);
    
    self.selectedValue = value;
    
    [self reloadData];
}

- (void)initTimeout {
    DDLogVerbose(@"%@ initTimeout", LOG_TAG);
    
    self.uiTimeouts = [[NSMutableArray alloc]init];
    
    int64_t oneMinute = 60;
    int64_t oneHour = oneMinute * 60;
    int64_t oneDay = oneHour * 24;
    int64_t oneWeek = oneDay * 7;
    int64_t oneMonth = oneDay * 30;
    
    if (self.menuSelectValueType == MenuSelectValueTypeTimeoutLockScreen) {
        [self.uiTimeouts addObject:[[UITimeout alloc]initWithTitle:[NSString formatTimeout:0] timeout:0]];
        [self.uiTimeouts addObject:[[UITimeout alloc]initWithTitle:[NSString formatTimeout:oneMinute] timeout:oneMinute]];
        [self.uiTimeouts addObject:[[UITimeout alloc]initWithTitle:[NSString formatTimeout:oneMinute * 5] timeout:oneMinute * 5]];
        [self.uiTimeouts addObject:[[UITimeout alloc]initWithTitle:[NSString formatTimeout:oneMinute * 15] timeout:oneMinute * 15]];
        [self.uiTimeouts addObject:[[UITimeout alloc]initWithTitle:[NSString formatTimeout:oneMinute * 30] timeout:oneMinute * 30]];
        [self.uiTimeouts addObject:[[UITimeout alloc]initWithTitle:[NSString formatTimeout:oneHour] timeout:oneHour]];
        [self.uiTimeouts addObject:[[UITimeout alloc]initWithTitle:[NSString formatTimeout:oneHour * 4] timeout:oneHour * 4]];
    } else if (self.menuSelectValueType == MenuSelectValueTypeTimeoutEphemeralMessage) {
        [self.uiTimeouts addObject:[[UITimeout alloc]initWithTitle:[NSString formatTimeout:5] timeout:5]];
        [self.uiTimeouts addObject:[[UITimeout alloc]initWithTitle:[NSString formatTimeout:10] timeout:10]];
        [self.uiTimeouts addObject:[[UITimeout alloc]initWithTitle:[NSString formatTimeout:30] timeout:30]];
        [self.uiTimeouts addObject:[[UITimeout alloc]initWithTitle:[NSString formatTimeout:oneMinute] timeout:oneMinute]];
        [self.uiTimeouts addObject:[[UITimeout alloc]initWithTitle:[NSString formatTimeout:oneMinute * 5] timeout:oneMinute * 5]];
        [self.uiTimeouts addObject:[[UITimeout alloc]initWithTitle:[NSString formatTimeout:oneMinute * 30] timeout:oneMinute * 30]];
        [self.uiTimeouts addObject:[[UITimeout alloc]initWithTitle:[NSString formatTimeout:oneHour] timeout:oneHour]];
        [self.uiTimeouts addObject:[[UITimeout alloc]initWithTitle:[NSString formatTimeout:oneDay] timeout:oneDay]];
        [self.uiTimeouts addObject:[[UITimeout alloc]initWithTitle:[NSString formatTimeout:oneWeek] timeout:oneWeek]];
        [self.uiTimeouts addObject:[[UITimeout alloc]initWithTitle:[NSString formatTimeout:oneMonth] timeout:oneMonth]];
    } else if (self.menuSelectValueType == MenuSelectValueTypeSilentModeDuration) {
        [self.uiTimeouts addObject:[[UITimeout alloc]initWithTitle:[NSString formatTimeout:oneHour] timeout:oneHour]];
        [self.uiTimeouts addObject:[[UITimeout alloc]initWithTitle:[NSString formatTimeout:oneHour * 8] timeout:oneHour * 8]];
        [self.uiTimeouts addObject:[[UITimeout alloc]initWithTitle:[NSString formatTimeout:oneHour * 24] timeout:oneHour * 24]];
        [self.uiTimeouts addObject:[[UITimeout alloc]initWithTitle:[NSString formatTimeout:oneWeek] timeout:oneWeek]];
        [self.uiTimeouts addObject:[[UITimeout alloc]initWithTitle:[NSString formatTimeout:-1] timeout:-1]];
    }
}

- (void)initItems {
    DDLogVerbose(@"%@ initItems", LOG_TAG);
    
    self.items = [[NSMutableArray alloc]init];
    
    if (self.menuSelectValueType == MenuSelectValueTypeQualityMedia) {
        [self.items addObject:[[UIMenuSelectValueItem alloc]initWithTitle:TwinmeLocalizedString(@"conversation_view_media_quality_standard", nil) subTitle:TwinmeLocalizedString(@"conversation_view_media_quality_standard_subtitle", nil)]];
        [self.items addObject:[[UIMenuSelectValueItem alloc]initWithTitle:TwinmeLocalizedString(@"conversation_view_media_quality_original", nil) subTitle:TwinmeLocalizedString(@"conversation_view_media_quality_original_subtitle", nil)]];
    } else if (self.menuSelectValueType == MenuSelectValueTypeDisplayCallsMode) {
        [self.items addObject:[[UIMenuSelectValueItem alloc]initWithTitle:TwinmeLocalizedString(@"settings_view_display_call_menu_none", nil) subTitle:nil]];
        [self.items addObject:[[UIMenuSelectValueItem alloc]initWithTitle:TwinmeLocalizedString(@"settings_view_display_call_menu_missed", nil) subTitle:nil]];
        [self.items addObject:[[UIMenuSelectValueItem alloc]initWithTitle:TwinmeLocalizedString(@"settings_view_call_item_menu_all", nil) subTitle:nil]];
    } else if (self.menuSelectValueType == MenuSelectValueTypeEditSpace) {
        [self.items addObject:[[UIMenuSelectValueItem alloc]initWithTitle:TwinmeLocalizedString(@"settings_space_view_space_category_title", nil) subTitle:nil]];
        [self.items addObject:[[UIMenuSelectValueItem alloc]initWithTitle:TwinmeLocalizedString(@"application_profile", nil) subTitle:nil]];
    } else if (self.menuSelectValueType == MenuSelectValueTypeProfileUpdateMode) {
        [self.items addObject:[[UIMenuSelectValueItem alloc]initWithTitle:TwinmeLocalizedString(@"edit_profile_view_propagating_no_contact", nil) subTitle:nil]];
        [self.items addObject:[[UIMenuSelectValueItem alloc]initWithTitle:TwinmeLocalizedString(@"edit_profile_view_propagating_except_contacts", nil) subTitle:nil]];
        [self.items addObject:[[UIMenuSelectValueItem alloc]initWithTitle:TwinmeLocalizedString(@"edit_profile_view_propagating_all_contacts", nil) subTitle:nil]];
    } else if (self.menuSelectValueType == MenuSelectValueTypeCallZoomable) {
        [self.items addObject:[[UIMenuSelectValueItem alloc]initWithTitle:TwinmeLocalizedString(@"contact_capabilities_view_camera_control_never", nil) subTitle:nil]];
        [self.items addObject:[[UIMenuSelectValueItem alloc]initWithTitle:TwinmeLocalizedString(@"contact_capabilities_view_camera_control_ask", nil) subTitle:nil]];
        [self.items addObject:[[UIMenuSelectValueItem alloc]initWithTitle:TwinmeLocalizedString(@"contact_capabilities_view_camera_control_allow", nil) subTitle:nil]];
    } else if (self.menuSelectValueType == MenuSelectValueTypeExternalCallType) {
        [self.items addObject:[[UIMenuSelectValueItem alloc]initWithTitle:TwinmeLocalizedString(@"create_external_call_view_direct_call_title", nil) subTitle:TwinmeLocalizedString(@"create_external_call_view_direct_call_description", nil)]];
        [self.items addObject:[[UIMenuSelectValueItem alloc]initWithTitle:TwinmeLocalizedString(@"create_external_call_view_conference_call_title", nil) subTitle:TwinmeLocalizedString(@"create_external_call_view_conference_call_description", nil)]];
    } else if (self.menuSelectValueType == MenuSelectValueTypeExternalCallExpiration) {
        [self.items addObject:[[UIMenuSelectValueItem alloc]initWithTitle:TwinmeLocalizedString(@"create_external_call_view_continuous_link_title", nil) subTitle:TwinmeLocalizedString(@"create_external_call_view_continuous_link_description", nil)]];
        [self.items addObject:[[UIMenuSelectValueItem alloc]initWithTitle:TwinmeLocalizedString(@"create_external_call_view_unique_link_title", nil) subTitle:TwinmeLocalizedString(@"create_external_call_view_unique_link_description", nil)]];
        [self.items addObject:[[UIMenuSelectValueItem alloc]initWithTitle:TwinmeLocalizedString(@"create_external_call_view_recurrent_link_title", nil) subTitle:TwinmeLocalizedString(@"create_external_call_view_recurrent_link_description", nil)]];
    } else if (self.menuSelectValueType == MenuSelectValueTypeSecurityLevel) {
        [self.items addObject:[[UIMenuSelectValueItem alloc]initWithTitle:TwinmeLocalizedString(@"settings_advanced_view_security_optimized", nil) subTitle:TwinmeLocalizedString(@"settings_advanced_view_security_optimized_info", nil)]];
        [self.items addObject:[[UIMenuSelectValueItem alloc]initWithTitle:TwinmeLocalizedString(@"settings_advanced_view_security_advanced", nil) subTitle:TwinmeLocalizedString(@"settings_advanced_view_security_advanced_info", nil)]];
        [self.items addObject:[[UIMenuSelectValueItem alloc]initWithTitle:TwinmeLocalizedString(@"settings_advanced_view_security_expert", nil) subTitle:TwinmeLocalizedString(@"settings_advanced_view_security_expert_info", nil)]];
    } else if (self.menuSelectValueType == MenuSelectValueTypeShareInvitation) {
        [self.items addObject:[[UIMenuSelectValueItem alloc]initWithTitle:TwinmeLocalizedString(@"contact_capabilities_view_camera_control_never", nil) subTitle:nil]];
        [self.items addObject:[[UIMenuSelectValueItem alloc]initWithTitle:TwinmeLocalizedString(@"privacy_view_share_invitation_ask", nil) subTitle:nil]];
        [self.items addObject:[[UIMenuSelectValueItem alloc]initWithTitle:TwinmeLocalizedString(@"contact_capabilities_view_camera_control_allow", nil) subTitle:nil]];
    }
}

- (void)setMenuSelectValueTypeWithType:(MenuSelectValueType)menuSelectValueType defaultValue:(int)defaultValue {
    DDLogVerbose(@"%@ setMenuSelectValueTypeWithType", LOG_TAG);
    
    self.menuSelectValueType = menuSelectValueType;
    
    BOOL isSelectTimeout = NO;
    switch (self.menuSelectValueType) {
        case MenuSelectValueTypeDisplayCallsMode:
        case MenuSelectValueTypeProfileUpdateMode:
        case MenuSelectValueTypeCallZoomable:
        case MenuSelectValueTypeExternalCallExpiration:
        case MenuSelectValueTypeSecurityLevel:
        case MenuSelectValueTypeShareInvitation:
        case MenuSelectValueTypeQualityMedia:
        case MenuSelectValueTypeEditSpace:
        case MenuSelectValueTypeExternalCallType:
            [self initItems];
            break;
            
        case MenuSelectValueTypeTimeoutLockScreen:
        case MenuSelectValueTypeTimeoutEphemeralMessage:
        case MenuSelectValueTypeSilentModeDuration:
            isSelectTimeout = YES;
            [self initTimeout];
            break;
        default:
            break;
    }
    
    CGFloat tableViewHeight = 0;
    if (isSelectTimeout) {
        tableViewHeight = self.uiTimeouts.count * Design.SETTING_CELL_HEIGHT;
    } else {
        CGFloat maxWidth = [SelectValueCell maxValueWidth];
        CGFloat minMargin = [SelectValueCell minMargin];
        for (UIMenuSelectValueItem *item in self.items) {
            [item calculateValueHeightWithMaxWidth:maxWidth margin:minMargin];
            tableViewHeight += item.valueHeight;
        }
    }
        
    self.tableViewHeightConstraint.constant = tableViewHeight;
    
    CGFloat maxHeight = (MIN_HEIGHT * Design.HEIGHT_RATIO) + tableViewHeight + Design.FONT_MEDIUM36.lineHeight;
    if (maxHeight > Design.DISPLAY_HEIGHT) {
        self.tableView.scrollEnabled = YES;
    } else {
        self.tableView.scrollEnabled = NO;
    }
    
    [self setupTitle];
    self.selectedValue = defaultValue;
    [self reloadData];
}

#pragma mark - UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ heightForRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    if (self.menuSelectValueType == MenuSelectValueTypeTimeoutLockScreen || self.menuSelectValueType == MenuSelectValueTypeTimeoutEphemeralMessage || self.menuSelectValueType == MenuSelectValueTypeSilentModeDuration) {
        return Design.SETTING_CELL_HEIGHT;
    } else {
        UIMenuSelectValueItem *item = [self.items objectAtIndex:indexPath.row];
        return item.valueHeight;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    DDLogVerbose(@"%@ numberOfSectionsInTableView: %@", LOG_TAG, tableView);
    
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ numberOfRowsInSection: %ld", LOG_TAG, tableView, (long)section);
    
    if (self.menuSelectValueType == MenuSelectValueTypeTimeoutLockScreen || self.menuSelectValueType == MenuSelectValueTypeTimeoutEphemeralMessage || self.menuSelectValueType == MenuSelectValueTypeSilentModeDuration) {
        return self.uiTimeouts.count;
    }
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ cellForRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    SelectValueCell *cell = [tableView dequeueReusableCellWithIdentifier:SELECT_VALUE_CELL_IDENTIFIER];
    if (!cell) {
        cell = [[SelectValueCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:SELECT_VALUE_CELL_IDENTIFIER];
    }
    
    NSString *title;
    NSString *subtitle = @"";
    BOOL checked = self.selectedValue == indexPath.row;
    BOOL hideSeparator = self.items.count == indexPath.row + 1;
    if (self.menuSelectValueType == MenuSelectValueTypeTimeoutLockScreen || self.menuSelectValueType == MenuSelectValueTypeTimeoutEphemeralMessage || self.menuSelectValueType == MenuSelectValueTypeSilentModeDuration) {
        UITimeout *uiTimeout = [self.uiTimeouts objectAtIndex:indexPath.row];
        hideSeparator = indexPath.row + 1 == self.uiTimeouts.count ? YES : NO;
        title = uiTimeout.title;
        checked = uiTimeout.timeout == self.selectedValue;
    } else {
        UIMenuSelectValueItem *item = [self.items objectAtIndex:indexPath.row];
        title = item.title;
        subtitle = item.subTitle;
    }
    
    cell.forceDarkMode = self.forceDarkMode;
    [cell bindWithTitle:title subTitle:subtitle checked:checked hideBorder:YES hideSeparator:hideSeparator];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ didSelectRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    if (self.menuSelectValueType == MenuSelectValueTypeTimeoutLockScreen || self.menuSelectValueType == MenuSelectValueTypeTimeoutEphemeralMessage || self.menuSelectValueType == MenuSelectValueTypeSilentModeDuration) {
        if ([self.menuSelectValueDelegate respondsToSelector:@selector(selectTimeout:uiTimeout:)]) {
            UITimeout *uiTimeout = [self.uiTimeouts objectAtIndex:indexPath.row];
            [self.menuSelectValueDelegate selectTimeout:self uiTimeout:uiTimeout];
        }
    } else {
        if ([self.menuSelectValueDelegate respondsToSelector:@selector(selectValue:value:)]) {
            [self.menuSelectValueDelegate selectValue:self value:(int)indexPath.row];
        }
    }
}

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    [super initViews];
    
    CGFloat safeAreaInset;
    UIWindow *window = [UIViewController currentWindow];
    if (window) {
        safeAreaInset = window.safeAreaInsets.bottom;
    } else {
        safeAreaInset = self.safeAreaInsets.bottom;
    }
    
    self.tableViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.tableViewBottomConstraint.constant = safeAreaInset;
    
    self.tableView.scrollEnabled = NO;
    self.tableView.backgroundColor = Design.POPUP_BACKGROUND_COLOR;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"SelectValueCell" bundle:nil] forCellReuseIdentifier:SELECT_VALUE_CELL_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"TimeoutCell" bundle:nil] forCellReuseIdentifier:TIMEOUT_CELL_IDENTIFIER];
}

- (void)setupTitle {
    DDLogVerbose(@"%@ setupTitle", LOG_TAG);
        
    switch (self.menuSelectValueType) {
        case MenuSelectValueTypeDisplayCallsMode:
            self.titleLabel.text = TwinmeLocalizedString(@"settings_view_display_call_title", nil);
            break;
            
        case MenuSelectValueTypeEditSpace:
            self.titleLabel.text = TwinmeLocalizedString(@"application_edit", nil);
            break;
            
        case MenuSelectValueTypeQualityMedia:
            self.titleLabel.text = TwinmeLocalizedString(@"conversation_view_media_quality_title", nil);
            break;
            
        case MenuSelectValueTypeProfileUpdateMode:
            self.titleLabel.text = TwinmeLocalizedString(@"edit_profile_view_propagating_profile", nil);
            break;
            
        case MenuSelectValueTypeTimeoutLockScreen:
            self.titleLabel.text = TwinmeLocalizedString(@"privacy_view_lock_screen_timeout", nil);
            break;
            
        case MenuSelectValueTypeTimeoutEphemeralMessage:
            self.titleLabel.text = TwinmeLocalizedString(@"application_timeout", nil);
            break;
            
        case MenuSelectValueTypeCallZoomable:
            self.titleLabel.text = TwinmeLocalizedString(@"contact_capabilities_view_camera_control_information", nil);
            break;
            
        case MenuSelectValueTypeExternalCallType:
            self.titleLabel.text = TwinmeLocalizedString(@"create_external_call_view_call_type", nil);
            break;
            
        case MenuSelectValueTypeExternalCallExpiration:
            self.titleLabel.text = TwinmeLocalizedString(@"create_external_call_view_link_validity", nil);
            break;
            
        case MenuSelectValueTypeSecurityLevel:
            self.titleLabel.text = TwinmeLocalizedString(@"settings_advanced_view_security_level_title", nil);
            break;
            
        case MenuSelectValueTypeSilentModeDuration:
            self.titleLabel.text = TwinmeLocalizedString(@"settings_view_turn_off_notification_sounds", nil);
            break;
            
        case MenuSelectValueTypeShareInvitation:
            self.titleLabel.text = TwinmeLocalizedString(@"privacy_view_share_invitation_setting", nil);
            break;
                                                         
        default:
            break;
    }
}

- (void)reloadData {
    DDLogVerbose(@"%@ reloadData", LOG_TAG);
    
    [self.tableView reloadData];
    
    if (self.forceDarkMode) {
        self.tableView.backgroundColor = [UIColor colorWithRed:72./255. green:72./255. blue:72./255. alpha:1];
    } else {
        self.tableView.backgroundColor = Design.POPUP_BACKGROUND_COLOR;
    }
}

#pragma mark - Private methods

- (void)finish {
    DDLogVerbose(@"%@ finish", LOG_TAG);
    
    if ([self.menuSelectValueDelegate respondsToSelector:@selector(cancelMenuSelectValue:)]) {
        [self.menuSelectValueDelegate cancelMenuSelectValue:self];
    }
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    [super updateColor];
    
    if (self.forceDarkMode) {
        self.titleLabel.textColor = [UIColor whiteColor];
    }
}

@end

