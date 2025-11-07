/*
 *  Copyright (c) 2020 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import "CallAnimationView.h"

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static CGFloat ANIMATION_DURATION = .6f;
static CGFloat ANIMATION_RED_CIRCLE_BEGIN_TIME = .8f;
static CGFloat ANIMATION_GREEN_CIRCLE_BEGIN_TIME = 1.f;
static CGFloat ANIMATION_BLUE_CIRCLE_BEGIN_TIME = 1.1f;
static CGFloat BORDER_WIDTH = 1.f;
static UIColor *DESIGN_RED_CIRCLE_COLOR;
static UIColor *DESIGN_GREEN_CIRCLE_COLOR;
static UIColor *DESIGN_BLUE_CIRCLE_COLOR;

//
// Interface: CallAnimationView
//

@interface CallAnimationView () <CAAnimationDelegate>

@property(nonatomic) UIView *redCircleView;
@property(nonatomic) UIView *greenCircleView;
@property(nonatomic) UIView *blueCircleView;

@end

//
// Implementation: CallAnimationView
//

#undef LOG_TAG
#define LOG_TAG @"CallAnimationView"

@implementation CallAnimationView

+ (void)initialize {
    DDLogVerbose(@"%@ initialize", LOG_TAG);
    
    DESIGN_RED_CIRCLE_COLOR = [UIColor colorWithRed:255./255. green:30./255. blue:92./255. alpha:1.0];
    DESIGN_GREEN_CIRCLE_COLOR = [UIColor colorWithRed:105./255. green:221./255. blue:198./255. alpha:1.0];
    DESIGN_BLUE_CIRCLE_COLOR = [UIColor colorWithRed:14./255. green:178./255. blue:254./255. alpha:1.0];
}

- (void)startAnimation {
    DDLogVerbose(@"%@ startAnimation", LOG_TAG);
    
    if (self.redCircleView.layer.animationKeys.count == 0) {
        CABasicAnimation *animationRedCircle = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        animationRedCircle.autoreverses = NO;
        animationRedCircle.repeatCount = 1;
        animationRedCircle.duration = ANIMATION_DURATION;
        animationRedCircle.beginTime = CACurrentMediaTime() + ANIMATION_RED_CIRCLE_BEGIN_TIME;
        animationRedCircle.toValue = @(1.0);
        animationRedCircle.removedOnCompletion = YES;
        
        CABasicAnimation *animationAlphaRedCircle = [CABasicAnimation animationWithKeyPath:@"opacity"];
        animationAlphaRedCircle.autoreverses = NO;
        animationAlphaRedCircle.repeatCount = 1;
        animationAlphaRedCircle.duration = ANIMATION_DURATION;
        animationAlphaRedCircle.beginTime = CACurrentMediaTime() + ANIMATION_RED_CIRCLE_BEGIN_TIME;
        animationAlphaRedCircle.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
        animationAlphaRedCircle.fromValue = @(1.0);
        animationAlphaRedCircle.toValue = @(0.0);
        animationAlphaRedCircle.removedOnCompletion = YES;
        
        [self.redCircleView.layer addAnimation:animationRedCircle forKey:@"RedCircleViewAnimation"];
        [self.redCircleView.layer addAnimation:animationAlphaRedCircle forKey:@"RedCircleViewAlphaAnimation"];
    }
    
    if (self.greenCircleView.layer.animationKeys.count == 0) {
        CABasicAnimation *animationGreenCircle = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        animationGreenCircle.autoreverses = NO;
        animationGreenCircle.repeatCount = 1;
        animationGreenCircle.duration = ANIMATION_DURATION;
        animationGreenCircle.beginTime = CACurrentMediaTime() + ANIMATION_GREEN_CIRCLE_BEGIN_TIME;
        animationGreenCircle.toValue = @(1.0);
        animationGreenCircle.removedOnCompletion = YES;
        
        CABasicAnimation *animationAlphaGreenCircle = [CABasicAnimation animationWithKeyPath:@"opacity"];
        animationAlphaGreenCircle.autoreverses = NO;
        animationAlphaGreenCircle.repeatCount = 1;
        animationAlphaGreenCircle.duration = ANIMATION_DURATION;
        animationAlphaGreenCircle.beginTime = CACurrentMediaTime() + ANIMATION_GREEN_CIRCLE_BEGIN_TIME;
        animationAlphaGreenCircle.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
        animationAlphaGreenCircle.fromValue = @(1.0);
        animationAlphaGreenCircle.toValue = @(0.0);
        animationAlphaGreenCircle.removedOnCompletion = YES;
        
        [self.greenCircleView.layer addAnimation:animationGreenCircle forKey:@"GreenCircleViewAnimation"];
        [self.greenCircleView.layer addAnimation:animationAlphaGreenCircle forKey:@"GreenCircleViewAlphaAnimation"];
    }
    
    if (self.blueCircleView.layer.animationKeys.count == 0) {
        CABasicAnimation *animationBlueCircle = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        animationBlueCircle.autoreverses = NO;
        animationBlueCircle.repeatCount = 1;
        animationBlueCircle.duration = ANIMATION_DURATION;
        animationBlueCircle.beginTime = CACurrentMediaTime() + ANIMATION_BLUE_CIRCLE_BEGIN_TIME;
        animationBlueCircle.toValue = @(1.0);
        animationBlueCircle.removedOnCompletion = YES;
        
        CABasicAnimation *animationAlphaBlueCircle = [CABasicAnimation animationWithKeyPath:@"opacity"];
        animationAlphaBlueCircle.delegate = self;
        animationAlphaBlueCircle.autoreverses = NO;
        animationAlphaBlueCircle.repeatCount = 1;
        animationAlphaBlueCircle.duration = ANIMATION_DURATION;
        animationAlphaBlueCircle.beginTime = CACurrentMediaTime() + ANIMATION_BLUE_CIRCLE_BEGIN_TIME;
        animationAlphaBlueCircle.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
        animationAlphaBlueCircle.fromValue = @(1.0);
        animationAlphaBlueCircle.toValue = @(0.0);
        animationAlphaBlueCircle.removedOnCompletion = YES;
        
        [self.blueCircleView.layer addAnimation:animationBlueCircle forKey:@"BlueCircleViewAnimation"];
        [self.blueCircleView.layer addAnimation:animationAlphaBlueCircle forKey:@"BlueCircleViewAlphaAnimation"];
    }
}

- (void)stopAnimation {
    DDLogVerbose(@"%@ stopAnimation", LOG_TAG);
    
    self.redCircleView.hidden = YES;
    self.greenCircleView.hidden = YES;
    self.blueCircleView.hidden = YES;
    
    [self.redCircleView.layer removeAllAnimations];
    [self.greenCircleView.layer removeAllAnimations];
    [self.blueCircleView.layer removeAllAnimations];
}

- (void)drawRect:(CGRect)rect {
    DDLogVerbose(@"%@ drawRect: %@", LOG_TAG, NSStringFromCGRect(rect));
    
    if (!self.redCircleView) {
        self.redCircleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        self.redCircleView.backgroundColor = [UIColor clearColor];
        self.redCircleView.layer.borderWidth = BORDER_WIDTH;
        self.redCircleView.layer.cornerRadius = self.frame.size.height * 0.5;
        self.redCircleView.clipsToBounds = YES;
        self.redCircleView.layer.borderColor = DESIGN_RED_CIRCLE_COLOR.CGColor;
        [self addSubview:self.redCircleView];
        self.redCircleView.layer.transform = CATransform3DMakeScale(0.0, 0.0, 1.0);
    }
    
    if (!self.greenCircleView) {
        self.greenCircleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        self.greenCircleView.backgroundColor = [UIColor clearColor];
        self.greenCircleView.layer.borderWidth = BORDER_WIDTH;
        self.greenCircleView.layer.cornerRadius = self.frame.size.height * 0.5;
        self.greenCircleView.clipsToBounds = YES;
        self.greenCircleView.layer.borderColor = DESIGN_GREEN_CIRCLE_COLOR.CGColor;
        [self addSubview:self.greenCircleView];
        self.greenCircleView.layer.transform = CATransform3DMakeScale(0.0, 0.0, 1.0);
    }
    
    if (!self.blueCircleView) {
        self.blueCircleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        self.blueCircleView.backgroundColor = [UIColor clearColor];
        self.blueCircleView.layer.borderWidth = BORDER_WIDTH;
        self.blueCircleView.layer.cornerRadius = self.frame.size.height * 0.5;
        self.blueCircleView.clipsToBounds = YES;
        self.blueCircleView.layer.borderColor = DESIGN_BLUE_CIRCLE_COLOR.CGColor;
        [self addSubview:self.blueCircleView];
        self.blueCircleView.layer.transform = CATransform3DMakeScale(0.f, 0.f, 1.0f);
    }
}

@end
