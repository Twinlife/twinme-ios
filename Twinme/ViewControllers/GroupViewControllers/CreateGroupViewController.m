/*
 *  Copyright (c) 2018-2020 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <Twinlife/TLConversationService.h>

#import <Twinme/TLProfile.h>
#import <Twinme/TLContact.h>
#import <Twinme/TLGroup.h>
#import <Twinme/UIImage+Resize.h>

#import <Utils/NSString+Utils.h>

#import "CreateGroupViewController.h"
#import "AddGroupMemberViewController.h"
#import "SettingsGroupViewController.h"
#import <TwinmeCommon/GroupService.h>

#import "ShowMemberCell.h"
#import "UIContact.h"

#import "ShowGroupViewController.h"
#import <TwinmeCommon/TwinmeNavigationController.h>

#import <TwinmeCommon/Design.h>
#import "InsideBorderView.h"
#import "DeviceAuthorization.h"
#import "SwitchView.h"
#import "AlertMessageView.h"
#import "MenuPhotoView.h"

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static NSString *MEMBER_CELL_IDENTIFIER = @"ShowMemberCellIdentifier";

static int MAX_GROUP_MEMBER = 5;

static UIColor *DESIGN_AVATAR_PLACEHOLDER_COLOR;

//
// Interface: CreateGroupViewController ()
//

@interface CreateGroupViewController () <GroupServiceDelegate, AddGroupMemberDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIAdaptivePresentationControllerDelegate, UITextFieldDelegate, UITextViewDelegate, UICollectionViewDataSource, AlertMessageViewDelegate, MenuPhotoViewDelegate, SettingsGroupDelegate>

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
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *membersLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *membersLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *membersLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet UILabel *membersLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *inviteViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *inviteViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *inviteViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet UIView *inviteView;
@property (weak, nonatomic) IBOutlet UILabel *inviteLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *membersViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *membersViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *membersViewHeightConstraint;
@property (weak, nonatomic) IBOutlet InsideBorderView *membersView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *membersCollectionViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *membersCollectionViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet UICollectionView *membersCollectionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *noMembersLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *noMembersLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *noMembersLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *noMembersAccessoryViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *noMembersAccessoryViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *noMembersAccessoryView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *settingsTitleLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *settingsTitleLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *settingsTitleLabelTopConstraint;
@property (weak, nonatomic) IBOutlet UILabel *settingsTitleLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *settingsViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *settingsViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *settingsViewTopConstraint;
@property (weak, nonatomic) IBOutlet InsideBorderView *settingsView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *settingsLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *settingsLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *settingsLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *settingsAccessoryViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *settingsAccessoryViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *settingsAccessoryView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *saveViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *saveViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *saveViewWidthConstraint;
@property (weak, nonatomic) IBOutlet UIView *saveView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *saveLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet UILabel *saveLabel;

@property (nonatomic) NSMutableArray *uiContacts;
@property (nonatomic) NSMutableArray *uiMembers;
@property (nonatomic) UIImage *avatar;
@property (nonatomic) UIImage *avatarLarge;
@property (nonatomic) NSString *nameGroup;
@property (nonatomic) NSString *descriptionGroup;
@property (nonatomic) BOOL allowMessage;
@property (nonatomic) BOOL allowInvitation;
@property (nonatomic) BOOL allowInviteMemberAsContact;
@property (nonatomic) BOOL canCreate;
@property (nonatomic) BOOL keyboardHidden;

@property (nonatomic) GroupService *groupService;
@property (nonatomic) TLGroup *group;

@end

//
// Implementation: CreateGroupViewController
//

#undef LOG_TAG
#define LOG_TAG @"CreateGroupViewController"

@implementation CreateGroupViewController

#pragma mark - UIViewController

+ (void)initialize {
    DDLogVerbose(@"%@ initialize", LOG_TAG);
    
    DESIGN_AVATAR_PLACEHOLDER_COLOR = [UIColor colorWithRed:242./255. green:243./255. blue:245./255. alpha:1.0];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    DDLogVerbose(@"%@ initWithCoder: %@", LOG_TAG, coder);
    
    self = [super initWithCoder:coder];
    
    if (self) {
        _uiContacts = [[NSMutableArray alloc] init];
        _uiMembers = [[NSMutableArray alloc] init];
        _allowMessage = YES;
        _allowInvitation = YES;
        _allowInviteMemberAsContact = YES;
        _keyboardHidden = YES;
        
        _groupService = [[GroupService alloc] initWithTwinmeContext:self.twinmeContext delegate:self];
    }
    return self;
}

- (void)viewDidLoad {
    DDLogVerbose(@"%@ viewDidLoad", LOG_TAG);
    
    [super viewDidLoad];
    
    [self.groupService getContacts];
    [self initViews];
}

- (void)viewWillAppear:(BOOL)animated {
    DDLogVerbose(@"%@ viewWillAppear: %@", LOG_TAG, animated ? @"YES" : @"NO");
    
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    DDLogVerbose(@"%@ viewWillDisappear: %@", LOG_TAG, animated ? @"YES" : @"NO");
    
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}


#pragma mark - GroupServiceDelegate

- (void)onSetCurrentSpace:(nonnull TLSpace *)space {
    DDLogVerbose(@"%@ onSetCurrentSpace: %@", LOG_TAG, space);

}

- (void)onGetContacts:(NSArray *)contacts {
    DDLogVerbose(@"%@ onGetContacts: %@", LOG_TAG, contacts);
    
    for (TLContact *contact in contacts) {
        [self updateUIContact:contact avatar:nil];
    }
}

- (void)updateUIContact:(nonnull TLContact *)contact avatar:(nullable UIImage *)avatar {
    DDLogVerbose(@"%@ updateUIContact: %@", LOG_TAG, contact);
    
    UIContact *uiContact = nil;
    for (UIContact *lUIContact in self.uiContacts) {
        if ([lUIContact.contact.uuid isEqual:contact.uuid]) {
            uiContact = lUIContact;
            break;
        }
    }
    
    // TBD Sort using id order when name are equals
    if (uiContact)  {
        [self.uiContacts removeObject:uiContact];
        [uiContact setContact:contact];
    } else {
        uiContact = [[UIContact alloc] initWithContact:contact];
    }
    if (!avatar && [contact hasPeer]) {
        [self.groupService getImageWithContact:contact withBlock:^(UIImage *image) {
            [uiContact updateAvatar:image];
        }];
    } else {
        [uiContact updateAvatar:avatar];
    }
    
    BOOL added = NO;
    NSInteger count = self.uiContacts.count;
    for (NSInteger i = 0; i < count; i++) {
        UIContact *lUIContact = self.uiContacts[i];
        if ([lUIContact.name caseInsensitiveCompare:uiContact.name] == NSOrderedDescending) {
            [self.uiContacts insertObject:uiContact atIndex:i];
            added = YES;
            break;
        }
    }
    if (!added) {
        [self.uiContacts addObject:uiContact];
    }
}

- (void)onCreateGroup:(nonnull TLGroup *)group conversation:(nonnull id<TLGroupConversation>)conversation {
    DDLogVerbose(@"%@ onCreateGroup: %@ conversation:%@", LOG_TAG, group, conversation);
    
    self.group = group;
    
    [self finish];
}

- (void)onErrorLimitReached {
    DDLogVerbose(@"%@ onErrorLimitReached",LOG_TAG);
    
    AlertMessageView *alertMessageView = [[AlertMessageView alloc] init];
    alertMessageView.alertMessageViewDelegate = self;
    [alertMessageView initWithTitle:TwinmeLocalizedString(@"delete_account_view_controller_warning", nil) message:[NSString stringWithFormat:TwinmeLocalizedString(@"application_group_limit_reached %@", nil), [NSString convertWithLocale:[NSString stringWithFormat:@"%d",[TLConversationService MAX_GROUP_MEMBERS]]]]];
    [self.navigationController.view addSubview:alertMessageView];
    [alertMessageView showAlertView];
}

#pragma mark - AddGroupMemberDelegate

- (void)addGroupMemberViewController:(AddGroupMemberViewController *)addGroupMemberViewController didFinishPickingMembers:(NSMutableArray *)groupMembers {
    DDLogVerbose(@"%@ addGroupMemberViewController: %@ didFinishPickingMembers: %@", LOG_TAG, addGroupMemberViewController, groupMembers);
    
    self.uiMembers = groupMembers;
    
    if (self.uiMembers.count  > 0) {
        self.noMembersLabel.hidden = YES;
        self.noMembersAccessoryView.hidden = YES;
        self.inviteView.hidden = NO;
        self.membersCollectionView.hidden = NO;
        [self.membersCollectionView reloadData];
    } else {
        self.noMembersLabel.hidden = NO;
        self.noMembersAccessoryView.hidden = NO;
        self.inviteView.hidden = YES;
        self.membersCollectionView.hidden = YES;
    }
}

#pragma mark - UITextFieldDelegate

- (void)updatePermissions:(BOOL)allowInvitation allowMessage:(BOOL)allowMessage allowInviteMemberAsContact:(BOOL)allowInviteMemberAsContact {
    DDLogVerbose(@"%@ updatePermissions: %@ allowMessage: %@ allowInviteMemberAsContact: %@", LOG_TAG, allowInvitation ? @"YES":@"NO", allowMessage ? @"YES":@"NO", allowInviteMemberAsContact ? @"YES":@"NO");
    
    self.allowInvitation = allowInvitation;
    self.allowMessage = allowMessage;
    self.allowInviteMemberAsContact = allowInviteMemberAsContact;
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
        self.avatarLarge = info[UIImagePickerControllerEditedImage];
        self.avatar = [self.avatarLarge resizeImage];
        self.avatarView.image = self.avatarLarge;
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

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    DDLogVerbose(@"%@ numberOfSectionsInCollectionView: %@", LOG_TAG, collectionView);
    
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    DDLogVerbose(@"%@ collectionView: %@ numberOfItemsInSection: %ld", LOG_TAG, collectionView, (long)section);
    
    if (self.uiMembers.count <= MAX_GROUP_MEMBER) {
        return self.uiMembers.count;
    }
    
    return MAX_GROUP_MEMBER + 1;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ collectionView: %@ layout: %@ sizeForItemAtIndexPath: %@", LOG_TAG, collectionView, collectionViewLayout, indexPath);
    
    CGFloat heightCell = roundf(self.membersViewWidthConstraint.constant / 6);
    return CGSizeMake(heightCell, heightCell);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    DDLogVerbose(@"%@ collectionView: %@ layout: %@ minimumLineSpacingForSectionAtIndex: %ld", LOG_TAG, collectionView, collectionViewLayout, (long)section);
    
    return 0;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(nonnull UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    DDLogVerbose(@"%@ collectionView: %@ layout: %@ referenceSizeForHeaderInSection: %ld", LOG_TAG, collectionView, collectionViewLayout, (long)section);
    
    return CGSizeMake(0, 0);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ collectionView: %@ cellForItemAtIndexPath: %@", LOG_TAG, collectionView, indexPath);
    
    ShowMemberCell *showRoomMemberCell = [collectionView dequeueReusableCellWithReuseIdentifier:MEMBER_CELL_IDENTIFIER forIndexPath:indexPath];
    
    if (indexPath.row < MAX_GROUP_MEMBER) {
        UIContact *uiMember = self.uiMembers[indexPath.row];
        [showRoomMemberCell bindWithName:uiMember.name avatar:uiMember.avatar memberCount:self.uiMembers.count];
    } else {
        [showRoomMemberCell bindWithName:nil avatar:nil memberCount:self.uiMembers.count - MAX_GROUP_MEMBER];
    }
    return showRoomMemberCell;
}

#pragma mark - AlertMessageViewDelegate

- (void)didCloseAlertMessage:(nonnull AlertMessageView *)alertMessageView {
    DDLogVerbose(@"%@ didCloseAlertMessage: %@", LOG_TAG, alertMessageView);
    
    [alertMessageView closeAlertView];
}

- (void)didFinishCloseAlertMessageAnimation:(nonnull AlertMessageView *)alertMessageView {
    DDLogVerbose(@"%@ didFinishCloseAlertMessageAnimation: %@", LOG_TAG, alertMessageView);
    
    [alertMessageView removeFromSuperview];
    
    [self finish];
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
        
    NSString *updatedName =  [self.nameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (updatedName.length == 0) {
        updatedName = self.nameTextField.placeholder;
    }
    
    NSString *updatedDescription =  [self.descriptionTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([updatedDescription isEqualToString:TwinmeLocalizedString(@"side_menu_view_controller_about", nil)]) {
        updatedDescription = @"";
    }
    
    BOOL updated = ![updatedName isEqualToString:self.nameTextField.placeholder] || ![updatedDescription isEqualToString:self.descriptionGroup];
    updated = updated || self.descriptionGroup != nil;
    
    self.canCreate = updated;
        
    if (self.canCreate) {
        self.saveView.alpha = 1.0;
    } else {
        self.saveView.alpha = 0.5;
    }
}

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    [super initViews];
    
    self.view.backgroundColor = Design.WHITE_COLOR;
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)]];
    
    [self.editAvatarView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleUpdateAvatarTapGesture)]];
    self.editAvatarView.isAccessibilityElement = YES;
    
    self.avatarView.backgroundColor = DESIGN_AVATAR_PLACEHOLDER_COLOR;
    
    self.avatarPlaceholderImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.nameLabel.text = TwinmeLocalizedString(@"create_group_view_controller_title", nil);
    
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
    
    self.membersViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.membersViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.membersViewTopConstraint.constant *= Design.HEIGHT_RATIO;
        
    [self.membersView setBorder:Design.SEPARATOR_COLOR_GREY borderWidth:Design.SEPARATOR_HEIGHT width:self.membersViewWidthConstraint.constant  height:self.membersViewHeightConstraint.constant left:NO right:NO top:YES bottom:YES];
    self.membersView.userInteractionEnabled = YES;
    self.membersView.backgroundColor = Design.WHITE_COLOR;
    
    UITapGestureRecognizer *membersViewGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleInvitationTapGesture:)];
    [self.membersView addGestureRecognizer:membersViewGestureRecognizer];
    self.membersLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.membersLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.membersLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.membersLabel.font = Design.FONT_BOLD26;
    self.membersLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.membersLabel.text = TwinmeLocalizedString(@"group_member_view_controller_section_member", nil).uppercaseString;
    
    self.inviteViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.inviteViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.inviteViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    UITapGestureRecognizer *inviteViewGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleInvitationTapGesture:)];
    [self.inviteView addGestureRecognizer:inviteViewGestureRecognizer];
    
    self.inviteView.hidden = YES;
    
    self.inviteLabel.font = Design.FONT_BOLD28;
    self.inviteLabel.textColor = Design.MAIN_COLOR;
    self.inviteLabel.text = [NSString stringWithFormat:@"+ %@", TwinmeLocalizedString(@"add_group_member_view_controller_add", nil)];
    
    self.membersCollectionViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.membersCollectionViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    UICollectionViewFlowLayout* viewFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    [viewFlowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    [viewFlowLayout setMinimumInteritemSpacing:0];
    [viewFlowLayout setMinimumLineSpacing:0];
    CGFloat heightCell = roundf(self.membersViewWidthConstraint.constant / 6);
    [viewFlowLayout setItemSize:CGSizeMake(heightCell, heightCell)];
    
    [self.membersCollectionView setUserInteractionEnabled:NO];
    [self.membersCollectionView setCollectionViewLayout:viewFlowLayout];
    self.membersCollectionView.dataSource = self;
    self.membersCollectionView.backgroundColor = Design.WHITE_COLOR;
    [self.membersCollectionView registerNib:[UINib nibWithNibName:@"ShowMemberCell" bundle:nil] forCellWithReuseIdentifier:MEMBER_CELL_IDENTIFIER];
    self.membersCollectionView.hidden = YES;
    
    self.noMembersLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.noMembersLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.noMembersLabel.text = TwinmeLocalizedString(@"add_group_member_view_controller_title", nil);
    
    self.noMembersAccessoryViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.noMembersAccessoryViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.noMembersAccessoryView.tintColor = Design.ACCESSORY_COLOR;
    self.noMembersAccessoryView.image = [self.noMembersAccessoryView.image imageFlippedForRightToLeftLayoutDirection];
    
    self.settingsTitleLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.settingsTitleLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.settingsTitleLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.settingsTitleLabel.font = Design.FONT_BOLD26;
    self.settingsTitleLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.settingsTitleLabel.text = TwinmeLocalizedString(@"application_configuration", nil).uppercaseString;
    
    self.settingsViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.settingsViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.settingsViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    UITapGestureRecognizer *settingsViewGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSettingsTapGesture:)];
    [self.settingsView addGestureRecognizer:settingsViewGestureRecognizer];
    
    [self.settingsView setBorder:Design.SEPARATOR_COLOR_GREY borderWidth:Design.SEPARATOR_HEIGHT width:self.settingsViewWidthConstraint.constant height:self.settingsViewHeightConstraint.constant left:NO right:NO top:YES bottom:YES];
    
    self.settingsLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.settingsLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.settingsLabel.text = TwinmeLocalizedString(@"settings_view_controller_authorization_title", nil);
    self.settingsAccessoryViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.settingsAccessoryViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.settingsAccessoryView.tintColor = Design.ACCESSORY_COLOR;
    self.settingsAccessoryView.image = [self.settingsAccessoryView.image imageFlippedForRightToLeftLayoutDirection];
    
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
}

- (void)finish {
    DDLogVerbose(@"%@ finish", LOG_TAG);
    
    if (self.groupService) {
        [self.groupService dispose];
        self.groupService = nil;
    }
    
    if (self.group) {
        [self dismissViewControllerAnimated:YES completion:^{
            [self.navigationController popToRootViewControllerAnimated:YES];
            [self showGroupWithGroup:self.group];
        }];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)handleBackTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleBackTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        [self finish];
    }
}

- (void)handleUpdateAvatarTapGesture {
    DDLogVerbose(@"%@ handleUpdateAvatarTapGesture", LOG_TAG);
    
    [self openMenuPhoto];
}

- (void)handleInvitationTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleInvitationTapGesture: %@", LOG_TAG, sender);
    
    AddGroupMemberViewController *addGroupMemberViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AddGroupMemberViewController"];
    addGroupMemberViewController.addGroupMemberDelegate = self;
    [addGroupMemberViewController initWithMembers:self.uiMembers fromCreateGroup:YES];
    
    TwinmeNavigationController *navigationController = [[TwinmeNavigationController alloc] initWithRootViewController:addGroupMemberViewController];
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (void)handleSettingsTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleSettingsTapGesture: %@", LOG_TAG, sender);
    
    SettingsGroupViewController *settingsGroupViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SettingsGroupViewController"];
    settingsGroupViewController.delegate = self;
    [settingsGroupViewController initWithPermissions:self.allowInvitation allowMessage:self.allowMessage allowInviteMemberAsContact:self.allowInviteMemberAsContact];
    [self.navigationController pushViewController:settingsGroupViewController animated:YES];
}

- (void)handleSaveTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleSaveTapGesture: %@", LOG_TAG, sender);
    
    if (!self.canCreate) {
        return;
    }
    
    self.nameGroup = self.nameTextField.text;
    self.descriptionGroup = self.descriptionTextView.text;
    
    long permissions = ~0;
    permissions &= ~(1 << TLPermissionTypeUpdateMember);
    permissions &= ~(1 << TLPermissionTypeRemoveMember);
    permissions &= ~(1 << TLPermissionTypeResetConversation);
    if (!self.allowInvitation) {
        permissions &= ~(1 << TLPermissionTypeInviteMember);
    }
    if (!self.allowMessage) {
        permissions &= ~(1 << TLPermissionTypeSendMessage);
        permissions &= ~(1 << TLPermissionTypeSendAudio);
        permissions &= ~(1 << TLPermissionTypeSendVideo);
        permissions &= ~(1 << TLPermissionTypeSendImage);
        permissions &= ~(1 << TLPermissionTypeSendFile);
    }
    if (!self.allowInviteMemberAsContact) {
        permissions &= ~(1 << TLPermissionTypeSendTwincode);
    }
    
    NSMutableArray *contacts = [[NSMutableArray alloc] init];
    for (UIContact *contact in self.uiMembers) {
        [contacts addObject:contact.contact];
    }
    
    [self.groupService createGroupWithName:self.nameGroup description:self.descriptionGroup avatar:self.avatar avatarLarge:self.avatarLarge members:contacts permissions:permissions];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    DDLogVerbose(@"%@ keyboardWillShow: %@", LOG_TAG, notification);
    
    if (!self.keyboardHidden) {
        return;
    }
    
    self.keyboardHidden = NO;
    NSDictionary *info = [notification userInfo];
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    CGRect saveViewFrame = self.membersView.frame;
    CGRect frame = self.view.frame;
    CGFloat slidePosition = frame.size.height - (keyboardSize.height + saveViewFrame.origin.y + saveViewFrame.size.height + self.membersViewTopConstraint.constant);
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

- (void)openMenuPhoto {
    DDLogVerbose(@"%@ openMenuPhoto", LOG_TAG);

    [self dismissKeyboard];
    
    MenuPhotoView *menuPhotoView = [[MenuPhotoView alloc]init];
    menuPhotoView.menuPhotoViewDelegate = self;
    [self.navigationController.view addSubview:menuPhotoView];
    [menuPhotoView openMenu:YES];
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
        picker.popoverPresentationController.sourceRect = CGRectMake(size.width * 0.5, size.height * 0.2, size.width * 0.6, size.height * 0.7);
        picker.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionAny;
        [self presentViewController:picker animated:YES completion:nil];
    } else {
        [self presentViewController:picker animated:YES completion:nil];
    }
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
        
    [super updateFont];
    
    self.nameTextField.font = Design.FONT_REGULAR28;
    self.descriptionTextView.font = Design.FONT_REGULAR28;
    self.saveLabel.font = Design.FONT_BOLD36;
    self.counterNameLabel.font = Design.FONT_REGULAR26;
    self.counterDescriptionLabel.font = Design.FONT_REGULAR26;
    self.membersLabel.font = Design.FONT_BOLD26;
    self.inviteLabel.font = Design.FONT_BOLD28;
    self.settingsTitleLabel.font = Design.FONT_BOLD26;
    self.settingsLabel.font = Design.FONT_REGULAR34;
    self.noMembersLabel.font = Design.FONT_REGULAR34;
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    [super updateColor];
    
    self.settingsTitleLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.settingsLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.nameView.backgroundColor = Design.TEXTFIELD_BACKGROUND_COLOR;
    self.saveView.backgroundColor = Design.MAIN_COLOR;
    self.descriptionView.backgroundColor = Design.TEXTFIELD_BACKGROUND_COLOR;
    self.nameTextField.textColor = Design.FONT_COLOR_DEFAULT;
    self.nameTextField.tintColor = Design.FONT_COLOR_DEFAULT;
    self.counterDescriptionLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.counterNameLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.membersLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.inviteLabel.textColor = Design.MAIN_COLOR;
    self.settingsTitleLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.settingsLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.noMembersLabel.textColor = Design.FONT_COLOR_DEFAULT;
    
    self.nameTextField.attributedPlaceholder = [[NSAttributedString alloc]initWithString:TwinmeLocalizedString(@"create_group_view_controller_name_hint", nil) attributes:[NSDictionary dictionaryWithObject:Design.PLACEHOLDER_COLOR forKey:NSForegroundColorAttributeName]];
    
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
