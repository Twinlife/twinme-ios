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
#import "AddProfileViewController.h"
#import "AccountMigrationScannerViewController.h"
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

@interface ShowProfileViewController () <EditIdentityServiceDelegate, MenuAddContactViewDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *twincodeViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *twincodeViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *twincodeViewTopConstraint;
@property (weak, nonatomic) IBOutlet UIView *twincodeView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *twincodeLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *twincodeLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *twincodeLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *twincodeImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *twincodeImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sideMenuViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sideMenuViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sideMenuViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet UIView *sideMenuView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sideMenuImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *sideMenuImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *addContactViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *addContactViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *addContactViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet UIView *addContactView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *addContactImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *addContactImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *noProfileImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *noProfileImageViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *noProfileImageViewTopConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *noProfileImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *noProfileLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *noProfileLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *noProfileLabelBottomConstraint;
@property (weak, nonatomic) IBOutlet UILabel *noProfileLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *createProfileViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *createProfileViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *createProfileViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *createProfileViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet UIView *createProfileView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *createProfileLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *createProfileLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *createProfileLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *transferLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *transferLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *transferLabelHeightConstraint;
@property (weak, nonatomic) IBOutlet UILabel *transferLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *transferViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *transferViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *transferView;

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

@property (nonatomic) BOOL profileNotFound;
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
        _profileNotFound = NO;
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
}

- (void)viewWillAppear:(BOOL)animated {
    DDLogVerbose(@"%@ viewWillAppear: %@", LOG_TAG, animated ? @"YES" : @"NO");
    
    [super viewWillAppear:animated];
    
    [self setLeftBarButtonItem:self.editIdentityService profile:self.defaultProfile];
        
    if (self.navigationController.viewControllers.count > 1) {
        self.backClickableView.hidden = NO;
        self.sideMenuView.hidden = YES;
    } else {
        self.backClickableView.hidden = YES;
        self.sideMenuView.hidden = NO;
    }
    
    if (!self.profile) {
        self.profile = self.defaultProfile;
    }
    [self updateProfile];
}

- (int)getActionViewHeight {
    DDLogVerbose(@"%@ getActionViewHeight", LOG_TAG);
    
    return self.actionView.frame.size.height - (self.messageLabel.frame.origin.y + self.messageLabel.intrinsicContentSize.height);
}

#pragma mark - Public methods

- (void)initWithProfile:(TLProfile *)profile isActive:(BOOL)isActive {
    DDLogVerbose(@"%@ initWithProfile: %@ isActive: %d", LOG_TAG, profile, isActive);
    
    self.profile = profile;
    self.isActiveProfile = isActive;
    [self updateProfile];
}

- (void)backTap {
    DDLogVerbose(@"%@ backTap", LOG_TAG);
    
    [super backTap];
}

- (void)editTap {
    DDLogVerbose(@"%@ editTap", LOG_TAG);
    
    EditProfileViewController *editProfileViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"EditProfileViewController"];
    [editProfileViewController initWithProfile:self.profile isActive:YES];
    [self.navigationController pushViewController:editProfileViewController animated:YES];
}

- (BOOL)showNavigationBar {
    DDLogVerbose(@"%@ showNavigationBar", LOG_TAG);
    
    if (self.profile) {
        return YES;
    }
    
    return NO;
}

#pragma mark - EditIdentityServiceDelegate

- (void)onSetCurrentSpace:(nonnull TLSpace *)space {
    DDLogVerbose(@"%@ onSetCurrentSpace: %@", LOG_TAG, space);
        
    if (space.profile) {
        self.profileNotFound = NO;
        self.profile = space.profile;
        [self updateProfile];
        [self.editIdentityService refreshWithProfile:self.profile];
    }
}

- (void)onUpdateSpace:(TLSpace *)space {
    DDLogVerbose(@"%@ onSetCurrentSpace: %@", LOG_TAG, space);
    
    if ([self.currentSpace.uuid isEqual:space.uuid] && space.profile) {
        self.profileNotFound = NO;
        self.profile = space.profile;
        [self updateProfile];
        [self.editIdentityService refreshWithProfile:self.profile];
    }
}

- (void)onCreateProfile:(TLProfile *)profile {
    DDLogVerbose(@"%@ onCreateProfile: %@", LOG_TAG, profile);
    
    if (!self.profile) {
        self.profileNotFound = NO;
        self.profile = profile;
        [self updateProfile];
        [self.editIdentityService refreshWithProfile:self.profile];
    }
}

