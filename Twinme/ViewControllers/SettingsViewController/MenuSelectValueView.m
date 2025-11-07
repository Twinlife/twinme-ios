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

#import <TwinmeCommon/Design.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static NSString *SELECT_VALUE_CELL_IDENTIFIER = @"SelectValueCellIdentifier";
static NSString *TIMEOUT_CELL_IDENTIFIER = @"TimeoutCellIdentifier";

static const CGFloat MIN_HEIGHT = 132;

//
// Interface: MenuSelectValueView ()
//

@interface MenuSelectValueView ()<CAAnimationDelegate, UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewBottomConstraint;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic) int count;
@property (nonatomic) int selectedValue;
@property (nonatomic) NSMutableArray *uiTimeouts;

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
    self.count = 0;
    self.menuSelectValueType = MenuSelectValueTypeImageSize;
    
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
    }
}

- (void)setMenuSelectValueTypeWithType:(MenuSelectValueType)menuSelectValueType {
    DDLogVerbose(@"%@ setMenuSelectValueTypeWithType", LOG_TAG);
    
    self.menuSelectValueType = menuSelectValueType;
    
    switch (self.menuSelectValueType) {
        case MenuSelectValueTypeImageSize:
        case MenuSelectValueTypeDisplayCallsMode:
        case MenuSelectValueTypeProfileUpdateMode:
        case MenuSelectValueTypeCallZoomable:
            self.count = 3;
            break;
            
        case MenuSelectValueTypeVideoSize:
        case MenuSelectValueTypeEditSpace:
            self.count = 2;
            break;
            
        case MenuSelectValueTypeTimeoutLockScreen:
        case MenuSelectValueTypeTimeoutEphemeralMessage:
            [self initTimeout];
            self.count = (int) self.uiTimeouts.count;
            break;
        default:
            break;
    }
    
    self.tableViewHeightConstraint.constant = Design.SETTING_CELL_HEIGHT * self.count;
    
    CGFloat maxHeight = (MIN_HEIGHT * Design.HEIGHT_RATIO) + (Design.SETTING_CELL_HEIGHT * self.count) + Design.FONT_MEDIUM36.lineHeight;
    if (maxHeight > Design.DISPLAY_HEIGHT) {
        self.tableView.scrollEnabled = YES;
    } else {
        self.tableView.scrollEnabled = NO;
    }
    
    [self setupTitle];
    [self setupSelectedValue];
        
    [self reloadData];
}

