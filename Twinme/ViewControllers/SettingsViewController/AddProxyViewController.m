/*
 *  Copyright (c) 2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <Twinlife/TLConnectivityService.h>
#import <Twinlife/TLProxyDescriptor.h>

#import <Utils/NSString+Utils.h>

#import "AddProxyViewController.h"
#import <TwinmeCommon/Design.h>

#import "OnboardingConfirmView.h"
#import "DefaultConfirmView.h"
#import "AlertMessageView.h"
#import "TwinmeTextField.h"

#import <TwinmeCommon/ProxyService.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static NSString * URL_PATTERN = @"((http|https)://)?([(w|W)]{3}+\\.)?+(.)+\\.+[A-Za-z]{2,3}+(\\.)?+(/(.)*)?";
static NSString * IP_PATTERN = @"^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}$";

//
// Interface: AddProxyViewController ()
//

@interface AddProxyViewController () <UITextFieldDelegate, ConfirmViewDelegate, AlertMessageViewDelegate, ProxyServiceDelegate>

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *proxyViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *proxyViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *proxyViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *proxyView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *proxyTextFieldLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *proxyTextFieldTrailingConstraint;
@property (weak, nonatomic) IBOutlet TwinmeTextField *proxyTextField;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *saveProxyViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *saveProxyViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *saveProxyViewWidthConstraint;
@property (weak, nonatomic) IBOutlet UIView *saveProxyView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *saveProxyLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet UILabel *saveProxyLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *formatLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *formatLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet UILabel *formatLabel;

@property (nonatomic) BOOL keyboardHidden;
@property (nonatomic) BOOL showOnboardingView;

@property (nonatomic) ProxyService *proxyService;

@end

//
// Implementation: AddProxyViewController
//

#undef LOG_TAG
#define LOG_TAG @"AddProxyViewController"

@implementation AddProxyViewController

#pragma mark - UIViewController

- (instancetype)initWithCoder:(NSCoder *)coder {
    DDLogVerbose(@"%@ initWithCoder: %@", LOG_TAG, coder);
    
    self = [super initWithCoder:coder];
    
    if (self) {
        _keyboardHidden = YES;
        _proxyService = [[ProxyService alloc] initWithTwinmeContext:self.twinmeContext delegate:self];
    }
    return self;
}

- (void)viewDidLoad {
    DDLogVerbose(@"%@ viewDidLoad", LOG_TAG);
    
    [super viewDidLoad];
    
    [self initViews];
}

- (void)viewWillAppear:(BOOL)animated {
    DDLogVerbose(@"%@ viewWillAppear: %@", LOG_TAG, animated ? @"YES" : @"NO");
    
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didPasteItemNotification:) name:TwinmeTextFieldDidPasteItemNotification object:nil];
    
    if (!self.showOnboardingView && !self.proxyDescriptor && [self.twinmeApplication startOnboarding:OnboardingTypeProxy]) {
        [self showOnboarding:YES];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    DDLogVerbose(@"%@ viewWillDisappear: %@", LOG_TAG, animated ? @"YES" : @"NO");
    
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TwinmeTextFieldDidPasteItemNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TwinmeTextFieldDeleteBackWardNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    DDLogVerbose(@"%@ viewDidAppear: %@", LOG_TAG, animated ? @"YES" : @"NO");
    
    [super viewDidAppear:animated];
}

- (void)didPasteItemNotification:(NSNotification *)notification {
    DDLogVerbose(@"%@ didPasteItemNotification: %@", LOG_TAG, notification);
    
    NSString *pastedContent = (NSString *)notification.object;

    if ([pastedContent containsString:TLTwincodeURI.PROXY_ACTION]) {
        pastedContent = [pastedContent stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@/", TLTwincodeURI.PROXY_ACTION] withString:@""];
    }
    
    self.proxyTextField.text = pastedContent;
    [self setUpdated];
}

#pragma mark - ProxyServiceDelegate

- (void)onAddProxy:(nonnull TLSNIProxyDescriptor *)proxyDescriptor {
    DDLogVerbose(@"%@ onAddProxy: %@", LOG_TAG, proxyDescriptor);
    
    [self finish];
}

- (void)onDeleteProxy:(nonnull TLSNIProxyDescriptor *)proxyDescriptor {
    DDLogVerbose(@"%@ onDeleteProxy: %@", LOG_TAG, proxyDescriptor);
    
    if ([proxyDescriptor isEqual:self.proxyDescriptor]) {
        [self finish];
    }
}

- (void)onErrorAddProxy {
    DDLogVerbose(@"%@ onErrorAddProxy", LOG_TAG);
        
    [self showAlertMessage:TwinmeLocalizedString(@"proxy_view_controller_invalid_format", nil)];
}

- (void)onErrorAlreadyUsed {
    DDLogVerbose(@"%@ onErrorAlreadyUsed", LOG_TAG);
    
    [self showAlertMessage:TwinmeLocalizedString(@"proxy_view_controller_already_use", nil)];
}

- (void)onErrorLimitReached {
    DDLogVerbose(@"%@ onErrorLimitReached", LOG_TAG);
    
    [self showAlertMessage:TwinmeLocalizedString(@"proxy_view_controller_limit", nil)];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    DDLogVerbose(@"%@ textFieldShouldReturn: %@", LOG_TAG, textField);
    
    [textField resignFirstResponder];
    
    return NO;
}

- (void)textFieldDidChange:(UITextField *)textField{
    DDLogVerbose(@"%@ textFieldDidChange: %@", LOG_TAG, textField);
    
    [self setUpdated];
}

#pragma mark - ConfirmViewDelegate

- (void)didTapConfirm:(nonnull AbstractConfirmView *)abstractConfirmView {
    DDLogVerbose(@"%@ didTapConfirm: %@", LOG_TAG, abstractConfirmView);

    [abstractConfirmView closeConfirmView];
}

- (void)didTapCancel:(nonnull AbstractConfirmView *)abstractConfirmView {
    DDLogVerbose(@"%@ didTapCancel: %@", LOG_TAG, abstractConfirmView);
    
    [abstractConfirmView closeConfirmView];
    [self.twinmeApplication setShowOnboardingType:OnboardingTypeProxy state:NO];
}

- (void)didClose:(nonnull AbstractConfirmView *)abstractConfirmView {
    DDLogVerbose(@"%@ didClose: %@", LOG_TAG, abstractConfirmView);
    
    [abstractConfirmView closeConfirmView];
}

- (void)didFinishCloseAnimation:(nonnull AbstractConfirmView *)abstractConfirmView {
    DDLogVerbose(@"%@ didFinishCloseAnimation: %@", LOG_TAG, abstractConfirmView);
    
    if (!self.showOnboardingView) {
        self.showOnboardingView = YES;
        [self.proxyTextField becomeFirstResponder];
    }
    
    [abstractConfirmView removeFromSuperview];
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
        
    self.view.backgroundColor = Design.WHITE_COLOR;
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)]];
    
    [self setNavigationTitle:TwinmeLocalizedString(@"proxy_view_controller_title", nil)];
                
    self.proxyViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.proxyViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.proxyViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.proxyView.backgroundColor = Design.TEXTFIELD_BACKGROUND_COLOR;
    self.proxyView.layer.cornerRadius = Design.CONTAINER_RADIUS;
    self.proxyView.clipsToBounds = YES;
    
    self.proxyTextFieldLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.proxyTextFieldTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.proxyTextField.font = Design.FONT_REGULAR44;
    self.proxyTextField.textColor = Design.FONT_COLOR_DEFAULT;
    self.proxyTextField.tintColor = Design.FONT_COLOR_DEFAULT;
    self.proxyTextField.placeholder = TwinmeLocalizedString(@"application_name_hint", nil);
    [self.proxyTextField setReturnKeyType:UIReturnKeyDone];
    self.proxyTextField.delegate = self;
    [self.proxyTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    self.saveProxyViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.saveProxyViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.saveProxyViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    
    self.saveProxyView.backgroundColor = Design.MAIN_COLOR;
    self.saveProxyView.userInteractionEnabled = YES;
    self.saveProxyView.isAccessibilityElement = YES;
    self.saveProxyView.alpha = 0.5;
    self.saveProxyView.layer.cornerRadius = Design.CONTAINER_RADIUS;
    self.saveProxyView.clipsToBounds = YES;
    self.saveProxyView.isAccessibilityElement = YES;
    self.saveProxyView.accessibilityLabel = TwinmeLocalizedString(@"application_save", nil);
    [self.saveProxyView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSaveTapGesture:)]];
    
    self.saveProxyLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.saveProxyLabel.font = Design.FONT_BOLD36;
    self.saveProxyLabel.textColor = [UIColor whiteColor];
    self.saveProxyLabel.text = TwinmeLocalizedString(@"application_save", nil);
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture)];
    [self.view addGestureRecognizer:tapGesture];
    
    self.messageLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.messageLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    
    self.messageLabel.font = Design.FONT_REGULAR32;
    self.messageLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.messageLabel.hidden = YES;
    
    self.formatLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.formatLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    
    self.formatLabel.font = Design.FONT_MEDIUM_ITALIC28;
    self.formatLabel.textColor = Design.FONT_COLOR_GREY;
    self.formatLabel.text = [NSString stringWithFormat:@"%@\n%@", TwinmeLocalizedString(@"proxy_view_controller_format", nil), TwinmeLocalizedString(@"proxy_view_controller_format_sample", nil)];
    
    if (self.proxyDescriptor) {
        self.proxyTextField.text = self.proxyDescriptor.proxyDescription;
        
        if (self.proxyDescriptor.proxyStatus != TLConnectionErrorNone) {
            self.messageLabel.hidden = NO;
            self.messageLabel.text = TwinmeLocalizedString(@"proxy_view_controller_warning", nil);
        } else {
            self.messageLabelTopConstraint.constant = 0;
        }
    } else {
        self.messageLabelTopConstraint.constant = 0;
        UIBarButtonItem *infoBarButtonItem =  [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"OnboardingInfoIcon"] style:UIBarButtonItemStylePlain target:self action:@selector(handleInfoTapGesture:)];
        infoBarButtonItem.tintColor = [UIColor whiteColor];
        infoBarButtonItem.accessibilityLabel = TwinmeLocalizedString(@"conversation_view_controller_menu_item_view_info_title", nil);
        self.navigationItem.rightBarButtonItem = infoBarButtonItem;
    }
}

- (void)setUpdated {
    DDLogVerbose(@"%@ setUpdated", LOG_TAG);
    
    if (self.proxyDescriptor) {
        if ([self.proxyDescriptor.host.lowercaseString isEqualToString:self.proxyTextField.text.lowercaseString]) {
            self.saveProxyView.alpha = 0.5;
        } else {
            self.saveProxyView.alpha = [self.proxyTextField.text length] > 0 ? 1.0 : 0.5;
        }
    } else {
        self.saveProxyView.alpha = [self.proxyTextField.text length] > 0 ? 1.0 : 0.5;
    }
}

- (void)finish {
    DDLogVerbose(@"%@ finish",LOG_TAG);
    
    if (self.proxyService) {
        [self.proxyService dispose];
        self.proxyService = nil;
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    DDLogVerbose(@"%@ keyboardWillShow: %@", LOG_TAG, notification);
    
    if (!self.keyboardHidden) {
        return;
    }
    
    self.keyboardHidden = NO;
    NSDictionary *info = [notification userInfo];
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    if ([self.twinmeApplication getDefaultKeyboardHeight] != keyboardSize.height) {
        [self.twinmeApplication setDefaultKeyboardHeight:keyboardSize.height];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification {
    DDLogVerbose(@"%@ keyboardWillHide: %@", LOG_TAG, notification);
    
    self.keyboardHidden = YES;
}

- (void)keyboardWillChangeFrame:(NSNotification *)notification {
    DDLogVerbose(@"%@ keyboardWillChangeFrame: %@", LOG_TAG, notification);
    
    NSDictionary *info = [notification userInfo];
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    if ([self.twinmeApplication getDefaultKeyboardHeight] != keyboardSize.height) {
        [self.twinmeApplication setDefaultKeyboardHeight:keyboardSize.height];
    }
}

- (void)dismissKeyboard {
    DDLogVerbose(@"%@ dismissKeyboard", LOG_TAG);
    
    if (!self.keyboardHidden) {
        [self.proxyTextField resignFirstResponder];
    }
}

- (void)handleTapGesture {
    DDLogVerbose(@"%@ handleTapGesture", LOG_TAG);
    
    if ([self.proxyTextField isFirstResponder]) {
        [self.proxyTextField resignFirstResponder];
    }
}

- (void)handleSaveTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleSaveTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        
        if (self.proxyTextField.alpha < 1.0) {
            return;
        }
        
        [self dismissKeyboard];
        [self.proxyService verifyProxyURI:[NSURL URLWithString:self.proxyTextField.text] proxyDescriptor:self.proxyDescriptor];
    }
}

- (void)handleInfoTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleInfoTapGesture ", LOG_TAG);
        
    [self hapticFeedBack:UIImpactFeedbackStyleHeavy];
    [self dismissKeyboard];
    [self showOnboarding:NO];
}

- (void)handleShareTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleShareTapGesture ", LOG_TAG);
 
    [self hapticFeedBack:UIImpactFeedbackStyleHeavy];
    [self dismissKeyboard];
        
    NSString *urlString = [NSString stringWithFormat:@"%@/%@", TLTwincodeURI.PROXY_ACTION, self.proxyDescriptor.host];
    
    NSString *message = [NSString stringWithFormat:TwinmeLocalizedString(@"proxy_view_controller_share", nil), urlString];
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[message] applicationActivities:nil];
    activityViewController.excludedActivityTypes = @[UIActivityTypeAirDrop,
                                                     UIActivityTypePrint,
                                                     UIActivityTypeAssignToContact,
                                                     UIActivityTypeSaveToCameraRoll,
                                                     UIActivityTypeAddToReadingList,
                                                     UIActivityTypePostToFlickr,
                                                     UIActivityTypePostToVimeo];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self presentViewController:activityViewController animated:YES completion:nil];
    } else {
        activityViewController.modalPresentationStyle = UIModalPresentationPopover;
        activityViewController.popoverPresentationController.sourceView = self.view;
        activityViewController.popoverPresentationController.sourceRect = CGRectMake(self.view.frame.size.width/2, self.view.frame.size.height/4, 0, 0);
        activityViewController.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionAny;
        [self presentViewController:activityViewController animated:YES completion:nil];
    }
}

- (void)showOnboarding:(BOOL)cancelAction {
    DDLogVerbose(@"%@ showOnboarding", LOG_TAG);
    
    OnboardingConfirmView *onboardingConfirmView = [[OnboardingConfirmView alloc] init];
    onboardingConfirmView.confirmViewDelegate = self;
    [onboardingConfirmView initWithTitle:TwinmeLocalizedString(@"proxy_view_controller_title", nil) message:TwinmeLocalizedString(@"proxy_view_controller_onboarding", nil) image:[UIImage imageNamed:@"OnboardingProxy"] action:TwinmeLocalizedString(@"application_ok", nil) actionColor:nil cancel:cancelAction ? TwinmeLocalizedString(@"application_do_not_display", nil) : nil];
    
    NSMutableAttributedString *attributedTitle = [[NSMutableAttributedString alloc] initWithString:TwinmeLocalizedString(@"proxy_view_controller_title", nil) attributes:[NSDictionary dictionaryWithObjectsAndKeys:Design.FONT_BOLD36, NSFontAttributeName, Design.FONT_COLOR_DEFAULT, NSForegroundColorAttributeName, nil]];
    [onboardingConfirmView updateTitle:attributedTitle];
    
    if (!cancelAction) {
        [onboardingConfirmView hideCancelAction];
    }
    
    [self.navigationController.view addSubview:onboardingConfirmView];
    [onboardingConfirmView showConfirmView];
}

- (void)showAlertMessage:(NSString *)message {
    DDLogVerbose(@"%@ showAlertMessage: %@", LOG_TAG, message);
    
    AlertMessageView *alertMessageView = [[AlertMessageView alloc] init];
    alertMessageView.alertMessageViewDelegate = self;
    [alertMessageView initWithTitle:TwinmeLocalizedString(@"delete_account_view_controller_warning", nil) message:message];
    [self.navigationController.view addSubview:alertMessageView];
    [alertMessageView showAlertView];
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    self.proxyTextField.font = Design.FONT_REGULAR28;
    self.saveProxyLabel.font = Design.FONT_BOLD36;
    self.messageLabel.font = Design.FONT_REGULAR32;
    self.formatLabel.font = Design.FONT_MEDIUM_ITALIC28;
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    [super updateColor];
    
    self.proxyView.backgroundColor = Design.TEXTFIELD_BACKGROUND_COLOR;
    self.saveProxyView.backgroundColor = Design.MAIN_COLOR;
    self.messageLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.proxyTextField.textColor = Design.FONT_COLOR_DEFAULT;
    self.proxyTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:TwinmeLocalizedString(@"proxy_view_controller_add_placeholder", nil) attributes:[NSDictionary dictionaryWithObject:Design.PLACEHOLDER_COLOR forKey:NSForegroundColorAttributeName]];
    self.formatLabel.textColor = Design.FONT_COLOR_GREY;
    
    if ([self.twinmeApplication darkModeEnable]) {
        self.proxyTextField.keyboardAppearance = UIKeyboardAppearanceDark;
    } else {
        self.proxyTextField.keyboardAppearance = UIKeyboardAppearanceLight;
    }
}

@end
