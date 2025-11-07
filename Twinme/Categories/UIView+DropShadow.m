/*
 *  Copyright (c) 2017 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Thibaud David (contact@thibauddavid.com)
 */

#import "UIView+DropShadow.h"

//
// Implementation:UIView (DropShadow)
//

@implementation UIView (DropShadow)

- (void)addDropShadowWithColor:(UIColor *)color shadowRadius:(CGFloat)shadowRadius shadowOffset:(CGSize)shadowOffset {
    
    [self addDropShadowWithColor:color shadowRadius:shadowRadius shadowOffset:shadowOffset opacity:1];
}

- (void)addDropShadowWithColor:(UIColor *)color shadowRadius:(CGFloat)shadowRadius shadowOffset:(CGSize)shadowOffset opacity:(CGFloat)opacity {
    
    self.layer.shadowColor = color.CGColor;
    self.layer.shadowRadius = shadowRadius;
    self.layer.shadowOffset = shadowOffset;
    self.layer.shadowOpacity = opacity;
    self.clipsToBounds = NO;
    self.layer.masksToBounds = NO;
}

- (void)updateRoundedShadowPath {
    
    self.layer.shouldRasterize = NO;
    self.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:self.bounds.size.height * 0.5].CGPath;
    self.layer.shouldRasterize = YES;
    self.layer.rasterizationScale = [UIScreen mainScreen].scale;
}

- (void)updateShadowPath {
    
    self.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.bounds].CGPath;
}

@end
