/*
 *  Copyright (c) 2020-2021 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <Utils/NSString+Utils.h>

#import "MenuRoomMemberView.h"

#import "RoomMembersViewController.h"
#import <TwinmeCommon/Design.h>
#import "UIRoomMember.h"

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static const CGFloat ANIMATION_DURATION = 0.1;
static const CGFloat DESIGN_MENU_VIEW_HEIGHT = 770;
static const CGFloat DESIGN_HEADER_ACTION_VIEW_HEIGHT = 220;
static const CGFloat DESIGN_ACTION_VIEW_HEIGHT = 120;

//
// Interface: MenuRoomMemberView ()
//

@interface MenuRoomMemberView () <CAAnimationDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cancelViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cancelViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cancelViewBottomConstraint;
@property (weak, nonatomic) IBOutlet UIView *cancelView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cancelLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet UILabel *cancelLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *actionViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *actionViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *actionViewBottomConstraint;
@property (weak, nonatomic) IBOutlet UIView *actionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *avatarViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *avatarViewTopConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *avatarView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameLabelTopConstraint;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separatorAdminViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *separatorAdminView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *adminViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *adminView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *adminLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet UILabel *adminLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separatorInviteViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *separatorInviteView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *inviteViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *inviteView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *inviteLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet UILabel *inviteLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separatorRemoveViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *separatorRemoveView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *removeViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *removeView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *removeLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet UILabel *removeLabel;

@property (nonatomic) UIRoomMember *uiMember;

@property (nonatomic) NSMutableArray *animationArray;

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
    
    self = [super init];
    
    self.frame = CGRectMake(0, 0, Design.DISPLAY_WIDTH, DESIGN_MENU_VIEW_HEIGHT * Design.HEIGHT_RATIO);
    
    self.animationArray = [[NSMutableArray alloc]init];
    self.removeAdmin = NO;
    
    if (self) {
        [self initViews];
    }
    return self;
}

#pragma mark - Public methods

- (void)openMenu:(UIRoomMember *)uiMember showAdminAction:(BOOL)showAdminAction showInviteAction:(BOOL)showInviteAction removeAdminAction:(BOOL)removeAdminAction {
    DDLogVerbose(@"%@ openMenu: %@", LOG_TAG, uiMember);
    
    self.uiMember = uiMember;
    self.removeAdmin = removeAdminAction;
    
    [self updateMember];
    [self updateFont];
    [self updateColor];
    
    self.actionView.alpha = 0;
    self.cancelView.alpha = 0;
    
    int countAction = 0;
    
    if (showAdminAction) {
        self.adminView.hidden = NO;
        self.removeView.hidden = NO;
        self.separatorAdminView.hidden = NO;
        self.separatorRemoveView.hidden = NO;
        self.adminViewHeightConstraint.constant = Design.HEIGHT_RATIO * DESIGN_ACTION_VIEW_HEIGHT;
        self.removeViewHeightConstraint.constant = Design.HEIGHT_RATIO * DESIGN_ACTION_VIEW_HEIGHT;
        countAction = 2;
        
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
        self.inviteViewHeightConstraint.constant = Design.HEIGHT_RATIO * DESIGN_ACTION_VIEW_HEIGHT;
        countAction += 1;
    } else {
        self.inviteView.hidden = YES;
        self.separatorInviteView.hidden = YES;
        self.inviteViewHeightConstraint.constant = 0;
    }
    
    self.actionViewHeightConstraint.constant = (DESIGN_HEADER_ACTION_VIEW_HEIGHT * Design.HEIGHT_RATIO) + (countAction * Design.HEIGHT_RATIO * DESIGN_ACTION_VIEW_HEIGHT);
    
    [self.animationArray removeAllObjects];
    [self.animationArray addObjectsFromArray:[NSArray arrayWithObjects:@"cancel", @"action", nil]];
    [self animationMenu];
}

- (void)animationMenu {
    DDLogVerbose(@"%@ animationMenu", LOG_TAG);
    
    UIView *animationView;
    NSString *key = self.animationArray.firstObject;
    
    if ([key isEqualToString:@"cancel"]) {
        animationView = self.cancelView;
    } else if ([key isEqualToString:@"action"]) {
        animationView = self.actionView;
    }
    
    if (animationView) {
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        [animation setValue:key forKey:@"layer"];
        animation.delegate = self;
        animation.repeatCount = 1;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
        animation.duration = ANIMATION_DURATION;
        animation.fromValue = [NSNumber numberWithFloat:0.0];
        animation.toValue = [NSNumber numberWithFloat:1.0];
        animation.removedOnCompletion = NO;
        animationView.layer.opacity = 1.0;
        [animationView.layer addAnimation:animation forKey:nil];
    }
}

- (void)animationDidStop:(CAAnimation *)animation finished:(BOOL)finished {
    DDLogVerbose(@"%@ animationDidStop: %@ finished:%d", LOG_TAG, animation, finished);
    
    if (finished) {
        [self.animationArray removeObjectAtIndex:0];
        if (self.animationArray.count > 0) {
            [self animationMenu];
        }
    }
}

#pragma mark - Private methods

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    self.userInteractionEnabled = YES;
    
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"MenuRoomMemberView" owner:self options:nil];
    UIView *view = [objects objectAtIndex:0];
    view.frame = CGRectMake(0, 0, Design.DISPLAY_WIDTH, DESIGN_MENU_VIEW_HEIGHT * Design.HEIGHT_RATIO);
    [self addSubview:[objects objectAtIndex:0]];
    
    self.cancelViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.cancelViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.cancelView.userInteractionEnabled = YES;
    self.cancelView.isAccessibilityElement = YES;
    self.cancelView.accessibilityLabel = TwinmeLocalizedString(@"application_cancel", nil);
    self.cancelView.backgroundColor = Design.POPUP_BACKGROUND_COLOR;
    self.cancelView.layer.cornerRadius = 28 * Design.HEIGHT_RATIO;
    self.cancelView.clipsToBounds = YES;
    
    UITapGestureRecognizer *tapCancelGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleCancelViewTapGesture:)];
    [self.cancelView addGestureRecognizer:tapCancelGesture];
    
    self.cancelLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    
    self.cancelLabel.textColor = [UIColor colorWithRed:0 green:122./255. blue:255./255. alpha:1];
    self.cancelLabel.font = Design.FONT_BOLD34;
    self.cancelLabel.text = TwinmeLocalizedString(@"application_cancel", nil);
    
    self.actionViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.actionViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.actionViewBottomConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.actionView.userInteractionEnabled = YES;
    self.actionView.backgroundColor = Design.POPUP_BACKGROUND_COLOR;
    self.actionView.layer.cornerRadius = 28 * Design.HEIGHT_RATIO;
    self.actionView.clipsToBounds = YES;
    
    self.avatarViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.avatarViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.avatarView.layer.cornerRadius = self.avatarViewHeightConstraint.constant * 0.5;
    self.avatarView.clipsToBounds = YES;
    
    self.nameLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.nameLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.nameLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.nameLabel.font = Design.FONT_REGULAR34;
    
    self.adminViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.adminView.backgroundColor = Design.SEPARATOR_COLOR_GREY;
    
    self.adminView.backgroundColor = Design.POPUP_BACKGROUND_COLOR;
    self.adminView.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *tapAdminGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleAdminViewTapGesture:)];
    [self.adminView addGestureRecognizer:tapAdminGesture];
    
    self.adminLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    
    self.adminLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.adminLabel.font = Design.FONT_BOLD34;
    self.adminLabel.text = TwinmeLocalizedString(@"room_members_view_controller_change_admin_title", nil);
    
    self.inviteViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.inviteView.backgroundColor = Design.SEPARATOR_COLOR_GREY;
    
    self.inviteView.backgroundColor = Design.POPUP_BACKGROUND_COLOR;
    self.inviteView.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *tapInviteGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleInviteViewTapGesture:)];
    [self.inviteView addGestureRecognizer:tapInviteGesture];
    
    self.inviteLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    
    self.inviteLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.inviteLabel.font = Design.FONT_BOLD34;
    self.inviteLabel.text = TwinmeLocalizedString(@"group_member_view_controller_invite_personnal_relation", nil);
    
    self.separatorInviteViewHeightConstraint.constant = Design.SEPARATOR_HEIGHT;
    self.separatorInviteView.backgroundColor = Design.SEPARATOR_COLOR_GREY;
    
    self.separatorAdminViewHeightConstraint.constant = Design.SEPARATOR_HEIGHT;
    self.separatorAdminView.backgroundColor = Design.SEPARATOR_COLOR_GREY;
    
    self.separatorRemoveViewHeightConstraint.constant = Design.SEPARATOR_HEIGHT;
    self.separatorRemoveView.backgroundColor = Design.SEPARATOR_COLOR_GREY;
    
    self.removeViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.removeView.backgroundColor = Design.POPUP_BACKGROUND_COLOR;
    self.removeView.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *tapRemoveGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleRemoveViewTapGesture:)];
    [self.removeView addGestureRecognizer:tapRemoveGesture];
    
    self.removeLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    
    self.removeLabel.textColor = Design.FONT_COLOR_RED;
    self.removeLabel.font = Design.FONT_BOLD34;
    self.removeLabel.text = TwinmeLocalizedString(@"application_remove", nil);
}

- (void)updateMember {
    DDLogVerbose(@"%@ updateMember", LOG_TAG);
    
    self.nameLabel.text = self.uiMember.name;
    self.avatarView.image = self.uiMember.avatar;
}

- (void)handleCancelViewTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleCancelViewTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        if ([self.menuRoomMemberDelegate respondsToSelector:@selector(cancelMenu)]) {
            [self.menuRoomMemberDelegate cancelMenu];
        }
    }
}

- (void)handleRemoveViewTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleRemoveViewTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        if ([self.menuRoomMemberDelegate respondsToSelector:@selector(removeFromRoom:)]) {
            [self.menuRoomMemberDelegate removeFromRoom:self.uiMember];
        }
    }
}

- (void)handleAdminViewTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleAdminViewTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        if (self.removeAdmin) {
            if ([self.menuRoomMemberDelegate respondsToSelector:@selector(removeAdministrator:)]) {
                [self.menuRoomMemberDelegate removeAdministrator:self.uiMember];
            }
        } else {
            if ([self.menuRoomMemberDelegate respondsToSelector:@selector(changeAdministrator:)]) {
                [self.menuRoomMemberDelegate changeAdministrator:self.uiMember];
            }
        }
    }
}

- (void)handleInviteViewTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleInviteViewTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        if ([self.menuRoomMemberDelegate respondsToSelector:@selector(inviteMember:)]) {
            [self.menuRoomMemberDelegate inviteMember:self.uiMember];
        }
    }
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    self.removeLabel.font = Design.FONT_BOLD34;
    self.adminLabel.font = Design.FONT_BOLD34;
    self.nameLabel.font = Design.FONT_REGULAR34;
    self.cancelLabel.font = Design.FONT_BOLD34;
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    self.nameLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.adminLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.removeLabel.textColor = Design.FONT_COLOR_RED;
    self.separatorAdminView.backgroundColor = Design.SEPARATOR_COLOR_GREY;
    self.separatorRemoveView.backgroundColor = Design.SEPARATOR_COLOR_GREY;
    self.removeView.backgroundColor = Design.POPUP_BACKGROUND_COLOR;
    self.adminView.backgroundColor = Design.POPUP_BACKGROUND_COLOR;
    self.actionView.backgroundColor = Design.POPUP_BACKGROUND_COLOR;
    self.cancelView.backgroundColor = Design.POPUP_BACKGROUND_COLOR;
}

@end

