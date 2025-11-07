/*
 *  Copyright (c) 2024 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <Twinlife/TLTwinlifeContext.h>

#import "InfoFloatingView.h"

#import <TwinmeCommon/Design.h>
#import <Utils/NSString+Utils.h>
#import <Lottie/Lottie.h>
#import "UIAppInfo.h"

#define DESIGN_X_INSET 30
#define DESIGN_Y_INSET 70
#define DESIGN_EXTEND_ALPHA 1.0
#define DESIGN_DEFAULT_ALPHA 1.0

#define ADD_TIME_INTERVAL 5
#define TIMER_INTERVAL 1
#define TIMER_MESSAGE_INTERVAL 5
#define NETWORK_ANIMATION_DURATION 3

static CGFloat DESIGN_SAFE_AREA_WIDTH_INSET = 0;
static CGFloat DESIGN_SAFE_AREA_HEIGHT_INSET = 0;

static CGFloat DESIGN_DEFAULT_SIZE = 120;
static CGFloat DESIGN_ROUNDED_VIEW_SIZE = 60;
static CGFloat DESIGN_ROUNDED_VIEW_MARGIN = 30;
static CGFloat DESIGN_IMAGE_MARGIN = 12;
static CGFloat DESIGN_IMAGE_SIZE = 36;

//
// Interface: InfoFloatingView
//

@interface InfoFloatingView () <CAAnimationDelegate>

@property (nonatomic, nullable) UIView *roundedView;
@property (nonatomic, nullable) UIImageView *iconImageView;
@property (nonatomic, nullable) UILabel *infoLabel;

@property (nonatomic) InfoFloatingViewState infoFloatingViewState;
@property (nonatomic) UIAppInfo *uiAppInfo;

@property (nonatomic) NSTimer *timer;
@property (nonatomic) NSTimer *timerMessage;
@property (nonatomic) NSDate *hideDate;

@property (nonatomic) LOTAnimationView *lottieAnimationView;

@end

//
// Implementation: CallFloatingView
//

#undef LOG_TAG
#define LOG_TAG @"InfoFloatingView"

@implementation InfoFloatingView

+ (void)initialize {
    
    UIWindow *window = UIApplication.sharedApplication.keyWindow;
    DESIGN_SAFE_AREA_WIDTH_INSET = window.safeAreaInsets.left + DESIGN_X_INSET * Design.WIDTH_RATIO;
    DESIGN_SAFE_AREA_HEIGHT_INSET = window.safeAreaInsets.top + DESIGN_Y_INSET * Design.HEIGHT_RATIO;
}

- (void)setConnectionStatus:(TLConnectionStatus)connectionStatus {
    
    [self resetTimer];
    [self setTimer];
    
    switch (connectionStatus) {
        case TLConnectionStatusConnected:
            self.uiAppInfo = [[UIAppInfo alloc]initWithInfoType:InfoFloatingViewTypeConnected];
            break;
            
        case TLConnectionStatusNoInternet:
            self.uiAppInfo = [[UIAppInfo alloc]initWithInfoType:InfoFloatingViewTypeOffline];
            break;
            
        case TLConnectionStatusNoService:
            self.uiAppInfo = [[UIAppInfo alloc]initWithInfoType:InfoFloatingViewTypeNoServices];
            break;
            
        case TLConnectionStatusConnecting:
            self.uiAppInfo = [[UIAppInfo alloc]initWithInfoType:InfoFloatingViewTypeConnectionInProgress];
            break;
            
        default:
            break;
    }
    [self setNeedsDisplay];
    
    if (self.alpha != 1) {
        [UIView animateWithDuration:.2 animations:^{
            self.alpha = 1;
        } completion:^(BOOL finished) {
        }];
    }
}

- (void)tapAction {
    
    [self resetTimer];
    [self setTimer];
    
    CGFloat labelX = (DESIGN_IMAGE_MARGIN * Design.HEIGHT_RATIO * 2) + (DESIGN_IMAGE_SIZE * Design.HEIGHT_RATIO);
    CGFloat maxLabelWidth = Design.DISPLAY_WIDTH - (DESIGN_SAFE_AREA_WIDTH_INSET * 2) - labelX;
    CGRect infoRect = [self.infoLabel.text boundingRectWithSize:CGSizeMake(maxLabelWidth, self.infoLabel.frame.size.height) options:NSStringDrawingUsesFontLeading attributes:@{
        NSFontAttributeName : Design.FONT_MEDIUM32
    } context:nil];
    
    CGRect labelFrame = self.infoLabel.frame;
    labelFrame.size.width = infoRect.size.width;
    self.infoLabel.frame = labelFrame;
        
    CGRect frame = self.frame;
    CGFloat backgroundAlpha;
    if (self.infoFloatingViewState == InfoFloatingViewStateDefault) {
        [self resetTimerMessage];
        [self setTimerMessage];
        
        self.infoFloatingViewState = InfoFloatingViewStateExtend;
        self.infoLabel.hidden = NO;
        
        CGFloat maxWidth = Design.DISPLAY_WIDTH - (DESIGN_SAFE_AREA_WIDTH_INSET * 2);
        CGFloat width = labelX + infoRect.size.width + (DESIGN_IMAGE_MARGIN * Design.HEIGHT_RATIO) + (DESIGN_ROUNDED_VIEW_MARGIN * Design.WIDTH_RATIO * 2);
        
        CGFloat extendX = DESIGN_SAFE_AREA_WIDTH_INSET;
        if (round(self.frame.origin.x) != round(extendX) && width < maxWidth) {
            extendX = Design.DISPLAY_WIDTH - DESIGN_SAFE_AREA_WIDTH_INSET - width;
        }
        CGFloat extendWidth = width < maxWidth ? width : maxWidth;
                
        frame = CGRectMake(extendX, frame.origin.y, extendWidth, DESIGN_DEFAULT_SIZE * Design.HEIGHT_RATIO);
        backgroundAlpha = DESIGN_EXTEND_ALPHA;
    } else {
        self.infoFloatingViewState = InfoFloatingViewStateDefault;
        
        [self resetTimerMessage];
        
        CGFloat x = DESIGN_SAFE_AREA_WIDTH_INSET;
        if (round(self.frame.origin.x) != round(DESIGN_SAFE_AREA_WIDTH_INSET)) {
            x = Design.DISPLAY_WIDTH - DESIGN_SAFE_AREA_WIDTH_INSET - (DESIGN_ROUNDED_VIEW_SIZE * Design.HEIGHT_RATIO);
        }
        
        frame = CGRectMake(x, frame.origin.y, DESIGN_DEFAULT_SIZE * Design.HEIGHT_RATIO, DESIGN_DEFAULT_SIZE * Design.HEIGHT_RATIO);
        self.infoLabel.hidden = YES;
        backgroundAlpha = DESIGN_DEFAULT_ALPHA;
    }
    
    [UIView animateWithDuration:0.5f delay:0.0 usingSpringWithDamping:0.6 initialSpringVelocity:1.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.frame = frame;
        CGRect roundedViewFrame = self.roundedView.frame;
        roundedViewFrame.size.width = frame.size.width - (DESIGN_ROUNDED_VIEW_MARGIN * 2 * Design.WIDTH_RATIO);
        self.roundedView.frame = roundedViewFrame;
        self.roundedView.backgroundColor = [UIColor colorWithWhite:0 alpha:backgroundAlpha];
    } completion:^(BOOL finished) {
    }];
}

- (void)hideView {
    
    if (self.hideDate && [self.hideDate compare:[NSDate date]] == NSOrderedAscending && (self.uiAppInfo && self.uiAppInfo.infoFloatingViewType == InfoFloatingViewTypeConnected)) {
        [UIView animateWithDuration:.2 animations:^{
            self.alpha = 0;
        } completion:^(BOOL finished) {
            [self resetTimer];
            [self resetTimerMessage];
        }];
    }
}

- (void)setTimer {
    
    self.hideDate = [NSDate dateWithTimeIntervalSinceNow:ADD_TIME_INTERVAL];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:TIMER_INTERVAL target:self selector:@selector(hideView) userInfo:nil repeats:YES];
}

- (void)resetTimer {
    
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)setTimerMessage {
    
    self.timerMessage = [NSTimer scheduledTimerWithTimeInterval:TIMER_MESSAGE_INTERVAL target:self selector:@selector(updateMessage) userInfo:nil repeats:YES];
}

- (void)resetTimerMessage {
    
    if (self.timerMessage) {
        [self.timerMessage invalidate];
        self.timerMessage = nil;
    }
}


#pragma mark - Touch Methods

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [super touchesMoved:touches withEvent:event];
    
    self.hideDate = [NSDate dateWithTimeIntervalSinceNow:ADD_TIME_INTERVAL];
    
    if (self.infoFloatingViewState == InfoFloatingViewStateExtend) {
        return;
    }
    
    UITouch *touch = [touches anyObject];
    CGPoint fromLocation = [touch previousLocationInView:self];
    CGPoint toLocation = [touch locationInView:self];
    CGPoint changeLocation = CGPointMake(toLocation.x - fromLocation.x, toLocation.y - fromLocation.y);
    
    super.center = CGPointMake(self.center.x + changeLocation.x, self.center.y + changeLocation.y);
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [super touchesEnded:touches withEvent:event];
    
    if (self.infoFloatingViewState == InfoFloatingViewStateExtend) {
        return;
    }
    
    [self moveToClosestCornerAnimated:YES];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [super touchesCancelled:touches withEvent:event];
    
    if (self.infoFloatingViewState == InfoFloatingViewStateExtend) {
        return;
    }
    
    [self moveToClosestCornerAnimated:YES];
}

- (void)drawRect:(CGRect)rect {
    
    [super drawRect:rect];
    
    self.layer.backgroundColor = [UIColor clearColor].CGColor;
    self.clipsToBounds = YES;
    
    if (!self.roundedView) {
        CGFloat viewX = DESIGN_ROUNDED_VIEW_MARGIN * Design.HEIGHT_RATIO;
        CGFloat viewY = (self.bounds.size.height - (DESIGN_ROUNDED_VIEW_SIZE * Design.HEIGHT_RATIO)) * 0.5;
        CGFloat viewSize = DESIGN_ROUNDED_VIEW_SIZE * Design.HEIGHT_RATIO;
        self.roundedView = [[UIView alloc] initWithFrame:CGRectMake(viewX, viewY, viewSize, viewSize)];
        self.roundedView.backgroundColor = [UIColor colorWithWhite:0 alpha:DESIGN_DEFAULT_ALPHA];
        self.roundedView.layer.cornerRadius = viewSize * 0.5;
        self.roundedView.layer.borderWidth = 1;
        self.roundedView.layer.borderColor = Design.POPUP_BACKGROUND_COLOR.CGColor;
        self.roundedView.clipsToBounds = YES;
        [self addSubview:self.roundedView];
        
        [self moveToTopRightAnimated:NO];
    }

    if (!self.iconImageView) {
        CGFloat iconX = DESIGN_IMAGE_MARGIN * Design.HEIGHT_RATIO;
        CGFloat iconY = ((DESIGN_ROUNDED_VIEW_SIZE - DESIGN_IMAGE_SIZE) * Design.HEIGHT_RATIO) * 0.5;
        CGFloat iconSize = DESIGN_IMAGE_SIZE * Design.HEIGHT_RATIO;
        self.iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(iconX, iconY, iconSize, iconSize)];
        self.iconImageView.clipsToBounds = YES;
        [self.iconImageView setContentMode:UIViewContentModeScaleAspectFit];
        [self.roundedView addSubview:self.iconImageView];
    }
    
    if (!self.infoLabel) {
        CGFloat labelX = (DESIGN_IMAGE_MARGIN * Design.HEIGHT_RATIO * 2) + (DESIGN_IMAGE_SIZE * Design.HEIGHT_RATIO);
        CGFloat labelWidth = Design.DISPLAY_WIDTH - (DESIGN_SAFE_AREA_WIDTH_INSET * 2) - labelX;
        self.infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelX, 0, labelWidth, DESIGN_ROUNDED_VIEW_SIZE * Design.HEIGHT_RATIO)];
        self.infoLabel.numberOfLines = 0;
        self.infoLabel.textAlignment = NSTextAlignmentNatural;
        self.infoLabel.textColor = [UIColor whiteColor];
        self.infoLabel.font = Design.FONT_MEDIUM32;
        [self.roundedView addSubview:self.infoLabel];
    }
    
    [self updateInfo];
}

#pragma mark - Math

- (CGPoint)closestCornerUnit {
    
    CGFloat xCenter = self.superview.center.x;
    CGFloat yCenter = self.superview.center.y;
    
    CGFloat xCenterDist = self.center.x - xCenter;
    CGFloat yCenterDist = self.center.y - yCenter;
    
    return CGPointMake(xCenterDist / fabs(xCenterDist), yCenterDist / fabs(yCenterDist));
}

#pragma mark - Public Commands

- (void)moveToTopLeftAnimated:(BOOL)animated {
    
    [self moveToCornerUnit:CGPointMake(-1, -1) animated:animated];
}

- (void)moveToTopRightAnimated:(BOOL)animated {
    
    [self moveToCornerUnit:CGPointMake(1, -1) animated:animated];
}

- (void)moveToBottomLeftAnimated:(BOOL)animated {
    
    [self moveToCornerUnit:CGPointMake(-1, 1) animated:animated];
}

- (void)moveToBottomRightAnimated:(BOOL)animated {
    
    [self moveToCornerUnit:CGPointMake(1, 1) animated:animated];
}

- (void)moveToClosestCornerAnimated:(BOOL)animated {
    
    CGPoint closestCornerUnit = [self closestCornerUnit];
    [self moveToCornerUnit:closestCornerUnit animated:animated];
}

#pragma mark - Private Commands

- (void)moveToCornerUnit:(CGPoint)unit animated:(BOOL)animated {
    
    if (!self.superview)
        return;
    
    CGFloat xCenter = self.superview.center.x;
    CGFloat yCenter = self.superview.center.y;
    
    CGFloat xWidth = (self.superview.bounds.size.width - self.bounds.size.width - DESIGN_SAFE_AREA_WIDTH_INSET * 2.0f);
    CGFloat yHeight = (self.superview.bounds.size.height - self.bounds.size.height - DESIGN_SAFE_AREA_HEIGHT_INSET  * 2.0f);
    
    CGPoint cornerPoint = CGPointMake(xCenter + (xWidth / 2.0f * unit.x), yCenter + (yHeight / 2.0f * unit.y));
    CGFloat xd = cornerPoint.x - self.center.x;
    CGFloat yd = cornerPoint.y - self.center.y;
    
    CGFloat directDistance = sqrt(xd * xd + yd * yd);
    CGFloat distancePerSecond = ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone? 720.0f : 1440.0f);
    
    [UIView animateWithDuration:(animated ? directDistance/distancePerSecond : 0.0f) delay:0.0 usingSpringWithDamping:0.6 initialSpringVelocity:1.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        super.center = cornerPoint;
    } completion:^(BOOL finished) {
    }];
    
    super.autoresizingMask = ((unit.x ? UIViewAutoresizingFlexibleLeftMargin : UIViewAutoresizingFlexibleRightMargin) | (unit.y ? UIViewAutoresizingFlexibleTopMargin : UIViewAutoresizingFlexibleBottomMargin));
}

- (void)updateInfo {
            
    self.infoLabel.text = [self.uiAppInfo getAppInfoTitle];
    
    if (self.infoFloatingViewState == InfoFloatingViewStateExtend) {
        [self updateFrame];
    }
    
    self.iconImageView.image = [self.uiAppInfo getAppInfoImage];
    
    if ([self.uiAppInfo getAppInfoColor]) {
        self.iconImageView.image = [self.iconImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        self.iconImageView.tintColor = [self.uiAppInfo getAppInfoColor];
    }
    
    if (self.uiAppInfo.infoFloatingViewType != InfoFloatingViewTypeConnected) {
        if (self.lottieAnimationView) {
            [self.lottieAnimationView stop];
            [self.lottieAnimationView removeFromSuperview];
            self.lottieAnimationView = nil;
        }
    } else {
        self.iconImageView.image = nil;
        [self loadAnimation];
        [self playAnimation];
    }
}

- (void)updateMessage {
    
    if (self.infoFloatingViewState == InfoFloatingViewStateExtend && (self.uiAppInfo && ![[self.uiAppInfo getAppInfoMessage] isEqualToString:@""])) {
        
        if ([self.infoLabel.text isEqualToString:[self.uiAppInfo getAppInfoTitle]]) {
            self.infoLabel.text = [self.uiAppInfo getAppInfoMessage];
        } else {
            self.infoLabel.text = [self.uiAppInfo getAppInfoTitle];
        }
        [self updateFrame];
    }
}

- (void)loadAnimation {

    if (self.lottieAnimationView) {
        if ([self.lottieAnimationView isAnimationPlaying]) {
            [self.lottieAnimationView stop];
        }
        [self.lottieAnimationView removeFromSuperview];
        self.lottieAnimationView = nil;
    }
    
    NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"shield_animation" ofType:@"json"]];

    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    
    self.lottieAnimationView = [LOTAnimationView animationFromJSON:dictionary];
    self.lottieAnimationView.frame = CGRectMake(0, 0, self.iconImageView.frame.size.width, self.iconImageView.frame.size.height);
    self.lottieAnimationView.loopAnimation = NO;
}

- (void)playAnimation {

    [self.iconImageView addSubview:self.lottieAnimationView];
    [self.lottieAnimationView play];
}

- (void)updateFrame {
    
    CGFloat labelX = (DESIGN_IMAGE_MARGIN * Design.HEIGHT_RATIO * 2) + (DESIGN_IMAGE_SIZE * Design.HEIGHT_RATIO);
    CGFloat maxLabelWidth = Design.DISPLAY_WIDTH - (DESIGN_SAFE_AREA_WIDTH_INSET * 2) - labelX;
    CGRect infoRect = [self.infoLabel.text boundingRectWithSize:CGSizeMake(maxLabelWidth, self.infoLabel.frame.size.height) options:NSStringDrawingUsesFontLeading attributes:@{
        NSFontAttributeName : Design.FONT_MEDIUM32
    } context:nil];
    
    CGRect labelFrame = self.infoLabel.frame;
    labelFrame.size.width = infoRect.size.width;
    self.infoLabel.frame = labelFrame;
        
    CGFloat maxWidth = Design.DISPLAY_WIDTH - (DESIGN_SAFE_AREA_WIDTH_INSET * 2);
    CGFloat width = labelX + infoRect.size.width + (DESIGN_IMAGE_MARGIN * Design.HEIGHT_RATIO) + (DESIGN_ROUNDED_VIEW_MARGIN * Design.WIDTH_RATIO * 2);
    
    CGFloat extendX = DESIGN_SAFE_AREA_WIDTH_INSET;
    if (round(self.frame.origin.x) != round(extendX) && width < maxWidth) {
        extendX = Design.DISPLAY_WIDTH - DESIGN_SAFE_AREA_WIDTH_INSET - width;
    }
    CGFloat extendWidth = width < maxWidth ? width : maxWidth;
            
    CGRect frame = CGRectMake(extendX, self.frame.origin.y, extendWidth, DESIGN_DEFAULT_SIZE * Design.HEIGHT_RATIO);

    [UIView animateWithDuration:0.5f delay:0.0 usingSpringWithDamping:0.6 initialSpringVelocity:1.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.frame = frame;
        CGRect roundedViewFrame = self.roundedView.frame;
        roundedViewFrame.size.width = frame.size.width - (DESIGN_ROUNDED_VIEW_MARGIN * 2 * Design.WIDTH_RATIO);
        self.roundedView.frame = roundedViewFrame;
    } completion:^(BOOL finished) {
    }];
}

@end

