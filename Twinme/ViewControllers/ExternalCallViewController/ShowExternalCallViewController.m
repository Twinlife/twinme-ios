/*
 *  Copyright (c) 2023 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <Twinme/TLCallReceiver.h>
#import <Twinme/TLSchedule.h>

#import "ShowExternalCallViewController.h"
#import "InvitationExternalCallViewController.h"
#import "EditExternalCallViewController.h"
#import "EditIdentityViewController.h"
#import "LastCallsViewController.h"

#import <TwinmeCommon/CallReceiverService.h>

#import <Utils/NSString+Utils.h>

#import <TwinmeCommon/Design.h>
#import "MenuCallCapabilitiesView.h"
#import "MenuDateTimeView.h"
#import "SwitchView.h"

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

//
// Interface: ShowExternalCallViewController ()
//

@interface ShowExternalCallViewController ()<CallReceiverServiceDelegate, SwitchViewDelegate, MenuCallCapabilitiesDelegate, MenuDateTimeViewDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *twincodeViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *twincodeViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *twincodeViewTopConstraint;
@property (weak, nonatomic) IBOutlet UIView *twincodeView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *twincodeLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *twincodeLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *twincodeLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *twincodeImageViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *twincodeImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *twincodeImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *settingsTitleLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *settingsTitleLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *settingsTitleLabelTopConstraint;
@property (weak, nonatomic) IBOutlet UILabel *settingsTitleLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *settingsViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *settingsViewTopConstraint;
@property (weak, nonatomic) IBOutlet InsideBorderView *settingsView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *settingsLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *settingsLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *settingsLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *settingsAccessoryViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *settingsAccessoryViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *settingsAccessoryView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *limitedViewHeightConstraint;
@property (weak, nonatomic) IBOutlet InsideBorderView *limitedView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *limitedLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *limitedLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *limitedLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *limitedSwitchTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *limitedSwitchHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *limitedSwitchWidthConstraint;
@property (weak, nonatomic) IBOutlet SwitchView *limitedSwitch;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *startViewHeightConstraint;
@property (weak, nonatomic) IBOutlet InsideBorderView *startView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *startLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *startLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *startLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *startDateViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *startDateViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *startDateViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet UIView *startDateView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *startDateLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *startDateLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *startDateLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *startHourViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *startHourViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *startHourViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet UIView *startHourView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *startHourLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *startHourLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *startHourLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *endViewHeightConstraint;
@property (weak, nonatomic) IBOutlet InsideBorderView *endView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *endLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *endLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *endLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *endDateViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *endDateViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *endDateViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet UIView *endDateView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *endDateLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *endDateLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *endDateLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *endHourViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *endHourViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *endHourViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet UIView *endHourView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *endHourLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *endHourLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *endHourLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *historyTitleLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *historyTitleLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *historyTitleLabelTopConstraint;
@property (weak, nonatomic) IBOutlet UILabel *historyTitleLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lastCallViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lastCallViewTopConstraint;
@property (weak, nonatomic) IBOutlet InsideBorderView *lastCallView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lastCallImageViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lastCallImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lastCallLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lastCallLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *lastCallLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lastCallAccessoryViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lastCallAccessoryViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *lastCallAccessoryView;

@property (nonatomic) NSString *name;
@property (nonatomic) NSString *callReceiverDescription;
@property (nonatomic) NSString *identityDescription;
@property (nonatomic) UIImage *avatar;

@property (nonatomic) CallReceiverService *callReceiverService;
@property (nonatomic) TLCallReceiver *callReceiver;

@property (nonatomic) TLDate *scheduleStartDate;
@property (nonatomic) TLTime *scheduleStartTime;
@property (nonatomic) TLDate *scheduleEndDate;
@property (nonatomic) TLTime *scheduleEndTime;

@end

//
// Implementation: ShowExternalCallViewController
//

#undef LOG_TAG
#define LOG_TAG @"ShowExternalCallViewController"

@implementation ShowExternalCallViewController

- (instancetype)initWithCoder:(NSCoder *)coder {
    DDLogVerbose(@"%@ initWithCoder: %@", LOG_TAG, coder);
    
    self = [super initWithCoder:coder];
    
    if (self) {
        _callReceiverService = [[CallReceiverService alloc] initWithTwinmeContext:self.twinmeContext delegate:self];
    }
    return self;
}

- (void)viewDidLoad {
    DDLogVerbose(@"%@ viewDidLoad", LOG_TAG);
    
    [super viewDidLoad];
    
    [self initViews];
}

- (void)viewDidAppear:(BOOL)animated {
    DDLogVerbose(@"%@ viewDidAppear: %@", LOG_TAG, animated ? @"YES" : @"NO");
    
    [super viewDidAppear:animated];
}

- (void)initWithCallReceiver:(TLCallReceiver *)callReceiver {
    DDLogVerbose(@"%@ initWithCallReceiver: %@", LOG_TAG, callReceiver);
    
    self.callReceiver = callReceiver;
    
    self.name = self.callReceiver.name;
    [self.callReceiverService getImageWithCallReceiver:callReceiver withBlock:^(UIImage *image) {
        self.avatar = image;
    }];
    self.identityName = self.callReceiver.identityName;
    
    if (self.callReceiver.objectDescription) {
        self.callReceiverDescription = self.callReceiver.objectDescription;
    } else {
        self.callReceiverDescription = self.callReceiver.peerDescription;
    }
    [self.callReceiverService initWithCallReceiver:callReceiver];
}

- (void)backTap {
    DDLogVerbose(@"%@ backTap", LOG_TAG);
    
    [super backTap];
}

- (void)editTap {
    DDLogVerbose(@"%@ editTap", LOG_TAG);
    
    EditExternalCallViewController *editExternalCallViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"EditExternalCallViewController"];
    [editExternalCallViewController initWithCallReceiver:self.callReceiver];
    [self.navigationController pushViewController:editExternalCallViewController animated:YES];
}

- (void)identityTap {
    DDLogVerbose(@"%@ identityTap", LOG_TAG);
    
    self.navigationController.navigationBarHidden = NO;
    EditIdentityViewController *editIdentityViewController = (EditIdentityViewController *)[[UIStoryboard storyboardWithName:@"iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"EditIdentityViewController"];
    [editIdentityViewController initWithCallReceiver:self.callReceiver];
    [self.navigationController pushViewController:editIdentityViewController animated:YES];
}

- (int)getActionViewHeight {
    DDLogVerbose(@"%@ getActionViewHeight", LOG_TAG);
    
    UIWindow *window = UIApplication.sharedApplication.keyWindow;
    CGFloat safeAreaInset = window.safeAreaInsets.bottom;
    
    return self.lastCallView.frame.origin.y + self.lastCallViewHeightConstraint.constant + safeAreaInset;
}

#pragma mark - CallReceiverServiceDelegate

- (void)onCreateCallReceiver:(nonnull TLCallReceiver *)callReceiver {
    DDLogVerbose(@"%@ onCreateCallReceiver: %@", LOG_TAG, callReceiver);
    
}

- (void)onGetCallReceiver:(nullable TLCallReceiver *)callReceiver {
    DDLogVerbose(@"%@ onGetCallReceiver: %@", LOG_TAG, callReceiver);
    
}

- (void)onGetCallReceivers:(nonnull NSArray<TLCallReceiver *> *)callReceiver {
    DDLogVerbose(@"%@ onGetCallReceivers: %@", LOG_TAG, callReceiver);
    
}

- (void)onUpdateCallReceiver:(TLCallReceiver *)callReceiver {
    DDLogVerbose(@"%@ onUpdateCallReceiver: %@", LOG_TAG, callReceiver);
    
    if ([callReceiver.uuid isEqual:self.callReceiver.uuid]) {
        self.callReceiver = callReceiver;
        
        self.name = self.callReceiver.name;
        [self.callReceiverService getImageWithCallReceiver:callReceiver withBlock:^(UIImage *image) {
            self.avatar = image;
        }];
        self.identityName = self.callReceiver.identityName;
        
        if (self.callReceiver.objectDescription) {
            self.callReceiverDescription = self.callReceiver.objectDescription;
        } else {
            self.callReceiverDescription = self.callReceiver.peerDescription;
        }

        [self updateCallReceiver];
    }
}

- (void)onUpdateCallReceiverAvatar:(UIImage *)avatar {
    DDLogVerbose(@"%@ onUpdateCallReceiverAvatar: %@", LOG_TAG, avatar);
    
    self.avatar = avatar;
    
    [self updateCallReceiver];
}

- (void)onChangeCallReceiverTwincode:(nonnull TLCallReceiver *)callReceiver {
    DDLogVerbose(@"%@ onChangeCallReceiverTwincode: %@", LOG_TAG, callReceiver);
    
}

- (void)onDeleteCallReceiver:(nonnull NSUUID *)callReceiverId {
    DDLogVerbose(@"%@ onDeleteCallReceiver: %@", LOG_TAG, callReceiverId);
    
    if ([callReceiverId isEqual:self.callReceiver.uuid]) {
        [self finish];
    }
}

- (void)onGetTwincodeURI:(nonnull TLTwincodeURI *)uri { 
    DDLogVerbose(@"%@ onGetTwincodeURI: %@", LOG_TAG, uri);

}

#pragma mark - MenuSelectValueDelegate

- (void)menuDidClosed:(MenuCallCapabilitiesView *)menuCallCapabilitiesView allowVoiceCall:(BOOL)allowVoiceCall allowVideoCall:(BOOL)allowVideoCall allowGroupCall:(BOOL)allowGroupCall {
    DDLogVerbose(@"%@ menuDidClosed", LOG_TAG);
    
    [menuCallCapabilitiesView removeFromSuperview];
    
    [self saveCallCapabilities:allowVoiceCall allowVideoCall:allowVideoCall allowGroupCall:allowGroupCall];
}

#pragma mark - MenuDateTimeDelegate

- (void)menuDateTimeDidClosed:(MenuDateTimeView *)menuDateTimeView menuDateTimeType:(MenuDateTimeType)menuDateTimeType date:(NSDate *)date {
    DDLogVerbose(@"%@ menuDateTimeDidClosed", LOG_TAG);
    
    [menuDateTimeView removeFromSuperview];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSCalendarUnit calendarUnit = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute;
    NSDateComponents *dateComponents = [calendar components:calendarUnit fromDate:date];
    
    if (menuDateTimeType == MenuDateTimeTypeStartDate || menuDateTimeType == MenuDateTimeTypeStartHour) {
        self.scheduleStartDate = [[TLDate alloc]initWithYear:(int)dateComponents.year month:(int)dateComponents.month day:(int)dateComponents.day];
        self.scheduleStartTime = [[TLTime alloc]initWithHour:(int)dateComponents.hour minute:(int)dateComponents.minute];
    } else if (menuDateTimeType == MenuDateTimeTypeEndDate || menuDateTimeType == MenuDateTimeTypeEndHour) {
        self.scheduleEndDate = [[TLDate alloc]initWithYear:(int)dateComponents.year month:(int)dateComponents.month day:(int)dateComponents.day];
        self.scheduleEndTime = [[TLTime alloc]initWithHour:(int)dateComponents.hour minute:(int)dateComponents.minute];
    }
    
    if ([self.scheduleStartDate compare:self.scheduleEndDate] ==  NSOrderedDescending) {
        NSDateComponents *startDateComponents = [[NSDateComponents alloc] init];
        startDateComponents.day = self.scheduleStartDate.day;
        startDateComponents.month = self.scheduleStartDate.month;
        startDateComponents.year = self.scheduleStartDate.year;
        startDateComponents.hour = self.scheduleStartTime.hour;
        startDateComponents.minute = self.scheduleStartTime.minute;
        
        NSDate *startDate = [calendar dateFromComponents:startDateComponents];
        NSDate *endDate = [calendar dateByAddingUnit:NSCalendarUnitHour value:1 toDate:startDate options:NSCalendarWrapComponents];
        dateComponents = [calendar components:calendarUnit fromDate:endDate];
        self.scheduleEndDate = [[TLDate alloc]initWithYear:(int)dateComponents.year month:(int)dateComponents.month day:(int)dateComponents.day];
        self.scheduleEndTime = [[TLTime alloc]initWithHour:(int)dateComponents.hour minute:(int)dateComponents.minute];
    }
    
    [self updateSchedule:YES];
}

#pragma mark - SwitchViewDelegate

- (void)switchViewDidTap:(SwitchView *)switchView {
    DDLogVerbose(@"%@ switchViewDidTap: %@", LOG_TAG, switchView);
    
    TLCapabilities *capabilities;
    if (!self.callReceiver.capabilities) {
        capabilities = [[TLCapabilities alloc]init];
    } else {
        capabilities = [[TLCapabilities alloc] initWithCapabilities:[self.callReceiver.capabilities attributeValue]];
    }
    
    if (!capabilities.schedule) {
        [self initSchedule];
    }
    
    [self saveCallSchedule];
}

#pragma mark - Private methods

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    [super initViews];
    
    self.view.backgroundColor = Design.WHITE_COLOR;
    
    self.twincodeViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.twincodeViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.twincodeViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.twincodeView.backgroundColor = Design.MAIN_COLOR;
    self.twincodeView.userInteractionEnabled = YES;
    self.twincodeView.layer.cornerRadius = Design.CONTAINER_RADIUS;
    self.twincodeView.clipsToBounds = YES;
    [self.twincodeView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTwincodeTapGesture:)]];
    
    self.twincodeImageViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.twincodeImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.twincodeLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.twincodeLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.twincodeLabel.font = Design.FONT_MEDIUM36;
    self.twincodeLabel.textColor = [UIColor whiteColor];
    self.twincodeLabel.text = TwinmeLocalizedString(@"show_call_view_controller_code", nil);
    
    [self.twincodeLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    
    self.nameLabel.text = TwinmeLocalizedString(@"application_profile", nil);
    
    self.messageLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.messageLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    
    self.messageLabel.font = Design.FONT_REGULAR26;
    self.messageLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.messageLabel.text = TwinmeLocalizedString(@"show_call_view_controller_code_information", nil);
    
    self.nameLabel.text = TwinmeLocalizedString(@"application_profile", nil);
    
    self.settingsTitleLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.settingsTitleLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.settingsTitleLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.settingsTitleLabel.font = Design.FONT_BOLD26;
    self.settingsTitleLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.settingsTitleLabel.text = TwinmeLocalizedString(@"settings_view_controller_title", nil).uppercaseString;
    
    self.settingsViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.settingsViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    UITapGestureRecognizer *settingsViewGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSettingsTapGesture:)];
    [self.settingsView addGestureRecognizer:settingsViewGestureRecognizer];
    
    [self.settingsView setBorder:Design.SEPARATOR_COLOR_GREY borderWidth:Design.SEPARATOR_HEIGHT width:Design.DISPLAY_WIDTH height:self.settingsViewHeightConstraint.constant left:false right:false top:true bottom:true];
    
    self.settingsLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.settingsLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.settingsLabel.text = TwinmeLocalizedString(@"show_call_view_controller_setting_calls", nil);
    self.settingsAccessoryViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.settingsAccessoryViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.settingsAccessoryView.tintColor = Design.ACCESSORY_COLOR;
    self.settingsAccessoryView.image = [self.settingsAccessoryView.image imageFlippedForRightToLeftLayoutDirection];
    
    self.limitedViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    [self.limitedView setBorder:Design.SEPARATOR_COLOR_GREY borderWidth:Design.SEPARATOR_HEIGHT width:Design.DISPLAY_WIDTH height:self.limitedViewHeightConstraint.constant left:false right:false top:false bottom:true];
    
    self.limitedLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.limitedLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.limitedLabel.font = Design.FONT_REGULAR34;
    self.limitedLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.limitedLabel.text = TwinmeLocalizedString(@"show_call_view_controller_setting_limited", nil);
    
    CGSize switchSize = [Design switchSize];
    self.limitedSwitchTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.limitedSwitchHeightConstraint.constant = switchSize.height;
    self.limitedSwitchWidthConstraint.constant = switchSize.width;
    
    self.limitedSwitch.switchViewDelegate = self;
    
    self.startViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    [self.startView setBorder:Design.SEPARATOR_COLOR_GREY borderWidth:Design.SEPARATOR_HEIGHT width:Design.DISPLAY_WIDTH height:self.limitedViewHeightConstraint.constant left:false right:false top:false bottom:true];
    
    self.startLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.startLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.startLabel.font = Design.FONT_REGULAR34;
    self.startLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.startLabel.text = TwinmeLocalizedString(@"show_call_view_controller_setting_start", nil);
    
    self.startDateViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.startDateViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.startDateViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.startDateView.userInteractionEnabled = YES;
    self.startDateView.clipsToBounds = YES;
    self.startDateView.layer.cornerRadius = Design.CONTAINER_RADIUS;
    self.startDateView.layer.backgroundColor = Design.BACKGROUND_COLOR_GREY.CGColor;
    
    UITapGestureRecognizer *startDateViewGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleStartDateViewTapGesture:)];
    [self.startDateView addGestureRecognizer:startDateViewGestureRecognizer];
    
    self.startDateLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.startDateLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.startDateLabel.font = Design.FONT_REGULAR32;
    self.startDateLabel.textColor = Design.FONT_COLOR_DEFAULT;
    
    self.startHourViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.startHourViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.startHourViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.startHourView.userInteractionEnabled = YES;
    self.startHourView.clipsToBounds = YES;
    self.startHourView.layer.cornerRadius = Design.CONTAINER_RADIUS;
    self.startHourView.layer.backgroundColor = Design.BACKGROUND_COLOR_GREY.CGColor;
    
    UITapGestureRecognizer *startHourViewGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleStartHourViewTapGesture:)];
    [self.startHourView addGestureRecognizer:startHourViewGestureRecognizer];
    
    self.startHourLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.startHourLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.startHourLabel.font = Design.FONT_REGULAR32;
    self.startHourLabel.textColor = Design.FONT_COLOR_DEFAULT;
    
    self.endViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    [self.endView setBorder:Design.SEPARATOR_COLOR_GREY borderWidth:Design.SEPARATOR_HEIGHT width:Design.DISPLAY_WIDTH height:self.limitedViewHeightConstraint.constant left:false right:false top:false bottom:true];
    
    self.endLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.endLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.endLabel.font = Design.FONT_REGULAR34;
    self.endLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.endLabel.text = TwinmeLocalizedString(@"show_call_view_controller_setting_end", nil);
    
    self.endDateViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.endDateViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.endDateViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.endDateView.userInteractionEnabled = YES;
    self.endDateView.clipsToBounds = YES;
    self.endDateView.layer.cornerRadius = Design.CONTAINER_RADIUS;
    self.endDateView.layer.backgroundColor = Design.BACKGROUND_COLOR_GREY.CGColor;
    
    UITapGestureRecognizer *endDateViewGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleEndDateViewTapGesture:)];
    [self.endDateView addGestureRecognizer:endDateViewGestureRecognizer];
    
    self.endDateLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.endDateLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.endDateLabel.font = Design.FONT_REGULAR32;
    self.endDateLabel.textColor = Design.FONT_COLOR_DEFAULT;
    
    self.endHourViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.endHourViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.endHourViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.endHourView.userInteractionEnabled = YES;
    self.endHourView.clipsToBounds = YES;
    self.endHourView.layer.cornerRadius = Design.CONTAINER_RADIUS;
    self.endHourView.layer.backgroundColor = Design.BACKGROUND_COLOR_GREY.CGColor;
    
    UITapGestureRecognizer *endHourViewGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleEndHourViewTapGesture:)];
    [self.endHourView addGestureRecognizer:endHourViewGestureRecognizer];
    
    self.endHourLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.endHourLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.endHourLabel.font = Design.FONT_REGULAR32;
    self.endHourLabel.textColor = Design.FONT_COLOR_DEFAULT;
    
    self.historyTitleLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.historyTitleLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.historyTitleLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.historyTitleLabel.font = Design.FONT_BOLD26;
    self.historyTitleLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.historyTitleLabel.text = TwinmeLocalizedString(@"show_contact_view_controller_history_title", nil).uppercaseString;
    
    self.lastCallAccessoryViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.lastCallAccessoryViewHeightConstraint.constant = Design.ACCESSORY_HEIGHT;
    self.lastCallAccessoryView.tintColor = Design.ACCESSORY_COLOR;
    self.lastCallAccessoryView.image = [self.lastCallAccessoryView.image imageFlippedForRightToLeftLayoutDirection];
    
    self.lastCallViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.lastCallViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    UITapGestureRecognizer *lastCallViewGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleLastCallsTapGesture:)];
    [self.lastCallView addGestureRecognizer:lastCallViewGestureRecognizer];
    
    [self.lastCallView setBorder:Design.SEPARATOR_COLOR_GREY borderWidth:Design.SEPARATOR_HEIGHT width:Design.DISPLAY_WIDTH height:self.lastCallViewHeightConstraint.constant left:false right:false top:true bottom:true];
    
    self.lastCallImageViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.lastCallImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.lastCallLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.lastCallLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.lastCallLabel.text = TwinmeLocalizedString(@"show_contact_view_controller_last_calls", nil);
    self.lastCallLabel.font = Design.FONT_REGULAR34;
    self.lastCallLabel.textColor = Design.FONT_COLOR_DEFAULT;
    
    [self updateCallReceiver];
}

- (void)finish {
    DDLogVerbose(@"%@ finish", LOG_TAG);
    
    if (self.callReceiverService) {
        [self.callReceiverService dispose];
        self.callReceiverService = nil;
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)handleTwincodeTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleTwincodeTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        self.navigationController.navigationBarHidden = NO;
        InvitationExternalCallViewController *invitationExternalCallViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"InvitationExternalCallViewController"];
        [invitationExternalCallViewController initWithCallReceiver:self.callReceiver];
        [self.navigationController pushViewController:invitationExternalCallViewController animated:YES];
    }
}

- (void)handleLastCallsTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleLastCallsTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        LastCallsViewController *lastCallsViewController = (LastCallsViewController *)[[UIStoryboard storyboardWithName:@"Contact" bundle:nil] instantiateViewControllerWithIdentifier:@"LastCallsViewController"];
        [lastCallsViewController initWithOriginator:self.callReceiver callReceiver:YES];
        [self.navigationController pushViewController:lastCallsViewController animated:YES];
    }
}

- (void)handleStartDateViewTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleStartDateViewTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        
        NSDate *date = [NSDate date];
        
        if (self.scheduleStartDate) {
            NSDateComponents *startDateComponents = [[NSDateComponents alloc] init];
            startDateComponents.day = self.scheduleStartDate.day;
            startDateComponents.month = self.scheduleStartDate.month;
            startDateComponents.year = self.scheduleStartDate.year;
            startDateComponents.hour = self.scheduleStartTime.hour;
            startDateComponents.minute = self.scheduleStartTime.minute;
            
            NSCalendar *calendar = [NSCalendar currentCalendar];
            date = [calendar dateFromComponents:startDateComponents];
        }
        
        [self openMenuDateTime:date minimumDate:[NSDate date] menuDateTimeType:MenuDateTimeTypeStartDate];
    }
}

- (void)handleStartHourViewTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleStartHourViewTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        NSDate *date = [NSDate date];
        
        if (self.scheduleStartDate) {
            NSDateComponents *startDateComponents = [[NSDateComponents alloc] init];
            startDateComponents.day = self.scheduleStartDate.day;
            startDateComponents.month = self.scheduleStartDate.month;
            startDateComponents.year = self.scheduleStartDate.year;
            startDateComponents.hour = self.scheduleStartTime.hour;
            startDateComponents.minute = self.scheduleStartTime.minute;
            
            NSCalendar *calendar = [NSCalendar currentCalendar];
            date = [calendar dateFromComponents:startDateComponents];
        }
        
        [self openMenuDateTime:date minimumDate:[NSDate date] menuDateTimeType:MenuDateTimeTypeStartHour];
    }
}

- (void)handleEndDateViewTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleEndDateViewTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        
        NSDate *date = [NSDate date];
        NSDate *minimumDate = [NSDate date];
        
        if (self.scheduleEndDate) {
            NSDateComponents *startDateComponents = [[NSDateComponents alloc] init];
            startDateComponents.day = self.scheduleEndDate.day;
            startDateComponents.month = self.scheduleEndDate.month;
            startDateComponents.year = self.scheduleEndDate.year;
            startDateComponents.hour = self.scheduleEndTime.hour;
            startDateComponents.minute = self.scheduleEndTime.minute;
            
            NSCalendar *calendar = [NSCalendar currentCalendar];
            date = [calendar dateFromComponents:startDateComponents];
        }
        
        if (self.scheduleStartDate) {
            NSDateComponents *startDateComponents = [[NSDateComponents alloc] init];
            startDateComponents.day = self.scheduleStartDate.day;
            startDateComponents.month = self.scheduleStartDate.month;
            startDateComponents.year = self.scheduleStartDate.year;
            startDateComponents.hour = self.scheduleStartTime.hour;
            startDateComponents.minute = self.scheduleStartTime.minute;
            
            NSCalendar *calendar = [NSCalendar currentCalendar];
            minimumDate = [calendar dateFromComponents:startDateComponents];
        }
            
        [self openMenuDateTime:date minimumDate:minimumDate menuDateTimeType:MenuDateTimeTypeEndDate];
    }
}

- (void)handleEndHourViewTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleStartHourViewTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        NSDate *date = [NSDate date];
        NSDate *minimumDate = [NSDate date];
        
        if (self.scheduleEndDate) {
            NSDateComponents *startDateComponents = [[NSDateComponents alloc] init];
            startDateComponents.day = self.scheduleEndDate.day;
            startDateComponents.month = self.scheduleEndDate.month;
            startDateComponents.year = self.scheduleEndDate.year;
            startDateComponents.hour = self.scheduleEndTime.hour;
            startDateComponents.minute = self.scheduleEndTime.minute;
            
            NSCalendar *calendar = [NSCalendar currentCalendar];
            date = [calendar dateFromComponents:startDateComponents];
        }
        
        if (self.scheduleStartDate) {
            NSDateComponents *startDateComponents = [[NSDateComponents alloc] init];
            startDateComponents.day = self.scheduleStartDate.day;
            startDateComponents.month = self.scheduleStartDate.month;
            startDateComponents.year = self.scheduleStartDate.year;
            startDateComponents.hour = self.scheduleStartTime.hour;
            startDateComponents.minute = self.scheduleStartTime.minute;
            
            NSCalendar *calendar = [NSCalendar currentCalendar];
            minimumDate = [calendar dateFromComponents:startDateComponents];
        }
            
        [self openMenuDateTime:date minimumDate:minimumDate menuDateTimeType:MenuDateTimeTypeEndHour];
    }
}

- (void)handleSettingsTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleSettingsTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        [self openMenuCallCapabilities];
    }
}

- (void)updateCallReceiver {
    DDLogVerbose(@"%@ updateCallReceiver", LOG_TAG);
    
    self.avatarView.image = self.avatar;
    self.nameLabel.text =  self.name;
    
    if ([self.callReceiverDescription isEqual:TwinmeLocalizedString(@"side_menu_view_controller_about", nil)]) {
        self.descriptionLabel.text = @"";
    } else {
        self.descriptionLabel.text = self.callReceiverDescription;
    }
    
    self.identityLabel.text = self.identityName;
    [self.callReceiverService getIdentityImageWithCallReceiver:self.callReceiver withBlock:^(UIImage *image) {
        self.identityAvatarView.image = image;
    }];
    
    [self updateCallCapabilities];
}

- (void)updateCallCapabilities {
    DDLogVerbose(@"%@ updateCallCapabilities", LOG_TAG);
    
    TLCapabilities *capabilities;
    
    if (!self.callReceiver.capabilities) {
        capabilities = [[TLCapabilities alloc]init];
    } else {
        capabilities = [[TLCapabilities alloc] initWithCapabilities:[self.callReceiver.capabilities attributeValue]];
    }
    
    NSMutableAttributedString *capabilitiesAttributedString = [[NSMutableAttributedString alloc] initWithString:@""];
    
    if ([capabilities hasAudio]) {
        [capabilitiesAttributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:TwinmeLocalizedString(@"show_contact_view_controller_audio", nil) attributes:[NSDictionary dictionaryWithObjectsAndKeys:Design.FONT_REGULAR32, NSFontAttributeName, Design.FONT_COLOR_GREY, NSForegroundColorAttributeName, nil]]];
    }
    
    if ([capabilities hasVideo]) {
        if (capabilitiesAttributedString.length > 0) {
            [capabilitiesAttributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:TwinmeLocalizedString(@", ", nil) attributes:[NSDictionary dictionaryWithObjectsAndKeys:Design.FONT_REGULAR32, NSFontAttributeName, Design.FONT_COLOR_GREY, NSForegroundColorAttributeName, nil]]];
        }
        [capabilitiesAttributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:TwinmeLocalizedString(@"show_contact_view_controller_video", nil) attributes:[NSDictionary dictionaryWithObjectsAndKeys:Design.FONT_REGULAR32, NSFontAttributeName, Design.FONT_COLOR_GREY, NSForegroundColorAttributeName, nil]]];
    }
    
    if ([capabilities hasGroupCall]) {
        if (capabilitiesAttributedString.length > 0) {
            [capabilitiesAttributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:TwinmeLocalizedString(@", ", nil) attributes:[NSDictionary dictionaryWithObjectsAndKeys:Design.FONT_REGULAR32, NSFontAttributeName, Design.FONT_COLOR_GREY, NSForegroundColorAttributeName, nil]]];
        }
        [capabilitiesAttributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:TwinmeLocalizedString(@"show_group_view_controller_title", nil) attributes:[NSDictionary dictionaryWithObjectsAndKeys:Design.FONT_REGULAR32, NSFontAttributeName, Design.FONT_COLOR_GREY, NSForegroundColorAttributeName, nil]]];
    }
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:TwinmeLocalizedString(@"show_call_view_controller_setting_calls", nil) attributes:[NSDictionary dictionaryWithObjectsAndKeys:Design.FONT_REGULAR34, NSFontAttributeName, Design.FONT_COLOR_DEFAULT, NSForegroundColorAttributeName, nil]];
    
    if (capabilitiesAttributedString.length > 0) {
        [attributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:@"\n"]];
        [attributedString appendAttributedString:capabilitiesAttributedString];
    }
    
    self.settingsLabel.attributedText = attributedString;
    
    if (capabilities.schedule) {
        [self.limitedSwitch setOn:capabilities.schedule.enabled];
        if (capabilities.schedule.enabled) {
            self.startView.hidden = NO;
            self.endView.hidden = NO;
            self.startViewHeightConstraint.constant = Design.SETTING_CELL_HEIGHT;
            self.endViewHeightConstraint.constant = Design.SETTING_CELL_HEIGHT;;
        } else {
            self.startView.hidden = YES;
            self.endView.hidden = YES;
            self.startViewHeightConstraint.constant = 0;
            self.endViewHeightConstraint.constant = 0;
        }
        
        if (capabilities.schedule.timeRanges.count > 0) {
            TLDateTimeRange *dateTimeRange = (TLDateTimeRange *)[capabilities.schedule.timeRanges objectAtIndex:0];
            self.scheduleStartDate = dateTimeRange.start.date;
            self.scheduleStartTime = dateTimeRange.start.time;
            self.scheduleEndDate = dateTimeRange.end.date;
            self.scheduleEndTime = dateTimeRange.end.time;
            
            [self updateSchedule:NO];
        } else {
            self.startDateLabel.text = @"";
            self.startHourLabel.text = @"";
            self.endDateLabel.text = @"";
            self.endHourLabel.text = @"";
        }
    } else {
        [self.limitedSwitch setOn:NO];
        self.startView.hidden = YES;
        self.endView.hidden = YES;
        self.startViewHeightConstraint.constant = 0;
        self.endViewHeightConstraint.constant = 0;
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3f * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        int actionViewHeight = [self getActionViewHeight];
        if (actionViewHeight != -1) {
            int heightDiff = Design.DISPLAY_HEIGHT - actionViewHeight;
            if (heightDiff < 0) {
                [self.actionView setSlideContactTopMargin:heightDiff];
            }
            self.actionViewHeightConstraint.constant = actionViewHeight;
        }
        self.containerViewHeightConstraint.constant = [self getScrollViewContentHeight];
    });
}

- (void)initSchedule {
    DDLogVerbose(@"%@ initSchedule", LOG_TAG);
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSCalendarUnit calendarUnit = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute;
    NSDate *date = [NSDate date];
    NSDateComponents *dateComponents = [calendar components:calendarUnit fromDate:date];
    self.scheduleStartDate = [[TLDate alloc]initWithYear:(int)dateComponents.year month:(int)dateComponents.month day:(int)dateComponents.day];
    
    date = [calendar dateByAddingUnit:NSCalendarUnitHour value:1 toDate:date options:NSCalendarWrapComponents];
    dateComponents = [calendar components:calendarUnit fromDate:date];
    self.scheduleStartTime = [[TLTime alloc]initWithHour:(int)dateComponents.hour minute:0];
    
    date = [calendar dateByAddingUnit:NSCalendarUnitHour value:1 toDate:date options:NSCalendarWrapComponents];
    dateComponents = [calendar components:calendarUnit fromDate:date];
    self.scheduleEndDate = [[TLDate alloc]initWithYear:(int)dateComponents.year month:(int)dateComponents.month day:(int)dateComponents.day];
    self.scheduleEndTime = [[TLTime alloc]initWithHour:(int)dateComponents.hour minute:0];
}

- (void)updateSchedule:(BOOL)save {
    DDLogVerbose(@"%@ updateSchedule", LOG_TAG);
    
    NSDateComponents *startDateComponents = [[NSDateComponents alloc] init];
    startDateComponents.day = self.scheduleStartDate.day;
    startDateComponents.month = self.scheduleStartDate.month;
    startDateComponents.year = self.scheduleStartDate.year;
    startDateComponents.hour = self.scheduleStartTime.hour;
    startDateComponents.minute = self.scheduleStartTime.minute;
    
    NSDateComponents *endDateComponents = [[NSDateComponents alloc] init];
    endDateComponents.day = self.scheduleEndDate.day;
    endDateComponents.month = self.scheduleEndDate.month;
    endDateComponents.year = self.scheduleEndDate.year;
    endDateComponents.hour = self.scheduleEndTime.hour;
    endDateComponents.minute = self.scheduleEndTime.minute;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *startDate = [calendar dateFromComponents:startDateComponents];
    NSDate *endDate = [calendar dateFromComponents:endDateComponents];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.locale = [NSLocale currentLocale];
    [dateFormatter setDateFormat:@"dd MMM yyyy"];
    
    self.startDateLabel.text = [dateFormatter stringFromDate:startDate];
    self.endDateLabel.text = [dateFormatter stringFromDate:endDate];
    
    [dateFormatter setDateFormat:@"HH:mm"];
    self.startHourLabel.text = [dateFormatter stringFromDate:startDate];
    self.endHourLabel.text = [dateFormatter stringFromDate:endDate];
    
    if (save) {
        [self saveCallSchedule];
    }
}

- (void)saveCallCapabilities:(BOOL)allowVoiceCall allowVideoCall:(BOOL)allowVideoCall allowGroupCall:(BOOL)allowGroupCall {
    DDLogVerbose(@"%@ saveCallCapabilities", LOG_TAG);
    
    TLCapabilities *capabilities;
    
    if (!self.callReceiver.capabilities) {
        capabilities = [[TLCapabilities alloc]init];
    } else {
        capabilities = [[TLCapabilities alloc] initWithCapabilities:[self.callReceiver.capabilities attributeValue]];
    }
    
    if ([capabilities hasAudio] == allowVoiceCall && [capabilities hasVideo] == allowVideoCall && [capabilities hasGroupCall] == allowGroupCall) {
        return;
    }
    
    [capabilities setCapAudioWithValue:allowVoiceCall];
    [capabilities setCapVideoWithValue:allowVideoCall];
    [capabilities setCapGroupCallWithValue:allowGroupCall];
    
    [self.callReceiverService updateCallReceiverWithCallReceiver:self.callReceiver name:self.callReceiver.name description:self.callReceiver.objectDescription identityName:self.callReceiver.identityName identityDescription:self.callReceiver.identityDescription avatar:nil largeAvatar:nil capabilities:capabilities];
}

- (void)saveCallSchedule {
    DDLogVerbose(@"%@ saveCallSchedule", LOG_TAG);
    
    TLCapabilities *capabilities;
    
    if (!self.callReceiver.capabilities) {
        capabilities = [[TLCapabilities alloc]init];
    } else {
        capabilities = [[TLCapabilities alloc] initWithCapabilities:[self.callReceiver.capabilities attributeValue]];
    }
    
    TLDateTime *startDateTime = [[TLDateTime alloc]initWithDate:self.scheduleStartDate time:self.scheduleStartTime];
    TLDateTime *endDateTime = [[TLDateTime alloc]initWithDate:self.scheduleEndDate time:self.scheduleEndTime];
    TLDateTimeRange *dateTimeRange = [[TLDateTimeRange alloc]initWithStart:startDateTime end:endDateTime];
    
    TLSchedule *schedule = [[TLSchedule alloc]initWithPrivate:NO timeZone:[NSTimeZone localTimeZone] timeRanges:@[dateTimeRange]];
    [schedule setEnabled:self.limitedSwitch.isOn];
    [capabilities setSchedule:schedule];
    
    [self.callReceiverService updateCallReceiverWithCallReceiver:self.callReceiver name:self.callReceiver.name description:self.callReceiver.objectDescription identityName:self.callReceiver.identityName identityDescription:self.callReceiver.identityDescription avatar:nil largeAvatar:nil capabilities:capabilities];
}

- (void)openMenuCallCapabilities {
    DDLogVerbose(@"%@ openMenuCallCapabilities", LOG_TAG);
    
    MenuCallCapabilitiesView *menuCallCapabilitiesView = [[MenuCallCapabilitiesView alloc]init];
    menuCallCapabilitiesView.menuCallCapabilitiesDelegate = self;
    [self.tabBarController.view addSubview:menuCallCapabilitiesView];
    
    TLCapabilities *capabilities;
    if (!self.callReceiver.capabilities) {
        capabilities = [[TLCapabilities alloc]init];
    } else {
        capabilities = [[TLCapabilities alloc] initWithCapabilities:[self.callReceiver.capabilities attributeValue]];
    }
    
    [menuCallCapabilitiesView openMenu:capabilities];
}

- (void)openMenuDateTime:(NSDate *)date minimumDate:(NSDate *)minimumDate menuDateTimeType:(MenuDateTimeType)menuDateTimeType {
    DDLogVerbose(@"%@ openMenuDateTime", LOG_TAG);
        
    MenuDateTimeView *menuDateTimeView = [[MenuDateTimeView alloc]init];
    menuDateTimeView.menuDateTimeViewDelegate = self;
    [self.tabBarController.view addSubview:menuDateTimeView];
        
    [menuDateTimeView setMenuDateTimeTypeWithType:menuDateTimeType];
    [menuDateTimeView openMenu:minimumDate date:date];
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    [super updateFont];
    
    self.descriptionLabel.font = Design.FONT_MEDIUM34;
    self.twincodeLabel.font = Design.FONT_REGULAR30;
    self.messageLabel.font = Design.FONT_REGULAR26;
    self.historyTitleLabel.font = Design.FONT_BOLD26;
    self.settingsTitleLabel.font = Design.FONT_BOLD26;
    self.settingsLabel.font = Design.FONT_REGULAR34;
    self.limitedLabel.font = Design.FONT_REGULAR34;
    self.startLabel.font = Design.FONT_REGULAR34;
    self.startDateLabel.font = Design.FONT_REGULAR32;
    self.startHourLabel.font = Design.FONT_REGULAR32;
    self.endLabel.font = Design.FONT_REGULAR34;
    self.endDateLabel.font = Design.FONT_REGULAR32;
    self.endHourLabel.font = Design.FONT_REGULAR32;
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    [super updateColor];
    
    self.view.backgroundColor = Design.WHITE_COLOR;
    self.descriptionLabel.textColor = Design.FONT_COLOR_DESCRIPTION;
    self.twincodeView.backgroundColor = Design.MAIN_COLOR;
    self.messageLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.settingsTitleLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.historyTitleLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.limitedLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.startLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.startDateView.layer.backgroundColor = Design.BACKGROUND_COLOR_GREY.CGColor;
    self.startDateLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.startHourView.layer.backgroundColor = Design.BACKGROUND_COLOR_GREY.CGColor;
    self.startHourLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.endLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.endDateView.layer.backgroundColor = Design.BACKGROUND_COLOR_GREY.CGColor;
    self.endDateLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.endHourView.layer.backgroundColor = Design.BACKGROUND_COLOR_GREY.CGColor;
    self.endHourLabel.textColor = Design.FONT_COLOR_DEFAULT;
    
    [self updateCallCapabilities];
}

@end
