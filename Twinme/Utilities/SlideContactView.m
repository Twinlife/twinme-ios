/*
 *  Copyright (c) 2019-2021 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "SlideContactView.h"

#import <TwinmeCommon/Design.h>

static CGFloat DESIGN_TOP_MARGIN = 88.0;
static CGFloat TOP_MARGIN;

//
// Interface: SlideContactView ()
//

@interface SlideContactView ()

@property(nonatomic) double initialPosition;

@property(nonatomic) CGFloat topMargin;
@property(nonatomic) CAShapeLayer *maskLayer;

@end

//
// Implementation: SlideContactView ()
//

@implementation SlideContactView

+ (void)initialize {
    
    TOP_MARGIN = DESIGN_TOP_MARGIN * Design.HEIGHT_RATIO;
}

- (void)setSlideContactTopMargin:(CGFloat)topMargin {
    
    self.topMargin = topMargin;
}

- (void)setMinPosition:(CGFloat)position {
    
    self.initialPosition = position;
}

#pragma mark - Touch Methods

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [super touchesMoved:touches withEvent:event];
    
    if (!self.canMove) {
        return;
    }
    
    if (!self.initialPosition) {
        self.initialPosition = self.frame.origin.y;
    }
    
    if (!self.topMargin) {
        self.topMargin = TOP_MARGIN;
    }
    
    UITouch *touch = [touches anyObject];
    CGPoint fromLocation = [touch previousLocationInView:self];
    CGPoint toLocation = [touch locationInView:self];
    CGPoint changeLocation = CGPointMake(toLocation.x - fromLocation.x, toLocation.y - fromLocation.y);
    
    CGFloat newLocation = self.center.y + changeLocation.y;
    
    if ((newLocation - (self.bounds.size.height / 2.0) >= self.topMargin)
        && (newLocation - (self.bounds.size.height / 2.0) <= self.initialPosition)) {
        super.center = CGPointMake(self.center.x, self.center.y + changeLocation.y);
    }
    
    [self.slideContactViewDelegate didMoveView:self];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [super touchesEnded:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [super touchesCancelled:touches withEvent:event];
}

- (void)drawRect:(CGRect)rect {
    
    [super drawRect:rect];
    
    if (self.maskLayer) {
        [self.maskLayer removeFromSuperlayer];
        self.maskLayer = nil;
    }
    
    CGRect maskFrame = self.bounds;
    maskFrame.size.height += Design.DISPLAY_HEIGHT;
    
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:maskFrame byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight) cornerRadii:CGSizeMake(40, 40)];
    self.maskLayer = [CAShapeLayer layer];
    self.maskLayer.frame = maskFrame;
    self.maskLayer.fillColor = Design.WHITE_COLOR.CGColor;
    self.maskLayer.path = maskPath.CGPath;
    [self.layer insertSublayer:self.maskLayer atIndex:0];
}

@end
