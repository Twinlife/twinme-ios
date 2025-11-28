/*
 *  Copyright (c) 2016-2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Marouane Qasmi (Marouane.Qasmi@twinlife-systems.com)
 *   Chedi Baccari (Chedi.Baccari@twinlife-systems.com)
 *   Christian Jacquemot (Christian.Jacquemot@twinlife-systems.com)
 *   Fabrice Trescartes (fabrice.trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <Twinlife/TLImageService.h>

#import <Twinme/TLProfile.h>
#import <Twinme/TLContact.h>

#import <Utils/NSString+Utils.h>

#import "EditContactViewController.h"

#import <TwinmeCommon/ApplicationDelegate.h>
#import <TwinmeCommon/Design.h>
#import <TwinmeCommon/EditContactService.h>
#import <TwinmeCommon/TwinmeApplication.h>

#import "DeleteConfirmView.h"
#import "ApplicationAssertion.h"

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

//
// Interface: EditContactViewController ()
//

@interface EditContactViewController () <EditContactServiceDelegate, UITextFieldDelegate, UITextViewDelegate, ConfirmViewDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *nameView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameTextFieldLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameTextFieldTrailingConstraint;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *counterNameLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *counterNameLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet UILabel *counterNameLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *descriptionViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *descriptionViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *descriptionViewTopConstraint;
@property (weak, nonatomic) IBOutlet UIView *descriptionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *descriptionTextViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *descriptionTextViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *descriptionTextViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *descriptionTextViewBottomConstraint;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *counterDescriptionLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *counterDescriptionLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet UILabel *counterDescriptionLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *saveProfileViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *saveProfileViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *saveProfileViewWidthConstraint;
@property (weak, nonatomic) IBOutlet UIView *saveProfileView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *saveProfileLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet UILabel *saveProfileLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *removeViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *removeView;
@property (weak, nonatomic) IBOutlet UILabel *removeLabel;

@property (nonatomic) BOOL keyboardHidden;
@property (nonatomic) BOOL saveViewDisabled;
@property (nonatomic) NSString *contactName;
@property (nonatomic) NSString *contactDescription;
@property (nonatomic) UIImage *contactAvatar;
@property (nonatomic) BOOL updated;
@property (nonatomic) BOOL hasClearedText;
@property (nonatomic) BOOL toRootView;

@property (nonatomic) EditContactService *editContactService;

@end

//
// Implementation: EditContactViewController
//

#undef LOG_TAG
#define LOG_TAG @"EditContactViewController"

@implementation EditContactViewController

#pragma mark - UIViewController

- (instancetype)initWithCoder:(NSCoder *)coder {
    DDLogVerbose(@"%@ initWithCoder: %@", LOG_TAG, coder);
    
    self = [super initWithCoder:coder];
    
    if (self) {
        _keyboardHidden = YES;
        _saveViewDisabled = NO;
        _updated = NO;
        _toRootView = NO;
        _hasClearedText = NO;
        
        _editContactService = [[EditContactService alloc] initWithTwinmeContext:self.twinmeContext delegate:self];
    }
    return self;
}

- (void)viewDidLoad {
    DDLogVerbose(@"%@ viewDidLoad", LOG_TAG);
    
    [super viewDidLoad];
    
    [self initViews];
    
    if (![self.contact hasPeer]) {
        [self finish];
    }
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

#pragma mark - Setters/Getters

- (void)setContact:(TLContact *)contact {
    DDLogVerbose(@"%@ setContact: %@", LOG_TAG, contact);
    
    _contact = contact;
    
    if ([self.contact hasPeer]) {
        self.contactName = self.contact.name;
        if ([self.contact hasPrivateIdentity]) {
            self.identityName = self.contact.identityName;
            [self.editContactService getIdentityImageWithContact:contact withBlock:^(UIImage *image) {
                self.identityAvatar = image;
            }];
        } else {
            self.identityName = nil;
            self.identityAvatar = [TLContact ANONYMOUS_AVATAR];
        }
        if (self.contact.objectDescription.length > 0) {
            self.contactDescription = self.contact.objectDescription;
        } else if (self.contact.peerDescription) {
            self.contactDescription = self.contact.peerDescription;
        } else {
            self.contactDescription = TwinmeLocalizedString(@"side_menu_view_controller_about", nil);
        }
        [self.editContactService initWithContact:self.contact];
    } else {
        self.contactName = self.contact.name;
        self.contactAvatar = [TLContact ANONYMOUS_AVATAR];
    }
}

#pragma mark - UITextFieldDelegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    DDLogVerbose(@"%@ textFieldShouldReturn: %@", LOG_TAG, textField);
    
    [textField resignFirstResponder];
    return NO;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    DDLogVerbose(@"%@ textView: %@ shouldChangeCharactersInRange: %lu shouldChangeCharactersInRange: %@", LOG_TAG, textField, (unsigned long)range.length, string);
    
    return textField.text.length + (string.length - range.length) <= MAX_NAME_LENGTH;
}

- (void)textFieldDidChange:(UITextField *)textField {
    DDLogVerbose(@"%@ textFieldDidChange: %@", LOG_TAG, textField);
    
    if (![textField.text isEqualToString:@""] && ![textField.text isEqualToString:self.contactName]) {
        [self setUpdated];
    } else if ([textField.text isEqualToString:@""] && !self.hasClearedText && ![self.contactName isEqualToString:self.contact.peerTwincodeName]) {
        self.hasClearedText = YES;
        self.nameTextField.text = self.contact.peerTwincodeName;
    } else {
        self.updated = NO;
        self.saveProfileView.alpha = 0.5f;
    }
    
    self.counterNameLabel.text = [NSString stringWithFormat:@"%lu/%d", (unsigned long)self.nameTextField.text.length, MAX_NAME_LENGTH];
}

#pragma mark - UITextViewDelegate

-(void)textViewDidBeginEditing:(UITextView *)textView {
    DDLogVerbose(@"%@ textViewDidBeginEditing: %@", LOG_TAG, textView);
    
    if ([textView.text isEqualToString:TwinmeLocalizedString(@"side_menu_view_controller_about", nil)]) {
        textView.text = @"";
        textView.textColor = Design.FONT_COLOR_DEFAULT;
    }
}

- (void)textViewDidChange:(UITextView *)textView {
    DDLogVerbose(@"%@ textViewDidChange: %@", LOG_TAG, textView);
    
    if (![textView.text isEqualToString:self.contact.objectDescription]) {
        [self setUpdated];
    } else if ([self.nameTextField.text isEqualToString:self.contactName]) {
        self.updated = NO;
        self.saveProfileView.alpha = 0.5;
    }
    
    self.counterDescriptionLabel.text = [NSString stringWithFormat:@"%lu/%d", (unsigned long)self.descriptionTextView.text.length, MAX_DESCRIPTION_LENGTH];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    DDLogVerbose(@"%@ textView: %@ shouldChangeTextInRange: %lu replacementText: %@", LOG_TAG, textView, (unsigned long)range.length, text);
    
    return textView.text.length + (text.length - range.length) <= MAX_DESCRIPTION_LENGTH;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    DDLogVerbose(@"%@ textViewDidEndEditing: %@", LOG_TAG, textView);
    
    if ([textView.text isEqualToString:@""]) {
        textView.text = TwinmeLocalizedString(@"side_menu_view_controller_about", nil);
        textView.textColor = Design.PLACEHOLDER_COLOR;
    }
}


#pragma mark - EditContactServiceDelegate

- (void)onUpdateContact:(nonnull TLContact *)contact avatar:(nullable UIImage *)avatar {
    DDLogVerbose(@"%@ onUpdateContact: %@", LOG_TAG, contact);
    
    TL_ASSERT_EQUAL(self.twinmeContext, contact.uuid, self.contact.uuid, [ApplicationAssertPoint INVALID_SUBJECT], TLAssertionParameterSubject, nil);
    
    [self finish];
}

- (void)onRefreshContactAvatar:(nonnull UIImage *)avatar {
    DDLogVerbose(@"%@ onRefreshContactAvatar: %@", LOG_TAG, avatar);

    self.contactAvatar = avatar;
    self.avatarView.image = avatar;
}

- (void)onDeleteContact:(NSUUID *)contactId {
    DDLogVerbose(@"%@ onDeleteContact: %@", LOG_TAG, contactId);
    
    TL_ASSERT_EQUAL(self.twinmeContext, contactId, self.contact.uuid, [ApplicationAssertPoint INVALID_SUBJECT], TLAssertionParameterSubject, nil);

    self.toRootView = YES;
    [self finish];
}

#pragma mark - ConfirmViewDelegate

- (void)didTapConfirm:(nonnull AbstractConfirmView *)abstractConfirmView {
    DDLogVerbose(@"%@ didTapConfirm: %@", LOG_TAG, abstractConfirmView);
    
    [self.editContactService deleteContact:self.contact];
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
    
    [super initViews];
    
    self.view.backgroundColor = Design.WHITE_COLOR;
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)]];
    
    [self setNavigationTitle:TwinmeLocalizedString(@"application_edit", nil)];
    
    self.nameViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.nameViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.nameViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.nameView.backgroundColor = Design.TEXTFIELD_BACKGROUND_COLOR;
    self.nameView.layer.cornerRadius = Design.CONTAINER_RADIUS;
    self.nameView.clipsToBounds = YES;
    
    self.nameTextFieldLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.nameTextFieldTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.nameTextField.font = Design.FONT_REGULAR44;
    self.nameTextField.textColor = Design.FONT_COLOR_DEFAULT;
    self.nameTextField.tintColor = Design.FONT_COLOR_DEFAULT;
    self.nameTextField.text = self.contactName;
    self.nameTextField.placeholder = self.contact.peerTwincodeName;
    [self.nameTextField setReturnKeyType:UIReturnKeyDone];
    self.nameTextField.delegate = self;
    [self.nameTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    self.counterNameLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.counterNameLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    
    self.counterNameLabel.font = Design.FONT_REGULAR26;
    self.counterNameLabel.textColor = Design.FONT_COLOR_DEFAULT;
    
    if (self.contactName.length > MAX_NAME_LENGTH) {
        self.nameTextField.text = [self.contactName substringToIndex:MAX_NAME_LENGTH];
        self.counterNameLabel.text = [NSString stringWithFormat:@"%d/%d", MAX_NAME_LENGTH, MAX_NAME_LENGTH];
    } else {
        self.counterNameLabel.text = [NSString stringWithFormat:@"%lu/%d", (unsigned long)self.contactName.length, MAX_NAME_LENGTH];
    }
    
    self.descriptionViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.descriptionViewHeightConstraint.constant = Design.DESCRIPTION_HEIGHT;
    self.descriptionViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.descriptionView.backgroundColor = Design.TEXTFIELD_BACKGROUND_COLOR;
    self.descriptionView.layer.cornerRadius = Design.CONTAINER_RADIUS;
    self.descriptionView.clipsToBounds = YES;
    
    self.descriptionTextViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.descriptionTextViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.descriptionTextView.font = Design.FONT_REGULAR28;
    self.descriptionTextView.textColor = Design.PLACEHOLDER_COLOR;
    self.descriptionTextView.tintColor = Design.FONT_COLOR_DEFAULT;
    self.descriptionTextView.delegate = self;
    self.descriptionTextView.text = TwinmeLocalizedString(@"side_menu_view_controller_about", nil);
    self.descriptionTextView.textContainer.lineFragmentPadding = 0;
    self.descriptionTextView.textContainerInset = UIEdgeInsetsZero;
    self.descriptionTextView.text = self.contactDescription;
    
    self.counterDescriptionLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.counterDescriptionLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    
    self.counterDescriptionLabel.font = Design.FONT_REGULAR26;
    self.counterDescriptionLabel.textColor = Design.FONT_COLOR_DEFAULT;
    
    if (self.contactDescription && ![self.contactDescription isEqualToString:@""]) {
        self.descriptionTextView.text = self.contactDescription;
        self.descriptionTextView.textColor = Design.FONT_COLOR_DEFAULT;
        self.counterDescriptionLabel.text = [NSString stringWithFormat:@"%lu/%d", (unsigned long)self.descriptionTextView.text.length, MAX_DESCRIPTION_LENGTH];
    } else {
        self.descriptionTextView.text = TwinmeLocalizedString(@"side_menu_view_controller_about", nil);
        self.descriptionTextView.textColor = Design.PLACEHOLDER_COLOR;
        self.counterDescriptionLabel.text = [NSString stringWithFormat:@"0/%d", MAX_DESCRIPTION_LENGTH];
    }
    
    self.saveProfileViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.saveProfileViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.saveProfileViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.saveProfileView.backgroundColor = Design.MAIN_COLOR;
    self.saveProfileView.userInteractionEnabled = YES;
    self.saveProfileView.layer.cornerRadius = Design.CONTAINER_RADIUS;
    self.saveProfileView.clipsToBounds = YES;
    self.saveProfileView.isAccessibilityElement = YES;
    self.saveProfileView.accessibilityLabel = TwinmeLocalizedString(@"application_save", nil);
    [self.saveProfileView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSaveTapGesture:)]];
    self.saveProfileView.alpha = 0.5f;
    
    self.saveProfileLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.saveProfileLabel.font = Design.FONT_BOLD36;
    self.saveProfileLabel.textColor = [UIColor whiteColor];
    self.saveProfileLabel.text = TwinmeLocalizedString(@"application_save", nil);
    
    self.removeViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.removeView.backgroundColor = Design.BACKGROUND_COLOR_WHITE_OPACITY11;
    UITapGestureRecognizer *removeViewGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleRemoveTapGesture:)];
    [self.removeView addGestureRecognizer:removeViewGestureRecognizer];
    
    self.removeLabel.font = Design.FONT_REGULAR34;
    self.removeLabel.textColor = Design.DELETE_COLOR_RED;
    self.removeLabel.text = TwinmeLocalizedString(@"application_delete", nil);
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture)];
    [self.view addGestureRecognizer:tapGesture];
    
    self.nameLabel.text = self.contactName;
    self.avatarView.image = self.contactAvatar;
}

- (void)finish {
    DDLogVerbose(@"%@ finish", LOG_TAG);
    
    if (self.editContactService) {
        [self.editContactService dispose];
        self.editContactService = nil;
    }
    
    self.navigationController.navigationBarHidden = NO;
    if (self.toRootView) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)setUpdated {
    DDLogVerbose(@"%@ setUpdated", LOG_TAG);
    
    if (self.updated) {
        return;
    }
    self.updated = YES;
    
    self.saveProfileView.alpha = 1.0f;
}

- (void)keyboardWillShow:(NSNotification *)notification {
    DDLogVerbose(@"%@ keyboardWillShow: %@", LOG_TAG, notification);
    
    if (!self.keyboardHidden) {
        return;
    }
    
    self.keyboardHidden = NO;
    NSDictionary *info = [notification userInfo];
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    CGRect saveViewFrame = self.saveProfileView.frame;
    CGRect frame = self.view.frame;
    CGFloat slidePosition = frame.size.height - (keyboardSize.height + saveViewFrame.origin.y + saveViewFrame.size.height + self.saveProfileViewTopConstraint.constant);
    [self moveSlideToPosition:slidePosition];
    
    if ([self.twinmeApplication getDefaultKeyboardHeight] != keyboardSize.height) {
        [self.twinmeApplication setDefaultKeyboardHeight:keyboardSize.height];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification {
    DDLogVerbose(@"%@ keyboardWillHide: %@", LOG_TAG, notification);
    
    self.keyboardHidden = YES;
    
    [self moveSlideToInitialPosition];
}

- (void)dismissKeyboard {
    DDLogVerbose(@"%@ dismissKeyboard", LOG_TAG);
    
    if (!self.keyboardHidden) {
        [self.nameTextField resignFirstResponder];
    }
}

- (void)handleTapGesture {
    DDLogVerbose(@"%@ handleTapGesture", LOG_TAG);
    
    if ([self.nameTextField isFirstResponder]) {
        [self.nameTextField resignFirstResponder];
    }
    
    if ([self.descriptionTextView isFirstResponder]) {
        [self.descriptionTextView resignFirstResponder];
    }
}

- (void)handleSaveTapGesture:(UIButton *)sender {
    DDLogVerbose(@"%@ handleSaveTapGesture: %@", LOG_TAG, sender);
    
    if (!self.updated) {
        return;
    }
    
    if (!self.saveViewDisabled) {
        self.saveViewDisabled = YES;
        
        NSString *updatedContactName = self.nameTextField.text;
        if (updatedContactName.length == 0) {
            updatedContactName = self.nameTextField.placeholder;
        }
        
        NSString *updatedContactDescription = self.descriptionTextView.text;
        if (updatedContactDescription.length == 0 || [updatedContactDescription isEqualToString:TwinmeLocalizedString(@"side_menu_view_controller_about", nil)]) {
            updatedContactDescription = self.contact.peerDescription;
        }
        
        if (![updatedContactName isEqualToString:self.contactName] || ![updatedContactDescription isEqualToString:self.contactDescription]) {
            [self.editContactService updateContactWithContact:self.contact contactName:updatedContactName contactDescription:updatedContactDescription];
        } else {
            [self finish];
        }
    }
}

- (void)handleRemoveTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleRemoveTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        DeleteConfirmView *deleteConfirmView = [[DeleteConfirmView alloc] init];
        deleteConfirmView.confirmViewDelegate = self;
        deleteConfirmView.deleteConfirmType = DeleteConfirmTypeOriginator;
        
        NSString *message = [NSString stringWithFormat:@"%@\n%@", TwinmeLocalizedString(@"edit_contact_view_controller_message", nil), TwinmeLocalizedString(@"edit_contact_view_controller_confirm_message", nil)];
        
        [deleteConfirmView initWithTitle:TwinmeLocalizedString(@"delete_account_view_controller_warning", nil) message:message avatar:self.contactAvatar icon:[UIImage imageNamed:@"ActionBarDelete"]];
        [self.view addSubview:deleteConfirmView];
        [deleteConfirmView showConfirmView];
    }
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    self.nameTextField.font = Design.FONT_REGULAR28;
    self.saveProfileLabel.font = Design.FONT_BOLD36;
    self.removeLabel.font = Design.FONT_REGULAR34;
    self.descriptionTextView.font = Design.FONT_REGULAR28;
    self.counterNameLabel.font = Design.FONT_REGULAR26;
    self.counterDescriptionLabel.font = Design.FONT_REGULAR26;
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    [super updateColor];
    
    self.nameView.backgroundColor = Design.TEXTFIELD_BACKGROUND_COLOR;
    self.saveProfileView.backgroundColor = Design.MAIN_COLOR;
    self.nameTextField.textColor = Design.FONT_COLOR_DEFAULT;
    self.nameTextField.tintColor = Design.FONT_COLOR_DEFAULT;
    
    self.nameTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.contact.peerTwincodeName attributes:[NSDictionary dictionaryWithObject:Design.PLACEHOLDER_COLOR forKey:NSForegroundColorAttributeName]];
    
    self.counterNameLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.counterDescriptionLabel.textColor = Design.FONT_COLOR_DEFAULT;
    
    if ([self.descriptionTextView.text isEqualToString:TwinmeLocalizedString(@"side_menu_view_controller_about", nil)]) {
        self.descriptionTextView.textColor = Design.PLACEHOLDER_COLOR;
    } else {
        self.descriptionTextView.textColor = Design.FONT_COLOR_DEFAULT;
    }
    
    if ([self.twinmeApplication darkModeEnable]) {
        self.nameTextField.keyboardAppearance = UIKeyboardAppearanceDark;
        self.descriptionTextView.keyboardAppearance = UIKeyboardAppearanceDark;
    } else {
        self.nameTextField.keyboardAppearance = UIKeyboardAppearanceLight;
        self.descriptionTextView.keyboardAppearance = UIKeyboardAppearanceLight;
    }
}

@end
