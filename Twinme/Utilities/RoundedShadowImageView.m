/*
 *  Copyright (c) 2017 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Christian Jacquemot (Christian.Jacquemot@twinlife-systems.com)
 */

#import "RoundedShadowImageView.h"

//
// Implementation: RoundedShadowImageView
//

@implementation RoundedShadowImageView

- (void)setShadowWithColor:(UIColor *)color shadowRadius:(CGFloat)shadowRadius shadowOffset:(CGSize)shadowOffset shadowOpacity:(CGFloat)shadowOpacity {
    
    self.layer.shadowColor = color.CGColor;
    self.layer.shadowRadius = shadowRadius;
    self.layer.shadowOffset = shadowOffset;
    self.layer.shadowOpacity = shadowOpacity;
    self.clipsToBounds = NO;
    self.layer.masksToBounds = NO;
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    self.layer.shouldRasterize = NO;
    self.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:self.bounds.size.height * 0.5].CGPath;
    self.layer.shouldRasterize = YES;
    self.layer.rasterizationScale = [UIScreen mainScreen].scale;
}

@end
