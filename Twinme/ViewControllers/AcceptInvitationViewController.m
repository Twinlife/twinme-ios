/*
 *  Copyright (c) 2016-2024 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Chedi Baccari (Chedi.Baccari@twinlife-systems.com)
 *   Christian Jacquemot (Christian.Jacquemot@twinlife-systems.com)
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 *   Stephane Carrez (Stephane.Carrez@twin.life)
 */

#import <CocoaLumberjack.h>

#import <Twinlife/TLConversationService.h>
#import <Twinlife/TLTwincodeOutboundService.h>

#import <Twinme/TLContact.h>
#import <Twinme/TLGroup.h>
#import <Twinme/TLProfile.h>
#import <Twinme/TLSpace.h>
#import <Twinme/UIImage+Resize.h>

#import <Utils/NSString+Utils.h>

#import "AcceptInvitationViewController.h"
#import "AddProfileViewController.h"
#import "SpacesViewController.h"

#import <TwinmeCommon/AcceptInvitationService.h>
#import <TwinmeCommon/ApplicationDelegate.h>
#import <TwinmeCommon/Design.h>
#import <TwinmeCommon/GroupService.h>
#import <TwinmeCommon/MainViewController.h>
#import <TwinmeCommon/TwinmeNavigationController.h>

#import "AlertMessageView.h"
#import "InsideBorderView.h"
#import "DefaultConfirmView.h"
#import "UIColor+Hex.h"
#import "UIViewController+ProgressIndicator.h"

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

#define CONTACT_CHECK_DELAY (60 * 1000L)

#define ICON_BACKGROUND_COLOR [UIColor colorWithRed:213./255. green:213./255. blue:213./255. alpha:1.0]

static const CGFloat DESIGN_AVATAR_HEIGHT = 148;
static const CGFloat DESIGN_CONFIRM_HEIGHT = 82;
static const CGFloat DESIGN_CANCEL_HEIGHT = 140;

//
// Interface: AcceptInvitationViewController ()
//

@class AcceptInvitationViewControllerTwinmeContextDelegate;
@class AcceptInvitationViewControllerTwincodeOutboundServiceDelegate;

@interface AcceptInvitationViewController () <AcceptInvitationServiceDelegate, GroupServiceDelegate, SpacesPickerDelegate, AlertMessageViewDelegate, ConfirmViewDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *actionViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *actionViewBottomConstraint;
@property (weak, nonatomic) IBOutlet UIView *actionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *slideMarkViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *slideMarkViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *slideMarkViewWidthConstraint;
@property (weak, nonatomic) IBOutlet UIView *slideMarkView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *avatarContainerViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *avatarContainerViewTopConstraint;
@property (weak, nonatomic) IBOutlet UIView *avatarContainerView;
@property (weak, nonatomic) IBOutlet UIImageView *avatarView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *iconViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *iconView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *iconImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bulletViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bulletViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet UIView *bulletView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *spaceTitleLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *spaceTitleLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *spaceTitleLabelTopConstraint;
@property (weak, nonatomic) IBOutlet UILabel *spaceTitleLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *spaceViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *spaceViewTopConstraint;
@property (weak, nonatomic) IBOutlet InsideBorderView *spaceView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *spaceImageViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *spaceImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *spaceImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *spaceAvatarViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *spaceAvatarViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *spaceAvatarView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *spaceLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *spaceLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *spaceLabel;
@property (weak, nonatomic) IBOutlet UILabel *spaceAvatarLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *confirmViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *confirmViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *confirmViewWidthConstraint;
@property (weak, nonatomic) IBOutlet UIView *confirmView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *confirmLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet UILabel *confirmLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cancelViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cancelViewBottomConstraint;
@property (weak, nonatomic) IBOutlet UIView *cancelView;
@property (weak, nonatomic) IBOutlet UILabel *cancelLabel;

@property (nonatomic) UIView *overlayView;

@property (nonatomic) BOOL actionEnable;
@property (nonatomic) BOOL setupDone;
@property (nonatomic) BOOL hasProfile;
@property (nonatomic) BOOL hasTwincode;
@property (nonatomic) BOOL hasExistingContact;
@property (nonatomic) NSString *contactName;
@property (nonatomic) NSString *contactDescription;
@property (nonatomic) UIImage *contactAvatar;
@property (nonatomic) TLProfile *profile;
@property (nonatomic) BOOL popToRootViewController;
@property (nonatomic) TLDescriptorId *descriptorId;
@property (nonatomic) TLSpace *space;
@property (nonatomic) TLSpace *initialSpace;
@property (nonatomic) TLNotification *notification;
@property (nonatomic) TLContact *contact;
@property (nonatomic) NSURL *url;

