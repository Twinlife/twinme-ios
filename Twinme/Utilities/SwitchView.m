/*
 *  Copyright (c) 2019-2021 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "SwitchView.h"

#import <TwinmeCommon/Design.h>

static CGFloat ANIMATION_DURATION = 0.2;
static CGFloat DESIGN_THUMB_INSET = 5.0;
static CGFloat DESIGN_BORDER_WIDTH = 2.5;

//
// Interface: SwitchView ()
//

@interface SwitchView ()

@property(nonatomic) UIView *thumbView;
@property(nonatomic) UIColor *onColor;
@property(nonatomic) UIColor *offColor;
@property(nonatomic) UIColor *borderColor;
@property(nonatomic) double borderWidth;

@end

@implementation SwitchView

- (instancetype)init {
    
    self = [super init];
    
    [self setupDefaultValue];
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    
    [self setupDefaultValue];
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    
    [self setupDefaultValue];
    
    return self;
}

- (void) setupDefaultValue {
    
    _isOn = YES;
    _isEnabled = YES;
    _onColor = [UIColor colorWithRed:76./255. green:217./255. blue:100./255. alpha:1.0];
    _offColor = [UIColor colorWithRed:255./255. green:64./255. blue:64./255. alpha:1.0];
    _borderColor = Design.SWITCH_BORDER_COLOR;
    _borderWidth = DESIGN_BORDER_WIDTH;
    
    self.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapSwitch)];
    [self addGestureRecognizer:tapGesture];
}

- (void)drawRect:(CGRect)rect {
    
    if (self.borderColor) {
        self.layer.borderColor = self.borderColor.CGColor;
    }
    
    self.backgroundColor = [UIColor clearColor];
    
    if (self.borderWidth) {
        self.layer.borderWidth = self.borderWidth;
    }
    
    self.layer.cornerRadius = self.frame.size.height / 2.0;
    self.clipsToBounds = YES;
    
    if (!self.thumbView) {
        CGFloat thumbHeight = self.frame.size.height - (DESIGN_THUMB_INSET * 2);
        CGFloat thumbX = self.frame.size.width - DESIGN_THUMB_INSET - thumbHeight;
        
        if (!self.isOn) {
            thumbX = DESIGN_THUMB_INSET;
        }
        
        self.thumbView = [[UIView alloc] initWithFrame:CGRectMake(thumbX, DESIGN_THUMB_INSET, thumbHeight, thumbHeight)];
        self.thumbView.backgroundColor = [UIColor clearColor];
        self.thumbView.layer.borderWidth = self.borderWidth;
        self.thumbView.layer.cornerRadius = thumbHeight / 2;
        self.thumbView.clipsToBounds = YES;
        
        if (!self.isOn) {
            self.thumbView.layer.borderColor = self.offColor.CGColor;
        } else {
            self.thumbView.layer.borderColor = self.onColor.CGColor;
        }
        
        [self addSubview:self.thumbView];
    } else {
        CGRect thumbViewRect = self.thumbView.frame;
        if (!self.isOn) {
            self.thumbView.layer.borderColor = self.offColor.CGColor;
            thumbViewRect.origin.x = DESIGN_THUMB_INSET;
        } else {
            self.thumbView.layer.borderColor = self.onColor.CGColor;
            thumbViewRect.origin.x = self.frame.size.width - DESIGN_THUMB_INSET - thumbViewRect.size.height;
        }
        self.thumbView.frame = thumbViewRect;
    }
    
    if (self.isEnabled) {
        self.alpha = 1.0;
    } else {
        self.alpha = 0.5;
    }
}

- (void)handleTapSwitch {
    
    if (!self.isEnabled) {
        return;
    }
    
    self.isOn = !self.isOn;
    
    [UIView animateWithDuration:ANIMATION_DURATION delay:0 options: UIViewAnimationOptionCurveEaseIn animations:^{
        CGRect thumbViewRect = self.thumbView.frame;
        if (!self.isOn) {
            self.thumbView.layer.borderColor = self.offColor.CGColor;
            thumbViewRect.origin.x = DESIGN_THUMB_INSET;
        } else {
            self.thumbView.layer.borderColor = self.onColor.CGColor;
            thumbViewRect.origin.x = self.frame.size.width - DESIGN_THUMB_INSET - thumbViewRect.size.height;
        }
        self.thumbView.frame = thumbViewRect;
    } completion:^(BOOL finished) {
        if ([self.switchViewDelegate respondsToSelector:@selector(switchViewDidTap:)]) {
            [self.switchViewDelegate switchViewDidTap:self];
        }
    }];
}

- (void)setOn:(BOOL)on {
    
    self.isOn = on;
    
    [UIView animateWithDuration:ANIMATION_DURATION delay:0 options: UIViewAnimationOptionCurveEaseIn animations:^{
        if (self.thumbView) {
            CGRect thumbViewRect = self.thumbView.frame;
            if (!self.isOn) {
                self.thumbView.layer.borderColor = self.offColor.CGColor;
                thumbViewRect.origin.x = DESIGN_THUMB_INSET;
            } else {
                self.thumbView.layer.borderColor = self.onColor.CGColor;
                thumbViewRect.origin.x = self.frame.size.width - DESIGN_THUMB_INSET - thumbViewRect.size.height;
            }
            self.thumbView.frame = thumbViewRect;
            
            if (!self.isOn) {
                self.thumbView.layer.borderColor = self.offColor.CGColor;
            } else {
                self.thumbView.layer.borderColor = self.onColor.CGColor;
            }
        }
    } completion:^(BOOL finished) {
    }];
}

- (void)setEnabled:(BOOL)enabled {
    
    self.isEnabled = enabled;
    
    if (self.isEnabled) {
        self.alpha = 1.0;
    } else {
        self.alpha = 0.5;
    }
}

- (void)resetSwitch {
    
    if (self.thumbView) {
        self.borderColor = Design.SWITCH_BORDER_COLOR;
        [self.thumbView removeFromSuperview];
        self.thumbView = nil;
        [self setNeedsLayout];
        [self setNeedsDisplay];
    }
}

@end
