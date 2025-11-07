/*
 *  Copyright (c) 2017-2021 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Thibaud David (contact@thibauddavid.com)
 *   Christian Jacquemot (Christian.Jacquemot@twinlife-systems.com)
 *   Chedi Baccari (Chedi.Baccari@twinlife-systems.com)
 *   Fabrice Trescartes (fabrice.trescartes@twin.life)
 */

#import <sys/utsname.h>

#import <CocoaLumberjack.h>

#import <Twinlife/TLManagementService.h>

#import <Utils/NSString+Utils.h>

#import "FeedbackViewController.h"
#import "LogsViewController.h"

#import <TwinmeCommon/Design.h>
#import "TTTAttributedLabel.h"
#import "SwitchView.h"
#import "UIView+Toast.h"

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static NSInteger EMAIL_TEXT_FIELD_TAG = 1;
static NSInteger SUBJECT_TEXT_FIELD_TAG = 2;

//
// Interface: FeedbackViewController ()
//

@interface FeedbackViewController () <UITextFieldDelegate, UITextViewDelegate, TTTAttributedLabelDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *emailViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *emailViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *emailViewTopConstraint;
@property (weak, nonatomic) IBOutlet UIView *emailView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *emailFieldLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *emailFieldTrailingConstraint;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *subjectViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *subjectViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *subjectViewTopConstraint;
@property (weak, nonatomic) IBOutlet UIView *subjectView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *subjectFieldLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *subjectFieldTrailingConstraint;
@property (weak, nonatomic) IBOutlet UITextField *subjectField;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageViewTopConstraint;
@property (weak, nonatomic) IBOutlet UIView *messageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageTextViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageTextViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageTextViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageTextViewBottomConstraint;
@property (weak, nonatomic) IBOutlet UITextView *messageTextView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *logsViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *logsView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *logsSwitchTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *logsSwitchHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *logsSwitchWidthConstraint;
@property (weak, nonatomic) IBOutlet SwitchView *logsSwitch;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sendLogsLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sendLogsLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *sendLogsLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *infosLogsLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *infosLogsLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet UILabel *infosLogsLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *logsReportViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *logsReportView;
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *logsLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sendViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sendViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sendViewTopConstraint;
@property (weak, nonatomic) IBOutlet UIView *sendView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sendLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet UILabel *sendLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *deviceInfoLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *deviceInfoLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *deviceInfoLabelBottomConstraint;
@property (weak, nonatomic) IBOutlet UILabel *deviceInfoLabel;

@property (nonatomic) NSString *deviceInfo;

@end

//
// Implementation: FeedbackViewController
//

#undef LOG_TAG
#define LOG_TAG @"FeedbackViewController"

@implementation FeedbackViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    DDLogVerbose(@"%@ viewDidLoad", LOG_TAG);
    
    [super viewDidLoad];
    
    [self initViews];
}

- (void)viewDidAppear:(BOOL)animated {
    DDLogVerbose(@"%@ viewDidAppear", LOG_TAG);
    
    [super viewDidAppear:animated];
    
    CGFloat containerHeight = self.deviceInfoLabel.frame.origin.y + self.deviceInfoLabel.intrinsicContentSize.height + self.deviceInfoLabelBottomConstraint.constant;
    
    if (containerHeight < self.view.bounds.size.height) {
        containerHeight = self.view.bounds.size.height;
    }
    
    self.containerViewHeightConstraint.constant = containerHeight;
}

#pragma mark - IBActions

