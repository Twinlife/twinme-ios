/*
 *  Copyright (c) 2019-2020 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "RoundRectProgressView.h"

#import <TwinmeCommon/Design.h>

static UIColor *DESIGN_ANIMATED_CIRCLE_COLOR1;
static UIColor *DESIGN_ANIMATED_CIRCLE_COLOR2;

static CGFloat DESIGN_ANIMATED_CIRCLE_SPEED1 = 12 * 60;  // revolution per hour
static CGFloat DESIGN_ANIMATED_CIRCLE_SPEED2 = 60; // revolution per hour

//
// Interface: RoundRectProgressView ()
//

@interface RoundRectProgressView ()

@property UIColor *animatedCircleColor1;
@property UIColor *animatedCircleColor2;
@property CGFloat angle1;
@property CGFloat angle2;
@property NSTimer *timer;

@end

//
// Implementation: RoundRectProgressView
//

@implementation RoundRectProgressView

+ (void)initialize {
    
    DESIGN_ANIMATED_CIRCLE_COLOR1 = [UIColor colorWithRed:134./255. green:244./255. blue:183./255. alpha:1.0];
    DESIGN_ANIMATED_CIRCLE_COLOR2 = [UIColor whiteColor];
}

- (void)startAnimation {
    
    if (self.timer) {
        return;
    }

    self.animatedCircleColor1 = DESIGN_ANIMATED_CIRCLE_COLOR1;
    self.animatedCircleColor2 = DESIGN_ANIMATED_CIRCLE_COLOR2;
    self.angle1 = - M_PI / 2;
    self.angle2 = - M_PI / 2;
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1./30. target:self selector:@selector(timerFire) userInfo:nil repeats:YES];
}

- (void)stopAnimation {
    
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)drawRect:(CGRect)rect {
    
    CGPoint center =  CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
    CGFloat radius = (sqrt((center.x * center.x) + (center.y * center.y)));
    
    UIBezierPath *animatedCircle1 = [UIBezierPath bezierPath];
    [animatedCircle1 addArcWithCenter:center radius:radius startAngle:self.angle2 endAngle:self.angle1 clockwise:NO];
    [animatedCircle1 setLineWidth:radius];
    [self.animatedCircleColor1 setStroke];
    [animatedCircle1 stroke];
    
    UIBezierPath *animatedCircle2 = [UIBezierPath bezierPath];
    [animatedCircle2 addArcWithCenter:center radius:radius startAngle:self.angle1 endAngle:(self.angle2 == self.angle1 ? 2. * M_PI : self.angle2) clockwise:NO];
    [animatedCircle2 setLineWidth:radius];
    [self.animatedCircleColor2 setStroke];
    [animatedCircle2 stroke];
}

- (void)timerFire {
    
    CGFloat angle1 = self.angle1;
    self.angle1 += 2. * M_PI * DESIGN_ANIMATED_CIRCLE_SPEED1 / 3600. / 30.;
    CGFloat angle2 = self.angle2;
    self.angle2 += 2. * M_PI * DESIGN_ANIMATED_CIRCLE_SPEED2 / 3600. / 30.;
    BOOL swap = NO;
    if (angle1 >= angle2) {
        if (self.angle1 < self.angle2) {
            swap = YES;
        }
    } else {
        if (self.angle1 > self.angle2) {
            swap = YES;
        }
    }
    if (swap) {
        UIColor *color = self.animatedCircleColor1;
        self.animatedCircleColor1 = self.animatedCircleColor2;
        self.animatedCircleColor2 = color;
    }
    if (self.angle1 > M_PI) {
        self.angle1 -= 2. * M_PI;
    }
    if (self.angle2 > M_PI) {
        self.angle2 -= 2. * M_PI;
    }
    
    [self setNeedsDisplay];
}

@end
