/*
 *  Copyright (c) 2022 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 *   Stephane Carrez (Stephane.Carrez@twin.life)
 */

#import <CocoaLumberjack.h>

#import "CallParticipantLocaleView.h"
#import <TwinmeCommon/CallViewController.h>

#import <WebRTC/RTCVideoRenderer.h>
#import <WebRTC/RTCEAGLVideoView.h>
#import <WebRTC/RTCMTLVideoView.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

#define DELAY_TRANSFORM 0.4

//
// Interface: CallParticipantLocaleView
//

@interface CallParticipantLocaleView()<RTC_OBJC_TYPE(RTCVideoViewDelegate)>

@property (nonatomic) UIView *localVideoView; // Either a RTC_OBJC_TYPE(RTCMTLVideoView) or RTC_OBJC_TYPE(RTCEAGLVideoView)

@property (nonatomic) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic) UITapGestureRecognizer *doubleTapGestureRecognizer;

@property (nonatomic) BOOL needTransformVideoView;

@end

//
// Implementation: CallParticipantLocaleView
//

#undef LOG_TAG
#define LOG_TAG @"CallParticipantLocaleView"

@implementation CallParticipantLocaleView

- (instancetype)init {
    DDLogVerbose(@"%@ init", LOG_TAG);
        
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"CallParticipantLocaleView" owner:self options:nil];
    self = [objects objectAtIndex:0];
            
    if (self) {
        self.isFrontCamera = YES;
        self.needTransformVideoView = YES;
        [self initViews];
    }
    return self;
}

- (BOOL)isRemoteParticipant {
    
    return NO;
}

- (BOOL)isCameraMute {
    
    return self.isVideoMute;
}

- (void)enableFrontCamera:(BOOL)frontCamera {
    
    if (self.isFrontCamera != frontCamera) {
        
        self.isFrontCamera = frontCamera;
        self.needTransformVideoView = YES;
    }
 }

- (NSString *)getName {
    DDLogVerbose(@"%@ getName", LOG_TAG);
    
    return self.name;
}

#pragma mark - RTCVideoViewDelegate

- (void)videoView:(id<RTC_OBJC_TYPE(RTCVideoRenderer)>)videoView didChangeVideoSize:(CGSize)size {
    DDLogVerbose(@"%@ videoView: %@ didChangeVideoSize: %@", LOG_TAG, videoView, NSStringFromCGSize(size));
    
    if ((UIView *)videoView == self.localVideoView) {
        dispatch_async(dispatch_get_main_queue(), ^(void){
            self.videoSize = size;
            [self updateVideoFrame];
        });
    }
}

- (void)updateVideoFrame {
    DDLogVerbose(@"%@ updateVideoFrame", LOG_TAG);
    
    CGRect bounds = self.bounds;
    if (self.videoSize.width > 0 && self.videoSize.height > 0) {
        CGRect localVideoFrame = AVMakeRectWithAspectRatioInsideRect(self.videoSize, bounds);
        CGFloat scale = 1;
        if (roundf(localVideoFrame.size.width) < roundf(bounds.size.width)) {
            scale = MAX(1, bounds.size.width / localVideoFrame.size.width);
        }
        if (roundf(localVideoFrame.size.height) < roundf(bounds.size.height)) {
            scale = MAX(1, bounds.size.height / localVideoFrame.size.height);
        }
        localVideoFrame.size.height *= scale;
        localVideoFrame.size.width *= scale;
        self.localVideoView.frame = localVideoFrame;
        self.localVideoView.center =
        CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
    } else {
        self.localVideoView.frame = bounds;
    }
}

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    [super initViews];
    
    self.tapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTapGesture:)];
    [self addGestureRecognizer:self.tapGestureRecognizer];
    
    UITapGestureRecognizer *switchCameraTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwitchCameraTapGesture:)];
    [self.switchCameraView addGestureRecognizer:switchCameraTapGestureRecognizer];
}