- (IBAction)onTouchUpInsideSend:(id)sender {
    DDLogVerbose(@"%@ onTouchUpInsideSend: %@", LOG_TAG, sender);
    
    if ([self.emailField isFirstResponder]) {
        [self.emailField resignFirstResponder];
    }
    
    if ([self.subjectField isFirstResponder]) {
        [self.subjectField resignFirstResponder];
    }
    
    if ([self.messageTextView isFirstResponder]) {
        [self.messageTextView resignFirstResponder];
    }
    
    NSString *subject = self.subjectField.text;
    NSString *message = self.messageTextView.text;
    if (subject.length != 0 || message.length != 0) {
        NSString *logReport = nil;        
        if (self.logsSwitch.isOn) {
            logReport = [[self.twinmeContext getManagementService] buildLogReport];
        }
        
        [[self.twinmeContext getManagementService] sendFeedbackWithDescription:message email:self.emailField.text subject:subject logReport:logReport];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication].keyWindow makeToast:TwinmeLocalizedString(@"feedback_view_controller_send_message", nil)];
    });
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    DDLogVerbose(@"%@ textFieldShouldBeginEditing: %@", LOG_TAG, textField);
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    DDLogVerbose(@"%@ textFieldShouldReturn: %@", LOG_TAG, textField);
    
    if (textField.tag == EMAIL_TEXT_FIELD_TAG) {
        [self.subjectField becomeFirstResponder];
    } else {
        [self.messageTextView becomeFirstResponder];
    }
    return NO;
}

#pragma mark - UITextViewDelegate

-(void)textViewDidBeginEditing:(UITextView *)textView {
    DDLogVerbose(@"%@ textViewDidBeginEditing: %@", LOG_TAG, textView);
    
    if ([textView.text isEqualToString:TwinmeLocalizedString(@"feedback_view_controller_message", nil)]) {
        textView.text = @"";
        textView.textColor = Design.FONT_COLOR_DEFAULT;
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    DDLogVerbose(@"%@ textViewDidEndEditing: %@", LOG_TAG, textView);
    
    if ([textView.text isEqualToString:@""]) {
        textView.text = TwinmeLocalizedString(@"feedback_view_controller_message", nil);
        textView.textColor = Design.PLACEHOLDER_COLOR;
    }
}

#pragma mark - TTTAttributedLabelDelegate

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    DDLogVerbose(@"%@ attributedLabel: %@ didSelectLinkWithURL: %@", LOG_TAG, label, url);
    
    [self showLogsReport];
}

