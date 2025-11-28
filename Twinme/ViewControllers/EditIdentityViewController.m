/*
 *  Copyright (c) 2016-2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Marouane Qasmi (Marouane.Qasmi@twinlife-systems.com)
 *   Chedi Baccari (Chedi.Baccari@twinlife-systems.com)
 *   Christian Jacquemot (Christian.Jacquemot@twinlife-systems.com)
 *   Thibaud David (contact@thibauddavid.com)
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 *   Stephane Carrez (Stephane.Carrez@twin.life)
 */

#import <CocoaLumberjack.h>

#import <Twinlife/TLImageService.h>

#import <Twinme/TLProfile.h>
#import <Twinme/TLCallReceiver.h>
#import <Twinme/TLContact.h>
#import <Twinme/TLGroup.h>
#import <Twinme/TLSpace.h>
#import <Twinme/UIImage+Resize.h>

#import <Utils/NSString+Utils.h>

#import "EditIdentityViewController.h"
#import "NotificationViewController.h"

#import <TwinmeCommon/Design.h>
#import <TwinmeCommon/EditIdentityService.h>

#import "AlertMessageView.h"
#import "MenuPhotoView.h"
#import "DeviceAuthorization.h"
#import "MenuPhotoView.h"
#import "ApplicationAssertion.h"

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

//
// Interface: EditIdentityViewController ()
//

@interface EditIdentityViewController () <EditIdentityServiceDelegate, UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextViewDelegate, UIAdaptivePresentationControllerDelegate, MenuPhotoViewDelegate>

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
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *saveProfileViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *saveProfileViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *saveProfileViewWidthConstraint;
@property (weak, nonatomic) IBOutlet UIView *saveProfileView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *saveProfileLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet UILabel *saveProfileLabel;

@property (nonatomic) BOOL keyboardHidden;
@property (nonatomic) BOOL updated;
@property (nonatomic) UIImage *updatedIdentityAvatar;
@property (nonatomic) UIImage *updatedIdentityLargeAvatar;
@property (nonatomic) UIImage *avatar;
@property (nonatomic) NSString *identityDescription;

@property (nonatomic) EditIdentityService *editIdentityService;
@property (nonatomic) TLProfile *profile;
@property (nonatomic) TLGroup *group;
@property (nonatomic) TLContact *contact;
@property (nonatomic) TLCallReceiver *callReceiver;

@end

//
// Implementation: EditIdentityViewController
//

#undef LOG_TAG
#define LOG_TAG @"EditIdentityViewController"

@implementation EditIdentityViewController

#pragma mark - UIViewController

