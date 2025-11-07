/*
 *  Copyright (c) 2022-2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "CustomProgressBarView.h"

#import <TwinmeCommon/Design.h>

static CGFloat ANIMATION_DURATION = 5;
static UIColor *DESIGN_BACKGROUND_COLOR;
static UIColor *DESIGN_BACKGROUND_DARK_COLOR;
static UIColor *DESIGN_PROGRESS_COLOR;

//
// Interface: CustomProgressBarView
//

@interface CustomProgressBarView ()

@property (nonatomic) UIView *containerView;
@property (nonatomic) UIView *progressView;
@property (nonatomic) BOOL startAnimationDeferred;

@end

//
// Implementation: CustomProgressBarView
//

@implementation CustomProgressBarView

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    
    if (self) {
        _startAnimationDeferred = NO;
        
        DESIGN_PROGRESS_COLOR = [Design MAIN_COLOR];
        DESIGN_BACKGROUND_COLOR = [Design LIGHT_GREY_BACKGROUND_COLOR];
        DESIGN_BACKGROUND_DARK_COLOR = [Design GREY_BACKGROUND_COLOR];
    }
    
    return self;
}

- (void)startAnimation {

    if (!self.progressView) {
        self.startAnimationDeferred = YES;
        return;
    }
    
    [UIView animateWithDuration:ANIMATION_DURATION delay:0 options: UIViewAnimationOptionCurveEaseIn animations:^{
        if (self.progressView) {
            self.progressView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        }
    } completion:^(BOOL finished) {
        if (finished && self.progressView && [self.customProgressBarDelegate respondsToSelector:@selector(customProgressBarEndAnimation:)]) {
            [self.customProgressBarDelegate customProgressBarEndAnimation:self];
        }
    }];
}

- (void)stopAnimation {
    
    [self.progressView.layer removeAllAnimations];
    self.progressView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
}

- (void)resetAnimation {
    
    self.progressView.frame = CGRectMake(0, 0, 0, self.frame.size.height);
}

- (void)drawRect:(CGRect)rect {
    
    [super drawRect:rect];
    
    self.backgroundColor = [UIColor clearColor];
    self.clipsToBounds = YES;
    self.layer.cornerRadius = self.frame.size.height * 0.5;
    
    if (!self.containerView) {
        self.containerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        if (self.isDarkMode) {
            self.containerView.backgroundColor = DESIGN_BACKGROUND_DARK_COLOR;
        } else {
            self.containerView.backgroundColor = DESIGN_BACKGROUND_COLOR;
        }
        self.containerView.clipsToBounds = YES;
        self.containerView.layer.cornerRadius = self.frame.size.height * 0.5;
        
        [self addSubview:self.containerView];
        
        self.progressView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 0, self.frame.size.height)];
        self.progressView.backgroundColor = DESIGN_PROGRESS_COLOR;
        self.progressView.clipsToBounds = YES;
        self.progressView.layer.cornerRadius = self.frame.size.height * 0.5;
        
        [self addSubview:self.progressView];
        
        if (self.startAnimationDeferred) {
            self.startAnimationDeferred = NO;
            [self startAnimation];
        }
    }
}

- (void)dealloc {
    
    [self.progressView.layer removeAllAnimations];
    self.customProgressBarDelegate = nil;
}

@end
