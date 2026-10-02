/*
 *  Copyright (c) 2026 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <UIKit/UIKit.h>

#import "ShareExtensionSelectedCell.h"

#import "DesignExtension.h"

//
// Interface: ShareExtensionSelectedCell ()
//

@interface ShareExtensionSelectedCell ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *avatarViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *avatarView;

@end

//
// Implementation: ShareExtensionSelectedCell
//

#undef LOG_TAG
#define LOG_TAG @"ShareExtensionSelectedCell"

@implementation ShareExtensionSelectedCell

- (void)awakeFromNib {
    
    [super awakeFromNib];
        
    self.avatarViewHeightConstraint.constant *= DesignExtension.HEIGHT_RATIO;
    
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
}

@end

