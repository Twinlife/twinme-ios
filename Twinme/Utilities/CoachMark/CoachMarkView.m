/*
 *  Copyright (c) 2022 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "CoachMarkView.h"

#import <TwinmeCommon/Design.h>

//
// Interface: CoachMarkView ()
//

@interface CoachMarkView ()

@property CGRect clipRect;
@property CGFloat radius;

@property BOOL isViewClipped;

@end

//
// Implementation: CoachMarkView ()
//

@implementation CoachMarkView

- (void)clipView:(CGRect)frame radius:(CGFloat)radius {
    
    self.clipRect = frame;
    self.radius = radius;
    
    [self setNeedsLayout];
}

- (void)drawRect:(CGRect)rect {
    
    [super drawRect:rect];
        
    if (!self.isViewClipped && self.clipRect.size.width != 0) {
        self.isViewClipped = YES;
        
        UIView *backgroundView = [[UIView alloc]initWithFrame:self.frame];
        backgroundView.backgroundColor = Design.OVERLAY_COLOR;
        [self addSubview:backgroundView];
        
        CALayer *maskLayer = [CALayer layer];
        maskLayer.frame = backgroundView.bounds;
        
        CAShapeLayer *clippedLayer = [CAShapeLayer layer];
        UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRect:backgroundView.frame];
        UIBezierPath *clippedPath;
        if (self.radius == 0) {
            clippedPath = [UIBezierPath bezierPathWithRect:self.clipRect];
        } else {
            clippedPath = [UIBezierPath bezierPathWithRoundedRect:self.clipRect cornerRadius:self.radius];
        }
        
        [bezierPath appendPath:[clippedPath bezierPathByReversingPath]];
        clippedLayer.path = bezierPath.CGPath;
        [maskLayer addSublayer:clippedLayer];
        
        backgroundView.layer.mask = maskLayer;
    }
}

@end
