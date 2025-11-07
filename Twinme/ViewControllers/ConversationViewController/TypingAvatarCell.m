/*
 *  Copyright (c) 2019 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "TypingAvatarCell.h"

#import <TwinmeCommon/Design.h>

#import "RoundedShadowView.h"

//
// Interface: TypingAvatarCell ()
//

@interface TypingAvatarCell ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *avatarViewContainerHeightConstraint;
@property (weak, nonatomic) IBOutlet RoundedShadowView *avatarViewContainer;
@property (weak, nonatomic) IBOutlet UIImageView *avatarView;

@end

//
// Implementation: TypingAvatarCell
//

#undef LOG_TAG
#define LOG_TAG @"TypingAvatarCell"

@implementation TypingAvatarCell

- (void)awakeFromNib {
    
    [super awakeFromNib];
    
    self.avatarViewContainerHeightConstraint.constant *= Design.HEIGHT_RATIO;
    float avatarViewShadowRadius = 5 * Design.HEIGHT_RATIO;
    [self.avatarViewContainer setShadowWithColor:Design.SHADOW_COLOR_DEFAULT shadowRadius:avatarViewShadowRadius shadowOffset:CGSizeMake(0, avatarViewShadowRadius) shadowOpacity:0.4];
    
    CALayer *avatarViewLayer = self.avatarView.layer;
    avatarViewLayer.cornerRadius = self.avatarViewContainerHeightConstraint.constant * 0.5;
    avatarViewLayer.masksToBounds = YES;
}

- (void)prepareForReuse {
    
    [super prepareForReuse];
    
    self.avatarViewContainer.hidden = YES;
    self.avatarView.image = nil;
}

- (void)bindWithAvatar:(UIImage *)avatar {
    
    self.avatarViewContainer.hidden = NO;
    self.avatarView.image = avatar;
}

@end

