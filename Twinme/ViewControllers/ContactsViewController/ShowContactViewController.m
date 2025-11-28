/*
 *  Copyright (c) 2016-2024 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Marouane Qasmi (Marouane.Qasmi@twinlife-systems.com)
 *   Chedi Baccari (Chedi.Baccari@twinlife-systems.com)
 *   Christian Jacquemot (Christian.Jacquemot@twinlife-systems.com)
 *   Fabrice Trescartes (fabrice.trescartes@twin.life)
 *   Stephane Carrez (Stephane.Carrez@twin.life)
 */

#import <CocoaLumberjack.h>

#import <Twinlife/TLImageService.h>

#import <Twinme/TLContact.h>
#import <Twinme/TLProfile.h>
#import <Twinme/TLSchedule.h>
#import <Twinme/TLSpace.h>

#import <Utils/NSString+Utils.h>

#import "ShowContactViewController.h"

#import <TwinmeCommon/CallViewController.h>
#import <TwinmeCommon/CoachMark.h>
#import <TwinmeCommon/Design.h>
#import <TwinmeCommon/ShowContactService.h>
#import <TwinmeCommon/TwinmeNavigationController.h>

#import "EditContactViewController.h"
#import "EditIdentityViewController.h"
#import "ConversationViewController.h"
#import "SpacesViewController.h"
#import "LastCallsViewController.h"
#import "ContactCapabilitiesViewController.h"
#import "CoachMarkViewController.h"
#import "ExportViewController.h"
#import "TypeCleanupViewController.h"
#import "ConversationFilesViewController.h"
#import "AuthentifiedRelationViewController.h"

#import "AlertMessageView.h"
#import "InsideBorderView.h"
#import "DeviceAuthorization.h"
#import "OnboardingConfirmView.h"
#import "SlideContactView.h"
#import "MenuCertifyView.h"
#import "UIColor+Hex.h"
#import "PaddingLabel.h"
#import "UIView+Toast.h"

#import <TwinmeCommon/CoachMark.h>
#import <TwinmeCommon/Design.h>
#import <TwinmeCommon/CallViewController.h>
#import <TwinmeCommon/TwinmeNavigationController.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static CGFloat DESIGN_NAME_DEFAULT_WIDTH = 420;

#define DELAY_COACH_MARK 0.5

//
// Interface: ShowContactViewController ()
//

@class ShowContactViewControllerTwinmeContextDelegate;

@interface ShowContactViewController () <ShowContactServiceDelegate, AlertMessageViewDelegate, CoachMarkDelegate, MenuCertifyViewDelegate, ConfirmViewDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameLabelXConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *certifiedRelationImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *certifiedRelationImageViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *certifiedRelationImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *chatViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *chatViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *chatViewTopConstraint;
@property (weak, nonatomic) IBOutlet UIView *chatView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *chatImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *chatRoundedView;
@property (weak, nonatomic) IBOutlet UILabel *chatLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *videoViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *videoViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *videoViewTopConstraint;
@property (weak, nonatomic) IBOutlet UIView *videoRoundedView;
@property (weak, nonatomic) IBOutlet UIView *videoView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *videoImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UILabel *videoLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *audioViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *audioViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *audioViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *audioViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *audioViewTopConstraint;
@property (weak, nonatomic) IBOutlet UIView *audioRoundedView;
@property (weak, nonatomic) IBOutlet UIView *audioView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *audioImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UILabel *audioLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *authentifiedRelationViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *authentifiedRelationViewTopConstraint;
@property (weak, nonatomic) IBOutlet InsideBorderView *authentifiedRelationView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *authentifiedRelationImageViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *authentifiedRelationImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *authentifiedRelationImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *authentifiedRelationLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *authentifiedRelationLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *authentifiedRelationLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *authentifiedRelationAccessoryViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *authentifiedRelationAccessoryViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *authentifiedRelationAccessoryView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *settingsTitleLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *settingsTitleLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *settingsTitleLabelTopConstraint;
@property (weak, nonatomic) IBOutlet UILabel *settingsTitleLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *settingsViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *settingsViewTopConstraint;
@property (weak, nonatomic) IBOutlet InsideBorderView *settingsView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *settingsImageViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *settingsImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *settingsImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *settingsLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *settingsLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *settingsLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *settingsNewLabelHeightConstraint;
@property (weak, nonatomic) IBOutlet PaddingLabel *settingsNewLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *settingsAccessoryViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *settingsAccessoryViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *settingsAccessoryView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *historyTitleLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *historyTitleLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *historyTitleLabelTopConstraint;
@property (weak, nonatomic) IBOutlet UILabel *historyTitleLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lastCallViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lastCallViewTopConstraint;
@property (weak, nonatomic) IBOutlet InsideBorderView *lastCallView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lastCallImageViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lastCallImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lastCallLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lastCallLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *lastCallLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lastCallAccessoryViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lastCallAccessoryViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *lastCallAccessoryView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *spaceViewHeightConstraint;
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
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *conversationsTitleLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *conversationsTitleLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *conversationsTitleLabelTopConstraint;
@property (weak, nonatomic) IBOutlet UILabel *conversationsTitleLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *filesViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *filesViewTopConstraint;
@property (weak, nonatomic) IBOutlet InsideBorderView *filesView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *filesImageViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *filesImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *filesImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *filesLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *filesLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *filesLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *filesAccessoryViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *filesAccessoryViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *filesAccessoryView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *exportViewHeightConstraint;
@property (weak, nonatomic) IBOutlet InsideBorderView *exportView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *exportImageViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *exportImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *exportImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *exportLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *exportLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *exportLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *exportAccessoryViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *exportAccessoryViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *exportAccessoryView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cleanViewHeightConstraint;
@property (weak, nonatomic) IBOutlet InsideBorderView *cleanView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cleanImageViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cleanImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *cleanImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cleanLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cleanLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *cleanLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cleanAccessoryViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cleanAccessoryViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *cleanAccessoryView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fallbackImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fallbackImageViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fallbackImageViewTopConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *fallbackImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fallbackLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fallbackLabelTopConstraint;
@property (weak, nonatomic) IBOutlet UILabel *fallbackLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *removeViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UILabel *removeLabel;

@property (nonatomic) TLContact *contact;
@property (nonatomic) NSString *contactName;
@property (nonatomic) NSString *contactDescription;
@property (nonatomic) UIImage *contactAvatar;

@property (nonatomic) ShowContactService *showContactService;

@property (nonatomic) BOOL startCertifyCall;

@end

//
// Implementation: ShowContactViewController
//

#undef LOG_TAG
#define LOG_TAG @"ShowContactViewController"

@implementation ShowContactViewController

#pragma mark - UIViewController

- (instancetype)initWithCoder:(NSCoder *)coder {
    DDLogVerbose(@"%@ initWithCoder: %@", LOG_TAG, coder);
    
    self = [super initWithCoder:coder];
    
    if (self) {
        _startCertifyCall = NO;
        _showContactService = [[ShowContactService alloc] initWithTwinmeContext:self.twinmeContext delegate:self];
    }
    return self;
}

