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
#import "InvitationRoomViewController.h"
#import "SettingsRoomViewController.h"

#import <TwinmeCommon/EditRoomService.h>

#import <TwinmeCommon/Design.h>
#import "InsideBorderView.h"
#import "DeviceAuthorization.h"
#import "AlertView.h"
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

//
// Interface: AdminRoomViewController ()
//

@interface AdminRoomViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UITextViewDelegate, AlertViewDelegate, EditRoomServiceDelegate, MenuPhotoViewDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollViewBottomConstraint;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *identityViewHeightConstraint;
@property (weak, nonatomic) IBOutlet InsideBorderView *identityView;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameTextFieldLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameTextFieldTrailingConstraint;
@property (weak, nonatomic) IBOutlet UIView *avatarContainerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *avatarContainerViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *avatarContainerViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *avatarView;
@property (weak, nonatomic) IBOutlet UIImageView *cameraImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cameraImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *welcomeMessageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet InsideBorderView *welcomeMessageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *welcomeMessageTextViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *welcomeMessageTextViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *welcomeMessageTextViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *welcomeMessageTextViewBottomConstraint;
@property (weak, nonatomic) IBOutlet UITextView *welcomeMessageTextView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *configurationTitleLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *configurationTitleWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *configurationTitleTopConstraint;
@property (weak, nonatomic) IBOutlet UILabel *configurationTitleLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *inviteViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *inviteViewTopConstraint;
@property (weak, nonatomic) IBOutlet InsideBorderView *inviteView;
@property (weak, nonatomic) IBOutlet UILabel *inviteLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *inviteLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *inviteLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *inviteImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *inviteImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *inviteImageViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *settingsViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *settingsViewTopConstraint;
@property (weak, nonatomic) IBOutlet InsideBorderView *settingsView;
@property (weak, nonatomic) IBOutlet UILabel *settingsLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *settingsLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *settingsLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *settingsImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *settingsImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *settingsImageViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *removeViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *removeView;
@property (weak, nonatomic) IBOutlet UILabel *removeLabel;
@property (nonatomic) UIBarButtonItem *saveBarButtonItem;

@property (nonatomic) CALayer *avatarContainerViewLayer;
@property (nonatomic) UIImage *avatar;
@property (nonatomic) UIImage *largeAvatar;
@property (nonatomic) NSString *nameContact;
@property (nonatomic) NSString *welcomeMessage;
@property (nonatomic) BOOL canSave;
@property (nonatomic) BOOL updated;
@property (nonatomic) BOOL keyboardHidden;

@property (nonatomic) int nbLinesDescription;
@property (nonatomic) int nbLinesWelcome;

@property (nonatomic) TLContact *room;

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
}

#pragma mark - UIViewController

