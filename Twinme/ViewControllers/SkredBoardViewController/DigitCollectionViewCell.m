/*
 *  Copyright (c) 2017-2018 twinlife SA & Telefun SAS.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Thibaud David (contact@thibauddavid.com)
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "DigitCollectionViewCell.h"
#import "UIView+GradientBackgroundColor.h"

#import <Utils/NSString+Utils.h>

//
// Interface: DigitCollectionViewCell ()
//

@interface DigitCollectionViewCell ()

@property (strong, nonatomic) UILabel *label;
@property (strong, nonatomic) CAShapeLayer *fillLayer;
@property (strong, nonatomic) UIColor *fillColor;
@property (assign, nonatomic) BOOL isHighlight;

@end

//
// Implementation: DigitCollectionViewCell
//

@implementation DigitCollectionViewCell

#pragma mark - Initializers

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    
    if(self = [super initWithCoder:aDecoder]) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    
    if(self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (instancetype)init {
    
    if(self = [super init]) {
        [self setup];
    }
    return self;
}

#pragma mark - UI Setup

- (void)setup {
    
    CAShapeLayer *fillLayer = [CAShapeLayer layer];
    fillLayer.fillRule = kCAFillRuleEvenOdd;
    self.fillLayer = fillLayer;
    [self.layer addSublayer:fillLayer];
    
    self.label = [UILabel new];
    self.label.textColor = [UIColor whiteColor];
    self.label.textAlignment = NSTextAlignmentCenter;
    self.label.backgroundColor = [UIColor clearColor];
    [self addSubview:self.label];
    
    [self setupGradientBackgroundFromColors:nil];
    
    self.clipsToBounds = YES;
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    self.label.frame = self.bounds;
    //    [self updateGradientBounds];
    self.layer.cornerRadius = self.frame.size.height /2;
    
    UIBezierPath *overlayPath = [UIBezierPath bezierPathWithRect:self.bounds];
    UIBezierPath *transparentPath = [UIBezierPath bezierPath];
    float radius = self.isHighlight ? 0 : (self.bounds.size.width/2 - 2);
    [transparentPath addArcWithCenter:CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2) radius:radius startAngle:0 endAngle:2 * M_PI clockwise:YES];
    
    [overlayPath appendPath:transparentPath];
    [overlayPath setUsesEvenOddFillRule:YES];
    
    self.fillLayer.path = overlayPath.CGPath;
    self.fillLayer.fillColor = self.fillColor.CGColor;
}

- (void)resetHighlight {
    
    self.backgroundColor = self.fillColor;
    [UIView animateWithDuration:0.4f delay:0 options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         self.backgroundColor = UIColor.clearColor;
                     }
                     completion:nil];
}


- (void)setHighlight:(BOOL)isHighlight {
    
    self.isHighlight = isHighlight;
    
    if (!self.isHighlight) {
        [self resetHighlight];
    } else {
        self.backgroundColor = UIColor.clearColor;
        
        [UIView animateWithDuration:0.3f delay:0 options:UIViewAnimationOptionAllowUserInteraction
                         animations:^{
                             self.backgroundColor = self.fillColor;
                         }
                         completion:nil];
    }
}

- (void)setDigit:(NSInteger)digit gradientColors:(NSArray<UIColor *> *)gradientColors {
    
    _digit = digit;
    self.label.text = [NSString convertWithLocale:@(digit).stringValue];
    self.fillColor = gradientColors.firstObject;
}

@end