- (void)viewDidLoad {
    DDLogVerbose(@"%@ viewDidLoad", LOG_TAG);
    
    [super viewDidLoad];
    
    [self initViews];
    
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    DDLogVerbose(@"%@ viewWillAppear: %@", LOG_TAG, animated ? @"YES" : @"NO");
    
    [super viewWillAppear:animated];

    self.startCertifyCall = NO;
    [self showCoachMark];
    [self updateContact];
}

- (void)viewWillDisappear:(BOOL)animated {
    DDLogVerbose(@"%@ viewWillDisappear: %@", LOG_TAG, animated ? @"YES" : @"NO");
    
    [super viewWillDisappear:animated];
}

#pragma mark - Public methods

- (void)initWithContact:(TLContact *)contact {
    DDLogVerbose(@"%@ initWithContact: %@", LOG_TAG, contact);
    
    self.contact = contact;
    [self.showContactService initWithContact:contact];
    
    self.contactName = self.contact.name;
    
    if ([self.contact hasPrivateIdentity]) {
        self.identityName = self.contact.identityName;
        [self.showContactService getIdentityImageWithContact:contact withBlock:^(UIImage *image) {
            self.identityAvatar = image;
        }];
    } else {
        self.identityName = nil;
        self.identityAvatar = [TLContact ANONYMOUS_AVATAR];
    }
    
    if (self.contact.objectDescription.length > 0) {
        self.contactDescription = self.contact.objectDescription;
    } else {
        self.contactDescription = self.contact.peerDescription;
    }
    
    [self checkSpacePermission];
}

- (void)editTap {
    DDLogVerbose(@"%@ editTap", LOG_TAG);
    
    if (self.contact) {
        self.navigationController.navigationBarHidden = NO;
        EditContactViewController *editContactViewController = (EditContactViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"EditContactViewController"];
        editContactViewController.contact = self.contact;
        [self.navigationController pushViewController:editContactViewController animated:YES];
    }
}

- (void)identityTap {
    DDLogVerbose(@"%@ identityTap", LOG_TAG);
    
    if ([self.contact hasPrivatePeer]) {
        if (![self.contact.space hasPermission:TLSpacePermissionTypeUpdateIdentity]) {
            AlertMessageView *alertMessageView = [[AlertMessageView alloc] init];
            alertMessageView.alertMessageViewDelegate = self;
            [alertMessageView initWithTitle:TwinmeLocalizedString(@"delete_account_view_controller_warning", nil) message:TwinmeLocalizedString(@"spaces_view_controller_permission_not_allowed", nil)];
            [self.view addSubview:alertMessageView];
            [alertMessageView showAlertView];
        } else {
            self.navigationController.navigationBarHidden = NO;
            EditIdentityViewController *editIdentityViewController = (EditIdentityViewController *)[[UIStoryboard storyboardWithName:@"iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"EditIdentityViewController"];
            [editIdentityViewController initWithContact:self.contact];
            [self.navigationController pushViewController:editIdentityViewController animated:YES];
        }
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication].keyWindow makeToast:TwinmeLocalizedString(@"show_contact_view_controller_pending_message",nil)];
        });
    }
}

- (BOOL)showNavigationBar {
    DDLogVerbose(@"%@ showNavigationBar", LOG_TAG);
    
    if (self.contact) {
        return self.contact.hasPeer;
    }
    
    return NO;
}

- (int)getActionViewHeight {
    DDLogVerbose(@"%@ getActionViewHeight", LOG_TAG);
    
    UIWindow *window = UIApplication.sharedApplication.keyWindow;
    CGFloat safeAreaInset = window.safeAreaInsets.bottom;
    
    return self.cleanView.frame.origin.y + self.cleanViewHeightConstraint.constant + safeAreaInset;
}

#pragma mark - ShowContactServiceDelegate

- (void)onRefreshContactAvatar:(nonnull UIImage *)avatar {
    DDLogVerbose(@"%@ onRefreshContactAvatar: %@", LOG_TAG, avatar);

    self.contactAvatar = avatar;
    self.avatarView.image = avatar;
}

- (void)onUpdateContact:(nonnull TLContact *)contact avatar:(nullable UIImage *)avatar {
    DDLogVerbose(@"%@ onUpdateContact: %@", LOG_TAG, contact);
    
    if (!self.contact || ![contact.uuid isEqual:self.contact.uuid]) {
        return;
    }
    
    self.contact = contact;
    if (self.contact.hasPeer) {
        self.contactName = self.contact.name;
        if (avatar) {
            self.contactAvatar = avatar;
        }
        if ([self.contact hasPrivateIdentity]) {
            self.identityName = self.contact.identityName;
            [self.showContactService getIdentityImageWithContact:contact withBlock:^(UIImage *image) {
                self.identityAvatar = image;
            }];
        } else {
            self.identityName = nil;
            self.identityAvatar = [TLContact ANONYMOUS_AVATAR];
        }
        
        if (self.contact.objectDescription.length > 0) {
            self.contactDescription = self.contact.objectDescription;
        } else {
            self.contactDescription = self.contact.peerDescription;
        }
    } else {
        self.scrollView.hidden = YES;
        self.fallbackView.hidden = NO;
        self.backClickableView.hidden = YES;
        self.navigationController.navigationBarHidden = NO;
        self.contactAvatar = [TLContact ANONYMOUS_AVATAR];
    }
    
    [self updateContact];
    [self checkSpacePermission];
}

- (void)onDeleteContact:(NSUUID *)contactId {
    DDLogVerbose(@"%@ onDeleteContact: %@", LOG_TAG, contactId);
    
    if (!self.contact || ![contactId isEqual:self.contact.uuid]) {
        return;
    }
    
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
}

#pragma mark - CoachMarkDelegate

- (void)didTapCoachMarkOverlay:(CoachMarkViewController *)coachMarkViewController {
    DDLogVerbose(@"%@ didTapCoachMarkOverlay: %@", LOG_TAG, coachMarkViewController);
    
    [coachMarkViewController closeView];
}

- (void)didTapCoachMarkFeature:(CoachMarkViewController *)coachMarkViewController {
    DDLogVerbose(@"%@ didTapCoachMarkFeature: %@", LOG_TAG, coachMarkViewController);
    
    [self.twinmeApplication hideCoachMark:[[coachMarkViewController getCoachMark] coachMarkTag]];
    [coachMarkViewController closeView];
    
    self.navigationController.navigationBarHidden = NO;
    ContactCapabilitiesViewController *contactCapabilitiesViewController = (ContactCapabilitiesViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"ContactCapabilitiesViewController"];
    [contactCapabilitiesViewController initWithContact:self.contact];
    [self.navigationController pushViewController:contactCapabilitiesViewController animated:YES];
}

- (void)didLongPressCoachMarkFeature:(CoachMarkViewController *)coachMarkViewController {
    DDLogVerbose(@"%@ didLongPressCoachMarkFeature: %@", LOG_TAG, coachMarkViewController);
    
}

#pragma mark - MenuCertifyViewDelegate

- (void)menuCertifyCancel:(MenuCertifyView *)menuCertifyView; {
    DDLogVerbose(@"%@ menuCertifyCancel", LOG_TAG);
    
    [menuCertifyView removeFromSuperview];
}

