/*
 *  Copyright (c) 2018-2020 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "InsideBorderView.h"

//
// Interface: InsideBorderView ()
//

@interface InsideBorderView ()

@property (nonatomic) BOOL isBorder;
@property (nonatomic) CALayer *leftBorder;
@property (nonatomic) CALayer *rightBorder;
@property (nonatomic) CALayer *topBorder;
@property (nonatomic) CALayer *bottomBorder;

@end

//
// Implementation: InsideBorderView
//

@implementation InsideBorderView

#pragma mark - UIView

- (instancetype)init {
    
    self = [super init];
    
    _isBorder = NO;
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    
    _isBorder = NO;
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    
    _isBorder = NO;
    
    return self;
}

- (void)clearBorder {
    
    self.isBorder = NO;
    
    if (self.leftBorder) {
        [self.leftBorder removeFromSuperlayer];
        self.leftBorder = nil;
    }
    
    if (self.rightBorder) {
        [self.rightBorder removeFromSuperlayer];
        self.rightBorder = nil;
    }
    
    if (self.topBorder) {
        [self.topBorder removeFromSuperlayer];
        self.topBorder = nil;
    }
    
    if (self.bottomBorder) {
        [self.bottomBorder removeFromSuperlayer];
        self.bottomBorder = nil;
    }
}

- (void)setBorder:(UIColor *)color borderWidth:(CGFloat)borderWidth width:(CGFloat)width height:(CGFloat)height left:(bool)left right:(bool)right top:(bool)top bottom:(bool)bottom {
    
    if (self.isBorder) {
        return;
    }
    
    self.isBorder = YES;
    
    if (left) {
        self.leftBorder = [CALayer layer];
        self.leftBorder.borderColor = color.CGColor;
        self.leftBorder.borderWidth = borderWidth;
        self.leftBorder.frame = CGRectMake(0, 0, borderWidth, height);
        [self.layer addSublayer:self.leftBorder];
    }
    
    if (right) {
        self.rightBorder = [CALayer layer];
        self.rightBorder.borderColor = color.CGColor;
        self.rightBorder.borderWidth = borderWidth;
        self.rightBorder.frame = CGRectMake(width - borderWidth, 0, borderWidth, height);
        [self.layer addSublayer:self.rightBorder];
    }
    
    if (top) {
        self.topBorder = [CALayer layer];
        self.topBorder.borderColor = color.CGColor;
        self.topBorder.borderWidth = borderWidth;
        self.topBorder.frame = CGRectMake(0, 0, width, borderWidth);
        [self.layer addSublayer:self.topBorder];
    }
    
    if (bottom) {
        self.bottomBorder = [CALayer layer];
        self.bottomBorder.borderColor = color.CGColor;
        self.bottomBorder.borderWidth = borderWidth;
        self.bottomBorder.frame = CGRectMake(0, height, width, borderWidth);
        [self.layer addSublayer:self.bottomBorder];
    }
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
}

@end
