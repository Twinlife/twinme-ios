/*
 *  Copyright (c) 2018-2020 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import "GroupMemberSectionHeaderCell.h"

#import <TwinmeCommon/Design.h>

//
// Interface: GroupMemberSectionHeaderCell ()
//

@interface GroupMemberSectionHeaderCell ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLabelTrailingConstraint;

@end

//
// Implementation: GroupMemberSectionHeaderCell
//

#undef LOG_TAG
#define LOG_TAG @"GroupMemberSectionHeaderCell"

@implementation GroupMemberSectionHeaderCell

- (void)awakeFromNib {
    
    [super awakeFromNib];
    
    self.contentView.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
    
    self.titleLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.titleLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.titleLabel.font = Design.FONT_BOLD28;
    self.titleLabel.textColor = Design.FONT_COLOR_DEFAULT;
}

@end
