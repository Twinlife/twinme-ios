/*
 *  Copyright (c) 2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import "EnterInvitationCodeViewController.h"

#import <Utils/NSString+Utils.h>

#import "AlertMessageView.h"
#import "DefaultConfirmView.h"
#import "InvitationCodeConfirmView.h"
#import "TwinmeTextField.h"

#import <TwinmeCommon/InvitationCodeService.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static const CGFloat DESIGN_TEXTFIELD_MARGIN = 20;

//
// Interface: EnterInvitationCodeViewController
//

@interface EnterInvitationCodeViewController () <UITextFieldDelegate, ConfirmViewDelegate, InvitationCodeServiceDelegate, AlertMessageViewDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *enterCodeViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *enterCodeViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *enterCodeViewWidthConstraint;
@property (weak, nonatomic) IBOutlet UIView *enterCodeView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *enterCode1TextFieldWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *enterCode1TextFieldTrailingConstraint;
@property (weak, nonatomic) IBOutlet TwinmeTextField *enterCode1TextField;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *enterCode2TextFieldWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *enterCode2TextFieldTrailingConstraint;
@property (weak, nonatomic) IBOutlet TwinmeTextField *enterCode2TextField;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *enterCode3TextFieldWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *enterCode3TextFieldTrailingConstraint;
@property (weak, nonatomic) IBOutlet TwinmeTextField *enterCode3TextField;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *enterCode4TextFieldWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *enterCode4TextFieldTrailingConstraint;
@property (weak, nonatomic) IBOutlet TwinmeTextField *enterCode4TextField;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *enterCode5TextFieldWidthConstraint;
@property (weak, nonatomic) IBOutlet TwinmeTextField *enterCode5TextField;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *enterCode6TextFieldWidthConstraint;
@property (weak, nonatomic) IBOutlet TwinmeTextField *enterCode6TextField;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *confirmViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *confirmViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *confirmViewWidthConstraint;
@property (weak, nonatomic) IBOutlet UIView *confirmView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *confirmLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet UILabel *confirmLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (nonatomic) UIView *overlayView;
@property (nonatomic) UIActivityIndicatorView *activityIndicatorView;

@property (nonatomic) BOOL showOnboardingView;
@property (nonatomic) BOOL enableConfirmView;

@property (nonatomic) InvitationCodeService *invitationCodeService;
@property (nonatomic, nullable) TLTwincodeOutbound *twincodeOutbound;

@end

//
// Implementation: EnterInvitationCodeViewController
//

#undef LOG_TAG
#define LOG_TAG @"EnterInvitationCodeViewController"

@implementation EnterInvitationCodeViewController

- (instancetype)initWithCoder:(NSCoder *)coder {
    DDLogVerbose(@"%@ initWithCoder: %@", LOG_TAG, coder);
    
    self = [super initWithCoder:coder];
    
    if (self) {
        _showOnboardingView = NO;
        _enableConfirmView = NO;
        
        _invitationCodeService = [[InvitationCodeService alloc] initWithTwinmeContext:self.twinmeContext delegate:self];
    }
    return self;
}

- (void)viewDidLoad {
    DDLogVerbose(@"%@ viewDidLoad", LOG_TAG);
    
    [super viewDidLoad];
    
    [self initViews];
    
    [self.invitationCodeService getInvitations];
}

- (void)viewWillAppear:(BOOL)animated {
    DDLogVerbose(@"%@ viewWillAppear", LOG_TAG);
    
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didPasteItemNotification:) name:TwinmeTextFieldDidPasteItemNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteBackwardNotification:) name:TwinmeTextFieldDeleteBackWardNotification object:nil];
    
    if (!self.showOnboardingView && [self.twinmeApplication startOnboarding:OnboardingTypeEnterMiniCode]) {
        self.showOnboardingView = YES;
        
        [self showOnboarding:NO];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    DDLogVerbose(@"%@ viewWillDisappear: %@", LOG_TAG, animated ? @"YES" : @"NO");
    
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TwinmeTextFieldDidPasteItemNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TwinmeTextFieldDeleteBackWardNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    DDLogVerbose(@"%@ viewDidAppear", LOG_TAG);
    
    [super viewDidAppear:animated];
    
    if (!self.showOnboardingView) {
        self.showOnboardingView = YES;
        [self.enterCode1TextField becomeFirstResponder];
    }
}

- (void)didPasteItemNotification:(NSNotification *)notification {
    DDLogVerbose(@"%@ didPasteItemNotification: %@", LOG_TAG, notification);
    
    NSString *pastedContent = (NSString *)notification.object;
    if (pastedContent.length > 5) {
        self.enterCode1TextField.text = [pastedContent substringWithRange:NSMakeRange(0, 1)].uppercaseString;
        self.enterCode2TextField.text = [pastedContent substringWithRange:NSMakeRange(1, 1)].uppercaseString;
        self.enterCode3TextField.text = [pastedContent substringWithRange:NSMakeRange(2, 1)].uppercaseString;
        self.enterCode4TextField.text = [pastedContent substringWithRange:NSMakeRange(3, 1)].uppercaseString;
        self.enterCode5TextField.text = [pastedContent substringWithRange:NSMakeRange(4, 1)].uppercaseString;
        self.enterCode6TextField.text = [pastedContent substringWithRange:NSMakeRange(5, 1)].uppercaseString;
    }
}

- (void)deleteBackwardNotification:(NSNotification *)notification {
    DDLogVerbose(@"%@ deleteBackwardNotification: %@", LOG_TAG, notification);
    
    TwinmeTextField *twinmeTextField = (TwinmeTextField *)notification.object;
    
    if (twinmeTextField == self.enterCode1TextField) {
        self.enterCode1TextField.text = @"";
    } else if (twinmeTextField == self.enterCode2TextField) {
        if ([self.enterCode2TextField.text isEqualToString:@""]) {
            [self.enterCode1TextField becomeFirstResponder];
            self.enterCode1TextField.text = @"";
        } else {
            self.enterCode2TextField.text = @"";
        }
    } else if (twinmeTextField == self.enterCode3TextField) {
        if ([self.enterCode3TextField.text isEqualToString:@""]) {
            [self.enterCode2TextField becomeFirstResponder];
            self.enterCode2TextField.text = @"";
        } else {
            self.enterCode3TextField.text = @"";
        }
    } else if (twinmeTextField == self.enterCode4TextField) {
        if ([self.enterCode4TextField.text isEqualToString:@""]) {
            [self.enterCode3TextField becomeFirstResponder];
            self.enterCode3TextField.text = @"";
        } else {
            self.enterCode4TextField.text = @"";
        }
    } else if (twinmeTextField == self.enterCode5TextField) {
        if ([self.enterCode5TextField.text isEqualToString:@""]) {
            [self.enterCode4TextField becomeFirstResponder];
            self.enterCode4TextField.text = @"";
        } else {
            self.enterCode5TextField.text = @"";
        }
    } else if (twinmeTextField == self.enterCode6TextField) {
        if ([self.enterCode6TextField.text isEqualToString:@""]) {
            [self.enterCode5TextField becomeFirstResponder];
            self.enterCode5TextField.text = @"";
        } else {
            self.enterCode6TextField.text = @"";
        }
    }
    
    [self updateViews];
}

#pragma mark - AlertMessageViewDelegate

- (void)didCloseAlertMessage:(nonnull AlertMessageView *)alertMessageView {
    DDLogVerbose(@"%@ didCloseAlertMessage: %@", LOG_TAG, alertMessageView);
    
    [alertMessageView closeAlertView];
}

- (void)didFinishCloseAlertMessageAnimation:(nonnull AlertMessageView *)alertMessageView {
    DDLogVerbose(@"%@ didFinishCloseAlertMessageAnimation: %@", LOG_TAG, alertMessageView);
    
    [alertMessageView removeFromSuperview];
    
    self.enterCode1TextField.text = @"";
    self.enterCode2TextField.text = @"";
    self.enterCode3TextField.text = @"";
    self.enterCode4TextField.text = @"";
    self.enterCode5TextField.text = @"";
    self.enterCode6TextField.text = @"";
}

#pragma mark - InvitationCodeServiceDelegate

- (void)onCreateInvitationWithCodeWithInvitation:(nullable TLInvitation *)invitation {
    DDLogVerbose(@"%@ onCreateInvitationCodeWithInvitation: %@", LOG_TAG, invitation);
}

- (void)onGetInvitationCodeWithTwincodeOutbound:(nullable TLTwincodeOutbound *)twincodeOutbound avatar:(nullable UIImage *)avatar publicKey:(nullable NSString *)publicKey {
    DDLogVerbose(@"%@ onGetInvitationCodeWithTwincodeOutbound: %@ publicKey: %@", LOG_TAG, twincodeOutbound, publicKey);
    
    self.overlayView.hidden = YES;
    if ([self.activityIndicatorView isAnimating]) {
        [self.activityIndicatorView stopAnimating];
    }
    
    self.twincodeOutbound = twincodeOutbound;
    [self showInvitationCodeConfirmView:twincodeOutbound avatar:avatar];
}

- (void)onGetInvitationCodeNotFound {
    DDLogVerbose(@"%@ onGetInvitationCodeNotFound", LOG_TAG);
    
    self.overlayView.hidden = YES;
    if ([self.activityIndicatorView isAnimating]) {
        [self.activityIndicatorView stopAnimating];
    }
    
    AlertMessageView *alertMessageView = [[AlertMessageView alloc] init];
    alertMessageView.alertMessageViewDelegate = self;
    [alertMessageView initWithTitle:TwinmeLocalizedString(@"delete_account_view_controller_warning", nil) message:TwinmeLocalizedString(@"enter_invitation_code_view_controller_error_message", nil)];
    [self.tabBarController.view addSubview:alertMessageView];
    [alertMessageView showAlertView];
}

- (void)onGetLocalInvitationCode {
    DDLogVerbose(@"%@ onGetLocalInvitationCode", LOG_TAG);
    
    self.overlayView.hidden = YES;
    if ([self.activityIndicatorView isAnimating]) {
        [self.activityIndicatorView stopAnimating];
    }
    
    AlertMessageView *alertMessageView = [[AlertMessageView alloc] init];
    alertMessageView.alertMessageViewDelegate = self;
    [alertMessageView initWithTitle:TwinmeLocalizedString(@"delete_account_view_controller_warning", nil) message:TwinmeLocalizedString(@"accept_invitation_view_controller_local_twincode", nil)];
    [self.tabBarController.view addSubview:alertMessageView];
    [alertMessageView showAlertView];
}

- (void)onGetInvitationsWithInvitations:(nullable NSArray<TLInvitation *> *)invitations {
    DDLogVerbose(@"%@ onGetInvitationsWithInvitations: %@", LOG_TAG, invitations);
}

- (void)onGetDefaultProfileWithProfile:(nonnull TLProfile *)profile {
    DDLogVerbose(@"%@ onGetDefaultProfileWithProfile: %@", LOG_TAG, profile);
}

- (void)onGetDefaultProfileNotFound {
    DDLogVerbose(@"%@ onGetDefaultProfileNotFound", LOG_TAG);
}

- (void)onDeleteInvitationWithInvitationId:(nonnull NSUUID *)invitationId {
    DDLogVerbose(@"%@ onDeleteInvitationWithInvitationId: %@", LOG_TAG, invitationId);
}

- (void)onGetTwincodeNotFound {
    DDLogVerbose(@"%@ onGetDefaultProfileNotFound", LOG_TAG);
}

- (void)onGetTwincodeWithTwincode:(nonnull TLTwincodeOutbound *)twincode avatar:(nullable UIImage *)avatar {
    DDLogVerbose(@"%@ onGetTwincodeWithTwincode: %@ avatar: %@", LOG_TAG, twincode, avatar);
}

- (void)onCreateContact:(TLContact *)contact {
    DDLogVerbose(@"%@ onCreateContact: %@", LOG_TAG, contact);
 
    [self showContactWithContact:contact popToRoot:YES];
    [self finish];
}

- (void)onInvitationCodeError:(TLBaseServiceErrorCode)errorCode {
    DDLogVerbose(@"%@ onInvitationCodeError: %u", LOG_TAG, errorCode);
    
    self.overlayView.hidden = YES;
    if ([self.activityIndicatorView isAnimating]) {
        [self.activityIndicatorView stopAnimating];
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    DDLogVerbose(@"%@ textFieldShouldReturn: %@", LOG_TAG, textField);
    
    [textField resignFirstResponder];
    return NO;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    DDLogVerbose(@"%@ textView: %@ shouldChangeCharactersInRange: %lu replacementString: %@", LOG_TAG, textField, (unsigned long)range.length, string);
    
    NSMutableCharacterSet *alphanumericCharacterSet = [NSMutableCharacterSet alphanumericCharacterSet];
    [alphanumericCharacterSet removeCharactersInString:@"015"];
    NSCharacterSet *characterSet = [NSCharacterSet characterSetWithCharactersInString:string];
    
    return [alphanumericCharacterSet isSupersetOfSet:characterSet] && textField.text.length + (string.length - range.length) <= 1;
}

- (void)textFieldDidChange:(UITextField *)textField {
    DDLogVerbose(@"%@ textFieldDidChange: %@", LOG_TAG, textField);
    
    textField.text = [textField.text uppercaseString];
    
    if (textField == self.enterCode1TextField) {
        self.enterCode2TextField.keyboardType = [self getKeyboardType:textField.text];
        [self.enterCode2TextField becomeFirstResponder];
    } else if (textField == self.enterCode2TextField) {
        self.enterCode3TextField.keyboardType = [self getKeyboardType:textField.text];
        [self.enterCode3TextField becomeFirstResponder];
    } else if (textField == self.enterCode3TextField) {
        self.enterCode4TextField.keyboardType = [self getKeyboardType:textField.text];
        [self.enterCode4TextField becomeFirstResponder];
    } else if (textField == self.enterCode4TextField) {
        self.enterCode5TextField.keyboardType = [self getKeyboardType:textField.text];
        [self.enterCode5TextField becomeFirstResponder];
    } else if (textField == self.enterCode5TextField) {
        self.enterCode6TextField.keyboardType = [self getKeyboardType:textField.text];
        [self.enterCode6TextField becomeFirstResponder];
    }
    
    [self updateViews];
}

#pragma mark - ConfirmViewDelegate

- (void)didTapConfirm:(nonnull AbstractConfirmView *)abstractConfirmView {
    DDLogVerbose(@"%@ didTapConfirm: %@", LOG_TAG, abstractConfirmView);
    
    [abstractConfirmView closeConfirmView];
    
    if ([abstractConfirmView isKindOfClass:[InvitationCodeConfirmView class]] && self.twincodeOutbound) {
        [self.invitationCodeService createContact:self.twincodeOutbound];
    }
}

- (void)didTapCancel:(nonnull AbstractConfirmView *)abstractConfirmView {
    DDLogVerbose(@"%@ didTapCancel: %@", LOG_TAG, abstractConfirmView);
    
    [abstractConfirmView closeConfirmView];
    
    if ([abstractConfirmView isKindOfClass:[DefaultConfirmView class]]) {
        [self.twinmeApplication setShowOnboardingType:OnboardingTypeEnterMiniCode state:NO];
    }
}

- (void)didClose:(nonnull AbstractConfirmView *)abstractConfirmView {
    DDLogVerbose(@"%@ didClose: %@", LOG_TAG, abstractConfirmView);
    
    [abstractConfirmView closeConfirmView];
}

- (void)didFinishCloseAnimation:(nonnull AbstractConfirmView *)abstractConfirmView {
    DDLogVerbose(@"%@ didFinishCloseAnimation: %@", LOG_TAG, abstractConfirmView);
    
    if ([abstractConfirmView isKindOfClass:[DefaultConfirmView class]]) {
        [self.enterCode1TextField becomeFirstResponder];
    }
    
    [abstractConfirmView removeFromSuperview];
}

#pragma mark - Private Methods

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    [self.view setBackgroundColor:Design.GREY_BACKGROUND_COLOR];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    tapGesture.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGesture];
    
    [self setNavigationTitle:TwinmeLocalizedString(@"add_contact_view_controller_invitation_code_title", nil)];
    
    UIBarButtonItem *infoBarButtonItem =  [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"OnboardingInfoIcon"] style:UIBarButtonItemStylePlain target:self action:@selector(handleInfoTapGesture:)];
    infoBarButtonItem.tintColor = [UIColor whiteColor];
    infoBarButtonItem.accessibilityLabel = TwinmeLocalizedString(@"conversation_view_controller_menu_item_view_info_title", nil);
    self.navigationItem.rightBarButtonItem = infoBarButtonItem;
    
    self.confirmViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.confirmViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.confirmViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    
    self.confirmView.backgroundColor = Design.MAIN_COLOR;
    self.confirmView.userInteractionEnabled = YES;
    self.confirmView.isAccessibilityElement = YES;
    self.confirmView.alpha = 0.5;
    self.confirmView.layer.cornerRadius = Design.CONTAINER_RADIUS;
    self.confirmView.clipsToBounds = YES;
    self.confirmView.accessibilityLabel = TwinmeLocalizedString(@"application_confirm", nil);
    [self.confirmView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleConfirmTapGesture:)]];
    
    self.confirmLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.confirmLabel.font = Design.FONT_BOLD36;
    self.confirmLabel.textColor = [UIColor whiteColor];
    self.confirmLabel.text = TwinmeLocalizedString(@"application_confirm", nil);
    
    self.messageLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.messageLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    
    self.messageLabel.font = Design.FONT_REGULAR32;
    self.messageLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.messageLabel.text = TwinmeLocalizedString(@"enter_invitation_code_view_controller_message", nil);
    
    self.enterCodeViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.enterCodeViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.enterCodeViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    
    self.enterCodeView.backgroundColor = [UIColor clearColor];
    
    CGFloat textFieldMargin = DESIGN_TEXTFIELD_MARGIN * Design.WIDTH_RATIO;
    CGFloat textFieldWith = (self.confirmViewWidthConstraint.constant - (textFieldMargin * 5)) / 6;
    
    self.enterCode1TextFieldWidthConstraint.constant = textFieldWith;
    self.enterCode1TextFieldTrailingConstraint.constant = DESIGN_TEXTFIELD_MARGIN * Design.WIDTH_RATIO;
    
    self.enterCode1TextField.clipsToBounds = YES;
    self.enterCode1TextField.delegate = self;
    self.enterCode1TextField.overrideDeleteBackWard = YES;
    self.enterCode1TextField.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
    self.enterCode1TextField.font = Design.FONT_BOLD68;
    self.enterCode1TextField.textAlignment = NSTextAlignmentCenter;
    self.enterCode1TextField.textColor = Design.FONT_COLOR_DEFAULT;
    self.enterCode1TextField.backgroundColor = Design.POPUP_BACKGROUND_COLOR;
    self.enterCode1TextField.tintColor = Design.FONT_COLOR_DEFAULT;
    self.enterCode1TextField.layer.cornerRadius = Design.CONTAINER_RADIUS;
    self.enterCode1TextField.layer.borderWidth = 1;
    self.enterCode1TextField.layer.borderColor = Design.BLACK_COLOR.CGColor;
    
    [self.enterCode1TextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    self.enterCode2TextFieldWidthConstraint.constant = textFieldWith;
    self.enterCode2TextFieldTrailingConstraint.constant = DESIGN_TEXTFIELD_MARGIN * Design.WIDTH_RATIO;
    
    self.enterCode2TextField.clipsToBounds = YES;
    self.enterCode2TextField.delegate = self;
    self.enterCode2TextField.overrideDeleteBackWard = YES;
    self.enterCode2TextField.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
    self.enterCode2TextField.font = Design.FONT_BOLD68;
    self.enterCode2TextField.textAlignment = NSTextAlignmentCenter;
    self.enterCode2TextField.textColor = Design.FONT_COLOR_DEFAULT;
    self.enterCode2TextField.backgroundColor = Design.POPUP_BACKGROUND_COLOR;
    self.enterCode2TextField.tintColor = Design.FONT_COLOR_DEFAULT;
    self.enterCode2TextField.layer.cornerRadius = Design.CONTAINER_RADIUS;
    self.enterCode2TextField.layer.borderWidth = 1;
    self.enterCode2TextField.layer.borderColor = Design.BLACK_COLOR.CGColor;
    
    [self.enterCode2TextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    self.enterCode3TextFieldWidthConstraint.constant = textFieldWith;
    self.enterCode3TextFieldTrailingConstraint.constant = DESIGN_TEXTFIELD_MARGIN * Design.WIDTH_RATIO;
    
    self.enterCode3TextField.clipsToBounds = YES;
    self.enterCode3TextField.delegate = self;
    self.enterCode3TextField.overrideDeleteBackWard = YES;
    self.enterCode3TextField.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
    self.enterCode3TextField.font = Design.FONT_BOLD68;
    self.enterCode3TextField.textAlignment = NSTextAlignmentCenter;
    self.enterCode3TextField.textColor = Design.FONT_COLOR_DEFAULT;
    self.enterCode3TextField.backgroundColor = Design.POPUP_BACKGROUND_COLOR;
    self.enterCode3TextField.tintColor = Design.FONT_COLOR_DEFAULT;
    self.enterCode3TextField.layer.cornerRadius = Design.CONTAINER_RADIUS;
    self.enterCode3TextField.layer.borderWidth = 1;
    self.enterCode3TextField.layer.borderColor = Design.BLACK_COLOR.CGColor;
    
    [self.enterCode3TextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    self.enterCode4TextFieldWidthConstraint.constant = textFieldWith;
    self.enterCode4TextFieldTrailingConstraint.constant = DESIGN_TEXTFIELD_MARGIN * Design.WIDTH_RATIO;
    
    self.enterCode4TextField.clipsToBounds = YES;
    self.enterCode4TextField.delegate = self;
    self.enterCode4TextField.overrideDeleteBackWard = YES;
    self.enterCode4TextField.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
    self.enterCode4TextField.font = Design.FONT_BOLD68;
    self.enterCode4TextField.textAlignment = NSTextAlignmentCenter;
    self.enterCode4TextField.textColor = Design.FONT_COLOR_DEFAULT;
    self.enterCode4TextField.backgroundColor = Design.POPUP_BACKGROUND_COLOR;
    self.enterCode4TextField.tintColor = Design.FONT_COLOR_DEFAULT;
    self.enterCode4TextField.layer.cornerRadius = Design.CONTAINER_RADIUS;
    self.enterCode4TextField.layer.borderWidth = 1;
    self.enterCode4TextField.layer.borderColor = Design.BLACK_COLOR.CGColor;
    
    [self.enterCode4TextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    self.enterCode5TextFieldWidthConstraint.constant = textFieldWith;
    
    self.enterCode5TextField.clipsToBounds = YES;
    self.enterCode5TextField.delegate = self;
    self.enterCode5TextField.overrideDeleteBackWard = YES;
    self.enterCode5TextField.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
    self.enterCode5TextField.font = Design.FONT_BOLD68;
    self.enterCode5TextField.textAlignment = NSTextAlignmentCenter;
    self.enterCode5TextField.textColor = Design.FONT_COLOR_DEFAULT;
    self.enterCode5TextField.backgroundColor = Design.POPUP_BACKGROUND_COLOR;
    self.enterCode5TextField.tintColor = Design.FONT_COLOR_DEFAULT;
    self.enterCode5TextField.layer.cornerRadius = Design.CONTAINER_RADIUS;
    self.enterCode5TextField.layer.borderWidth = 1;
    self.enterCode5TextField.layer.borderColor = Design.BLACK_COLOR.CGColor;
    
    [self.enterCode5TextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    self.enterCode6TextFieldWidthConstraint.constant = textFieldWith;
    
    self.enterCode6TextField.clipsToBounds = YES;
    self.enterCode6TextField.delegate = self;
    self.enterCode6TextField.overrideDeleteBackWard = YES;
    self.enterCode6TextField.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
    self.enterCode6TextField.font = Design.FONT_BOLD68;
    self.enterCode6TextField.textAlignment = NSTextAlignmentCenter;
    self.enterCode6TextField.textColor = Design.FONT_COLOR_DEFAULT;
    self.enterCode6TextField.backgroundColor = Design.POPUP_BACKGROUND_COLOR;
    self.enterCode6TextField.tintColor = Design.FONT_COLOR_DEFAULT;
    self.enterCode6TextField.layer.cornerRadius = Design.CONTAINER_RADIUS;
    self.enterCode6TextField.layer.borderWidth = 1;
    self.enterCode6TextField.layer.borderColor = Design.BLACK_COLOR.CGColor;
    
    [self.enterCode6TextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    self.overlayView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, Design.DISPLAY_WIDTH, Design.DISPLAY_HEIGHT)];
    self.overlayView.backgroundColor = Design.OVERLAY_COLOR;
    self.overlayView.hidden = YES;
    
    if (@available(iOS 13.0, *)) {
        self.activityIndicatorView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
        self.activityIndicatorView.color = [UIColor whiteColor];
    } else {
        self.activityIndicatorView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    }
    self.activityIndicatorView.hidesWhenStopped = YES;
    
    [self.overlayView addSubview:self.activityIndicatorView];
    
    [self.activityIndicatorView setCenter:CGPointMake(Design.DISPLAY_WIDTH * 0.5, Design.DISPLAY_HEIGHT * 0.5)];
    [self.navigationController.view addSubview:self.overlayView];
}

- (void)finish {
    DDLogVerbose(@"%@ finish", LOG_TAG);
    
    [self.invitationCodeService dispose];
}

- (void)handleConfirmTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleConfirmTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        [self hapticFeedBack:UIImpactFeedbackStyleHeavy];
        
        if (self.enableConfirmView) {
            
            self.overlayView.hidden = NO;
            [self.activityIndicatorView startAnimating];
            
            [self dismissKeyboard];
            
            NSMutableString *invitationCode = [[NSMutableString alloc]initWithString:self.enterCode1TextField.text];
            [invitationCode appendString:self.enterCode2TextField.text];
            [invitationCode appendString:self.enterCode3TextField.text];
            [invitationCode appendString:self.enterCode4TextField.text];
            [invitationCode appendString:self.enterCode5TextField.text];
            [invitationCode appendString:self.enterCode6TextField.text];
            
            [self.invitationCodeService getInvitationCodeWithCode:invitationCode];
        }
    }
}

- (IBAction)handleInfoTapGesture:(id)sender {
    DDLogVerbose(@"%@ handleInfoTapGesture: %@", LOG_TAG, sender);
    
    [self hapticFeedBack:UIImpactFeedbackStyleHeavy];
    
    [self showOnboarding:YES];
}

- (void)showOnboarding:(BOOL)fromInfo {
    DDLogVerbose(@"%@ showOnboarding", LOG_TAG);
    
    [self dismissKeyboard];
    
    DefaultConfirmView *defaultConfirmView = [[DefaultConfirmView alloc] init];
    defaultConfirmView.confirmViewDelegate = self;
    
    NSMutableString *message = [[NSMutableString alloc] initWithString: TwinmeLocalizedString(@"enter_invitation_code_view_controller_onboarding_message", nil)];
    [message appendString:@"\n\n"];
    [message appendString:TwinmeLocalizedString(@"enter_invitation_code_view_controller_certified_message", nil)];
    
    [defaultConfirmView initWithTitle:nil message:message image:[UIImage imageNamed:@"OnboardingMiniCode"] avatar:nil action:TwinmeLocalizedString(@"enter_invitation_code_view_controller_enter_code", nil) actionColor:nil cancel:TwinmeLocalizedString(@"application_do_not_display", nil)];
    [defaultConfirmView useLargeImage];
    
    if (fromInfo) {
        [defaultConfirmView hideCancelAction];
    }
    
    [self.navigationController.view addSubview:defaultConfirmView];
    [defaultConfirmView showConfirmView];
}

- (void)showInvitationCodeConfirmView:(TLTwincodeOutbound *)twincodeOutbound avatar:(UIImage *)avatar {
    DDLogVerbose(@"%@ showInvitationCodeConfirmView: %@", LOG_TAG, twincodeOutbound);
    
    InvitationCodeConfirmView *invitationCodeConfirmView = [[InvitationCodeConfirmView alloc] init];
    invitationCodeConfirmView.confirmViewDelegate = self;
    
    NSMutableString *message = [[NSMutableString alloc] initWithString:[NSString stringWithFormat:TwinmeLocalizedString(@"accept_invitation_view_controller_message %@", nil), twincodeOutbound.name]];
    [message appendString:@"\n\n"];
    [message appendString:TwinmeLocalizedString(@"enter_invitation_code_view_controller_invitation_message", nil)];
    
    [invitationCodeConfirmView initWithTitle:twincodeOutbound.name message:message avatar:avatar icon:[UIImage imageNamed:@"ActionBarAddContact"]];
    [self.navigationController.view addSubview:invitationCodeConfirmView];
    [invitationCodeConfirmView showConfirmView];
}

- (void)dismissKeyboard {
    DDLogVerbose(@"%@ dismissKeyboard", LOG_TAG);
    
    [self.enterCode1TextField resignFirstResponder];
    [self.enterCode2TextField resignFirstResponder];
    [self.enterCode3TextField resignFirstResponder];
    [self.enterCode4TextField resignFirstResponder];
    [self.enterCode5TextField resignFirstResponder];
    [self.enterCode6TextField resignFirstResponder];
}

- (void)updateViews {
    DDLogVerbose(@"%@ updateViews", LOG_TAG);
    
    self.enableConfirmView = NO;
    
    if (![self.enterCode1TextField.text isEqual:@""]
        && ![self.enterCode2TextField.text isEqual:@""]
        && ![self.enterCode3TextField.text isEqual:@""]
        && ![self.enterCode4TextField.text isEqual:@""]
        && ![self.enterCode5TextField.text isEqual:@""]
        && ![self.enterCode6TextField.text isEqual:@""]) {
        self.enableConfirmView = YES;
    }
    
    self.confirmView.alpha = self.enableConfirmView ? 1.0f : 0.5f;
}

- (UIKeyboardType)getKeyboardType:(NSString *)text {
    DDLogVerbose(@"%@ getKeyboardType: %@", LOG_TAG, text);
    
    NSCharacterSet *decimalDigitCharacterSet = [NSCharacterSet decimalDigitCharacterSet];
    NSCharacterSet *characterSet = [NSCharacterSet characterSetWithCharactersInString:text];

    if ([decimalDigitCharacterSet isSupersetOfSet:characterSet]) {
        return UIKeyboardTypeNumbersAndPunctuation;
    }
    
    return UIKeyboardTypeDefault;
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    self.confirmLabel.font = Design.FONT_BOLD36;
    self.messageLabel.font = Design.FONT_REGULAR32;
    
    self.enterCode1TextField.font = Design.FONT_BOLD68;
    self.enterCode2TextField.font = Design.FONT_BOLD68;
    self.enterCode3TextField.font = Design.FONT_BOLD68;
    self.enterCode4TextField.font = Design.FONT_BOLD68;
    self.enterCode5TextField.font = Design.FONT_BOLD68;
    self.enterCode6TextField.font = Design.FONT_BOLD68;
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    [super updateColor];
    
    [self.view setBackgroundColor:Design.GREY_BACKGROUND_COLOR];
    
    self.confirmView.backgroundColor = Design.MAIN_COLOR;
    
    self.messageLabel.textColor = Design.FONT_COLOR_DEFAULT;
    
    self.enterCode1TextField.textColor = Design.FONT_COLOR_DEFAULT;
    self.enterCode1TextField.backgroundColor = Design.POPUP_BACKGROUND_COLOR;
    self.enterCode1TextField.layer.borderColor = Design.BLACK_COLOR.CGColor;
    
    self.enterCode2TextField.textColor = Design.FONT_COLOR_DEFAULT;
    self.enterCode2TextField.backgroundColor = Design.POPUP_BACKGROUND_COLOR;
    self.enterCode2TextField.layer.borderColor = Design.BLACK_COLOR.CGColor;
    
    self.enterCode3TextField.textColor = Design.FONT_COLOR_DEFAULT;
    self.enterCode3TextField.backgroundColor = Design.POPUP_BACKGROUND_COLOR;
    self.enterCode3TextField.layer.borderColor = Design.BLACK_COLOR.CGColor;
    
    self.enterCode4TextField.textColor = Design.FONT_COLOR_DEFAULT;
    self.enterCode4TextField.backgroundColor = Design.POPUP_BACKGROUND_COLOR;
    self.enterCode4TextField.layer.borderColor = Design.BLACK_COLOR.CGColor;
    
    self.enterCode5TextField.textColor = Design.FONT_COLOR_DEFAULT;
    self.enterCode5TextField.backgroundColor = Design.POPUP_BACKGROUND_COLOR;
    self.enterCode5TextField.layer.borderColor = Design.BLACK_COLOR.CGColor;
    
    self.enterCode6TextField.textColor = Design.FONT_COLOR_DEFAULT;
    self.enterCode6TextField.backgroundColor = Design.POPUP_BACKGROUND_COLOR;
    self.enterCode6TextField.layer.borderColor = Design.BLACK_COLOR.CGColor;
    
    self.overlayView.backgroundColor = Design.OVERLAY_COLOR;
}

@end
