/*
 *  Copyright (c) 2021-2022 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "AudioTrackView.h"

#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <Accelerate/Accelerate.h>

#import <TwinmeCommon/AudioTrack.h>
#import "ConversationViewController.h"

static CGFloat DESIGN_LINE_SPACE = 2;
static CGFloat DESIGN_LINE_WIDTH = 1;

//
// Interface: AudioTrackView
//

@interface AudioTrackView()

@property (nonatomic) UIView *trackView;
@property (nonatomic) UIView *progressView;

@property (nonatomic) NSData *trackData;
@property (nonatomic) UIColor *lineColor;
@property (nonatomic) UIColor *progressColor;

@end

//
// Implementation: AudioTrackView
//

@implementation AudioTrackView

#pragma mark - Touch method

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    [super touchesBegan:touches withEvent:event];
    
    self.isTouch = YES;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [super touchesMoved:touches withEvent:event];
    
    UITouch *touch = [touches anyObject];
    CGPoint toLocation = [touch locationInView:self];
    [self.progressView setFrame:CGRectMake(0, 0, toLocation.x, self.progressView.frame.size.height)];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [super touchesCancelled:touches withEvent:event];
    
    self.isTouch = NO;
    
    UITouch *touch = [touches anyObject];
    CGPoint toLocation = [touch locationInView:self];
    float progressWidth = toLocation.x / self.frame.size.width;
    [self.audioTrackViewDelegate audioTrackViewTouchEnd:progressWidth];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [super touchesEnded:touches withEvent:event];
    
    self.isTouch = NO;
    
    UITouch *touch = [touches anyObject];
    CGPoint toLocation = [touch locationInView:self];
    float progressWidth = toLocation.x / self.frame.size.width;
    [self.audioTrackViewDelegate audioTrackViewTouchEnd:progressWidth];
}

#pragma mark - public method

- (void)drawTrack:(nonnull AudioTrack *)audioTrack lineColor:(nonnull UIColor *)lineColor progressColor:(nonnull UIColor *)progressColor {
    
    self.isTouch = NO;
    self.lineColor = lineColor;
    self.progressColor = progressColor;
    
    self.trackData = audioTrack.trackData;
    [self setNeedsDisplay];
}

- (void)updateProgressView:(float)progress {
    
    if (!self.isTouch) {
        float progressWidth = self.frame.size.width * progress;
        [self.progressView setFrame:CGRectMake(0, 0, progressWidth, self.progressView.frame.size.height)];
    }
}

#pragma mark - private method

- (void)drawRect:(CGRect)rect {
    
    self.clipsToBounds = YES;
    
    if (self.trackData && self.trackData.bytes && self.trackData.length > 0) {
        if (self.trackView) {
            [self.trackView removeFromSuperview];
            self.trackView = nil;
        }
        
        if (self.progressView) {
            [self.progressView removeFromSuperview];
            self.progressView = nil;
        }
        
        self.trackView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        self.trackView.backgroundColor = [UIColor clearColor];
        self.trackView.userInteractionEnabled = YES;
        
        self.progressView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, self.frame.size.height)];
        self.progressView.clipsToBounds = YES;
        self.progressView.userInteractionEnabled = YES;
        self.progressView.backgroundColor = [UIColor clearColor];
        
        [self addSubview:self.trackView];
        [self addSubview:self.progressView];
        
        float *samples = (float *)self.trackData.bytes;
        NSInteger sampleCount = (self.trackData.length - sizeof(float)) / sizeof(float);
        float startX = 1;
        
        UIBezierPath *lineBezierPath = [UIBezierPath bezierPath];
        for (int sample = 0; sample < sampleCount; sample++) {
            float lineHeight = self.frame.size.height * samples[sample];
            float startY = (self.frame.size.height - fabs(lineHeight)) / 2;
            [lineBezierPath moveToPoint:CGPointMake(startX, startY)];
            [lineBezierPath addLineToPoint:CGPointMake(startX, startY + lineHeight)];
            
            startX += DESIGN_LINE_SPACE;
        }
        
        CAShapeLayer *sampleLayer = [CAShapeLayer layer];
        sampleLayer.path = lineBezierPath.CGPath;
        sampleLayer.lineWidth = DESIGN_LINE_WIDTH;
        sampleLayer.lineJoin = kCALineJoinRound;
        sampleLayer.lineCap = kCALineCapRound;
        sampleLayer.fillColor = self.lineColor.CGColor;
        sampleLayer.strokeColor = self.lineColor.CGColor;
        [self.trackView.layer addSublayer:sampleLayer];
        
        CAShapeLayer *sampleProgressLayer = [CAShapeLayer layer];
        sampleProgressLayer.path = lineBezierPath.CGPath;
        sampleProgressLayer.lineWidth = DESIGN_LINE_WIDTH;
        sampleProgressLayer.lineJoin = kCALineJoinRound;
        sampleProgressLayer.lineCap = kCALineCapRound;
        sampleProgressLayer.fillColor = self.progressColor.CGColor;
        sampleProgressLayer.strokeColor = self.progressColor.CGColor;
        [self.progressView.layer addSublayer:sampleProgressLayer];
    }
}

@end
