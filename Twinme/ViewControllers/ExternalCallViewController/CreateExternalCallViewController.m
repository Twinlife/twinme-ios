/*
 *  Copyright (c) 2023-2024 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <Twinme/TLProfile.h>
#import <Twinme/TLCallReceiver.h>
#import <Twinme/TLSchedule.h>
#import <Twinme/TLSpace.h>
#import <Twinme/UIImage+Resize.h>

#import "CreateExternalCallViewController.h"
#import "InvitationExternalCallViewController.h"
#import "TransferCallViewController.h"

#import <Utils/NSString+Utils.h>

#import <TwinmeCommon/Design.h>
#import "SwitchView.h"
#import "MenuCallCapabilitiesView.h"
#import "MenuDateTimeView.h"
#import "DeviceAuthorization.h"
#import <TwinmeCommon/ApplicationDelegate.h>
#import <TwinmeCommon/MainViewController.h>
#import <TwinmeCommon/TwinmeNavigationController.h>
#import "MenuPhotoView.h"

#import <TwinmeCommon/CallReceiverService.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static UIColor *DESIGN_AVATAR_PLACEHOLDER_COLOR;

//
// Interface: CreateExternalCallViewController ()
//

@interface CreateExternalCallViewController ()<UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextViewDelegate, CallReceiverServiceDelegate, SwitchViewDelegate, MenuCallCapabilitiesDelegate, MenuDateTimeViewDelegate, UIAdaptivePresentationControllerDelegate, MenuPhotoViewDelegate>

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
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *settingsViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *settingsViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *settingsViewTopConstraint;
@property (weak, nonatomic) IBOutlet InsideBorderView *settingsView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *settingsLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *settingsLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *settingsLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *settingsAccessoryViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *settingsAccessoryViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *settingsAccessoryView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *limitedViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *limitedViewWidthConstraint;
@property (weak, nonatomic) IBOutlet InsideBorderView *limitedView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *limitedLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *limitedLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *limitedLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *limitedSwitchTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *limitedSwitchHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *limitedSwitchWidthConstraint;
@property (weak, nonatomic) IBOutlet SwitchView *limitedSwitch;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *startViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *startViewWidthConstraint;
@property (weak, nonatomic) IBOutlet InsideBorderView *startView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *startLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *startLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *startLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *startDateViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *startDateViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *startDateViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet UIView *startDateView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *startDateLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *startDateLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *startDateLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *startHourViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *startHourViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *startHourViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet UIView *startHourView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *startHourLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *startHourLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *startHourLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *endViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *endViewWidthConstraint;
@property (weak, nonatomic) IBOutlet InsideBorderView *endView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *endLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *endLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *endLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *endDateViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *endDateViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *endDateViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet UIView *endDateView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *endDateLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *endDateLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *endDateLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *endHourViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *endHourViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *endHourViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet UIView *endHourView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *endHourLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *endHourLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *endHourLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *saveViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *saveViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *saveViewWidthConstraint;
@property (weak, nonatomic) IBOutlet UIView *saveView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *saveLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet UILabel *saveLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;

@property (nonatomic) BOOL keyboardHidden;
@property (nonatomic) BOOL updated;
@property (nonatomic) BOOL creatingInProgress;
@property (nonatomic) BOOL showOnboardingView;
@property (nonatomic) UIImage *updatedCallReceiverAvatar;
@property (nonatomic) UIImage *updatedCallReceiverLargeAvatar;

@property (nonatomic) CallReceiverService *callReceiverService;
@property (nonatomic) TLCallReceiver *callReceiver;

@property (nonatomic) TLDate *scheduleStartDate;
@property (nonatomic) TLTime *scheduleStartTime;
@property (nonatomic) TLDate *scheduleEndDate;
@property (nonatomic) TLTime *scheduleEndTime;

@property (nonatomic) BOOL scheduleEnable;
@property (nonatomic) BOOL allowVoiceCall;
@property (nonatomic) BOOL allowVideoCall;
@property (nonatomic) BOOL allowGroupCall;

@end

//
// Implementation: CreateExternalCallViewController
//

#undef LOG_TAG
#define LOG_TAG @"CreateExternalCallViewController"

@implementation CreateExternalCallViewController

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
        _isTransfert = NO;
        _creatingInProgress = NO;
        _keyboardHidden = YES;
        _showOnboardingView = NO;
        _scheduleEnable = NO;
        _allowVoiceCall = YES;
        _allowVideoCall = YES;
        _allowGroupCall = NO;
        _callReceiverService = [[CallReceiverService alloc] initWithTwinmeContext:self.twinmeContext delegate:self];
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

#pragma mark - CallReceiverServiceDelegate

- (void)onCreateCallReceiver:(nonnull TLCallReceiver *)callReceiver {
    DDLogVerbose(@"%@ onCreateCallReceiver: %@", LOG_TAG, callReceiver);
    
    self.callReceiver = callReceiver;
    [self finish];
}

- (void)onGetCallReceiver:(nullable TLCallReceiver *)callReceiver {
    DDLogVerbose(@"%@ onGetCallReceiver: %@", LOG_TAG, callReceiver);
    
}

- (void)onGetCallReceivers:(nonnull NSArray<TLCallReceiver *> *)callReceiver {
    DDLogVerbose(@"%@ onGetCallReceivers: %@", LOG_TAG, callReceiver);
    
}

- (void)onUpdateCallReceiver:(TLCallReceiver *)callReceiver {
    DDLogVerbose(@"%@ onUpdateCallReceiver: %@", LOG_TAG, callReceiver);
    
}

- (void)onChangeCallReceiverTwincode:(nonnull TLCallReceiver *)callReceiver {
    DDLogVerbose(@"%@ onChangeCallReceiverTwincode: %@", LOG_TAG, callReceiver);
    
}

- (void)onUpdateCallReceiverAvatar:(UIImage *)avatar {
    DDLogVerbose(@"%@ onUpdateCallReceiverAvatar: %@", LOG_TAG, avatar);
    
}

- (void)onDeleteCallReceiver:(nonnull NSUUID *)callReceiverId {
    DDLogVerbose(@"%@ onDeleteCallReceiver: %@", LOG_TAG, callReceiverId);
    
}

- (void)onGetTwincodeURI:(nonnull TLTwincodeURI *)uri {
    DDLogVerbose(@"%@ onGetTwincodeURI: %@", LOG_TAG, uri);

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
    
    if ([textField.text isEqual:@""]) {
        self.updated = NO;
        self.saveView.alpha = 0.5;
    } else {
        self.updated = YES;
        self.saveView.alpha = 1.f;
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
    
    self.counterDescriptionLabel.text = [NSString stringWithFormat:@"%lu/%d", (unsigned long)self.descriptionTextView.text.length, MAX_DESCRIPTION_LENGTH];
}

- (void)textViewDidChange:(UITextView *)textView {
    DDLogVerbose(@"%@ textViewDidChange: %@", LOG_TAG, textView);
    
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
        
        self.updatedCallReceiverLargeAvatar = info[UIImagePickerControllerEditedImage];
        self.updatedCallReceiverAvatar = [self.updatedCallReceiverLargeAvatar resizeImage];
        self.avatarView.image = self.updatedCallReceiverLargeAvatar;
        self.avatarPlaceholderImageView.hidden = YES;
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

#pragma mark - MenuSelectValueDelegate

- (void)menuDidClosed:(MenuCallCapabilitiesView *)menuCallCapabilitiesView allowVoiceCall:(BOOL)allowVoiceCall allowVideoCall:(BOOL)allowVideoCall allowGroupCall:(BOOL)allowGroupCall {
    DDLogVerbose(@"%@ menuDidClosed", LOG_TAG);

    [menuCallCapabilitiesView removeFromSuperview];
    
    self.allowVoiceCall = allowVoiceCall;
    self.allowVideoCall = allowVideoCall;
    self.allowGroupCall = allowGroupCall;
    
    [self updateCallCapabilities];
}

#pragma mark - MenuDateTimeDelegate

- (void)menuDateTimeDidClosed:(MenuDateTimeView *)menuDateTimeView menuDateTimeType:(MenuDateTimeType)menuDateTimeType date:(NSDate *)date {
    DDLogVerbose(@"%@ menuDateTimeDidClosed", LOG_TAG);
    
    [menuDateTimeView removeFromSuperview];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSCalendarUnit calendarUnit = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute;
    NSDateComponents *dateComponents = [calendar components:calendarUnit fromDate:date];
    
    if (menuDateTimeType == MenuDateTimeTypeStartDate || menuDateTimeType == MenuDateTimeTypeStartHour) {
        self.scheduleStartDate = [[TLDate alloc]initWithYear:(int)dateComponents.year month:(int)dateComponents.month day:(int)dateComponents.day];
        self.scheduleStartTime = [[TLTime alloc]initWithHour:(int)dateComponents.hour minute:(int)dateComponents.minute];
    } else if (menuDateTimeType == MenuDateTimeTypeEndDate || menuDateTimeType == MenuDateTimeTypeEndHour) {
        self.scheduleEndDate = [[TLDate alloc]initWithYear:(int)dateComponents.year month:(int)dateComponents.month day:(int)dateComponents.day];
        self.scheduleEndTime = [[TLTime alloc]initWithHour:(int)dateComponents.hour minute:(int)dateComponents.minute];
    }
    
    if ([self.scheduleStartDate compare:self.scheduleEndDate] ==  NSOrderedDescending) {
        NSDateComponents *startDateComponents = [[NSDateComponents alloc] init];
        startDateComponents.day = self.scheduleStartDate.day;
        startDateComponents.month = self.scheduleStartDate.month;
        startDateComponents.year = self.scheduleStartDate.year;
        startDateComponents.hour = self.scheduleStartTime.hour;
        startDateComponents.minute = self.scheduleStartTime.minute;
        
        NSDate *startDate = [calendar dateFromComponents:startDateComponents];
        NSDate *endDate = [calendar dateByAddingUnit:NSCalendarUnitHour value:1 toDate:startDate options:NSCalendarWrapComponents];
        dateComponents = [calendar components:calendarUnit fromDate:endDate];
        self.scheduleEndDate = [[TLDate alloc]initWithYear:(int)dateComponents.year month:(int)dateComponents.month day:(int)dateComponents.day];
        self.scheduleEndTime = [[TLTime alloc]initWithHour:(int)dateComponents.hour minute:(int)dateComponents.minute];
    }
    
    [self updateSchedule];
}

#pragma mark - SwitchViewDelegate

- (void)switchViewDidTap:(SwitchView *)switchView {
    DDLogVerbose(@"%@ switchViewDidTap: %@", LOG_TAG, switchView);
    
    self.scheduleEnable = switchView.isOn;
    
    if (self.scheduleEnable && !self.scheduleStartDate) {
        [self initSchedule];
    }
    
    [self updateSchedule];
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

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    [super initViews];
    
    self.view.backgroundColor = Design.WHITE_COLOR;
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)]];
    
    [self setNavigationTitle:TwinmeLocalizedString(@"premium_services_view_controller_click_to_call_title", nil)];
    
    if (self.isTransfert) {
        self.avatarView.image = [UIImage imageNamed:@"TransfertCallPlaceholder"];
    } else {
        [self.callReceiverService getImageWithProfile:self.currentSpace.profile withBlock:^(UIImage *image) {
            self.avatarView.image = image;
        }];
    }
        
    [self.editAvatarView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleUpdateAvatarTapGesture)]];

    self.editAvatarView.isAccessibilityElement = YES;
    
    self.avatarView.backgroundColor = DESIGN_AVATAR_PLACEHOLDER_COLOR;
    self.avatarPlaceholderImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    if (self.isTransfert) {
        self.nameLabel.text = TwinmeLocalizedString(@"premium_services_view_controller_transfert_title", nil);
    } else {
        self.nameLabel.text = TwinmeLocalizedString(@"premium_services_view_controller_click_to_call_title", nil);
    }
    
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
    if (self.isTransfert) {
        self.nameTextField.text = TwinmeLocalizedString(@"create_transfert_call_view_controller_name_placeholder", nil);
    } else {
        self.nameTextField.text = self.currentSpace.profile.name;
    }
    
    self.nameTextField.delegate = self;
    [self.nameTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    self.counterNameLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.counterNameLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    
    self.counterNameLabel.font = Design.FONT_REGULAR26;
    self.counterNameLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.counterNameLabel.text = [NSString stringWithFormat:@"0/%d", MAX_NAME_LENGTH];
    
    if (self.currentSpace.profile.name.length > MAX_NAME_LENGTH) {
        self.nameTextField.text = [self.currentSpace.profile.name substringToIndex:MAX_NAME_LENGTH];
        self.counterNameLabel.text = [NSString stringWithFormat:@"%d/%d", MAX_NAME_LENGTH, MAX_NAME_LENGTH];
    } else {
        self.counterNameLabel.text = [NSString stringWithFormat:@"%lu/%d", (unsigned long)self.currentSpace.profile.name.length, MAX_NAME_LENGTH];
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
    
    self.counterDescriptionLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.counterDescriptionLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    
    self.counterDescriptionLabel.font = Design.FONT_REGULAR26;
    self.counterDescriptionLabel.textColor = Design.FONT_COLOR_DEFAULT;
    
    if (self.currentSpace.profile.objectDescription && ![self.currentSpace.profile.objectDescription isEqualToString:@""]) {
        self.descriptionTextView.text = self.currentSpace.profile.objectDescription;
        self.descriptionTextView.textColor = Design.FONT_COLOR_DEFAULT;
        self.counterDescriptionLabel.text = [NSString stringWithFormat:@"%lu/%d", (unsigned long)self.descriptionTextView.text.length, MAX_DESCRIPTION_LENGTH];
    } else {
        self.descriptionTextView.text = TwinmeLocalizedString(@"side_menu_view_controller_about", nil);
        self.descriptionTextView.textColor = Design.PLACEHOLDER_COLOR;
        self.counterDescriptionLabel.text = [NSString stringWithFormat:@"0/%d", MAX_DESCRIPTION_LENGTH];
    }
    
    self.settingsViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.settingsViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.settingsViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    UITapGestureRecognizer *settingsViewGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSettingsTapGesture:)];
    [self.settingsView addGestureRecognizer:settingsViewGestureRecognizer];
    
    [self.settingsView setBorder:Design.SEPARATOR_COLOR_GREY borderWidth:Design.SEPARATOR_HEIGHT width:self.settingsViewWidthConstraint.constant height:self.settingsViewHeightConstraint.constant left:false right:false top:false bottom:true];
    
    self.settingsLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.settingsLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.settingsLabel.text = TwinmeLocalizedString(@"show_call_view_controller_setting_calls", nil);
    self.settingsAccessoryViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.settingsAccessoryViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.settingsAccessoryView.tintColor = Design.ACCESSORY_COLOR;
    self.settingsAccessoryView.image = [self.settingsAccessoryView.image imageFlippedForRightToLeftLayoutDirection];
    
    self.limitedViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.limitedViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    
    [self.limitedView setBorder:Design.SEPARATOR_COLOR_GREY borderWidth:Design.SEPARATOR_HEIGHT width:self.limitedViewWidthConstraint.constant height:self.limitedViewHeightConstraint.constant left:false right:false top:false bottom:true];
    
    self.limitedLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.limitedLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.limitedLabel.font = Design.FONT_REGULAR34;
    self.limitedLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.limitedLabel.text = TwinmeLocalizedString(@"show_call_view_controller_setting_limited", nil);
        
    CGSize switchSize = [Design switchSize];
    self.limitedSwitchTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.limitedSwitchHeightConstraint.constant = switchSize.height;
    self.limitedSwitchWidthConstraint.constant = switchSize.width;
    
    self.limitedSwitch.switchViewDelegate = self;
    
    self.startViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.startViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    
    [self.startView setBorder:Design.SEPARATOR_COLOR_GREY borderWidth:Design.SEPARATOR_HEIGHT width:self.startViewWidthConstraint.constant height:self.limitedViewHeightConstraint.constant left:false right:false top:false bottom:true];
    
    self.startLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.startLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.startLabel.font = Design.FONT_REGULAR34;
    self.startLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.startLabel.text = TwinmeLocalizedString(@"show_call_view_controller_setting_start", nil);
    
    self.startDateViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.startDateViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.startDateViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
        
    self.startDateView.userInteractionEnabled = YES;
    self.startDateView.clipsToBounds = YES;
    self.startDateView.layer.cornerRadius = Design.CONTAINER_RADIUS;
    self.startDateView.layer.backgroundColor = Design.BACKGROUND_COLOR_GREY.CGColor;
    
    UITapGestureRecognizer *startDateViewGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleStartDateViewTapGesture:)];
    [self.startDateView addGestureRecognizer:startDateViewGestureRecognizer];
    
    self.startDateLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.startDateLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.startDateLabel.font = Design.FONT_REGULAR32;
    self.startDateLabel.textColor = Design.FONT_COLOR_DEFAULT;
    
    self.startHourViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.startHourViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.startHourViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.startHourView.userInteractionEnabled = YES;
    self.startHourView.clipsToBounds = YES;
    self.startHourView.layer.cornerRadius = Design.CONTAINER_RADIUS;
    self.startHourView.layer.backgroundColor = Design.BACKGROUND_COLOR_GREY.CGColor;
    
    UITapGestureRecognizer *startHourViewGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleStartHourViewTapGesture:)];
    [self.startHourView addGestureRecognizer:startHourViewGestureRecognizer];
    
    self.startHourLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.startHourLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.startHourLabel.font = Design.FONT_REGULAR32;
    self.startHourLabel.textColor = Design.FONT_COLOR_DEFAULT;
    
    self.endViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.endViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    
    [self.endView setBorder:Design.SEPARATOR_COLOR_GREY borderWidth:Design.SEPARATOR_HEIGHT width:self.endViewWidthConstraint.constant height:self.limitedViewHeightConstraint.constant left:false right:false top:false bottom:false];
    
    self.endLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.endLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.endLabel.font = Design.FONT_REGULAR34;
    self.endLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.endLabel.text = TwinmeLocalizedString(@"show_call_view_controller_setting_end", nil);
    
    self.endDateViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.endDateViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.endDateViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.endDateView.userInteractionEnabled = YES;
    self.endDateView.clipsToBounds = YES;
    self.endDateView.layer.cornerRadius = Design.CONTAINER_RADIUS;
    self.endDateView.layer.backgroundColor = Design.BACKGROUND_COLOR_GREY.CGColor;
    
    UITapGestureRecognizer *endDateViewGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleEndDateViewTapGesture:)];
    [self.endDateView addGestureRecognizer:endDateViewGestureRecognizer];
    
    self.endDateLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.endDateLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.endDateLabel.font = Design.FONT_REGULAR32;
    self.endDateLabel.textColor = Design.FONT_COLOR_DEFAULT;
    
    self.endHourViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.endHourViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.endHourViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.endHourView.userInteractionEnabled = YES;
    self.endHourView.clipsToBounds = YES;
    self.endHourView.layer.cornerRadius = Design.CONTAINER_RADIUS;
    self.endHourView.layer.backgroundColor = Design.BACKGROUND_COLOR_GREY.CGColor;
    
    UITapGestureRecognizer *endHourViewGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleEndHourViewTapGesture:)];
    [self.endHourView addGestureRecognizer:endHourViewGestureRecognizer];
    
    self.endHourLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.endHourLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.endHourLabel.font = Design.FONT_REGULAR32;
    self.endHourLabel.textColor = Design.FONT_COLOR_DEFAULT;
    
    self.saveViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.saveViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.saveViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    
    self.saveView.backgroundColor = Design.MAIN_COLOR;
    self.saveView.userInteractionEnabled = YES;
    self.saveView.layer.cornerRadius = Design.CONTAINER_RADIUS;
    self.saveView.clipsToBounds = YES;
    [self.saveView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSaveTapGesture:)]];
    
    self.saveLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.saveLabel.font = Design.FONT_BOLD36;
    self.saveLabel.textColor = [UIColor whiteColor];
    self.saveLabel.text = TwinmeLocalizedString(@"application_save", nil);
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture)];
    [self.view addGestureRecognizer:tapGesture];
    
    self.messageLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.messageLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    
    self.messageLabel.font = Design.FONT_REGULAR32;
    self.messageLabel.textColor = Design.FONT_COLOR_DEFAULT;
    
    if (self.isTransfert) {
        self.messageLabel.text = TwinmeLocalizedString(@"create_transfert_call_view_controller_message", nil);
    } else {
        self.messageLabel.text = TwinmeLocalizedString(@"create_external_call_view_controller_message", nil);
    }
    
    [self updateCallCapabilities];
    [self updateSchedule];
}

- (void)finish {
    DDLogVerbose(@"%@ finish", LOG_TAG);
    
    if (self.callReceiverService) {
        [self.callReceiverService dispose];
        self.callReceiverService = nil;
    } else {
        return;
    }
    
    if (self.callReceiver) {
        [self showCallReceiver:self.callReceiver];
        self.callReceiver = nil;
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
    
    self.saveView.alpha = 1.0;
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

- (void)handleStartDateViewTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleStartDateViewTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        [self openMenuDateTime:[NSDate date] menuDateTimeType:MenuDateTimeTypeStartDate];
    }
}

- (void)handleStartHourViewTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleStartHourViewTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        [self openMenuDateTime:[NSDate date] menuDateTimeType:MenuDateTimeTypeStartHour];
    }
}

- (void)handleEndDateViewTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleEndDateViewTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        
        if (self.scheduleStartDate) {
            NSDateComponents *startDateComponents = [[NSDateComponents alloc] init];
            startDateComponents.day = self.scheduleStartDate.day;
            startDateComponents.month = self.scheduleStartDate.month;
            startDateComponents.year = self.scheduleStartDate.year;
            
            NSCalendar *calendar = [NSCalendar currentCalendar];
            NSDate *minimumDate = [calendar dateFromComponents:startDateComponents];
            [self openMenuDateTime:minimumDate menuDateTimeType:MenuDateTimeTypeEndDate];
        } else {
            [self openMenuDateTime:[NSDate date] menuDateTimeType:MenuDateTimeTypeEndDate];
        }
    }
}

- (void)handleEndHourViewTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleStartHourViewTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        if (self.scheduleStartDate && self.scheduleStartTime) {
            NSDateComponents *startDateComponents = [[NSDateComponents alloc] init];
            startDateComponents.day = self.scheduleStartDate.day;
            startDateComponents.month = self.scheduleStartDate.month;
            startDateComponents.year = self.scheduleStartDate.year;
            startDateComponents.hour = self.scheduleStartTime.hour;
            startDateComponents.minute = self.scheduleStartTime.minute;
            
            NSCalendar *calendar = [NSCalendar currentCalendar];
            NSDate *minimumDate = [calendar dateFromComponents:startDateComponents];
            [self openMenuDateTime:minimumDate menuDateTimeType:MenuDateTimeTypeEndHour];
        } else {
            [self openMenuDateTime:[NSDate date] menuDateTimeType:MenuDateTimeTypeEndHour];
        }
    }
}

- (void)handleSettingsTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleSettingsTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        [self openMenuCallCapabilities];
    }
}

- (void)handleSaveTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleSaveTapGesture: %@", LOG_TAG, sender);
    
    if (self.creatingInProgress || [self.nameTextField.text isEqualToString:@""]) {
        return;
    }
    
    NSString *identityDescription =  [self.descriptionTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([identityDescription isEqualToString:TwinmeLocalizedString(@"side_menu_view_controller_about", nil)]) {
        identityDescription = @"";
    }
    
    TLCapabilities *capabilities = [[TLCapabilities alloc]init];
    if (self.isTransfert) {
        capabilities = [[TLCapabilities alloc]init];
        [capabilities setCapTransferWithValue:YES];
        
        if (!self.updatedCallReceiverAvatar) {
            self.updatedCallReceiverLargeAvatar = [UIImage imageNamed:@"TransfertCallPlaceholder"];
            self.updatedCallReceiverAvatar = [self.updatedCallReceiverLargeAvatar resizeImage];
        }
    } else {
        [capabilities setCapAudioWithValue:self.allowVoiceCall];
        [capabilities setCapVideoWithValue:self.allowVideoCall];
        [capabilities setCapGroupCallWithValue:self.allowGroupCall];
        
        if (self.scheduleStartDate) {
            TLDateTime *startDateTime = [[TLDateTime alloc]initWithDate:self.scheduleStartDate time:self.scheduleStartTime];
            TLDateTime *endDateTime = [[TLDateTime alloc]initWithDate:self.scheduleEndDate time:self.scheduleEndTime];
            TLDateTimeRange *dateTimeRange = [[TLDateTimeRange alloc]initWithStart:startDateTime end:endDateTime];
            
            TLSchedule *schedule = [[TLSchedule alloc]initWithPrivate:NO timeZone:[NSTimeZone localTimeZone] timeRanges:@[dateTimeRange]];
            [schedule setEnabled:self.scheduleEnable];
            [capabilities setSchedule:schedule];
        }
    }
    
    [self.callReceiverService createCallReceiver:self.nameTextField.text description:identityDescription identityName:self.nameTextField.text identityDescription:identityDescription avatar:self.updatedCallReceiverAvatar largeAvatar:self.updatedCallReceiverLargeAvatar capabilities:capabilities space:self.currentSpace];
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

- (void)showCallReceiver:(nonnull TLCallReceiver *)callReceiver {
    DDLogVerbose(@"%@ showCallReceiver: %@", LOG_TAG, callReceiver);
        
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        self.navigationController.navigationBarHidden = NO;
        ApplicationDelegate *delegate = (ApplicationDelegate *)[[UIApplication sharedApplication] delegate];
        MainViewController *mainViewController = delegate.mainViewController;
        TwinmeNavigationController *selectedNavigationController = mainViewController.selectedViewController;
        if (self.isTransfert) {
            TransferCallViewController *transferCallViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"TransferCallViewController"];
            [transferCallViewController initWithCallReceiver:callReceiver];
            [selectedNavigationController pushViewController:transferCallViewController animated:YES];
        } else {
            InvitationExternalCallViewController *invitationExternalCallViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"InvitationExternalCallViewController"];
            [invitationExternalCallViewController initWithCallReceiver:callReceiver];
            [selectedNavigationController pushViewController:invitationExternalCallViewController animated:YES];
        }
        
    }];
    
    [self.navigationController popViewControllerAnimated:YES];

    [CATransaction commit];
}

- (void)initSchedule {
    DDLogVerbose(@"%@ initSchedule", LOG_TAG);
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSCalendarUnit calendarUnit = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute;
    NSDate *date = [NSDate date];
    NSDateComponents *dateComponents = [calendar components:calendarUnit fromDate:date];
    self.scheduleStartDate = [[TLDate alloc]initWithYear:(int)dateComponents.year month:(int)dateComponents.month day:(int)dateComponents.day];
    
    date = [calendar dateByAddingUnit:NSCalendarUnitHour value:1 toDate:date options:NSCalendarWrapComponents];
    dateComponents = [calendar components:calendarUnit fromDate:date];
    self.scheduleStartTime = [[TLTime alloc]initWithHour:(int)dateComponents.hour minute:0];
    
    date = [calendar dateByAddingUnit:NSCalendarUnitHour value:1 toDate:date options:NSCalendarWrapComponents];
    dateComponents = [calendar components:calendarUnit fromDate:date];
    self.scheduleEndDate = [[TLDate alloc]initWithYear:(int)dateComponents.year month:(int)dateComponents.month day:(int)dateComponents.day];
    self.scheduleEndTime = [[TLTime alloc]initWithHour:(int)dateComponents.hour minute:0];
}

- (void)updateSchedule {
    DDLogVerbose(@"%@ updateSchedule", LOG_TAG);

    if (self.isTransfert) {
        self.settingsView.hidden = YES;
        self.limitedView.hidden = YES;
        self.settingsViewHeightConstraint.constant = 0;
        self.limitedViewHeightConstraint.constant = 0;
    }

    [self.limitedSwitch setOn:self.scheduleEnable];
    
    if (self.scheduleEnable) {
        self.startView.hidden = NO;
        self.endView.hidden = NO;
        self.startViewHeightConstraint.constant = Design.SETTING_CELL_HEIGHT;
        self.endViewHeightConstraint.constant = Design.SETTING_CELL_HEIGHT;
        
        NSDateComponents *startDateComponents = [[NSDateComponents alloc] init];
        startDateComponents.day = self.scheduleStartDate.day;
        startDateComponents.month = self.scheduleStartDate.month;
        startDateComponents.year = self.scheduleStartDate.year;
        startDateComponents.hour = self.scheduleStartTime.hour;
        startDateComponents.minute = self.scheduleStartTime.minute;
        
        NSDateComponents *endDateComponents = [[NSDateComponents alloc] init];
        endDateComponents.day = self.scheduleEndDate.day;
        endDateComponents.month = self.scheduleEndDate.month;
        endDateComponents.year = self.scheduleEndDate.year;
        endDateComponents.hour = self.scheduleEndTime.hour;
        endDateComponents.minute = self.scheduleEndTime.minute;
        
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDate *startDate = [calendar dateFromComponents:startDateComponents];
        NSDate *endDate = [calendar dateFromComponents:endDateComponents];
         
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
        dateFormatter.locale = [NSLocale currentLocale];
        [dateFormatter setDateFormat:@"dd MMM yyyy"];

        self.startDateLabel.text = [dateFormatter stringFromDate:startDate];
        self.endDateLabel.text = [dateFormatter stringFromDate:endDate];
        
        [dateFormatter setDateFormat:@"HH:mm"];
        self.startHourLabel.text = [dateFormatter stringFromDate:startDate];
        self.endHourLabel.text = [dateFormatter stringFromDate:endDate];
    } else {
        self.startView.hidden = YES;
        self.endView.hidden = YES;
        self.startViewHeightConstraint.constant = 0;
        self.endViewHeightConstraint.constant = 0;
    }
}

- (void)updateCallCapabilities {
    DDLogVerbose(@"%@ updateCallCapabilities", LOG_TAG);
    
    NSMutableAttributedString *capabilitiesAttributedString = [[NSMutableAttributedString alloc] initWithString:@""];
    
    if (self.allowVoiceCall) {
        [capabilitiesAttributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:TwinmeLocalizedString(@"show_contact_view_controller_audio", nil) attributes:[NSDictionary dictionaryWithObjectsAndKeys:Design.FONT_REGULAR32, NSFontAttributeName, Design.FONT_COLOR_GREY, NSForegroundColorAttributeName, nil]]];
    }
    
    if (self.allowVideoCall) {
        if (capabilitiesAttributedString.length > 0) {
            [capabilitiesAttributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:TwinmeLocalizedString(@", ", nil) attributes:[NSDictionary dictionaryWithObjectsAndKeys:Design.FONT_REGULAR32, NSFontAttributeName, Design.FONT_COLOR_GREY, NSForegroundColorAttributeName, nil]]];
        }
        [capabilitiesAttributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:TwinmeLocalizedString(@"show_contact_view_controller_video", nil) attributes:[NSDictionary dictionaryWithObjectsAndKeys:Design.FONT_REGULAR32, NSFontAttributeName, Design.FONT_COLOR_GREY, NSForegroundColorAttributeName, nil]]];
    }
    
    if (self.allowGroupCall) {
        if (capabilitiesAttributedString.length > 0) {
            [capabilitiesAttributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:TwinmeLocalizedString(@", ", nil) attributes:[NSDictionary dictionaryWithObjectsAndKeys:Design.FONT_REGULAR32, NSFontAttributeName, Design.FONT_COLOR_GREY, NSForegroundColorAttributeName, nil]]];
        }
        [capabilitiesAttributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:TwinmeLocalizedString(@"show_group_view_controller_title", nil) attributes:[NSDictionary dictionaryWithObjectsAndKeys:Design.FONT_REGULAR32, NSFontAttributeName, Design.FONT_COLOR_GREY, NSForegroundColorAttributeName, nil]]];
    }
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:TwinmeLocalizedString(@"show_call_view_controller_setting_calls", nil) attributes:[NSDictionary dictionaryWithObjectsAndKeys:Design.FONT_REGULAR34, NSFontAttributeName, Design.FONT_COLOR_DEFAULT, NSForegroundColorAttributeName, nil]];
    
    if (capabilitiesAttributedString.length > 0) {
        [attributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:@"\n"]];
        [attributedString appendAttributedString:capabilitiesAttributedString];
    }
    
    self.settingsLabel.attributedText = attributedString;
}

- (void)openMenuCallCapabilities {
    DDLogVerbose(@"%@ openMenuCallCapabilities", LOG_TAG);
    
    [self dismissKeyboard];
    
    MenuCallCapabilitiesView *menuCallCapabilitiesView = [[MenuCallCapabilitiesView alloc]init];
    menuCallCapabilitiesView.menuCallCapabilitiesDelegate = self;
    [self.tabBarController.view addSubview:menuCallCapabilitiesView];
    
    TLCapabilities *capabilities = [[TLCapabilities alloc]init];
    [capabilities setCapAudioWithValue:self.allowVoiceCall];
    [capabilities setCapVideoWithValue:self.allowVideoCall];
    [capabilities setCapGroupCallWithValue:self.allowGroupCall];
    
    [menuCallCapabilitiesView openMenu:capabilities];
}

- (void)openMenuPhoto {
    DDLogVerbose(@"%@ openMenuPhoto", LOG_TAG);
    
    [self dismissKeyboard];
    
    MenuPhotoView *menuPhotoView = [[MenuPhotoView alloc]init];
    menuPhotoView.menuPhotoViewDelegate = self;
    [self.tabBarController.view addSubview:menuPhotoView];
    [menuPhotoView openMenu:YES];
}

- (void)openMenuDateTime:(NSDate *)date menuDateTimeType:(MenuDateTimeType)menuDateTimeType {
    DDLogVerbose(@"%@ openMenuDateTime", LOG_TAG);
    
    [self dismissKeyboard];
    
    MenuDateTimeView *menuDateTimeView = [[MenuDateTimeView alloc]init];
    menuDateTimeView.menuDateTimeViewDelegate = self;
    [self.tabBarController.view addSubview:menuDateTimeView];
        
    [menuDateTimeView setMenuDateTimeTypeWithType:menuDateTimeType];
    [menuDateTimeView openMenu:date];
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    self.nameTextField.font = Design.FONT_REGULAR28;
    self.descriptionTextView.font = Design.FONT_REGULAR28;
    self.saveLabel.font = Design.FONT_BOLD36;
    self.counterNameLabel.font = Design.FONT_REGULAR26;
    self.counterDescriptionLabel.font = Design.FONT_REGULAR26;
    self.messageLabel.font = Design.FONT_REGULAR32;
    self.settingsLabel.font = Design.FONT_REGULAR34;
    self.limitedLabel.font = Design.FONT_REGULAR34;
    self.startLabel.font = Design.FONT_REGULAR34;
    self.startDateLabel.font = Design.FONT_REGULAR32;
    self.startHourLabel.font = Design.FONT_REGULAR32;
    self.endLabel.font = Design.FONT_REGULAR34;
    self.endDateLabel.font = Design.FONT_REGULAR32;
    self.endHourLabel.font = Design.FONT_REGULAR32;
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    [super updateColor];
    
    self.nameView.backgroundColor = Design.TEXTFIELD_BACKGROUND_COLOR;
    self.saveView.backgroundColor = Design.MAIN_COLOR;
    self.descriptionView.backgroundColor = Design.TEXTFIELD_BACKGROUND_COLOR;
    self.nameTextField.textColor = Design.FONT_COLOR_DEFAULT;
    self.nameTextField.tintColor = Design.FONT_COLOR_DEFAULT;
    self.messageLabel.textColor = Design.FONT_COLOR_DEFAULT;
    if (self.isTransfert) {
        self.nameTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:TwinmeLocalizedString(@"create_transfert_call_view_controller_name_placeholder", nil) attributes:[NSDictionary dictionaryWithObject:Design.PLACEHOLDER_COLOR forKey:NSForegroundColorAttributeName]];
    } else {
        self.nameTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:TwinmeLocalizedString(@"application_name_hint", nil) attributes:[NSDictionary dictionaryWithObject:Design.PLACEHOLDER_COLOR forKey:NSForegroundColorAttributeName]];
    }
    
    self.counterDescriptionLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.counterNameLabel.textColor = Design.FONT_COLOR_DEFAULT;
    
    if ([self.descriptionTextView.text isEqualToString:TwinmeLocalizedString(@"side_menu_view_controller_about", nil)]) {
        self.descriptionTextView.textColor = Design.PLACEHOLDER_COLOR;
    } else {
        self.descriptionTextView.textColor = Design.FONT_COLOR_DEFAULT;
    }
    
    self.limitedLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.startLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.startDateView.layer.backgroundColor = Design.BACKGROUND_COLOR_GREY.CGColor;
    self.startDateLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.startHourView.layer.backgroundColor = Design.BACKGROUND_COLOR_GREY.CGColor;
    self.startHourLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.endLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.endDateView.layer.backgroundColor = Design.BACKGROUND_COLOR_GREY.CGColor;
    self.endDateLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.endHourView.layer.backgroundColor = Design.BACKGROUND_COLOR_GREY.CGColor;
    self.endHourLabel.textColor = Design.FONT_COLOR_DEFAULT;
    
    [self updateCallCapabilities];
}

@end
