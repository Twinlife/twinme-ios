/*
 *  Copyright (c) 2017 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Chedi Baccari (Chedi.Baccari@twinlife-systems.com)
 *   Christian Jacquemot (Christian.Jacquemot@twinlife-systems.com)
 */

#import "SoundWaveView.h"

#import <TwinmeCommon/Design.h>

static const int LINES_COUNT = 100;

//
// Interface: SoundWaveView ()
//

@interface SoundWaveView ()

@property NSTimer* timer;

@end

//
// Implementation: SoundWaveView ()
//

@implementation SoundWaveView

- (void)startAnimation {
    
    self.hidden = NO;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(timerFire) userInfo:nil repeats:YES];
    [self setNeedsDisplay];
}

- (void)stopAnimation {
    
    self.hidden = YES;
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)timerFire {
    
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    
    CABasicAnimation *animation;
    animation = [CABasicAnimation animation];
    [animation setDuration:0.3];
    [[self layer] addAnimation:animation forKey:@"contents"];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:229./255. green:227./255. blue:225./255. alpha:1].CGColor);
    CGContextSetLineWidth(context, 4 * Design.WIDTH_RATIO);
    CGFloat x = self.bounds.origin.x;
    CGFloat y = self.bounds.origin.y + self.bounds.size.height / 2;
    CGFloat deltaX = self.bounds.size.width / LINES_COUNT;
    CGFloat min = 2;
    for (int i = 0; i < LINES_COUNT; i++) {
        x += deltaX;
        CGFloat max = self.bounds.size.height;
        if (i < LINES_COUNT / 2) {
            max = max / (self.bounds.size.width / 2) * (x - self.bounds.size.width / 2) + max;
        } else {
            max = max / (self.bounds.size.width / 2) * (self.bounds.size.width / 2 - x) + max;
        }
        CGFloat deltaY = min + (rand() * (max - min) / RAND_MAX);
        CGContextMoveToPoint(context, x, y - deltaY / 2);
        CGContextAddLineToPoint(context, x, y + deltaY / 2);
        CGContextStrokePath(context);
    }
}


@end