- (void)onUpdateProfile:(TLProfile *)profile {
    DDLogVerbose(@"%@ onUpdateProfile: %@", LOG_TAG, profile);
    
    if ([self.profile.uuid isEqual:profile.uuid]) {
        self.profileNotFound = NO;
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
    
    [self setNavigationTitle:TwinmeLocalizedString(@"application_profile", nil)];

    self.view.backgroundColor = Design.WHITE_COLOR;
    
    self.avatarView.backgroundColor = DESIGN_AVATAR_PLACEHOLDER_COLOR;

    self.sideMenuViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.sideMenuViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.sideMenuViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.sideMenuView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
    self.sideMenuView.userInteractionEnabled = YES;
    self.sideMenuView.isAccessibilityElement = YES;
    self.sideMenuView.layer.cornerRadius = self.sideMenuViewHeightConstraint.constant * 0.5;
    self.sideMenuView.clipsToBounds = YES;
    [self.sideMenuView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSideMenuTapGesture:)]];
    
    self.sideMenuImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.addContactViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.addContactViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.addContactViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
   
    self.addContactView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
    self.addContactView.userInteractionEnabled = YES;
    self.addContactView.isAccessibilityElement = YES;
    self.addContactView.layer.cornerRadius = self.addContactViewHeightConstraint.constant * 0.5;
    self.addContactView.clipsToBounds = YES;
    [self.addContactView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleAddContactTapGesture:)]];
    self.addContactView.accessibilityLabel = TwinmeLocalizedString(@"add_contact_view_controller_title", nil);
    
    self.addContactImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.addContactImageView.tintColor = [UIColor whiteColor];
    
    self.twincodeViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.twincodeViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.twincodeViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.twincodeView.backgroundColor = Design.MAIN_COLOR;
    self.twincodeView.userInteractionEnabled = YES;
    self.twincodeView.isAccessibilityElement = YES;
    self.twincodeView.accessibilityLabel = TwinmeLocalizedString(@"show_profile_view_controller_twincode_title", nil);
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
        
    self.nameLabel.text = TwinmeLocalizedString(@"application_profile", nil);
    
    self.messageLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.messageLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    
    self.messageLabel.font = Design.FONT_REGULAR26;
    self.messageLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.messageLabel.text = TwinmeLocalizedString(@"show_profile_view_controller_message", nil);
    
    self.nameLabel.text = TwinmeLocalizedString(@"application_profile", nil);
    
    self.noProfileImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.noProfileImageViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.noProfileImageViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.noProfileImageView.hidden = YES;
    
    self.noProfileLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.noProfileLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.noProfileLabelBottomConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.noProfileLabel.font = Design.FONT_MEDIUM34;
    self.noProfileLabel.textColor = Design.FONT_COLOR_DEFAULT;
    [self.noProfileLabel setAdjustsFontSizeToFitWidth:YES];
    self.noProfileLabel.text = TwinmeLocalizedString(@"add_contact_view_controller_onboarding_message", nil);
    self.noProfileLabel.hidden = YES;
    
    self.createProfileViewBottomConstraint.constant *= Design.HEIGHT_RATIO;
    self.createProfileViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.createProfileViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.createProfileViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.createProfileView.backgroundColor = Design.MAIN_COLOR;
    self.createProfileView.userInteractionEnabled = YES;
    self.createProfileView.layer.cornerRadius = Design.CONTAINER_RADIUS;
    self.createProfileView.clipsToBounds = YES;
    self.createProfileView.hidden = YES;
    self.createProfileView.isAccessibilityElement = YES;
    self.createProfileView.accessibilityLabel = TwinmeLocalizedString(@"show_profile_view_controller_create_profile", nil);
    [self.createProfileView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleCreateProfileTapGesture:)]];
    
    self.createProfileLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.createProfileLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;

    self.createProfileLabel.font = Design.FONT_MEDIUM34;
    self.createProfileLabel.textColor = [UIColor whiteColor];
    self.createProfileLabel.text = TwinmeLocalizedString(@"show_profile_view_controller_create_profile", nil);
    
    self.transferLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.transferLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.transferLabelHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.transferLabel.font = Design.FONT_REGULAR26;
    self.transferLabel.textColor = Design.FONT_COLOR_DEFAULT;
    
    NSMutableAttributedString *transferAttributedString = [[NSMutableAttributedString alloc] initWithString:TwinmeLocalizedString(@"account_view_controller_transfer_from_another_device", nil)];
    [transferAttributedString addAttribute:NSUnderlineStyleAttributeName value:@1 range:NSMakeRange(0,
                                                                                                 [transferAttributedString length])];
    [self.transferLabel setAttributedText:transferAttributedString];
    
    self.transferViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.transferViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.transferView.userInteractionEnabled = YES;
    [self.transferView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTransferTapGesture:)]];
}