- (void)menuCertifyStartScan:(MenuCertifyView *)menuCertifyView; {
    DDLogVerbose(@"%@ menuCertifyStartScan", LOG_TAG);
    
    [menuCertifyView removeFromSuperview];
    
    self.navigationController.navigationBarHidden = NO;
    AuthentifiedRelationViewController *authentifiedRelationViewController = (AuthentifiedRelationViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"AuthentifiedRelationViewController"];
    [authentifiedRelationViewController initWithContact:self.contact];
    [self.navigationController pushViewController:authentifiedRelationViewController animated:YES];
}

- (void)menuCertifyStartVideoCall:(MenuCertifyView *)menuCertifyView; {
    DDLogVerbose(@"%@ menuCertifyStartVideoCall", LOG_TAG);
    
    [menuCertifyView removeFromSuperview];
    
    if (!self.contact.capabilities.hasVideo) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication].keyWindow makeToast:[NSString stringWithFormat:TwinmeLocalizedString(@"authentified_relation_view_controller_certify_by_video_call_missing_capability",nil), self.contactName]];
        });
        return;
    }
    
    if ([self.twinmeApplication startOnboarding:OnboardingTypeCertifiedRelation]) {
        OnboardingConfirmView *onboardingConfirmView = [[OnboardingConfirmView alloc] init];
        onboardingConfirmView.confirmViewDelegate = self;
        onboardingConfirmView.tag = OnboardingTypeCertifiedRelation;
        UIImage *image = [self.twinmeApplication darkModeEnable:[self currentSpaceSettings]] ? [UIImage imageNamed:@"OnboardingAuthentifiedRelationDark"] : [UIImage imageNamed:@"OnboardingAuthentifiedRelation"];
        NSString *message = [NSString stringWithFormat:@"%@\n\n%@", TwinmeLocalizedString(@"authentified_relation_view_controller_onboarding_message", nil), TwinmeLocalizedString(@"call_view_controller_certify_onboarding_message", nil)];
        
        NSMutableAttributedString *attributedTitle = [[NSMutableAttributedString alloc] initWithString:TwinmeLocalizedString(@"authentified_relation_view_controller_to_be_certified_title", nil) attributes:[NSDictionary dictionaryWithObjectsAndKeys:Design.FONT_BOLD36, NSFontAttributeName, Design.FONT_COLOR_DEFAULT, NSForegroundColorAttributeName, nil]];
        [attributedTitle appendAttributedString:[[NSMutableAttributedString alloc] initWithString:@"\n\n"]];
        [attributedTitle appendAttributedString:[[NSMutableAttributedString alloc] initWithString:TwinmeLocalizedString(@"authentified_relation_view_controller_onboarding_subtitle", nil) attributes:[NSDictionary dictionaryWithObjectsAndKeys:Design.FONT_MEDIUM34, NSFontAttributeName, Design.FONT_COLOR_GREY, NSForegroundColorAttributeName, nil]]];
                
        [onboardingConfirmView initWithTitle:TwinmeLocalizedString(@"authentified_relation_view_controller_to_be_certified_title", nil) message:message image:image action:TwinmeLocalizedString(@"authentified_relation_view_controller_start", nil) actionColor:nil cancel:TwinmeLocalizedString(@"application_do_not_display", nil)];
        [onboardingConfirmView updateTitle:attributedTitle];
        
        [self.navigationController.view addSubview:onboardingConfirmView];
        [onboardingConfirmView showConfirmView];
    } else {
        [self startCertifyByVideoCall];
    }
}

- (void)startCertifyByVideoCall {
    DDLogVerbose(@"%@ startCertifyByVideoCall", LOG_TAG);
    
    if (self.contact && !self.twinmeApplication.inCall && self.contact.capabilities.hasVideo && ![self hasSchedule]) {
        self.startCertifyCall = YES;
        [self startVideoCallWithPermissionCheck:NO];
    } else if (!self.contact.capabilities.hasVideo) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication].keyWindow makeToast:TwinmeLocalizedString(@"application_not_authorized_operation_by_your_contact",nil)];
        });
    } else if ([self hasSchedule]) {
        [self showSchedule];
    }
}

#pragma mark - ConfirmViewDelegate

- (void)didTapConfirm:(nonnull AbstractConfirmView *)abstractConfirmView {
    DDLogVerbose(@"%@ didTapConfirm: %@", LOG_TAG, abstractConfirmView);
    
    if (abstractConfirmView.tag == OnboardingTypeCertifiedRelation){
        [self startCertifyByVideoCall];
    }
    
    [abstractConfirmView closeConfirmView];
}

