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

@interface DeleteAccountViewController ()<DeleteAccountServiceDelegate, BottomSheetViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *accountLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *accountLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *accountLabelBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *accountLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *accountImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *accountImageViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *accountImageViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *accountImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *deleteViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *deleteViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *deleteView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *deleteLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet UILabel *deleteLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cancelViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cancelViewBottomConstraint;
@property (weak, nonatomic) IBOutlet UIView *cancelView;
@property (weak, nonatomic) IBOutlet UILabel *cancelLabel;

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
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - DeleteAccountServiceDelegate

- (void)onDeleteAccount {
    DDLogVerbose(@"%@ onDeleteAccount", LOG_TAG);
    
    ApplicationDelegate *delegate = (ApplicationDelegate *)[[UIApplication sharedApplication] delegate];
    DeletedAccountViewController *deletedAccountViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"DeletedAccountViewController"];
    delegate.window.rootViewController = deletedAccountViewController;
}

#pragma mark - BottomSheetViewDelegate

- (void)didTapConfirm:(nonnull AbstractBottomSheetView *)abstractBottomSheetView {
    DDLogVerbose(@"%@ didTapConfirm: %@", LOG_TAG, abstractBottomSheetView);
    
    [self confirmDeleteAccount];
    [abstractBottomSheetView closeConfirmView];
}

- (void)didTapCancel:(nonnull AbstractBottomSheetView *)abstractBottomSheetView {
    DDLogVerbose(@"%@ didTapCancel: %@", LOG_TAG, abstractBottomSheetView);
    
    [abstractBottomSheetView closeConfirmView];
}

- (void)didClose:(nonnull AbstractBottomSheetView *)abstractBottomSheetView {
    DDLogVerbose(@"%@ didClose: %@", LOG_TAG, abstractBottomSheetView);
    
    [abstractBottomSheetView closeConfirmView];
}

- (void)didFinishCloseAnimation:(nonnull AbstractBottomSheetView *)abstractBottomSheetView {
    DDLogVerbose(@"%@ didFinishCloseAnimation: %@", LOG_TAG, abstractBottomSheetView);
    
    [abstractBottomSheetView removeFromSuperview];
}

#pragma mark - Private methods

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    self.view.backgroundColor = Design.WHITE_COLOR;
    
    [self setNavigationTitle:TwinmeLocalizedString(@"account_view_title", nil)];
    
    self.accountLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.accountLabelBottomConstraint.constant *= Design.HEIGHT_RATIO;
    self.accountLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    
    self.accountLabel.text =  [NSString stringWithFormat:@"%@\n\n%@\n\n%@", TwinmeLocalizedString(@"account_view_message_first_part", nil), TwinmeLocalizedString(@"account_view_message_second_part", nil), TwinmeLocalizedStringFromTable(@"account_view_message_third_part", @"LocalizableBackup", nil)];
    self.accountLabel.font = Design.FONT_MEDIUM34;
    self.accountLabel.textColor = Design.FONT_COLOR_DEFAULT;
    
    self.accountImageViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.accountImageViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.accountImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.deleteViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.deleteViewWidthConstraint.constant *= Design.WIDTH_RATIO;
        
    self.deleteView.backgroundColor = Design.DELETE_COLOR_RED;
    self.deleteView.userInteractionEnabled = YES;
    self.deleteView.layer.cornerRadius = Design.CONTAINER_RADIUS;
    self.deleteView.clipsToBounds = YES;
    self.deleteView.isAccessibilityElement = YES;
    [self.deleteView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDeleteTapGesture:)]];

    self.deleteLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
        
    self.deleteLabel.font = Design.FONT_BOLD36;
    self.deleteLabel.textColor = [UIColor whiteColor];
    self.deleteLabel.text = TwinmeLocalizedString(@"deleted_account_view_delete", nil);
    
    self.cancelViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    UITapGestureRecognizer *cancelViewGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleCancelTapGesture:)];
    [self.cancelView addGestureRecognizer:cancelViewGestureRecognizer];
    
    UIWindow *window = [self currentWindow];
    if (window) {
        self.cancelViewBottomConstraint.constant = window.safeAreaInsets.bottom;
    } else {
        self.cancelViewBottomConstraint.constant = self.view.safeAreaInsets.bottom;
    }
    
    self.cancelLabel.font = Design.FONT_BOLD36;
    self.cancelLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.cancelLabel.text = TwinmeLocalizedString(@"application_cancel", nil);
}

- (void)handleDeleteTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleDeleteTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
    
        [self hapticFeedBack:UIImpactFeedbackStyleLight];
        
        self.deleteConfirmView = [[DeleteAccountConfirmView alloc] init];
        self.deleteConfirmView.bottomSheetViewDelegate = self;
        self.deleteConfirmView.spaceSettings = self.currentSpaceSettings;
        NSString *message = [NSString stringWithFormat:@"%@\n%@", TwinmeLocalizedString(@"application_operation_irreversible", nil), TwinmeLocalizedString(@"account_view_delete_account", nil)];
        [self.deleteConfirmView initWithTitle:TwinmeLocalizedString(@"deleted_account_view_warning", nil) message:message avatar:nil icon:nil];
        [self.navigationController.view addSubview: self.deleteConfirmView];
        [self.deleteConfirmView showConfirmView];
    }
}

- (void)handleCancelTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleCancelTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        [self hapticFeedBack:UIImpactFeedbackStyleLight];
        
        [self finish];
    }
}

- (void)confirmDeleteAccount {
    DDLogVerbose(@"%@ confirmDeleteAccount", LOG_TAG);
    
    [self.deleteAccountService deleteAccount];
    [self.twinmeApplication restoreWelcomeScreen];
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    self.deleteLabel.font = Design.FONT_BOLD36;
    self.accountLabel.font = Design.FONT_MEDIUM34;
    self.cancelLabel.font = Design.FONT_BOLD36;
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    self.deleteLabel.textColor = [UIColor whiteColor];
    self.accountLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.cancelLabel.textColor = Design.FONT_COLOR_DEFAULT;
}

@end
