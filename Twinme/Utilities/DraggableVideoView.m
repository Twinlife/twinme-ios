/*
 *  Copyright (c) 2019-2020 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "DraggableVideoView.h"

#import <TwinmeCommon/Design.h>

#define DESIGN_INSET 40
#define VIEW_BORDER 8
#define DESIGN_AUDIO_MUTE_HEIGHT 80

static CGFloat DESIGN_VIEW_BORDER;
static CGFloat DESIGN_SAFE_AREA_WIDTH_INSET = 0;
static CGFloat DESIGN_SAFE_AREA_HEIGHT_INSET = 0;

//
// Interface: DraggableVideoView ()
//

@interface DraggableVideoView ()

@property(nonatomic) UIView *microMuteView;

@end

//
// Implementation: DraggableVideoView
//

@implementation DraggableVideoView

+ (void)initialize {
    
    DESIGN_VIEW_BORDER = Design.MIN_RATIO * VIEW_BORDER;
    
    UIWindow *window = UIApplication.sharedApplication.keyWindow;
    DESIGN_SAFE_AREA_WIDTH_INSET = window.safeAreaInsets.left;
    DESIGN_SAFE_AREA_HEIGHT_INSET = window.safeAreaInsets.top;
    
    if (DESIGN_SAFE_AREA_WIDTH_INSET == 0) {
        DESIGN_SAFE_AREA_WIDTH_INSET = DESIGN_INSET * Design.MIN_RATIO;
    }
    
    if (DESIGN_SAFE_AREA_HEIGHT_INSET == 0) {
        DESIGN_SAFE_AREA_HEIGHT_INSET = DESIGN_INSET * Design.MIN_RATIO;
    }
}

#pragma mark - Touch Methods

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [super touchesMoved:touches withEvent:event];
    
    UITouch *touch = [touches anyObject];
    CGPoint fromLocation = [touch previousLocationInView:self];
    CGPoint toLocation = [touch locationInView:self];
    CGPoint changeLocation = CGPointMake(toLocation.x - fromLocation.x, toLocation.y - fromLocation.y);
    
    super.center = CGPointMake(self.center.x + changeLocation.x, self.center.y + changeLocation.y);
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [super touchesEnded:touches withEvent:event];
    
    [self moveToClosestCornerAnimated:YES];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [super touchesCancelled:touches withEvent:event];
    
    [self moveToClosestCornerAnimated:YES];
}

- (void)hideMicroMute:(BOOL)hidden {
    
    self.microMuteView.hidden = hidden;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    UIBezierPath *backgroundPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(DESIGN_VIEW_BORDER, DESIGN_VIEW_BORDER, self.frame.size.width - (DESIGN_VIEW_BORDER * 2.0), self.frame.size.height - (DESIGN_VIEW_BORDER * 2.0)) cornerRadius:8.0f];
    [[UIColor whiteColor] setFill];
    [backgroundPath fill];
    
    if (!self.microMuteView) {
        self.microMuteView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"RemoteAudioMute"]];
        CGFloat audioMuteSize = DESIGN_AUDIO_MUTE_HEIGHT * Design.MIN_RATIO;
        self.microMuteView.frame = CGRectMake((self.frame.size.width / 2) - (audioMuteSize / 2), (self.frame.size.height / 2) - (audioMuteSize / 2), audioMuteSize, audioMuteSize);
        self.microMuteView.hidden = YES;
        [self addSubview:self.microMuteView];
    }
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
    
    [self moveToCornerUnit:CGPointMake(-1.0f, -1.0f) animated:animated];
}

- (void)moveToTopRightAnimated:(BOOL)animated {
    
    [self moveToCornerUnit:CGPointMake(1.0f, -1.0f) animated:animated];
}

- (void)moveToBottomLeftAnimated:(BOOL)animated {
    
    [self moveToCornerUnit:CGPointMake(-1.0f, 1.0f) animated:animated];
}

- (void)moveToBottomRightAnimated:(BOOL)animated {
    
    [self moveToCornerUnit:CGPointMake(1.0f, 1.0f) animated:animated];
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
    
    CGFloat directDistance = sqrt(xd*xd + yd*yd);
    CGFloat distancePerSecond = ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone? 720.0f : 1440.0f);
    
    [UIView animateWithDuration:(animated ? directDistance/distancePerSecond : 0.0f) delay:0.0 usingSpringWithDamping:0.6 initialSpringVelocity:1.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
        super.center = cornerPoint;
    }
                     completion:^(BOOL finished) {
    }];
    
    super.autoresizingMask = ((unit.x ? UIViewAutoresizingFlexibleLeftMargin : UIViewAutoresizingFlexibleRightMargin) | (unit.y ? UIViewAutoresizingFlexibleTopMargin : UIViewAutoresizingFlexibleBottomMargin));
}

@end