@property (nonatomic) AcceptInvitationService *acceptInvitationService;

- (void)onGetTwincodeWithTwincode:(nonnull TLTwincodeOutbound *)twincode avatar:(nullable UIImage *)avatar;

- (void)onGetTwincodeNotFound;

- (void)onLocalTwincode;

- (void)onExistingContacts:(nonnull NSArray<TLContact *> *)contacts;

- (void)onCreateContact:(nonnull TLContact *)contact;

- (void)onGetDefaultProfile:(nonnull TLProfile *)profile;

- (void)onMoveContact:(nonnull TLContact *)contact;

- (void)onGetDefaultSpace:(nonnull TLSpace *)space;

- (void)onGetDefaultProfileNotFound;

- (void)onDeleteDescriptors:(nonnull NSSet<TLDescriptorId *> *)descriptors;

- (void)onDeleteNotification:(nonnull NSUUID *)notificationId;

- (void)onSetCurrentSpace:(nonnull TLSpace *)space;
@end

#undef LOG_TAG
#define LOG_TAG @"AcceptInvitationViewController"

@implementation AcceptInvitationViewController

#pragma mark - UIViewController

- (instancetype)initWithCoder:(NSCoder *)coder {
    DDLogVerbose(@"%@ initWithCoder: %@", LOG_TAG, coder);
    
    self = [super initWithCoder:coder];
    
    if (self) {
        _hasProfile = NO;
        _hasTwincode = NO;
        _setupDone = NO;
        _actionEnable = YES;
        _popToRootViewController = NO;
        _hasExistingContact = NO;
    }
    return self;
}

- (void)viewDidLoad {
    DDLogVerbose(@"%@ viewDidLoad", LOG_TAG);
    
    [super viewDidLoad];
    
    [self initViews];
}

#pragma mark - Public methods

- (void)initWithProfile:(TLProfile *)profile url:(NSURL *)url descriptorId:(TLDescriptorId *)descriptorId originatorId:(NSUUID *)originatorId isGroup:(BOOL)isGroup notification:(TLNotification *)notification popToRootViewController:(BOOL)popToRootViewController  {
    DDLogVerbose(@"%@ initWithProfile: %@ url: %@ twincodeId: %@ originatorId: %@ isGroup: %d notification: %@ popToRootViewController: %@", LOG_TAG, profile, url, descriptorId, originatorId, isGroup, notification, popToRootViewController ? @"YES" : @"NO");
    
    self.popToRootViewController = popToRootViewController;
    self.url = url;
    
    if (profile) {
        self.hasProfile = YES;
        
        self.profile = profile;
    }

    NSUUID *contactId = isGroup ? nil : originatorId;
    NSUUID *groupId = isGroup ? originatorId : nil;
    TLTrustMethod trustMethod;
    if (descriptorId) {
        trustMethod = TLTrustMethodPeer;
    } else {
        // SCz must be identify whether this is a link or a QR-code
        trustMethod = TLTrustMethodQrCode;
    }
    self.acceptInvitationService = [[AcceptInvitationService alloc] initWithTwinmeContext:self.twinmeContext delegate:self uri:url contactId:contactId groupId:groupId descriptorId:descriptorId trustMethod:trustMethod];
    self.descriptorId = descriptorId;
    self.notification = notification;
}

- (void)showInView:(UIView *)view {
    DDLogVerbose(@"%@ showInView: %@", LOG_TAG, view);
    
    self.view.frame = view.frame;
    [view addSubview:self.view];
    [self showActionView];
}

#pragma mark - AcceptInvitationServiceDelegate

- (void)onCreateContact:(TLContact *)contact {
    DDLogVerbose(@"%@ onCreateContact: %@", LOG_TAG, contact);
    
    self.contact = contact;
    if (self.descriptorId) {
        [self.acceptInvitationService deleteDescriptor:self.descriptorId];
    }
    if (self.notification) {
        [self.acceptInvitationService deleteNotification:self.notification];
    } else {
        [self finish];
    }
}

