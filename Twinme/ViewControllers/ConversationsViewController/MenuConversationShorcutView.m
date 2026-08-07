/*
 *  Copyright (c) 2026 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <Utils/NSString+Utils.h>

#import "MenuConversationShorcutView.h"
#import "MessageSettingsViewController.h"
#import "MenuHeaderCell.h"
#import "MenuIconCell.h"
#import "SettingsValueItemCell.h"
#import "SettingsItemCell.h"
#import "UIConversation.h"
#import "UIContact.h"
#import "SwitchView.h"

#import <TwinmeCommon/Design.h>
#import <TwinmeCommon/UIViewController+Utils.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static NSString *MENU_ICON_CELL_IDENTIFIER = @"MenuIconCellIdentifier";
static NSString *MENU_HEADER_CELL_IDENTIFIER = @"MenuHeaderCellIdentifier";
static NSString *SETTINGS_CELL_IDENTIFIER = @"SettingsCellIdentifier";
static NSString *SETTINGS_VALUE_CELL_IDENTIFIER = @"SettingsValueCellIdentifier";

static CGFloat DESIGN_HEADER_HEIGHT = 300.f;

typedef enum {
    MenuConversationShorcutHeader,
    MenuConversationShorcutReaction,
    MenuConversationShorcutSilentMode,
    MenuConversationShorcutSilentModeExpiration,
    MenuConversationShorcutReset,
    MenuConversationShorcutCount
} MenuConversationShorcut;

//
// Interface: MenuConversationShorcutView ()
//

@interface MenuConversationShorcutView ()<CAAnimationDelegate, UITableViewDelegate, UITableViewDataSource, SettingsActionDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewBottomConstraint;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic) UIConversation *uiConversation;
@property (nonatomic) BOOL silentMode;
@property (nonatomic) BOOL notificationReaction;
@property (nonatomic) int64_t silentExpiration;
@end

//
// Implementation: MenuConversationShorcutView
//

#undef LOG_TAG
#define LOG_TAG @"MenuConversationShorcutView"

@implementation MenuConversationShorcutView

#pragma mark - UIView

- (instancetype)init {
    DDLogVerbose(@"%@ init", LOG_TAG);
    
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"MenuConversationShorcutView" owner:self options:nil];
    self = [objects objectAtIndex:0];
    
    self.frame = CGRectMake(0, 0, Design.DISPLAY_WIDTH, Design.DISPLAY_HEIGHT);
    self.silentMode = NO;
    self.notificationReaction = YES;

    if (self) {
        [self initViews];
    }
    return self;
}

- (void)openMenu:(nonnull UIConversation *)uiConversation silentMode:(BOOL)silentMode notificationReaction:(BOOL)notificationReaction silentExpiration:(int64_t)silentExpiration {
    
    DDLogVerbose(@"%@ openMenu: %@", LOG_TAG, uiConversation);
    
    self.uiConversation = uiConversation;
    self.silentMode = silentMode;
    self.notificationReaction = notificationReaction;
    self.silentExpiration = silentExpiration;
    
    [self openMenu];
}

#pragma mark - SettingsActionDelegate

- (void)switchChangeValue:(SwitchView *)updatedSwitch {
    DDLogVerbose(@"%@ switchChangeValue: %@", LOG_TAG, updatedSwitch);

    if (updatedSwitch.tag == MenuConversationShorcutSilentMode) {
        self.silentMode = updatedSwitch.isOn;
        
        if (self.silentMode) {
            if ([self.menuConversationShorcutDelegate respondsToSelector:@selector(selectSilentModeDuration:conversation:)]) {
                [self.menuConversationShorcutDelegate selectSilentModeDuration:self conversation:self.uiConversation];
            }
        }
    } else if (updatedSwitch.tag == MenuConversationShorcutReaction) {
        self.notificationReaction = updatedSwitch.isOn;
    }
    
    [self reloadData];
}

#pragma mark - UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ heightForRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    if (indexPath.row == MenuConversationShorcutHeader) {
        return DESIGN_HEADER_HEIGHT * Design.HEIGHT_RATIO;
    }
    
    if (indexPath.row == MenuConversationShorcutSilentModeExpiration && !self.silentMode) {
        return CGFLOAT_MIN;
    }
        
    return Design.SETTING_CELL_HEIGHT;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    DDLogVerbose(@"%@ numberOfSectionsInTableView: %@", LOG_TAG, tableView);
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ numberOfRowsInSection: %ld", LOG_TAG, tableView, (long)section);
    
    return MenuConversationShorcutCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ cellForRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    if (indexPath.row == MenuConversationShorcutHeader) {
        MenuHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:MENU_HEADER_CELL_IDENTIFIER];
        if (!cell) {
            cell = [[MenuHeaderCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:MENU_HEADER_CELL_IDENTIFIER];
        }
    
        [cell bindWithName:self.uiConversation.uiContact.name avatar:self.uiConversation.uiContact.avatar];
        return cell;
    } else if (indexPath.row == MenuConversationShorcutReset) {
        MenuIconCell *cell = [tableView dequeueReusableCellWithIdentifier:MENU_ICON_CELL_IDENTIFIER];
        if (!cell) {
            cell = [[MenuIconCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:MENU_ICON_CELL_IDENTIFIER];
        }
        
        NSString *title =  title = TwinmeLocalizedString(@"main_view_reset_conversation_title", nil);
        NSString *icon = icon = @"ToolbarTrash";;
        BOOL hideSeparator = YES;
        [cell bindWithTitle:title icon:icon iconColor:Design.DELETE_COLOR_RED hideSeparator:hideSeparator];
            
        return cell;
    } else if (indexPath.row == MenuConversationShorcutSilentModeExpiration) {
        SettingsValueItemCell *cell = [tableView dequeueReusableCellWithIdentifier:SETTINGS_VALUE_CELL_IDENTIFIER];
        if (!cell) {
            cell = [[SettingsValueItemCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:SETTINGS_VALUE_CELL_IDENTIFIER];
        }
        
        NSString *title = TwinmeLocalizedString(@"settings_view_turn_off_notification_sounds", nil);
        NSString *value = @"";
        UIImage *icon = [UIImage imageNamed:@"SendOptionEphemeralIcon"];
        if (self.silentExpiration > 0) {
            value = [NSString stringWithFormat:TwinmeLocalizedString(@"application_until", nil), [NSString formatItemTimeInterval:self.silentExpiration]];
        } else if (self.silentExpiration == -1) {
            value = TwinmeLocalizedString(@"contact_capabilities_view_camera_control_allow", nil);
        }
       
        cell.forceDarkMode = self.forceDarkMode;
        [cell bindWithTitle:title value:value icon:icon backgroundColor:Design.POPUP_BACKGROUND_COLOR];
        
        return cell;
    } else {
        SettingsItemCell *cell = [tableView dequeueReusableCellWithIdentifier:SETTINGS_CELL_IDENTIFIER];
        if (!cell) {
            cell = [[SettingsItemCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:SETTINGS_CELL_IDENTIFIER];
        }
        
        cell.settingsActionDelegate = self;
        cell.forceDarkMode = self.forceDarkMode;
        
        NSString *title;
        UIImage *icon;
        BOOL switchState = NO;
        int tag = (int) indexPath.row;
        BOOL disableSwitch = NO;
        BOOL hideSeparator = NO;
        
        if (indexPath.row == MenuConversationShorcutSilentMode) {
            title = TwinmeLocalizedString(@"settings_view_silent_mode", nil);
            icon = [UIImage imageNamed:@"TabBarNotificationGrey"];
            switchState = self.silentMode;
        } else {
            title = TwinmeLocalizedString(@"settings_view_message_reactions_notification", nil);
            icon = [UIImage imageNamed:@"NotificationReactionIcon"];
            switchState = self.notificationReaction;
        }
                
        [cell bindWithTitle:title subTitle:nil  icon:icon stateSwitch:switchState tagSwitch:tag hiddenSwitch:NO disableSwitch:disableSwitch backgroundColor:Design.POPUP_BACKGROUND_COLOR hiddenSeparator:hideSeparator];
        
        return cell;
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ didSelectRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    if (indexPath.row == MenuConversationShorcutHeader) {
        if ([self.menuConversationShorcutDelegate respondsToSelector:@selector(showOriginator:conversation:)]) {
            [self.menuConversationShorcutDelegate showOriginator:self conversation:self.uiConversation];
        }
    } else if (indexPath.row == MenuConversationShorcutReset) {
        if ([self.menuConversationShorcutDelegate respondsToSelector:@selector(resetConversation:conversation:)]) {
            [self.menuConversationShorcutDelegate resetConversation:self conversation:self.uiConversation];
        }
    } else if (indexPath.row == MenuConversationShorcutSilentModeExpiration) {
        if ([self.menuConversationShorcutDelegate respondsToSelector:@selector(selectSilentModeDuration:conversation:)]) {
            [self.menuConversationShorcutDelegate selectSilentModeDuration:self conversation:self.uiConversation];
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
    self.tableViewHeightConstraint.constant = Design.SETTING_CELL_HEIGHT * (MenuConversationShorcutCount - 1) + (DESIGN_HEADER_HEIGHT * Design.HEIGHT_RATIO);

    self.tableView.scrollEnabled = NO;
    self.tableView.backgroundColor = Design.POPUP_BACKGROUND_COLOR;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"MenuIconCell" bundle:nil] forCellReuseIdentifier:MENU_ICON_CELL_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"MenuHeaderCell" bundle:nil] forCellReuseIdentifier:MENU_HEADER_CELL_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"SettingsItemCell" bundle:nil] forCellReuseIdentifier:SETTINGS_CELL_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"SettingsValueItemCell" bundle:nil] forCellReuseIdentifier:SETTINGS_VALUE_CELL_IDENTIFIER];
}

- (void)reloadData {
    DDLogVerbose(@"%@ reloadData", LOG_TAG);
    
    int countSettingsCellHeight = MenuConversationShorcutCount - 1;
    if (!self.silentMode) {
        countSettingsCellHeight -= 1;
    }
    
    self.tableViewHeightConstraint.constant = Design.SETTING_CELL_HEIGHT * countSettingsCellHeight + (DESIGN_HEADER_HEIGHT * Design.HEIGHT_RATIO);
    [self.tableView reloadData];
    self.tableView.backgroundColor = Design.POPUP_BACKGROUND_COLOR;
}

#pragma mark - Private methods

- (void)finish {
    DDLogVerbose(@"%@ finish", LOG_TAG);
        
    if ([self.menuConversationShorcutDelegate respondsToSelector:@selector(saveConversationSettings:conversation:silentMode:silentModeExpiration:notificationReaction:)]) {
        [self.menuConversationShorcutDelegate saveConversationSettings:self conversation:self.uiConversation silentMode:self.silentMode silentModeExpiration:0 notificationReaction:self.notificationReaction];
    }
}

@end

