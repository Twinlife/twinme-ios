/*
 *  Copyright (c) 2018-2020 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import "GroupMemberViewController.h"

#import <Twinlife/TLConversationService.h>

#import <Twinme/TLTwinmeContext.h>
#import <Twinme/TLGroup.h>

#import <Utils/NSString+Utils.h>

#import "GroupMemberCell.h"
#import "UIInvitation.h"

#import <TwinmeCommon/Design.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

//
// Interface: GroupMemberCell ()
//

@interface GroupMemberCell ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *avatarViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *avatarViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *avatarView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separatorViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separatorViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *separatorView;

@end

//
// Implementation: GroupMemberCell
//

#undef LOG_TAG
#define LOG_TAG @"GroupMemberCell"

@implementation GroupMemberCell

- (void)awakeFromNib {
    
    [super awakeFromNib];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.contentView.backgroundColor = Design.WHITE_COLOR;
    
    self.avatarViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.avatarViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    
    CALayer *avatarViewLayer = self.avatarView.layer;
    avatarViewLayer.cornerRadius = self.avatarViewHeightConstraint.constant * 0.5;
    avatarViewLayer.masksToBounds = YES;
    
    self.nameLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.nameLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.nameLabel.font = Design.FONT_REGULAR32;
    self.nameLabel.textColor = Design.FONT_COLOR_DEFAULT;
    
    self.separatorViewBottomConstraint.constant = Design.SEPARATOR_HEIGHT;
    self.separatorViewHeightConstraint.constant = Design.SEPARATOR_HEIGHT;
    
    self.separatorView.backgroundColor = Design.SEPARATOR_COLOR_GREY;
    self.separatorView.alpha = 0.5f;
}

- (void)prepareForReuse {
    
    [super prepareForReuse];
    
    self.avatarView.hidden = YES;
    self.avatarView.image = nil;
    self.nameLabel.text = nil;
}

- (void)bindWithContact:(UIContact *)uiContact invitation:(UIInvitation *)invitation hideSeparator:(BOOL)hideSeparator {
    DDLogVerbose(@"%@ bindWithContact: %@ invitation:%@", LOG_TAG, uiContact, invitation);
    
    self.avatarView.hidden = NO;
    
    self.avatarView.image = uiContact.avatar;
    self.nameLabel.text = uiContact.name;
    
    NSMutableAttributedString *memberAttributedString = [[NSMutableAttributedString alloc]initWithString:uiContact.name attributes:[NSDictionary dictionaryWithObject:Design.FONT_REGULAR32 forKey:NSFontAttributeName]];
    
    NSString *statusInvitation = @"";
    if ([invitation peerFailure]) {
        statusInvitation = TwinmeLocalizedString(@"conversation_view_controller_invitation_failed", nil);
    } else if (invitation.invitationDescriptor) {
        switch (invitation.invitationDescriptor.status) {
            case TLInvitationDescriptorStatusTypePending:
                statusInvitation = TwinmeLocalizedString(@"conversation_view_controller_invitation_pending", nil);
                break;
                
            case TLInvitationDescriptorStatusTypeAccepted:
                statusInvitation = TwinmeLocalizedString(@"conversation_view_controller_invitation_accepted", nil);
                break;
                
            case TLInvitationDescriptorStatusTypeJoined:
                statusInvitation = TwinmeLocalizedString(@"conversation_view_controller_invitation_joined", nil);
                break;
                
            case TLInvitationDescriptorStatusTypeRefused:
                statusInvitation = TwinmeLocalizedString(@"conversation_view_controller_invitation_refused", nil);
                break;
                
            case TLInvitationDescriptorStatusTypeWithdrawn:
                statusInvitation = TwinmeLocalizedString(@"conversation_view_controller_invitation_refused", nil);
                break;
                
            default:
                break;
        }
    }
    
    if (![statusInvitation isEqualToString:@""]) {
        [memberAttributedString appendAttributedString:[[NSMutableAttributedString alloc]initWithString:@"\n"]];
        [memberAttributedString appendAttributedString:[[NSMutableAttributedString alloc]initWithString:statusInvitation attributes:[NSDictionary dictionaryWithObject:Design.FONT_REGULAR24 forKey:NSFontAttributeName]]];
    }
    
    self.nameLabel.attributedText = memberAttributedString;
    
    self.separatorView.hidden = hideSeparator;
    
    [self updateColor];
}

- (void)updateColor {
    
    self.contentView.backgroundColor = Design.WHITE_COLOR;
    self.nameLabel.textColor = Design.FONT_COLOR_DEFAULT;
}

@end