- (void)onMoveContact:(TLContact *)contact {
    DDLogVerbose(@"%@ onMoveContact: %@", LOG_TAG, contact);
    
    if (self.notification) {
        [self.acceptInvitationService deleteNotification:self.notification];
    } else {
        [self finish];
    }
}

- (void)onParseTwincodeURI:(TLBaseServiceErrorCode)errorCode uri:(nullable TLTwincodeURI *)uri {
    DDLogVerbose(@"%@ onParseTwincodeURI: %d uri: %@", LOG_TAG, errorCode, uri);

    if (errorCode != TLBaseServiceErrorCodeSuccess) {
        [self incorrectQRCode:errorCode];
    } else if (uri.kind != TLTwincodeURIKindInvitation) {
        NSString *message = TwinmeLocalizedString(@"capture_view_controller_incorrect_qrcode", nil);
        
        switch (uri.kind) {
            case TLTwincodeURIKindCall:
                message = TwinmeLocalizedString(@"add_contact_view_controller_scan_message_call_link", nil);
                break;
                
            case TLTwincodeURIKindAccountMigration:
                message = TwinmeLocalizedString(@"add_contact_view_controller_scan_message_migration_link", nil);
                break;
                
            case TLTwincodeURIKindTransfer:
                message = TwinmeLocalizedString(@"add_contact_view_controller_scan_message_transfer_link", nil);
                break;
                
            default:
                break;
        }
        
        AlertMessageView *alertMessageView = [[AlertMessageView alloc] init];
        alertMessageView.alertMessageViewDelegate = self;
        [alertMessageView initWithTitle:TwinmeLocalizedString(@"delete_account_view_controller_warning", nil) message:message];
        [self.tabBarController.view addSubview:alertMessageView];
        [alertMessageView showAlertView];
    }
}

- (void)onGetTwincodeWithTwincode:(nonnull TLTwincodeOutbound *)twincode avatar:(UIImage *)avatar {
    DDLogVerbose(@"%@ onGetTwincodeWithTwincode: %@ avatar: %@", LOG_TAG, twincode, avatar);
    
    self.hasTwincode = YES;
    
    self.contactName = twincode.name;
    self.contactDescription = twincode.twincodeDescription;
    self.contactAvatar = avatar;
    
    [self updateTwincode];
}

- (void)onGetTwincodeNotFound {
    DDLogVerbose(@"%@ onGetTwincodeNotFound", LOG_TAG);
        
    self.actionView.hidden = YES;
    
    AlertMessageView *alertMessageView = [[AlertMessageView alloc] init];
    alertMessageView.alertMessageViewDelegate = self;
    [alertMessageView initWithTitle:TwinmeLocalizedString(@"delete_account_view_controller_warning", nil) message:TwinmeLocalizedString(@"add_contact_view_controller_scan_error_revoked_link", nil)];
    [self.view addSubview:alertMessageView];
    [alertMessageView showAlertView];
}

- (void)onLocalTwincode {
    DDLogVerbose(@"%@ onLocalTwincode", LOG_TAG);
    
    self.actionView.hidden = YES;
    
    self.hasTwincode = YES;
    
    AlertMessageView *alertMessageView = [[AlertMessageView alloc] init];
    alertMessageView.alertMessageViewDelegate = self;
    [alertMessageView initWithTitle:TwinmeLocalizedString(@"delete_account_view_controller_warning", nil) message:TwinmeLocalizedString(@"accept_invitation_view_controller_local_twincode", nil)];
    [self.view addSubview:alertMessageView];
    [alertMessageView showAlertView];
}

- (void)onGetDefaultSpace:(nonnull TLSpace *)space {
    DDLogVerbose(@"%@ onGetDefaultSpace: %@", LOG_TAG, space);
    
}

- (void)onGetDefaultProfile:(TLProfile *)profile {
    DDLogVerbose(@"%@ onGetDefaultProfile: %@", LOG_TAG, profile);
    
    self.space = profile.space;
    
    if (!self.initialSpace) {
        self.initialSpace = profile.space;
    }
    
    self.hasProfile = YES;
    self.profile = profile;
    
    [self updateSpace];
}

- (void)onGetDefaultProfileNotFound {
    DDLogVerbose(@"%@ onGetDefaultProfileNotFound", LOG_TAG);
    
    self.hasProfile = NO;
}