- (instancetype)initWithCoder:(NSCoder *)coder {
    DDLogVerbose(@"%@ initWithCoder: %@", LOG_TAG, coder);
    
    self = [super initWithCoder:coder];
    
    if (self) {
        _canSave = NO;
        _updated = NO;
        _keyboardHidden = YES;
        _nbLinesDescription = 0;
        _nbLinesWelcome = 0;
        
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    DDLogVerbose(@"%@ viewWillDisappear: %@", LOG_TAG, animated ? @"YES" : @"NO");
    
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardDidShow:(NSNotification *)notification {
    DDLogVerbose(@"%@ keyboardDidShow: %@", LOG_TAG, notification);
    
    NSDictionary *info = [notification userInfo];
    CGPoint keyboardOrigin = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].origin;
    
    self.scrollViewBottomConstraint.constant = self.view.frame.size.height - keyboardOrigin.y;
    
    self.keyboardHidden = NO;
}

- (void)keyboardWillHide:(NSNotification *)notification {
    DDLogVerbose(@"%@ keyboardWillHide: %@", LOG_TAG, notification);
    
    self.scrollViewBottomConstraint.constant = 0;
    
    self.keyboardHidden = YES;
}

- (void)viewDidLayoutSubviews {
    DDLogVerbose(@"%@ viewDidLayoutSubviews", LOG_TAG);
    
    if (self.contentViewHeightConstraint.constant < self.view.frame.size.height) {
        self.contentViewHeightConstraint.constant = self.view.safeAreaLayoutGuide.layoutFrame.size.height;
    }
}

- (void)initWithRoom:(TLContact *)room {
    DDLogVerbose(@"%@ initWithRoom: %@", LOG_TAG, room);
    
    self.room = room;
    
    [self.editRoomService getRoomConfig:room];
}

#pragma mark - EditRoomServiceDelegate

- (void)onGetRoomConfig:(nonnull TLRoomConfig *)roomConfig {
    DDLogVerbose(@"%@ onGetRoomConfig: %@", LOG_TAG, roomConfig);
    
    if (roomConfig.welcome) {
        self.welcomeMessageTextView.text = roomConfig.welcome;
    }
}

- (void)onGetRoomConfigNotFound {
    DDLogVerbose(@"%@ onGetRoomConfigNotFound", LOG_TAG);
    
    self.welcomeMessageTextView.text = TwinmeLocalizedString(@"admin_room_view_controller_welcome_message", nil);
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
    
    if (textView == self.welcomeMessageTextView && [self.welcomeMessageTextView.text isEqualToString:TwinmeLocalizedString(@"admin_room_view_controller_welcome_message", nil)]) {
        self.welcomeMessageTextView.text = @"";
        self.welcomeMessageTextView.textColor = Design.FONT_COLOR_DEFAULT;
    }
}

- (void)textViewDidChange:(UITextView *)textView {
    DDLogVerbose(@"%@ textViewDidChange", LOG_TAG);
    
    [self centerTextDescription:textView];
    [self setUpdated];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    DDLogVerbose(@"%@ textViewDidEndEditing: %@", LOG_TAG, textView);
    
    if (textView == self.welcomeMessageTextView && [self.welcomeMessageTextView.text isEqualToString:@""]) {
        self.welcomeMessageTextView.text = TwinmeLocalizedString(@"admin_room_view_controller_welcome_message", nil);
        self.welcomeMessageTextView.textColor = Design.PLACEHOLDER_COLOR;
    }
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)pickerController didFinishPickingMediaWithInfo:(NSDictionary *)info {
    DDLogVerbose(@"%@ imagePickerController: %@ didFinishPickingMediaWithInfo: %@", LOG_TAG, pickerController, info);
    
    [pickerController dismissViewControllerAnimated:YES completion:^{
        self.avatarContainerViewLayer.borderColor = [UIColor clearColor].CGColor;
        
        self.largeAvatar = info[UIImagePickerControllerEditedImage];
        self.avatar = [self.largeAvatar resizeImage];
        
        CATransition *animation = [CATransition animation];
        animation.type = kCATransitionFade;
        animation.subtype = kCATransitionFromTop;
        animation.duration = 0.5;
        [self.avatarView.layer addAnimation:animation forKey:nil];
        self.avatarView.image = self.avatar;
        self.cameraImageView.hidden = YES;
        
        [self setUpdated];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)pickerController {
    DDLogVerbose(@"%@ imagePickerControllerDidCancel: %@", LOG_TAG, pickerController);
    
    [pickerController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - AlertViewDelegate

- (void)handleAcceptButtonClick:(AlertView *)alertView {
    DDLogVerbose(@"%@ handleAcceptButtonClick: %@", LOG_TAG, alertView);
    
    [self.editRoomService deleteRoom:self.room];
}

- (void)handleCancelButtonClick:(AlertView *)alertView {
    DDLogVerbose(@"%@ handleCancelButtonClick: %@", LOG_TAG, alertView);
    
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

#pragma mark - Private methods

- (void)setUpdated {
    DDLogVerbose(@"%@ setUpdated", LOG_TAG);
    
    self.nameContact = self.nameTextField.text;
    self.welcomeMessage = self.welcomeMessageTextView.text;
    
    if ([self.nameContact isEqualToString:self.room.name] && !self.avatar) {
        if (!self.canSave) {
            return;
        }
        self.canSave = false;
        self.saveBarButtonItem.enabled = NO;
    } else {
        if (self.canSave) {
            return;
        }
        self.canSave = true;
        self.saveBarButtonItem.enabled = YES;
    }
}

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    self.view.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
    
    [self setNavigationTitle:TwinmeLocalizedString(@"application_edit", nil)];
    
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)]];
    
    self.saveBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:TwinmeLocalizedString(@"application_save", nil) style:UIBarButtonItemStylePlain target:self action:@selector(handleSaveTapGesture:)];
    [self.saveBarButtonItem setTitleTextAttributes: @{NSFontAttributeName : Design.FONT_BOLD36, NSForegroundColorAttributeName: [UIColor whiteColor]} forState:UIControlStateNormal];
    [self.saveBarButtonItem setTitleTextAttributes: @{NSFontAttributeName : Design.FONT_BOLD36, NSForegroundColorAttributeName: [UIColor colorWithWhite:1.0 alpha:0.5]} forState:UIControlStateDisabled];
    self.saveBarButtonItem.enabled = NO;
    self.navigationItem.rightBarButtonItem = self.saveBarButtonItem;
    
    self.scrollView.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
    
    self.contentViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.contentView.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
    
    self.identityViewHeightConstraint.constant  *= Design.HEIGHT_RATIO;
    self.identityView.backgroundColor = Design.WHITE_COLOR;
    [self.identityView setBorder:Design.SEPARATOR_COLOR_GREY borderWidth:Design.SEPARATOR_HEIGHT width:[[UIScreen mainScreen] bounds].size.width height:self.identityViewHeightConstraint.constant left:false right:false top:true bottom:false];
    
    self.nameTextFieldLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.nameTextFieldTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.nameTextField.font = Design.FONT_REGULAR32;
    self.nameTextField.textColor = Design.FONT_COLOR_DEFAULT;
    self.nameTextField.placeholder = TwinmeLocalizedString(@"application_name_hint", nil);
    self.nameTextField.delegate = self;
    [self.nameTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    self.avatarContainerViewHeightConstraint.constant  *= Design.HEIGHT_RATIO;
    self.avatarContainerViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.cameraImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.cameraImageView.tintColor = Design.EDIT_AVATAR_IMAGE_COLOR;
    
    self.avatarContainerViewLayer = self.avatarContainerView.layer;
    self.avatarContainerViewLayer.cornerRadius = self.avatarContainerViewHeightConstraint.constant * 0.5;
    self.avatarContainerViewLayer.masksToBounds = YES;
    
    self.avatarView.userInteractionEnabled = YES;
    [self.avatarView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleAvatarTapGesture:)]];
    self.avatarView.backgroundColor = Design.EDIT_AVATAR_BACKGROUND_COLOR;
    
    self.welcomeMessageViewHeightConstraint.constant  *= Design.HEIGHT_RATIO;
    self.welcomeMessageView.backgroundColor = Design.WHITE_COLOR;
    [self.welcomeMessageView setBorder:Design.SEPARATOR_COLOR_GREY borderWidth:Design.SEPARATOR_HEIGHT width:[[UIScreen mainScreen] bounds].size.width height:self.welcomeMessageViewHeightConstraint.constant left:false right:false top:true bottom:false];
    
    self.welcomeMessageTextViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.welcomeMessageTextViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.welcomeMessageTextView.font = Design.FONT_REGULAR32;
    self.welcomeMessageTextView.textColor = Design.PLACEHOLDER_COLOR;
    self.welcomeMessageTextView.backgroundColor = Design.WHITE_COLOR;
    self.welcomeMessageTextView.text = TwinmeLocalizedString(@"admin_room_view_controller_welcome_message", nil);
    self.welcomeMessageTextView.delegate = self;
    self.welcomeMessageTextView.textContainer.lineFragmentPadding = 0;
    self.welcomeMessageTextView.textContainerInset = UIEdgeInsetsZero;
    
    CGFloat welcomeTextMargin = (self.welcomeMessageViewHeightConstraint.constant - self.welcomeMessageTextView.font.lineHeight) / 2.0;
    self.welcomeMessageTextViewTopConstraint.constant = welcomeTextMargin;
    self.welcomeMessageTextViewBottomConstraint.constant = welcomeTextMargin;
    
    self.configurationTitleTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.configurationTitleLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.configurationTitleWidthConstraint.constant *= Design.WIDTH_RATIO;
    
    self.configurationTitleLabel.text = TwinmeLocalizedString(@"application_configuration", nil);
    self.configurationTitleLabel.font = Design.FONT_BOLD28;
    self.configurationTitleLabel.textColor = Design.FONT_COLOR_DEFAULT;
    
    self.inviteViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.inviteViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.inviteView.backgroundColor = Design.WHITE_COLOR;
    [self.inviteView setBorder:Design.SEPARATOR_COLOR_GREY borderWidth:Design.SEPARATOR_HEIGHT width:[[UIScreen mainScreen] bounds].size.width height:self.inviteViewHeightConstraint.constant left:false right:false top:true bottom:true];
    
    UITapGestureRecognizer *inviteViewGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleInviteTapGesture:)];
    [self.inviteView addGestureRecognizer:inviteViewGestureRecognizer];
    
    self.inviteLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.inviteLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.inviteLabel.font = Design.FONT_REGULAR32;
    self.inviteLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.inviteLabel.text = TwinmeLocalizedString(@"show_room_view_controller_invite_participants", nil);
    
    self.inviteImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.inviteImageViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.inviteImageView.tintColor = Design.BLACK_COLOR;
    self.inviteImageView.image = [self.inviteImageView.image imageFlippedForRightToLeftLayoutDirection];
    
    self.settingsViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.settingsViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.settingsView.backgroundColor = Design.WHITE_COLOR;
    [self.settingsView setBorder:Design.SEPARATOR_COLOR_GREY borderWidth:Design.SEPARATOR_HEIGHT width:[[UIScreen mainScreen] bounds].size.width height:self.settingsViewHeightConstraint.constant left:false right:false top:true bottom:true];
    
    UITapGestureRecognizer *settingsViewGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSettingsTapGesture:)];
    [self.settingsView addGestureRecognizer:settingsViewGestureRecognizer];
    
    self.settingsLabel.font = Design.FONT_REGULAR32;
    self.settingsLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.settingsLabel.text = TwinmeLocalizedString(@"settings_view_controller_title", nil);
    
    self.settingsLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.settingsLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.settingsImageView.tintColor = Design.BLACK_COLOR;
    self.settingsImageView.image = [self.inviteImageView.image imageFlippedForRightToLeftLayoutDirection];
    
    self.settingsImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.settingsImageViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.removeViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.removeView.backgroundColor = Design.BACKGROUND_COLOR_WHITE_OPACITY11;
    UITapGestureRecognizer *removeViewGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleRemoveTapGesture:)];
    [self.removeView addGestureRecognizer:removeViewGestureRecognizer];
    
    self.removeLabel.font = Design.FONT_REGULAR34;
    self.removeLabel.textColor = Design.DELETE_COLOR_RED;
    self.removeLabel.text = TwinmeLocalizedString(@"application_delete", nil);
    
    [self updateRoom];
    [self centerTextDescription:self.welcomeMessageTextView];
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
        [self.welcomeMessageTextView resignFirstResponder];
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
    
    [self.editRoomService updateRoomWithName:self.room name:updatedName avatar:self.avatar largeAvatar:self.largeAvatar welcomeMessage:self.welcomeMessageTextView.text];
}