- (void)didTapCancel:(nonnull AbstractConfirmView *)abstractConfirmView {
    DDLogVerbose(@"%@ didTapCancel: %@", LOG_TAG, abstractConfirmView);
    
    if (abstractConfirmView.tag == OnboardingTypeCertifiedRelation){
        [self.twinmeApplication setShowOnboardingType:OnboardingTypeCertifiedRelation state:NO];
        [self startCertifyByVideoCall];
    }
    
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
    
    self.certifiedRelationImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.certifiedRelationImageViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.certifiedRelationImageView.hidden = YES;
    
    self.chatViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.chatViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.chatViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.chatView.isAccessibilityElement = YES;
    UITapGestureRecognizer *chatViewGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleChatTapGesture:)];
    [self.chatView addGestureRecognizer:chatViewGestureRecognizer];
    [self.chatView setAccessibilityLabel:TwinmeLocalizedString(@"conversations_view_controller_title", nil)];
    
    self.chatRoundedView.backgroundColor = Design.CHAT_COLOR;
    self.chatRoundedView.layer.cornerRadius = self.chatViewWidthConstraint.constant * 0.5;
    
    self.chatImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.chatLabel.font = Design.FONT_REGULAR28;
    self.chatLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.chatLabel.text = TwinmeLocalizedString(@"show_contact_view_controller_chat", nil);
    
    self.videoViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.videoViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.videoViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.videoView.isAccessibilityElement = YES;
    UITapGestureRecognizer *videoViewGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleVideoTapGesture:)];
    [self.videoView addGestureRecognizer:videoViewGestureRecognizer];
    [self.videoView setAccessibilityLabel:TwinmeLocalizedString(@"conversation_view_controller_video_call", nil)];
    
    self.videoRoundedView.backgroundColor = Design.VIDEO_CALL_COLOR;
    self.videoRoundedView.layer.cornerRadius = self.videoViewWidthConstraint.constant * 0.5;
    
    self.videoImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.videoLabel.font = Design.FONT_REGULAR28;
    self.videoLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.videoLabel.text = TwinmeLocalizedString(@"show_contact_view_controller_video", nil);
    
    self.audioViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.audioViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.audioViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.audioViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.audioViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.audioView.isAccessibilityElement = YES;
    UITapGestureRecognizer *audioViewGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleAudioTapGesture:)];
    [self.audioView addGestureRecognizer:audioViewGestureRecognizer];
    [self.audioView setAccessibilityLabel:TwinmeLocalizedString(@"conversation_view_controller_audio_call", nil)];
    
    self.audioRoundedView.backgroundColor = Design.AUDIO_CALL_COLOR;
    self.audioRoundedView.layer.cornerRadius = self.audioViewWidthConstraint.constant * 0.5;
    
    self.audioImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.audioLabel.font = Design.FONT_REGULAR28;
    self.audioLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.audioLabel.text = TwinmeLocalizedString(@"show_contact_view_controller_audio", nil);
    
    self.authentifiedRelationViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.authentifiedRelationViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    UITapGestureRecognizer *authentifiedRelationViewGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleAuthentifiedRelationTapGesture:)];
    [self.authentifiedRelationView addGestureRecognizer:authentifiedRelationViewGestureRecognizer];
    
    [self.authentifiedRelationView setBorder:Design.SEPARATOR_COLOR_GREY borderWidth:Design.SEPARATOR_HEIGHT width:Design.DISPLAY_WIDTH height:self.authentifiedRelationViewHeightConstraint.constant left:false right:false top:true bottom:true];
    
    self.authentifiedRelationImageViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.authentifiedRelationImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.authentifiedRelationImageView.tintColor = Design.UNSELECTED_TAB_COLOR;
    
    self.authentifiedRelationLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.authentifiedRelationLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;

    self.authentifiedRelationLabel.text = TwinmeLocalizedString(@"authentified_relation_view_controller_title", nil);
    self.authentifiedRelationLabel.font = Design.FONT_REGULAR34;
    self.authentifiedRelationLabel.textColor = Design.FONT_COLOR_DEFAULT;
    
    self.authentifiedRelationAccessoryViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.authentifiedRelationAccessoryViewTrailingConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.authentifiedRelationAccessoryView.tintColor = Design.ACCESSORY_COLOR;
    self.authentifiedRelationAccessoryView.image = [self.authentifiedRelationAccessoryView.image imageFlippedForRightToLeftLayoutDirection];
    
    self.settingsTitleLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.settingsTitleLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.settingsTitleLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.settingsTitleLabel.font = Design.FONT_BOLD26;
    self.settingsTitleLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.settingsTitleLabel.text = TwinmeLocalizedString(@"settings_view_controller_title", nil).uppercaseString;
    
    self.settingsViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.settingsViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    UITapGestureRecognizer *settingsViewGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSettingsTapGesture:)];
    [self.settingsView addGestureRecognizer:settingsViewGestureRecognizer];
    
    [self.settingsView setBorder:Design.SEPARATOR_COLOR_GREY borderWidth:Design.SEPARATOR_HEIGHT width:Design.DISPLAY_WIDTH height:self.settingsViewHeightConstraint.constant left:false right:false top:true bottom:true];
    
    self.settingsImageViewLeadingConstraint.constant *= Design.HEIGHT_RATIO;
    self.settingsImageViewHeightConstraint.constant *= Design.WIDTH_RATIO;
    self.settingsImageView.tintColor = Design.UNSELECTED_TAB_COLOR;
    
    self.settingsLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.settingsLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.settingsLabel.text = TwinmeLocalizedString(@"contact_capabilities_view_controller_call_settings", nil);
    
    self.settingsNewLabelHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.settingsNewLabel.font = Design.FONT_MEDIUM32;
    self.settingsNewLabel.textColor = [UIColor whiteColor];
    
    self.settingsNewLabel.textAlignment = NSTextAlignmentCenter;
    self.settingsNewLabel.insets = UIEdgeInsetsMake(0, Design.TEXT_PADDING, 0, Design.TEXT_PADDING);
    self.settingsNewLabel.text = TwinmeLocalizedString(@"application_new", nil);
    
    self.settingsNewLabel.clipsToBounds = YES;
    self.settingsNewLabel.userInteractionEnabled = YES;
    self.settingsNewLabel.backgroundColor = Design.MAIN_COLOR;
    self.settingsNewLabel.layer.cornerRadius = self.settingsNewLabelHeightConstraint.constant * 0.5;
    
    UITapGestureRecognizer *settingsNewFeatureViewGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSettingsNewFeatureTapGesture:)];
    [self.settingsNewLabel addGestureRecognizer:settingsNewFeatureViewGestureRecognizer];
    
    self.settingsAccessoryViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.settingsAccessoryViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.settingsAccessoryView.tintColor = Design.ACCESSORY_COLOR;
    self.settingsAccessoryView.image = [self.settingsAccessoryView.image imageFlippedForRightToLeftLayoutDirection];
    
    self.historyTitleLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.historyTitleLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.historyTitleLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.historyTitleLabel.font = Design.FONT_BOLD26;
    self.historyTitleLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.historyTitleLabel.text = TwinmeLocalizedString(@"show_contact_view_controller_history_title", nil).uppercaseString;
    
    self.lastCallAccessoryViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.lastCallAccessoryViewHeightConstraint.constant = Design.ACCESSORY_HEIGHT;
    self.lastCallAccessoryView.tintColor = Design.ACCESSORY_COLOR;
    self.lastCallAccessoryView.image = [self.lastCallAccessoryView.image imageFlippedForRightToLeftLayoutDirection];
    
    self.lastCallViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.lastCallViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    UITapGestureRecognizer *lastCallViewGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleLastCallsTapGesture:)];
    [self.lastCallView addGestureRecognizer:lastCallViewGestureRecognizer];
    
    [self.lastCallView setBorder:Design.SEPARATOR_COLOR_GREY borderWidth:Design.SEPARATOR_HEIGHT width:Design.DISPLAY_WIDTH height:self.lastCallViewHeightConstraint.constant left:false right:false top:true bottom:true];
    
    self.lastCallImageViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.lastCallImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.lastCallLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.lastCallLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.lastCallLabel.text = TwinmeLocalizedString(@"show_contact_view_controller_last_calls", nil);
    self.lastCallLabel.font = Design.FONT_REGULAR34;
    self.lastCallLabel.textColor = Design.FONT_COLOR_DEFAULT;
    
    self.spaceViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    UITapGestureRecognizer *spaceViewGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSpaceTapGesture:)];
    [self.spaceView addGestureRecognizer:spaceViewGestureRecognizer];
    
    [self.spaceView setBorder:Design.SEPARATOR_COLOR_GREY borderWidth:Design.SEPARATOR_HEIGHT width:Design.DISPLAY_WIDTH height:self.spaceViewHeightConstraint.constant left:false right:false top:false bottom:true];
    
    self.spaceImageViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.spaceImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.spaceImageView.tintColor = Design.UNSELECTED_TAB_COLOR;
    
    self.spaceAvatarLabel.font = Design.FONT_BOLD44;
    self.spaceAvatarLabel.textColor = [UIColor whiteColor];
    self.spaceAvatarLabel.hidden = YES;
    
    NSString *nameSpace = @"";
    NSString *nameProfile = @"";
    if (self.contact.space.settings.name) {
        nameSpace = self.contact.space.settings.name;
    }
    if (self.contact.space.profile.name) {
        nameProfile = self.contact.space.profile.name;
    }
    
    self.spaceLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.spaceLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@""];
    [attributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:nameSpace attributes:[NSDictionary dictionaryWithObjectsAndKeys:Design.FONT_MEDIUM34, NSFontAttributeName, Design.FONT_COLOR_DEFAULT, NSForegroundColorAttributeName, nil]]];
    [attributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:@"\n"]];
    [attributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:nameProfile attributes:[NSDictionary dictionaryWithObjectsAndKeys:Design.FONT_MEDIUM32, NSFontAttributeName, Design.FONT_COLOR_PROFILE_GREY, NSForegroundColorAttributeName, nil]]];
    self.spaceLabel.attributedText = attributedString;
    
    self.spaceAvatarViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.spaceAvatarViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.spaceAvatarView.clipsToBounds = YES;
    self.spaceAvatarView.layer.cornerRadius = Design.SPACE_RADIUS_RATIO * self.spaceAvatarViewHeightConstraint.constant;
    
    [self getImageWithService:self.showContactService space:self.contact.space withBlock:^(UIImage *image) {
        self.spaceAvatarView.image = image;
    }];
    
    self.conversationsTitleLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.conversationsTitleLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.conversationsTitleLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.conversationsTitleLabel.font = Design.FONT_BOLD26;
    self.conversationsTitleLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.conversationsTitleLabel.text = TwinmeLocalizedString(@"conversations_view_controller_title", nil).uppercaseString;
    
    self.filesViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.filesViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    UITapGestureRecognizer *filesViewGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleFilesTapGesture:)];
    [self.filesView addGestureRecognizer:filesViewGestureRecognizer];
    
    [self.filesView setBorder:Design.SEPARATOR_COLOR_GREY borderWidth:Design.SEPARATOR_HEIGHT width:Design.DISPLAY_WIDTH height:self.filesViewHeightConstraint.constant left:false right:false top:true bottom:true];
    
    self.filesImageViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.filesImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.filesImageView.tintColor = Design.UNSELECTED_TAB_COLOR;
    
    self.filesLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.filesLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.filesLabel.text = TwinmeLocalizedString(@"conversation_files_view_controller_title", nil);
    self.filesLabel.font = Design.FONT_REGULAR34;
    self.filesLabel.textColor = Design.FONT_COLOR_DEFAULT;
    
    self.filesAccessoryViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.filesAccessoryViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.filesAccessoryView.tintColor = Design.ACCESSORY_COLOR;
    self.filesAccessoryView.image = [self.filesAccessoryView.image imageFlippedForRightToLeftLayoutDirection];
    
    self.exportViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    UITapGestureRecognizer *exportViewGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleExportTapGesture:)];
    [self.exportView addGestureRecognizer:exportViewGestureRecognizer];
    
    [self.exportView setBorder:Design.SEPARATOR_COLOR_GREY borderWidth:Design.SEPARATOR_HEIGHT width:Design.DISPLAY_WIDTH height:self.exportViewHeightConstraint.constant left:false right:false top:true bottom:true];
    
    self.exportImageViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.exportImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.exportImageView.tintColor = Design.UNSELECTED_TAB_COLOR;
    
    self.exportLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.exportLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.exportLabel.text = TwinmeLocalizedString(@"show_contact_view_controller_export_contents", nil);
    self.exportLabel.font = Design.FONT_REGULAR34;
    self.exportLabel.textColor = Design.FONT_COLOR_DEFAULT;
    
    self.exportAccessoryViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.exportAccessoryViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.exportAccessoryView.tintColor = Design.ACCESSORY_COLOR;
    self.exportAccessoryView.image = [self.exportAccessoryView.image imageFlippedForRightToLeftLayoutDirection];
    
    self.cleanViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    UITapGestureRecognizer *cleanViewGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleCleanTapGesture:)];
    [self.cleanView addGestureRecognizer:cleanViewGestureRecognizer];
    
    [self.cleanView setBorder:Design.SEPARATOR_COLOR_GREY borderWidth:Design.SEPARATOR_HEIGHT width:Design.DISPLAY_WIDTH height:self.cleanViewHeightConstraint.constant left:false right:false top:true bottom:true];
    
    self.cleanImageViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.cleanImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.cleanImageView.tintColor = Design.UNSELECTED_TAB_COLOR;
    
    self.cleanLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.cleanLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.cleanLabel.text = TwinmeLocalizedString(@"show_contact_view_controller_cleanup", nil);
    self.cleanLabel.font = Design.FONT_REGULAR34;
    self.cleanLabel.textColor = Design.FONT_COLOR_DEFAULT;
    
    self.cleanAccessoryViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.cleanAccessoryViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.cleanAccessoryView.tintColor = Design.ACCESSORY_COLOR;
    self.cleanAccessoryView.image = [self.cleanAccessoryView.image imageFlippedForRightToLeftLayoutDirection];
    
    self.fallbackView.backgroundColor = Design.WHITE_COLOR;
    
    self.fallbackImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.fallbackImageViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.fallbackImageViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.fallbackLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.fallbackLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.fallbackLabel.font = Design.FONT_MEDIUM34;
    self.fallbackLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.fallbackLabel.text = TwinmeLocalizedString(@"application_contact_not_found", nil);
    
    self.removeViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.removeLabel.font = Design.FONT_MEDIUM34;
    self.removeLabel.textColor = [UIColor redColor];
    self.removeLabel.text = TwinmeLocalizedString(@"application_delete", nil);
    self.removeLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *removeViewGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleRemoveTapGesture:)];
    [self.removeLabel addGestureRecognizer:removeViewGestureRecognizer];
    
    self.fallbackView.hidden = YES;
    
    if (![self.contact hasPeer]) {
        self.scrollView.hidden = YES;
        self.navigationController.navigationBarHidden = NO;
        self.fallbackView.hidden = NO;
        self.backClickableView.hidden = YES;
        [self setNavigationTitle:self.contact.name];
    }
    
    [self updateContact];
}