- (void)onExistingContacts:(nonnull NSArray<TLContact *> *)contacts {
    DDLogVerbose(@"%@ onExistingContacts: %@", LOG_TAG, contacts);
    
    int64_t now = [[NSDate date] timeIntervalSince1970] * 1000L;
    for (TLContact *contact in contacts) {
        if (contact.creationDate + CONTACT_CHECK_DELAY > now) {
            [self onCreateContact:contact];
            return;
        }
    }
    
    if (contacts.count > 0) {
        self.hasExistingContact = YES;
        self.messageLabel.text = TwinmeLocalizedString(@"add_contact_view_controller_existing_contact_message", nil);
    } else {
        self.hasExistingContact = NO;
        self.messageLabel.text = [NSString stringWithFormat:TwinmeLocalizedString(@"accept_invitation_view_controller_message %@", nil), self.contactName];
    }
}

- (void)onDeleteDescriptors:(NSSet<TLDescriptorId *> *)descriptors {
    DDLogVerbose(@"%@ onDeleteDescriptors: %@", LOG_TAG, descriptors);
    
    if (self.notification) {
        [self.acceptInvitationService deleteNotification:self.notification];
    } else {
        [self finish];
    }
}

- (void)onDeleteNotification:(NSUUID *)notificationId {
    DDLogVerbose(@"%@ onDeleteNotification: %@", LOG_TAG, notificationId);
    
    [self finish];
}

- (void)onSetCurrentSpace:(TLSpace *)space {
    DDLogVerbose(@"%@ onSetCurrentSpace: %@", LOG_TAG, space);
    
}

#pragma mark - SpacesPickerDelegate

- (void)didSelectSpace:(TLSpace *)space {
    DDLogVerbose(@"%@ didSelectSpace: %@", LOG_TAG, space);
    
    self.space = space;
    self.profile = space.profile;
    
    [self updateSpace];
}

#pragma mark - ConfirmViewDelegate

