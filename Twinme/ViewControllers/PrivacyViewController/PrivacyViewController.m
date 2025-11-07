/*
 *  Copyright (c) 2021-2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <LocalAuthentication/LocalAuthentication.h>

#import "PrivacyViewController.h"

#import "MenuSelectValueView.h"
#import <TwinmeCommon/Design.h>
#import "InsideBorderView.h"
#import "SwitchView.h"
#import "AlertMessageView.h"
#import "UITimeout.h"

#import <Utils/NSString+Utils.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static const CGFloat DESIGN_HIDE_LAST_SCREEN_TOP_MARGIN = 80;

//
// Interface: PrivacyViewController
//

@interface PrivacyViewController ()<SwitchViewDelegate, AlertMessageViewDelegate, MenuSelectValueDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lockScreenViewHeightConstraint;
@property (weak, nonatomic) IBOutlet InsideBorderView *lockScreenView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lockScreenLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lockScreenLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lockScreenLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lockScreenLabelBottomConstraint;
@property (weak, nonatomic) IBOutlet UILabel *lockScreenLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lockScreenSwitchTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lockScreenSwitchHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lockScreenSwitchWidthConstraint;
@property (weak, nonatomic) IBOutlet SwitchView *lockScreenSwitch;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lockScreenInformationLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lockScreenInformationLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lockScreenInformationLabelTopConstraint;
@property (weak, nonatomic) IBOutlet UILabel *lockScreenInformationLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *hideLastScreenViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *hideLastScreenViewTopConstraint;
@property (weak, nonatomic) IBOutlet InsideBorderView *hideLastScreenView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *hideLastScreenLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *hideLastScreenLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *hideLastScreenLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *hideLastScreenLabelBottomConstraint;
@property (weak, nonatomic) IBOutlet UILabel *hideLastScreenLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *hideLastScreenSwitchTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *hideLastScreenSwitchHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *hideLastScreenSwitchWidthConstraint;
@property (weak, nonatomic) IBOutlet SwitchView *hideLastScreenSwitch;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *hideLastScreenInformationLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *hideLastScreenInformationLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *hideLastScreenInformationLabelTopConstraint;
@property (weak, nonatomic) IBOutlet UILabel *hideLastScreenInformationLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lockScreenTimeoutViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lockScreenTimeoutViewTopConstraint;
@property (weak, nonatomic) IBOutlet InsideBorderView *lockScreenTimeoutView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lockScreenTimeoutTitleLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lockScreenTimeoutTitleLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet UILabel *lockScreenTimeoutTitleLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lockScreenTimeoutLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lockScreenTimeoutLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *lockScreenTimeoutLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *hideRecentCallsViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *hideRecentCallsViewTopConstraint;
@property (weak, nonatomic) IBOutlet InsideBorderView *hideRecentCallsView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *hideRecentCallsLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *hideRecentCallsLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *hideRecentCallsLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *hideRecentCallsLabelBottomConstraint;
@property (weak, nonatomic) IBOutlet UILabel *hideRecentCallsLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *hideRecentCallsSwitchTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *hideRecentCallsSwitchHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *hideRecentCallsSwitchWidthConstraint;
@property (weak, nonatomic) IBOutlet SwitchView *hideRecentCallsSwitch;

@end

//
// Implementation: PrivacyViewController
//

#undef LOG_TAG
#define LOG_TAG @"PrivacyViewController"

@implementation PrivacyViewController

- (void)viewDidLoad {
    DDLogVerbose(@"%@ viewDidLoad", LOG_TAG);
    
    [super viewDidLoad];
    
    [self initViews];
}

- (void)viewWillAppear:(BOOL)animated {
    DDLogVerbose(@"%@ viewWillAppear: %@", LOG_TAG, animated ? @"YES" : @"NO");
    
    [super viewWillAppear:animated];
    
    [self updateSettings];
}

- (void)viewDidLayoutSubviews {
    DDLogVerbose(@"%@ viewDidLayoutSubviews", LOG_TAG);
    
    [self.lockScreenView clearBorder];
    [self.hideLastScreenView clearBorder];
    [self.lockScreenTimeoutView clearBorder];
    [self.hideRecentCallsView clearBorder];
    
    CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
    
    [self.lockScreenView setBorder:Design.SEPARATOR_COLOR_GREY borderWidth:Design.SEPARATOR_HEIGHT width:screenWidth height:self.lockScreenView.frame.size.height left:false right:false top:false bottom:true];
    [self.hideLastScreenView setBorder:Design.SEPARATOR_COLOR_GREY borderWidth:Design.SEPARATOR_HEIGHT width:screenWidth height:self.hideLastScreenView.frame.size.height left:false right:false top:true bottom:true];
    [self.lockScreenTimeoutView setBorder:Design.SEPARATOR_COLOR_GREY borderWidth:Design.SEPARATOR_HEIGHT width:screenWidth height:self.lockScreenTimeoutView.frame.size.height left:false right:false top:true bottom:true];
    [self.hideRecentCallsView setBorder:Design.SEPARATOR_COLOR_GREY borderWidth:Design.SEPARATOR_HEIGHT width:screenWidth height:self.hideRecentCallsView.frame.size.height left:false right:false top:true bottom:true];
}

#pragma mark - MenuSelectValueDelegate

- (void)cancelMenuSelectValue:(MenuSelectValueView *)menuSelectValueView {
    DDLogVerbose(@"%@ cancelMenu", LOG_TAG);
    
    [menuSelectValueView removeFromSuperview];
}

- (void)selectTimeout:(MenuSelectValueView *)menuSelectValueView uiTimeout:(UITimeout *)uiTimeout {
    DDLogVerbose(@"%@ selectTimeout: %@", LOG_TAG, uiTimeout);
    
    [menuSelectValueView removeFromSuperview];

    [self.twinmeApplication setTimeoutScreenLockWithTime:(int)uiTimeout.timeout];
    self.lockScreenTimeoutLabel.text = uiTimeout.title;
}

#pragma mark - SwitchViewDelegate

- (void)switchViewDidTap:(SwitchView *)switchView {
    DDLogVerbose(@"%@ switchViewDidTap: %@", LOG_TAG, switchView);
    
    if (switchView == self.lockScreenSwitch) {
        [self.twinmeApplication setScreenLockWithState:switchView.isOn];
    } else if (switchView == self.hideLastScreenSwitch) {
        [self.twinmeApplication setHideLastScreenWithState:switchView.isOn];
    } else if (switchView == self.hideRecentCallsSwitch) {
        [self.twinmeApplication setHideRecentCallsWithState:switchView.isOn];
    }
    
    [self updateSettings];
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
    
    [self setNavigationTitle:TwinmeLocalizedString(@"privacy_view_controller_title", nil)];
    
    self.lockScreenViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.lockScreenView.backgroundColor = Design.WHITE_COLOR;
    self.lockScreenView.isAccessibilityElement = YES;
    self.lockScreenView.accessibilityLabel = TwinmeLocalizedString(@"privacy_view_controller_lock_screen_title", nil);
    UITapGestureRecognizer *lockScreenViewTapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwitchTapGesture:)];
    [self.lockScreenView addGestureRecognizer:lockScreenViewTapGesture];
    
    self.lockScreenLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.lockScreenLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.lockScreenLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.lockScreenLabelBottomConstraint.constant *= Design.HEIGHT_RATIO;
    self.lockScreenLabel.text = TwinmeLocalizedString(@"privacy_view_controller_lock_screen_title", nil);
    self.lockScreenLabel.font = Design.FONT_REGULAR34;
    self.lockScreenLabel.textColor = Design.FONT_COLOR_DEFAULT;
    
    CGSize switchSize = [Design switchSize];
    self.lockScreenSwitchTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.lockScreenSwitchHeightConstraint.constant = switchSize.height;
    self.lockScreenSwitchWidthConstraint.constant = switchSize.width;
    
    self.lockScreenSwitch.switchViewDelegate = self;
    
    self.lockScreenInformationLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.lockScreenInformationLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.lockScreenInformationLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.lockScreenInformationLabel.text = TwinmeLocalizedString(@"privacy_view_controller_lock_screen_message", nil);
    self.lockScreenInformationLabel.font = Design.FONT_REGULAR28;
    self.lockScreenInformationLabel.textColor = Design.FONT_COLOR_GREY;
    
    self.lockScreenTimeoutViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.lockScreenTimeoutViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.lockScreenTimeoutView.backgroundColor = Design.WHITE_COLOR;
    self.lockScreenTimeoutView.isAccessibilityElement = YES;
    self.lockScreenTimeoutView.accessibilityLabel = TwinmeLocalizedString(@"privacy_view_controller_lock_screen_timeout", nil);
    UITapGestureRecognizer *lockScreenTimeoutViewTapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTimeoutTapGesture:)];
    [self.lockScreenTimeoutView addGestureRecognizer:lockScreenTimeoutViewTapGesture];
    
    self.lockScreenTimeoutTitleLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.lockScreenTimeoutTitleLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.lockScreenTimeoutTitleLabel.text = TwinmeLocalizedString(@"privacy_view_controller_lock_screen_timeout", nil);
    self.lockScreenTimeoutTitleLabel.font = Design.FONT_REGULAR34;
    self.lockScreenTimeoutTitleLabel.textColor = Design.FONT_COLOR_DEFAULT;
    
    self.lockScreenTimeoutLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.lockScreenTimeoutLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.lockScreenTimeoutLabel.font = Design.FONT_REGULAR34;
    self.lockScreenTimeoutLabel.textColor = Design.FONT_COLOR_DEFAULT;
    
    if ([[UIApplication sharedApplication] userInterfaceLayoutDirection] == UIUserInterfaceLayoutDirectionRightToLeft) {
        self.lockScreenTimeoutLabel.textAlignment = NSTextAlignmentLeft;
    }
    
    self.hideLastScreenViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.hideLastScreenViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.hideLastScreenView.backgroundColor = Design.WHITE_COLOR;
    self.hideLastScreenView.isAccessibilityElement = YES;
    self.hideLastScreenView.accessibilityLabel = TwinmeLocalizedString(@"privacy_view_controller_hide_last_screen_title", nil);
    UITapGestureRecognizer *hideLastScreenViewTapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwitchTapGesture:)];
    [self.hideLastScreenView addGestureRecognizer:hideLastScreenViewTapGesture];
    
    self.hideLastScreenLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.hideLastScreenLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.hideLastScreenLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.hideLastScreenLabelBottomConstraint.constant *= Design.HEIGHT_RATIO;
    self.hideLastScreenLabel.text = TwinmeLocalizedString(@"privacy_view_controller_hide_last_screen_title", nil);
    self.hideLastScreenLabel.font = Design.FONT_REGULAR34;
    self.hideLastScreenLabel.textColor = Design.FONT_COLOR_DEFAULT;
    
    self.hideLastScreenSwitchTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.hideLastScreenSwitchHeightConstraint.constant = switchSize.height;
    self.hideLastScreenSwitchWidthConstraint.constant = switchSize.width;
    
    self.hideLastScreenSwitch.switchViewDelegate = self;
    
    self.hideLastScreenInformationLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.hideLastScreenInformationLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.hideLastScreenInformationLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.hideLastScreenInformationLabel.text = TwinmeLocalizedString(@"privacy_view_controller_hide_last_screen_message", nil);
    self.hideLastScreenInformationLabel.font = Design.FONT_REGULAR28;
    self.hideLastScreenInformationLabel.textColor = Design.FONT_COLOR_GREY;
    
    self.hideRecentCallsViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.hideRecentCallsViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.hideRecentCallsView.backgroundColor = Design.WHITE_COLOR;
    self.hideRecentCallsView.isAccessibilityElement = YES;
    self.hideRecentCallsView.accessibilityLabel = TwinmeLocalizedString(@"privacy_view_controller_display_recent_call", nil);
    UITapGestureRecognizer *hideRecentCallsViewTapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwitchTapGesture:)];
    [self.hideRecentCallsView addGestureRecognizer:hideRecentCallsViewTapGesture];
    
    self.hideRecentCallsLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.hideRecentCallsLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.hideRecentCallsLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.hideRecentCallsLabelBottomConstraint.constant *= Design.HEIGHT_RATIO;
    self.hideRecentCallsLabel.text = TwinmeLocalizedString(@"privacy_view_controller_display_recent_call", nil);
    self.hideRecentCallsLabel.font = Design.FONT_REGULAR34;
    self.hideRecentCallsLabel.textColor = Design.FONT_COLOR_DEFAULT;
    
    self.hideRecentCallsSwitchTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.hideRecentCallsSwitchHeightConstraint.constant = switchSize.height;
    self.hideRecentCallsSwitchWidthConstraint.constant = switchSize.width;
    
    self.hideRecentCallsSwitch.switchViewDelegate = self;
}

- (void)handleSwitchTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleSwitchTapGesture: %@", LOG_TAG, sender);
    
    if ([sender.view isEqual:self.lockScreenView]) {
        [self.lockScreenSwitch setOn:!self.lockScreenSwitch.isOn];
        [self.twinmeApplication setScreenLockWithState:self.lockScreenSwitch.isOn];
    } else if ([sender.view isEqual:self.hideLastScreenView]) {
        [self.hideLastScreenSwitch setOn:!self.hideLastScreenSwitch.isOn];
        [self.twinmeApplication setHideLastScreenWithState:self.hideLastScreenSwitch.isOn];
    } else if ([sender.view isEqual:self.hideRecentCallsSwitch]) {
        [self.hideRecentCallsSwitch setOn:!self.hideRecentCallsSwitch.isOn];
        [self.twinmeApplication setHideRecentCallsWithState:self.hideRecentCallsSwitch.isOn];
    }
    
    [self updateSettings];
}

- (void)handleTimeoutTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleTimeoutTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        [self openMenu];
    }
}

- (void)handleLockScreenTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleLockScreenTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        AlertMessageView *alertMessageView = [[AlertMessageView alloc] init];
        alertMessageView.alertMessageViewDelegate = self;
        [alertMessageView initWithTitle:TwinmeLocalizedString(@"delete_account_view_controller_warning", nil) message:TwinmeLocalizedString(@"lock_screen_view_controller_passcode_not_set", nil)];
        [self.navigationController.view addSubview:alertMessageView];
        [alertMessageView showAlertView];
    }
}

- (void)updateSettings {
    DDLogVerbose(@"%@ updateSettings", LOG_TAG);
    
    [self.lockScreenSwitch setOn:[self.twinmeApplication isScreenLock]];
    [self.hideLastScreenSwitch setOn:[self.twinmeApplication isLastScreenHidden]];
    [self.hideRecentCallsSwitch setOn:[self.twinmeApplication isRecentCallsHidden]];
    
    if ([self.twinmeApplication isScreenLock]) {
        self.lockScreenTimeoutView.hidden = NO;
        self.lockScreenTimeoutViewHeightConstraint.constant = Design.SETTING_CELL_HEIGHT;
        self.hideLastScreenViewTopConstraint.constant = DESIGN_HIDE_LAST_SCREEN_TOP_MARGIN * Design.HEIGHT_RATIO;
        [self updateScreenLockTimeoutTitle];
    } else {
        self.lockScreenTimeoutView.hidden = YES;
        self.lockScreenTimeoutViewHeightConstraint.constant = 0;
        self.hideLastScreenViewTopConstraint.constant = 0;
    }
    
    LAContext *context = [[LAContext alloc] init];
    
    NSError *error = nil;
    if (![context canEvaluatePolicy:LAPolicyDeviceOwnerAuthentication error:&error]) {
        self.lockScreenView.alpha = 0.5f;
        self.lockScreenLabel.alpha = 0.5f;
        [self.lockScreenSwitch setEnabled:NO];
        
        UITapGestureRecognizer *lockScreenViewTapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleLockScreenTapGesture:)];
        [self.lockScreenView addGestureRecognizer:lockScreenViewTapGesture];
    }
}

- (void)openMenu {
    DDLogVerbose(@"%@ openMenu", LOG_TAG);
    
    MenuSelectValueView *menuTimeoutView = [[MenuSelectValueView alloc] init];
    [menuTimeoutView setMenuSelectValueTypeWithType:MenuSelectValueTypeTimeoutLockScreen];
    menuTimeoutView.menuSelectValueDelegate = self;
    [menuTimeoutView setSelectedValueWithValue:[self.twinmeApplication getTimeoutScreenLock]];
    [self.tabBarController.view addSubview:menuTimeoutView];
    
    [menuTimeoutView openMenu];
}

- (void)updateScreenLockTimeoutTitle {
    DDLogVerbose(@"%@ updateScreenLockTimeoutTitle", LOG_TAG);
    
    int screenLockTimeout = [self.twinmeApplication getTimeoutScreenLock];
    self.lockScreenTimeoutLabel.text = [NSString formatTimeout:screenLockTimeout];
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    self.lockScreenLabel.font = Design.FONT_REGULAR34;
    self.hideLastScreenLabel.font = Design.FONT_REGULAR34;
    self.hideLastScreenInformationLabel.font = Design.FONT_REGULAR28;
    self.lockScreenInformationLabel.font = Design.FONT_REGULAR28;
    self.lockScreenTimeoutTitleLabel.font = Design.FONT_REGULAR34;
    self.lockScreenTimeoutLabel.font = Design.FONT_REGULAR34;
    self.hideRecentCallsLabel.font = Design.FONT_REGULAR34;
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    self.view.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
    
    self.lockScreenLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.hideLastScreenLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.hideRecentCallsLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.hideLastScreenInformationLabel.textColor = Design.FONT_COLOR_GREY;
    self.lockScreenTimeoutTitleLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.lockScreenTimeoutLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.lockScreenInformationLabel.textColor = Design.FONT_COLOR_GREY;
    self.lockScreenView.backgroundColor = Design.WHITE_COLOR;
    self.lockScreenTimeoutView.backgroundColor = Design.WHITE_COLOR;
    self.hideLastScreenView.backgroundColor = Design.WHITE_COLOR;
}

@end
