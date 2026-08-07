/*
 *  Copyright (c) 2026 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <Utils/NSString+Utils.h>

#import "ShareContactCell.h"

#import <TwinmeCommon/Design.h>

//
// Interface: ShareContactCell ()
//

@interface ShareContactCell ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *avatarViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *avatarViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *avatarView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@end

//
// Implementation: ShareContactCell
//

#undef LOG_TAG
#define LOG_TAG @"ShareContactCell"

@implementation ShareContactCell

- (void)awakeFromNib {
    
    [super awakeFromNib];
    
    self.backgroundColor = Design.WHITE_COLOR;
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.avatarViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.avatarViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.avatarView.clipsToBounds = YES;
    self.avatarView.layer.cornerRadius = self.avatarViewHeightConstraint.constant * 0.5f;
        
    self.nameLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.nameLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;

    self.nameLabel.font = Design.FONT_MEDIUM32;
    self.nameLabel.textColor = Design.FONT_COLOR_DEFAULT;
}

- (void)prepareForReuse {
    
    [super prepareForReuse];
}

- (void)bindWithName:(NSString *)name avatar:(UIImage *)avatar {
    
    self.avatarView.image = avatar;
    
    NSString *title = [NSString stringWithFormat:TwinmeLocalizedString(@"share_contact_view_share_title", nil), name];
    NSString *message = [NSString stringWithFormat:TwinmeLocalizedString(@"share_contact_view_share_info", nil), name];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@""];
    [attributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:title attributes:[NSDictionary dictionaryWithObjectsAndKeys:Design.FONT_MEDIUM32, NSFontAttributeName, Design.FONT_COLOR_DEFAULT, NSForegroundColorAttributeName, nil]]];
    [attributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:@"\n"]];
    [attributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:message attributes:[NSDictionary dictionaryWithObjectsAndKeys:Design.FONT_MEDIUM28, NSFontAttributeName, Design.FONT_COLOR_GREY, NSForegroundColorAttributeName, nil]]];
    
    self.nameLabel.attributedText = attributedString;

    [self updateColor];
}

- (void)updateColor {
    
    self.backgroundColor = Design.WHITE_COLOR;
}
@end

