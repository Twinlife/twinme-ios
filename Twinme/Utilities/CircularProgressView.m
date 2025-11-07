/*
 *  Copyright (c) 2016-2020 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Marouane Qasmi (Marouane.Qasmi@twinlife-systems.com)
 *   Chedi Baccari (Chedi.Baccari@twinlife-systems.com)
 *   Christian Jacquemot (Christian.Jacquemot@twinlife-systems.com)
 *   Stephane Carrez (Stephane.Carrez@twin.life)
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "CircularProgressView.h"

#import <TwinmeCommon/Design.h>

static CGFloat DESIGN_ANIMATED_CIRCLE_RADIUS_RATIO = 237. / 323.;
static CGFloat DESIGN_ANIMATED_CIRCLE_STROKE_WIDTH_RATIO = 14. / 323.;
static UIColor *DESIGN_ANIMATED_CIRCLE_COLOR1;
static UIColor *DESIGN_ANIMATED_CIRCLE_COLOR2;
static CGFloat DESIGN_ANIMATED_CIRCLE_SPEED1 = 12 * 60;  // revolution per hour
static CGFloat DESIGN_ANIMATED_CIRCLE_SPEED2 = 15; // revolution per hour

//
// Interface: CircularProgressView ()
//

@interface CircularProgressView ()

@property CGFloat animatedCircleRadius;
@property CGFloat animatedCircleStokeWidth;
@property UIColor *animatedCircleColor1;
@property UIColor *animatedCircleColor2;
@property CGFloat angle1;
@property CGFloat angle2;
@property NSTimer* timer;

@end

//
// Implementation: CircularProgressView
//

@implementation CircularProgressView

+ (void)initialize {
    
    DESIGN_ANIMATED_CIRCLE_COLOR1 = [UIColor colorWithRed:134./255. green:244./255. blue:183./255. alpha:1.0];
    DESIGN_ANIMATED_CIRCLE_COLOR2 = [UIColor clearColor];
}

- (void)initializeWithRadius:(float)radius {
    
    self.animatedCircleRadius = radius * DESIGN_ANIMATED_CIRCLE_RADIUS_RATIO;
    self.animatedCircleStokeWidth = radius * DESIGN_ANIMATED_CIRCLE_STROKE_WIDTH_RATIO;
    self.animatedCircleColor1 = DESIGN_ANIMATED_CIRCLE_COLOR1;
    self.animatedCircleColor2 = DESIGN_ANIMATED_CIRCLE_COLOR2;
    self.angle1 = - M_PI / 2;
    self.angle2 = - M_PI / 2;
    [self setNeedsDisplay];
}

- (void)startAnimation {
    
    if (!self.timer) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1./30. target:self selector:@selector(timerFire) userInfo:nil repeats:YES];
    }
    [self setNeedsDisplay];
}

- (void)stopAnimation {
    
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)drawRect:(CGRect)rect {
    
    CGPoint center = CGPointMake(rect.size.width / 2, rect.size.height / 2);
    
    UIBezierPath* animatedCircle1 = [UIBezierPath bezierPath];
    [animatedCircle1 addArcWithCenter:center radius:self.animatedCircleRadius startAngle:self.angle2 endAngle:self.angle1 clockwise:YES];
    animatedCircle1.lineWidth = self.animatedCircleStokeWidth;
    [self.animatedCircleColor1 setStroke];
    [animatedCircle1 stroke];
    
    UIBezierPath* animatedCircle2 = [UIBezierPath bezierPath];
    [animatedCircle2 addArcWithCenter:center radius:self.animatedCircleRadius startAngle:self.angle1 endAngle:(self.angle2 == self.angle1 ? 2 * M_PI : self.angle2) clockwise:YES];
    animatedCircle2.lineWidth = self.animatedCircleStokeWidth;
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