- (void)finish {
    DDLogVerbose(@"%@ finish", LOG_TAG);
    
    if (self.showContactService) {
        [self.showContactService dispose];
        self.showContactService = nil;
    }
    
    self.navigationController.navigationBarHidden = NO;
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)handleSpaceTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleSpaceTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        if (![self.contact.space hasPermission:TLSpacePermissionTypeMoveContact]) {
            AlertMessageView *alertMessageView = [[AlertMessageView alloc] init];
            alertMessageView.alertMessageViewDelegate = self;
            [alertMessageView initWithTitle:TwinmeLocalizedString(@"delete_account_view_controller_warning", nil) message:TwinmeLocalizedString(@"spaces_view_controller_permission_not_allowed", nil)];
            [self.view addSubview:alertMessageView];
            [alertMessageView showAlertView];
        } else {
            SpacesViewController *spacesViewController = [[UIStoryboard storyboardWithName:@"Space" bundle:nil] instantiateViewControllerWithIdentifier:@"SpacesViewController"];
            [spacesViewController initWithContact:self.contact];
            spacesViewController.pickerMode = YES;
            TwinmeNavigationController *navigationController = [[TwinmeNavigationController alloc] initWithRootViewController:spacesViewController];
            [self.navigationController presentViewController:navigationController animated:YES completion:nil];
            self.startModal = YES;
        }
    }
}

