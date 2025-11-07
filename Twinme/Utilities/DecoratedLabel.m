/*
 *  Copyright (c) 2016-2020 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Christian Jacquemot (Christian.Jacquemot@twinlife-systems.com)
 *   Thibaud David (contact@thibauddavid.com)
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "DecoratedLabel.h"

#import <Twinme/TLTwinmeContext.h>

//
// Interface: DecoratedLabel ()
//

@interface DecoratedLabel () <TTTAttributedLabelDelegate>

@property (nonatomic) UIColor *decorColor;
@property (nonatomic) UIColor *decorShadowColor;
@property (nonatomic) UIColor *borderColor;
@property (nonatomic) CGFloat borderWidth;
@property (nonatomic) CGFloat top;
@property (nonatomic) CGFloat left;
@property (nonatomic) CGFloat bottom;
@property (nonatomic) CGFloat right;
@property (nonatomic) CGFloat topLeft;
@property (nonatomic) CGFloat topRight;
@property (nonatomic) CGFloat bottomRight;
@property (nonatomic) CGFloat bottomLeft;
@property (nonatomic) CAShapeLayer *borderLayer;

@end

//
// Implementation: DecoratedLabel
//

@implementation DecoratedLabel

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    
    if (self) {
        [self setup];
    }
    return self;
}

#pragma mark - Setters/Getters

- (void)setDecorColor:(UIColor *)decorColor {
    
    _decorColor = decorColor;
}

- (void)setDecorShadowColor:(UIColor *)decorShadowColor {
    
    _decorShadowColor = decorShadowColor;
}

- (void)setBorderColor:(UIColor *)borderColor {
    
    _borderColor = borderColor;
}

- (void)setBorderWidth:(CGFloat)borderWidth {
    
    _borderWidth = borderWidth;
}

#pragma mark - Public methods

- (void)setPaddingWithTop:(CGFloat)top left:(CGFloat)left bottom:(CGFloat)bottom right:(CGFloat)right {
    
    self.top = top;
    self.left = left;
    self.bottom = bottom;
    self.right = right;
}

- (void)setCornerRadiusWithTopLeft:(CGFloat)topLeft topRight:(CGFloat)topRight bottomRight:(CGFloat)bottomRight bottomLeft:(CGFloat)bottomLeft {
    
    self.topLeft = topLeft;
    self.topRight = topRight;
    self.bottomRight = bottomRight;
    self.bottomLeft = bottomLeft;
}

#pragma mark - TTTAttributedLabel

- (CGSize)intrinsicContentSize {
    
    CGSize intrinsicSuperViewContentSize = [super intrinsicContentSize];
    
    intrinsicSuperViewContentSize.width += self.left + self.right + 2;
    intrinsicSuperViewContentSize.height += self.top + self.bottom;
    return intrinsicSuperViewContentSize;
}

- (void)drawTextInRect:(CGRect)rect {
    
    CGFloat height = rect.size.height;
    CGFloat max = MIN(rect.size.width / 2., height / 2.);
    CGFloat topLeft = MIN(self.topLeft, max);
    CGFloat topRight = MIN(self.topRight, max);
    CGFloat bottomRight = MIN(self.bottomRight, max);
    CGFloat bottomLeft = MIN(self.bottomLeft, max);
    
    UIBezierPath *path = [[UIBezierPath alloc] init];
    [path addArcWithCenter:CGPointMake(topLeft, topLeft) radius:topLeft startAngle:M_PI endAngle:-M_PI_2 clockwise:YES];
    [path addArcWithCenter:CGPointMake(rect.size.width - topRight, topRight) radius:topRight startAngle:-M_PI_2 endAngle:0 clockwise:YES];
    [path addArcWithCenter:CGPointMake(rect.size.width - bottomRight, height - bottomRight) radius:bottomRight startAngle:0 endAngle:M_PI_2 clockwise:YES];
    [path addArcWithCenter:CGPointMake(bottomLeft, height - bottomLeft) radius:bottomLeft startAngle:M_PI_2 endAngle:M_PI clockwise:YES];
    [path closePath];
    
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    CGContextSaveGState(contextRef);
    CGContextSetFillColorWithColor(contextRef, self.decorColor.CGColor);
    CGContextTranslateCTM(contextRef, rect.origin.x, rect.origin.y);
    [path fill];
    CGContextRestoreGState(contextRef);
    
    if (self.borderWidth != 0) {
        if (self.borderLayer) {
            [self.borderLayer removeFromSuperlayer];
        }
        CAShapeLayer *mask = [CAShapeLayer layer];
        mask.path = path.CGPath;
        self.layer.masksToBounds = YES;
        self.layer.mask = mask;
        
        self.borderLayer = [CAShapeLayer layer];
        self.borderLayer.path = mask.path;
        self.borderLayer.fillColor = [UIColor clearColor].CGColor;
        self.borderLayer.strokeColor = self.borderColor.CGColor;
        self.borderLayer.lineWidth = self.borderWidth;
        self.borderLayer.frame = rect;
        [self.layer addSublayer:self.borderLayer];
    }
    
    UIEdgeInsets insets = {self.top, self.left, self.bottom, self.right};
    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, insets)];
}

#pragma mark - TTTAttributedLabelDelegate

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    
    NSString *action = url.host;
    if ([[TLTwinmeContext INVITE_ACTION] isEqualToString:action]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:SelectInvitationLink object:url];
    } else {
        [self openUrl:url];
    }
}

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithAddress:(NSDictionary *)addressComponents {
    
    NSString *address = [addressComponents[@"Street"]?:@"" stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSString *city = [addressComponents[@"City"]?:@"" stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSString *mapScheme = [NSString stringWithFormat:@"http://maps.apple.com/?address=%@,%@", address, city];
    [self openUrl:[NSURL URLWithString:mapScheme]];
}

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithPhoneNumber:(NSString *)phoneNumber {
    
    NSURL *phoneNumberUrl = [NSURL URLWithString:[@"tel://" stringByAppendingString:phoneNumber]];
    [self openUrl:phoneNumberUrl];
}

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithDate:(NSDate *)date {
    
    NSURL *calendarScheme = [NSURL URLWithString:[NSString stringWithFormat:@"calshow:%f", [date timeIntervalSinceReferenceDate]]];
    [self openUrl:calendarScheme];
}

#pragma mark - Private methods

- (void)setup {
    
    self.enabledTextCheckingTypes = NSTextCheckingTypeLink | NSTextCheckingTypeAddress | NSTextCheckingTypePhoneNumber | NSTextCheckingTypeDate;
    self.delegate = self;
}

- (void)openUrl:(NSURL *)url {
    
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
    }
}

@end
