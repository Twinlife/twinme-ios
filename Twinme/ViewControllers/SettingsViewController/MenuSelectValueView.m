/*
 *  Copyright (c) 2022 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <Utils/NSString+Utils.h>

#import "MenuSelectValueView.h"
#import "SelectValueCell.h"
#import "MessageSettingsViewController.h"

#import "ColorCell.h"

#import <TwinmeCommon/Design.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static NSString *SELECT_VALUE_CELL_IDENTIFIER = @"SelectValueCellIdentifier";

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

- (void)setMenuSelectValueTypeWithType:(MenuSelectValueType)menuSelectValueType {
    DDLogVerbose(@"%@ setMenuSelectValueTypeWithType", LOG_TAG);
    
    self.menuSelectValueType = menuSelectValueType;
    
    switch (self.menuSelectValueType) {
        case MenuSelectValueTypeImageSize:
        case MenuSelectValueTypeDisplayCallsMode:
        case MenuSelectValueTypeProfileUpdateMode:
            self.count = 3;
            break;
            
        case MenuSelectValueTypeVideoSize:
            self.count = 2;
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
    } else if (self.menuSelectValueType == MenuSelectValueTypeProfileUpdateMode) {
        if (indexPath.row == TLProfileUpdateModeAll) {
            title = TwinmeLocalizedString(@"edit_profile_view_controller_propagating_all_contacts", nil);
        } else if (indexPath.row == TLProfileUpdateModeDefault) {
            title = TwinmeLocalizedString(@"edit_profile_view_controller_propagating_except_contacts", nil);
        } else {
            title = TwinmeLocalizedString(@"edit_profile_view_controller_propagating_no_contact", nil);
        }
    }
        
    BOOL hideSeparator = self.count == indexPath.row + 1;
    [cell bindWithTitle:title subTitle:subtitle checked:self.selectedValue == indexPath.row hideBorder:YES hideSeparator:hideSeparator];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ didSelectRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    if ([self.menuSelectValueDelegate respondsToSelector:@selector(selectValue:value:)]) {
        [self.menuSelectValueDelegate selectValue:self value:(int)indexPath.row];
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
}

- (void)setupTitle {
    DDLogVerbose(@"%@ setupTitle", LOG_TAG);
    
    switch (self.menuSelectValueType) {
        case MenuSelectValueTypeDisplayCallsMode:
            self.titleLabel.text = TwinmeLocalizedString(@"settings_view_controller_display_call_title", nil);
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
    self.tableView.backgroundColor = Design.POPUP_BACKGROUND_COLOR;
}

#pragma mark - Private methods

- (void)finish {
    DDLogVerbose(@"%@ finish", LOG_TAG);
    
    if ([self.menuSelectValueDelegate respondsToSelector:@selector(cancelMenuSelectValue:)]) {
        [self.menuSelectValueDelegate cancelMenuSelectValue:self];
    }
}

@end