#pragma mark - UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ heightForRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    return Design.SETTING_CELL_HEIGHT;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    DDLogVerbose(@"%@ numberOfSectionsInTableView: %@", LOG_TAG, tableView);
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ numberOfRowsInSection: %ld", LOG_TAG, tableView, (long)section);
    
    if (self.menuSelectValueType == MenuSelectValueTypeTimeoutLockScreen || self.menuSelectValueType == MenuSelectValueTypeTimeoutEphemeralMessage) {
        return self.uiTimeouts.count;
    }
    return self.count;
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
    BOOL hideSeparator = self.count == indexPath.row + 1;
    if (self.menuSelectValueType == MenuSelectValueTypeImageSize) {
        if (indexPath.row == SendImageSizeSmall) {
            title = TwinmeLocalizedString(@"conversation_view_controller_reduce_menu_minimal", nil);
            subtitle = TwinmeLocalizedString(@"conversation_view_controller_reduce_menu_minimal_size", nil);
        } else if (indexPath.row == SendImageSizeMedium) {
            title = TwinmeLocalizedString(@"conversation_view_controller_reduce_menu_lower", nil);
            subtitle = TwinmeLocalizedString(@"conversation_view_controller_reduce_menu_lower_size", nil);
        } else {
            title = TwinmeLocalizedString(@"conversation_view_controller_reduce_menu_original", nil);
            subtitle = TwinmeLocalizedString(@"conversation_view_controller_reduce_menu_original_subtitle", nil);
        }
    } else if (self.menuSelectValueType == MenuSelectValueTypeVideoSize) {
        if (indexPath.row == SendVideoSizeLower) {
            title = TwinmeLocalizedString(@"conversation_view_controller_reduce_menu_minimal", nil);
        } else {
            title = TwinmeLocalizedString(@"conversation_view_controller_reduce_menu_original", nil);
        }
    } else if (self.menuSelectValueType == MenuSelectValueTypeDisplayCallsMode) {
        if (indexPath.row == TLDisplayCallsModeNone) {
            title = TwinmeLocalizedString(@"settings_view_controller_display_call_menu_none", nil);
        } else if (indexPath.row == TLDisplayCallsModeMissed) {
            title = TwinmeLocalizedString(@"settings_view_controller_display_call_menu_missed", nil);
        } else {
            title = TwinmeLocalizedString(@"settings_view_controller_call_item_menu_all", nil);
        }
    } else if (self.menuSelectValueType == MenuSelectValueTypeEditSpace) {
        if (indexPath.row == 0) {
            title = TwinmeLocalizedString(@"settings_space_view_controller_space_category_title", nil);
        } else {
            title = TwinmeLocalizedString(@"application_profile", nil);
        }
    } else if (self.menuSelectValueType == MenuSelectValueTypeProfileUpdateMode) {
        if (indexPath.row == TLProfileUpdateModeAll) {
            title = TwinmeLocalizedString(@"edit_profile_view_controller_propagating_all_contacts", nil);
        } else if (indexPath.row == TLProfileUpdateModeDefault) {
            title = TwinmeLocalizedString(@"edit_profile_view_controller_propagating_except_contacts", nil);
        } else {
            title = TwinmeLocalizedString(@"edit_profile_view_controller_propagating_no_contact", nil);
        }
    } else if (self.menuSelectValueType == MenuSelectValueTypeTimeoutLockScreen || self.menuSelectValueType == MenuSelectValueTypeTimeoutEphemeralMessage) {
        UITimeout *uiTimeout = [self.uiTimeouts objectAtIndex:indexPath.row];
        hideSeparator = indexPath.row + 1 == self.uiTimeouts.count ? YES : NO;
        title = uiTimeout.title;
        checked = uiTimeout.timeout == self.selectedValue;
    } else if (self.menuSelectValueType == MenuSelectValueTypeCallZoomable) {
        if (indexPath.row == TLVideoZoomableNever) {
            title = TwinmeLocalizedString(@"contact_capabilities_view_controller_camera_control_never", nil);
        } else if (indexPath.row == TLVideoZoomableAsk) {
            title = TwinmeLocalizedString(@"contact_capabilities_view_controller_camera_control_ask", nil);
        } else {
            title = TwinmeLocalizedString(@"contact_capabilities_view_controller_camera_control_allow", nil);
        }
    }
    
    cell.forceDarkMode = self.forceDarkMode;
    [cell bindWithTitle:title subTitle:subtitle checked:checked hideBorder:YES hideSeparator:hideSeparator];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ didSelectRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    if (self.menuSelectValueType == MenuSelectValueTypeTimeoutLockScreen || self.menuSelectValueType == MenuSelectValueTypeTimeoutEphemeralMessage) {
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
    
    UIWindow *window = UIApplication.sharedApplication.keyWindow;
    CGFloat safeAreaInset = window.safeAreaInsets.bottom;
    
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
            self.titleLabel.text = TwinmeLocalizedString(@"settings_view_controller_display_call_title", nil);
            break;
            
        case MenuSelectValueTypeEditSpace:
            self.titleLabel.text = TwinmeLocalizedString(@"application_edit", nil);
            break;
            
        case MenuSelectValueTypeImageSize:
            self.titleLabel.text = TwinmeLocalizedString(@"settings_view_controller_image_title", nil);
            break;
            
        case MenuSelectValueTypeVideoSize:
            self.titleLabel.text = TwinmeLocalizedString(@"show_contact_view_controller_video", nil);
            break;
            
        case MenuSelectValueTypeProfileUpdateMode:
            self.titleLabel.text = TwinmeLocalizedString(@"edit_profile_view_controller_propagating_profile", nil);
            break;
            
        case MenuSelectValueTypeTimeoutLockScreen:
            self.titleLabel.text = TwinmeLocalizedString(@"privacy_view_controller_lock_screen_timeout", nil);
            break;
            
        case MenuSelectValueTypeTimeoutEphemeralMessage:
            self.titleLabel.text = TwinmeLocalizedString(@"application_timeout", nil);
            break;
            
        case MenuSelectValueTypeCallZoomable:
            self.titleLabel.text = TwinmeLocalizedString(@"contact_capabilities_view_controller_information_camera_control", nil);
            break;
            
        default:
            break;
    }
}

- (void)setupSelectedValue {
    DDLogVerbose(@"%@ setupSelectedValue", LOG_TAG);
    
    ApplicationDelegate *delegate = (ApplicationDelegate *)[[UIApplication sharedApplication] delegate];
    TwinmeApplication *twinmeApplication = [delegate twinmeApplication];
    
    switch (self.menuSelectValueType) {
        case MenuSelectValueTypeDisplayCallsMode:
            self.selectedValue = twinmeApplication.displayCallsMode;
            break;
            
        case MenuSelectValueTypeEditSpace:
            self.selectedValue = -1;
            break;
            
        case MenuSelectValueTypeImageSize:
            self.selectedValue = twinmeApplication.sendImageSize;
            break;
            
        case MenuSelectValueTypeVideoSize:
            self.selectedValue = twinmeApplication.sendVideoSize;;
            break;
            
        case MenuSelectValueTypeProfileUpdateMode:
            self.selectedValue = twinmeApplication.profileUpdateMode;
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

@end

