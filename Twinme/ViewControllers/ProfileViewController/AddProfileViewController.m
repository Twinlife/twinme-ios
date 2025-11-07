/*
 *  Copyright (c) 2020-2022 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <Twinme/TLProfile.h>
#import <Twinme/TLContact.h>
#import <Twinme/UIImage+Resize.h>

#import <Utils/NSString+Utils.h>

#import "AddProfileViewController.h"
#import "AddContactViewController.h"
#import "NewConversationViewController.h"
#import "AcceptInvitationViewController.h"
#import "OnboardingProfileViewController.h"

#import <TwinmeCommon/ApplicationDelegate.h>
#import <TwinmeCommon/CreateProfileService.h>
#import <TwinmeCommon/Design.h>
#import <TwinmeCommon/MainViewController.h>
#import <TwinmeCommon/TwinmeNavigationController.h>

#import "OnboardingConfirmView.h"
#import "MenuPhotoView.h"
#import "DefaultConfirmView.h"

#import "DeviceAuthorization.h"

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

#define MAX_NAME_LENGTH 32

static UIColor *DESIGN_AVATAR_PLACEHOLDER_COLOR;

//
// Interface: AddProfileViewController ()
//

@interface AddProfileViewController () <CreateProfileServiceDelegate, UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextViewDelegate, UIAdaptivePresentationControllerDelegate, MenuPhotoViewDelegate, ConfirmViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *avatarPlaceholderImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *avatarPlaceholderImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *avatarViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *avatarViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *avatarView;
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
@property (nonatomic) CGFloat yOffset;
@property (nonatomic) BOOL updated;
@property (nonatomic) BOOL creatingInProgress;
@property (nonatomic) BOOL showOnboardingView;
@property (nonatomic) UIImage *updatedProfileAvatar;
@property (nonatomic) UIImage *updatedProfileLargeAvatar;

@property (nonatomic) TLProfile *profile;

@property (nonatomic) CreateProfileService *createProfileService;

@end

//
// Implementation: AddProfileViewController
//

#undef LOG_TAG
#define LOG_TAG @"AddProfileViewController"

@implementation AddProfileViewController

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
        _creatingInProgress = NO;
        _keyboardHidden = YES;
        _firstProfile = NO;
        _fromContactsTab = NO;
        _fromConversationsTab = NO;
        _showOnboardingView = NO;
        _fromCreateSpace = NO;
        _createProfileService = [[CreateProfileService alloc] initWithTwinmeContext:self.twinmeContext delegate:self];
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
    
    if (!self.showOnboardingView) {
        self.showOnboardingView = YES;
        
        [self showOnboarding:NO];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    DDLogVerbose(@"%@ viewWillDisappear: %@", LOG_TAG, animated ? @"YES" : @"NO");
    
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    DDLogVerbose(@"%@ viewDidAppear: %@", LOG_TAG, animated ? @"YES" : @"NO");
    
    [super viewDidAppear:animated];
}

- (void)backTap {
    DDLogVerbose(@"%@ backTap", LOG_TAG);
    
    if (![self.lastLevelName isEqual:@""]) {
        [self.createProfileService setLevel:self.lastLevelName];
    } else {
        [self.createProfileService setCurrentSpace];
    }
    
    [self finish];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    DDLogVerbose(@"%@ textFieldShouldReturn: %@", LOG_TAG, textField);
    
    [textField resignFirstResponder];
    
    if (!self.updatedProfileAvatar && ![textField.text isEqualToString:@""]) {
        [self openMenuPhoto];
    }
    
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

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)pickerController didFinishPickingMediaWithInfo:(NSDictionary *)info {
    DDLogVerbose(@"%@ imagePickerController: %@ didFinishPickingMediaWithInfo: %@", LOG_TAG, pickerController, info);
        
    [pickerController dismissViewControllerAnimated:YES completion:^{
        self.updatedProfileLargeAvatar = info[UIImagePickerControllerEditedImage];
        self.updatedProfileAvatar = [self.updatedProfileLargeAvatar resizeImage];
        self.avatarView.image = self.updatedProfileLargeAvatar;
        self.avatarPlaceholderImageView.hidden = YES;
        
        [self setUpdated];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)pickerController {
    DDLogVerbose(@"%@ imagePickerControllerDidCancel: %@", LOG_TAG, pickerController);
        
    [pickerController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - CreateProfileServiceDelegate

- (void)onCreateSpace:(TLSpace *)space {
    DDLogVerbose(@"%@ onCreateSpace: %@", LOG_TAG, space);
    
    self.creatingInProgress = NO;
    
    [self finish];
}

- (void)onCreateProfile:(TLProfile *)profile {
    DDLogVerbose(@"%@ onCreateProfile: %@", LOG_TAG, profile);
    
    self.creatingInProgress = NO;
    
    self.profile = profile;
    
    [self finish];
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

#pragma mark - ConfirmViewDelegate

- (void)didTapConfirm:(nonnull AbstractConfirmView *)abstractConfirmView {
    DDLogVerbose(@"%@ didTapConfirm: %@", LOG_TAG, abstractConfirmView);

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
    
    if ([abstractConfirmView isKindOfClass:[DefaultConfirmView class]]) {
        [self.nameTextField becomeFirstResponder];
    }
    
    [abstractConfirmView removeFromSuperview];
}

#pragma mark - Private methods

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
        
    self.view.backgroundColor = Design.WHITE_COLOR;
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)]];
    
    [self setNavigationTitle:TwinmeLocalizedString(@"application_profile", nil)];
        
    self.avatarViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.avatarViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.avatarView.isAccessibilityElement = YES;
    self.avatarView.backgroundColor = DESIGN_AVATAR_PLACEHOLDER_COLOR;

    self.avatarView.userInteractionEnabled = YES;
    self.avatarView.clipsToBounds = YES;
    self.avatarView.layer.cornerRadius = self.avatarViewHeightConstraint.constant * 0.5;
    
    [self.avatarView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleUpdateAvatarTapGesture)]];
    self.avatarView.isAccessibilityElement = YES;
    
    self.avatarPlaceholderImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
        
    UIBarButtonItem *infoBarButtonItem =  [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"OnboardingInfoIcon"] style:UIBarButtonItemStylePlain target:self action:@selector(handleInfoTapGesture:)];
    infoBarButtonItem.tintColor = [UIColor whiteColor];
    infoBarButtonItem.accessibilityLabel = TwinmeLocalizedString(@"conversation_view_controller_menu_item_view_info_title", nil);
    self.navigationItem.rightBarButtonItem = infoBarButtonItem;
        
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
    self.nameTextField.placeholder = TwinmeLocalizedString(@"application_name_hint", nil);
    [self.nameTextField setReturnKeyType:UIReturnKeyDone];
    self.nameTextField.delegate = self;
    [self.nameTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    self.counterNameLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.counterNameLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    
    self.counterNameLabel.font = Design.FONT_REGULAR26;
    self.counterNameLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.counterNameLabel.text = [NSString stringWithFormat:@"0/%d", MAX_NAME_LENGTH];
        
    self.saveProfileViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.saveProfileViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.saveProfileViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    
    self.saveProfileView.backgroundColor = Design.MAIN_COLOR;
    self.saveProfileView.userInteractionEnabled = YES;
    self.saveProfileView.isAccessibilityElement = YES;
    self.saveProfileView.alpha = 0.5;
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
    
    self.messageLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.messageLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    
    self.messageLabel.font = Design.FONT_REGULAR32;
    self.messageLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.messageLabel.text = TwinmeLocalizedString(@"create_profile_view_controller_save_message", nil);
}

- (void)finish {
    DDLogVerbose(@"%@ finish", LOG_TAG);
    
    if (self.createProfileService) {
        [self.createProfileService dispose];
        self.createProfileService = nil;
    } else {
        return;
    }
    
    if (self.firstProfile && self.profile) {
        [CATransaction begin];
        [CATransaction setCompletionBlock:^{
            ApplicationDelegate *delegate = (ApplicationDelegate *)[[UIApplication sharedApplication] delegate];
            MainViewController *mainViewController = delegate.mainViewController;
            TwinmeNavigationController *selectedNavigationController = mainViewController.selectedViewController;
            if (self.invitationURL) {
                AcceptInvitationViewController *acceptInvitationViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AcceptInvitationViewController"];
                [acceptInvitationViewController initWithProfile:self.profile url:self.invitationURL descriptorId:nil originatorId:nil isGroup:NO notification:nil popToRootViewController:NO];
                [acceptInvitationViewController showInView:mainViewController.view];
            } else if (self.fromContactsTab || self.fromConversationsTab) {
                AddContactViewController *addContactViewController = (AddContactViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"AddContactViewController"];
                [addContactViewController initWithProfile:self.profile invitationMode:InvitationModeScan];
                [selectedNavigationController pushViewController:addContactViewController animated:YES];
            }
        }];
        
        [self.navigationController popViewControllerAnimated:YES];

        [CATransaction commit];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)setUpdated {
    DDLogVerbose(@"%@ setUpdated", LOG_TAG);
    
    if ([self.nameTextField.text length] > 0 && self.updatedProfileAvatar) {
        self.updated = YES;
        self.saveProfileView.alpha = 1.0;
    } else {
        self.updated = NO;
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
    
    if ([self.twinmeApplication getDefaultKeyboardHeight] != keyboardSize.height) {
        [self.twinmeApplication setDefaultKeyboardHeight:keyboardSize.height];
    }
    
    [self updateAvatarHeight];
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
    
    [self updateAvatarHeight];
}

- (void)dismissKeyboard {
    DDLogVerbose(@"%@ dismissKeyboard", LOG_TAG);
    
    if (!self.keyboardHidden) {
        [self.nameTextField resignFirstResponder];
    }
}

- (void)updateAvatarHeight {
    DDLogVerbose(@"%@ updateAvatarHeight", LOG_TAG);
    
    CGRect messageRect = [self.messageLabel.text boundingRectWithSize:CGSizeMake(self.messageLabelWidthConstraint.constant, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{
        NSFontAttributeName : Design.FONT_REGULAR32
    } context:nil];
    
    CGRect counterNameRect = [self.counterNameLabel.text boundingRectWithSize:CGSizeMake(self.counterNameLabelWidthConstraint.constant, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{
        NSFontAttributeName : Design.FONT_REGULAR26
    } context:nil];
    
    CGFloat avatarHeight = self.containerView.frame.size.height - [self.twinmeApplication getDefaultKeyboardHeight] - self.avatarViewTopConstraint.constant - self.nameViewTopConstraint.constant - self.nameViewHeightConstraint.constant - self.counterNameLabelTopConstraint.constant - counterNameRect.size.height - self.saveProfileViewTopConstraint.constant - self.saveProfileViewHeightConstraint.constant - (self.messageLabelTopConstraint.constant * 2) - messageRect.size.height;
    
    self.avatarViewHeightConstraint.constant = avatarHeight;
    self.avatarView.layer.cornerRadius = self.avatarViewHeightConstraint.constant * 0.5;
}

- (void)handleTapGesture {
    DDLogVerbose(@"%@ handleTapGesture", LOG_TAG);
    
    if ([self.nameTextField isFirstResponder]) {
        [self.nameTextField resignFirstResponder];
    }
}

- (void)handleUpdateAvatarTapGesture {
    DDLogVerbose(@"%@ handleUpdateAvatarTapGesture", LOG_TAG);
    
    [self openMenuPhoto];
}

- (void)handleSaveTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleSaveTapGesture: %@", LOG_TAG, sender);
    
    if (self.creatingInProgress) {
        return;
    }
    
    if ([self.nameTextField.text length] == 0) {
        [self showOnboarding:YES];
        return;
    } else if (!self.updatedProfileAvatar) {
        [self openMenuPhoto];
        return;
    }
    
    self.creatingInProgress = YES;
    
    ApplicationDelegate *delegate = (ApplicationDelegate *)[[UIApplication sharedApplication] delegate];
    MainViewController *mainViewController = delegate.mainViewController;
    NSString *nameSpace;
    if ([mainViewController numberSpaces:YES] == 0) {
        nameSpace = TwinmeLocalizedString(@"space_appearance_view_controller_general_title", nil);
    } else {
        nameSpace = [NSString stringWithFormat:@"%@ %lu", TwinmeLocalizedString(@"settings_space_view_controller_space_category_title", nil), [mainViewController numberSpaces:YES] + 1];
    }
    [self.createProfileService createProfile:self.nameTextField.text profileDescription:nil avatar:self.updatedProfileAvatar largeAvatar:self.updatedProfileLargeAvatar nameSpace:nameSpace createSpace:self.fromCreateSpace];
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
    
    [self dismissKeyboard];
    
    MenuPhotoView *menuPhotoView = [[MenuPhotoView alloc]init];
    menuPhotoView.menuPhotoViewDelegate = self;
    [self.tabBarController.view addSubview:menuPhotoView];
    [menuPhotoView openMenu:NO];
}

- (void)handleInfoTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleInfoTapGesture ", LOG_TAG);
        
    [self dismissKeyboard];
    
    OnboardingConfirmView *onboardingConfirmView = [[OnboardingConfirmView alloc] init];
    onboardingConfirmView.confirmViewDelegate = self;

    NSString *message;
    
    NSString *title =  TwinmeLocalizedString(@"application_profile", nil);
    
    NSMutableString *mutableString = [[NSMutableString alloc] initWithString:TwinmeLocalizedString(@"create_profile_view_controller_onboarding_message_part_1", nil)];
    [mutableString appendString:@"\n\n"];
    [mutableString appendString:TwinmeLocalizedString(@"create_profile_view_controller_onboarding_message_part_2", nil)];
    [mutableString appendString:@"\n\n"];
    [mutableString appendString:TwinmeLocalizedString(@"create_profile_view_controller_onboarding_message_part_3", nil)];
    [mutableString appendString:@"\n\n"];
    [mutableString appendString:TwinmeLocalizedString(@"create_profile_view_controller_onboarding_message_part_4", nil)];
    
    message = mutableString;
    
    UIImage *image = [self.twinmeApplication darkModeEnable:self.currentSpaceSettings] ? [UIImage imageNamed:@"OnboardingAddProfileDark"] : [UIImage imageNamed:@"OnboardingAddProfile"];
    
    [onboardingConfirmView initWithTitle:title message:message image:image action:TwinmeLocalizedString(@"application_ok", nil) actionColor:nil cancel:nil];
    
    NSMutableAttributedString *attributedTitle = [[NSMutableAttributedString alloc] initWithString:TwinmeLocalizedString(@"application_profile", nil) attributes:[NSDictionary dictionaryWithObjectsAndKeys:Design.FONT_BOLD36, NSFontAttributeName, Design.FONT_COLOR_DEFAULT, NSForegroundColorAttributeName, nil]];
    [onboardingConfirmView updateTitle:attributedTitle];
    
    [onboardingConfirmView hideCancelAction];
    [self.navigationController.view addSubview:onboardingConfirmView];
    [onboardingConfirmView showConfirmView];
}

- (void)showOnboarding:(BOOL)incompleteProfile {
    DDLogVerbose(@"%@ showOnboarding", LOG_TAG);
    
    DefaultConfirmView *defaultConfirmView = [[DefaultConfirmView alloc] init];
    defaultConfirmView.confirmViewDelegate = self;

    UIImage *image = [self.twinmeApplication darkModeEnable:[self currentSpaceSettings]] ? [UIImage imageNamed:@"OnboardingAddProfileDark"] : [UIImage imageNamed:@"OnboardingAddProfile"];
    
    NSString *confirmTitle = incompleteProfile ? TwinmeLocalizedString(@"application_ok", nil) : TwinmeLocalizedString(@"show_profile_view_controller_create_profile", nil);

    [defaultConfirmView initWithTitle:nil message:TwinmeLocalizedString(@"create_profile_view_controller_incomplete_profile_message", nil) image:image avatar:nil action:confirmTitle actionColor:nil cancel:nil];
    [defaultConfirmView hideCancelAction];
    [self.tabBarController.view addSubview:defaultConfirmView];
    [defaultConfirmView showConfirmView];
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    self.nameTextField.font = Design.FONT_REGULAR28;
    self.saveProfileLabel.font = Design.FONT_BOLD36;
    self.counterNameLabel.font = Design.FONT_REGULAR26;
    self.messageLabel.font = Design.FONT_REGULAR32;
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    [super updateColor];
    
    self.nameView.backgroundColor = Design.TEXTFIELD_BACKGROUND_COLOR;
    self.saveProfileView.backgroundColor = Design.MAIN_COLOR;
    self.nameTextField.textColor = Design.FONT_COLOR_DEFAULT;
    self.nameTextField.tintColor = Design.FONT_COLOR_DEFAULT;
    self.messageLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.nameTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:TwinmeLocalizedString(@"application_name_hint", nil) attributes:[NSDictionary dictionaryWithObject:Design.PLACEHOLDER_COLOR forKey:NSForegroundColorAttributeName]];
    self.counterNameLabel.textColor = Design.FONT_COLOR_DEFAULT;
}

@end