- (void)didTapConfirm:(nonnull AbstractConfirmView *)abstractConfirmView {
    DDLogVerbose(@"%@ didTapConfirm: %@", LOG_TAG, abstractConfirmView);
    
    ApplicationDelegate *delegate = (ApplicationDelegate *)[[UIApplication sharedApplication] delegate];
    MainViewController *mainViewController = delegate.mainViewController;
    TwinmeNavigationController *selectedNavigationController = mainViewController.selectedViewController;
    
    AddProfileViewController *addProfileViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AddProfileViewController"];
    addProfileViewController.firstProfile = YES;
    addProfileViewController.invitationURL = self.url;
    [selectedNavigationController pushViewController:addProfileViewController animated:YES];
    
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
    
    [self finish];
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

#pragma mark - Private methods

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    self.view.backgroundColor = [UIColor clearColor];
    self.view.isAccessibilityElement = NO;
    
    self.overlayView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, Design.DISPLAY_WIDTH, Design.DISPLAY_HEIGHT)];
    self.overlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.overlayView.alpha = .0f;
    self.overlayView.backgroundColor = [UIColor blackColor];
    
    [self.view insertSubview:self.overlayView atIndex:0];
    
    UITapGestureRecognizer *tapOverlayGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleCancelTapGesture:)];
    [self.overlayView addGestureRecognizer:tapOverlayGestureRecognizer];
    
    self.actionViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.actionViewBottomConstraint.constant *= Design.WIDTH_RATIO;
    
    self.actionView.hidden = YES;
    self.actionView.userInteractionEnabled = YES;
    self.actionView.backgroundColor = Design.POPUP_BACKGROUND_COLOR;
    self.actionView.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
    self.actionView.layer.cornerRadius = 40 * Design.HEIGHT_RATIO;
    self.actionView.clipsToBounds = YES;
        
    UISwipeGestureRecognizer *swipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleCancelTapGesture:)];
    [swipeGestureRecognizer setDirection:(UISwipeGestureRecognizerDirectionDown)];
    [self.actionView addGestureRecognizer:swipeGestureRecognizer];
    
    self.slideMarkViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.slideMarkViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.slideMarkViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.slideMarkView.backgroundColor = [UIColor colorWithRed:244./255. green:244./255. blue:244./255. alpha:1.0];
    self.slideMarkView.layer.cornerRadius = self.slideMarkViewHeightConstraint.constant * 0.5;
    self.slideMarkView.clipsToBounds = YES;
    
    self.avatarContainerViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.avatarContainerViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.avatarContainerView.clipsToBounds = YES;
    self.avatarContainerView.layer.cornerRadius = self.avatarContainerViewHeightConstraint.constant * 0.5f;
    self.avatarContainerView.layer.borderWidth = 3.f;
    self.avatarContainerView.layer.borderColor = [UIColor whiteColor].CGColor;

    self.avatarContainerView.layer.shadowOpacity = Design.SHADOW_OPACITY;
    self.avatarContainerView.layer.shadowOffset = Design.SHADOW_OFFSET;
    self.avatarContainerView.layer.shadowRadius = Design.SHADOW_RADIUS;
    self.avatarContainerView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.avatarContainerView.layer.masksToBounds = NO;
    
    self.avatarView.clipsToBounds = YES;
    self.avatarView.layer.cornerRadius = self.avatarContainerViewHeightConstraint.constant * 0.5f;
    self.avatarView.image = self.contactAvatar;
    
    self.nameLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.nameLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.nameLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    if (self.contactName) {
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:self.contactName attributes:[NSDictionary dictionaryWithObjectsAndKeys: Design.FONT_BOLD44, NSFontAttributeName, Design.FONT_COLOR_DEFAULT, NSForegroundColorAttributeName, nil]];
        if (![self.contactDescription isEqual:@""] && ![self.contactDescription isEqual:TwinmeLocalizedString(@"side_menu_view_controller_about", nil)]) {
            [attributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:@"\n"]];
            [attributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:self.contactDescription attributes:[NSDictionary dictionaryWithObjectsAndKeys: Design.FONT_MEDIUM30, NSFontAttributeName, Design.FONT_COLOR_GREY, NSForegroundColorAttributeName, nil]]];
        }

        self.nameLabel.attributedText = attributedString;
    }
    
    self.messageLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.messageLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.messageLabel.font = Design.FONT_MEDIUM38;
    self.messageLabel.textColor = Design.FONT_COLOR_GREY;
    self.messageLabel.text = [NSString stringWithFormat:TwinmeLocalizedString(@"accept_invitation_view_controller_message %@", nil), self.contactName];
    
    self.spaceTitleLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.spaceTitleLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.spaceTitleLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.spaceTitleLabel.font = Design.FONT_BOLD26;
    self.spaceTitleLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.spaceTitleLabel.text = TwinmeLocalizedString(@"settings_space_view_controller_space_category_title", nil).uppercaseString;
    
    self.spaceViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.spaceViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    UITapGestureRecognizer *spaceViewGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSpaceTapGesture:)];
    [self.spaceView addGestureRecognizer:spaceViewGestureRecognizer];
    
    [self.spaceView setBorder:Design.SEPARATOR_COLOR_GREY borderWidth:Design.SEPARATOR_HEIGHT width:Design.DISPLAY_WIDTH height:self.spaceViewHeightConstraint.constant left:NO right:NO top:YES bottom:YES];
    
    self.spaceImageViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.spaceImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.spaceImageView.tintColor = Design.UNSELECTED_TAB_COLOR;
    
    self.spaceAvatarLabel.font = Design.FONT_BOLD44;
    self.spaceAvatarLabel.textColor = [UIColor whiteColor];
    self.spaceAvatarLabel.hidden = YES;
    
    self.spaceLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.spaceLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;

    self.spaceAvatarViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.spaceAvatarViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.spaceAvatarView.clipsToBounds = YES;
    self.spaceAvatarView.layer.cornerRadius = Design.SPACE_RADIUS_RATIO * self.spaceAvatarViewHeightConstraint.constant;
    
    self.iconViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
   
    self.iconView.layer.cornerRadius = self.iconViewHeightConstraint.constant * 0.5f;
    self.iconView.layer.borderWidth = 3.f;
    self.iconView.layer.borderColor = [UIColor whiteColor].CGColor;
    
    self.iconView.layer.shadowOpacity = Design.SHADOW_OPACITY;
    self.iconView.layer.shadowOffset = Design.SHADOW_OFFSET;
    self.iconView.layer.shadowRadius = Design.SHADOW_RADIUS;
    self.iconView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.iconView.layer.masksToBounds = NO;
    self.iconView.backgroundColor = ICON_BACKGROUND_COLOR;
    
    self.iconImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.iconImageView.tintColor = [UIColor whiteColor];

    self.bulletViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.bulletViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.bulletView.clipsToBounds = YES;
    self.bulletView.layer.cornerRadius = self.bulletViewHeightConstraint.constant * 0.5f;
    self.bulletView.layer.borderWidth = 3.f;
    self.bulletView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.bulletView.backgroundColor = ICON_BACKGROUND_COLOR;
    
    self.confirmViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.confirmViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.confirmViewWidthConstraint.constant *= Design.WIDTH_RATIO;
        
    self.confirmView.backgroundColor = Design.MAIN_COLOR;
    self.confirmView.userInteractionEnabled = YES;
    self.confirmView.layer.cornerRadius = Design.CONTAINER_RADIUS;
    self.confirmView.clipsToBounds = YES;
    self.confirmView.isAccessibilityElement = YES;
    [self.confirmView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleConfirmTapGesture:)]];
    
    self.confirmLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
        
    self.confirmLabel.font = Design.FONT_BOLD36;
    self.confirmLabel.textColor = [UIColor whiteColor];
    self.confirmLabel.text = TwinmeLocalizedString(@"application_accept", nil);
    
    self.cancelViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    UITapGestureRecognizer *cancelViewGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleCancelTapGesture:)];
    [self.cancelView addGestureRecognizer:cancelViewGestureRecognizer];
    
    UIWindow *window = UIApplication.sharedApplication.keyWindow;
    self.cancelViewBottomConstraint.constant = window.safeAreaInsets.bottom;

    self.cancelLabel.font = Design.FONT_MEDIUM38;
    self.cancelLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.cancelLabel.text = TwinmeLocalizedString(@"application_cancel", nil);
}