- (void)handleRemoveTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleRemoveTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        AlertView *alertView = [[AlertView alloc] initWithTitle:TwinmeLocalizedString(@"application_delete", nil) message:TwinmeLocalizedString(@"application_delete_message", nil) cancelButtonTitle:TwinmeLocalizedString(@"application_no", nil) otherButtonTitles:TwinmeLocalizedString(@"application_yes", nil) alertViewDelegate:self];
        [alertView showInView:self.tabBarController];
    }
}

- (void)handleInviteTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleInviteTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        InvitationRoomViewController *invitationRoomViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"InvitationRoomViewController"];
        [invitationRoomViewController initWithRoom:self.room];
        [self.navigationController pushViewController:invitationRoomViewController animated:YES];
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

- (void)centerTextDescription:(UITextView *)textView {
    DDLogVerbose(@"%@ centerTextDescription", LOG_TAG);
    
    int nbLines = textView.contentSize.height / textView.font.lineHeight;
    
    int lastNbLines = self.nbLinesDescription;
    
    if (textView == self.welcomeMessageTextView) {
        lastNbLines = self.nbLinesWelcome;
    }
    
    if (nbLines != lastNbLines) {
        CGFloat lastDescriptionViewHeight = textView.frame.size.height;
        CGFloat newDescriptionViewHeight = textView.contentSize.height + (self.welcomeMessageTextViewTopConstraint.constant * 2.0);
        
        if (newDescriptionViewHeight < SECTION_HEIGHT) {
            newDescriptionViewHeight = SECTION_HEIGHT;
        }
        
        if (lastDescriptionViewHeight != newDescriptionViewHeight) {
            
            CGRect descriptionTextRect = textView.frame;
            descriptionTextRect.size.height = textView.contentSize.height;
            textView.frame = descriptionTextRect;
            
            [textView setContentOffset:CGPointZero animated:YES];
            
            if (textView == self.welcomeMessageTextView) {
                self.welcomeMessageViewHeightConstraint.constant = newDescriptionViewHeight;
                [self.welcomeMessageView clearBorder];
                [self.welcomeMessageView setBorder:Design.SEPARATOR_COLOR_GREY borderWidth:Design.SEPARATOR_HEIGHT width:[[UIScreen mainScreen] bounds].size.width height:newDescriptionViewHeight left:false right:false top:true bottom:false];
                self.nbLinesWelcome = nbLines;
            }
        }
    }
}

