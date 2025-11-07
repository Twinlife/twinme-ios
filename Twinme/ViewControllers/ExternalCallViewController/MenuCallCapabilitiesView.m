/*
 *  Copyright (c) 2023 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <Twinme/TLCallReceiver.h>
#import <Utils/NSString+Utils.h>

#import "MenuCallCapabilitiesView.h"
#import "MessageSettingsViewController.h"
#import "SettingsItemCell.h"

#import <TwinmeCommon/Design.h>

#import "SwitchView.h"

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static NSString *SETTINGS_CELL_IDENTIFIER = @"SettingsCellIdentifier";

typedef enum {
    TAG_ALLOW_AUDIO_CALL,
    TAG_ALLOW_VIDEO_CALL,
    TAG_ALLOW_GROUP_CALL
} TLCapabitiesTag;

//
// Interface: MenuCallCapabilitiesView ()
//

@interface MenuCallCapabilitiesView ()<UITableViewDelegate, UITableViewDataSource, SettingsActionDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewBottomConstraint;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic) int count;
@property (nonatomic) int selectedValue;

@property (nonatomic) BOOL allowAudioCall;
@property (nonatomic) BOOL allowVideoCall;
@property (nonatomic) BOOL allowGroupCall;

@end

//
// Implementation: MenuCallCapabilitiesView
//

#undef LOG_TAG
#define LOG_TAG @"MenuCallCapabilitiesView"

@implementation MenuCallCapabilitiesView

#pragma mark - UIView

- (instancetype)init {
    DDLogVerbose(@"%@ init", LOG_TAG);
    
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"MenuCallCapabilitiesView" owner:self options:nil];
    self = [objects objectAtIndex:0];
    
    self.frame = CGRectMake(0, 0, Design.DISPLAY_WIDTH, Design.DISPLAY_HEIGHT);
    self.count = 3;
    
    if (self) {
        [self initViews];
    }
    return self;
}

#pragma mark - Public methods

- (void)openMenu:(TLCapabilities *)capabilities {
    DDLogVerbose(@"%@ openMenu", LOG_TAG);
        
    self.allowAudioCall = [capabilities hasAudio];
    self.allowVideoCall = [capabilities hasVideo];
    self.allowGroupCall = [capabilities hasGroupCall];
    
    [self openMenu];
}

#pragma mark - SettingsActionDelegate

- (void)switchChangeValue:(SwitchView *)updatedSwitch {
    DDLogVerbose(@"%@ switchChangeValue: %@", LOG_TAG, updatedSwitch);
    
    switch (updatedSwitch.tag) {
        case TAG_ALLOW_AUDIO_CALL:
            self.allowAudioCall = updatedSwitch.isOn;
            break;
            
        case TAG_ALLOW_VIDEO_CALL:
            self.allowVideoCall = updatedSwitch.isOn;
            break;
            
        case TAG_ALLOW_GROUP_CALL:
            self.allowGroupCall = updatedSwitch.isOn;
            break;
            
        default:
            break;
    }
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
    
    SettingsItemCell *cell = [tableView dequeueReusableCellWithIdentifier:SETTINGS_CELL_IDENTIFIER];
    if (!cell) {
        cell = [[SettingsItemCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:SETTINGS_CELL_IDENTIFIER];
    }
    
    cell.settingsActionDelegate = self;
    
    NSString *title = @"";
    BOOL switchState = NO;
    int tag = 0;
    BOOL disableSwitch = NO;
    if (indexPath.row == 0) {
        switchState = self.allowAudioCall;
        disableSwitch = YES;
        tag = TAG_ALLOW_AUDIO_CALL;
        title = TwinmeLocalizedString(@"conversation_view_controller_audio_call", nil);
    } else if (indexPath.row == 1) {
        switchState = self.allowVideoCall;
        tag = TAG_ALLOW_VIDEO_CALL;
        title = TwinmeLocalizedString(@"conversation_view_controller_video_call", nil);
    } else {
        switchState = self.allowGroupCall;
        tag = TAG_ALLOW_GROUP_CALL;
        title = TwinmeLocalizedString(@"show_call_view_controller_setting_group_calls", nil);
    }
    
    [cell bindWithTitle:title icon:nil stateSwitch:switchState tagSwitch:tag hiddenSwitch:NO disableSwitch:disableSwitch backgroundColor:Design.POPUP_BACKGROUND_COLOR hiddenSeparator:NO];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ didSelectRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
}

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    [super initViews];
    
    self.titleLabel.text = TwinmeLocalizedString(@"show_call_view_controller_setting_calls", nil);
    
    UIWindow *window = UIApplication.sharedApplication.keyWindow;
    CGFloat safeAreaInset = window.safeAreaInsets.bottom;
    
    self.tableViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.tableViewHeightConstraint.constant = Design.SETTING_CELL_HEIGHT * self.count;
    self.tableViewBottomConstraint.constant = safeAreaInset;
    
    self.tableView.scrollEnabled = NO;
    self.tableView.backgroundColor = Design.POPUP_BACKGROUND_COLOR;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"SettingsItemCell" bundle:nil] forCellReuseIdentifier:SETTINGS_CELL_IDENTIFIER];
}

- (void)reloadData {
    DDLogVerbose(@"%@ reloadData", LOG_TAG);
    
    [self.tableView reloadData];
    self.tableView.backgroundColor = Design.POPUP_BACKGROUND_COLOR;
}

#pragma mark - Private methods

- (void)finish {
    DDLogVerbose(@"%@ finish", LOG_TAG);
    
    if ([self.menuCallCapabilitiesDelegate respondsToSelector:@selector(menuDidClosed:allowVoiceCall:allowVideoCall:allowGroupCall:)]) {
        [self.menuCallCapabilitiesDelegate menuDidClosed:self allowVoiceCall:self.allowAudioCall allowVideoCall:self.allowVideoCall allowGroupCall:self.allowGroupCall];
    }
}

@end

