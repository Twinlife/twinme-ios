/*
 *  Copyright (c) 2023-2024 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <Twinlife/TLTwinlife.h>
#import <Twinlife/TLConversationService.h>
#import <Twinlife/TLTwincodeOutboundService.h>

#import <Twinme/TLProfile.h>
#import <Twinme/TLSpace.h>
#import <Twinme/UIImage+Resize.h>
#import <Twinme/TLTwinmeAttributes.h>

#import <Utils/NSString+Utils.h>

#import <TwinmeCommon/InvitationSubscriptionService.h>

#import "AcceptInvitationSubscriptionViewController.h"
#import <TwinmeCommon/MainViewController.h>

#import <TwinmeCommon/ApplicationDelegate.h>
#import <TwinmeCommon/Design.h>
#import "UIColor+Hex.h"
#import "UIView+Toast.h"
#import "UIViewController+ProgressIndicator.h"
#import <TwinmeCommon/TwinmeNavigationController.h>
#import "AlertMessageView.h"

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static const CGFloat DESIGN_AVATAR_HEIGHT = 148;
static const CGFloat DESIGN_CANCEL_HEIGHT = 140;

//
// Interface: AcceptInvitationSubscriptionViewController ()
//

@interface AcceptInvitationSubscriptionViewController () <AlertMessageViewDelegate, InvitationSubscriptionServiceDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *actionViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *actionViewBottomConstraint;
@property (weak, nonatomic) IBOutlet UIView *actionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *slideMarkViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *slideMarkViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *slideMarkViewWidthConstraint;
@property (weak, nonatomic) IBOutlet UIView *slideMarkView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *avatarViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *avatarViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *avatarViewWidthConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *avatarView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
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

@property (nonatomic) NSURL *url;
@property (nonatomic) BOOL actionEnable;
@property (nonatomic) BOOL setupDone;
@property (nonatomic) BOOL updatedContainerHeight;
@property (nonatomic) BOOL hasProfile;
@property (nonatomic) BOOL hasTwincode;
@property (nonatomic) NSString *contactName;
@property (nonatomic) NSString *contactDescription;
@property (nonatomic) UIImage *contactAvatar;
@property (nonatomic) NSUUID *peerTwincodeOutboundId;
@property (nonatomic) NSString *activationCode;

@property (nonatomic) InvitationSubscriptionService *invitationSubscriptionService;

@end

#undef LOG_TAG
#define LOG_TAG @"AcceptInvitationSubscriptionViewController"

@implementation AcceptInvitationSubscriptionViewController

#pragma mark - UIViewController

- (instancetype)initWithCoder:(NSCoder *)coder {
    DDLogVerbose(@"%@ initWithCoder: %@", LOG_TAG, coder);
    
    self = [super initWithCoder:coder];
    
    if (self) {
        _hasProfile = NO;
        _hasTwincode = NO;
        _setupDone = NO;
        _actionEnable = YES;
        _updatedContainerHeight = NO;
        _invitationSubscriptionService = [[InvitationSubscriptionService alloc] initWithTwinmeContext:self.twinmeContext delegate:self];
    }
    return self;
}

- (void)viewDidLoad {
    DDLogVerbose(@"%@ viewDidLoad", LOG_TAG);
    
    [super viewDidLoad];
    
    [self initViews];
}

- (void)initWithPeerTwincodeOutboundId:(nonnull NSUUID *)peerTwincodeOutboundId activationCode:(nonnull NSString *)activationCode {
    DDLogVerbose(@"%@ initWithPeerTwincodeOutboundId: %@ activationCode: %@", LOG_TAG, peerTwincodeOutboundId, activationCode);
    
    self.peerTwincodeOutboundId = peerTwincodeOutboundId;
    self.activationCode = activationCode;
}

#pragma mark - InvitationSubscriptionServiceDelegate

- (void)onGetTwincodeWithTwincode:(nonnull TLTwincodeOutbound *)twincode avatar:(nullable UIImage *)avatar {
    DDLogVerbose(@"%@ onGetTwincodeWithName: %@ avatar: %@", LOG_TAG, twincode, avatar);
    
    self.hasTwincode = true;
    
    self.contactName = twincode.name;
    self.contactDescription = twincode.twincodeDescription;
    self.contactAvatar = avatar;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateTwincode];
    });
}

- (void)onGetTwincodeNotFound {
    DDLogVerbose(@"%@ onGetTwincodeNotFound", LOG_TAG);
    
    AlertMessageView *alertMessageView = [[AlertMessageView alloc] init];
    alertMessageView.alertMessageViewDelegate = self;
    [alertMessageView initWithTitle:TwinmeLocalizedString(@"delete_account_view_controller_warning", nil) message:TwinmeLocalizedString(@"accept_invitation_view_controller_incorrect_contact_information", nil)];
    [self.view addSubview:alertMessageView];
    [alertMessageView showAlertView];
}

- (void)onSubscribeSuccess {
    DDLogVerbose(@"%@ onSubscribeSuccess", LOG_TAG);

    dispatch_async(dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication].keyWindow makeToast:TwinmeLocalizedString(@"in_app_subscription_view_controller_invitation_success",nil)];
    });
    
    [self saveTwincodeAttribute];
    [self.acceptInvitationSubscriptionDelegate invitationSubscriptionDidFinish:TLBaseServiceErrorCodeSuccess];
    [self finish];
}

- (void)onSubscribeFailed:(TLBaseServiceErrorCode)errorCode {
    DDLogVerbose(@"%@ onSubscribeFailed errorCode: %d", LOG_TAG, errorCode);

    [self.acceptInvitationSubscriptionDelegate invitationSubscriptionDidFinish:errorCode];
    [self finish];
}

- (void)viewDidLayoutSubviews {
    DDLogVerbose(@"%@ viewDidLayoutSubviews", LOG_TAG);
    
    [super viewDidLayoutSubviews];
    
    if (!self.setupDone) {
        [self setup];
    }
}

- (void)setup {
    DDLogVerbose(@"%@ setup", LOG_TAG);
    
    self.setupDone = YES;
    if (self.peerTwincodeOutboundId) {
        [self.invitationSubscriptionService getTwincodeOutboundWithTwincodeOutboundId:self.peerTwincodeOutboundId];
    } else {
        [self incorrectQRCode];
    }
}

- (void)showInView:(UIView *)view {
    DDLogVerbose(@"%@ showInView: %@", LOG_TAG, view);
    
    self.view.frame = view.frame;
    [view addSubview:self.view];
    [self showActionView];
}

#pragma mark - AlertMessageViewDelegate

- (void)didCloseAlertMessage:(nonnull AlertMessageView *)alertMessageView {
    DDLogVerbose(@"%@ didCloseAlertMessage: %@", LOG_TAG, alertMessageView);
    
    [alertMessageView closeAlertView];
}

- (void)didFinishCloseAlertMessageAnimation:(nonnull AlertMessageView *)alertMessageView {
    DDLogVerbose(@"%@ didFinishCloseAlertMessageAnimation: %@", LOG_TAG, alertMessageView);
    
    [alertMessageView removeFromSuperview];
    
    [self.acceptInvitationSubscriptionDelegate invitationSubscriptionDidCancel];
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
    
    self.avatarViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.avatarViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.avatarViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    
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

- (void)handleCloseTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleBackTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        
        [self.acceptInvitationSubscriptionDelegate invitationSubscriptionDidCancel];
        [self finish];
    }
}

- (void)finish {
    DDLogVerbose(@"%@ finish", LOG_TAG);
    
    [self.invitationSubscriptionService dispose];
    
    [self.view removeFromSuperview];
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
        
        if (self.hasTwincode) {
            self.actionEnable = NO;
            self.confirmView.alpha = 0.5;
            self.cancelView.alpha = 0.5;
            [self.invitationSubscriptionService subscribeFeature:self.peerTwincodeOutboundId.UUIDString activationCode:self.activationCode profileTwincodeOutboundId:self.currentSpace.profile.twincodeOutbound.uuid.UUIDString];
        }
    }
}

- (void)handleCancelTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleCancelTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        if (!self.actionEnable) {
            return;
        }

        self.actionEnable = NO;
        [self.acceptInvitationSubscriptionDelegate invitationSubscriptionDidCancel];
        [self closeActionView];
    }
}

- (void)incorrectQRCode {
    DDLogVerbose(@"%@ incorrectQRCode", LOG_TAG);
    
    AlertMessageView *alertMessageView = [[AlertMessageView alloc] init];
    alertMessageView.alertMessageViewDelegate = self;
    [alertMessageView initWithTitle:TwinmeLocalizedString(@"delete_account_view_controller_warning", nil) message:TwinmeLocalizedString(@"accept_invitation_view_controller_incorrect_contact_information", nil)];
    [self.view addSubview:alertMessageView];
    [alertMessageView showAlertView];
}

- (void)updateTwincode {
    DDLogVerbose(@"%@ updateTwincode", LOG_TAG);
        
    if (self.hasTwincode) {
        self.avatarViewHeightConstraint.constant = DESIGN_AVATAR_HEIGHT * Design.HEIGHT_RATIO;
        self.cancelViewHeightConstraint.constant = DESIGN_CANCEL_HEIGHT * Design.HEIGHT_RATIO;
        
        self.avatarView.hidden = NO;
        self.nameLabel.hidden = NO;
        self.confirmView.hidden = NO;
        self.cancelView.hidden = NO;
        
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:self.contactName attributes:[NSDictionary dictionaryWithObjectsAndKeys: Design.FONT_BOLD44, NSFontAttributeName, Design.FONT_COLOR_DEFAULT, NSForegroundColorAttributeName, nil]];
        if (self.contactDescription && ![self.contactDescription isEqual:@""] && ![self.contactDescription isEqual:TwinmeLocalizedString(@"side_menu_view_controller_about", nil)]) {
            [attributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:@"\n"]];
            [attributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:self.contactDescription attributes:[NSDictionary dictionaryWithObjectsAndKeys: Design.FONT_MEDIUM30, NSFontAttributeName, Design.FONT_COLOR_GREY, NSForegroundColorAttributeName, nil]]];
        }
        
        self.nameLabel.attributedText = attributedString;
        self.avatarView.image = self.contactAvatar;
            
        self.messageLabel.text = [NSString stringWithFormat:TwinmeLocalizedString(@"in_app_subscription_view_controller_accept_invitation", nil), self.contactName];
    } else {
        self.avatarViewHeightConstraint.constant = 0;
        self.cancelViewHeightConstraint.constant = 0;
        
        self.avatarView.hidden = YES;
        self.nameLabel.hidden = YES;
        self.confirmView.hidden = YES;
        self.cancelView.hidden = YES;
        
        self.messageLabel.text = [NSString stringWithFormat:@"%@\n%@", TwinmeLocalizedString(@"accept_invitation_view_controller_being_transferred", nil), TwinmeLocalizedString(@"accept_invitation_view_controller_check_connection", nil)];
    }
}

- (void)saveTwincodeAttribute {
    DDLogVerbose(@"%@ saveTwincodeAttribute", LOG_TAG);
    
    [self.twinmeApplication setInvitationSubscriptionTwincodeWithTwincode:self.peerTwincodeOutboundId];
    
    NSError *error = nil;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *groupURL = [fileManager containerURLForSecurityApplicationGroupIdentifier:[TLTwinlife APP_GROUP_NAME]];
   
    NSString *subscriptionPath = [groupURL.path stringByAppendingPathComponent:@"/subscription"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:subscriptionPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:subscriptionPath withIntermediateDirectories:NO attributes:nil error:&error];
    }
    
    NSString *imageName = [NSString stringWithFormat:@"%@/%@.png", subscriptionPath, self.peerTwincodeOutboundId] ;
    if ([[NSFileManager defaultManager] fileExistsAtPath:imageName]) {
        [[NSFileManager defaultManager] removeItemAtPath:imageName error:nil];
    }
    
    NSData *imageData = [NSData dataWithData:UIImagePNGRepresentation(self.contactAvatar)];
    [imageData writeToFile:imageName atomically:YES];
    [self.twinmeApplication setInvitationSubscriptionImageWithImage:imageName];
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    self.messageLabel.font = Design.FONT_MEDIUM40;
    self.confirmLabel.font = Design.FONT_BOLD36;
    self.cancelLabel.font = Design.FONT_BOLD36;
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    self.actionView.backgroundColor = Design.POPUP_BACKGROUND_COLOR;
    self.messageLabel.textColor = Design.FONT_COLOR_GREY;
    self.cancelLabel.textColor = Design.FONT_COLOR_DEFAULT;
}

@end

