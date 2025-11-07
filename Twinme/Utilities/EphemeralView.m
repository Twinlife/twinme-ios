/*
 *  Copyright (c) 2021 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "EphemeralView.h"

static CGFloat DESIGN_LINE_WIDTH = 2;

//
// Interface: EphemeralView ()
//

@interface EphemeralView ()

@property(nonatomic) CAShapeLayer *backgroundCircle;
@property(nonatomic) CAShapeLayer *dashedCircle;
@property(nonatomic) CAShapeLayer *firstLine;
@property(nonatomic) CAShapeLayer *secondLine;

@end

//
// Interface: EphemeralView ()
//

@implementation EphemeralView

- (void)updateWithPercent:(CGFloat)percent color:(UIColor *)color size:(CGFloat)size {
    
    CGFloat degrees = 360.0 * percent;
    CGFloat radians = (degrees * M_PI) / 180.0;
    
    CGFloat startAngle = 3 * M_PI_2;
    CGFloat endAngle = startAngle + radians;
    
    if (self.backgroundCircle) {
        [self.backgroundCircle removeFromSuperlayer];
        self.backgroundCircle = nil;
    }
    
    self.backgroundCircle = [CAShapeLayer layer];
    
    self.backgroundCircle.path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(size * 0.5, size * 0.5) radius:size * 0.5 startAngle:startAngle endAngle:endAngle clockwise:YES].CGPath;
    
    self.backgroundCircle.fillColor = [UIColor clearColor].CGColor;
    self.backgroundCircle.strokeColor = color.CGColor;
    self.backgroundCircle.lineWidth = DESIGN_LINE_WIDTH;
    self.backgroundCircle.lineJoin = kCALineCapRound;
    [self.layer addSublayer:self.backgroundCircle];
    
    if (self.dashedCircle) {
        [self.dashedCircle removeFromSuperlayer];
        self.dashedCircle = nil;
    }
    
    self.dashedCircle = [CAShapeLayer layer];
    self.dashedCircle.path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, size, size) cornerRadius:size * 0.5].CGPath;
    
    self.dashedCircle.fillColor = [UIColor clearColor].CGColor;
    self.dashedCircle.strokeColor = color.CGColor;
    self.dashedCircle.lineWidth = DESIGN_LINE_WIDTH;
    self.dashedCircle.lineJoin = kCALineCapRound;
    self.dashedCircle.lineDashPattern = @[@4, @2];
    self.dashedCircle.lineDashPhase = 5;
    
    [self.layer addSublayer:self.dashedCircle];
    
    if (self.firstLine) {
        [self.firstLine removeFromSuperlayer];
        self.firstLine = nil;
    }
    
    self.firstLine = [CAShapeLayer layer];
    UIBezierPath *lineBezierPath = [UIBezierPath bezierPath];
    [lineBezierPath moveToPoint:CGPointMake(size * 0.5, size * 0.5)];
    [lineBezierPath addLineToPoint:CGPointMake(size * 0.5, 0)];
    self.firstLine.path = lineBezierPath.CGPath;
    self.firstLine.lineWidth = DESIGN_LINE_WIDTH;
    self.firstLine.lineJoin = kCALineCapRound;
    self.firstLine.lineCap = kCALineCapRound;
    self.firstLine.fillColor = [UIColor clearColor].CGColor;
    self.firstLine.strokeColor = color.CGColor;
    self.firstLine.lineDashPattern = @[@5, @5];
    self.firstLine.lineDashPhase = 0;
    [self.layer addSublayer:self.firstLine];
    
    if (self.secondLine) {
        [self.secondLine removeFromSuperlayer];
        self.secondLine = nil;
    }
    
    CGFloat endX = (size * 0.5) + ((size * 0.5) * cos(endAngle));
    CGFloat endY = (size * 0.5) + ((size * 0.5) * sin(endAngle));
    
    self.secondLine = [CAShapeLayer layer];
    UIBezierPath *secondLineBezierPath = [UIBezierPath bezierPath];
    [secondLineBezierPath moveToPoint:CGPointMake(size * 0.5, size * 0.5)];
    [secondLineBezierPath addLineToPoint:CGPointMake(endX, endY)];
    self.secondLine.path = secondLineBezierPath.CGPath;
    self.secondLine.lineWidth = DESIGN_LINE_WIDTH;
    self.secondLine.lineJoin = kCALineCapRound;
    self.secondLine.lineCap = kCALineCapRound;
    self.secondLine.fillColor = [UIColor clearColor].CGColor;
    self.secondLine.strokeColor = color.CGColor;
    self.secondLine.lineDashPattern = @[@5, @5];
    self.secondLine.lineDashPhase = 0;
    [self.layer addSublayer:self.secondLine];
    
    if (percent == 1.0) {
        self.secondLine.hidden = YES;
    }
}

- (void)drawRect:(CGRect)rect {
    
    self.layer.backgroundColor = [UIColor clearColor].CGColor;
}

@end
