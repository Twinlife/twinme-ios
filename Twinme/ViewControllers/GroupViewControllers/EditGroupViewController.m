/*
 *  Copyright (c) 2020-2024 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (fabrice.trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <Twinlife/TLTwincodeOutboundService.h>
#import <Twinme/TLProfile.h>
#import <Twinme/TLGroup.h>
#import <Twinme/UIImage+Resize.h>

#import <Utils/NSString+Utils.h>

#import "EditGroupViewController.h"

#import <TwinmeCommon/ApplicationDelegate.h>
#import <TwinmeCommon/Design.h>
#import <TwinmeCommon/EditGroupService.h>
#import <TwinmeCommon/TwinmeApplication.h>

#import "DeleteConfirmView.h"
#import "MenuPhotoView.h"
#import "DeviceAuthorization.h"

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

//
// Interface: EditGroupViewController ()
//

@interface EditGroupViewController () <EditGroupServiceDelegate, UITextFieldDelegate, ConfirmViewDelegate, UITextViewDelegate, UIAdaptivePresentationControllerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, MenuPhotoViewDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *avatarPlaceholderImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *avatarPlaceholderImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *noAvatarImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *noAvatarImageView;
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
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *saveViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *saveViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *saveViewWidthConstraint;
@property (weak, nonatomic) IBOutlet UIView *saveView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *saveLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet UILabel *saveLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *removeViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *removeView;
@property (weak, nonatomic) IBOutlet UILabel *removeLabel;

@property (nonatomic) BOOL keyboardHidden;
@property (nonatomic) BOOL saveViewDisabled;
@property (nonatomic) NSString *groupName;
@property (nonatomic) NSString *groupDescription;
@property (nonatomic) UIImage *groupAvatar;
@property (nonatomic) UIImage *avatar;
@property (nonatomic) UIImage *largeAvatar;
@property (nonatomic) BOOL updated;
@property (nonatomic) BOOL hasClearedText;
@property (nonatomic) TLGroup *group;
@property (nonatomic) id<TLGroupConversation> groupConversation;

@property (nonatomic) EditGroupService *editGroupService;

@end

//
// Implementation: EditGroupViewController
//

#undef LOG_TAG
#define LOG_TAG @"EditGroupViewController"

@implementation EditGroupViewController

#pragma mark - UIViewController

- (instancetype)initWithCoder:(NSCoder *)coder {
    DDLogVerbose(@"%@ initWithCoder: %@", LOG_TAG, coder);
    
    self = [super initWithCoder:coder];
    
    if (self) {
        _saveViewDisabled = NO;
        _updated = NO;
        _hasClearedText = NO;
        
        _editGroupService = [[EditGroupService alloc] initWithTwinmeContext:self.twinmeContext delegate:self];
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

#pragma mark - Public methods

- (void)initWithGroup:(TLGroup *)group {
    DDLogVerbose(@"%@ initWithGroup: %@", LOG_TAG, group);
    
    self.group = group;
    
    self.groupName = self.group.name;
    
    if (self.group.objectDescription.length > 0) {
        self.groupDescription = self.group.objectDescription;
    } else if (self.group.peerDescription) {
        self.groupDescription = self.group.peerDescription;
    } else {
        self.groupDescription = @"";
    }
    
    [self.editGroupService refreshWithGroup:group];
}

#pragma mark - UITextFieldDelegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    DDLogVerbose(@"%@ textFieldShouldReturn: %@", LOG_TAG, textField);
    
    [textField resignFirstResponder];
    return NO;
}

- (void)textFieldDidChange:(UITextField *)textField {
    DDLogVerbose(@"%@ textFieldDidChange: %@", LOG_TAG, textField);
    
    if (![textField.text isEqualToString:@""] && ![textField.text isEqualToString:self.groupName]) {
        [self setUpdated];
    } else {
        self.updated = NO;
        self.saveView.alpha = 0.5f;
    }
    
    if (![textField.text isEqualToString:@""] && ![textField.text isEqualToString:self.groupName]) {
        [self setUpdated];
    } else if ([textField.text isEqualToString:@""] && !self.hasClearedText && ![self.groupName isEqualToString:self.group.groupPublicName]) {
        self.hasClearedText = YES;
        self.nameTextField.text = self.group.groupPublicName;
    } else {
        self.updated = NO;
        self.saveView.alpha = 0.5f;
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
    
    if (![textView.text isEqualToString:self.group.objectDescription]) {
        [self setUpdated];
    } else if (!self.avatar && [self.nameTextField.text isEqualToString:self.group.name]) {
        self.updated = NO;
        self.saveView.alpha = 0.5;
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
        self.largeAvatar = info[UIImagePickerControllerEditedImage];
        self.avatar = [self.largeAvatar resizeImage];
        
        CATransition *animation = [CATransition animation];
        animation.type = kCATransitionFade;
        animation.subtype = kCATransitionFromTop;
        animation.duration = 0.5;
        [self.avatarView.layer addAnimation:animation forKey:nil];
        self.avatarView.image = self.largeAvatar;
        self.noAvatarImageView.hidden = YES;
        self.avatarView.backgroundColor = [UIColor clearColor];
        
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

#pragma mark - EditGroupServiceDelegate

- (void)onUpdateGroupAvatar:(nonnull UIImage *)avatar {
    DDLogVerbose(@"%@ onUpdateGroupAvatar: %@", LOG_TAG, avatar);
    
    self.groupAvatar = avatar;
    
    if (self.group.avatarId && self.groupAvatar) {
        self.avatarView.image = self.groupAvatar;
        self.avatarView.backgroundColor = [UIColor clearColor];
        self.noAvatarImageView.hidden = YES;
    }
}

- (void)onUpdateGroupAvatarNotFound {
    DDLogVerbose(@"%@ onUpdateGroupAvatarNotFound", LOG_TAG);
    
    if (self.group.avatarId) {
        [self.editGroupService getImageWithGroup:self.group withBlock:^(UIImage *image) {
            self.avatarView.image = image;
            self.avatarView.backgroundColor = [UIColor clearColor];
            self.noAvatarImageView.hidden = YES;
        }];
    }
}

- (void)onUpdateGroup:(nonnull TLGroup *)group avatar:(nullable UIImage *)avatar {
    DDLogVerbose(@"%@ onUpdateGroup: %@", LOG_TAG, group);
    
    self.group = group;
    
    self.updated = NO;
    
    [self finish];
}

- (void)onLeaveGroup:(TLGroup *)group memberTwincodeId:(NSUUID *)memberTwincodeId {
    DDLogVerbose(@"%@ onLeaveGroup: %@ memberTwincodeId: %@", LOG_TAG, group, memberTwincodeId);
    
    if ([group isLeaving]) {
        [self finish];
    }
}

- (void)onDeleteGroup:(NSUUID *)groupId {
    DDLogVerbose(@"%@ onDeleteGroup: %@", LOG_TAG, groupId);
    
    if ([self.group isOwner]) {
        [self finish];
    }
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
    
    if ([self.group isOwner]) {
        [self.editGroupService leaveGroupWithMemberTwincodeId:self.group memberTwincodeId:self.group.twincodeOutboundId];
    } else {
        [self.editGroupService leaveGroupWithMemberTwincodeId:self.group memberTwincodeId:self.group.twincodeOutbound.uuid];
    }
    
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
        
    [self.editAvatarView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleUpdateAvatarTapGesture)]];
    self.editAvatarView.isAccessibilityElement = YES;
    
    self.avatarPlaceholderImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    if (self.groupAvatar) {
        self.avatarView.image = self.groupAvatar;
        self.noAvatarImageView.hidden = YES;
    } else {
        self.noAvatarImageView.hidden = NO;
        self.avatarView.backgroundColor = Design.EDIT_AVATAR_BACKGROUND_COLOR;
    }
    
    self.noAvatarImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.nameLabel.text = self.groupName;
    
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
    self.nameTextField.text = self.groupName;
    self.nameTextField.placeholder = self.groupName;
    [self.nameTextField setReturnKeyType:UIReturnKeyDone];
    self.nameTextField.delegate = self;
    [self.nameTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    self.counterNameLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.counterNameLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    
    self.counterNameLabel.font = Design.FONT_REGULAR26;
    self.counterNameLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.counterNameLabel.text = [NSString stringWithFormat:@"0/%d", MAX_NAME_LENGTH];
    
    if (self.groupName.length > MAX_NAME_LENGTH) {
        self.nameTextField.text = [self.groupName substringToIndex:MAX_NAME_LENGTH];
        self.counterNameLabel.text = [NSString stringWithFormat:@"%d/%d", MAX_NAME_LENGTH, MAX_NAME_LENGTH];
    } else {
        self.counterNameLabel.text = [NSString stringWithFormat:@"%lu/%d", (unsigned long)self.groupName.length, MAX_NAME_LENGTH];
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
    self.descriptionTextView.textContainer.lineFragmentPadding = 0;
    self.descriptionTextView.textContainerInset = UIEdgeInsetsZero;
    
    if (self.groupDescription && ![self.groupDescription isEqualToString:@""]) {
        self.descriptionTextView.text = self.groupDescription;
        self.descriptionTextView.textColor = Design.FONT_COLOR_DEFAULT;
        self.counterDescriptionLabel.text = [NSString stringWithFormat:@"%lu/%d", (unsigned long)self.descriptionTextView.text.length, MAX_DESCRIPTION_LENGTH];
    } else {
        self.descriptionTextView.text = TwinmeLocalizedString(@"side_menu_view_controller_about", nil);
        self.descriptionTextView.textColor = Design.PLACEHOLDER_COLOR;
        self.counterDescriptionLabel.text = [NSString stringWithFormat:@"0/%d", MAX_DESCRIPTION_LENGTH];
    }
    
    self.counterDescriptionLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.counterDescriptionLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    
    self.counterDescriptionLabel.font = Design.FONT_REGULAR26;
    self.counterDescriptionLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.counterDescriptionLabel.text = [NSString stringWithFormat:@"0/%d", MAX_DESCRIPTION_LENGTH];
    
    self.saveViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.saveViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.saveViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    
    self.saveView.backgroundColor = Design.MAIN_COLOR;
    self.saveView.userInteractionEnabled = YES;
    self.saveView.layer.cornerRadius = Design.CONTAINER_RADIUS;
    self.saveView.clipsToBounds = YES;
    self.saveView.isAccessibilityElement = YES;
    self.saveView.accessibilityLabel = TwinmeLocalizedString(@"application_save", nil);
    [self.saveView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSaveTapGesture:)]];
    self.saveView.alpha = 0.5f;
    
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
    
    if ([self.group isOwner]) {
        self.editAvatarView.hidden = NO;
        self.avatarPlaceholderImageView.hidden = NO;
        self.removeLabel.text = TwinmeLocalizedString(@"application_delete", nil);
    } else {
        self.editAvatarView.hidden = YES;
        self.avatarPlaceholderImageView.hidden = YES;
        self.removeLabel.text = TwinmeLocalizedString(@"show_group_view_controller_leave", nil);
    }
}

- (void)finish {
    DDLogVerbose(@"%@ finish", LOG_TAG);
    
    if (self.editGroupService) {
        [self.editGroupService dispose];
        self.editGroupService = nil;
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setUpdated {
    DDLogVerbose(@"%@ setUpdated", LOG_TAG);
    
    if (self.updated) {
        return;
    }
    self.updated = YES;
    
    self.saveView.alpha = 1.0f;
}

- (void)keyboardWillShow:(NSNotification *)notification {
    DDLogVerbose(@"%@ keyboardWillShow: %@", LOG_TAG, notification);
    
    if (!self.keyboardHidden) {
        return;
    }
    
    self.keyboardHidden = NO;
    NSDictionary *info = [notification userInfo];
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    CGRect saveViewFrame = self.saveView.frame;
    CGRect frame = self.view.frame;
    CGFloat slidePosition = frame.size.height - (keyboardSize.height + saveViewFrame.origin.y + saveViewFrame.size.height + self.saveViewTopConstraint.constant);
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

- (void)handleTapGesture {
    DDLogVerbose(@"%@ handleTapGesture", LOG_TAG);
    
    if ([self.nameTextField isFirstResponder]) {
        [self.nameTextField resignFirstResponder];
    }
    
    if ([self.descriptionTextView isFirstResponder]) {
        [self.descriptionTextView resignFirstResponder];
    }
}

- (void)handleUpdateAvatarTapGesture {
    DDLogVerbose(@"%@ handleUpdateAvatarTapGesture", LOG_TAG);
    
    [self openMenuPhoto];
}

- (void)handleSaveTapGesture:(UIButton *)sender {
    DDLogVerbose(@"%@ handleSaveTapGesture: %@", LOG_TAG, sender);
    
    if (!self.updated) {
        return;
    }
    
    if (!self.saveViewDisabled) {
        self.saveViewDisabled = YES;
        
        NSString *updatedName = self.nameTextField.text;
        if (updatedName.length == 0) {
            updatedName = self.nameTextField.placeholder;
        }
        
        NSString *updatedDescription =  [self.descriptionTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if ([updatedDescription isEqualToString:TwinmeLocalizedString(@"side_menu_view_controller_about", nil)]) {
            updatedDescription = @"";
        }
        
        BOOL updated = ![updatedName isEqualToString:self.nameTextField.placeholder] || ![updatedDescription isEqualToString:self.groupDescription];
        updated = updated || self.largeAvatar != nil;
        
        if (updated) {
            if (self.largeAvatar) {
                [self.editGroupService updateGroupWithName:self.group name:updatedName description:updatedDescription avatar:self.avatar largeAvatar:self.largeAvatar];
            } else {
                [self.editGroupService updateGroupWithName:self.group name:updatedName description:updatedDescription];
            }
        } else {
            [self finish];
        }
    }
}

- (void)handleRemoveTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleRemoveTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        
        [self.editGroupService getImageWithGroup:self.group withBlock:^(UIImage *image) {
            NSString *message = [NSString stringWithFormat:@"%@\n%@", TwinmeLocalizedString(@"show_group_view_controller_leave_message", nil), TwinmeLocalizedString(@"show_group_view_controller_leave_message_confirm", nil)];
            
            if ([self.group isOwner]) {
                message = [NSString stringWithFormat:@"%@\n%@", TwinmeLocalizedString(@"show_group_view_controller_remove_message", nil), TwinmeLocalizedString(@"show_group_view_controller_remove_message_confirm", nil)];
            }
            
            DeleteConfirmView *deleteConfirmView = [[DeleteConfirmView alloc] init];
            deleteConfirmView.confirmViewDelegate = self;
            deleteConfirmView.deleteConfirmType = DeleteConfirmTypeOriginator;
            [deleteConfirmView initWithTitle:TwinmeLocalizedString(@"delete_account_view_controller_warning", nil) message:message avatar:image icon:[UIImage imageNamed:@"ActionBarDelete"]];
            [deleteConfirmView setConfirmTitle:TwinmeLocalizedString(@"application_confirm", nil)];
            [self.view addSubview:deleteConfirmView];
            [deleteConfirmView showConfirmView];
        }];
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
    [menuPhotoView openMenu:YES];
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    self.nameTextField.font = Design.FONT_REGULAR28;
    self.saveLabel.font = Design.FONT_BOLD36;
    self.counterNameLabel.font = Design.FONT_REGULAR26;
    self.removeLabel.font = Design.FONT_REGULAR34;
    self.counterDescriptionLabel.font = Design.FONT_REGULAR28;
    self.counterNameLabel.font = Design.FONT_REGULAR26;
    self.counterDescriptionLabel.font = Design.FONT_REGULAR26;
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    [super updateColor];
    
    self.nameView.backgroundColor = Design.TEXTFIELD_BACKGROUND_COLOR;
    self.saveView.backgroundColor = Design.MAIN_COLOR;
    self.nameTextField.textColor = Design.FONT_COLOR_DEFAULT;
    self.nameTextField.tintColor = Design.FONT_COLOR_DEFAULT;
    self.counterNameLabel.textColor = Design.FONT_COLOR_DEFAULT;
    
    self.nameTextField.attributedPlaceholder = [[NSAttributedString alloc]initWithString:self.group.groupPublicName attributes:[NSDictionary dictionaryWithObject:Design.PLACEHOLDER_COLOR forKey:NSForegroundColorAttributeName]];
    
    self.counterDescriptionLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.counterNameLabel.textColor = Design.FONT_COLOR_DEFAULT;
    
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
