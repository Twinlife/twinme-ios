/*
 *  Copyright (c) 2024 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import "DeleteAccountConfirmView.h"

#import <Utils/NSString+Utils.h>

#import <TwinmeCommon/ApplicationDelegate.h>
#import <TwinmeCommon/Design.h>
#import <TwinmeCommon/TwinmeApplication.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static CGFloat DESIGN_TEXTFIELD_HEIGHT = 82;

//
// Interface: DeleteAccountConfirmView ()
//

@interface DeleteAccountConfirmView ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *deleteAccountImageViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *deleteAccountImageViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *deleteAccountImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *deleteAccountImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *deleteConfirmViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *deleteConfirmViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *deleteConfirmViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *deleteConfirmView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *deleteConfirmTextFieldLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *deleteConfirmTextFieldTrailingConstraint;
@property (weak, nonatomic) IBOutlet UITextField *deleteConfirmTextField;

@property BOOL confirmDeleteAccount;

@end

//
// Implementation: DeleteAccountConfirmView
//

#undef LOG_TAG
#define LOG_TAG @"DeleteAccountConfirmView"

@implementation DeleteAccountConfirmView

#pragma mark - UIView

- (instancetype)init {
    DDLogVerbose(@"%@ init", LOG_TAG);
    
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"DeleteAccountConfirmView" owner:self options:nil];
    self = [objects objectAtIndex:0];
    
    self.frame = CGRectMake(0, 0, Design.DISPLAY_WIDTH, Design.DISPLAY_HEIGHT);
    
    if (self) {
        self.confirmDeleteAccount = NO;
        [self initViews];
    }
    return self;
}

- (void)updateKeyboard:(CGFloat)sizeKeyboard {
    DDLogVerbose(@"%@ updateKeyboard: %f", LOG_TAG, sizeKeyboard);
    
    self.actionViewBottomConstraint.constant = -sizeKeyboard;
    
    [UIView animateWithDuration:1 animations:^{
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
    }];
}

- (void)handleConfirmTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleConfirmTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        if (!self.confirmDeleteAccount) {
            self.confirmDeleteAccount = YES;
            self.confirmView.alpha = 0.5f;
            self.deleteConfirmView.hidden = NO;
            self.deleteConfirmViewHeightConstraint.constant = DESIGN_TEXTFIELD_HEIGHT * Design.HEIGHT_RATIO;
            self.messageLabel.text = TwinmeLocalizedString(@"delete_account_view_controller_confirm_message", nil);
            self.confirmLabel.text = TwinmeLocalizedString(@"application_confirm_deletion", nil);
        } else if ([self.deleteConfirmTextField.text isEqualToString:@"OK"]) {
            if ([self.confirmViewDelegate respondsToSelector:@selector(didTapConfirm:)]) {
                [self.confirmViewDelegate didTapConfirm:self];
            }
        }
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    DDLogVerbose(@"%@ textFieldShouldReturn: %@", LOG_TAG, textField);
    
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidChange:(UITextField *)textField {
    DDLogVerbose(@"%@ textFieldDidChange: %@", LOG_TAG, textField);
    
    if ([textField.text isEqual:@"OK"]) {
        self.confirmView.alpha = 1.0f;
        [textField resignFirstResponder];
    } else {
        self.confirmView.alpha = 0.5f;
    }
}

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    [super initViews];
    
    self.deleteAccountImageViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.deleteAccountImageViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.deleteAccountImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.deleteConfirmViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.deleteConfirmViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.deleteConfirmViewHeightConstraint.constant = 0;
    self.deleteConfirmView.backgroundColor = Design.TEXTFIELD_POPUP_BACKGROUND_COLOR;
    self.deleteConfirmView.layer.cornerRadius = Design.CONTAINER_RADIUS;
    self.deleteConfirmView.clipsToBounds = YES;
    self.deleteConfirmView.hidden = YES;
    
    self.deleteConfirmTextFieldLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.deleteConfirmTextFieldTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.deleteConfirmTextField.font = Design.FONT_REGULAR44;
    self.deleteConfirmTextField.textColor = Design.FONT_COLOR_DEFAULT;
    self.deleteConfirmTextField.tintColor = Design.FONT_COLOR_DEFAULT;
    self.deleteConfirmTextField.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
    [self.deleteConfirmTextField setReturnKeyType:UIReturnKeyDone];
    self.deleteConfirmTextField.delegate = self;
    [self.deleteConfirmTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    self.deleteConfirmTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:TwinmeLocalizedString(@"application_ok", nil) attributes:[NSDictionary dictionaryWithObject:Design.PLACEHOLDER_COLOR forKey:NSForegroundColorAttributeName]];
    
    self.bulletView.hidden = YES;
    self.iconView.hidden = YES;
    self.avatarContainerView.hidden = YES;
    
    self.confirmView.backgroundColor = Design.DELETE_COLOR_RED;
    self.confirmLabel.text = TwinmeLocalizedString(@"delete_account_view_controller_delete", nil);
        
    self.cancelLabel.textColor = Design.FONT_COLOR_DEFAULT;
    
    ApplicationDelegate *delegate = (ApplicationDelegate *)[[UIApplication sharedApplication] delegate];
    TwinmeApplication *twinmeApplication = [delegate twinmeApplication];
    
    if ([twinmeApplication darkModeEnable:self.spaceSettings]) {
        self.deleteConfirmTextField.keyboardAppearance = UIKeyboardAppearanceDark;
    } else {
        self.deleteConfirmTextField.keyboardAppearance = UIKeyboardAppearanceLight;
    }
}

@end