- (void)finish {
    DDLogVerbose(@"%@ finish", LOG_TAG);
    
    if (self.editIdentityService) {
        [self.editIdentityService dispose];
        self.editIdentityService = nil;
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)handleSideMenuTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleSideMenuTapGesture: %@", LOG_TAG, sender);
    
    [super backTap];
}

- (void)handleTwincodeTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleTwincodeTapGesture: %@", LOG_TAG, sender);
    
    AddContactViewController *addContactViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AddContactViewController"];
    [addContactViewController initWithProfile:self.defaultProfile invitationMode:InvitationModeOnlyInvite];
    [self.navigationController pushViewController:addContactViewController animated:YES];
}

- (void)handleAddContactTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleAddContactTapGesture: %@", LOG_TAG, sender);
    
    MenuAddContactView *menuAddContactView = [[MenuAddContactView alloc]init];
    menuAddContactView.menuAddContactViewDelegate = self;
    [self.tabBarController.view addSubview:menuAddContactView];
    [menuAddContactView openMenu];
}

- (void)handleCreateProfileTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleCreateProfileTapGesture: %@", LOG_TAG, sender);
    
    AddProfileViewController *addProfileViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AddProfileViewController"];
    addProfileViewController.firstProfile = YES;
    [self.navigationController pushViewController:addProfileViewController animated:YES];
}

- (void)handleTransferTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleTransferTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        AccountMigrationScannerViewController *accountMigrationScannerViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AccountMigrationScannerViewController"];
        accountMigrationScannerViewController.fromCurrentDevice = NO;
        [self.navigationController pushViewController:accountMigrationScannerViewController animated:YES];
    }
}

- (void)updateProfile {
    DDLogVerbose(@"%@ updateProfile", LOG_TAG);
    
    if (self.profile) {
        self.navigationController.navigationBarHidden = YES;
        self.scrollView.hidden = NO;
        self.avatarView.hidden = NO;
        if (self.navigationController.viewControllers.count > 1) {
            self.backClickableView.hidden = NO;
            self.sideMenuView.hidden = YES;
            self.sideMenuImageView.hidden = YES;
        } else {
            self.backClickableView.hidden = YES;
            self.sideMenuView.hidden = NO;
            self.sideMenuImageView.hidden = NO;
        }
        
        self.addContactView.hidden = NO;
        self.addContactImageView.hidden = NO;
        self.noProfileLabel.hidden = YES;
        self.noProfileImageView.hidden = YES;
        self.createProfileView.hidden = YES;
        self.transferView.hidden = YES;
        
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
        self.navigationController.navigationBarHidden = NO;
        self.scrollView.hidden = YES;
        self.avatarView.hidden = YES;
        self.sideMenuView.hidden = YES;
        self.sideMenuImageView.hidden = YES;
        self.backClickableView.hidden = YES;
        self.addContactView.hidden = YES;
        self.addContactImageView.hidden = YES;
        self.nameLabel.text = TwinmeLocalizedString(@"application_profile", nil);
        self.noProfileLabel.hidden = NO;
        self.noProfileImageView.hidden = NO;
        self.createProfileView.hidden = NO;
        self.transferView.hidden = NO;
    }
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    [super updateFont];
    
    self.descriptionLabel.font = Design.FONT_MEDIUM34;
    self.twincodeLabel.font = Design.FONT_REGULAR30;
    self.messageLabel.font = Design.FONT_REGULAR26;
    self.noProfileLabel.font = Design.FONT_MEDIUM34;
    self.createProfileLabel.font = Design.FONT_MEDIUM34;
    self.transferLabel.font = Design.FONT_REGULAR26;
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    [super updateColor];
    
    self.view.backgroundColor = Design.WHITE_COLOR;
    self.descriptionLabel.textColor = Design.FONT_COLOR_DESCRIPTION;
    self.twincodeView.backgroundColor = Design.MAIN_COLOR;
    self.messageLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.noProfileLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.createProfileView.backgroundColor = Design.MAIN_COLOR;
    self.transferLabel.textColor = Design.FONT_COLOR_DEFAULT;
}

@end