#pragma mark - Private methods

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    self.view.backgroundColor = Design.WHITE_COLOR;
    
    [self setNavigationTitle:TwinmeLocalizedString(@"feedback_view_controller_title", nil)];
    
    self.containerViewBottomConstraint.constant *= Design.HEIGHT_RATIO;
    self.containerViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.containerViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.containerViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.containerViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.emailViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.emailViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.emailViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.emailView.backgroundColor = Design.TEXTFIELD_BACKGROUND_COLOR;
    self.emailView.layer.cornerRadius = Design.CONTAINER_RADIUS;
    self.emailView.clipsToBounds = YES;
    
    self.emailFieldLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.emailFieldTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.emailField.font = Design.FONT_REGULAR28;
    self.emailField.tag = EMAIL_TEXT_FIELD_TAG;
    self.emailField.delegate = self;
    self.emailField.keyboardType = UIKeyboardTypeEmailAddress;
    self.emailField.textColor = Design.FONT_COLOR_DEFAULT;
    self.emailField.tintColor = Design.FONT_COLOR_DEFAULT;
    self.emailField.placeholder = TwinmeLocalizedString(@"feedback_view_controller_email", nil);
    
    self.subjectViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.subjectViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.subjectViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.subjectView.backgroundColor = Design.TEXTFIELD_BACKGROUND_COLOR;
    self.subjectView.layer.cornerRadius = Design.CONTAINER_RADIUS;
    self.subjectView.clipsToBounds = YES;
    
    self.subjectFieldLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.subjectFieldTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.subjectField.font = Design.FONT_REGULAR28;
    self.subjectField.textColor = Design.FONT_COLOR_DEFAULT;
    self.subjectField.tag = SUBJECT_TEXT_FIELD_TAG;
    self.subjectField.delegate = self;
    self.subjectField.placeholder = TwinmeLocalizedString(@"feedback_view_controller_subject", nil);
    self.subjectField.tintColor = Design.FONT_COLOR_DEFAULT;
    
    self.messageViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.messageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.messageViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.messageView.backgroundColor = Design.TEXTFIELD_BACKGROUND_COLOR;
    self.messageView.layer.cornerRadius = Design.CONTAINER_RADIUS;
    self.messageView.clipsToBounds = YES;
    
    self.messageTextViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.messageTextViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.messageTextView.font = Design.FONT_REGULAR28;
    self.messageTextView.textColor = Design.PLACEHOLDER_COLOR;
    self.messageTextView.tintColor = Design.FONT_COLOR_DEFAULT;
    self.messageTextView.delegate = self;
    self.messageTextView.text = TwinmeLocalizedString(@"feedback_view_controller_message", nil);
    self.messageTextView.textContainer.lineFragmentPadding = 0;
    self.messageTextView.textContainerInset = UIEdgeInsetsZero;
        
    CGSize switchSize = [Design switchSize];
    self.logsSwitchTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.logsSwitchHeightConstraint.constant = switchSize.height;
    self.logsSwitchWidthConstraint.constant = switchSize.width;

    self.logsViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    CGFloat logMargin = (Design.DISPLAY_WIDTH - self.messageViewWidthConstraint.constant) * 0.5f;
    
    UITapGestureRecognizer *logsViewTapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwitchTapGesture:)];
    [self.logsView addGestureRecognizer:logsViewTapGesture];
    
    self.logsSwitchTrailingConstraint.constant = logMargin;
    
    self.logsSwitch.backgroundColor = Design.WHITE_COLOR;
    self.logsSwitch.isAccessibilityElement = YES;
    self.logsSwitch.accessibilityLabel = TwinmeLocalizedString(@"privacy_view_controller_lock_screen_title", nil);
    [self.logsSwitch setOn:YES];
    
    UITapGestureRecognizer *sendLogsViewTapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwitchTapGesture:)];
    [self.logsSwitch addGestureRecognizer:sendLogsViewTapGesture];
    
    self.sendLogsLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.sendLogsLabelLeadingConstraint.constant = logMargin;
    
    self.sendLogsLabel.font = Design.FONT_REGULAR34;
    self.sendLogsLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.sendLogsLabel.text = TwinmeLocalizedString(@"feedback_view_controller_send_logs", nil);
    
    self.infosLogsLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.infosLogsLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    
    self.infosLogsLabel.font = Design.FONT_REGULAR26;
    self.infosLogsLabel.textColor = Design.FONT_COLOR_GREY;
    self.infosLogsLabel.text = [NSString stringWithFormat:@"%@\n\n%@", TwinmeLocalizedString(@"feedback_view_controller_info_logs", nil), TwinmeLocalizedString(@"feedback_view_controller_help", nil)];

    self.logsReportViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.logsReportView.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *reportTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleLogsReportTapGesture:)];
    [self.logsReportView addGestureRecognizer:reportTapGesture];
    
    self.logsLabel.font = Design.FONT_REGULAR26;
    NSMutableDictionary *mutableLinkAttributes = [NSMutableDictionary dictionary];
    [mutableLinkAttributes setObject:[NSNumber numberWithBool:YES] forKey:(NSString *)kCTUnderlineStyleAttributeName];
    [mutableLinkAttributes setObject:(__bridge id)[Design.MAIN_COLOR CGColor] forKey:(NSString *)kCTForegroundColorAttributeName];
    self.logsLabel.linkAttributes = [NSDictionary dictionaryWithDictionary:mutableLinkAttributes];
        
    self.logsLabel.text = TwinmeLocalizedString(@"feedback_view_controller_logs", nil);
    
    NSString *logs = TwinmeLocalizedString(@"feedback_view_controller_logs", nil);
    NSRange logsRange = [self.logsLabel.text rangeOfString:logs];
    
    self.logsLabel.enabledTextCheckingTypes = NSTextCheckingTypeLink;
    [self.logsLabel addLinkToURL:[NSURL URLWithString:@""] withRange:logsRange];
    self.logsLabel.delegate = self;
    
    self.sendViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.sendViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.sendViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.sendView.backgroundColor = Design.MAIN_COLOR;
    self.sendView.userInteractionEnabled = YES;
    self.sendView.isAccessibilityElement = YES;
    self.sendView.accessibilityLabel = TwinmeLocalizedString(@"feedback_view_controller_send", nil);
    self.sendView.layer.cornerRadius = Design.CONTAINER_RADIUS;
    self.sendView.clipsToBounds = YES;
    [self.sendView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTouchUpInsideSend:)]];
    
    self.sendLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    
    self.sendLabel.font = Design.FONT_BOLD28;
    self.sendLabel.textColor = [UIColor whiteColor];
    self.sendLabel.text = TwinmeLocalizedString(@"feedback_view_controller_send", nil);
    
    self.deviceInfoLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.deviceInfoLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.deviceInfoLabelBottomConstraint.constant *= Design.HEIGHT_RATIO;
    self.deviceInfoLabel.font = Design.FONT_REGULAR28;
    self.deviceInfoLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.deviceInfoLabel.text = [NSString stringWithFormat:@"%@\n%@", [self deviceInfo], TwinmeLocalizedString(@"feedback_view_controller_gdpr_notice", nil)];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture)];
    [self.view addGestureRecognizer:tapGesture];
}

