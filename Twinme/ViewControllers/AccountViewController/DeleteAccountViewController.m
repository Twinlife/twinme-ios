/*
 *  Copyright (c) 2024 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <Utils/NSString+Utils.h>

#import "DeleteAccountViewController.h"

#import <TwinmeCommon/DeleteAccountService.h>

#import "DeletedAccountViewController.h"
#import "DeleteAccountConfirmView.h"

#import <TwinmeCommon/Design.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

//
// Interface: DeleteAccountViewController ()
//

@interface DeleteAccountViewController ()<DeleteAccountServiceDelegate, ConfirmViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *accountLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *accountLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *accountLabelBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *accountLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *accountImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *accountImageViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *accountImageViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *accountImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *deleteViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *deleteView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *deleteLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *deleteLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *deleteLabel;

@property (nonatomic) DeleteAccountService *deleteAccountService;

@property (nonatomic) DeleteAccountConfirmView *deleteConfirmView;
@property (nonatomic) BOOL keyboardHidden;

@end

//
// Implementation: DeleteAccountViewController
//

#undef LOG_TAG
#define LOG_TAG @"DeleteAccountViewController"

@implementation DeleteAccountViewController

- (instancetype)initWithCoder:(NSCoder *)coder {
    DDLogVerbose(@"%@ initWithCoder: %@", LOG_TAG, coder);
    
    self = [super initWithCoder:coder];
    
    if (self) {
        _deleteAccountService = [[DeleteAccountService alloc] initWithTwinmeContext:self.twinmeContext delegate:self];
        _keyboardHidden = YES;
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
}

- (void)viewWillDisappear:(BOOL)animated {
    DDLogVerbose(@"%@ viewWillDisappear: %@", LOG_TAG, animated ? @"YES" : @"NO");
    
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
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
    
    if (self.deleteConfirmView) {
        [self.deleteConfirmView updateKeyboard:keyboardSize.height];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification {
    DDLogVerbose(@"%@ keyboardWillHide: %@", LOG_TAG, notification);
    
    self.keyboardHidden = YES;
    
    if (self.deleteConfirmView) {
        [self.deleteConfirmView updateKeyboard:0];
    }
}

- (void)finish {
    DDLogVerbose(@"%@ finish", LOG_TAG);
    
    [self.deleteAccountService dispose];
    
    [super finish];
}

#pragma mark - DeleteAccountServiceDelegate

- (void)onDeleteAccount {
    DDLogVerbose(@"%@ onDeleteAccount", LOG_TAG);
    
    ApplicationDelegate *delegate = (ApplicationDelegate *)[[UIApplication sharedApplication] delegate];
    DeletedAccountViewController *deletedAccountViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"DeletedAccountViewController"];
    delegate.window.rootViewController = deletedAccountViewController;
}

#pragma mark - ConfirmViewDelegate

- (void)didTapConfirm:(nonnull AbstractConfirmView *)abstractConfirmView {
    DDLogVerbose(@"%@ didTapConfirm: %@", LOG_TAG, abstractConfirmView);
    
    [self confirmDeleteAccount];
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
    
    self.view.backgroundColor = Design.WHITE_COLOR;
    
    [self setNavigationTitle:TwinmeLocalizedString(@"account_view_controller_title", nil)];
    
    self.accountLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.accountLabelBottomConstraint.constant *= Design.HEIGHT_RATIO;
    self.accountLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    
    self.accountLabel.text =  [NSString stringWithFormat:@"%@\n\n%@", TwinmeLocalizedString(@"account_view_controller_message_first_part", nil), TwinmeLocalizedString(@"account_view_controller_message_second_part", nil)];
    self.accountLabel.font = Design.FONT_MEDIUM34;
    self.accountLabel.textColor = Design.FONT_COLOR_DEFAULT;
    
    self.accountImageViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.accountImageViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.accountImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.deleteViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    UITapGestureRecognizer *deleteViewGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDeleteTapGesture:)];
    [self.deleteView addGestureRecognizer:deleteViewGestureRecognizer];
    
    self.deleteView.backgroundColor = [UIColor clearColor];
    self.deleteView.userInteractionEnabled = YES;
    
    self.deleteLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.deleteLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.deleteLabel.font = Design.FONT_MEDIUM34;
    self.deleteLabel.textColor = [UIColor redColor];
    self.deleteLabel.text = TwinmeLocalizedString(@"application_delete", nil);
}

- (void)handleDeleteTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleDeleteTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        
        self.deleteConfirmView = [[DeleteAccountConfirmView alloc] init];
        self.deleteConfirmView.confirmViewDelegate = self;
        NSString *message = [NSString stringWithFormat:@"%@\n%@", TwinmeLocalizedString(@"application_operation_irreversible", nil), TwinmeLocalizedString(@"account_view_controller_delete_account", nil)];
        [ self.deleteConfirmView initWithTitle:TwinmeLocalizedString(@"delete_account_view_controller_warning", nil) message:message avatar:nil icon:nil];
        [self.navigationController.view addSubview: self.deleteConfirmView];
        [ self.deleteConfirmView showConfirmView];
    }
}

- (void)confirmDeleteAccount {
    DDLogVerbose(@"%@ confirmDeleteAccount", LOG_TAG);
    
    [self.deleteAccountService deleteAccount];
    [self.twinmeApplication restoreWelcomeScreen];
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    self.deleteLabel.font = Design.FONT_MEDIUM34;
    self.accountLabel.font = Design.FONT_MEDIUM34;
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    self.deleteLabel.textColor = [UIColor redColor];
    self.accountLabel.textColor = Design.FONT_COLOR_DEFAULT;
}

@end