- (void)finish {
    DDLogVerbose(@"%@ finish", LOG_TAG);
    
    [self.acceptInvitationService dispose];
    
    [self.view removeFromSuperview];
    
    if ([self.acceptInvitationDelegate respondsToSelector:@selector(invitationDidFinish:)]) {
        [self.acceptInvitationDelegate invitationDidFinish:self.contact];
    }
}

- (void)handleSpaceTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleSpaceTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        SpacesViewController *spacesViewController = [[UIStoryboard storyboardWithName:@"Space" bundle:nil] instantiateViewControllerWithIdentifier:@"SpacesViewController"];
        spacesViewController.pickerMode = YES;
        spacesViewController.spacesPickerDelegate = self;
        TwinmeNavigationController *navigationController = [[TwinmeNavigationController alloc] initWithRootViewController:spacesViewController];
        [self presentViewController:navigationController animated:YES completion:nil];
    }
}

- (void)showActionView {
    DDLogVerbose(@"%@ showActionView", LOG_TAG);
    
    [self updateTwincode];
    self.actionView.frame = CGRectMake(0, Design.DISPLAY_HEIGHT, Design.DISPLAY_WIDTH, self.actionView.frame.size.height);
    self.actionView.hidden = NO;

    [UIView animateWithDuration:Design.ANIMATION_VIEW_DURATION
                          delay:0
                        options:0
                     animations:^{
        self.overlayView.alpha = 0.3f;
        self.actionView.frame = CGRectMake(0, Design.DISPLAY_HEIGHT - self.actionView.frame.size.height, Design.DISPLAY_WIDTH, self.actionView.frame.size.height);
    }
                     completion:nil];
}

- (void)closeActionView {
    DDLogVerbose(@"%@ closeActionView", LOG_TAG);
    
    [UIView animateWithDuration:Design.ANIMATION_VIEW_DURATION
                          delay:0
                        options:0
                     animations:^{
        self.overlayView.alpha = 0.f;
        self.actionView.frame = CGRectMake(0, Design.DISPLAY_HEIGHT, Design.DISPLAY_WIDTH, self.actionView.frame.size.height);
    }
                     completion:^(BOOL finished) {
        [self finish];
    }];
}

