/*
 *  Copyright (c) 2017-2023 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Christian Jacquemot (Christian.Jacquemot@twinlife-systems.com)
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "ContactCell.h"

#import <Twinme/TLTwinmeAttributes.h>

#import "UIContact.h"
#import "UIContactTag.h"

#import <TwinmeCommon/Design.h>

#import "UIColor+Hex.h"

//
// Interface: ContactCell ()
//

@interface ContactCell ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *avatarViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *avatarViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *avatarView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tagViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tagViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tagViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tagViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet UIView *tagView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tagLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tagLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *tagLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tagImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tagImageViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *tagImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *certifiedRelationImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *certifiedRelationImageViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *certifiedRelationImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separatorViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separatorViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *separatorView;

@end

//
// Implementation: ContactCell
//

#undef LOG_TAG
#define LOG_TAG @"ContactCell"

@implementation ContactCell

- (void)awakeFromNib {
    
    [super awakeFromNib];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.backgroundColor = Design.WHITE_COLOR;
    
    self.avatarViewHeightConstraint.constant = Design.AVATAR_HEIGHT;
    self.avatarViewLeadingConstraint.constant = Design.AVATAR_LEADING;
    
    CALayer *avatarViewLayer = self.avatarView.layer;
    avatarViewLayer.cornerRadius = self.avatarViewHeightConstraint.constant * 0.5;
    avatarViewLayer.masksToBounds = YES;
    
    self.nameLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.nameLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.nameLabel.font = Design.FONT_REGULAR34;
    self.nameLabel.textColor = Design.FONT_COLOR_DEFAULT;
    
    self.tagViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.tagViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.tagViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.tagViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.tagView.clipsToBounds = YES;
    self.tagView.layer.cornerRadius = Design.CONTAINER_RADIUS;
    self.tagView.layer.borderWidth = 1;
    
    self.tagLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.tagLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
   
    self.tagLabel.font = Design.FONT_REGULAR28;
    
    self.tagImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.tagImageViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.tagImageView.tintColor = Design.ACCESSORY_COLOR;
    self.tagImageView.hidden = YES;
    
    self.certifiedRelationImageViewHeightConstraint.constant = Design.CERTIFIED_HEIGHT;
    self.certifiedRelationImageViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.separatorViewBottomConstraint.constant = Design.SEPARATOR_HEIGHT;
    self.separatorViewHeightConstraint.constant = Design.SEPARATOR_HEIGHT;
    
    self.separatorView.backgroundColor = Design.SEPARATOR_COLOR_GREY;
    self.separatorView.alpha = 0.5f;
}

- (void)prepareForReuse {
    
    [super prepareForReuse];
    
    self.avatarView.image = nil;
    self.nameLabel.text = nil;
}

- (void)bindWithContact:(UIContact *)uiContact hideSeparator:(BOOL)hideSeparator {
        
    self.avatarView.image = uiContact.avatar;
    self.nameLabel.text = uiContact.name;
    self.separatorView.hidden = hideSeparator;
    self.tagImageView.hidden = YES;
    
    if ([uiContact.avatar isEqual:[TLTwinmeAttributes DEFAULT_GROUP_AVATAR]]) {
        self.avatarView.backgroundColor = [UIColor colorWithHexString:Design.DEFAULT_COLOR alpha:1.0];
        self.avatarView.tintColor = [UIColor whiteColor];
    } else {
        self.avatarView.backgroundColor = [UIColor clearColor];
        self.avatarView.tintColor = [UIColor clearColor];
    }
    
    self.certifiedRelationImageView.hidden = !uiContact.isCertified;
    
    if (uiContact.isCertified) {
        self.nameLabelTrailingConstraint.constant = (Design.NAME_TRAILING * 2) + self.certifiedRelationImageViewHeightConstraint.constant + self.certifiedRelationImageViewLeadingConstraint.constant;
    } else {
        self.nameLabelTrailingConstraint.constant = Design.NAME_TRAILING;
    }
        
    if (uiContact.contactTag) {
        self.tagView.hidden = NO;
        self.tagView.backgroundColor = uiContact.contactTag.backgroundColor;
        self.tagView.layer.borderColor = uiContact.contactTag.foregroundColor.CGColor;
        
        self.tagLabel.textColor = uiContact.contactTag.foregroundColor;
        self.tagLabel.text = uiContact.contactTag.title;
        
        self.nameLabelTrailingConstraint.constant = (Design.NAME_TRAILING * 2) +
        self.tagLabel.intrinsicContentSize.width + self.tagLabelLeadingConstraint.constant + self.tagLabelLeadingConstraint.constant + self.tagLabelTrailingConstraint.constant;
        
        self.certifiedRelationImageView.hidden = YES;
    } else {
        self.tagView.hidden = YES;
        self.nameLabelTrailingConstraint.constant = Design.NAME_TRAILING;
    }
    
    [self updateFont];
    [self updateColor];
}

- (void)bindWithName:(NSString *)name avatar:(UIImage *)avatar hideSeparator:(BOOL)hideSeparator hideSchedule:(BOOL)hideSchedule {
        
    self.avatarView.image = avatar;
    self.nameLabel.text = name;
    self.separatorView.hidden = hideSeparator;
    self.tagImageView.hidden = hideSchedule;
    self.certifiedRelationImageView.hidden = YES;
        
    self.tagView.hidden = YES;
    self.nameLabelTrailingConstraint.constant = Design.NAME_TRAILING;

    [self updateFont];
    [self updateColor];
}

- (void)updateFont {
    
    self.nameLabel.font = Design.FONT_REGULAR34;
    self.tagLabel.font = Design.FONT_REGULAR28;
}

- (void)updateColor {
    
    self.backgroundColor = Design.WHITE_COLOR;
    self.nameLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.separatorView.backgroundColor = Design.SEPARATOR_COLOR_GREY;
}

@end