- (instancetype)initWithCoder:(NSCoder *)coder {
    DDLogVerbose(@"%@ initWithCoder: %@", LOG_TAG, coder);
    
    self = [super initWithCoder:coder];
    
    if (self) {
        _updated = NO;
        _keyboardHidden = YES;
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

#pragma mark - Public methods

- (void)initWithContact:(TLContact *)contact {
    DDLogVerbose(@"%@ initWithContact: %@", LOG_TAG, contact);
    
    self.contact = contact;
    
    [self updateProfile];
    [self.editIdentityService refreshWithContact:contact];
}

- (void)initWithGroup:(TLGroup *)group {
    DDLogVerbose(@"%@ initWithGroup: %@", LOG_TAG, group);
    
    self.group = group;
    
    [self updateProfile];
    [self.editIdentityService refreshWithGroup:group];
}

- (void)initWithCallReceiver:(TLCallReceiver *)callReceiver {
    DDLogVerbose(@"%@ initWithCallReceiver: %@", LOG_TAG, callReceiver);
    
    self.callReceiver = callReceiver;
    
    [self updateProfile];
    [self.editIdentityService refreshWithCallReceiver:callReceiver];
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
    
    if (![textField.text isEqualToString:self.profile.name]) {
        [self setUpdated];
    } else if (!self.updatedIdentityAvatar) {
        self.updated = NO;
        self.saveProfileView.alpha = 0.5;
    }
    
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
    
    if (![textView.text isEqualToString:self.profile.objectDescription]) {
        [self setUpdated];
    } else if (!self.updatedIdentityAvatar && [self.nameTextField.text isEqualToString:self.profile.name]) {
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

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)pickerController didFinishPickingMediaWithInfo:(NSDictionary *)info {
    DDLogVerbose(@"%@ imagePickerController: %@ didFinishPickingMediaWithInfo: %@", LOG_TAG, pickerController, info);
    
    self.navigationController.navigationBarHidden = YES;
    
    [pickerController dismissViewControllerAnimated:YES completion:^{
        [self setUpdated];
        
        self.updatedIdentityLargeAvatar = info[UIImagePickerControllerEditedImage];
        self.updatedIdentityAvatar = [self.updatedIdentityLargeAvatar resizeImage];
        self.avatarView.image = self.updatedIdentityLargeAvatar;
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)pickerController {
    DDLogVerbose(@"%@ imagePickerControllerDidCancel: %@", LOG_TAG, pickerController);
    
    self.navigationController.navigationBarHidden = YES;
    [pickerController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - EditIdentityServiceDelegate

- (void)onSetCurrentSpace:(nonnull TLSpace *)space {
    DDLogVerbose(@"%@ onSetCurrentSpace: %@", LOG_TAG, space);
    
    if (space.profile) {
        self.profile = space.profile;
        [self setLeftBarButtonItem:self.editIdentityService profile:space.profile];
        [self updateProfile];
    }
}

- (void)onUpdateProfile:(TLProfile *)profile {
    DDLogVerbose(@"%@ onUpdateProfile: %@", LOG_TAG, profile);
    
    self.profile = profile;
    
    self.updated = NO;
    
    [self finish];
}

- (void)onUpdateContact:(nonnull TLContact *)contact avatar:(nullable UIImage *)avatar {
    DDLogVerbose(@"%@ onUpdateContact: %@", LOG_TAG, contact);
    
    self.contact = contact;
    
    self.updated = NO;
    
    [self finish];
}

- (void)onUpdateGroup:(nonnull TLGroup *)group avatar:(nullable UIImage *)avatar {
    DDLogVerbose(@"%@ onUpdateGroup: %@", LOG_TAG, group);
    
    self.group = group;
    
    self.updated = NO;
    
    [self finish];
}

- (void)onUpdateCallReceiver:(TLCallReceiver *)callReceiver {
    DDLogVerbose(@"%@ onUpdateCallReceiver: %@", LOG_TAG, callReceiver);
    
    self.callReceiver = callReceiver;
    
    self.updated = NO;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self finish];
    });
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

- (void)onCreateProfile:(nonnull TLProfile *)profile {
    DDLogVerbose(@"%@ onCreateProfile: %@", LOG_TAG, profile);

}

#pragma mark - UIAdaptivePresentationControllerDelegate

- (void)presentationControllerWillDismiss:(UIPresentationController *)presentationController {
    DDLogVerbose(@"%@ presentationControllerWillDismiss: %@", LOG_TAG, presentationController);
    
    self.navigationController.navigationBarHidden = YES;
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
    DDLogVerbose(@"%@ cancelMenu", LOG_TAG);
    
    [menuPhotoView removeFromSuperview];
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
    
    [super initViews];
    
    self.view.backgroundColor = Design.WHITE_COLOR;
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)]];
    
    [self setNavigationTitle:TwinmeLocalizedString(@"application_edit", nil)];
    
    [self.editAvatarView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleUpdateAvatarTapGesture)]];
    self.editAvatarView.isAccessibilityElement = YES;
    
    self.avatarPlaceholderImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
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
        
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture)];
    [self.view addGestureRecognizer:tapGesture];
        
    [self updateProfile];
}

