/*
 *  Copyright (c) 2017-2021 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Christian Jacquemot (Christian.Jacquemot@twinlife-systems.com)
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "ConversationCell.h"

#import <Twinme/TLTwinmeAttributes.h>
#import <Twinme/TLGroupMember.h>

#import "UIContact.h"
#import "UIConversation.h"
#import "UIGroupConversation.h"

#import "UIColor+Hex.h"

#import <TwinmeCommon/Design.h>

#import <Utils/NSString+Utils.h>

static const CGFloat DESIGN_NAME_TRAILING = 20;


//
// Interface: ConversationCell ()
//

@interface ConversationCell ()<UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *avatarViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *avatarViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet UIView *avatarView;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameLabelTopConstraint;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separatorViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separatorViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *separatorView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *memberOneAvatarViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *memberOneAvatarViewTopConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *memberOneAvatarView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *memberTwoAvatarViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *memberTwoAvatarViewTopConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *memberTwoAvatarView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *memberThreeAvatarViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *memberThreeAvatarViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *memberThreeAvatarView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *memberFourAvatarViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *memberFourAvatarView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *moreMembersLabelHeightConstraint;
@property (weak, nonatomic) IBOutlet UILabel *moreMembersLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dateLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dateLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *unreadViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *unreadViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *unreadView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tagViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tagViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tagViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet UIView *tagView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tagLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tagLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *tagLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *certifiedRelationImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *certifiedRelationImageViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *certifiedRelationImageView;

@property (nonatomic) UIConversation *uiConversation;

@end

//
// Implementation: ConversationCell
//

@implementation ConversationCell

- (void)awakeFromNib {
    
    [super awakeFromNib];
    
    self.backgroundColor = Design.WHITE_COLOR;
    
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onLongPressInsideContent:)];
    longPressGesture.delegate = self;
    [self addGestureRecognizer:longPressGesture];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapInsideContent:)];
    tapGesture.delegate = self;
    [self addGestureRecognizer:tapGesture];
    [tapGesture requireGestureRecognizerToFail:longPressGesture];
    
    self.avatarViewHeightConstraint.constant = Design.AVATAR_HEIGHT;
    self.avatarViewLeadingConstraint.constant = Design.AVATAR_LEADING;
    
    CALayer *avatarViewLayer = self.avatarImageView.layer;
    avatarViewLayer.cornerRadius = self.avatarViewHeightConstraint.constant * 0.5;
    avatarViewLayer.masksToBounds = YES;
    
    CGFloat memberAvatarHeight = ceilf(self.memberOneAvatarViewHeightConstraint.constant * Design.HEIGHT_RATIO);
    CGFloat memberAvatarRadius = memberAvatarHeight * 0.5;
    
    self.memberOneAvatarViewHeightConstraint.constant = memberAvatarHeight;
    self.memberOneAvatarView.layer.cornerRadius = memberAvatarRadius;
    self.memberOneAvatarView.layer.masksToBounds = YES;
        
    self.memberTwoAvatarViewHeightConstraint.constant = memberAvatarHeight;
    self.memberTwoAvatarView.layer.cornerRadius = memberAvatarRadius;
    self.memberTwoAvatarView.layer.masksToBounds = YES;
    
    self.memberThreeAvatarViewHeightConstraint.constant = memberAvatarHeight;;
    self.memberThreeAvatarView.layer.cornerRadius = memberAvatarRadius;
    self.memberThreeAvatarView.layer.masksToBounds = YES;
    
    self.memberFourAvatarViewHeightConstraint.constant = memberAvatarHeight;
    self.memberFourAvatarView.layer.cornerRadius = memberAvatarRadius;
    self.memberFourAvatarView.layer.masksToBounds = YES;
    
    self.moreMembersLabelHeightConstraint.constant = memberAvatarHeight;
    self.moreMembersLabel.layer.cornerRadius = memberAvatarRadius;
    self.moreMembersLabel.layer.masksToBounds = YES;
    self.moreMembersLabel.backgroundColor = Design.FONT_COLOR_GREY;
    self.moreMembersLabel.font = Design.FONT_MEDIUM20;
    self.moreMembersLabel.textColor = [UIColor whiteColor];
    
    self.nameLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.nameLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.nameLabel.font = Design.FONT_REGULAR34;
    self.nameLabel.textColor = Design.FONT_COLOR_DEFAULT;
    
    self.messageLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.messageLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.messageLabel.font = Design.FONT_REGULAR28;
    self.messageLabel.textColor = [UIColor colorWithRed:115./255. green:138./255. blue:161./255. alpha:1.0];
    
    self.dateLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.dateLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.dateLabel.font = Design.FONT_REGULAR24;
    self.dateLabel.textColor = [UIColor colorWithRed:115./255. green:138./255. blue:161./255. alpha:1.0];
    
    if ([[UIApplication sharedApplication] userInterfaceLayoutDirection] == UIUserInterfaceLayoutDirectionRightToLeft) {
        self.dateLabel.textAlignment = NSTextAlignmentLeft;
    }
    
    self.separatorViewBottomConstraint.constant = Design.SEPARATOR_HEIGHT;
    self.separatorViewHeightConstraint.constant = Design.SEPARATOR_HEIGHT;
    
    self.separatorView.backgroundColor = Design.SEPARATOR_COLOR_GREY;
    self.separatorView.alpha = 0.5f;
    
    self.unreadViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.unreadViewHeightConstraint.constant *= Design.WIDTH_RATIO;
    
    self.unreadView.layer.cornerRadius = self.unreadViewHeightConstraint.constant * 0.5;
    self.unreadView.clipsToBounds = YES;
    self.unreadView.backgroundColor = Design.MAIN_COLOR;
    
    self.tagViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.tagViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.tagViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.tagView.clipsToBounds = YES;
    self.tagView.layer.cornerRadius = Design.CONTAINER_RADIUS;
    self.tagView.layer.borderWidth = 1;
    self.tagView.layer.borderColor = [UIColor colorWithRed:255./255. green:147./255. blue:0./255. alpha:1].CGColor;
    self.tagView.layer.backgroundColor = [UIColor colorWithRed:255./255. green:147./255. blue:0./255. alpha:0.12].CGColor;
    
    self.tagLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.tagLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
   
    self.tagLabel.font = Design.FONT_REGULAR28;
    self.tagLabel.textColor = [UIColor colorWithRed:255./255. green:147./255. blue:0./255. alpha:1];
    self.tagLabel.text = TwinmeLocalizedString(@"show_contact_view_controller_pending", nil);
    
    self.certifiedRelationImageViewHeightConstraint.constant = Design.CERTIFIED_HEIGHT;
    self.certifiedRelationImageViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
}

- (void)prepareForReuse {
    
    [super prepareForReuse];
    
    self.avatarImageView.image = nil;
    self.memberOneAvatarView.image = nil;
    self.memberTwoAvatarView.image = nil;
    self.memberThreeAvatarView.image = nil;
    self.memberFourAvatarView.image = nil;
    self.nameLabel.text = nil;
    self.dateLabel.text = nil;
    self.messageLabel.attributedText = nil;
}

- (void)bindWithConversation:(UIConversation *)uiConversation topMargin:(CGFloat)topMargin hideSeparator:(BOOL)hideSeparator {
    
    self.uiConversation = uiConversation;
        
    self.avatarImageView.backgroundColor = [UIColor clearColor];
    self.avatarImageView.tintColor = [UIColor clearColor];
    self.tagView.hidden = YES;
    self.messageLabel.hidden = NO;
    self.dateLabel.hidden = NO;
    self.certifiedRelationImageView.hidden = YES;
    
    self.nameLabelTrailingConstraint.constant = DESIGN_NAME_TRAILING * Design.HEIGHT_RATIO;
    
    if ([uiConversation isKindOfClass:[UIGroupConversation class]]) {
        UIGroupConversation *groupConversation = (UIGroupConversation *)uiConversation;
        if (![groupConversation.uiContact.avatar isEqual:[TLTwinmeAttributes DEFAULT_GROUP_AVATAR]] || groupConversation.groupAvatars.count < 2) {
            if ([groupConversation.uiContact.avatar isEqual:[TLTwinmeAttributes DEFAULT_GROUP_AVATAR]]) {
                self.avatarImageView.backgroundColor = [UIColor colorWithHexString:Design.DEFAULT_COLOR alpha:1.0];
                self.avatarImageView.tintColor = [UIColor whiteColor];
            }
            self.avatarImageView.image = groupConversation.uiContact.avatar;
            self.avatarImageView.hidden = NO;
            
            if (groupConversation.groupMemberCount > 0) {
                self.moreMembersLabel.hidden = NO;
                self.moreMembersLabel.text = [NSString stringWithFormat:@"+%lu", (unsigned long)groupConversation.groupMemberCount];
            } else {
                self.moreMembersLabel.hidden = YES;
            }
        } else {
            self.avatarImageView.hidden = YES;
            if (groupConversation.groupAvatars.count == 2) {
                self.memberOneAvatarView.image = [groupConversation.groupAvatars objectAtIndex:0];
                self.memberOneAvatarView.hidden = NO;
                float top = self.avatarViewHeightConstraint.constant * 0.5 - self.memberOneAvatarViewHeightConstraint.constant * 0.5;
                self.memberOneAvatarViewTopConstraint.constant = top;
                
                self.memberTwoAvatarView.image = [groupConversation.groupAvatars objectAtIndex:1];
                self.memberTwoAvatarView.hidden = NO;
                self.memberTwoAvatarViewTopConstraint.constant = top;
                
                self.memberThreeAvatarView.hidden = YES;
                self.memberFourAvatarView.hidden = YES;
                self.moreMembersLabel.hidden = YES;
            } else if (groupConversation.groupAvatars.count == 3) {
                self.memberOneAvatarView.image = [groupConversation.groupAvatars objectAtIndex:0];
                self.memberOneAvatarView.hidden = NO;
                self.memberOneAvatarViewTopConstraint.constant = 0;
                
                self.memberTwoAvatarView.image = [groupConversation.groupAvatars objectAtIndex:1];
                self.memberTwoAvatarView.hidden = NO;
                self.memberTwoAvatarViewTopConstraint.constant = 0;
                float leading = self.avatarViewHeightConstraint.constant * 0.5 - self.memberThreeAvatarViewHeightConstraint.constant * 0.5;
                self.memberThreeAvatarViewLeadingConstraint.constant = leading;
                
                self.memberThreeAvatarView.image = [groupConversation.groupAvatars objectAtIndex:2];
                self.memberThreeAvatarView.hidden = NO;
                
                self.memberFourAvatarView.hidden = YES;
                self.moreMembersLabel.hidden = YES;
            } else if (groupConversation.groupAvatars.count > 3) {
                self.memberOneAvatarView.image = [groupConversation.groupAvatars objectAtIndex:0];
                self.memberOneAvatarView.hidden = NO;
                self.memberOneAvatarViewTopConstraint.constant = 0;
                
                self.memberTwoAvatarView.image = [groupConversation.groupAvatars objectAtIndex:1];
                self.memberTwoAvatarView.hidden = NO;
                self.memberTwoAvatarViewTopConstraint.constant = 0;
                
                self.memberThreeAvatarView.image = [groupConversation.groupAvatars objectAtIndex:2];
                self.memberThreeAvatarView.hidden = NO;
                self.memberThreeAvatarViewLeadingConstraint.constant = 0;
                
                if (groupConversation.groupAvatars.count == 4) {
                    self.memberFourAvatarView.image = [groupConversation.groupAvatars objectAtIndex:3];
                    self.memberFourAvatarView.hidden = NO;
                    self.moreMembersLabel.hidden = YES;
                } else {
                    self.memberFourAvatarView.hidden = YES;
                    self.moreMembersLabel.hidden = NO;
                    NSUInteger more = groupConversation.groupMemberCount - 3;
                    self.moreMembersLabel.text = [NSString stringWithFormat:@"+%lu", (unsigned long)more];
                }
            }
        }
        
        if (groupConversation.groupConversationStateType == TLGroupConversationStateCreated) {
            self.tagView.hidden = NO;
            self.dateLabel.hidden = YES;
        }
    } else {
        self.memberOneAvatarView.hidden = YES;
        self.memberTwoAvatarView.hidden = YES;
        self.memberThreeAvatarView.hidden = YES;
        self.memberFourAvatarView.hidden = YES;
        self.moreMembersLabel.hidden = YES;
        self.avatarImageView.hidden = NO;
        self.avatarImageView.image = uiConversation.uiContact.avatar;
        
        if (uiConversation.uiContact.isCertified) {
            self.certifiedRelationImageView.hidden = NO;
            self.nameLabelTrailingConstraint.constant = self.certifiedRelationImageViewHeightConstraint.constant + self.certifiedRelationImageViewLeadingConstraint.constant * 2;
        }
    }
    
    self.nameLabelTopConstraint.constant = topMargin;
    self.nameLabel.text = uiConversation.uiContact.name;
    self.messageLabel.attributedText = [uiConversation getLastMessage];
    self.dateLabel.text = [uiConversation getLastMessageDate];
    
    self.unreadView.hidden = ![uiConversation isLastDescriptorUnread];
    self.separatorView.hidden = hideSeparator;
    
    [self updateFont];
    [self updateColor];
}

#pragma mark - UILongPressGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    
    return YES;
}

- (void)onTapInsideContent:(UITapGestureRecognizer *)tapGesture {
    
    if ([self.conversationsActionDelegate respondsToSelector:@selector(didTapConversation:)]) {
        [self.conversationsActionDelegate didTapConversation:self.uiConversation];
    }
}

- (void)onLongPressInsideContent:(UILongPressGestureRecognizer *)longPressGesture {
    
    if (longPressGesture.state == UIGestureRecognizerStateBegan && [self.conversationsActionDelegate respondsToSelector:@selector(didLongPressConversation:)]) {
        [self.conversationsActionDelegate didLongPressConversation:self.uiConversation];
    }
}

- (void)updateFont {
    
    self.nameLabel.font = Design.FONT_MEDIUM34;
    self.messageLabel.font = Design.FONT_REGULAR30;
    self.dateLabel.font = Design.FONT_REGULAR30;
    self.moreMembersLabel.font = Design.FONT_MEDIUM20;
}

- (void)updateColor {
    
    self.backgroundColor = Design.WHITE_COLOR;
    self.moreMembersLabel.backgroundColor = Design.FONT_COLOR_GREY;
    self.unreadView.backgroundColor = Design.MAIN_COLOR;
    self.nameLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.separatorView.backgroundColor = Design.SEPARATOR_COLOR_GREY;
}

@end