- (void)openMenuPhoto {
    DDLogVerbose(@"%@ openMenuPhoto", LOG_TAG);
    
    [self dismissKeyboard];
    
    MenuPhotoView *menuPhotoView = [[MenuPhotoView alloc]init];
    menuPhotoView.menuPhotoViewDelegate = self;
    [self.tabBarController.view addSubview:menuPhotoView];
    [menuPhotoView openMenu:YES];
}

- (void)updateRoom {
    DDLogVerbose(@"%@ updateRoom", LOG_TAG);
    
    if (!self.room) {
        return;
    }
    
    self.nameTextField.placeholder = self.room.name;
    self.nameTextField.text = self.room.name;
    [self.editRoomService getImageWithContact:self.room withBlock:^(UIImage *image) {
        self.avatar = image;
    }];
    self.avatarView.image = self.avatar;
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    [self.saveBarButtonItem setTitleTextAttributes: @{NSFontAttributeName: Design.FONT_BOLD36, NSForegroundColorAttributeName: [UIColor whiteColor]} forState:UIControlStateNormal];
    [self.saveBarButtonItem setTitleTextAttributes: @{NSFontAttributeName: Design.FONT_BOLD36, NSForegroundColorAttributeName: [UIColor colorWithWhite:1.0 alpha:0.5]} forState:UIControlStateDisabled];
    
    self.nameTextField.font = Design.FONT_REGULAR32;
    self.welcomeMessageTextView.font = Design.FONT_REGULAR32;
    self.configurationTitleLabel.font = Design.FONT_BOLD28;
    self.inviteLabel.font = Design.FONT_REGULAR32;
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    self.nameTextField.textColor = Design.FONT_COLOR_DEFAULT;
    self.welcomeMessageTextView.textColor = Design.PLACEHOLDER_COLOR;
    self.configurationTitleLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.inviteLabel.textColor = Design.FONT_COLOR_DEFAULT;
    
    if (self.room) {
        self.nameTextField.attributedPlaceholder = [[NSAttributedString alloc]initWithString:self.room.name attributes:[NSDictionary dictionaryWithObject:Design.PLACEHOLDER_COLOR forKey:NSForegroundColorAttributeName]];
    }
}

@end
