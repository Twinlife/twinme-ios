/*
 *  Copyright (c) 2019-2024 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <Twinme/TLProfile.h>
#import <Twinme/TLSpace.h>
#import <Twinme/UIImage+Resize.h>

#import <Utils/NSString+Utils.h>

#import "EditSpaceViewController.h"
#import "MessageSettingsSpaceViewController.h"
#import "ContactsSpaceViewController.h"
#import <TwinmeCommon/TwinmeNavigationController.h>
#import "EditIdentityViewController.h"
#import "EditProfileViewController.h"
#import "SpaceAppearanceViewController.h"

#import "ColorCell.h"
#import "UICustomColor.h"

#import <TwinmeCommon/EditSpaceService.h>
#import <TwinmeCommon/SpaceSettingsService.h>

#import "AlertMessageView.h"
#import <TwinmeCommon/Design.h>
#import "DeviceAuthorization.h"
#import "InsideBorderView.h"
#import "UIColor+Hex.h"
#import "SwitchView.h"
#import "SpaceSetting.h"
#import "UIView+Toast.h"
#import <TwinmeCommon/MainViewController.h>
#import "UITemplateSpace.h"
#import "MenuPhotoView.h"
#import "DeleteSpaceConfirmView.h"

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static UIColor *DESIGN_AVATAR_PLACEHOLDER_COLOR;

static NSString *COLOR_CELL_IDENTIFIER = @"ColorCellIdentifier";

static CGFloat DESIGN_COLLECTION_CELL_HEIGHT = 78;
static CGFloat DESIGN_COLLECTION_CELL_WIDTH = 70;

//
// Interface: EditSpaceViewController ()
//

@interface EditSpaceViewController () <UITextFieldDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, EditSpaceServiceDelegate, UIAdaptivePresentationControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, CustomColorDelegate, SpaceSettingsServiceDelegate, MenuPhotoViewDelegate, ConfirmViewDelegate, AlertMessageViewDelegate>

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
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *colorViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *colorViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *colorViewTopConstraint;
@property (weak, nonatomic) IBOutlet UIView *colorView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *colorCollectionViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *colorCollectionViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UICollectionView *colorCollectionView;
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
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;

@property (nonatomic) NSString *nameSpace;
@property (nonatomic) NSString *descriptionSpace;
@property (nonatomic) BOOL canEdit;

@property (nonatomic) BOOL keyboardHidden;
@property (nonatomic) BOOL updated;
@property (nonatomic) UIImage *avatar;
@property (nonatomic) UIImage *updatedSpaceAvatar;
@property (nonatomic) UIImage *updatedSpaceLargeAvatar;

@property (nonatomic, nonnull) TLSpace *space;
@property (nonatomic, nonnull) EditSpaceService *editSpaceService;
@property (nonatomic, nonnull) SpaceSettingsService *spaceSettingsService;

@property (nonatomic, nullable) UITemplateSpace *templateSpace;
@property (nonatomic) NSMutableArray *colors;

@property (nonatomic) BOOL hasContacts;
@property (nonatomic) BOOL hasGroups;
@property (nonatomic) BOOL createSpace;
@property (nonatomic) BOOL initTemplateSpace;

@property (nonatomic) UICustomColor *selectedColor;

@end

//
// Implementation: EditSpaceViewController
//

#undef LOG_TAG
#define LOG_TAG @"EditSpaceViewController"

@implementation EditSpaceViewController

#pragma mark - UIViewController

+ (void)initialize {
    DDLogVerbose(@"%@ initialize", LOG_TAG);
    
    DESIGN_AVATAR_PLACEHOLDER_COLOR = [UIColor colorWithRed:242./255. green:243./255. blue:245./255. alpha:1.0];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    DDLogVerbose(@"%@ initWithCoder: %@", LOG_TAG, coder);
    
    self = [super initWithCoder:coder];
    
    if (self) {
        _hasContacts = NO;
        _hasGroups = NO;
        _createSpace = NO;
        _keyboardHidden = YES;
        _initTemplateSpace = NO;
        _colors = Design.SPACES_COLOR;
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
    
    [self updateSpace];
}

- (void)viewWillDisappear:(BOOL)animated {
    DDLogVerbose(@"%@ viewWillDisappear: %@", LOG_TAG, animated ? @"YES" : @"NO");
    
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)initWithSpace:(TLSpace *)space {
    DDLogVerbose(@"%@ initWithSpace: %@", LOG_TAG, space);
    
    self.space = space;
    
    if (!self.space) {
        self.createSpace = YES;
    }
    
    self.editSpaceService = [[EditSpaceService alloc]initWithTwinmeContext:self.twinmeContext delegate:self space:self.space];
    self.spaceSettingsService = [[SpaceSettingsService alloc]initWithTwinmeContext:self.twinmeContext delegate:self];
}

- (void)initWithTemplateSpace:(UITemplateSpace *)templateSpace {
    DDLogVerbose(@"%@ initWithTemplateSpace: %@", LOG_TAG, templateSpace);
    
    self.createSpace = YES;
    self.templateSpace = templateSpace;
    self.canEdit = YES;
    
    if ([self.templateSpace getColor]) {
        self.selectedColor = [[UICustomColor alloc]initWithColor:[self.templateSpace getColor]];
        for (UICustomColor *customColor in self.colors) {
            if ([customColor.color isEqual:self.selectedColor.color]) {
                [customColor setSelectedColor:YES];
            } else {
                [customColor setSelectedColor:NO];
            }
        }
    } else if (self.colors.count > 0) {
        UICustomColor *customColor = [self.colors objectAtIndex:0];
        [customColor setSelectedColor:YES];
    }
    
    self.editSpaceService = [[EditSpaceService alloc]initWithTwinmeContext:self.twinmeContext delegate:self space:nil];
    self.spaceSettingsService = [[SpaceSettingsService alloc]initWithTwinmeContext:self.twinmeContext delegate:self];
}

#pragma mark - SpaceServiceDelegate

- (void)onGetSpace:(nonnull TLSpace *)space avatar:(nullable UIImage *)avatar {
    DDLogVerbose(@"%@ onGetSpace: %@", LOG_TAG, space);
    
    if (!self.createSpace) {
        self.space = space;
        self.avatar = avatar;
        self.avatarView.image = avatar;
    }
    
    [self updateSpace];
}

- (void)onGetContacts:(NSArray *)contacts {
    DDLogVerbose(@"%@ onGetContacts: %@", LOG_TAG, contacts);
    
    self.hasContacts = contacts.count > 0;
}

- (void)onGetGroups:(NSArray *)groups {
    DDLogVerbose(@"%@ onGetGroups: %@", LOG_TAG, groups);
    
    self.hasGroups = groups.count > 0;
}

- (void)onCreateSpace:(TLSpace *)space {
    DDLogVerbose(@"%@ onCreateSpace: %@", LOG_TAG, space);
    
    if (self.createSpace) {
        TLSpaceSettings *spaceSettings = space.settings;
        if ([space.settings getBooleanWithName:PROPERTY_DEFAULT_APPEARANCE_SETTINGS defaultValue:YES]) {
            spaceSettings = self.twinmeContext.defaultSpaceSettings;
        }
        
        if (![Design.MAIN_STYLE isEqualToString:spaceSettings.style]) {
            [Design setMainColor:spaceSettings.style];
        }
        [self setNavigationBarStyle];
        
        [CATransaction begin];
        [CATransaction setCompletionBlock:^{
            ApplicationDelegate *delegate = (ApplicationDelegate *)[[UIApplication sharedApplication] delegate];
            MainViewController *mainViewController = delegate.mainViewController;
            TwinmeNavigationController *selectedNavigationController = mainViewController.selectedViewController;
            EditProfileViewController *editProfileViewController = (EditProfileViewController *)[[UIStoryboard storyboardWithName:@"iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"EditProfileViewController"];
            [editProfileViewController initWithSpace:space templateSpace:self.templateSpace];
            [selectedNavigationController pushViewController:editProfileViewController animated:YES];
        }];
        
        [self.navigationController popToRootViewControllerAnimated:NO];

        [CATransaction commit];
    }
    
    [self finish];
}

- (void)onUpdateSpace:(TLSpace *)space {
    DDLogVerbose(@"%@ onUpdateSpace: %@", LOG_TAG, space);

    if ([self.currentSpace.uuid isEqual:space.uuid]) {
        TLSpaceSettings *spaceSettings = space.settings;
        if ([space.settings getBooleanWithName:PROPERTY_DEFAULT_APPEARANCE_SETTINGS defaultValue:YES]) {
            spaceSettings = self.twinmeContext.defaultSpaceSettings;
        }
        
        if (![Design.MAIN_STYLE isEqualToString:spaceSettings.style]) {
            [Design setMainColor:spaceSettings.style];
        }
        [self setNavigationBarStyle];
    }
    
    [self finish];
}

- (void)onUpdateSpaceAvatar:(UIImage *)avatar {
    DDLogVerbose(@"%@ onUpdateSpaceAvatar: %@", LOG_TAG, avatar);
    
    if (!self.createSpace) {
        self.avatarView.image = avatar;
    }
}

- (void)onDeleteSpace:(nonnull NSUUID *)spaceId {
    DDLogVerbose(@"%@ onDeleteSpace: %@", LOG_TAG, spaceId);
    
    [self finish];
}

- (void)onCreateProfile:(TLProfile *)profile {
    DDLogVerbose(@"%@ onCreateProfile: %@", LOG_TAG, profile);
    
    [self updateSpace];
}

- (void)onUpdateProfile:(TLProfile *)profile {
    DDLogVerbose(@"%@ onUpdateProfile: %@", LOG_TAG, profile);
    
    [self updateSpace];
}

#pragma mark - SpaceSettingsServiceDelegate

- (void)onUpdateSpaceDefaultSettings:(nonnull TLSpaceSettings *)spaceSettings {
    DDLogVerbose(@"%@ onUpdateSpaceDefaultSettings: %@", LOG_TAG, spaceSettings);
    
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    DDLogVerbose(@"%@ numberOfSectionsInCollectionView: %@", LOG_TAG, collectionView);
    
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    DDLogVerbose(@"%@ collectionView: %@ numberOfItemsInSection: %ld", LOG_TAG, collectionView, (long)section);
    
    return self.colors.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ collectionView: %@ layout: %@ sizeForItemAtIndexPath: %@", LOG_TAG, collectionView, collectionViewLayout, indexPath);
    
    CGFloat heightCell = DESIGN_COLLECTION_CELL_HEIGHT * Design.HEIGHT_RATIO;
    CGFloat widthCell = DESIGN_COLLECTION_CELL_WIDTH * Design.WIDTH_RATIO;
    return CGSizeMake(widthCell, heightCell);
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
    
    ColorCell *colorCell = [collectionView dequeueReusableCellWithReuseIdentifier:COLOR_CELL_IDENTIFIER forIndexPath:indexPath];
    colorCell.customColorDelegate = self;
    
    UICustomColor *uiColor = self.colors[indexPath.row];
    [colorCell bindWithColor:uiColor];
    
    return colorCell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ collectionView: %@ didSelectItemAtIndexPath: %@", LOG_TAG, collectionView, indexPath);
    
}

#pragma mark - CustomColorDelegate

- (void)didSelectCustomColor:(UICustomColor *)customColor {
    DDLogVerbose(@"%@ didSelectCustomColor: %@", LOG_TAG, customColor);
    
    self.selectedColor = customColor;
    
    for (UICustomColor *customColor in self.colors) {
        if ([customColor.color isEqual:self.selectedColor.color]) {
            [customColor setSelectedColor:YES];
        } else {
            [customColor setSelectedColor:NO];
        }
    }
    
    if (!self.selectedColor.color && self.colors.count > 0) {
        UICustomColor *customColor = [self.colors objectAtIndex:0];
        [customColor setSelectedColor:YES];
    }
    
    [self.colorCollectionView reloadData];
    
    if (self.selectedColor.color) {
        self.saveView.backgroundColor = [UIColor colorWithHexString:self.selectedColor.color alpha:1.0];
    } else {
        self.saveView.backgroundColor = Design.MAIN_COLOR;
    }
    
    if (self.selectedColor.color && !self.updatedSpaceAvatar) {
        self.avatarView.backgroundColor = [UIColor colorWithHexString:self.selectedColor.color alpha:1.0];
    } else {
        self.avatarView.backgroundColor = DESIGN_AVATAR_PLACEHOLDER_COLOR;
    }
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
    
    if ([textView.text isEqualToString:TwinmeLocalizedString(@"application_description", nil)]) {
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
        textView.text = TwinmeLocalizedString(@"application_description", nil);
        textView.textColor = Design.PLACEHOLDER_COLOR;
    }
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)pickerController didFinishPickingMediaWithInfo:(NSDictionary *)info {
    DDLogVerbose(@"%@ imagePickerController: %@ didFinishPickingMediaWithInfo: %@", LOG_TAG, pickerController, info);
    
    self.navigationController.navigationBarHidden = YES;
    
    [pickerController dismissViewControllerAnimated:YES completion:^{
        self.updatedSpaceLargeAvatar = info[UIImagePickerControllerEditedImage];
        self.updatedSpaceAvatar = [self.updatedSpaceLargeAvatar resizeImage];
        self.avatarView.image = self.updatedSpaceLargeAvatar;
        
        [self setUpdated];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)pickerController {
    DDLogVerbose(@"%@ imagePickerControllerDidCancel: %@", LOG_TAG, pickerController);
    
    self.navigationController.navigationBarHidden = YES;
    
    [pickerController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - ConfirmViewDelegate

- (void)didTapConfirm:(nonnull AbstractConfirmView *)abstractConfirmView {
    DDLogVerbose(@"%@ didTapConfirm: %@", LOG_TAG, abstractConfirmView);
    
    [self deleteSpace];
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

- (void)setUpdated {
    DDLogVerbose(@"%@ setUpdated", LOG_TAG);
    
    self.nameSpace = self.nameTextField.text;
    
    if ([self.descriptionTextView.text isEqualToString:TwinmeLocalizedString(@"application_description", nil)]) {
        self.descriptionSpace = @"";
    } else {
        self.descriptionSpace = self.descriptionTextView.text;
    }
    
    if (([self.nameSpace isEqualToString:@""] || [self.nameSpace isEqualToString:self.space.settings.name])
        && ([self.descriptionSpace isEqualToString:self.space.settings.objectDescription])
        && !self.updatedSpaceAvatar) {
        self.canEdit = NO;
    } else {
        self.canEdit = YES;
    }
    
    if (self.canEdit) {
        self.saveView.alpha = 1.0;
    } else {
        self.saveView.alpha = 0.5;
    }
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
    DDLogVerbose(@"%@ menuPhotoDidSelectCamera", LOG_TAG);
 
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
    
    self.avatarView.backgroundColor = DESIGN_AVATAR_PLACEHOLDER_COLOR;
    
    self.nameLabel.text = TwinmeLocalizedString(@"settings_space_view_controller_space_category_title", nil);
    
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
    self.nameTextField.placeholder = TwinmeLocalizedString(@"create_space_view_controller_space_hint", nil);
    [self.nameTextField setReturnKeyType:UIReturnKeyDone];
    self.nameTextField.delegate = self;
    [self.nameTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    self.counterNameLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.counterNameLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    
    self.counterNameLabel.font = Design.FONT_REGULAR26;
    self.counterNameLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.counterNameLabel.text = [NSString stringWithFormat:@"0/%d", MAX_NAME_LENGTH];
    
    self.colorViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.colorViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.colorViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.colorView.backgroundColor = Design.TEXTFIELD_BACKGROUND_COLOR;
    self.colorView.layer.cornerRadius = Design.CONTAINER_RADIUS;
    self.colorView.clipsToBounds = YES;
    self.colorView.userInteractionEnabled = NO;
    
    self.colorCollectionViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.colorCollectionViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
        
    self.colorCollectionView.dataSource = self;
    self.colorCollectionView.delegate = self;
    self.colorCollectionView.backgroundColor = [UIColor clearColor];
    [self.colorCollectionView registerNib:[UINib nibWithNibName:@"ColorCell" bundle:nil] forCellWithReuseIdentifier:COLOR_CELL_IDENTIFIER];
    
    UICollectionViewFlowLayout* viewFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    [viewFlowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    [viewFlowLayout setMinimumInteritemSpacing:0];
    [viewFlowLayout setMinimumLineSpacing:0];
    CGFloat heightCell = DESIGN_COLLECTION_CELL_HEIGHT * Design.HEIGHT_RATIO;
    CGFloat widthCell = DESIGN_COLLECTION_CELL_WIDTH * Design.WIDTH_RATIO;
    [viewFlowLayout setItemSize:CGSizeMake(widthCell, heightCell)];
    
    [self.colorCollectionView setCollectionViewLayout:viewFlowLayout];
    [self.colorCollectionView reloadData];
    
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
    self.descriptionTextView.text = TwinmeLocalizedString(@"application_description", nil);
    self.descriptionTextView.textContainer.lineFragmentPadding = 0;
    self.descriptionTextView.textContainerInset = UIEdgeInsetsZero;
    
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
    self.saveView.isAccessibilityElement = YES;
    self.saveView.accessibilityLabel = TwinmeLocalizedString(@"application_save", nil);
    self.saveView.layer.cornerRadius = Design.CONTAINER_RADIUS;
    self.saveView.clipsToBounds = YES;
    [self.saveView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSaveTapGesture:)]];
    
    self.saveLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.saveLabel.font = Design.FONT_BOLD36;
    self.saveLabel.textColor = [UIColor whiteColor];
    self.saveLabel.text = TwinmeLocalizedString(@"application_save", nil);
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture)];
    [self.view addGestureRecognizer:tapGesture];
    
    self.removeViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.removeView.backgroundColor = Design.BACKGROUND_COLOR_WHITE_OPACITY11;
    UITapGestureRecognizer *removeViewGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleRemoveTapGesture:)];
    [self.removeView addGestureRecognizer:removeViewGestureRecognizer];
    
    self.removeLabel.font = Design.FONT_REGULAR34;
    self.removeLabel.textColor = Design.FONT_COLOR_RED;
    self.removeLabel.text = TwinmeLocalizedString(@"application_delete", nil);
    
    self.messageLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.messageLabelWidthConstraint.constant *= Design.WIDTH_RATIO;

    if (self.space) {
        self.messageLabelTopConstraint.constant = self.removeViewHeightConstraint.constant;
        self.descriptionViewTopConstraint.constant -= (self.colorViewHeightConstraint.constant + self.colorViewTopConstraint.constant);
    }
    
    self.messageLabel.font = Design.FONT_REGULAR32;
    self.messageLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.messageLabel.text = TwinmeLocalizedString(@"create_space_view_controller_message", nil);
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

- (void)handleUpdateAvatarTapGesture {
    DDLogVerbose(@"%@ handleUpdateAvatarTapGesture", LOG_TAG);
    
    [self openMenuPhoto];
}

- (void)handleSaveTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleSaveTapGesture: %@", LOG_TAG, sender);
    
    if (!self.canEdit) {
        return;
    }
        
    [self saveSpace];
}

- (void)handleRemoveTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleRemoveTapGesture: %@", LOG_TAG, sender);
        
    if (sender.state == UIGestureRecognizerStateEnded) {
        
        ApplicationDelegate *delegate = (ApplicationDelegate *)[[UIApplication sharedApplication] delegate];
        MainViewController *mainViewController = delegate.mainViewController;
        if ([mainViewController numberSpaces:NO] < 2 && !self.space.settings.isSecret) {
            AlertMessageView *alertMessageView = [[AlertMessageView alloc] init];
            alertMessageView.alertMessageViewDelegate = self;
            [alertMessageView initWithTitle:TwinmeLocalizedString(@"delete_account_view_controller_warning", nil) message:TwinmeLocalizedString(@"edit_space_view_controller_delete_only_one_space_message", nil)];
            [self.tabBarController.view addSubview:alertMessageView];
            [alertMessageView showAlertView];
            
            return;
        }
        
        if ([self.twinmeContext isDefaultSpace:self.space]) {
            TLSpace *nextDefaultSpace = [mainViewController getNextDefaultSpace:self.space];
            
            if (!nextDefaultSpace) {
                return;
            }
            
            [self.editSpaceService setDefaultSpace:nextDefaultSpace];
        }
        
        NSMutableString *deleteTitle = [[NSMutableString alloc] initWithString:TwinmeLocalizedString(@"application_are_you_sure", nil)];
        [deleteTitle appendString:@"\n"];
        [deleteTitle appendString:TwinmeLocalizedString(@"application_operation_irreversible", nil)];
        
        DeleteSpaceConfirmView *deleteSpaceConfirmView = [[DeleteSpaceConfirmView alloc] init];
        deleteSpaceConfirmView.confirmViewDelegate = self;
        [deleteSpaceConfirmView initWithTitle:deleteTitle message:TwinmeLocalizedString(@"edit_space_view_controller_delete_message", nil) spaceName:self.space.settings.name spaceStyle:self.space.settings.style avatar:self.avatar icon:[UIImage imageNamed:@"ActionBarDelete"]];
        [self.view addSubview:deleteSpaceConfirmView];
        [deleteSpaceConfirmView showConfirmView];
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
        picker.popoverPresentationController.sourceRect = CGRectMake(size.width * 0.5, size.height * 0.2, size.width * 0.6, size.height * 0.7);
        picker.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionAny;
        [self presentViewController:picker animated:YES completion:nil];
    } else {
        [self presentViewController:picker animated:YES completion:nil];
    }
}

- (void)finish {
    DDLogVerbose(@"%@ finish", LOG_TAG);
    
    [self.editSpaceService dispose];
    [self.spaceSettingsService dispose];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)saveSpace {
    DDLogVerbose(@"%@ saveSpace", LOG_TAG);
    
    if (self.space) {
        TLSpaceSettings *spaceSettings = [[TLSpaceSettings alloc] initWithSettings:self.space.settings];
        spaceSettings.name = self.nameTextField.text;
        
        if (![self.descriptionTextView.text isEqualToString:TwinmeLocalizedString(@"application_description", nil)]) {
            [spaceSettings setObjectDescription:self.descriptionTextView.text];
        } else {
            [spaceSettings setObjectDescription:nil];
        }
        
        [self.editSpaceService updateSpace:spaceSettings avatar:self.updatedSpaceAvatar largeAvatar:self.updatedSpaceLargeAvatar];
    } else {
        NSString *spaceDescription;
        if (![self.descriptionTextView.text isEqualToString:TwinmeLocalizedString(@"application_description", nil)]) {
            spaceDescription = self.descriptionTextView.text;
        }
        
        TLSpaceSettings *defaultSettings = [self.twinmeContext defaultSpaceSettings];
        TLSpaceSettings *settings = [[TLSpaceSettings alloc] initWithName:self.nameTextField.text settings:defaultSettings];
        
        if (self.selectedColor.color) {
            [settings setStyle:self.selectedColor.color];
            
            ApplicationDelegate *delegate = (ApplicationDelegate *)[[UIApplication sharedApplication] delegate];
            MainViewController *mainViewController = delegate.mainViewController;
            
            if ([mainViewController numberSpaces:NO] == 0) {
                [defaultSettings setStyle:self.selectedColor.color];
                [self.spaceSettingsService updateDefaultSpaceSettings:defaultSettings];
            } else {
                [settings setBooleanWithName:PROPERTY_DEFAULT_APPEARANCE_SETTINGS value:NO];
            }
        }
        
        [self.editSpaceService createSpace:self.nameTextField.text spaceAvatar:self.updatedSpaceAvatar spaceLargeAvatar:self.updatedSpaceLargeAvatar descriptionSpace:spaceDescription spaceSettings:settings];
    }
}

- (void)deleteSpace {
    DDLogVerbose(@"%@ deleteSpace", LOG_TAG);
    
    ApplicationDelegate *delegate = (ApplicationDelegate *)[[UIApplication sharedApplication] delegate];
    MainViewController *mainViewController = delegate.mainViewController;
        
    if ([self.twinmeContext isDefaultSpace:self.space]) {
        TLSpace *nextDefaultSpace = [mainViewController getNextDefaultSpace:self.space];
        
        if (!nextDefaultSpace) {
            return;
        }
        
        [self.editSpaceService setDefaultSpace:nextDefaultSpace];
    }
    
    [self.editSpaceService deleteSpace];
}

- (void)updateSpace {
    DDLogVerbose(@"%@ updateSpace", LOG_TAG);
    
    if (self.space) {
        self.colorView.hidden = YES;
        self.colorCollectionView.hidden = YES;
        self.nameTextField.text = self.space.settings.name;
        
        if (self.space.settings.objectDescription && ![self.space.settings.objectDescription isEqualToString:@""]) {
            self.descriptionTextView.text = self.space.settings.objectDescription;
            self.descriptionTextView.textColor = Design.FONT_COLOR_DEFAULT;
        }
        self.removeView.hidden = NO;
        
        ApplicationDelegate *delegate = (ApplicationDelegate *)[[UIApplication sharedApplication] delegate];
        MainViewController *mainViewController = delegate.mainViewController;
        if ([mainViewController numberSpaces:NO] < 2 && !self.space.settings.isSecret) {
            self.removeView.alpha = 0.5;
        } else {
            self.removeView.alpha = 1.0;
        }
    } else if (self.templateSpace && !self.initTemplateSpace) {
        self.initTemplateSpace = YES;
        self.removeView.hidden = YES;
        self.colorView.hidden = NO;
        self.colorCollectionView.hidden = NO;
        if (self.templateSpace.templateType != TemplateTypeOther) {
            self.nameTextField.text = [self.templateSpace getSpace];
        }
        
        if ([self.templateSpace getImage]) {
            self.avatarView.image = [self.templateSpace getImage];
            self.avatarView.backgroundColor = [UIColor clearColor];
            
            if ([self.templateSpace getImageUrl]) {
                NSURL *url = [NSURL URLWithString:[self.templateSpace getImageUrl]];
                NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
                NSURLSessionConfiguration *urlSessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
                NSURLSession *urlSession = [NSURLSession sessionWithConfiguration:urlSessionConfiguration delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
                NSURLSessionDataTask *urlSessionDataTask = [urlSession dataTaskWithRequest:urlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                    if (!error) {
                        UIImage *image = [UIImage imageWithData:data];
                        if (image) {
                            self.avatarView.image = image;
                            self.updatedSpaceLargeAvatar = image;
                            self.updatedSpaceAvatar = [self.templateSpace getImage];
                        }
                    }
                }];
                [urlSessionDataTask resume];
            }
        }
    } else if (self.createSpace) {
        self.removeView.hidden = YES;
        self.colorView.hidden = NO;
        self.colorCollectionView.hidden = NO;
    }
    
    if (self.canEdit) {
        self.saveView.alpha = 1.0;
    } else {
        self.saveView.alpha = 0.5;
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
    
    [super updateFont];
    
    self.nameTextField.font = Design.FONT_REGULAR28;
    self.descriptionTextView.font = Design.FONT_REGULAR28;
    self.saveLabel.font = Design.FONT_BOLD36;
    self.counterNameLabel.font = Design.FONT_REGULAR26;
    self.counterDescriptionLabel.font = Design.FONT_REGULAR26;
    self.removeLabel.font = Design.FONT_REGULAR34;
    self.messageLabel.font = Design.FONT_REGULAR32;
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    [super updateColor];
    
    self.view.backgroundColor = Design.WHITE_COLOR;
    
    self.colorView.backgroundColor = Design.TEXTFIELD_BACKGROUND_COLOR;
    
    self.removeView.backgroundColor = Design.BACKGROUND_COLOR_WHITE_OPACITY11;
    self.removeLabel.textColor = Design.DELETE_COLOR_RED;
    
    self.nameView.backgroundColor = Design.TEXTFIELD_BACKGROUND_COLOR;
    self.nameTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:TwinmeLocalizedString(@"create_space_view_controller_space_hint", nil) attributes:[NSDictionary dictionaryWithObject:Design.PLACEHOLDER_COLOR forKey:NSForegroundColorAttributeName]];
    
    if (self.selectedColor.color) {
        self.saveView.backgroundColor = [UIColor colorWithHexString:self.selectedColor.color alpha:1.0];
    } else {
        self.saveView.backgroundColor = Design.MAIN_COLOR;
    }
    
    if (self.selectedColor.color && !self.updatedSpaceAvatar) {
        self.avatarView.backgroundColor = [UIColor colorWithHexString:self.selectedColor.color alpha:1.0];
    } else {
        self.avatarView.backgroundColor = DESIGN_AVATAR_PLACEHOLDER_COLOR;
    }
    
    self.descriptionView.backgroundColor = Design.TEXTFIELD_BACKGROUND_COLOR;
    self.nameTextField.textColor = Design.FONT_COLOR_DEFAULT;
    self.nameTextField.tintColor = Design.FONT_COLOR_DEFAULT;
    self.counterDescriptionLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.counterNameLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.messageLabel.textColor = Design.FONT_COLOR_DEFAULT;
    
    if ([self.descriptionTextView.text isEqualToString:TwinmeLocalizedString(@"application_description", nil)]) {
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

- (void)setNavigationBarStyle {
    DDLogVerbose(@"%@ setNavigationBarStyle", LOG_TAG);
    
    TwinmeNavigationController *navigationController = (TwinmeNavigationController *) self.navigationController;
    [navigationController setNavigationBarStyle];
}

@end
