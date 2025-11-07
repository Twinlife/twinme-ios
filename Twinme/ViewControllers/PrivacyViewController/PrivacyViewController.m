/*
 *  Copyright (c) 2021 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <LocalAuthentication/LocalAuthentication.h>

#import "PrivacyViewController.h"

#import <TwinmeCommon/Design.h>
#import "InsideBorderView.h"
#import "SwitchView.h"
#import "UIPremiumFeature.h"
#import "PremiumFeatureConfirmView.h"

#import <Utils/NSString+Utils.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

//
// Interface: PrivacyViewController
//

@interface PrivacyViewController ()<ConfirmViewDelegate>

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

- (void)viewDidLayoutSubviews {
    DDLogVerbose(@"%@ viewDidLayoutSubviews", LOG_TAG);
    
    [self.lockScreenView clearBorder];
    [self.hideLastScreenView clearBorder];
    [self.hideRecentCallsView clearBorder];
    
    CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
    
    [self.lockScreenView setBorder:Design.SEPARATOR_COLOR_GREY borderWidth:Design.SEPARATOR_HEIGHT width:screenWidth height:self.lockScreenView.frame.size.height left:false right:false top:false bottom:true];
    [self.hideLastScreenView setBorder:Design.SEPARATOR_COLOR_GREY borderWidth:Design.SEPARATOR_HEIGHT width:screenWidth height:self.hideLastScreenView.frame.size.height left:false right:false top:true bottom:true];
    [self.hideRecentCallsView setBorder:Design.SEPARATOR_COLOR_GREY borderWidth:Design.SEPARATOR_HEIGHT width:screenWidth height:self.hideRecentCallsView.frame.size.height left:false right:false top:true bottom:true];
}

#pragma mark - ConfirmViewDelegate

- (void)didTapConfirm:(nonnull AbstractConfirmView *)abstractConfirmView {
    DDLogVerbose(@"%@ didTapConfirm: %@", LOG_TAG, abstractConfirmView);
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:TwinmeLocalizedString(@"twinme_plus_link", nil)] options:@{} completionHandler:nil];

    [abstractConfirmView closeConfirmView];
}

- (void)didTapCancel:(nonnull AbstractConfirmView *)abstractConfirmView {
    DDLogVerbose(@"%@ didTapCancel: %@", LOG_TAG, abstractConfirmView);
    
    [abstractConfirmView closeConfirmView];
}

- (void)didClose:(nonnull AbstractConfirmView *)abstractConfirmView {
    DDLogVerbose(@"%@ didClose: %@", LOG_TAG, abstractConfirmView);
    
    [abstractConfirmView closeConfirmView];
}

- (void)didFinishCloseAnimation:(nonnull AbstractConfirmView *)abstractConfirmView {
    DDLogVerbose(@"%@ didFinishCloseAnimation: %@", LOG_TAG, abstractConfirmView);
    
    [abstractConfirmView removeFromSuperview];
}

#pragma mark - Private methods

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    self.view.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
    
    [self setNavigationTitle:TwinmeLocalizedString(@"privacy_view_controller_title", nil)];
    
    self.lockScreenViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.lockScreenView.backgroundColor = Design.WHITE_COLOR;
    self.lockScreenView.isAccessibilityElement = YES;
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
    
    self.lockScreenSwitch.userInteractionEnabled = NO;
    self.lockScreenSwitch.isEnabled = NO;
    [self.lockScreenSwitch setOn:NO];
    
    self.lockScreenInformationLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.lockScreenInformationLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.lockScreenInformationLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.lockScreenInformationLabel.text = TwinmeLocalizedString(@"privacy_view_controller_lock_screen_message", nil);
    self.lockScreenInformationLabel.font = Design.FONT_REGULAR28;
    self.lockScreenInformationLabel.textColor = Design.FONT_COLOR_GREY;
    
    self.hideLastScreenViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.hideLastScreenViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.hideLastScreenView.backgroundColor = Design.WHITE_COLOR;
    self.hideLastScreenView.isAccessibilityElement = YES;
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

    self.hideLastScreenSwitch.userInteractionEnabled = NO;
    self.hideLastScreenSwitch.isEnabled = NO;
    [self.hideLastScreenSwitch setOn:NO];
    
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
    
    self.hideRecentCallsSwitch.userInteractionEnabled = NO;
    self.hideRecentCallsSwitch.isEnabled = NO;
    [self.hideRecentCallsSwitch setOn:NO];
}

- (void)handleSwitchTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleSwitchTapGesture: %@", LOG_TAG, sender);
    
    PremiumFeatureConfirmView *premiumFeatureConfirmView = [[PremiumFeatureConfirmView alloc] init];
    premiumFeatureConfirmView.confirmViewDelegate = self;
    [premiumFeatureConfirmView initWithPremiumFeature:[[UIPremiumFeature alloc]initWithFeatureType:FeatureTypePrivacy] parentViewController:self.navigationController];
    [self.navigationController.view addSubview:premiumFeatureConfirmView];
    [premiumFeatureConfirmView showConfirmView];
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    self.lockScreenLabel.font = Design.FONT_REGULAR34;
    self.hideLastScreenLabel.font = Design.FONT_REGULAR34;
    self.hideLastScreenInformationLabel.font = Design.FONT_REGULAR28;
    self.lockScreenInformationLabel.font = Design.FONT_REGULAR28;
    self.hideRecentCallsLabel.font = Design.FONT_REGULAR34;
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    self.view.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
    
    self.lockScreenLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.hideLastScreenLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.hideRecentCallsLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.hideLastScreenInformationLabel.textColor = Design.FONT_COLOR_GREY;
    self.lockScreenInformationLabel.textColor = Design.FONT_COLOR_GREY;
    self.lockScreenView.backgroundColor = Design.WHITE_COLOR;
    self.hideLastScreenView.backgroundColor = Design.WHITE_COLOR;
}

@end