- (void)handleTapGesture {
    DDLogVerbose(@"%@ handleTapGesture", LOG_TAG);
    
    if ([self.emailField isFirstResponder]) {
        [self.emailField resignFirstResponder];
    }
    
    if ([self.subjectField isFirstResponder]) {
        [self.subjectField resignFirstResponder];
    }
    
    if ([self.messageTextView isFirstResponder]) {
        [self.messageTextView resignFirstResponder];
    }
}

- (NSString *)deviceInfo {
    DDLogVerbose(@"%@ deviceInfo", LOG_TAG);
    
    NSString *appVersionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString *appBuildString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    NSString *appVersion = [NSString stringWithFormat:@"%@ (build %@)", appVersionString, appBuildString];
    NSString *osVersion = [[NSProcessInfo processInfo] operatingSystemVersionString];
    
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceId = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    return [NSString stringWithFormat:@"Device model: %@\nOS version: %@\nApp version: %@", deviceId, osVersion, appVersion];
}

- (void)handleBackTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleBackTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)handleSwitchTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleSwitchTapGesture: %@", LOG_TAG, sender);
    
    [self.logsSwitch setOn:!self.logsSwitch.isOn];
}

- (void)handleLogsReportTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleLogsReportTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        [self showLogsReport];
    }
}

- (void)showLogsReport {
    DDLogVerbose(@"%@ showLogsReport", LOG_TAG);
    
    LogsViewController *logsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"LogsViewController"];
    [logsViewController initWithLogs:[[self.twinmeContext getManagementService] buildLogReport]];
    [self.navigationController pushViewController:logsViewController animated:YES];
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    self.emailField.font = Design.FONT_REGULAR28;
    self.subjectField.font = Design.FONT_REGULAR28;
    self.messageTextView.font = Design.FONT_REGULAR28;
    self.sendLabel.font = Design.FONT_BOLD28;
    self.sendLogsLabel.font = Design.FONT_REGULAR34;
    self.infosLogsLabel.font = Design.FONT_REGULAR26;
    self.logsLabel.font = Design.FONT_REGULAR26;
    self.deviceInfoLabel.font = Design.FONT_REGULAR28;
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    self.sendView.backgroundColor = Design.MAIN_COLOR;
    self.emailField.textColor = Design.FONT_COLOR_DEFAULT;
    self.emailField.tintColor = Design.FONT_COLOR_DEFAULT;
    self.subjectField.textColor = Design.FONT_COLOR_DEFAULT;
    self.subjectField.tintColor = Design.FONT_COLOR_DEFAULT;
    self.sendLogsLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.infosLogsLabel.textColor = Design.FONT_COLOR_GREY;
    self.deviceInfoLabel.textColor = Design.FONT_COLOR_DEFAULT;
    
    self.emailView.backgroundColor = Design.TEXTFIELD_BACKGROUND_COLOR;
    self.subjectView.backgroundColor = Design.TEXTFIELD_BACKGROUND_COLOR;
    self.messageView.backgroundColor = Design.TEXTFIELD_BACKGROUND_COLOR;
    
    self.emailField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:TwinmeLocalizedString(@"feedback_view_controller_email", nil) attributes:[NSDictionary dictionaryWithObject:Design.PLACEHOLDER_COLOR forKey:NSForegroundColorAttributeName]];
    self.subjectField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:TwinmeLocalizedString(@"feedback_view_controller_subject", nil) attributes:[NSDictionary dictionaryWithObject:Design.PLACEHOLDER_COLOR forKey:NSForegroundColorAttributeName]];
}

@end
