/*
 *  Copyright (c) 2019-2021 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import "ConversationViewController.h"

#import <Utils/NSString+Utils.h>

#import "MenuSendOptionsView.h"
#import "MessageSettingsViewController.h"
#import "ConversationViewController.h"

#import "SettingsValueItemCell.h"
#import "SettingsItemCell.h"
#import "MenuSelectValueView.h"
#import "UITimeout.h"

#import <TwinmeCommon/Design.h>
#import <TwinmeCommon/UIViewController+Utils.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static NSString *SETTINGS_CELL_IDENTIFIER = @"SettingsCellIdentifier";
static NSString *SETTINGS_VALUE_CELL_IDENTIFIER = @"SettingsValueCellIdentifier";

typedef enum {
    TAG_ALLOW_EPHEMERAL,
    TAG_ALLOW_COPY
} TLSettingTag;

//
// Interface: MenuSendOptionsView ()
//

@interface MenuSendOptionsView ()<UITableViewDelegate, UITableViewDataSource, SettingsActionDelegate, SwitchViewDelegate, MenuSelectValueDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sendViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sendViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sendViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sendViewBottomConstraint;
@property (weak, nonatomic) IBOutlet UIView *sendView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sendLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet UILabel *sendLabel;

@property BOOL allowEphemeral;
@property BOOL allowCopy;
@property int64_t timeout;
@property int count;

@end

//
// Implementation: MenuSendOptionsView
//

#undef LOG_TAG
#define LOG_TAG @"MenuSendOptionsView"

@implementation MenuSendOptionsView

#pragma mark - UIView

- (instancetype)init {
    DDLogVerbose(@"%@ init", LOG_TAG);
    
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"MenuSendOptionsView" owner:self options:nil];
    self = [objects objectAtIndex:0];
    
    self.frame = CGRectMake(0, 0, Design.DISPLAY_WIDTH, Design.DISPLAY_HEIGHT);
    
    if (self) {
        _allowCopy = YES;
        _allowEphemeral = NO;
        _count = 2;
        self.forceDarkMode = NO;
        [self initViews];
    }
    return self;
}

- (void)openMenu:(BOOL)allowCopy allowEphemeralMessage:(BOOL)allowEphemeralMessage timeout:(int64_t)timeout {
    DDLogVerbose(@"%@ openMenu: %@", LOG_TAG, allowCopy ? @"YES":@"NO");
    
    self.allowCopy = allowCopy;
    self.allowEphemeral = allowEphemeralMessage;
    self.timeout = timeout;
    
    if (self.allowEphemeral) {
        self.count = 3;
    } else {
        self.count = 2;
    }
        
    self.tableViewHeightConstraint.constant = Design.SETTING_CELL_HEIGHT * self.count;
    [self openMenu];
}

- (void)updateTimeout:(int64_t)timeout {
    DDLogVerbose(@"%@ updateTimeout: %lld", LOG_TAG, timeout);
    
    self.timeout = timeout;
}

- (void)reloadData {
    DDLogVerbose(@"%@ reloadData", LOG_TAG);
    
    [self.tableView reloadData];
}

#pragma mark - MenuTimeoutDelegate

- (void)cancelMenuSelectValue:(MenuSelectValueView *)menuSelectValueView {
    DDLogVerbose(@"%@ cancelMenu", LOG_TAG);
    
    [menuSelectValueView removeFromSuperview];
}

- (void)selectTimeout:(MenuSelectValueView *)menuSelectValueView uiTimeout:(UITimeout *)uiTimeout {
    DDLogVerbose(@"%@ selectTimeout: %@", LOG_TAG, uiTimeout);
    
    [menuSelectValueView removeFromSuperview];
    
    self.timeout = uiTimeout.timeout;
    [self reloadData];
}

#pragma mark - SettingsActionDelegate

- (void)switchChangeValue:(SwitchView *)updatedSwitch {
    DDLogVerbose(@"%@ switchChangeValue: %@", LOG_TAG, updatedSwitch);
    
    if (updatedSwitch.tag == TAG_ALLOW_EPHEMERAL) {
        self.allowEphemeral = updatedSwitch.isOn;
    } else {
        self.allowCopy = updatedSwitch.isOn;
    }
    
    if (self.allowEphemeral) {
        self.count = 3;
    } else {
        self.count = 2;
    }
    
    self.tableViewHeightConstraint.constant = Design.SETTING_CELL_HEIGHT * self.count;

    [UIView animateWithDuration:0.3 animations:^{
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self reloadData];
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    DDLogVerbose(@"%@ numberOfSectionsInTableView: %@", LOG_TAG, tableView);
    
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath  {
    DDLogVerbose(@"%@ tableView: %@ heightForRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    return Design.SETTING_CELL_HEIGHT;
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
    
    if (self.allowEphemeral) {
        return 3;
    }
    
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ cellForRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    if (self.allowEphemeral && indexPath.row == 1) {
        SettingsValueItemCell *cell = [tableView dequeueReusableCellWithIdentifier:SETTINGS_VALUE_CELL_IDENTIFIER];
        if (!cell) {
            cell = [[SettingsValueItemCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:SETTINGS_VALUE_CELL_IDENTIFIER];
        }
        
        cell.forceDarkMode = self.forceDarkMode;
        [cell bindWithTitle:TwinmeLocalizedString(@"application_timeout", nil) value:[NSString formatTimeout:self.timeout] backgroundColor:Design.POPUP_BACKGROUND_COLOR];
        
        return cell;
    } else {
        SettingsItemCell *cell = [tableView dequeueReusableCellWithIdentifier:SETTINGS_CELL_IDENTIFIER];
        if (!cell) {
            cell = [[SettingsItemCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:SETTINGS_CELL_IDENTIFIER];
        }
        
        cell.settingsActionDelegate = self;
        cell.forceDarkMode = self.forceDarkMode;
        
        NSString *title = @"";
        UIImage *icon;
        BOOL switchState = NO;
        int tag = 0;
        BOOL hideSeparator = NO;
        
        if (indexPath.row == 0) {
            title = TwinmeLocalizedString(@"settings_view_controller_ephemeral_title", nil);
            tag = TAG_ALLOW_EPHEMERAL;
            switchState = self.allowEphemeral;
            icon = [UIImage imageNamed:@"SendOptionEphemeralIcon"];
        } else {
            title = TwinmeLocalizedString(@"conversation_view_controller_send_menu_allow_copy", nil);
            tag = TAG_ALLOW_COPY;
            switchState = self.allowCopy;
            hideSeparator = YES;
            icon = self.allowCopy ? [UIImage imageNamed:@"SendOptionCopyAllowedIcon"] : [UIImage imageNamed:@"SendOptionCopyIcon"];
        }
        
        [cell bindWithTitle:title icon:icon stateSwitch:switchState tagSwitch:tag hiddenSwitch:NO disableSwitch:NO backgroundColor:Design.POPUP_BACKGROUND_COLOR hiddenSeparator:hideSeparator];
        
        return cell;
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ didSelectRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    if (self.allowEphemeral && indexPath.row == 1) {
        
        MenuSelectValueView *menuTimeoutView = [[MenuSelectValueView alloc] init];
        menuTimeoutView.menuSelectValueDelegate = self;
        menuTimeoutView.forceDarkMode = self.forceDarkMode;
        [menuTimeoutView setMenuSelectValueTypeWithType:MenuSelectValueTypeTimeoutEphemeralMessage];
        [menuTimeoutView setSelectedValueWithValue:(int) self.timeout];
        [self addSubview:menuTimeoutView];
        [menuTimeoutView openMenu];
    }
}

#pragma mark - Private methods

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    [super initViews];
    
    self.actionViewTopConstraint.constant *= Design.HEIGHT_RATIO;

    self.tableViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.tableViewHeightConstraint.constant = Design.SETTING_CELL_HEIGHT * self.count;
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.scrollEnabled = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = Design.SETTING_CELL_HEIGHT * Design.HEIGHT_RATIO;
    [self.tableView registerNib:[UINib nibWithNibName:@"SettingsItemCell" bundle:nil] forCellReuseIdentifier:SETTINGS_CELL_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"SettingsValueItemCell" bundle:nil] forCellReuseIdentifier:SETTINGS_VALUE_CELL_IDENTIFIER];
    self.tableView.backgroundColor = [UIColor clearColor];
    
    self.sendViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.sendViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.sendViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.sendViewBottomConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.sendView.backgroundColor = Design.MAIN_COLOR;
    self.sendView.userInteractionEnabled = YES;
    self.sendView.layer.cornerRadius = Design.CONTAINER_RADIUS;
    self.sendView.clipsToBounds = YES;
    self.sendView.isAccessibilityElement = YES;
    self.sendView.accessibilityLabel = TwinmeLocalizedString(@"feedback_view_controller_send", nil);
    [self.sendView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSendTapGesture:)]];
    
    self.sendLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.sendLabel.font = Design.FONT_BOLD36;
    self.sendLabel.textColor = [UIColor whiteColor];
    self.sendLabel.text = TwinmeLocalizedString(@"feedback_view_controller_send", nil);
}

- (void)handleSendTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleSendTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        if ([self.menuSendOptionsDelegate respondsToSelector:@selector(sendFromOptionsMenu:allowCopy:allowEphemeral:expireTimeout:)]) {
            [self.menuSendOptionsDelegate sendFromOptionsMenu:self allowCopy:self.allowCopy allowEphemeral:self.allowEphemeral expireTimeout:self.timeout];
        }
    }
}

#pragma mark - Private methods

- (void)finish {
    DDLogVerbose(@"%@ finish", LOG_TAG);
    
    if ([self.menuSendOptionsDelegate respondsToSelector:@selector(cancelMenuSendOptions:)]) {
        [self.menuSendOptionsDelegate cancelMenuSendOptions:self];
    }
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    self.sendLabel.font = Design.FONT_BOLD36;
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    [super updateColor];
    
    self.sendView.backgroundColor = Design.MAIN_COLOR;
}

@end
