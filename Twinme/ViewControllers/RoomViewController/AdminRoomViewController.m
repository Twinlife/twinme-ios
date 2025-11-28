/*
 *  Copyright (c) 2020-2024 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <Twinme/TLContact.h>
#import <Twinme/TLProfile.h>
#import <Twinme/UIImage+Resize.h>
#import <Twinme/TLRoomConfig.h>

#import <Utils/NSString+Utils.h>

#import "AdminRoomViewController.h"
#import "AddParticipantsViewController.h"
#import "InvitationRoomViewController.h"
#import "SettingsRoomViewController.h"

#import <TwinmeCommon/EditRoomService.h>

#import <TwinmeCommon/Design.h>
#import "InsideBorderView.h"
#import "DeviceAuthorization.h"
#import "DeleteConfirmView.h"
#import "MenuPhotoView.h"

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static CGFloat DESIGN_MIN_BOTTOM_APPEARANCE = 40;
static CGFloat DESIGN_SECTION_HEIGHT = 120;
static CGFloat SECTION_HEIGHT;
static CGFloat MIN_BOTTOM_APPEARANCE;

static UIColor *DESIGN_AVATAR_PLACEHOLDER_COLOR;

//
// Interface: AdminRoomViewController ()
//

@interface AdminRoomViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UITextViewDelegate,  EditRoomServiceDelegate, MenuPhotoViewDelegate, ConfirmViewDelegate>

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
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *configurationTitleTopConstraint;
@property (weak, nonatomic) IBOutlet UILabel *configurationTitleLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *settingsViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *settingsViewTopConstraint;
@property (weak, nonatomic) IBOutlet InsideBorderView *settingsView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *settingsLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *settingsLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *settingsLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *settingsImageViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *settingsImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *settingsImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *settingsAccessoryImageHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *settingsAccessoryImageTrailingConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *settingsAccessoryImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *inviteViewHeightConstraint;
@property (weak, nonatomic) IBOutlet InsideBorderView *inviteView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *inviteImageViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *inviteImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *inviteImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *inviteLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *inviteLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *inviteLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *inviteAccessoryImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *inviteAccessoryImageViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *inviteAccessoryImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *invitationCodeViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *invitationCodeViewHeightConstraint;
@property (weak, nonatomic) IBOutlet InsideBorderView *invitationCodeView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *invitationCodeImageViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *invitationCodeImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *invitationCodeImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *invitationCodeLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *invitationCodeLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *invitationCodeLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *invitationCodeAccessoryImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *invitationCodeAccessoryImageViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *invitationCodeAccessoryImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *saveViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *saveViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *saveViewWidthConstraint;
@property (weak, nonatomic) IBOutlet UIView *saveView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *saveLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet UILabel *saveLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *removeViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *removeView;
@property (weak, nonatomic) IBOutlet UILabel *removeLabel;

@property (nonatomic) UIView *overlayView;
@property (nonatomic) MenuPhotoView *menuPhotoView;

@property (nonatomic) CALayer *avatarContainerViewLayer;
@property (nonatomic) UIImage *updatedAvatar;
@property (nonatomic) UIImage *updatedLargeAvatar;
@property (nonatomic) NSString *nameContact;
@property (nonatomic) NSString *welcomeMessage;
@property (nonatomic) BOOL canSave;
@property (nonatomic) BOOL updated;
@property (nonatomic) BOOL keyboardHidden;

@property (nonatomic) TLContact *room;
@property (nonatomic) TLRoomConfig *roomConfig;

@property (nonatomic) EditRoomService *editRoomService;

@end

//
// Implementation: AdminRoomViewController
//

#undef LOG_TAG
#define LOG_TAG @"AdminRoomViewController"

@implementation AdminRoomViewController

+ (void)initialize {
    DDLogVerbose(@"%@ initialize", LOG_TAG);
    
    SECTION_HEIGHT = DESIGN_SECTION_HEIGHT * Design.HEIGHT_RATIO;
    MIN_BOTTOM_APPEARANCE = DESIGN_MIN_BOTTOM_APPEARANCE * Design.HEIGHT_RATIO;
    DESIGN_AVATAR_PLACEHOLDER_COLOR = [UIColor colorWithRed:242./255. green:243./255. blue:245./255. alpha:1.0];
}

#pragma mark - UIViewController

- (instancetype)initWithCoder:(NSCoder *)coder {
    DDLogVerbose(@"%@ initWithCoder: %@", LOG_TAG, coder);
    
    self = [super initWithCoder:coder];
    
    if (self) {
        _canSave = NO;
        _updated = NO;
        _keyboardHidden = YES;
        
        _editRoomService = [[EditRoomService alloc] initWithTwinmeContext:self.twinmeContext delegate:self];
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
    CGRect settingsFrame = self.settingsView.frame;
    CGRect frame = self.view.frame;
    CGFloat slidePosition = frame.size.height - (keyboardSize.height + settingsFrame.origin.y + settingsFrame.size.height);
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

- (void)initWithRoom:(TLContact *)room {
    DDLogVerbose(@"%@ initWithRoom: %@", LOG_TAG, room);
    
    self.room = room;
    
    [self.editRoomService getRoomConfig:room];
}

#pragma mark - EditRoomServiceDelegate

- (void)onGetRoomConfig:(nonnull TLRoomConfig *)roomConfig {
    DDLogVerbose(@"%@ onGetRoomConfig: %@", LOG_TAG, roomConfig);
    
    if (roomConfig.welcome && ![roomConfig.welcome isEqual:@""]) {
        self.roomConfig = roomConfig;
        self.descriptionTextView.text = roomConfig.welcome;
        self.descriptionTextView.textColor = Design.FONT_COLOR_DEFAULT;
    }
}

- (void)onGetRoomConfigNotFound {
    DDLogVerbose(@"%@ onGetRoomConfigNotFound", LOG_TAG);
    
    self.descriptionTextView.text = TwinmeLocalizedString(@"admin_room_view_controller_welcome_message", nil);
}

- (void)onUpdateRoom:(nonnull TLContact *)room {
    DDLogVerbose(@"%@ onUpdateRoom: %@", LOG_TAG, room);
    
    if ([room.uuid isEqual:self.room.uuid]) {
        [self finish];
    }
}

- (void)onDeleteRoom:(nonnull NSUUID *)roomId {
    DDLogVerbose(@"%@ onDeleteRoom: %@", LOG_TAG, roomId);
    
    if ([roomId isEqual:self.room.uuid]) {
        [self finish];
    }
}

#pragma mark - UITextFieldDelegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    DDLogVerbose(@"%@ textFieldShouldReturn: %@", LOG_TAG, textField);
    
    [textField resignFirstResponder];
    return NO;
}

- (void)textFieldDidChange:(UITextField *)textField {
    DDLogVerbose(@"%@ textFieldDidChange: %@", LOG_TAG, textField);
    
    [self setUpdated];
}

#pragma mark - UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView {
    DDLogVerbose(@"%@ textViewDidBeginEditing: %@", LOG_TAG, textView);
    
    if (textView == self.descriptionTextView && [self.descriptionTextView.text isEqualToString:TwinmeLocalizedString(@"admin_room_view_controller_welcome_message", nil)]) {
        self.descriptionTextView.text = @"";
        self.descriptionTextView.textColor = Design.FONT_COLOR_DEFAULT;
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
    
    if (textView == self.descriptionTextView && [self.descriptionTextView.text isEqualToString:@""]) {
        self.descriptionTextView.text = TwinmeLocalizedString(@"admin_room_view_controller_welcome_message", nil);
        self.descriptionTextView.textColor = Design.PLACEHOLDER_COLOR;
    }
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)pickerController didFinishPickingMediaWithInfo:(NSDictionary *)info {
    DDLogVerbose(@"%@ imagePickerController: %@ didFinishPickingMediaWithInfo: %@", LOG_TAG, pickerController, info);
    
    self.navigationController.navigationBarHidden = YES;
    
    [pickerController dismissViewControllerAnimated:YES completion:^{
        self.avatarPlaceholderImageView.hidden = NO;
        self.updatedLargeAvatar = info[UIImagePickerControllerEditedImage];
        self.updatedAvatar = [self.updatedLargeAvatar resizeImage];
        self.avatarView.image = self.updatedLargeAvatar;
        [self setUpdated];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)pickerController {
    DDLogVerbose(@"%@ imagePickerControllerDidCancel: %@", LOG_TAG, pickerController);
    
    self.navigationController.navigationBarHidden = YES;
    [pickerController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIAdaptivePresentationControllerDelegate

- (void)presentationControllerWillDismiss:(UIPresentationController *)presentationController {
    DDLogVerbose(@"%@ presentationControllerWillDismiss: %@", LOG_TAG, presentationController);

    self.navigationController.navigationBarHidden = YES;
}

#pragma mark - ConfirmViewDelegate

- (void)didTapConfirm:(nonnull AbstractConfirmView *)abstractConfirmView {
    DDLogVerbose(@"%@ didTapConfirm: %@", LOG_TAG, abstractConfirmView);
    
    [self.editRoomService deleteRoom:self.room];
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

#pragma mark - Private methods

- (void)setUpdated {
    DDLogVerbose(@"%@ setUpdated", LOG_TAG);
    
    self.nameContact = self.nameTextField.text;
    self.welcomeMessage = self.descriptionTextView.text;
    
    if ([self.nameContact isEqualToString:self.room.name] && [self.welcomeMessage isEqualToString:self.roomConfig.welcome] && !self.updatedAvatar) {
        if (!self.canSave) {
            return;
        }
        self.canSave = NO;
        self.saveView.alpha = 0.5f;
    } else {
        if (self.canSave) {
            return;
        }
        self.canSave = YES;
        self.saveView.alpha = 1.0f;
    }
}

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    [super initViews];
    
    self.view.backgroundColor = Design.WHITE_COLOR;
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)]];
        
    [self.editAvatarView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleAvatarTapGesture:)]];
    self.editAvatarView.isAccessibilityElement = YES;
    
    self.avatarView.backgroundColor = DESIGN_AVATAR_PLACEHOLDER_COLOR;
    
    self.avatarPlaceholderImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.nameLabel.text = TwinmeLocalizedString(@"show_room_view_controller_room_title", nil);
    
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
    self.descriptionTextView.text = TwinmeLocalizedString(@"admin_room_view_controller_welcome_message", nil);
    self.descriptionTextView.textContainer.lineFragmentPadding = 0;
    self.descriptionTextView.textContainerInset = UIEdgeInsetsZero;
    
    self.counterDescriptionLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.counterDescriptionLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    
    self.counterDescriptionLabel.font = Design.FONT_REGULAR26;
    self.counterDescriptionLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.counterDescriptionLabel.text = [NSString stringWithFormat:@"0/%d", MAX_DESCRIPTION_LENGTH];

    self.configurationTitleTopConstraint.constant *= Design.HEIGHT_RATIO;

    self.configurationTitleLabel.text = TwinmeLocalizedString(@"application_configuration", nil);
    self.configurationTitleLabel.font = Design.FONT_BOLD28;
    self.configurationTitleLabel.textColor = Design.FONT_COLOR_DEFAULT;
    
    self.settingsViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.settingsViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    [self.settingsView setBorder:Design.SEPARATOR_COLOR_GREY borderWidth:Design.SEPARATOR_HEIGHT width:self.descriptionViewWidthConstraint.constant  height:self.settingsViewHeightConstraint.constant left:false right:false top:true bottom:true];
    
    self.settingsView.userInteractionEnabled = true;
    self.settingsView.backgroundColor = Design.WHITE_COLOR;
    self.settingsView.isAccessibilityElement = YES;
    self.settingsView.accessibilityLabel = TwinmeLocalizedString(@"settings_view_controller_title", nil);
    
    UITapGestureRecognizer *settingsViewGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSettingsTapGesture:)];
    [self.settingsView addGestureRecognizer:settingsViewGestureRecognizer];
    
    self.settingsLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.settingsLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.settingsLabel.font = Design.FONT_REGULAR34;
    self.settingsLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.settingsLabel.text = TwinmeLocalizedString(@"settings_view_controller_title", nil);
    
    self.settingsImageViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.settingsImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.settingsImageView.tintColor = Design.UNSELECTED_TAB_COLOR;
    
    self.settingsAccessoryImageHeightConstraint.constant = Design.ACCESSORY_HEIGHT;
    self.settingsAccessoryImageTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.settingsAccessoryImageView.tintColor = Design.ACCESSORY_COLOR;
    self.settingsAccessoryImageView.image = [self.settingsAccessoryImageView.image imageFlippedForRightToLeftLayoutDirection];
    
    self.inviteViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    [self.inviteView setBorder:Design.SEPARATOR_COLOR_GREY borderWidth:Design.SEPARATOR_HEIGHT width:self.descriptionViewWidthConstraint.constant  height:self.inviteViewHeightConstraint.constant left:false right:false top:true bottom:true];
    
    self.inviteView.userInteractionEnabled = true;
    self.inviteView.backgroundColor = Design.WHITE_COLOR;
    self.inviteView.isAccessibilityElement = YES;
    self.inviteView.accessibilityLabel = TwinmeLocalizedString(@"show_room_view_controller_invite_participants", nil);
    
    UITapGestureRecognizer *inviteViewGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleInviteTapGesture:)];
    [self.inviteView addGestureRecognizer:inviteViewGestureRecognizer];
    
    self.inviteLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.inviteLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.inviteLabel.font = Design.FONT_REGULAR34;
    self.inviteLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.inviteLabel.text = TwinmeLocalizedString(@"show_room_view_controller_invite_participants", nil);
    
    self.inviteImageViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.inviteImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.inviteImageView.tintColor = Design.UNSELECTED_TAB_COLOR;
    
    self.inviteAccessoryImageViewHeightConstraint.constant = Design.ACCESSORY_HEIGHT;
    self.inviteAccessoryImageViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.inviteAccessoryImageView.tintColor = Design.ACCESSORY_COLOR;
    self.inviteAccessoryImageView.image = [self.inviteAccessoryImageView.image imageFlippedForRightToLeftLayoutDirection];
    
    self.invitationCodeViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.invitationCodeViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    [self.invitationCodeView setBorder:Design.SEPARATOR_COLOR_GREY borderWidth:Design.SEPARATOR_HEIGHT width:self.descriptionViewWidthConstraint.constant  height:self.invitationCodeViewHeightConstraint.constant left:false right:false top:true bottom:true];
    
    self.invitationCodeView.userInteractionEnabled = true;
    self.invitationCodeView.backgroundColor = Design.WHITE_COLOR;
    self.invitationCodeView.isAccessibilityElement = YES;
    self.invitationCodeView.accessibilityLabel = TwinmeLocalizedString(@"show_profile_view_controller_twincode_title", nil);
    
    UITapGestureRecognizer *invitationCodeViewGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleInvitationCodeTapGesture:)];
    [self.invitationCodeView addGestureRecognizer:invitationCodeViewGestureRecognizer];
    
    self.invitationCodeLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.invitationCodeLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.invitationCodeLabel.font = Design.FONT_REGULAR34;
    self.invitationCodeLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.invitationCodeLabel.text = TwinmeLocalizedString(@"show_profile_view_controller_twincode_title", nil);
    
    self.invitationCodeImageViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.invitationCodeImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.invitationCodeImageView.image = [self.invitationCodeImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.invitationCodeImageView.tintColor = Design.UNSELECTED_TAB_COLOR;
    
    self.invitationCodeAccessoryImageViewHeightConstraint.constant = Design.ACCESSORY_HEIGHT;
    self.invitationCodeAccessoryImageViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.invitationCodeAccessoryImageView.tintColor = Design.ACCESSORY_COLOR;
    self.invitationCodeAccessoryImageView.image = [self.invitationCodeAccessoryImageView.image imageFlippedForRightToLeftLayoutDirection];
    
    self.saveViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.saveViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.saveViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    
    self.saveView.backgroundColor = Design.MAIN_COLOR;
    self.saveView.userInteractionEnabled = YES;
    self.saveView.layer.cornerRadius = Design.CONTAINER_RADIUS;
    self.saveView.clipsToBounds = YES;
    self.saveView.isAccessibilityElement = YES;
    self.saveView.alpha = 0.5;
    self.saveView.accessibilityLabel = TwinmeLocalizedString(@"application_save", nil);
    [self.saveView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSaveTapGesture:)]];
    
    self.saveLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.saveLabel.font = Design.FONT_BOLD36;
    self.saveLabel.textColor = [UIColor whiteColor];
    self.saveLabel.text = TwinmeLocalizedString(@"application_save", nil);
    
    self.removeViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.removeView.backgroundColor = Design.BACKGROUND_COLOR_WHITE_OPACITY11;
    UITapGestureRecognizer *removeViewGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleRemoveTapGesture:)];
    [self.removeView addGestureRecognizer:removeViewGestureRecognizer];
    
    self.removeLabel.font = Design.FONT_REGULAR34;
    self.removeLabel.textColor = Design.DELETE_COLOR_RED;
    self.removeLabel.text = TwinmeLocalizedString(@"application_delete", nil);
    
    self.overlayView = [UIView new];
    self.overlayView.frame = CGRectMake(0, 0, Design.DISPLAY_WIDTH, Design.DISPLAY_HEIGHT);
    self.overlayView.backgroundColor = Design.OVERLAY_COLOR;
    self.overlayView.hidden = YES;
    self.overlayView.userInteractionEnabled = YES;
    [self.tabBarController.view addSubview:self.overlayView];
    
    UITapGestureRecognizer *tapOverlayGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleOverlayTapGesture:)];
    [self.overlayView addGestureRecognizer:tapOverlayGesture];
    
    self.menuPhotoView = [[MenuPhotoView alloc] init];
    self.menuPhotoView.hidden = YES;
    self.menuPhotoView.menuPhotoViewDelegate = self;
    [self.tabBarController.view addSubview:self.menuPhotoView];
    
    [self updateRoom];
}

- (void)finish {
    DDLogVerbose(@"%@ finish", LOG_TAG);
    
    if (self.editRoomService) {
        [self.editRoomService dispose];
        self.editRoomService = nil;
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)dismissKeyboard {
    DDLogVerbose(@"%@ dismissKeyboard", LOG_TAG);
    
    if (!self.keyboardHidden) {
        [self.nameTextField resignFirstResponder];
        [self.descriptionTextView resignFirstResponder];
    }
}

- (void)handleOverlayTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleOverlayTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        [self closeMenu];
    }
}

- (void)handleAvatarTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleAvatarTapGesture: %@", LOG_TAG, sender);
    
    [self openMenuPhoto];
}

- (void)handleSaveTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleSaveTapGesture: %@", LOG_TAG, sender);
    
    if (!self.canSave) {
        return;
    }
    
    NSString *updatedName =  [self.nameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (updatedName.length == 0) {
        updatedName = self.nameTextField.placeholder;
    }
    
    NSString *updatedDescription =  [self.descriptionTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([updatedDescription isEqualToString:TwinmeLocalizedString(@"admin_room_view_controller_welcome_message", nil)]) {
        updatedDescription = @"";
    }
    
    BOOL updated = ![updatedName isEqualToString:self.nameTextField.placeholder] || ![updatedDescription isEqualToString:self.roomConfig.welcome];
    updated = updated || self.updatedLargeAvatar != nil;
    
    if (updated) {
        [self.editRoomService updateRoomWithName:self.room name:updatedName avatar:self.updatedLargeAvatar largeAvatar:self.updatedLargeAvatar welcomeMessage:updatedDescription];
    }
}

- (void)handleRemoveTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleRemoveTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        DeleteConfirmView *deleteConfirmView = [[DeleteConfirmView alloc] init];
        deleteConfirmView.confirmViewDelegate = self;
        deleteConfirmView.deleteConfirmType = DeleteConfirmTypeOriginator;
    
        [deleteConfirmView initWithTitle:self.room.name message:TwinmeLocalizedString(@"application_delete_message", nil)  avatar:self.avatarView.image icon:[UIImage imageNamed:@"ActionBarDelete"]];
        [self.navigationController.view addSubview:deleteConfirmView];
        [deleteConfirmView showConfirmView];
    }
}

- (void)handleInviteTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleInviteTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        AddParticipantsViewController *addParticipantsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AddParticipantsViewController"];
        [addParticipantsViewController initWithRoom:self.room];
        [self.navigationController pushViewController:addParticipantsViewController animated:YES];
    }
}

- (void)handleSettingsTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleSettingsTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        SettingsRoomViewController *settingsRoomViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SettingsRoomViewController"];
        [settingsRoomViewController initWithRoom:self.room];
        [self.navigationController pushViewController:settingsRoomViewController animated:YES];
    }
}

- (void)handleInvitationCodeTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleInvitationCodeTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        InvitationRoomViewController *invitationRoomViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"InvitationRoomViewController"];
        [invitationRoomViewController initWithRoom:self.room];
        [self.navigationController pushViewController:invitationRoomViewController animated:YES];
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
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        CGSize size = self.view.bounds.size;
        picker.modalPresentationStyle = UIModalPresentationPopover;
        picker.popoverPresentationController.sourceView = self.view;
        picker.popoverPresentationController.sourceRect = CGRectMake(size.width * 0.5, size.height * 0.2, size.width * 0.6, size.height * 0.7);
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
    [self.navigationController.view addSubview:menuPhotoView];
    [menuPhotoView openMenu:YES];
}

- (void)closeMenu {
    DDLogVerbose(@"%@ closeMenu", LOG_TAG);
    
    self.overlayView.hidden = YES;
    self.menuPhotoView.hidden = YES;
}

- (void)updateRoom {
    DDLogVerbose(@"%@ updateRoom", LOG_TAG);
    
    if (!self.room) {
        return;
    }
    
    self.nameTextField.placeholder = self.room.name;
    self.nameTextField.text = self.room.name;
    [self.editRoomService getImageWithContact:self.room withBlock:^(UIImage *image) {
        self.avatarView.image = image;
    }];
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
        
    [super updateFont];
    
    self.nameTextField.font = Design.FONT_REGULAR32;
    self.descriptionTextView.font = Design.FONT_REGULAR32;
    self.configurationTitleLabel.font = Design.FONT_BOLD28;
    self.settingsLabel.font = Design.FONT_REGULAR34;
    self.inviteLabel.font = Design.FONT_REGULAR34;
    self.invitationCodeLabel.font = Design.FONT_REGULAR34;
    self.saveLabel.font = Design.FONT_BOLD36;
    self.removeLabel.font = Design.FONT_REGULAR34;
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    [super updateColor];
    
    self.nameTextField.textColor = Design.FONT_COLOR_DEFAULT;
    self.descriptionTextView.textColor = Design.PLACEHOLDER_COLOR;
    self.configurationTitleLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.inviteLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.saveView.backgroundColor = Design.MAIN_COLOR;
    self.removeLabel.textColor = Design.DELETE_COLOR_RED;
    
    if (self.room) {
        self.nameTextField.attributedPlaceholder = [[NSAttributedString alloc]initWithString:self.room.name attributes:[NSDictionary dictionaryWithObject:Design.PLACEHOLDER_COLOR forKey:NSForegroundColorAttributeName]];
    }
    
    if ([self.twinmeApplication darkModeEnable]) {
        self.nameTextField.keyboardAppearance = UIKeyboardAppearanceDark;
        self.descriptionTextView.keyboardAppearance = UIKeyboardAppearanceDark;
    } else {
        self.nameTextField.keyboardAppearance = UIKeyboardAppearanceLight;
        self.descriptionTextView.keyboardAppearance = UIKeyboardAppearanceLight;
    }
    
    self.settingsView.backgroundColor = Design.WHITE_COLOR;
    self.settingsLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.settingsImageView.tintColor = Design.UNSELECTED_TAB_COLOR;
    self.settingsAccessoryImageView.tintColor = Design.ACCESSORY_COLOR;
    
    self.inviteView.backgroundColor = Design.WHITE_COLOR;
    self.inviteLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.inviteImageView.tintColor = Design.UNSELECTED_TAB_COLOR;
    self.inviteAccessoryImageView.tintColor = Design.ACCESSORY_COLOR;
    
    self.invitationCodeView.backgroundColor = Design.WHITE_COLOR;
    self.invitationCodeLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.invitationCodeImageView.tintColor = Design.UNSELECTED_TAB_COLOR;
    self.invitationCodeAccessoryImageView.tintColor = Design.ACCESSORY_COLOR;
    
    self.invitationCodeView.backgroundColor = Design.WHITE_COLOR;
    self.invitationCodeLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.invitationCodeImageView.tintColor = Design.UNSELECTED_TAB_COLOR;
    self.invitationCodeAccessoryImageView.tintColor = Design.ACCESSORY_COLOR;
}

@end