- (void)updateViews {
    DDLogVerbose(@"%@ updateViews", LOG_TAG);
    
    [super updateViews];
    
    if (((CALL_IS_OUTGOING(self.callStatus) || CALL_IS_ACTIVE(self.callStatus)) && self.isVideoCall && self.nbParticipants == 2) || self.nbParticipants > 2) {
        self.hidden = NO;
    } else {
        self.hidden = YES;
    }
    
    if (self.isVideoMute || CALL_IS_TERMINATED(self.callStatus) || CALL_IS_ON_HOLD(self.callStatus)) {
        if (self.localVideoView) {
            self.localVideoView.hidden = YES;
        }
        self.switchCameraView.hidden = YES;
        self.avatarView.hidden = NO;
        self.avatarView.image = self.avatar;
    } else {
        if (!self.localVideoView) {
            CGRect localVideoFrame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);

            // Use MetalKit on recent devices and GLKit on old ones.
            RTC_OBJC_TYPE(RTCMTLVideoView) *localVideoView = [[RTC_OBJC_TYPE(RTCMTLVideoView) alloc] initWithFrame:localVideoFrame];
            if ([localVideoView isConfigured]) {
                localVideoView.delegate = self;
                self.localVideoView = localVideoView;
            } else {
                DDLogError(@"%@ MetalKit video view creation failed (fallback to RTCEAGLVideoView)", LOG_TAG);
            }

            // Fallback to EAGL video view if MetalKit failed.
            if (!self.localVideoView) {
                RTC_OBJC_TYPE(RTCEAGLVideoView) *localVideoView = [[RTC_OBJC_TYPE(RTCEAGLVideoView) alloc] initWithFrame:localVideoFrame];

                localVideoView.delegate = self;
                self.localVideoView = localVideoView;
            }
            CALayer *localVideoViewLayer = self.localVideoView.layer;
            [localVideoViewLayer setMasksToBounds:YES];
            [localVideoViewLayer setCornerRadius:14];
            self.localVideoView.userInteractionEnabled = YES;
            [self insertSubview:self.localVideoView atIndex:0];
            
            [self setLocalVideoTrackRenderer];
            self.doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleDoubleTapGesture:)];
            self.doubleTapGestureRecognizer.numberOfTapsRequired = 2;
            [self.localVideoView addGestureRecognizer:self.doubleTapGestureRecognizer];
            
            [self.tapGestureRecognizer requireGestureRecognizerToFail:self.doubleTapGestureRecognizer];
            
            UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(didPinchVideo:)];
            [self.localVideoView addGestureRecognizer:pinchGestureRecognizer];
            
            [self bringSubviewToFront:self.nameView];
        } else if (self.localVideoTrack) {
            [self setLocalVideoTrackRenderer];
            [self updateVideoFrame];
        }
        ((RTC_OBJC_TYPE(RTCMTLVideoView) *)self.localVideoView).enabled = YES;
        
        self.localVideoView.hidden = NO;
        self.switchCameraView.hidden = NO;
        self.avatarView.hidden = YES;
    }
    
    if (self.isAudioMute) {
        self.microMuteView.hidden = NO;
    } else {
        self.microMuteView.hidden = YES;
    }
    
    if (CALL_IS_ON_HOLD(self.callStatus)) {
        self.pauseView.hidden = NO;
        self.overlayView.hidden = NO;
    } else {
        self.pauseView.hidden = YES;
        self.overlayView.hidden = YES;
    }
    
    CGFloat constraintValue = self.switchCameraBottomConstraint.constant;
    if (!self.nameView.hidden && !self.switchCameraView.hidden) {
        if (self.nameView.frame.origin.x < (self.switchCameraView.frame.origin.x * 2 + self.switchCameraView.frame.size.width)) {
            self.switchCameraBottomConstraint.constant = self.nameViewBottomConstraint.constant * 2 + self.nameViewHeightConstraint.constant;
        } else {
            self.switchCameraBottomConstraint.constant = self.nameViewBottomConstraint.constant;
        }
    } else {
        self.switchCameraBottomConstraint.constant = self.nameViewBottomConstraint.constant;
    }
    
    if (constraintValue != self.switchCameraBottomConstraint.constant && !self.switchCameraView.hidden) {
        [UIView animateWithDuration:0.5 animations:^{
            [self layoutIfNeeded];
        } completion:^(BOOL finished) {
        }];
    }
}

- (void)setLocalVideoTrackRenderer {
    if (self.localVideoView && self.localVideoTrack) {
        if (self.isFrontCamera) {
            self.localVideoView.transform = CGAffineTransformMakeScale(-1.0, 1.0);
        } else {
            self.localVideoView.transform = CGAffineTransformIdentity;
        }
        [self.localVideoTrack addRenderer:(id<RTC_OBJC_TYPE(RTCVideoRenderer)>)self.localVideoView];
    }
}

- (void)handleDoubleTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleDoubleTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didDoubleTapCallParticipantView:)]) {
            [self.delegate didDoubleTapCallParticipantView:self];
        }
    }
}

- (void)handleTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didTapCallParticipantView:)]) {
            [self.delegate didTapCallParticipantView:self];
        }
    }
}

- (void)handleSwitchCameraTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleSwitchCameraTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didTapSwitchCameraCallParticipantView:)]) {
            [self.delegate didTapSwitchCameraCallParticipantView:self];
        }
    }
}

- (void)didPinchVideo:(UIPinchGestureRecognizer *)pinchGestureRecognizer {
    DDLogVerbose(@"%@ didPinchVideo: %@", LOG_TAG, pinchGestureRecognizer);
    
    if (self.callParticipantViewAspect == CallParticipantViewAspectFullScreen || (self.nbParticipants == 2 && self.callParticipantViewMode == CallParticipantViewModeSmallRemote)) {
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(didPinchLocaleVideo:gestureState:)]) {
            CGFloat scale = pinchGestureRecognizer.scale;
            CGFloat value = -0.1;
            if (scale >= 1) {
                value = 0.1;
            }
            [self.delegate didPinchLocaleVideo:value gestureState:pinchGestureRecognizer.state];
        }
        
    }
}

- (void)minZoom {
    DDLogVerbose(@"%@ minZoom", LOG_TAG);
}

- (void)resetZoom {
    DDLogVerbose(@"%@ resetZoom", LOG_TAG);
}

@end