- (void)handleChatTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleChatTapGesture: %@", LOG_TAG, sender);
    
    if (self.contact && sender.state == UIGestureRecognizerStateEnded) {
        self.navigationController.navigationBarHidden = NO;
        ConversationViewController *conversationViewController = (ConversationViewController *)[[UIStoryboard storyboardWithName:@"iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"ConversationViewController"];
        [conversationViewController initWithContact:self.contact];
        [self.navigationController pushViewController:conversationViewController animated:YES];
    }
}

- (void)handleVideoTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleVideoTapGesture: %@", LOG_TAG, sender);
    
    if (self.contact && sender.state == UIGestureRecognizerStateEnded && !self.twinmeApplication.inCall && self.contact.capabilities.hasVideo && ![self hasSchedule]) {
        [self startVideoCallWithPermissionCheck:NO];
    } else if (!self.contact.capabilities.hasVideo) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication].keyWindow makeToast:TwinmeLocalizedString(@"application_not_authorized_operation_by_your_contact",nil)];
        });
    } else if ([self hasSchedule]) {
        [self showSchedule];
    }
}

- (void)startVideoCallWithPermissionCheck:(BOOL)videoBell {
    DDLogVerbose(@"%@ startVideoCallWithPermissionCheck: %d", LOG_TAG, videoBell);
        
    AVAuthorizationStatus cameraAuthorizationStatus = [DeviceAuthorization deviceCameraAuthorizationStatus];
    switch (cameraAuthorizationStatus) {
        case AVAuthorizationStatusNotDetermined: {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if (granted) {
                    AVAudioSessionRecordPermission audioSessionRecordPermission = [DeviceAuthorization deviceMicrophonePermissionStatus];
                    switch (audioSessionRecordPermission) {
                        case AVAudioSessionRecordPermissionUndetermined: {
                            [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
                                if (granted) {
                                    dispatch_async(dispatch_get_main_queue(), ^(void) {
                                        [self startVideoCallViewController:videoBell];
                                    });
                                }
                            }];
                            break;
                        }
                            
                        case AVAudioSessionRecordPermissionDenied:
                            [DeviceAuthorization showMicrophoneCameraSettingsAlertInController:self];
                            break;
                            
                        case AVAudioSessionRecordPermissionGranted: {
                            dispatch_async(dispatch_get_main_queue(), ^(void) {
                                [self startVideoCallViewController:videoBell];
                            });
                            break;
                        }
                    }
                }
            }];
            break;
        }
            
        case AVAuthorizationStatusRestricted:
        case AVAuthorizationStatusDenied:
            [DeviceAuthorization showMicrophoneCameraSettingsAlertInController:self];
            break;
            
        case AVAuthorizationStatusAuthorized: {
            AVAudioSessionRecordPermission audioSessionRecordPermission = [DeviceAuthorization deviceMicrophonePermissionStatus];
            switch (audioSessionRecordPermission) {
                case AVAudioSessionRecordPermissionUndetermined: {
                    [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
                        if (granted) {
                            dispatch_async(dispatch_get_main_queue(), ^(void) {
                                [self startVideoCallViewController:videoBell];
                            });
                        }
                    }];
                    break;
                }
                    
                case AVAudioSessionRecordPermissionDenied:
                    [DeviceAuthorization showMicrophoneCameraSettingsAlertInController:self];
                    break;
                    
                case AVAudioSessionRecordPermissionGranted: {
                    dispatch_async(dispatch_get_main_queue(), ^(void) {
                        [self startVideoCallViewController:videoBell];
                    });
                    break;
                }
            }
            break;
        }
    }
}

- (void)startVideoCallViewController:(BOOL)videoBell {
    DDLogVerbose(@"%@ startVideoCallViewController: %d", LOG_TAG, videoBell);
    
    if (self.contact) {
        if (![self.contact hasPrivatePeer]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[UIApplication sharedApplication].keyWindow makeToast:TwinmeLocalizedString(@"show_contact_view_controller_pending_message",nil)];
            });
            return;
        }
        
        CallViewController *callViewController = (CallViewController *)[[UIStoryboard storyboardWithName:@"Call" bundle:nil] instantiateViewControllerWithIdentifier:@"CallViewController"];
        [callViewController startCallWithOriginator:self.contact videoBell:videoBell isVideoCall:YES isCertifyCall:self.startCertifyCall];
        [self.navigationController pushViewController:callViewController animated:YES];
    }
}

- (void)handleAudioTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleAudioTapGesture: %@", LOG_TAG, sender);
    
    if (self.contact && sender.state == UIGestureRecognizerStateEnded && !self.twinmeApplication.inCall && self.contact.capabilities.hasAudio && ![self hasSchedule]) {
        AVAudioSessionRecordPermission audioSessionRecordPermission = [DeviceAuthorization deviceMicrophonePermissionStatus];
        switch (audioSessionRecordPermission) {
            case AVAudioSessionRecordPermissionUndetermined: {
                [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
                    if (granted) {
                        dispatch_async(dispatch_get_main_queue(), ^(void) {
                            [self startAudioCallViewController];
                        });
                    }
                }];
                break;
            }
                
            case AVAudioSessionRecordPermissionDenied:
                [DeviceAuthorization showMicrophoneSettingsAlertInController:self];
                break;
                
            case AVAudioSessionRecordPermissionGranted: {
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    [self startAudioCallViewController];
                });
                break;
            }
        }
    } else if (!self.contact.capabilities.hasAudio) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication].keyWindow makeToast:TwinmeLocalizedString(@"application_not_authorized_operation_by_your_contact",nil)];
        });
    } else if ([self hasSchedule]) {
        [self showSchedule];
    }
}

- (void)startAudioCallViewController {
    DDLogVerbose(@"%@ startAudioCallViewController", LOG_TAG);
    
    if (self.contact) {
        if (![self.contact hasPrivatePeer]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[UIApplication sharedApplication].keyWindow makeToast:TwinmeLocalizedString(@"show_contact_view_controller_pending_message",nil)];
            });
            return;
        }
        CallViewController *callViewController = (CallViewController *)[[UIStoryboard storyboardWithName:@"Call" bundle:nil] instantiateViewControllerWithIdentifier:@"CallViewController"];
        [callViewController startCallWithOriginator:self.contact videoBell:NO isVideoCall:NO isCertifyCall:NO];
        [self.navigationController pushViewController:callViewController animated:YES];
    }
}

- (void)handleRemoveTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleRemoveTapGesture: %@", LOG_TAG, sender);
    
    if (self.contact && sender.state == UIGestureRecognizerStateEnded) {
        [self.showContactService deleteContact:self.contact];
    }
}

- (void)handleLastCallsTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleLastCallsTapGesture: %@", LOG_TAG, sender);
    
    if (self.contact && sender.state == UIGestureRecognizerStateEnded) {
        self.navigationController.navigationBarHidden = NO;
        LastCallsViewController *lastCallsViewController = (LastCallsViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"LastCallsViewController"];
        [lastCallsViewController initWithOriginator:self.contact callReceiver:NO];
        [self.navigationController pushViewController:lastCallsViewController animated:YES];
    }
}

- (void)handleAuthentifiedRelationTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleAuthentifiedRelationTapGesture: %@", LOG_TAG, sender);
    
    if (self.contact && sender.state == UIGestureRecognizerStateEnded) {

        if (self.contact.certificationLevel == TLCertificationLevel4) {
            self.navigationController.navigationBarHidden = NO;
            AuthentifiedRelationViewController *authentifiedRelationViewController = (AuthentifiedRelationViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"AuthentifiedRelationViewController"];
            [authentifiedRelationViewController initWithContact:self.contact];
            [self.navigationController pushViewController:authentifiedRelationViewController animated:YES];
        } else {
            self.startCertifyCall = NO;
            [self openMenuCertify];
        }
    }
}