- (void)handleConfirmTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleConfirmTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        if (!self.actionEnable) {
            return;
        }
        
        if (!self.hasProfile) {
            DefaultConfirmView *defaultConfirmView = [[DefaultConfirmView alloc] init];
            defaultConfirmView.confirmViewDelegate = self;

            UIImage *image = [self.twinmeApplication darkModeEnable:[self currentSpaceSettings]] ?  [UIImage imageNamed:@"OnboardingAddProfileDark"] : [UIImage imageNamed:@"OnboardingAddProfile"];
            [defaultConfirmView initWithTitle:TwinmeLocalizedString(@"create_profile_view_controller_title", nil) message:TwinmeLocalizedString(@"application_add_contact_no_profile", nil) image:image avatar:nil action:TwinmeLocalizedString(@"show_profile_view_controller_create_profile", nil) actionColor:nil cancel:nil];

            [self.view addSubview:defaultConfirmView];
            [defaultConfirmView showConfirmView];
        } else if (self.hasTwincode) {
            self.actionEnable = NO;
            self.confirmView.alpha = 0.5;
            self.cancelView.alpha = 0.5;
            [self.acceptInvitationService createContactWithProfile:self.profile space:self.space];
        }
    }
}

- (void)handleCancelTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleCancelTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        if (!self.actionEnable) {
            return;
        }
        
        if (self.descriptorId) {
            self.actionEnable = NO;
            self.confirmView.alpha = 0.5;
            self.cancelView.alpha = 0.5;
            [self.acceptInvitationService deleteDescriptor:self.descriptorId];
        } else {
            [self closeActionView];
        }
    }
}

- (void)incorrectQRCode {
    DDLogVerbose(@"%@ incorrectQRCode", LOG_TAG);
        
    AlertMessageView *alertMessageView = [[AlertMessageView alloc] init];
    alertMessageView.alertMessageViewDelegate = self;
    [alertMessageView initWithTitle:TwinmeLocalizedString(@"application_error", nil) message:TwinmeLocalizedString(@"accept_invitation_view_controller_incorrect_contact_information", nil)];
    [self.tabBarController.view addSubview:alertMessageView];
    [alertMessageView showAlertView];
}

- (void)incorrectQRCode:(TLBaseServiceErrorCode)errorCode {
    DDLogVerbose(@"%@ incorrectQRCode", LOG_TAG);
    
    NSString *message;
    
    switch (errorCode) {
        case TLBaseServiceErrorCodeBadRequest:
            message = TwinmeLocalizedString(@"add_contact_view_controller_scan_error_incorect_link", nil);
            break;
            
        case TLBaseServiceErrorCodeFeatureNotImplemented:
            message = TwinmeLocalizedString(@"add_contact_view_controller_scan_error_not_managed_link", nil);
            break;
            
        case TLBaseServiceErrorCodeItemNotFound:
            message = TwinmeLocalizedString(@"add_contact_view_controller_scan_error_corrupt_link", nil);
            break;
            
        default:
            message = TwinmeLocalizedString(@"capture_view_controller_incorrect_qrcode", nil);
            break;
    }
    
    AlertMessageView *alertMessageView = [[AlertMessageView alloc] init];
    alertMessageView.alertMessageViewDelegate = self;
    [alertMessageView initWithTitle:TwinmeLocalizedString(@"delete_account_view_controller_warning", nil) message:message];
    [self.tabBarController.view addSubview:alertMessageView];
    [alertMessageView showAlertView];
}

