/*
 *  Copyright (c) 2020-2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <Utils/NSString+Utils.h>

#import "MenuRoomMemberView.h"

#import <TwinmeCommon/Design.h>
#import "UIRoomMember.h"

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif


//
// Interface: MenuRoomMemberView ()
//

@interface MenuRoomMemberView ()<CAAnimationDelegate>

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
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separatorAdminViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *separatorAdminView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *adminViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *adminView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *adminImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *adminImageViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *adminImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *adminLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *adminLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *adminLabel;
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

@property (nonatomic) UIRoomMember *uiMember;

@property (nonatomic) BOOL canInvite;
@property (nonatomic) BOOL canRemove;
@property (nonatomic) BOOL removeAdmin;

@end

//
// Implementation: MenuRoomMemberView
//

#undef LOG_TAG
#define LOG_TAG @"MenuRoomMemberView"

@implementation MenuRoomMemberView

#pragma mark - UIView

- (instancetype)init {
    DDLogVerbose(@"%@ init", LOG_TAG);
    
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"MenuRoomMemberView" owner:self options:nil];
    self = [objects objectAtIndex:0];
    
    self.frame = CGRectMake(0, 0, Design.DISPLAY_WIDTH, Design.DISPLAY_HEIGHT);
    self.removeAdmin = NO;
    
    if (self) {
        [self initViews];
    }
    return self;
}

#pragma mark - Public methods

- (void)openMenu:(UIRoomMember *)uiMember showAdminAction:(BOOL)showAdminAction showInviteAction:(BOOL)showInviteAction removeAdminAction:(BOOL)removeAdminAction {
    DDLogVerbose(@"%@ openMenu: %@ showAdminAction: %@ showInviteAction: %@ removeAdminAction: %@", LOG_TAG, uiMember, showAdminAction ? @"YES" : @"NO", showInviteAction ? @"YES" : @"NO", removeAdminAction ? @"YES" : @"NO");
    
    self.uiMember = uiMember;
    
    self.canRemove = showInviteAction;
    self.canInvite = showInviteAction;
    self.removeAdmin = removeAdminAction;
    
    if (showAdminAction) {
        self.adminView.hidden = NO;
        self.removeView.hidden = NO;
        self.separatorAdminView.hidden = NO;
        self.separatorRemoveView.hidden = NO;
        self.adminViewHeightConstraint.constant = Design.SETTING_CELL_HEIGHT;
        self.removeViewHeightConstraint.constant = Design.SETTING_CELL_HEIGHT;
        
        if (self.removeAdmin) {
            self.adminLabel.text = TwinmeLocalizedString(@"room_members_view_controller_remove_admin_title", nil);
        } else {
            self.adminLabel.text = TwinmeLocalizedString(@"room_members_view_controller_change_admin_title", nil);
        }
    } else {
        self.adminView.hidden = YES;
        self.removeView.hidden = YES;
        self.separatorAdminView.hidden = YES;
        self.separatorRemoveView.hidden = YES;
        self.adminViewHeightConstraint.constant = 0;
        self.removeViewHeightConstraint.constant = 0;
    }
    
    if (showInviteAction) {
        self.inviteView.hidden = NO;
        self.separatorInviteView.hidden = NO;
        self.inviteViewHeightConstraint.constant = Design.SETTING_CELL_HEIGHT;
    } else {
        self.inviteView.hidden = YES;
        self.separatorInviteView.hidden = YES;
        self.inviteViewHeightConstraint.constant = 0;
    }
    
    [self updateMember];
    [self updateFont];
    [self updateColor];
        
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
    
    self.separatorAdminViewHeightConstraint.constant = Design.SEPARATOR_HEIGHT;
    self.separatorAdminView.backgroundColor = Design.SEPARATOR_COLOR_GREY;
    
    self.adminViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.adminView.backgroundColor = Design.POPUP_BACKGROUND_COLOR;
    self.adminView.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *tapAdmineGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleAdminViewTapGesture:)];
    [self.adminView addGestureRecognizer:tapAdmineGesture];
    
    self.adminImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.adminImageViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.adminImageView.image = [self.adminImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.adminImageView.tintColor = Design.BLACK_COLOR;
    
    self.adminLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.adminLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.adminLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.adminLabel.font = Design.FONT_MEDIUM34;
    self.adminLabel.text = TwinmeLocalizedString(@"room_members_view_controller_change_admin_title", nil);
    
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
    
    if ([self.menuRoomMemberDelegate respondsToSelector:@selector(cancelMenuRoomMember:)]) {
        [self.menuRoomMemberDelegate cancelMenuRoomMember:self];
    }
}

- (void)handleRemoveViewTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleRemoveViewTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        if ([self.menuRoomMemberDelegate respondsToSelector:@selector(removeMember:uiMember:canRemove:)]) {
            [self.menuRoomMemberDelegate removeMember:self uiMember:self.uiMember canRemove:self.canRemove];
        }
    }
}

- (void)handleInviteViewTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleInviteViewTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        if ([self.menuRoomMemberDelegate respondsToSelector:@selector(inviteMemberAsContact:uiMember:canInvite:)]) {
            [self.menuRoomMemberDelegate inviteMemberAsContact:self uiMember:self.uiMember canInvite:self.canInvite];
        }
    }
}

- (void)handleAdminViewTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleAdminViewTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        if (self.removeAdmin) {
            if ([self.menuRoomMemberDelegate respondsToSelector:@selector(removeAdministrator:uiMember:)]) {
                [self.menuRoomMemberDelegate removeAdministrator:self uiMember:self.uiMember];
            }
        } else {
            if ([self.menuRoomMemberDelegate respondsToSelector:@selector(changeAdministrator:uiMember:)]) {
                [self.menuRoomMemberDelegate changeAdministrator:self uiMember:self.uiMember];
            }
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

