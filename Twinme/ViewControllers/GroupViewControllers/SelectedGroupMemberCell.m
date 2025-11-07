/*
 *  Copyright (c) 2018-2020 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "SelectedGroupMemberCell.h"

#import <TwinmeCommon/Design.h>

//
// Interface: SelectedGroupMemberCell ()
//

@interface SelectedGroupMemberCell ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *avatarViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *avatarView;

@end

//
// Implementation: SelectedGroupMemberCell
//

#undef LOG_TAG
#define LOG_TAG @"SelectedGroupMemberCell"

@implementation SelectedGroupMemberCell

- (void)awakeFromNib {
    
    [super awakeFromNib];
    
    self.contentView.backgroundColor = Design.WHITE_COLOR;
    
    self.avatarViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    CALayer *avatarViewLayer = self.avatarView.layer;
    avatarViewLayer.cornerRadius = self.avatarViewHeightConstraint.constant * 0.5;
    avatarViewLayer.masksToBounds = YES;
}

- (void)prepareForReuse {
    
    [super prepareForReuse];
    
    self.avatarView.hidden = YES;
    self.avatarView.image = nil;
}

- (void)bindWithAvatar:(UIImage *)avatar {
    
    self.avatarView.hidden = NO;
    self.avatarView.image = avatar;
    
    self.contentView.backgroundColor = Design.WHITE_COLOR;
}

@end

