/*
 *  Copyright (c) 2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <Utils/NSString+Utils.h>

#import "AddInvitationCodeCell.h"

#import <TwinmeCommon/Design.h>

//
// Interface: AddInvitationCodeCell ()
//

@interface AddInvitationCodeCell ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *addRoundedViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *addRoundedViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *addRoundedView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *addImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *addImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameLabelBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameLabelHeightConstraint;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separatorViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *separatorView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *accessoryImageViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *accessoryImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *accessoryImageView;

@end

//
// Implementation: AddInvitationCodeCell
//

#undef LOG_TAG
#define LOG_TAG @"AddInvitationCodeCell"

@implementation AddInvitationCodeCell

- (void)awakeFromNib {
    
    [super awakeFromNib];
    
    self.backgroundColor = Design.WHITE_COLOR;
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.addRoundedViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.addRoundedViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.addRoundedView.backgroundColor = Design.MAIN_COLOR;
    self.addRoundedView.layer.cornerRadius = self.addRoundedViewHeightConstraint.constant * 0.5f;
    
    self.addImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.addImageView.image = [self.addImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.addImageView setTintColor:[UIColor whiteColor]];
    
    self.nameLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.nameLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.nameLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.nameLabelBottomConstraint.constant *= Design.HEIGHT_RATIO;
    self.nameLabelHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.nameLabel.font = Design.FONT_MEDIUM32;
    self.nameLabel.textColor = Design.FONT_COLOR_DEFAULT;
    
    self.separatorViewHeightConstraint.constant = Design.SEPARATOR_HEIGHT;
    self.separatorView.backgroundColor = Design.SEPARATOR_COLOR_GREY;
    
    self.accessoryImageViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.accessoryImageViewHeightConstraint.constant = Design.ACCESSORY_HEIGHT;
    self.accessoryImageView.tintColor = Design.ACCESSORY_COLOR;
}

- (void)prepareForReuse {
    
    [super prepareForReuse];
}

- (void)bindWithTitle:(NSString *)title subTitle:(NSString *)subTitle {
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@""];
    [attributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:title attributes:[NSDictionary dictionaryWithObjectsAndKeys:Design.FONT_MEDIUM32, NSFontAttributeName, Design.FONT_COLOR_DEFAULT, NSForegroundColorAttributeName, nil]]];
    [attributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:@"\n"]];
    [attributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:subTitle attributes:[NSDictionary dictionaryWithObjectsAndKeys:Design.FONT_MEDIUM28, NSFontAttributeName, Design.FONT_COLOR_GREY, NSForegroundColorAttributeName, nil]]];
    
    self.nameLabel.attributedText = attributedString;
    
    [self updateColor];
}

- (void)updateColor {
    
    self.backgroundColor = Design.WHITE_COLOR;
    self.accessoryImageView.tintColor = Design.ACCESSORY_COLOR;
}
@end

