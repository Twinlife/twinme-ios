/*
 *  Copyright (c) 2018-2024 twinlife SA.
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
#import <Twinme/TLSpace.h>
#import <Twinme/TLTwinmeAttributes.h>

#import <Utils/NSString+Utils.h>

#import "AcceptGroupInvitationViewController.h"
#import "SpacesViewController.h"

#import <TwinmeCommon/Design.h>
#import <TwinmeCommon/GroupInvitationService.h>
#import <TwinmeCommon/TwinmeNavigationController.h>

#import "UIColor+Hex.h"
#import "InsideBorderView.h"
#import "UIViewController+ProgressIndicator.h"

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

#define ICON_BACKGROUND_COLOR [UIColor colorWithRed:213./255. green:213./255. blue:213./255. alpha:1.0]

static UIColor *DESIGN_BACKGROUND_COLOR;
static UIColor *DESIGN_NO_AVATAR_COLOR;

static const CGFloat DESIGN_AVATAR_HEIGHT = 148;
static const CGFloat DESIGN_CANCEL_HEIGHT = 140;

//
// Interface: AcceptGroupInvitationViewContoller ()
//

@interface AcceptGroupInvitationViewController () <GroupInvitationServiceDelegate, SpacesPickerDelegate>

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
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contactViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *contactView;
@property (weak, nonatomic) IBOutlet UIImageView *contactImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *statusInvitationImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *statusInvitationImageView;
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

@property (nonatomic) GroupInvitationService *groupInvitationService;

@property (nonatomic) id<TLConversation> conversation;
@property (nonatomic) TLContact *contact;
@property (nonatomic) TLGroup *group;
@property (nonatomic) TLInvitationDescriptor *invitationDescriptor;
@property (nonatomic) TLSpace *space;
@property (nonatomic) TLSpace *initialSpace;
@property (nonatomic) UIImage *contactAvatar;
@property (nonatomic) BOOL isGetInvitationDone;
@property (nonatomic) BOOL actionEnable;
@property (nonatomic) BOOL isActionViewDidAppear;

@end

#undef LOG_TAG
#define LOG_TAG @"AcceptGroupInvitationViewController"

@implementation AcceptGroupInvitationViewController

+ (void)initialize {
    DDLogVerbose(@"%@ initialize", LOG_TAG);
    
    DESIGN_BACKGROUND_COLOR = [UIColor colorWithRed:250./255. green:251./255. blue:254./255. alpha:1];
    DESIGN_NO_AVATAR_COLOR = [UIColor colorWithRed:243./255. green:243./255. blue:243./255. alpha:1];
}

#pragma mark - UIViewController

- (instancetype)initWithCoder:(NSCoder *)coder {
    DDLogVerbose(@"%@ initWithCoder: %@", LOG_TAG, coder);
    
    self = [super initWithCoder:coder];
    
    if (self) {
        _groupInvitationService = [[GroupInvitationService alloc] initWithTwinmeContext:self.twinmeContext delegate:self];
        _isGetInvitationDone = NO;
        _actionEnable = YES;
        _isActionViewDidAppear = NO;
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
}

- (void)initWithInvitationId:(TLDescriptorId *)invitationId contactId:(NSUUID *)contactId {
    DDLogVerbose(@"%@ initWithInvitationId: %@ contactId: %@", LOG_TAG, invitationId, contactId);
    
    [self.groupInvitationService initWithDescriptorId:invitationId contactId:contactId];
}

- (void)showInView:(UIView *)view {
    DDLogVerbose(@"%@ showInView: %@", LOG_TAG, view);
    
    self.view.frame = view.frame;
    [view addSubview:self.view];
}

#pragma mark - GroupInvitationServiceDelegate

- (void)onGetContact:(nonnull TLContact *)contact avatar:(nullable UIImage *)avatar {
    DDLogVerbose(@"%@ onGetContact: %@", LOG_TAG, contact);

    self.contact = contact;
    self.contactAvatar = avatar;
    self.messageLabel.text = [NSString stringWithFormat:TwinmeLocalizedString(@"accept_group_invitation_view_controller_message %@", nil), self.contact.name];
    self.contactImageView.image = self.contactAvatar;
    
    [self updateInvitationDescriptor];
}

- (void)onGetInvitationWithInvitationDescriptor:(nonnull TLInvitationDescriptor *)invitationDescriptor avatar:(nullable UIImage *)avatar {
    DDLogVerbose(@"%@ onGetInvitationImageWithInvitationDescriptor: %@ invitation: %@", LOG_TAG, invitationDescriptor, avatar);
    
    self.isGetInvitationDone = YES;
    self.invitationDescriptor = invitationDescriptor;
    
    if (!avatar || [avatar isEqual:[TLTwinmeAttributes DEFAULT_GROUP_AVATAR]]) {
        if (!avatar) {
            avatar = [TLTwinmeAttributes DEFAULT_GROUP_AVATAR];
        }
        
        self.avatarView.backgroundColor = [UIColor colorWithHexString:Design.DEFAULT_COLOR alpha:1.0];
        self.avatarView.tintColor = [UIColor whiteColor];
    } else {
        self.avatarView.backgroundColor = [UIColor clearColor];
        self.avatarView.tintColor = [UIColor clearColor];
    }
        
    self.avatarView.image = avatar;
    
    [self updateInvitationDescriptor];
}

- (void)onDeclinedInvitationWithInvitationDescriptor:(nonnull TLInvitationDescriptor *)invitationDescriptor {
    DDLogVerbose(@"%@ onDeclinedInvitationWithInvitationDescriptor: %@", LOG_TAG, invitationDescriptor);
    
    self.invitationDescriptor = invitationDescriptor;
    [self updateInvitationDescriptor];
}

- (void)onAcceptedInvitationWithInvitationDescriptor:(nonnull TLInvitationDescriptor *)invitationDescriptor group:(nonnull TLGroup *)group {
    DDLogVerbose(@"%@ onAcceptedInvitationWithInvitationDescriptor: %@ groupId: %@", LOG_TAG, invitationDescriptor, group);
    
    self.group = group;
    self.invitationDescriptor = invitationDescriptor;
    [self updateInvitationDescriptor];
    
    if (![self.initialSpace.uuid isEqual:self.space.uuid]) {
        [self.groupInvitationService moveGroupToSpace:self.space group:group];
    }
    
    self.invitationDescriptor = invitationDescriptor;
    [self updateInvitationDescriptor];
}

- (void)onDeletedInvitation {
    DDLogVerbose(@"%@ onDeletedInvitation", LOG_TAG);

    DDLogError(@"%@ BIG OOPS INVITATION DELETED!!! MUST DISPLAY SOMETHING OR FINISH", LOG_TAG);
    
    self.isGetInvitationDone = YES;
    [self updateInvitationDescriptor];
}

- (void)onGetSpace:(nonnull TLSpace *)space avatar:(nullable UIImage *)avatar {
    DDLogVerbose(@"%@ onGetSpace: %@", LOG_TAG, space);
    
    self.space = space;
    self.initialSpace = space;
    [self updateSpace];
}

- (void)onGetCurrentSpace:(TLSpace *)space {
    DDLogVerbose(@"%@ onGetCurrentSpace: %@", LOG_TAG, space);
    
    self.space = space;
    self.initialSpace = space;
    [self updateSpace];
}

- (void)onSetCurrentSpace:(nonnull TLSpace *)space {
    DDLogVerbose(@"%@ onSetCurrentSpace: %@", LOG_TAG, space);

}

- (void)onMoveGroup:(TLGroup *)group {
    DDLogVerbose(@"%@ onMoveGroup: %@", LOG_TAG, group);
    
    [self updateInvitationDescriptor];
}

#pragma mark - SpacesPickerDelegate

- (void)didSelectSpace:(TLSpace *)space {
    DDLogVerbose(@"%@ didSelectSpace: %@", LOG_TAG, space);
    
    self.space = space;
    [self updateSpace];
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
    
    self.messageLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.messageLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.messageLabel.font = Design.FONT_MEDIUM38;
    self.messageLabel.textColor = Design.FONT_COLOR_GREY;

    self.contactViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
   
    self.contactView.layer.cornerRadius = self.contactViewHeightConstraint.constant * 0.5f;
    self.contactView.layer.borderWidth = 3.f;
    self.contactView.layer.borderColor = [UIColor whiteColor].CGColor;
    
    self.contactView.layer.shadowOpacity = Design.SHADOW_OPACITY;
    self.contactView.layer.shadowOffset = Design.SHADOW_OFFSET;
    self.contactView.layer.shadowRadius = Design.SHADOW_RADIUS;
    self.contactView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.contactView.layer.masksToBounds = NO;
    self.contactView.backgroundColor = ICON_BACKGROUND_COLOR;
    
    self.contactImageView.hidden = YES;
    self.contactImageView.tintColor = [UIColor whiteColor];
    self.contactImageView.clipsToBounds = YES;
    self.contactImageView.layer.cornerRadius = self.contactViewHeightConstraint.constant * 0.5f;
    
    self.statusInvitationImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.statusInvitationImageView.hidden = YES;
    
    self.bulletViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.bulletViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.bulletView.clipsToBounds = YES;
    self.bulletView.layer.cornerRadius = self.bulletViewHeightConstraint.constant * 0.5f;
    self.bulletView.layer.borderWidth = 3.f;
    self.bulletView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.bulletView.backgroundColor = ICON_BACKGROUND_COLOR;
    
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
    
    UITapGestureRecognizer *cancelViewGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDeclineTapGesture:)];
    [self.cancelView addGestureRecognizer:cancelViewGestureRecognizer];
    
    UIWindow *window = UIApplication.sharedApplication.keyWindow;
    self.cancelViewBottomConstraint.constant = window.safeAreaInsets.bottom;

    self.cancelLabel.font = Design.FONT_MEDIUM38;
    self.cancelLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.cancelLabel.text = TwinmeLocalizedString(@"application_decline", nil);
}

- (void)finish {
    DDLogVerbose(@"%@ finish", LOG_TAG);
    
    if (self.group) {
        [self showGroupWithGroup:self.group];
        self.group = nil;
    }
    
    if (self.groupInvitationService) {
        [self.groupInvitationService dispose];
        self.groupInvitationService = nil;
    }
    
    [self.view removeFromSuperview];
}

- (void)showActionView {
    DDLogVerbose(@"%@ showActionView", LOG_TAG);
    
    if (self.isActionViewDidAppear) {
        return;
    }
    
    self.isActionViewDidAppear = YES;
    
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


- (void)handleCancelTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleCancelTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        if (!self.actionEnable) {
            return;
        }
        
        if (self.invitationDescriptor && self.invitationDescriptor.status == TLInvitationDescriptorStatusTypePending) {
            if (![self.initialSpace.uuid isEqual:self.space.uuid]) {
                [self.groupInvitationService setCurrentSpace:self.initialSpace];
            }
        }
        
        [self closeActionView];
    }
}

- (void)handleDeclineTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleCancelTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        if (!self.actionEnable) {
            return;
        }
        
        if (self.invitationDescriptor && self.invitationDescriptor.status == TLInvitationDescriptorStatusTypePending) {
            if (![self.initialSpace.uuid isEqual:self.space.uuid]) {
                [self.groupInvitationService setCurrentSpace:self.initialSpace];
            }
            
            [self.groupInvitationService declineInvitation];
        }
    }
}

- (void)handleConfirmTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleConfirmTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        if (!self.actionEnable) {
            return;
        }
        
        if (self.invitationDescriptor && self.invitationDescriptor.status == TLInvitationDescriptorStatusTypePending) {
            [self.groupInvitationService acceptInvitation];
        } else {
            [self closeActionView];
        }
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
        [self.groupInvitationService getImageWithSpace:self.space withBlock:^(UIImage *image) {
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

- (void)updateInvitationDescriptor {
    DDLogVerbose(@"%@ updateInvitationDescriptor: %@", LOG_TAG, self.invitationDescriptor);
    
    if (self.invitationDescriptor) {
        self.avatarContainerViewHeightConstraint.constant = DESIGN_AVATAR_HEIGHT * Design.HEIGHT_RATIO;
        self.cancelViewHeightConstraint.constant = DESIGN_CANCEL_HEIGHT * Design.HEIGHT_RATIO;
        self.spaceViewHeightConstraint.constant = Design.SETTING_CELL_HEIGHT;
        
        self.nameLabel.text = self.invitationDescriptor.name;
        self.nameLabel.hidden = NO;
        self.avatarContainerView.hidden = NO;
        self.contactView.hidden = NO;
        self.bulletView.hidden = NO;
        self.spaceTitleLabel.hidden = NO;
        self.spaceView.hidden = NO;
        
        switch (self.invitationDescriptor.status) {
            case TLInvitationDescriptorStatusTypePending:
                self.confirmView.hidden = NO;
                self.cancelView.hidden = NO;
                self.messageLabel.text = [NSString stringWithFormat:TwinmeLocalizedString(@"accept_group_invitation_view_controller_message %@", nil), self.contact.name];
                self.contactImageView.hidden = NO;
                self.statusInvitationImageView.hidden = YES;
                self.spaceTitleLabel.hidden = NO;
                self.spaceView.hidden = NO;
                break;
                
            case TLInvitationDescriptorStatusTypeAccepted:
                self.confirmView.hidden = NO;
                self.cancelView.hidden = YES;
                self.cancelViewBottomConstraint.constant = 0;
                self.spaceTitleLabelTopConstraint.constant = 0;
                self.spaceViewHeightConstraint.constant = 0;
                self.messageLabel.text = TwinmeLocalizedString(@"conversation_view_controller_invitation_accepted", nil);
                self.contactImageView.hidden = YES;
                self.statusInvitationImageView.hidden = NO;
                self.statusInvitationImageView.image = [UIImage imageNamed:@"InvitationStateAccepted"];
                self.spaceTitleLabel.hidden = YES;
                self.spaceView.hidden = YES;
                self.confirmLabel.text = TwinmeLocalizedString(@"application_ok", nil);
                break;
                
            case TLInvitationDescriptorStatusTypeJoined:
                self.confirmView.hidden = NO;
                self.cancelView.hidden = YES;
                self.cancelViewBottomConstraint.constant = 0;
                self.spaceTitleLabelTopConstraint.constant = 0;
                self.spaceViewHeightConstraint.constant = 0;
                self.messageLabel.text = TwinmeLocalizedString(@"conversation_view_controller_invitation_joined", nil);
                self.contactImageView.hidden = YES;
                self.statusInvitationImageView.hidden = NO;
                self.statusInvitationImageView.image = [UIImage imageNamed:@"InvitationStateJoined"];
                self.spaceTitleLabel.hidden = YES;
                self.spaceView.hidden = YES;
                self.confirmLabel.text = TwinmeLocalizedString(@"application_ok", nil);
                break;
                
            case TLInvitationDescriptorStatusTypeRefused:
                self.confirmView.hidden = NO;
                self.cancelView.hidden = YES;
                self.cancelViewBottomConstraint.constant = 0;
                self.spaceTitleLabelTopConstraint.constant = 0;
                self.spaceViewHeightConstraint.constant = 0;
                self.messageLabel.text = TwinmeLocalizedString(@"conversation_view_controller_invitation_refused", nil);
                self.contactImageView.hidden = YES;
                self.statusInvitationImageView.hidden = NO;
                self.statusInvitationImageView.image = [UIImage imageNamed:@"InvitationStateRefused"];
                self.spaceTitleLabel.hidden = YES;
                self.spaceView.hidden = YES;
                self.confirmLabel.text = TwinmeLocalizedString(@"application_ok", nil);
                break;
                
            case TLInvitationDescriptorStatusTypeWithdrawn:
                self.confirmView.hidden = NO;
                self.cancelView.hidden = YES;
                self.cancelViewBottomConstraint.constant = 0;
                self.spaceTitleLabelTopConstraint.constant = 0;
                self.spaceViewHeightConstraint.constant = 0;
                self.contactImageView.hidden = YES;
                self.statusInvitationImageView.hidden = NO;
                self.statusInvitationImageView.image = [UIImage imageNamed:@"ToolbarTrash"];
                self.statusInvitationImageView.tintColor = [UIColor whiteColor];
                self.spaceTitleLabel.hidden = YES;
                self.spaceView.hidden = YES;
                self.confirmLabel.text = TwinmeLocalizedString(@"application_ok", nil);
                self.messageLabel.text = TwinmeLocalizedString(@"accept_group_invitation_view_controller_deleted", nil);
                break;
                
            default:
                break;
        }
    } else {
        self.avatarContainerViewHeightConstraint.constant = 0;
        self.cancelViewHeightConstraint.constant = 0;
        self.spaceViewHeightConstraint.constant = 0;
        
        self.cancelView.hidden = YES;
        self.confirmView.hidden = YES;
        self.bulletView.hidden = YES;
        self.contactView.hidden = YES;
        self.spaceTitleLabel.hidden = YES;
        self.spaceView.hidden = YES;
        
        if (!self.contactAvatar) {
            self.avatarView.image = [TLTwinmeAttributes DEFAULT_GROUP_AVATAR];
        } else {
            self.avatarView.image = self.contactAvatar;
        }
        
        self.nameLabel.hidden = YES;
        if (self.isGetInvitationDone) {
            self.avatarContainerView.hidden = NO;
            self.messageLabel.text = TwinmeLocalizedString(@"accept_group_invitation_view_controller_deleted", nil);
        } else {
            self.avatarContainerView.hidden = YES;
            self.messageLabel.text = [NSString stringWithFormat:@"%@\n%@", TwinmeLocalizedString(@"accept_invitation_view_controller_being_transferred", nil), TwinmeLocalizedString(@"accept_invitation_view_controller_check_connection", nil)];
        }
        self.spaceTitleLabel.hidden = YES;
        self.spaceView.hidden = YES;
    }
    
    [self showActionView];
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    self.nameLabel.font = Design.FONT_BOLD44;
    self.messageLabel.font = Design.FONT_MEDIUM40;
    self.confirmLabel.font = Design.FONT_BOLD36;
    self.cancelLabel.font = Design.FONT_BOLD36;
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    self.actionView.backgroundColor = Design.POPUP_BACKGROUND_COLOR;
    self.nameLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.messageLabel.textColor = Design.FONT_COLOR_GREY;
    self.cancelLabel.textColor = Design.FONT_COLOR_DEFAULT;
}

@end
