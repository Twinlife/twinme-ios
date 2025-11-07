/*
 *  Copyright (c) 2019-2020 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <Twinme/TLContact.h>
#import <Twinme/TLSpace.h>

#import "MoveContactCell.h"

#import "UIMoveContact.h"
#import <TwinmeCommon/Design.h>

//
// Interface: MoveContactCell ()
//

@interface MoveContactCell ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *avatarViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *avatarViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *avatarView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameLabelYConstraint;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *spaceLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *spaceLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *spaceLabelYConstraint;
@property (weak, nonatomic) IBOutlet UILabel *spaceLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *certifiedRelationImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *certifiedRelationImageViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *certifiedRelationImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *checkMarkViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *checkMarkViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet UIView *checkMarkView;
@property (weak, nonatomic) IBOutlet UIImageView *checkMarkImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separatorViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separatorViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *separatorView;

@property UIMoveContact *uiMoveContact;

@end

//
// Implementation: MoveContactCell
//

#undef LOG_TAG
#define LOG_TAG @"MoveContactCell"

@implementation MoveContactCell

- (void)awakeFromNib {
    
    [super awakeFromNib];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.contentView.backgroundColor = Design.WHITE_COLOR;
    
    self.avatarViewHeightConstraint.constant = Design.AVATAR_HEIGHT;
    self.avatarViewLeadingConstraint.constant = Design.AVATAR_LEADING;
    
    CALayer *avatarViewLayer = self.avatarView.layer;
    avatarViewLayer.cornerRadius = self.avatarViewHeightConstraint.constant * 0.5;
    avatarViewLayer.masksToBounds = YES;
    
    self.nameLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.nameLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.nameLabelYConstraint.constant = -Design.FONT_MEDIUM34.lineHeight * 0.5f;;
    
    self.nameLabel.font = Design.FONT_MEDIUM34;
    self.nameLabel.textColor = Design.FONT_COLOR_DEFAULT;
    
    self.spaceLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.spaceLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.spaceLabelYConstraint.constant = Design.FONT_REGULAR32.lineHeight * 0.5f;;
    
    self.spaceLabel.font = Design.FONT_REGULAR32;
    self.spaceLabel.textColor = Design.FONT_COLOR_DEFAULT;
    
    
    self.checkMarkViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.checkMarkViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    CALayer *checkMarkViewLayer = self.checkMarkView.layer;
    checkMarkViewLayer.cornerRadius = self.checkMarkViewHeightConstraint.constant * 0.5;
    checkMarkViewLayer.borderWidth = Design.CHECKMARK_BORDER_WIDTH;
    checkMarkViewLayer.borderColor = Design.CHECKMARK_BORDER_COLOR.CGColor;
    
    self.checkMarkImageView.tintColor = Design.MAIN_COLOR;
    
    self.certifiedRelationImageViewHeightConstraint.constant = Design.CERTIFIED_HEIGHT;
    self.certifiedRelationImageViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    
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

- (void)bindWithContact:(UIMoveContact *)moveContact hideSeparator:(BOOL)hideSeparator {
    
    self.uiMoveContact = moveContact;
    
    self.avatarView.hidden = NO;
    self.avatarView.image = self.uiMoveContact.avatar;
    
    self.nameLabel.text = self.uiMoveContact.name;
    self.spaceLabel.text = self.uiMoveContact.contact.space.settings.name;
    
    self.checkMarkImageView.hidden = !self.uiMoveContact.isSelected;
    
    if (self.uiMoveContact.isCertified) {
        self.certifiedRelationImageView.hidden = NO;
        self.nameLabelTrailingConstraint.constant = (Design.NAME_TRAILING * 2) + self.certifiedRelationImageViewHeightConstraint.constant + self.certifiedRelationImageViewLeadingConstraint.constant;
    } else {
        self.nameLabelTrailingConstraint.constant = Design.NAME_TRAILING;
        self.certifiedRelationImageView.hidden = YES;
    }
    
    if (self.uiMoveContact.canMove) {
        self.checkMarkView.alpha = 1.0f;
        self.avatarView.alpha = 1.0f;
        self.nameLabel.alpha = 1.0f;
        self.certifiedRelationImageView.alpha = 1.0f;
    } else {
        self.checkMarkView.alpha = 0.5f;
        self.avatarView.alpha = 0.5f;
        self.nameLabel.alpha = 0.5f;
        self.certifiedRelationImageView.alpha = 0.5f;
    }
    
    self.separatorView.hidden = hideSeparator;
    
    [self updateFont];
    [self updateColor];
}

- (void)updateFont {
    
    self.nameLabel.font = Design.FONT_MEDIUM34;
    self.spaceLabel.font = Design.FONT_MEDIUM32;
    self.nameLabelYConstraint.constant = -Design.FONT_MEDIUM34.lineHeight * 0.5f;
    self.spaceLabelYConstraint.constant = Design.FONT_REGULAR32.lineHeight * 0.5f;
}

- (void)updateColor {
    
    self.contentView.backgroundColor = Design.WHITE_COLOR;
    self.nameLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.spaceLabel.textColor = Design.FONT_COLOR_PROFILE_GREY;
    self.separatorView.backgroundColor = Design.SEPARATOR_COLOR_GREY;
    self.checkMarkImageView.tintColor = Design.MAIN_COLOR;
}

@end