- (void)finish {
    DDLogVerbose(@"%@ finish", LOG_TAG);
    
    if (self.editIdentityService) {
        [self.editIdentityService dispose];
        self.editIdentityService = nil;
    }
    
    self.navigationController.navigationBarHidden = NO;
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
    
    if (self.updated) {
        return;
    }
    self.updated = YES;
    
    self.saveProfileView.alpha = 1.0;
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

- (void)handleUpdateAvatarTapGesture {
    DDLogVerbose(@"%@ handleUpdateAvatarTapGesture", LOG_TAG);
    
    [self openMenuPhoto];
}

- (void)handleSaveTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleSaveTapGesture: %@", LOG_TAG, sender);
    
    if (!self.updated) {
        return;
    }
    
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
            // If no new image is selected, give the previous image.
            avatar = self.avatar;
        }
        if (self.profile) {
            [self.editIdentityService updateIdentityWithProfile:self.profile identityName:updatedIdentityName identityDescription:updatedIdentityDescription identityAvatar:avatar identityLargeAvatar:self.updatedIdentityLargeAvatar profileUpdateMode:self.twinmeApplication.profileUpdateMode];
        } else if (self.contact) {
            [self.editIdentityService updateIdentityWithContact:self.contact identityName:updatedIdentityName identityDescription:updatedIdentityDescription identityAvatar:avatar identityLargeAvatar:self.updatedIdentityLargeAvatar];
        } else if (self.group) {
            [self.editIdentityService updateIdentityWithGroup:self.group identityName:updatedIdentityName identityAvatar:avatar identityLargeAvatar:self.updatedIdentityLargeAvatar];
        } else if (self.callReceiver) {
            [self.editIdentityService updateIdentityWithCallReceiver:self.callReceiver identityName:updatedIdentityName identityDescription:updatedIdentityDescription identityAvatar:avatar identityLargeAvatar:self.updatedIdentityLargeAvatar];
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

- (void)openMenuPhoto {
    DDLogVerbose(@"%@ openMenuPhoto", LOG_TAG);
    
    [self handleTapGesture];
    
    MenuPhotoView *menuPhotoView = [[MenuPhotoView alloc]init];
    menuPhotoView.menuPhotoViewDelegate = self;
    [self.tabBarController.view addSubview:menuPhotoView];
    [menuPhotoView openMenu:NO];
}

- (void)updateProfile {
    DDLogVerbose(@"%@ updateProfile", LOG_TAG);
    
    TLImageId *avatarId;
    NSString *placeholder = @"";
    self.identityDescription = @"";
    if (self.profile) {
        [self.editIdentityService getImageWithProfile:self.profile withBlock:^(UIImage *image) {
            self.avatar = image;
        }];
        avatarId = self.profile.avatarId;
        self.nameTextField.text = self.profile.name;
        self.nameLabel.text = self.profile.name;
        self.identityDescription = self.profile.objectDescription;

        TL_ASSERT_NOT_NULL(self.twinmeContext, self.profile.name, [ApplicationAssertPoint INVALID_NAME], [TLAssertValue initWithSubject:self.profile], nil);

        if (self.profile.name) {
            placeholder = self.profile.name;
        }
        self.saveProfileView.alpha = self.updated ? 1.0 : 0.5;
    } else if (self.contact) {
        [self.editIdentityService getImageWithContact:self.contact withBlock:^(UIImage *image) {
            self.avatar = image;
        }];
        avatarId = self.contact.identityAvatarId;
        self.avatarView.image = self.avatar;
        self.nameTextField.text = self.contact.name;
        self.nameLabel.text = self.contact.name;
        self.identityDescription = self.contact.identityDescription;

        TL_ASSERT_NOT_NULL(self.twinmeContext, self.contact.name, [ApplicationAssertPoint INVALID_NAME], [TLAssertValue initWithSubject:self.contact], nil);

        if (self.contact.name) {
            placeholder = self.contact.name;
        }
        if ([self.contact hasPrivateIdentity]) {
            [self.editIdentityService getIdentityImageWithContact:self.contact withBlock:^(UIImage *image) {
                self.avatar = image;
            }];
            self.avatarView.image = self.avatar;
            self.nameTextField.text = self.contact.identityName;
            self.nameLabel.text = self.contact.identityName;

            TL_ASSERT_NOT_NULL(self.twinmeContext, self.contact.identityName, [ApplicationAssertPoint INVALID_NAME], [TLAssertValue initWithSubject:self.contact], nil);

            if (self.contact.identityName) {
                placeholder = self.contact.identityName;
            }
        }
        self.saveProfileView.alpha = self.updated ? 1.0 : 0.5;
    } else if (self.group) {
        [self.editIdentityService getIdentityImageWithGroup:self.group withBlock:^(UIImage *image) {
            self.avatar = image;
        }];
        avatarId = self.group.identityAvatarId;
        self.avatarView.image = self.avatar;
        self.nameTextField.text = self.group.identityName;
        self.nameLabel.text = self.group.identityName;

        TL_ASSERT_NOT_NULL(self.twinmeContext, self.group.identityName, [ApplicationAssertPoint INVALID_NAME], [TLAssertValue initWithSubject:self.group], nil);

        if (self.group.identityName) {
            placeholder = self.group.identityName;
        }
        self.saveProfileView.alpha = self.updated ? 1.0 : 0.5;
        self.descriptionViewHeightConstraint.constant = 0;
        self.descriptionViewTopConstraint.constant = 0;
        self.descriptionView.hidden = YES;
        self.counterDescriptionLabel.hidden = YES;
    } else if (self.callReceiver) {
        [self.editIdentityService getIdentityImageWithCallReceiver:self.callReceiver withBlock:^(UIImage *image) {
            self.avatar = image;
        }];
        avatarId = self.callReceiver.identityAvatarId;
        self.avatarView.image = self.avatar;
        self.nameTextField.text = self.callReceiver.identityName;
        self.nameLabel.text = self.callReceiver.identityName;
        self.identityDescription = self.callReceiver.identityDescription;

        TL_ASSERT_NOT_NULL(self.twinmeContext, self.callReceiver.identityName, [ApplicationAssertPoint INVALID_NAME], [TLAssertValue initWithSubject:self.callReceiver], nil);
        if (self.callReceiver.identityName) {
            placeholder = self.callReceiver.identityName;
        }
        self.saveProfileView.alpha = self.updated ? 1.0 : 0.5;
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
    
    if (avatarId && !self.updatedIdentityAvatar) {
        self.avatarView.image = self.avatar;
    } else if (self.updatedIdentityLargeAvatar) {
        self.avatarView.image = self.updatedIdentityLargeAvatar;
    }
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    self.nameTextField.font = Design.FONT_REGULAR28;
    self.descriptionTextView.font = Design.FONT_REGULAR28;
    self.saveProfileLabel.font = Design.FONT_BOLD36;
    self.counterNameLabel.font = Design.FONT_REGULAR26;
    self.counterDescriptionLabel.font = Design.FONT_REGULAR26;
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
    
    if ([self.descriptionTextView.text isEqualToString:TwinmeLocalizedString(@"side_menu_view_controller_about", nil)]) {
        self.descriptionTextView.textColor = Design.PLACEHOLDER_COLOR;
    } else {
        self.descriptionTextView.textColor = Design.FONT_COLOR_DEFAULT;
    }
    
    if ([self.twinmeApplication darkModeEnable:[self currentSpaceSettings]]) {
        self.nameTextField.keyboardAppearance = UIKeyboardAppearanceDark;
        self.descriptionTextView.keyboardAppearance = UIKeyboardAppearanceDark;
    } else {
        self.nameTextField.keyboardAppearance = UIKeyboardAppearanceLight;
        self.descriptionTextView.keyboardAppearance = UIKeyboardAppearanceLight;
    }
}

@end
