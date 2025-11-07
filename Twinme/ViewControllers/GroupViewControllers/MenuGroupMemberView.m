/*
 *  Copyright (c) 2020-2024 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <Utils/NSString+Utils.h>

#import "MenuGroupMemberView.h"

#import <TwinmeCommon/Design.h>
#import "UIContact.h"

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif


//
// Interface: MenuGroupMemberView ()
//

@interface MenuGroupMemberView ()<CAAnimationDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *avatarViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *avatarViewTopConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *avatarView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameLabelTopConstraint;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separatorInviteViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *separatorInviteView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *inviteViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *inviteView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *inviteImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *inviteImageViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *inviteImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *inviteLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *inviteLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *inviteLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separatorRemoveViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *separatorRemoveView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *removeImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *removeImageViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *removeImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *removeViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *removeViewBottomConstraint;
@property (weak, nonatomic) IBOutlet UIView *removeView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *removeLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *removeLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *removeLabel;

@property (nonatomic) UIContact *uiMember;

@property (nonatomic) BOOL canInvite;
@property (nonatomic) BOOL canRemove;

@end

//
// Implementation: MenuGroupMemberView
//

#undef LOG_TAG
#define LOG_TAG @"MenuGroupMemberView"

@implementation MenuGroupMemberView

#pragma mark - UIView

- (instancetype)init {
    DDLogVerbose(@"%@ init", LOG_TAG);
    
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"MenuGroupMemberView" owner:self options:nil];
    self = [objects objectAtIndex:0];
    
    self.frame = CGRectMake(0, 0, Design.DISPLAY_WIDTH, Design.DISPLAY_HEIGHT);
        
    if (self) {
        [self initViews];
    }
    return self;
}

#pragma mark - Public methods

- (void)openMenu:(UIContact *)uiMember canInvite:(BOOL)canInvite canRemove:(BOOL)canRemove {
    DDLogVerbose(@"%@ openMenu: %@ canInvite: %@ canRemove: %@", LOG_TAG, uiMember, canInvite ? @"YES" : @"NO", canRemove ? @"YES" : @"NO");
    
    self.uiMember = uiMember;
    
    self.canInvite = canInvite;
    self.canRemove = canRemove;
    
    [self updateMember];
    
    [super openMenu];
}

#pragma mark - Private methods

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    [super initViews];
    
    self.headerViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.headerView.backgroundColor = Design.POPUP_BACKGROUND_COLOR;
    
    self.avatarViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.avatarViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.avatarView.layer.cornerRadius = self.avatarViewHeightConstraint.constant * 0.5;
    self.avatarView.clipsToBounds = YES;
    
    self.nameLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.nameLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.nameLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.nameLabel.font = Design.FONT_MEDIUM34;
    
    self.separatorInviteViewHeightConstraint.constant = Design.SEPARATOR_HEIGHT;
    self.separatorInviteView.backgroundColor = Design.SEPARATOR_COLOR_GREY;
    
    self.inviteViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.inviteView.backgroundColor = Design.POPUP_BACKGROUND_COLOR;
    self.inviteView.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *tapInviteGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleInviteViewTapGesture:)];
    [self.inviteView addGestureRecognizer:tapInviteGesture];
    
    self.inviteImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.inviteImageViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.inviteImageView.image = [self.inviteImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.inviteImageView.tintColor = Design.BLACK_COLOR;
    
    self.inviteLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.inviteLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.inviteLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.inviteLabel.font = Design.FONT_MEDIUM34;
    self.inviteLabel.text = TwinmeLocalizedString(@"group_member_view_controller_invite_personnal_relation", nil);
    
    self.separatorRemoveViewHeightConstraint.constant = Design.SEPARATOR_HEIGHT;
    self.separatorRemoveView.backgroundColor = Design.SEPARATOR_COLOR_GREY;
    
    self.removeViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    UIWindow *window = UIApplication.sharedApplication.keyWindow;
    CGFloat safeAreaInset = window.safeAreaInsets.bottom;
    
    self.removeViewBottomConstraint.constant = safeAreaInset;
    
    self.removeView.backgroundColor = Design.POPUP_BACKGROUND_COLOR;
    self.removeView.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *tapRemoveGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleRemoveViewTapGesture:)];
    [self.removeView addGestureRecognizer:tapRemoveGesture];
    
    self.removeImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.removeImageViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.removeLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.removeLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.removeLabel.textColor = Design.FONT_COLOR_RED;
    self.removeLabel.font = Design.FONT_MEDIUM34;
    self.removeLabel.text = TwinmeLocalizedString(@"application_remove", nil);
}

- (void)updateMember {
    DDLogVerbose(@"%@ updateMember", LOG_TAG);
    
    self.nameLabel.text = self.uiMember.name;
    self.avatarView.image = self.uiMember.avatar;
    
    if (self.canRemove) {
        self.removeView.alpha = 1.0f;
    } else {
        self.removeView.alpha = 0.5f;
    }
    
    if (self.canInvite) {
        self.inviteView.alpha = 1.0f;
    } else {
        self.inviteView.alpha = 0.5f;
    }
}

- (void)finish {
    DDLogVerbose(@"%@ finish", LOG_TAG);
    
    if ([self.menuGroupMemberDelegate respondsToSelector:@selector(cancelMenuGroupMember:)]) {
        [self.menuGroupMemberDelegate cancelMenuGroupMember:self];
    }
}

- (void)handleRemoveViewTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleRemoveViewTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        if ([self.menuGroupMemberDelegate respondsToSelector:@selector(removeMember:uiContact:canRemove:)]) {
            [self.menuGroupMemberDelegate removeMember:self uiContact:self.uiMember canRemove:self.canRemove];
        }
    }
}

- (void)handleInviteViewTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleInviteViewTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        if ([self.menuGroupMemberDelegate respondsToSelector:@selector(inviteMemberAsContact:member:canInvite:)]) {
            [self.menuGroupMemberDelegate inviteMemberAsContact:self member:self.uiMember canInvite:self.canInvite];
        }
    }
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    self.removeLabel.font = Design.FONT_MEDIUM34;
    self.inviteLabel.font = Design.FONT_MEDIUM34;
    self.nameLabel.font = Design.FONT_MEDIUM34;
}

@end

