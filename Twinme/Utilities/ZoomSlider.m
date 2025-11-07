/*
 *  Copyright (c) 2019 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "ZoomSlider.h"

#import <TwinmeCommon/Design.h>

#define THUMB_BORDER 2

//
// Interface: ZoomSlider
//

@interface ZoomSlider ()

@property(nonatomic) UIView *thumbView;

@property UIColor *sliderColor;
@property BOOL canMove;

@end

//
// Implementation: ZoomSlider
//

@implementation ZoomSlider

- (void)initializeSlider:(CGRect)rectThumb {
    
    self.sliderColor = [UIColor whiteColor];
    
    if (!self.thumbView) {
        self.thumbView = [[UIView alloc]init];
        self.thumbView.frame = rectThumb;
        self.thumbView.backgroundColor = [UIColor clearColor];
        self.thumbView.userInteractionEnabled = YES;
        self.thumbView.clipsToBounds = NO;
        self.thumbView.layer.cornerRadius = rectThumb.size.width / 2.0;
        self.thumbView.layer.borderColor = self.sliderColor.CGColor;
        self.thumbView.layer.borderWidth = THUMB_BORDER;
        [self addSubview:self.thumbView];
        [self setNeedsDisplay];
    }
}

- (void)setZoom:(CGFloat)zoom withSliderHeight:(CGFloat)height {
    
    CGFloat thumbY = (1.0 - zoom) * (height - self.thumbView.frame.size.height);
    self.thumbView.frame = CGRectMake(0, thumbY, self.thumbView.frame.size.width,  self.thumbView.frame.size.width);
    [self setNeedsDisplay];
}

#pragma mark - Touch Methods

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    [super touchesBegan:touches withEvent:event];
    
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
    
    self.canMove = CGRectContainsPoint(self.thumbView.frame, touchPoint);
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [super touchesMoved:touches withEvent:event];
    
    if (self.canMove) {
        UITouch *touch = [touches anyObject];
        CGPoint fromLocation = [touch previousLocationInView:self];
        CGPoint toLocation = [touch locationInView:self];
        CGPoint changeLocation = CGPointMake(toLocation.x - fromLocation.x, toLocation.y - fromLocation.y);
        
        float newThumbY = self.thumbView.frame.origin.y + changeLocation.y;
        if (newThumbY < 0) {
            newThumbY = 0;
        } else if (newThumbY >= (self.frame.size.height - self.thumbView.frame.size.height)) {
            newThumbY = self.frame.size.height - self.thumbView.frame.size.height;
        }
        
        self.thumbView.frame = CGRectMake(0, newThumbY, self.thumbView.frame.size.width, self.thumbView.frame.size.width);
        [self setNeedsDisplay];
        
        CGFloat zoom = 1.0 - (self.thumbView.frame.origin.y / (self.frame.size.height - self.thumbView.frame.size.height));
        [self.delegate updateZoom:zoom];
    }
}

- (void)updateColor:(UIColor *)color {
    
    self.sliderColor = color;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    
    [super drawRect:rect];
    
    if (self.thumbView) {
        self.thumbView.layer.borderColor = self.sliderColor.CGColor;
        
        CGPoint startTopLine = CGPointMake(self.center.x, 0);
        CGPoint endTopLine = CGPointMake(self.center.x, self.thumbView.frame.origin.y);
        
        UIBezierPath *topLine = [UIBezierPath bezierPath];
        [topLine moveToPoint:startTopLine];
        [topLine addLineToPoint:endTopLine];
        [topLine setLineWidth:2.0f];
        [self.sliderColor setStroke];
        [topLine stroke];
        
        CGPoint startBottomLine = CGPointMake(self.center.x,  self.thumbView.frame.origin.y +  self.thumbView.frame.size.height);
        CGPoint endBottomLine = CGPointMake(self.center.x, self.frame.size.height);
        
        UIBezierPath *bottomLine = [UIBezierPath bezierPath];
        [bottomLine moveToPoint:startBottomLine];
        [bottomLine addLineToPoint:endBottomLine];
        [bottomLine setLineWidth:2.0f];
        [self.sliderColor setStroke];
        [bottomLine stroke];
    }
}

@end
