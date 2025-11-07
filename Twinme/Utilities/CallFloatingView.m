/*
 *  Copyright (c) 2020-2022 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 *   Stephane Carrez (Stephane.Carrez@twin.life)
 */
#import <CocoaLumberjack.h>

#import "CallFloatingView.h"

#import <WebRTC/RTCVideoRenderer.h>
#import <WebRTC/RTCEAGLVideoView.h>
#import <WebRTC/RTCMTLVideoView.h>

#import <TwinmeCommon/Design.h>
#import <TwinmeCommon/CallParticipant.h>

#define DESIGN_INSET 40
static CGFloat DESIGN_SAFE_AREA_WIDTH_INSET = 0;
static CGFloat DESIGN_SAFE_AREA_HEIGHT_INSET = 0;

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

//
// Interface: CallFloatingView
//

@interface CallFloatingView () <CAAnimationDelegate, RTC_OBJC_TYPE(RTCVideoViewDelegate)>

@property (nonatomic, nullable) UIImageView *avatarView;
@property (nonatomic, nullable) UIView *videoView;
@property (nonatomic, nullable) CallParticipant *participant;
@property (nonatomic, nullable) UIView *remoteVideoView; // Either a RTC_OBJC_TYPE(RTCMTLVideoView) or RTC_OBJC_TYPE(RTCEAGLVideoView)

@property (nonatomic) BOOL remoteVideoTrackAdded;
@property (nonatomic) BOOL keyboardHidden;
@property (nonatomic) CallFloatingViewPosition callFloatingViewPosition;

@end

//
// Implementation: CallFloatingView
//

#undef LOG_TAG
#define LOG_TAG @"CallFloatingView"

@implementation CallFloatingView

+ (void)initialize {
    
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

- (void)initWithCallParticipant:(nonnull CallParticipant *)participant {
    
    self.participant = participant;
    self.remoteVideoTrackAdded = NO;
    self.keyboardHidden = YES;
    self.callFloatingViewPosition = CallFloatingViewPositionTopRight;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

    [self setNeedsDisplay];
}

- (void)moveToTop {
    
    if (self.callFloatingViewPosition == CallFloatingViewPositionBottomRight) {
        self.callFloatingViewPosition = CallFloatingViewPositionTopRight;
        [self moveToTopRightAnimated:YES];
    } else if (self.callFloatingViewPosition == CallFloatingViewPositionBottomLeft) {
        self.callFloatingViewPosition = CallFloatingViewPositionTopLeft;
        [self moveToTopLeftAnimated:YES];
    }
}

- (void)keyboardWillShow:(NSNotification *)notification {
    DDLogVerbose(@"%@ keyboardWillShow: %@", LOG_TAG, notification);
    
    if (!self.keyboardHidden) {
        return;
    }
    
    self.keyboardHidden = NO;
    
    [self moveToTop];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    DDLogVerbose(@"%@ keyboardWillHide: %@", LOG_TAG, notification);
    
    self.keyboardHidden = YES;
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

- (void)drawRect:(CGRect)rect {
    
    [super drawRect:rect];
    
    self.layer.cornerRadius = self.bounds.size.height * 0.5;
    self.layer.borderWidth = 1;
    self.layer.borderColor = Design.BLACK_COLOR.CGColor;
    
    if (!self.avatarView && self.participant) {
        self.avatarView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
        self.avatarView.image = [self.participant avatar];
        self.avatarView.clipsToBounds = YES;
        self.avatarView.hidden = !self.participant.isVideoMute;
        self.avatarView.layer.cornerRadius = self.bounds.size.height * 0.5;
        [self addSubview:self.avatarView];
        
        [self moveToTopRightAnimated:NO];
    }
    
    if (!self.remoteVideoView && !self.participant.isVideoMute) {
        self.videoView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
        self.videoView.userInteractionEnabled = NO;
        self.videoView.clipsToBounds = YES;
        self.videoView.layer.cornerRadius = self.bounds.size.height * 0.5;
        [self addSubview:self.videoView];
        
        // Use MetalKit on recent devices and GLKit on old ones.
        RTC_OBJC_TYPE(RTCMTLVideoView) *remoteVideoView = [[RTC_OBJC_TYPE(RTCMTLVideoView) alloc] initWithFrame:CGRectZero];
        if ([remoteVideoView isConfigured]) {
            remoteVideoView.delegate = self;
            self.remoteVideoView = remoteVideoView;
        } else {
            DDLogError(@"%@ MetalKit video view creation failed (fallback to RTCEAGLVideoView)", LOG_TAG);
        }

        // Fallback to EAGL video view if MetalKit failed.
        if (!self.remoteVideoView) {
            RTC_OBJC_TYPE(RTCEAGLVideoView) *remoteVideoView = [[RTC_OBJC_TYPE(RTCEAGLVideoView) alloc] initWithFrame:CGRectZero];
            remoteVideoView.delegate = self;
            self.remoteVideoView = remoteVideoView;
        }
        self.remoteVideoView.userInteractionEnabled = NO;
        self.remoteVideoView.clipsToBounds = YES;
        [self.videoView addSubview:self.remoteVideoView];
        [self.participant attachWithRenderer:(id<RTC_OBJC_TYPE(RTCVideoRenderer)>)self.remoteVideoView];
        self.remoteVideoTrackAdded = YES;
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
    
    if (!self.keyboardHidden) {
        if (self.callFloatingViewPosition == CallFloatingViewPositionTopLeft) {
            [self moveToTopLeftAnimated:YES];
        } else if (self.callFloatingViewPosition == CallFloatingViewPositionTopRight) {
            [self moveToTopRightAnimated:YES];
        }
    } else {
        CGPoint closestCornerUnit = [self closestCornerUnit];
        if (closestCornerUnit.x == 1 && closestCornerUnit.y == 1) {
            self.callFloatingViewPosition = CallFloatingViewPositionBottomRight;
        } else if (closestCornerUnit.x == -1 && closestCornerUnit.y == 1) {
            self.callFloatingViewPosition = CallFloatingViewPositionBottomLeft;
        } else if (closestCornerUnit.x == 1 && closestCornerUnit.y == -1) {
            self.callFloatingViewPosition = CallFloatingViewPositionTopRight;
        } else {
            self.callFloatingViewPosition = CallFloatingViewPositionTopLeft;
        }
        
        [self moveToCornerUnit:closestCornerUnit animated:animated];
    }
}

- (void)videoView:(id<RTC_OBJC_TYPE(RTCVideoRenderer)>)videoView didChangeVideoSize:(CGSize)size {
    
    CGRect bounds = self.bounds;
    if (size.width > 0 && size.height > 0) {
        CGRect remoteVideoFrame = AVMakeRectWithAspectRatioInsideRect(size, bounds);
        CGFloat scale = 1;
        if (remoteVideoFrame.size.width < bounds.size.width) {
            scale = MAX(1, bounds.size.width / remoteVideoFrame.size.width);
        }
        if (remoteVideoFrame.size.height < bounds.size.height) {
            scale = MAX(1, bounds.size.height / remoteVideoFrame.size.height);
        }
        remoteVideoFrame.size.height *= scale;
        remoteVideoFrame.size.width *= scale;
        self.remoteVideoView.frame = remoteVideoFrame;
        self.remoteVideoView.center = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
    } else {
        self.remoteVideoView.frame = bounds;
    }
}

- (void)dispose {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
    if (self.participant) {
        [self.participant detachRenderer];
        self.participant = nil;
    }
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

@end

