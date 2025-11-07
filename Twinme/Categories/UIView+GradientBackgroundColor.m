/*
 *  Copyright (c) 2017-2024 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Thibaud David (contact@thibauddavid.com)
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <objc/runtime.h>

#import "UIView+GradientBackgroundColor.h"

static char const * const addGradientTagKey = "AddGradientBackground";

@interface UIView ()

@property(readwrite) BOOL addGradient;

@end

@implementation UIView (GradientBackgroundColor)

- (void)setAddGradient:(BOOL)addGradient {
    
    NSNumber *boolValue = [NSNumber numberWithBool:addGradient];
    objc_setAssociatedObject(self, addGradientTagKey, boolValue, OBJC_ASSOCIATION_RETAIN);
}

- (BOOL)addGradient {
    
    NSNumber *addGradientObject = objc_getAssociatedObject(self, addGradientTagKey);
    if (!addGradientObject) {
        return NO;
    }
    return [addGradientObject boolValue];
}

- (void)setupGradientBackgroundFromColors:(NSArray *)colors {
    
    [self setupGradientBackgroundFromColors:colors opacity:1 orientation:GradientOrientationVertical];
}

- (void)setupGradientBackgroundFromColors:(NSArray *)colors opacity:(CGFloat)opacity orientation:(GradientOrientation)gradientOrientation {
    
    if (![self addGradient]) {
        [self setAddGradient:YES];
        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.frame = self.bounds;
        gradient.colors = colors;
        if (gradientOrientation == GradientOrientationHorizontal) {
            gradient.startPoint = CGPointMake(0.0, 0.5);
            gradient.endPoint = CGPointMake(1.0, 0.5);
        } else if (gradientOrientation == GradientOrientationDiagonal) {
            gradient.startPoint = CGPointMake(0.0, 0.0);
            gradient.endPoint = CGPointMake(1.0, 1.0);
        }
        gradient.opacity = opacity;
        self.clipsToBounds = YES;
        self.layer.masksToBounds = YES;
        
        [self.layer insertSublayer:gradient atIndex:0];
    }
    
}

- (void)updateGradientBounds {
    
    self.layer.sublayers.firstObject.frame = self.bounds;
    self.layer.sublayers.firstObject.cornerRadius = self.layer.cornerRadius;
}

- (void)updateGradientColors:(NSArray<UIColor *> *)colors {
    
    NSMutableArray *cgColors = [NSMutableArray array];
    for (UIColor *color in colors) {
        [cgColors addObject:(id)color.CGColor];
    }
    CALayer *gradientLayer = self.layer.sublayers.firstObject;
    if ([gradientLayer isKindOfClass:[CAGradientLayer class]]) {
        ((CAGradientLayer *)gradientLayer).colors = cgColors;
    }
}

@end
