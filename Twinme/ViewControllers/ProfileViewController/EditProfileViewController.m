/*
 *  Copyright (c) 2021-2024 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <Twinme/TLProfile.h>
#import <Twinme/TLCallReceiver.h>
#import <Twinme/TLContact.h>
#import <Twinme/TLGroup.h>
#import <Twinme/TLSpace.h>
#import <Twinme/UIImage+Resize.h>

#import <Utils/NSString+Utils.h>

#import "EditProfileViewController.h"
#import "OnboardingProfileViewController.h"
#import "NotificationViewController.h"

#import "AlertMessageView.h"
#import "DeviceAuthorization.h"
#import "MenuSelectValueView.h"
#import "MenuPhotoView.h"
#import "MenuPropagatingProfileView.h"
#import "UIViewController+ProgressIndicator.h"
#import "ApplicationAssertion.h"

#import <TwinmeCommon/Design.h>
#import <TwinmeCommon/EditIdentityService.h>
#import <TwinmeCommon/MainViewController.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static UIColor *DESIGN_AVATAR_PLACEHOLDER_COLOR;

//
// Interface: EditProfileViewController ()
//

@interface EditProfileViewController () <EditIdentityServiceDelegate, UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextViewDelegate, UIAdaptivePresentationControllerDelegate, MenuSelectValueDelegate, MenuPhotoViewDelegate, AlertMessageViewDelegate, MenuPropagatingProfileDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *avatarPlaceholderImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *avatarPlaceholderImageView;
@property (weak, nonatomic) IBOutlet UIView *editAvatarView;
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
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *propagateViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *propagateViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *propagateViewTopConstraint;
@property (weak, nonatomic) IBOutlet UIView *propagateView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *propagateLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *propagateLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *propagateImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *propagateImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *saveProfileViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *saveProfileViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *saveProfileViewWidthConstraint;
@property (weak, nonatomic) IBOutlet UIView *saveProfileView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *saveProfileLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet UILabel *saveProfileLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;

@property (nonatomic) BOOL keyboardHidden;
@property (nonatomic) BOOL updated;
@property (nonatomic) BOOL isActiveProfile;
@property (nonatomic) UIImage *updatedIdentityAvatar;
@property (nonatomic) UIImage *updatedIdentityLargeAvatar;

@property (nonatomic) EditIdentityService *editIdentityService;
@property (nonatomic) TLProfile *profile;
@property (nonatomic) TLSpace *space;
@property (nonatomic) NSString *name;
@property (nonatomic) NSString *identityDescription;
@property (nonatomic) UIImage *avatar;

@property (nonatomic) BOOL updateProfileDone;

@end

//
// Implementation: EditProfileViewController
//

#undef LOG_TAG
#define LOG_TAG @"EditProfileViewController"

@implementation EditProfileViewController

#pragma mark - UIViewController

+ (void)initialize {
    DDLogVerbose(@"%@ initialize", LOG_TAG);
    
    DESIGN_AVATAR_PLACEHOLDER_COLOR = [UIColor colorWithRed:242./255. green:243./255. blue:245./255. alpha:1.0];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    DDLogVerbose(@"%@ initWithCoder: %@", LOG_TAG, coder);
    
    self = [super initWithCoder:coder];
    
    if (self) {
        _updated = NO;
        _keyboardHidden = YES;
        _updateProfileDone = NO;
        _editIdentityService = [[EditIdentityService alloc] initWithTwinmeContext:self.twinmeContext delegate:self];
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
    
    if (!self.updateProfileDone) {
        self.updateProfileDone = YES;
        [self updateProfile];
        
        if (self.profile) {
            [self.editIdentityService refreshWithProfile:self.profile];
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    DDLogVerbose(@"%@ viewWillDisappear: %@", LOG_TAG, animated ? @"YES" : @"NO");
    
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    DDLogVerbose(@"%@ viewDidAppear: %@", LOG_TAG, animated ? @"YES" : @"NO");
    
    [super viewDidAppear:animated];
}

- (void)backTap {
    DDLogVerbose(@"%@ backTap", LOG_TAG);

    [super backTap];

    if (self.navigationController.viewControllers.count == 1) {
        [self.nameTextField resignFirstResponder];
        [self.descriptionTextView resignFirstResponder];
    }
}

#pragma mark - Public methods

- (void)initWithProfile:(TLProfile *)profile isActive:(BOOL)isActive {
    DDLogVerbose(@"%@ initWithProfile: %@ isActive: %d", LOG_TAG, profile, isActive);
    
    self.profile = profile;
    self.isActiveProfile = isActive;
    [self updateProfile];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    DDLogVerbose(@"%@ textFieldShouldReturn: %@", LOG_TAG, textField);
    
    [textField resignFirstResponder];
    return NO;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    DDLogVerbose(@"%@ textView: %@ shouldChangeCharactersInRange: %lu shouldChangeCharactersInRange: %@", LOG_TAG, textField, (unsigned long)range.length, string);
    
    return textField.text.length + (string.length - range.length) <= MAX_NAME_LENGTH;
}

- (void)textFieldDidChange:(UITextField *)textField{
    DDLogVerbose(@"%@ textFieldDidChange: %@", LOG_TAG, textField);
    
    [self setUpdated];
    
    self.counterNameLabel.text = [NSString stringWithFormat:@"%lu/%d", (unsigned long)self.nameTextField.text.length, MAX_NAME_LENGTH];
}

#pragma mark - UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView {
    DDLogVerbose(@"%@ textViewDidBeginEditing: %@", LOG_TAG, textView);
    
    if ([textView.text isEqualToString:TwinmeLocalizedString(@"side_menu_view_controller_about", nil)]) {
        textView.text = @"";
        textView.textColor = Design.FONT_COLOR_DEFAULT;
    }
}

- (void)textViewDidChange:(UITextView *)textView {
    DDLogVerbose(@"%@ textViewDidChange: %@", LOG_TAG, textView);
    
    [self setUpdated];
    
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

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)pickerController didFinishPickingMediaWithInfo:(NSDictionary *)info {
    DDLogVerbose(@"%@ imagePickerController: %@ didFinishPickingMediaWithInfo: %@", LOG_TAG, pickerController, info);
    
    self.navigationController.navigationBarHidden = YES;
    
    [pickerController dismissViewControllerAnimated:YES completion:^{
        self.avatarPlaceholderImageView.hidden = NO;
        self.updatedIdentityLargeAvatar = info[UIImagePickerControllerEditedImage];
        self.updatedIdentityAvatar = [self.updatedIdentityLargeAvatar resizeImage];
        self.avatarView.image = self.updatedIdentityLargeAvatar;
        
        [self setUpdated];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)pickerController {
    DDLogVerbose(@"%@ imagePickerControllerDidCancel: %@", LOG_TAG, pickerController);
    
    self.navigationController.navigationBarHidden = YES;
    [pickerController dismissViewControllerAnimated:YES completion:nil];
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

#pragma mark - EditIdentityServiceDelegate

- (void)onSetCurrentSpace:(nonnull TLSpace *)space {
    DDLogVerbose(@"%@ onSetCurrentSpace: %@", LOG_TAG, space);

    if (space.profile) {
        self.updateProfileDone = NO;
        self.profile = space.profile;
        [self updateProfile];
        [self.editIdentityService refreshWithProfile:self.profile];
    }
}

- (void)onUpdateSpace:(nonnull TLSpace *)space {
    DDLogVerbose(@"%@ onUpdateSpace: %@", LOG_TAG, space);

    if (space.profile && self.navigationController.viewControllers.count == 1) {
        self.updateProfileDone = NO;
        self.profile = space.profile;
        [self updateProfile];
        [self.editIdentityService refreshWithProfile:self.profile];
    }
}

- (void)onCreateProfile:(TLProfile *)profile {
    DDLogVerbose(@"%@ onCreateProfile: %@", LOG_TAG, profile);
    
    self.profile = profile;
    
    self.updated = NO;
    
    [self updateProfile];
    [self.editIdentityService refreshWithProfile:self.profile];
}

- (void)onUpdateProfile:(TLProfile *)profile {
    DDLogVerbose(@"%@ onUpdateProfile: %@", LOG_TAG, profile);
    
    if ([self.profile.uuid isEqual:profile.uuid]) {
        self.profile = profile;
        
        self.updated = NO;
        
        if (self.navigationController.viewControllers.count > 1) {
            [self finish];
        } else {
            [self.nameTextField resignFirstResponder];
            [self.descriptionTextView resignFirstResponder];
            self.saveProfileView.alpha = 0.5;
            [self hideProgressIndicator];
        }
    }
}

- (void)onUpdateCallReceiver:(TLCallReceiver *)callReceiver {
    DDLogVerbose(@"%@ onUpdateCallReceiver: %@", LOG_TAG, callReceiver);
    
}

- (void)onDeleteProfile:(NSUUID *)profileId {
    DDLogVerbose(@"%@ onDeleteProfile: %@", LOG_TAG, profileId);
    
    if ([self.profile.uuid isEqual:profileId]) {
        [self finish];
    }
}

- (void)onUpdateIdentityAvatar:(UIImage *)avatar {
    DDLogVerbose(@"%@ onUpdateIdentityAvatar: %@", LOG_TAG, avatar);
    
    self.avatarView.image = avatar;
}

#pragma mark - UIAdaptivePresentationControllerDelegate

- (void)presentationControllerWillDismiss:(UIPresentationController *)presentationController {
    DDLogVerbose(@"%@ presentationControllerWillDismiss: %@", LOG_TAG, presentationController);

    self.navigationController.navigationBarHidden = YES;
}

#pragma mark - MenuSelectValueDelegate

- (void)cancelMenuSelectValue:(MenuSelectValueView *)menuSelectValueView {
    DDLogVerbose(@"%@ cancelMenuSelectValue: %@", LOG_TAG, menuSelectValueView);
    
    [menuSelectValueView removeFromSuperview];
}

- (void)selectValue:(MenuSelectValueView *)menuSelectValueView value:(int)value {
    DDLogVerbose(@"%@ selectValue: %d", LOG_TAG, value);
    
    [menuSelectValueView removeFromSuperview];
    
    [self.twinmeApplication setProfileUpdateModeWithMode:value];
    
    NSMutableAttributedString *valueAttributedString = [[NSMutableAttributedString alloc] initWithString:TwinmeLocalizedString(@"edit_profile_view_controller_propagating_profile", nil) attributes:[NSDictionary dictionaryWithObjectsAndKeys:Design.FONT_REGULAR32, NSFontAttributeName, Design.FONT_COLOR_DEFAULT, NSForegroundColorAttributeName, nil]];
    
    NSString *subTitle = @"";

    if (value == TLProfileUpdateModeAll) {
        subTitle = TwinmeLocalizedString(@"edit_profile_view_controller_propagating_all_contacts", nil);
    } else if (value == TLProfileUpdateModeDefault) {
        subTitle = TwinmeLocalizedString(@"edit_profile_view_controller_propagating_except_contacts", nil);
    } else {
        subTitle = TwinmeLocalizedString(@"edit_profile_view_controller_propagating_no_contact", nil);
    }
    
    [valueAttributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:@"\n"]];
    [valueAttributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:subTitle attributes:[NSDictionary dictionaryWithObjectsAndKeys:Design.FONT_REGULAR32, NSFontAttributeName, Design.FONT_COLOR_GREY, NSForegroundColorAttributeName, nil]]];
    
    self.propagateLabel.attributedText = valueAttributedString;
}

#pragma mark - MenuPhotoViewDelegate

- (void)menuPhotoDidSelectCamera:(MenuPhotoView *)menuPhotoView {
    DDLogVerbose(@"%@ menuPhotoDidSelectCamera", LOG_TAG);
    
    [menuPhotoView removeFromSuperview];
    [self takePhoto];
}

- (void)menuPhotoDidSelectGallery:(MenuPhotoView *)menuPhotoView {
    DDLogVerbose(@"%@ menuPhotoDidSelectGallery", LOG_TAG);
    
    [menuPhotoView removeFromSuperview];
    [self selectPhoto];
}

- (void)cancelMenuPhoto:(MenuPhotoView *)menuPhotoView {
    DDLogVerbose(@"%@ menuPhotoDidSelectCamera", LOG_TAG);
 
    [menuPhotoView removeFromSuperview];
}

#pragma mark - MenuPropagatingProfileDelegate

- (void)cancelMenuPropagatingProfileView:(MenuPropagatingProfileView *)menuPropagatingProfileView {
    DDLogVerbose(@"%@ cancelMenuPropagatingProfileView: %@", LOG_TAG, menuPropagatingProfileView);
    
    [menuPropagatingProfileView removeFromSuperview];
    
    [self saveProfile];
}

- (void)saveProfileWithUpdateMode:(MenuPropagatingProfileView *)menuPropagatingProfileView profileUpdateMode:(TLProfileUpdateMode)profileUpdateMode {
    DDLogVerbose(@"%@ saveProfileWithUpdateMode: %@ profileUpdateMode: %d", LOG_TAG, menuPropagatingProfileView, profileUpdateMode);
    
    [menuPropagatingProfileView removeFromSuperview];
    
    [self.twinmeApplication setProfileUpdateModeWithMode:profileUpdateMode];
    
    [self saveProfile];
}

#pragma mark - Private methods

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    [super initViews];
    
    self.view.backgroundColor = Design.WHITE_COLOR;
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)]];
    
    [self.editAvatarView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleUpdateAvatarTapGesture)]];
    self.editAvatarView.isAccessibilityElement = YES;
    
    self.avatarView.backgroundColor = DESIGN_AVATAR_PLACEHOLDER_COLOR;
    
    self.avatarPlaceholderImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.nameLabel.text = TwinmeLocalizedString(@"application_profile", nil);
    
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
    [self.nameTextField setReturnKeyType:UIReturnKeyDone];
    self.nameTextField.delegate = self;
    [self.nameTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    self.counterNameLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.counterNameLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    
    self.counterNameLabel.font = Design.FONT_REGULAR26;
    self.counterNameLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.counterNameLabel.text = [NSString stringWithFormat:@"0/%d", MAX_NAME_LENGTH];
    
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
    
    self.counterDescriptionLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.counterDescriptionLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    
    self.counterDescriptionLabel.font = Design.FONT_REGULAR26;
    self.counterDescriptionLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.counterDescriptionLabel.text = [NSString stringWithFormat:@"0/%d", MAX_DESCRIPTION_LENGTH];
    
    self.propagateViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.propagateViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.propagateViewTopConstraint.constant *= Design.HEIGHT_RATIO;
        
    self.propagateView.clipsToBounds = YES;
    self.propagateView.isAccessibilityElement = YES;
    self.propagateView.accessibilityLabel = TwinmeLocalizedString(@"edit_profile_view_controller_propagating_profile", nil);
    [self.propagateView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handlePropagateTapGesture:)]];
    
    self.propagateLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.propagateLabel.font = Design.FONT_REGULAR32;
    self.propagateLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.propagateLabel.text = TwinmeLocalizedString(@"edit_profile_view_controller_propagating_profile", nil);

    self.propagateImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
        
    self.saveProfileViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.saveProfileViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.saveProfileViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    
    self.saveProfileView.backgroundColor = Design.MAIN_COLOR;
    self.saveProfileView.userInteractionEnabled = YES;
    self.saveProfileView.layer.cornerRadius = Design.CONTAINER_RADIUS;
    self.saveProfileView.clipsToBounds = YES;
    self.saveProfileView.isAccessibilityElement = YES;
    self.saveProfileView.accessibilityLabel = TwinmeLocalizedString(@"application_save", nil);
    [self.saveProfileView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSaveTapGesture:)]];
    
    self.saveProfileLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.saveProfileLabel.font = Design.FONT_BOLD36;
    self.saveProfileLabel.textColor = [UIColor whiteColor];
    self.saveProfileLabel.text = TwinmeLocalizedString(@"application_save", nil);
    
    self.messageLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.messageLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    
    self.messageLabel.font = Design.FONT_REGULAR32;
    self.messageLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.messageLabel.text = TwinmeLocalizedString(@"create_profile_view_controller_message", nil);
        
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture)];
    [self.view addGestureRecognizer:tapGesture];
}

- (void)finish {
    DDLogVerbose(@"%@ finish", LOG_TAG);
    
    if (self.editIdentityService) {
        [self.editIdentityService dispose];
        self.editIdentityService = nil;
    }
    
    [self.navigationController popViewControllerAnimated:YES];
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

- (void)setUpdated {
    DDLogVerbose(@"%@ setUpdated", LOG_TAG);
    
    if (!self.profile) {
        if ([self.nameTextField.text length] > 0 && self.updatedIdentityAvatar) {
            self.updated = YES;
        } else {
            self.updated = NO;
        }
    } else {
        NSString *updatedIdentityName =  [self.nameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if (updatedIdentityName.length == 0) {
            updatedIdentityName = self.nameTextField.placeholder;
        }
        
        NSString *updatedIdentityDescription =  [self.descriptionTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if ([updatedIdentityDescription isEqualToString:TwinmeLocalizedString(@"side_menu_view_controller_about", nil)]) {
            updatedIdentityDescription = @"";
        }
        
        BOOL updated = ![updatedIdentityName isEqualToString:self.nameTextField.placeholder] || ![updatedIdentityDescription isEqualToString:self.identityDescription];
        updated = updated || self.updatedIdentityAvatar != nil;
        
        self.updated = updated;
    }
    
    if (self.updated) {
        self.saveProfileView.alpha = 1.0;
    } else {
        self.saveProfileView.alpha = 0.5;
    }
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
        [self.descriptionTextView resignFirstResponder];
    }
}

- (void)handleUpdateAvatarTapGesture {
    DDLogVerbose(@"%@ handleUpdateAvatarTapGesture", LOG_TAG);
    
    [self openMenuPhoto];
}

- (void)handlePropagateTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handlePropagateTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        [self openMenuSelectValue];
    }
}

- (void)handleSaveTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleSaveTapGesture: %@", LOG_TAG, sender);
    
    if (!self.profile) {
        if ([self.nameTextField.text length] == 0) {
            AlertMessageView *alertMessageView = [[AlertMessageView alloc] init];
            alertMessageView.alertMessageViewDelegate = self;
            [alertMessageView initWithTitle:TwinmeLocalizedString(@"delete_account_view_controller_warning", nil) message:TwinmeLocalizedString(@"application_profile_name_not_defined", nil)];
            [self.tabBarController.view addSubview:alertMessageView];
            [alertMessageView showAlertView];
            return;
        } else if (!self.updatedIdentityAvatar) {
            [self openMenuPhoto];
            return;
        }
    }
    
    if (!self.updated) {
        return;
    }
    
    if (self.profile) {
        [self dismissKeyboard];
        MenuPropagatingProfileView *menuPropagatingProfileView = [[MenuPropagatingProfileView alloc] init];
        menuPropagatingProfileView.menuPropagatingProfileDelegate = self;
        [self.tabBarController.view addSubview:menuPropagatingProfileView];
        [menuPropagatingProfileView openMenu];
    } else {
        [self saveProfile];
    }
}

- (void)saveProfile {
    DDLogVerbose(@"%@ saveProfile", LOG_TAG);
    
    NSString *updatedIdentityName =  [self.nameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (updatedIdentityName.length == 0) {
        updatedIdentityName = self.nameTextField.placeholder;
    }
    
    NSString *updatedIdentityDescription =  [self.descriptionTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([updatedIdentityDescription isEqualToString:TwinmeLocalizedString(@"side_menu_view_controller_about", nil)]) {
        updatedIdentityDescription = @"";
    }
    
    BOOL updated = ![updatedIdentityName isEqualToString:self.nameTextField.placeholder] || ![updatedIdentityDescription isEqualToString:self.identityDescription];
    updated = updated || self.updatedIdentityAvatar != nil;
    if (updated && updatedIdentityName) {
        UIImage *avatar = self.updatedIdentityAvatar;
        if (!avatar) {
            // If no new image is selected, give the previous image
            avatar = self.avatar;
        }
        if (self.profile) {
            [self.editIdentityService updateIdentityWithProfile:self.profile identityName:updatedIdentityName identityDescription:updatedIdentityDescription identityAvatar:avatar identityLargeAvatar:self.updatedIdentityLargeAvatar profileUpdateMode:self.twinmeApplication.profileUpdateMode];
        } else {
            [self.editIdentityService createProfile:updatedIdentityName identityDescription:updatedIdentityDescription identityAvatar:avatar identityLargeAvatar:self.updatedIdentityLargeAvatar space:self.currentSpace];
        }
    }
}


- (void)takePhoto {
    DDLogVerbose(@"%@ takePhoto", LOG_TAG);
    
    AVAuthorizationStatus cameraAuthorizationStatus = [DeviceAuthorization deviceCameraAuthorizationStatus];
    switch (cameraAuthorizationStatus) {
        case AVAuthorizationStatusNotDetermined: {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if (granted) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
                        picker.delegate = self;
                        picker.allowsEditing = YES;
                        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                        picker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
                        [self presentViewController:picker animated:YES completion:nil];
                    });
                }
            }];
            break;
        }
            
        case AVAuthorizationStatusRestricted:
        case AVAuthorizationStatusDenied: {
            [DeviceAuthorization showCameraSettingsAlertInController:self];
            break;
        }
            
        case AVAuthorizationStatusAuthorized: {
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.allowsEditing = YES;
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            picker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
            [self presentViewController:picker animated:YES completion:nil];
            break;
        }
    }
}

- (void)selectPhoto {
    DDLogVerbose(@"%@ selectPhoto", LOG_TAG);
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.presentationController.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        CGSize size = self.view.bounds.size;
        picker.modalPresentationStyle = UIModalPresentationPopover;
        picker.popoverPresentationController.sourceView = self.view;
        picker.popoverPresentationController.sourceRect = CGRectMake(size.width / 2., size.height * 0.2, size.width * 0.6, size.height * 0.7);
        picker.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionAny;
        [self presentViewController:picker animated:YES completion:nil];
    } else {
        [self presentViewController:picker animated:YES completion:nil];
    }
}

- (void)openMenuSelectValue {
    DDLogVerbose(@"%@ openMenuSelectValue", LOG_TAG);
    
    [self dismissKeyboard];
    
    MenuSelectValueView *menuSelectValueView = [[MenuSelectValueView alloc]init];
    menuSelectValueView.menuSelectValueDelegate = self;
    [self.tabBarController.view addSubview:menuSelectValueView];
    [menuSelectValueView setMenuSelectValueTypeWithType:MenuSelectValueTypeProfileUpdateMode];
    [menuSelectValueView openMenu];
}

- (void)openMenuPhoto {
    DDLogVerbose(@"%@ openMenuPhoto", LOG_TAG);
    
    [self dismissKeyboard];
    
    MenuPhotoView *menuPhotoView = [[MenuPhotoView alloc]init];
    menuPhotoView.menuPhotoViewDelegate = self;
    [self.tabBarController.view addSubview:menuPhotoView];
    [menuPhotoView openMenu:NO];
}

- (void)updateProfile {
    DDLogVerbose(@"%@ updateProfile", LOG_TAG);
    
    NSString *placeholder = @"";
    if (self.profile) {
        self.nameLabel.text = TwinmeLocalizedString(@"edit_profile_view_controller_editing_profile", nil);
        [self.editIdentityService getImageWithProfile:self.profile withBlock:^(UIImage *image) {
            self.avatar = image;
        }];
        self.avatarView.image = self.avatar;
        self.nameTextField.text = self.profile.name;
        self.identityDescription = self.profile.objectDescription;
        
        TL_ASSERT_NOT_NULL(self.twinmeContext, self.profile.name, [ApplicationAssertPoint INVALID_NAME], [TLAssertValue initWithSubject:self.profile], nil);

        if (self.profile.name) {
            placeholder = self.profile.name;
        }
        self.saveProfileView.alpha = self.updated ? 1.0 : 0.5;
                
        NSMutableAttributedString *valueAttributedString = [[NSMutableAttributedString alloc] initWithString:TwinmeLocalizedString(@"edit_profile_view_controller_propagating_profile", nil) attributes:[NSDictionary dictionaryWithObjectsAndKeys:Design.FONT_REGULAR32, NSFontAttributeName, Design.FONT_COLOR_DEFAULT, NSForegroundColorAttributeName, nil]];
        
        NSString *subTitle = @"";

        if (self.twinmeApplication.profileUpdateMode == TLProfileUpdateModeAll) {
            subTitle = TwinmeLocalizedString(@"edit_profile_view_controller_propagating_all_contacts", nil);
        } else if (self.twinmeApplication.profileUpdateMode == TLProfileUpdateModeDefault) {
            subTitle = TwinmeLocalizedString(@"edit_profile_view_controller_propagating_except_contacts", nil);
        } else {
            subTitle = TwinmeLocalizedString(@"edit_profile_view_controller_propagating_no_contact", nil);
        }
        
        [valueAttributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:@"\n"]];
        [valueAttributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:subTitle attributes:[NSDictionary dictionaryWithObjectsAndKeys:Design.FONT_REGULAR32, NSFontAttributeName, Design.FONT_COLOR_GREY, NSForegroundColorAttributeName, nil]]];
        
        self.propagateLabel.attributedText = valueAttributedString;
    } else if (self.name && self.avatar) {
        self.avatarView.image = self.avatar;
        self.nameTextField.text = self.name;
        placeholder =  self.name;
        self.saveProfileView.alpha = self.updated ? 1.0 : 0.5;
        self.propagateView.hidden = YES;
        self.propagateViewHeightConstraint.constant = 0;
        self.propagateViewTopConstraint.constant = 0;
    } else {
        placeholder = TwinmeLocalizedString(@"application_name_hint", nil);
        self.saveProfileView.alpha = 0.5;
        self.propagateView.hidden = YES;
        self.propagateViewHeightConstraint.constant = 0;
        self.propagateViewTopConstraint.constant = 0;
    }
    
    self.nameTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:placeholder attributes:[NSDictionary dictionaryWithObject:Design.PLACEHOLDER_COLOR forKey:NSForegroundColorAttributeName]];
    
    if (self.nameTextField.text.length > MAX_NAME_LENGTH) {
        self.nameTextField.text = [self.nameTextField.text substringToIndex:MAX_NAME_LENGTH];
    }
    
    self.counterNameLabel.text = [NSString stringWithFormat:@"%lu/%d", (unsigned long)self.nameTextField.text.length, MAX_NAME_LENGTH];
    
    if (self.identityDescription && ![self.identityDescription isEqualToString:@""]) {
        self.descriptionTextView.text = self.identityDescription;
        self.descriptionTextView.textColor = Design.FONT_COLOR_DEFAULT;
        self.counterDescriptionLabel.text = [NSString stringWithFormat:@"%lu/%d", (unsigned long)self.descriptionTextView.text.length, MAX_DESCRIPTION_LENGTH];
    } else {
        self.descriptionTextView.text = TwinmeLocalizedString(@"side_menu_view_controller_about", nil);
        self.descriptionTextView.textColor = Design.PLACEHOLDER_COLOR;
        self.counterDescriptionLabel.text = [NSString stringWithFormat:@"0/%d", MAX_DESCRIPTION_LENGTH];
    }
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    self.nameTextField.font = Design.FONT_REGULAR28;
    self.descriptionTextView.font = Design.FONT_REGULAR28;
    self.saveProfileLabel.font = Design.FONT_BOLD36;
    self.counterNameLabel.font = Design.FONT_REGULAR26;
    self.counterDescriptionLabel.font = Design.FONT_REGULAR26;
    self.propagateLabel.font = Design.FONT_REGULAR32;
    self.messageLabel.font = Design.FONT_REGULAR32;
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    [super updateColor];
    
    self.nameView.backgroundColor = Design.TEXTFIELD_BACKGROUND_COLOR;
    self.saveProfileView.backgroundColor = Design.MAIN_COLOR;
    self.descriptionView.backgroundColor = Design.TEXTFIELD_BACKGROUND_COLOR;
    self.nameTextField.textColor = Design.FONT_COLOR_DEFAULT;
    self.nameTextField.tintColor = Design.FONT_COLOR_DEFAULT;
    self.counterDescriptionLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.counterNameLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.propagateLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.messageLabel.textColor = Design.FONT_COLOR_DEFAULT;
    
    if ([self.descriptionTextView.text isEqualToString:TwinmeLocalizedString(@"side_menu_view_controller_about", nil)]) {
        self.descriptionTextView.textColor = Design.PLACEHOLDER_COLOR;
    } else {
        self.descriptionTextView.textColor = Design.FONT_COLOR_DEFAULT;
    }
}

@end