- (void)handleSettingsTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleSettingsTapGesture: %@", LOG_TAG, sender);
    
    if (self.contact && sender.state == UIGestureRecognizerStateEnded) {
        self.navigationController.navigationBarHidden = NO;
        ContactCapabilitiesViewController *contactCapabilitiesViewController = (ContactCapabilitiesViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"ContactCapabilitiesViewController"];
        [contactCapabilitiesViewController initWithContact:self.contact];
        [self.navigationController pushViewController:contactCapabilitiesViewController animated:YES];
    }
}

- (void)handleSettingsNewFeatureTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleSettingsTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        OnboardingConfirmView *onboardingConfirmView = [[OnboardingConfirmView alloc] init];
        onboardingConfirmView.confirmViewDelegate = self;
        onboardingConfirmView.tag = OnboardingTypeRemoteCameraSettings;
        [onboardingConfirmView initWithTitle:TwinmeLocalizedString(@"call_view_controller_camera_control_needs_help", nil) message: TwinmeLocalizedString(@"contact_capabilities_view_controller_camera_control_onboarding", nil) image:[UIImage imageNamed:@"OnboardingControlCamera"] action:TwinmeLocalizedString(@"application_ok", nil) actionColor:nil cancel:TwinmeLocalizedString(@"application_do_not_display", nil)];
        [onboardingConfirmView hideCancelAction];
        [self.navigationController.view addSubview:onboardingConfirmView];
        [onboardingConfirmView showConfirmView];
    }
}

- (void)handleFilesTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleFilesTapGesture: %@", LOG_TAG, sender);
    
    if (self.contact && sender.state == UIGestureRecognizerStateEnded) {
        self.navigationController.navigationBarHidden = NO;
        ConversationFilesViewController *conversationFilesViewController = (ConversationFilesViewController *)[[UIStoryboard storyboardWithName:@"iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"ConversationFilesViewController"];
        [conversationFilesViewController initWithOriginator:self.contact];
        [self.navigationController pushViewController:conversationFilesViewController animated:YES];
    }
}

- (void)handleExportTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleExportTapGesture: %@", LOG_TAG, sender);
    
    if (self.contact && sender.state == UIGestureRecognizerStateEnded) {
        self.navigationController.navigationBarHidden = NO;
        ExportViewController *exportViewController = (ExportViewController *)[[UIStoryboard storyboardWithName:@"iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"ExportViewController"];
        [exportViewController initExportWithContact:self.contact];
        [self.navigationController pushViewController:exportViewController animated:YES];
    }
}

- (void)handleCleanTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleCleanTapGesture: %@", LOG_TAG, sender);
    
    if (self.contact && sender.state == UIGestureRecognizerStateEnded) {
        self.navigationController.navigationBarHidden = NO;
        TypeCleanUpViewController *typeCleanupViewController = (TypeCleanUpViewController *)[[UIStoryboard storyboardWithName:@"iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"TypeCleanUpViewController"];
        [typeCleanupViewController initCleanUpWithContact:self.contact];
        [self.navigationController pushViewController:typeCleanupViewController animated:YES];
    }
}

- (void)updateContact {
    DDLogVerbose(@"%@ updateContact", LOG_TAG);
    
    self.avatarView.image = self.contactAvatar;
    self.nameLabel.text =  self.contactName;
    
    if ([self.contactDescription isEqual:TwinmeLocalizedString(@"side_menu_view_controller_about", nil)]) {
        self.descriptionLabel.text = @"";
    } else {
        self.descriptionLabel.text = self.contactDescription;
    }
    
    self.identityLabel.text = self.identityName;

    if (self.contact.space.avatarId) {
        [self.showContactService getImageWithSpace:self.contact.space withBlock:^(UIImage *image) {
            self.spaceAvatarView.image = image;
            self.spaceAvatarLabel.hidden = YES;
        }];
    } else {
        self.spaceAvatarView.image = nil;
        self.spaceAvatarLabel.hidden = NO;
        if (self.contact.space.settings.style) {
            self.spaceAvatarView.backgroundColor = [UIColor colorWithHexString:self.contact.space.settings.style alpha:1.0];
        } else {
            self.spaceAvatarView.backgroundColor = Design.MAIN_COLOR;
        }
        self.spaceAvatarLabel.text = [NSString firstCharacter:self.contact.space.settings.name];
    }
    
    NSString *nameSpace = @"";
    NSString *nameProfile = @"";
    if (self.contact.space.settings.name) {
        nameSpace = self.contact.space.settings.name;
    }
    if (self.contact.space.profile.name) {
        nameProfile = self.contact.space.profile.name;
    }
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@""];
    [attributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:nameSpace attributes:[NSDictionary dictionaryWithObjectsAndKeys:Design.FONT_MEDIUM34, NSFontAttributeName, Design.FONT_COLOR_DEFAULT, NSForegroundColorAttributeName, nil]]];
    [attributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:@"\n"]];
    [attributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:nameProfile attributes:[NSDictionary dictionaryWithObjectsAndKeys:Design.FONT_MEDIUM32, NSFontAttributeName, Design.FONT_COLOR_PROFILE_GREY, NSForegroundColorAttributeName, nil]]];
    self.spaceLabel.attributedText = attributedString;
    [self.showContactService getIdentityImageWithContact:self.contact withBlock:^(UIImage *image) {
        self.identityAvatarView.image = image;
    }];
    
    if (![self.contact hasPrivatePeer]) {
        self.identityView.alpha = 0.5f;
    } else {
        self.identityView.alpha = 1.f;
    }
    
    if (self.contact.certificationLevel == TLCertificationLevel4) {
        self.certifiedRelationImageView.hidden = NO;
        self.nameLabelWidthConstraint.constant = (DESIGN_NAME_DEFAULT_WIDTH * Design.WIDTH_RATIO) - self.certifiedRelationImageViewHeightConstraint.constant - self.certifiedRelationImageViewLeadingConstraint.constant;
        self.nameLabelXConstraint.constant = -((self.certifiedRelationImageViewHeightConstraint.constant + self.certifiedRelationImageViewLeadingConstraint.constant) * 0.5);
    } else {
        self.certifiedRelationImageView.hidden = YES;
        self.nameLabelWidthConstraint.constant = DESIGN_NAME_DEFAULT_WIDTH * Design.WIDTH_RATIO;
        self.nameLabelXConstraint.constant = 0;
    }
        
    if (self.contact.certificationLevel == TLCertificationLevel0) {
        self.authentifiedRelationView.hidden = YES;
        self.authentifiedRelationViewHeightConstraint.constant = 0;
    } else {
        self.authentifiedRelationView.hidden = NO;
        self.authentifiedRelationViewHeightConstraint.constant = Design.SETTING_CELL_HEIGHT;
        
        if (self.contact.certificationLevel == TLCertificationLevel4) {
            self.authentifiedRelationLabel.text = TwinmeLocalizedString(@"authentified_relation_view_controller_title", nil);
            self.authentifiedRelationImageView.image = [UIImage imageNamed:@"AuthentifiedRelationIcon"];
        } else {
            self.authentifiedRelationLabel.text = TwinmeLocalizedString(@"authentified_relation_view_controller_to_be_certified_title", nil);
            self.authentifiedRelationImageView.image = [UIImage imageNamed:@"AuthentifiedRelationGreyIcon"];
        }
    }
    
    [self updateInCall];
}

