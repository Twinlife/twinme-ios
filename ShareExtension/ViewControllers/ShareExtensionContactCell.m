/*
 *  Copyright (c) 2021 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "ShareExtensionContactCell.h"

#import <Twinme/TLTwinmeAttributes.h>

#import <UIKit/UIKit.h>
#import "UIColor+Hex.h"

#import "DesignExtension.h"

static CGFloat DESIGN_SEPARATOR_HEIGHT = 0.5;
static CGFloat DESIGN_CERTIFIED_HEIGHT = 28;
static CGFloat DESIGN_NAME_TRAILING = 38;

//
// Interface: ShareExtensionContactCell ()
//

@interface ShareExtensionContactCell ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *avatarViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *avatarViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *avatarView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *certifiedRelationImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *certifiedRelationImageViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *certifiedRelationImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separatorViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separatorViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separatorViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *separatorView;

@end

//
// Implementation: ShareContactCell
//

#undef LOG_TAG
#define LOG_TAG @"ShareContactCell"

@implementation ShareExtensionContactCell

- (void)awakeFromNib {
    
    [super awakeFromNib];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.contentView.backgroundColor = DesignExtension.WHITE_COLOR;
    
    self.avatarViewHeightConstraint.constant *= DesignExtension.HEIGHT_RATIO;
    self.avatarViewLeadingConstraint.constant *= DesignExtension.WIDTH_RATIO;
    
    CALayer *avatarViewLayer = self.avatarView.layer;
    avatarViewLayer.cornerRadius = self.avatarViewHeightConstraint.constant * 0.5;
    avatarViewLayer.masksToBounds = YES;
    
    self.nameLabelLeadingConstraint.constant *= DesignExtension.WIDTH_RATIO;
    self.nameLabelTrailingConstraint.constant *= DesignExtension.WIDTH_RATIO;
    self.nameLabel.font = DesignExtension.FONT_REGULAR34;
    self.nameLabel.textColor = DesignExtension.FONT_COLOR_DEFAULT;
    
    self.certifiedRelationImageViewHeightConstraint.constant = DESIGN_CERTIFIED_HEIGHT * DesignExtension.HEIGHT_RATIO;
    self.certifiedRelationImageViewLeadingConstraint.constant *= DesignExtension.WIDTH_RATIO;
    
    self.separatorViewLeadingConstraint.constant *= DesignExtension.WIDTH_RATIO;
    self.separatorViewBottomConstraint.constant = DESIGN_SEPARATOR_HEIGHT;
    self.separatorViewHeightConstraint.constant = DESIGN_SEPARATOR_HEIGHT;
    
    self.separatorView.backgroundColor = [UIColor colorWithRed:199./255. green:199./255. blue:255./255. alpha:0.3];
}

- (void)prepareForReuse {
    
    [super prepareForReuse];
    
    self.avatarView.image = nil;
    self.nameLabel.text = nil;
}

- (void)bindWithName:(NSString *)name avatar:(UIImage *)avatar isCertified:(BOOL)isCertified hideSeparator:(BOOL)hideSeparator {
    
    if ([avatar isEqual:[TLTwinmeAttributes DEFAULT_GROUP_AVATAR]]) {
        self.avatarView.backgroundColor = DesignExtension.MAIN_COLOR;
        self.avatarView.tintColor = [UIColor whiteColor];
    } else {
        self.avatarView.backgroundColor = [UIColor clearColor];
        self.avatarView.tintColor = [UIColor clearColor];
    }
    
    self.avatarView.image = avatar;
    
    self.nameLabel.text = name;
    
    self.certifiedRelationImageView.hidden = !isCertified;
    
    if (isCertified) {
        self.nameLabelTrailingConstraint.constant = (DESIGN_NAME_TRAILING * DesignExtension.WIDTH_RATIO * 2) + self.certifiedRelationImageViewHeightConstraint.constant + self.certifiedRelationImageViewLeadingConstraint.constant;
    } else {
        self.nameLabelTrailingConstraint.constant = DESIGN_NAME_TRAILING * DesignExtension.WIDTH_RATIO;
    }
    
    self.separatorView.hidden = hideSeparator;
}

@end