- (void)updateTwincode {
    DDLogVerbose(@"%@ updateTwincode", LOG_TAG);
    
    if (self.hasTwincode) {
        self.avatarContainerViewHeightConstraint.constant = DESIGN_AVATAR_HEIGHT * Design.HEIGHT_RATIO;
        self.cancelViewHeightConstraint.constant = DESIGN_CANCEL_HEIGHT * Design.HEIGHT_RATIO;
        self.confirmViewHeightConstraint.constant = DESIGN_CONFIRM_HEIGHT * Design.HEIGHT_RATIO;
        
        self.avatarContainerView.hidden = NO;
        self.bulletView.hidden = NO;
        self.iconView.hidden = NO;
        self.nameLabel.hidden = NO;
        self.confirmView.hidden = NO;
        self.cancelView.hidden = NO;
        
        if (self.hasProfile) {
            self.spaceViewHeightConstraint.constant = Design.SETTING_CELL_HEIGHT;
            self.spaceTitleLabel.hidden = NO;
            self.spaceView.hidden = NO;
        } else {
            self.spaceViewHeightConstraint.constant = 0;
            self.spaceTitleLabel.hidden = YES;
            self.spaceView.hidden = YES;
        }
        
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:self.contactName attributes:[NSDictionary dictionaryWithObjectsAndKeys: Design.FONT_BOLD44, NSFontAttributeName, Design.FONT_COLOR_DEFAULT, NSForegroundColorAttributeName, nil]];
        if (self.contactDescription && ![self.contactDescription isEqual:@""] && ![self.contactDescription isEqual:TwinmeLocalizedString(@"side_menu_view_controller_about", nil)]) {
            [attributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:@"\n"]];
            [attributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:self.contactDescription attributes:[NSDictionary dictionaryWithObjectsAndKeys: Design.FONT_MEDIUM30, NSFontAttributeName, Design.FONT_COLOR_GREY, NSForegroundColorAttributeName, nil]]];
        }
        
        self.nameLabel.attributedText = attributedString;
        self.avatarView.image = self.contactAvatar;
            
        if (self.hasExistingContact ) {
            self.messageLabel.text = TwinmeLocalizedString(@"add_contact_view_controller_existing_contact_message", nil);
        } else {
            self.messageLabel.text = [NSString stringWithFormat:TwinmeLocalizedString(@"accept_invitation_view_controller_message %@", nil), self.contactName];
        }
    } else {
        self.avatarContainerViewHeightConstraint.constant = 0;
        self.cancelViewHeightConstraint.constant = 0;
        self.spaceViewHeightConstraint.constant = 0;
        self.confirmViewHeightConstraint.constant = 0;
        
        self.avatarContainerView.hidden = YES;
        self.bulletView.hidden = YES;
        self.iconView.hidden = YES;
        self.nameLabel.hidden = YES;
        self.confirmView.hidden = YES;
        self.cancelView.hidden = YES;
        self.spaceTitleLabel.hidden = YES;
        self.spaceView.hidden = YES;
        
        self.messageLabel.text = [NSString stringWithFormat:@"%@\n%@", TwinmeLocalizedString(@"accept_invitation_view_controller_being_transferred", nil), TwinmeLocalizedString(@"accept_invitation_view_controller_check_connection", nil)];
    }
}

- (void)updateSpace {
    DDLogVerbose(@"%@ updateSpace", LOG_TAG);
    
    if (!self.space) {
        return;
    }
    
    NSString *nameSpace = @"";
    NSString *nameProfile = @"";
    if (self.space.settings.name) {
        nameSpace = self.space.settings.name;
    }
    if (self.space.profile.name) {
        nameProfile = self.space.profile.name;
    }
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@""];
    [attributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:nameSpace attributes:[NSDictionary dictionaryWithObjectsAndKeys:Design.FONT_MEDIUM34, NSFontAttributeName, Design.FONT_COLOR_DEFAULT, NSForegroundColorAttributeName, nil]]];
    [attributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:@"\n"]];
    [attributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:nameProfile attributes:[NSDictionary dictionaryWithObjectsAndKeys:Design.FONT_MEDIUM32, NSFontAttributeName, Design.FONT_COLOR_PROFILE_GREY, NSForegroundColorAttributeName, nil]]];
    self.spaceLabel.attributedText = attributedString;
        
    if (self.space.avatarId) {
        [self.acceptInvitationService getImageWithSpace:self.space withBlock:^(UIImage *image) {
            self.spaceAvatarView.image = image;
            self.spaceAvatarLabel.hidden = YES;
        }];
    } else {
        self.spaceAvatarView.image = nil;
        self.spaceAvatarLabel.hidden = NO;
        if (self.space.settings.style) {
            self.spaceAvatarView.backgroundColor = [UIColor colorWithHexString:self.space.settings.style alpha:1.0];
        } else {
            self.spaceAvatarView.backgroundColor = Design.MAIN_COLOR;
        }
        self.spaceAvatarLabel.text = [NSString firstCharacter:self.space.settings.name];
    }
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);

    self.messageLabel.font = Design.FONT_MEDIUM40;
    self.confirmLabel.font = Design.FONT_BOLD36;
    self.cancelLabel.font = Design.FONT_BOLD36;
    self.spaceTitleLabel.font = Design.FONT_BOLD26;
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    self.actionView.backgroundColor = Design.POPUP_BACKGROUND_COLOR;
    self.messageLabel.textColor = Design.FONT_COLOR_GREY;
    self.spaceTitleLabel.textColor = Design.FONT_COLOR_DEFAULT;
}

@end