- (void)showCoachMark {
    DDLogVerbose(@"%@ showCoachMark", LOG_TAG);
    
    if ([self.twinmeApplication showCoachMark:TAG_COACH_MARK_CONTACT_CAPABILITIES]) {
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(DELAY_COACH_MARK * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            CoachMarkViewController *coachMarkViewController = (CoachMarkViewController *)[[UIStoryboard storyboardWithName:@"iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"CoachMarkViewController"];
            CGRect clipRect = CGRectMake(self.settingsView.frame.origin.x, self.actionView.frame.origin.y + self.settingsView.frame.origin.y, self.settingsView.frame.size.width, self.settingsView.frame.size.height);
            CoachMark *coachMark = [[CoachMark alloc]initWithMessage:TwinmeLocalizedString(@"show_contact_view_controller_settings_coach_mark", nil) tag:TAG_COACH_MARK_CONTACT_CAPABILITIES alignLeft:YES onTop:YES featureRect:clipRect featureRadius:0];
            [coachMarkViewController initWithCoachMark:coachMark];
            coachMarkViewController.delegate = self;
            [coachMarkViewController showInView:self];
        });
    }
    
}

- (void)openMenuCertify {
    DDLogVerbose(@"%@ openMenuMigration", LOG_TAG);
        
    MenuCertifyView *menuCertifyView = [[MenuCertifyView alloc] init];
    menuCertifyView.menuCertifyViewDelegate = self;
    [self.navigationController.view addSubview:menuCertifyView];
    [menuCertifyView openMenu];
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    [super updateFont];
    
    self.chatLabel.font = Design.FONT_REGULAR28;
    self.videoLabel.font = Design.FONT_REGULAR28;
    self.audioLabel.font = Design.FONT_REGULAR28;
    self.historyTitleLabel.font = Design.FONT_BOLD26;
    self.settingsTitleLabel.font = Design.FONT_BOLD26;
    self.settingsLabel.font = Design.FONT_REGULAR34;
    self.settingsNewLabel.font = Design.FONT_MEDIUM32;
    self.conversationsTitleLabel.font = Design.FONT_BOLD26;
    self.lastCallLabel.font = Design.FONT_REGULAR34;
    self.fallbackLabel.font = Design.FONT_MEDIUM34;
    self.removeLabel.font = Design.FONT_MEDIUM34;
    self.filesLabel.font = Design.FONT_REGULAR34;
    self.exportLabel.font = Design.FONT_REGULAR34;
    self.cleanLabel.font = Design.FONT_REGULAR34;
    self.spaceAvatarLabel.font = Design.FONT_BOLD44;
    
    NSString *nameSpace = @"";
    NSString *nameProfile = @"";
    if (self.contact.space.settings.name) {
        nameSpace = self.contact.space.settings.name;
    }
    if (self.contact.space.profile.name) {
        nameProfile = self.contact.space.profile.name;
    }
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@""];
    [attributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:nameSpace attributes:[NSDictionary dictionaryWithObjectsAndKeys:Design.FONT_MEDIUM34, NSFontAttributeName, Design.FONT_COLOR_DEFAULT, NSForegroundColorAttributeName, nil]]];
    [attributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:@"\n"]];
    [attributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:nameProfile attributes:[NSDictionary dictionaryWithObjectsAndKeys:Design.FONT_MEDIUM32, NSFontAttributeName, Design.FONT_COLOR_PROFILE_GREY, NSForegroundColorAttributeName, nil]]];
    self.spaceLabel.attributedText = attributedString;
    self.authentifiedRelationLabel.font = Design.FONT_REGULAR34;
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    [super updateColor];
    
    self.chatLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.videoLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.audioLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.conversationsTitleLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.settingsTitleLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.settingsLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.settingsNewLabel.backgroundColor = Design.MAIN_COLOR;
    self.historyTitleLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.lastCallLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.fallbackLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.filesLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.exportLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.cleanLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.authentifiedRelationLabel.textColor = Design.FONT_COLOR_DEFAULT;
}

- (void)checkSpacePermission {
    DDLogVerbose(@"%@ checkSpacePermission", LOG_TAG);
    
    if (![self.contact.space hasPermission:TLSpacePermissionTypeMoveContact]) {
        self.spaceLabel.alpha = .5f;
    } else {
        self.spaceLabel.alpha = 1.f;
    }
    
    if (![self.contact.space hasPermission:TLSpacePermissionTypeUpdateIdentity]) {
        self.identityView.alpha = .5f;
    } else {
        self.identityView.alpha = 1.f;
    }
}

- (BOOL)hasSchedule {
    DDLogVerbose(@"%@ hasSchedule", LOG_TAG);
    
    if (self.contact.capabilities.schedule && self.contact.capabilities.schedule.enabled) {
        return ![self.contact.capabilities.schedule isNowInRange];
    }
    
    return NO;
}

- (void)showSchedule {
    DDLogVerbose(@"%@ showSchedule", LOG_TAG);
    
    NSString *message = @"";
    
    TLSchedule *schedule = self.contact.capabilities.schedule;
    
    if (schedule && schedule.timeRanges.count > 0) {
        TLDateTimeRange *dateTimeRange = (TLDateTimeRange *)[schedule.timeRanges objectAtIndex:0];
        TLDateTime *start = dateTimeRange.start;
        TLDateTime *end = dateTimeRange.end;
        
        if ([start.date isEqual:end.date]) {
            message = [NSString stringWithFormat:TwinmeLocalizedString(@"show_call_view_controller_schedule_from_to", nil), [start.date formatDate], [start.time formatTime], [end.time formatTime]];
        } else {
            message = [NSString stringWithFormat:@"%@ %@", [start formatDateTime], [end formatDateTime]];
        }
    } else {
        message = TwinmeLocalizedString(@"show_call_view_controller_schedule_message", nil);
    }
                
    AlertMessageView *alertMessageView = [[AlertMessageView alloc] init];
    alertMessageView.alertMessageViewDelegate = self;
    [alertMessageView initWithTitle:TwinmeLocalizedString(@"show_call_view_controller_schedule_call", nil) message:message];
    [self.tabBarController.view addSubview:alertMessageView];
    [alertMessageView showAlertView];
}

- (void)updateInCall {
    DDLogVerbose(@"%@ updateInCall", LOG_TAG);
    
    BOOL inCall = self.twinmeApplication.inCall;
    if (!self.contact.capabilities.hasAudio || inCall || !self.contact.hasPrivatePeer || [self hasSchedule]) {
        self.audioView.alpha = 0.5f;
    } else {
        self.audioView.alpha = 1.0f;
    }
    
    if (!self.contact.capabilities.hasVideo || inCall || !self.contact.hasPrivatePeer || [self hasSchedule]) {
        self.videoView.alpha = 0.5f;
    } else {
        self.videoView.alpha = 1.0f;
    }
}

@end
