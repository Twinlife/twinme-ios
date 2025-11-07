/*
 *  Copyright (c) 2022-2024 twinlife SA.
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

#import "ShowProfileViewController.h"
#import "EditProfileViewController.h"
#import "NotificationViewController.h"
#import "AddContactViewController.h"
#import "MenuAddContactView.h"

#import <TwinmeCommon/Design.h>
#import <TwinmeCommon/EditIdentityService.h>

#import "DeviceAuthorization.h"

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static UIColor *DESIGN_AVATAR_PLACEHOLDER_COLOR;

//
// Interface: ShowProfileViewController ()
//

@interface ShowProfileViewController () <EditIdentityServiceDelegate, UIAdaptivePresentationControllerDelegate, MenuAddContactViewDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *twincodeViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *twincodeViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *twincodeViewTopConstraint;
@property (weak, nonatomic) IBOutlet UIView *twincodeView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *twincodeLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *twincodeLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *twincodeLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *twincodeImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *twincodeImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *avatarPlaceholderImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *avatarPlaceholderImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *addContactViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *addContactViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *addContactViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet UIView *addContactView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *addContactImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *addContactImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;

@property (nonatomic) BOOL keyboardHidden;
@property (nonatomic) BOOL updated;
@property (nonatomic) UIImage *updatedIdentityAvatar;
@property (nonatomic) UIImage *updatedIdentityLargeAvatar;

@property (nonatomic) EditIdentityService *editIdentityService;
@property (nonatomic) TLProfile *profile;
@property (nonatomic) TLSpace *space;
@property (nonatomic) NSString *name;
@property (nonatomic) NSString *identityDescription;
@property (nonatomic) UIImage *avatar;

@property (nonatomic) BOOL updateProfileDone;
@property (nonatomic) BOOL showOnboardingView;

@end

//
// Implementation: ShowProfileViewController
//

#undef LOG_TAG
#define LOG_TAG @"ShowProfileViewController"

@implementation ShowProfileViewController

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
        _showOnboardingView = NO;
        _editIdentityService = [[EditIdentityService alloc] initWithTwinmeContext:self.twinmeContext delegate:self];
    }
    return self;
}

- (void)viewDidLoad {
    DDLogVerbose(@"%@ viewDidLoad", LOG_TAG);
    
    [super viewDidLoad];
    
    [self initViews];
    [self updateProfile];
    
    if (self.profile) {
        [self.editIdentityService refreshWithProfile:self.profile];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    DDLogVerbose(@"%@ viewWillAppear: %@", LOG_TAG, animated ? @"YES" : @"NO");
    
    [super viewWillAppear:animated];
    
    [self updateProfile];
}

- (int)getActionViewHeight {
    DDLogVerbose(@"%@ getActionViewHeight", LOG_TAG);
    
    return self.actionView.frame.size.height - (self.messageLabel.frame.origin.y + self.messageLabel.intrinsicContentSize.height);
}

#pragma mark - Public methods

- (void)initWithProfile:(TLProfile *)profile {
    DDLogVerbose(@"%@ initWithProfile: %@", LOG_TAG, profile);
    
    self.profile = profile;
    self.space = self.profile.space;
}

- (void)backTap {
    DDLogVerbose(@"%@ backTap", LOG_TAG);
    
    [super backTap];
}

- (void)editTap {
    DDLogVerbose(@"%@ editTap", LOG_TAG);
    
    EditProfileViewController *editProfileViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"EditProfileViewController"];
    [editProfileViewController initWithSpace:self.space];
    [self.navigationController pushViewController:editProfileViewController animated:YES];
}

#pragma mark - EditIdentityServiceDelegate

- (void)onSetCurrentSpace:(nonnull TLSpace *)space {
    DDLogVerbose(@"%@ onSetCurrentSpace: %@", LOG_TAG, space);
    
    if (space.profile) {
        self.profile = space.profile;
        [self updateProfile];
        [self.editIdentityService refreshWithProfile:self.profile];
    }
}

- (void)onUpdateSpace:(TLSpace *)space {
    DDLogVerbose(@"%@ onSetCurrentSpace: %@", LOG_TAG, space);
    
    if ([self.currentSpace.uuid isEqual:space.uuid] && space.profile) {
        self.profile = space.profile;
        [self updateProfile];
        [self.editIdentityService refreshWithProfile:self.profile];
    }
}

- (void)onCreateProfile:(TLProfile *)profile {
    DDLogVerbose(@"%@ onCreateProfile: %@", LOG_TAG, profile);
    
    if (!self.profile) {
        self.profile = profile;
        
        [self updateProfile];
        [self.editIdentityService refreshWithProfile:self.profile];
    }
}

- (void)onUpdateProfile:(TLProfile *)profile {
    DDLogVerbose(@"%@ onUpdateProfile: %@", LOG_TAG, profile);
    
    if ([self.profile.uuid isEqual:profile.uuid]) {
        self.profile = profile;
        
        [self updateProfile];
        [self.editIdentityService refreshWithProfile:self.profile];
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
    
    self.avatar = avatar;
    [self updateProfile];
}

#pragma mark - UIAdaptivePresentationControllerDelegate

- (void)presentationControllerWillDismiss:(UIPresentationController *)presentationController {
    DDLogVerbose(@"%@ presentationControllerWillDismiss: %@", LOG_TAG, presentationController);
    
    self.navigationController.navigationBarHidden = YES;
}

#pragma mark - MenuAddContactViewDelegate

- (void)menuAddContactDidSelectScan:(MenuAddContactView *)menuAddContactView {
    DDLogVerbose(@"%@ menuAddContactDidSelectScan: %@", LOG_TAG, menuAddContactView);
    
    [menuAddContactView removeFromSuperview];
    
    AddContactViewController *addContactViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AddContactViewController"];
    [addContactViewController initWithProfile:self.profile invitationMode:InvitationModeScan];
    [self.navigationController pushViewController:addContactViewController animated:YES];
}

- (void)menuAddContactDidSelectInvite:(MenuAddContactView *)menuAddContactView {
    DDLogVerbose(@"%@ menuAddContactDidSelectInvite: %@", LOG_TAG, menuAddContactView);
    
    [menuAddContactView removeFromSuperview];
    
    AddContactViewController *addContactViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AddContactViewController"];
    [addContactViewController initWithProfile:self.profile invitationMode:InvitationModeInvite];
    [self.navigationController pushViewController:addContactViewController animated:YES];
}

- (void)cancelMenuAddContactView:(MenuAddContactView *)menuAddContactView {
    DDLogVerbose(@"%@ cancelMenuAddContactView: %@", LOG_TAG, menuAddContactView);
    
    [menuAddContactView removeFromSuperview];
}

#pragma mark - Private methods

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    [super initViews];
    
    self.view.backgroundColor = Design.WHITE_COLOR;
    
    self.avatarView.backgroundColor = DESIGN_AVATAR_PLACEHOLDER_COLOR;

    self.addContactViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.addContactViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.addContactViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
   
    self.addContactView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
    self.addContactView.userInteractionEnabled = YES;
    self.addContactView.layer.cornerRadius = self.addContactViewHeightConstraint.constant * 0.5;
    self.addContactView.clipsToBounds = YES;
    [self.addContactView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleAddContactTapGesture:)]];
    
    self.addContactImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.addContactImageView.tintColor = [UIColor whiteColor];
    
    self.twincodeViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.twincodeViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.twincodeViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.twincodeView.backgroundColor = Design.MAIN_COLOR;
    self.twincodeView.userInteractionEnabled = YES;
    self.twincodeView.layer.cornerRadius = Design.CONTAINER_RADIUS;
    self.twincodeView.clipsToBounds = YES;
    [self.twincodeView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTwincodeTapGesture:)]];
    
    self.twincodeImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.twincodeLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.twincodeLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.twincodeLabel.font = Design.FONT_MEDIUM36;
    self.twincodeLabel.textColor = [UIColor whiteColor];
    self.twincodeLabel.text = TwinmeLocalizedString(@"show_profile_view_controller_twincode_title", nil);
    
    [self.twincodeLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    
    self.avatarPlaceholderImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.nameLabel.text = TwinmeLocalizedString(@"application_profile", nil);
    
    self.messageLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.messageLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    
    self.messageLabel.font = Design.FONT_REGULAR26;
    self.messageLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.messageLabel.text = TwinmeLocalizedString(@"show_profile_view_controller_message", nil);
    
    self.nameLabel.text = TwinmeLocalizedString(@"application_profile", nil);
}

- (void)finish {
    DDLogVerbose(@"%@ finish", LOG_TAG);
    
    if (self.editIdentityService) {
        [self.editIdentityService dispose];
        self.editIdentityService = nil;
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)handleTwincodeTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleTwincodeTapGesture: %@", LOG_TAG, sender);
    
    AddContactViewController *addContactViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AddContactViewController"];
    [addContactViewController initWithProfile:self.profile invitationMode:InvitationModeOnlyInvite];
    [self.navigationController pushViewController:addContactViewController animated:YES];
}

- (void)handleAddContactTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleAddContactTapGesture: %@", LOG_TAG, sender);
    
    MenuAddContactView *menuAddContactView = [[MenuAddContactView alloc]init];
    menuAddContactView.menuAddContactViewDelegate = self;
    [self.tabBarController.view addSubview:menuAddContactView];
    [menuAddContactView openMenu];
}

- (void)updateProfile {
    DDLogVerbose(@"%@ updateProfile", LOG_TAG);
    
    if (self.profile) {
        self.descriptionLabel.hidden = NO;
        self.twincodeView.hidden = NO;
        self.twincodeImageView.hidden = NO;
        self.avatarPlaceholderImageView.hidden = YES;
        self.addContactView.hidden = NO;
        self.addContactImageView.hidden = NO;
        self.messageLabel.hidden = NO;
        self.twincodeLabel.hidden = NO;
        self.editView.hidden = NO;
        
        if (!self.avatar) {
            [self.editIdentityService getImageWithProfile:self.profile withBlock:^(UIImage *image) {
                self.avatar = image;
            }];
        }
        
        self.avatarView.image = self.avatar;
        self.nameLabel.text = self.profile.name;

        self.identityDescription = self.profile.objectDescription;
        
        if ([self.identityDescription isEqual:TwinmeLocalizedString(@"side_menu_view_controller_about", nil)]) {
            self.descriptionLabel.text = @"";
        } else {
            self.descriptionLabel.text = self.identityDescription;
        }
    } else {
        self.descriptionLabel.hidden = NO;
        self.twincodeView.hidden = YES;
        self.addContactView.hidden = YES;
        self.addContactImageView.hidden = YES;
        self.twincodeView.hidden = YES;
        self.twincodeImageView.hidden = YES;
        self.avatarPlaceholderImageView.hidden = NO;
        self.messageLabel.hidden = YES;
        self.twincodeLabel.hidden = YES;
        self.editView.hidden = YES;
        
        self.nameLabel.text = TwinmeLocalizedString(@"application_profile", nil);
    }
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    [super updateFont];
    
    self.descriptionLabel.font = Design.FONT_MEDIUM34;
    self.twincodeLabel.font = Design.FONT_REGULAR30;
    self.messageLabel.font = Design.FONT_REGULAR26;
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    [super updateColor];
    
    self.view.backgroundColor = Design.WHITE_COLOR;
    self.descriptionLabel.textColor = Design.FONT_COLOR_DESCRIPTION;
    self.twincodeView.backgroundColor = Design.MAIN_COLOR;
    self.messageLabel.textColor = Design.FONT_COLOR_DEFAULT;
}

@end
