/*
 *  Copyright (c) 2019-2020 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <Utils/NSString+Utils.h>

#import "AddGroupCell.h"

#import <TwinmeCommon/Design.h>

//
// Interface: AddGroupCell ()
//

@interface AddGroupCell ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *addGroupViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *addGroupViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet UIView *addGroupView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *addGroupViewImageHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@end

//
// Implementation: AddGroupCell
//

#undef LOG_TAG
#define LOG_TAG @"AddGroupCell"

@implementation AddGroupCell

- (void)awakeFromNib {
    
    [super awakeFromNib];
    
    self.backgroundColor = Design.WHITE_COLOR;
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.addGroupViewHeightConstraint.constant = Design.AVATAR_HEIGHT;
    self.addGroupViewLeadingConstraint.constant = Design.AVATAR_LEADING;
    
    self.addGroupViewImageHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.nameLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.nameLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.nameLabel.font = Design.FONT_REGULAR34;
    self.nameLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.nameLabel.text = TwinmeLocalizedString(@"main_view_controller_add_group", nil);
}

- (void)prepareForReuse {
    
    [super prepareForReuse];
}

- (void)bind {
    
    [self updateFont];
    [self updateColor];
}

- (void)updateFont {
    
    self.nameLabel.font = Design.FONT_REGULAR34;
}

- (void)updateColor {
    
    self.backgroundColor = Design.WHITE_COLOR;
    self.nameLabel.textColor = Design.FONT_COLOR_DEFAULT;
}
@end

