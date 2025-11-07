/*
 *  Copyright (c) 2022-2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 *   Stephane Carrez (Stephane.Carrez@twin.life)
 */

#import <CocoaLumberjack.h>

#import <WebRTC/RTCVideoTrack.h>
#import <WebRTC/RTCEAGLVideoView.h>
#import <WebRTC/RTCMTLVideoView.h>

#import <Twinme/TLCapabilities.h>

#import <Utils/NSString+Utils.h>

#import "CallParticipantRemoteView.h"
#import <TwinmeCommon/CallViewController.h>

#import <TwinmeCommon/CallParticipant.h>

#import <TwinmeCommon/ApplicationDelegate.h>
#import <TwinmeCommon/TwinmeApplication.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

#define ZOOM_MAX 5

//
// Interface: CallParticipantRemoteView
//

@interface CallParticipantRemoteView ()<RTC_OBJC_TYPE(RTCVideoViewDelegate)>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cancelViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cancelViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cancelViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cancelViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet UIView *cancelView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cancelImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *cancelImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *noAvatarViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *noAvatarView;
@property (weak, nonatomic) IBOutlet UILabel *noAvatarLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *zoomLevelViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *zoomLevelViewBottomConstraint;
@property (weak, nonatomic) IBOutlet UIView *zoomLevelView;
@property (weak, nonatomic) IBOutlet UILabel *zoomLevelLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fullScreenViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fullScreenViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fullScreenViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *fullScreenView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fullScreenImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *fullScreenImageView;

@property (nonatomic) UIView *remoteVideoView; // Either a RTC_OBJC_TYPE(RTCMTLVideoView) or RTC_OBJC_TYPE(RTCEAGLVideoView)

@property (nonatomic) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic) UITapGestureRecognizer *doubleTapGestureRecognizer;

@property (nonatomic) BOOL isVideoInitialized;
@property (nonatomic) BOOL deferredMinZoom;

@property (nonatomic) CGFloat lastScale;
@property (nonatomic) CGFloat zoom;
@property (nonatomic) CGPoint lastPoint;

@end

//
// Implementation: CallParticipantRemoteView
//

#undef LOG_TAG
#define LOG_TAG @"CallParticipantRemoteView"

@implementation CallParticipantRemoteView

- (instancetype)init {
    DDLogVerbose(@"%@ init", LOG_TAG);
        
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"CallParticipantRemoteView" owner:self options:nil];
    self = [objects objectAtIndex:0];
            
    if (self) {
        self.lastScale = 1.0;
        self.zoom = 1.0;
        self.deferredMinZoom = NO;
        [self initViews];
    }
    return self;
}

- (BOOL)isRemoteParticipant {
    DDLogVerbose(@"%@ isRemoteParticipant", LOG_TAG);
    
    return YES;
}

- (BOOL)isCameraMute {
    
    return self.callParticipant.isVideoMute;
}

- (BOOL)isMessageSupported {
    DDLogVerbose(@"%@ isMessageSupported", LOG_TAG);
    
    return self.callParticipant.isMessageSupported == CallMessageSupportYes;
}

- (BOOL)isLocationSupported {
    DDLogVerbose(@"%@ isLocationSupported", LOG_TAG);
    
    return self.callParticipant.isGeolocationSupported == CallGeolocationSupportYes;
}

- (BOOL)isStreamingSupported {
    DDLogVerbose(@"%@ isStreamingSupported", LOG_TAG);
    
    return IS_STREAMING_SUPPORTED(self.callParticipant.streamingStatus);
}

- (BOOL)isRemoteCameraControl {
    DDLogVerbose(@"%@ isRemoteCameraControl", LOG_TAG);
    
    return [self.callParticipant isRemoteCameraControl];
}

- (BOOL)isZoomableSupported {
    DDLogVerbose(@"%@ isZoomableSupported", LOG_TAG);
    
    return self.callParticipant.isZoomable != TLVideoZoomableNever;
}

- (BOOL)isVideoInFitMode {
    DDLogVerbose(@"%@ isVideoInFitMode", LOG_TAG);
    
    if (self.fitVideoSize.width > 0 && self.fitVideoSize.height > 0) {
        if (roundf(self.fitVideoSize.width) == roundf(self.frame.size.width) && roundf(self.fitVideoSize.height) == roundf(self.frame.size.height)) {
            return YES;
        }
    }
    
    return NO;
}

- (NSString *)getName {
    DDLogVerbose(@"%@ getName", LOG_TAG);
    
    return self.callParticipant.name;
}

- (CallParticipant *)getCallParticipant {
    DDLogVerbose(@"%@ getCallParticipant", LOG_TAG);
    
    return self.callParticipant;
}

- (int)getParticipantId {
    DDLogVerbose(@"%@ getParticipantId", LOG_TAG);
    
    return self.callParticipant.participantId;
}

#pragma mark - RTCVideoViewDelegate

- (void)videoView:(id<RTC_OBJC_TYPE(RTCVideoRenderer)>)videoView didChangeVideoSize:(CGSize)size {
    DDLogVerbose(@"%@ videoView: %@ didChangeVideoSize: %@", LOG_TAG, videoView, NSStringFromCGSize(size));
    
    if ((UIView *)videoView == self.remoteVideoView) {
        dispatch_async(dispatch_get_main_queue(), ^(void){
            self.videoSize = size;
            [self updateViews];
        });
    }
}

- (void)updateVideoFrame {
    DDLogVerbose(@"%@ updateVideoFrame", LOG_TAG);
    
    CGRect bounds = self.bounds;
    if (self.videoSize.width > 0 && self.videoSize.height > 0) {
        CGRect remoteVideoFrame = AVMakeRectWithAspectRatioInsideRect(self.videoSize, bounds);
        self.fitVideoSize = remoteVideoFrame.size;
        CGFloat scale = 1;
        
        CGFloat maxWidth = self.bounds.size.width * self.zoom;
        CGFloat maxHeight = self.bounds.size.height * self.zoom;
        
        if (roundf(remoteVideoFrame.size.width) < roundf(maxWidth)) {
            scale = MAX(1, maxWidth / remoteVideoFrame.size.width);
        }
        if (roundf(remoteVideoFrame.size.height) < roundf(maxHeight)) {
            scale = MAX(1, maxHeight / remoteVideoFrame.size.height);
        }
        remoteVideoFrame.size.height *= scale;
        remoteVideoFrame.size.width *= scale;
                        
        self.remoteVideoView.frame = remoteVideoFrame;
        self.remoteVideoView.center = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
    } else {
        self.remoteVideoView.frame = bounds;
    }
}

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    [super initViews];
    
    self.isVideoInitialized = NO;
                
    self.tapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTapGesture:)];
    [self addGestureRecognizer:self.tapGestureRecognizer];
    
    UITapGestureRecognizer *infoTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleInfoTapGesture:)];
    [self.infoView addGestureRecognizer:infoTapGestureRecognizer];
    
    self.cancelViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.cancelViewBottomConstraint.constant *= Design.HEIGHT_RATIO;
    self.cancelViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.cancelViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    
    self.cancelView.userInteractionEnabled = YES;
    self.cancelView.hidden = YES;
    self.cancelView.clipsToBounds = YES;
    [self.cancelView setBackgroundColor:Design.BUTTON_RED_COLOR];
    self.cancelView.layer.cornerRadius = self.cancelViewHeightConstraint.constant * 0.5;
    
    self.cancelImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.cancelImageView.image = [self.cancelImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.cancelImageView setTintColor:[UIColor whiteColor]];
    
    UITapGestureRecognizer *cancelTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleCancelTapGesture:)];
    [self.cancelView addGestureRecognizer:cancelTapGestureRecognizer];
    
    self.noAvatarViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.noAvatarView.clipsToBounds = YES;
    self.noAvatarView.layer.cornerRadius = self.noAvatarViewHeightConstraint.constant * 0.5f;
    self.noAvatarView.hidden = YES;
    
    self.noAvatarLabel.textColor = [UIColor whiteColor];
    self.noAvatarLabel.font = Design.FONT_BOLD68;
    
    self.zoomLevelViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.zoomLevelViewBottomConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.zoomLevelView.clipsToBounds = YES;
    self.zoomLevelView.layer.cornerRadius = self.zoomLevelViewHeightConstraint.constant * 0.5f;
    self.zoomLevelView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.7];
    self.zoomLevelView.hidden = YES;
    
    self.zoomLevelLabel.font = Design.FONT_BOLD44;
    self.zoomLevelLabel.textColor = Design.ZOOM_COLOR;
    self.zoomLevelLabel.adjustsFontSizeToFitWidth = YES;
    self.zoomLevelLabel.hidden = YES;
    
    self.fullScreenViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.fullScreenViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.fullScreenViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.fullScreenView.backgroundColor = [UIColor whiteColor];
    self.fullScreenView.userInteractionEnabled = YES;
    self.fullScreenView.isAccessibilityElement = YES;
    self.fullScreenView.layer.shadowOpacity = Design.SHADOW_OPACITY;
    self.fullScreenView.layer.shadowOffset = Design.SHADOW_OFFSET;
    self.fullScreenView.layer.shadowRadius = Design.SHADOW_RADIUS;
    self.fullScreenView.layer.shadowColor = Design.SHADOW_COLOR_DEFAULT.CGColor;
    self.fullScreenView.layer.cornerRadius = self.fullScreenViewHeightConstraint.constant * 0.5;
    self.fullScreenView.layer.masksToBounds = NO;
    [self.fullScreenView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleFullScreenTapGesture:)]];
    
    self.fullScreenImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    UITapGestureRecognizer *switchCameraTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwitchCameraTapGesture:)];
    [self.switchCameraView addGestureRecognizer:switchCameraTapGestureRecognizer];
}

- (void)updateViews {
    DDLogVerbose(@"%@ updateViews", LOG_TAG);
    
    [super updateViews];
        
    if (!CALL_IS_ACTIVE(self.callStatus) && CALL_IS_OUTGOING(self.callStatus) && self.isVideoCall && self.nbParticipants == 2) {
        self.hidden = YES;
    } else {
        self.hidden = NO;
    }
    
    if (self.callParticipant.isVideoMute || (self.isVideoCall && !CALL_IS_ACTIVE(self.callStatus)) || CALL_IS_TERMINATED(self.callStatus)) {
        if (self.remoteVideoView) {
            self.remoteVideoView.hidden = YES;
        }
        
        if (self.callParticipant.avatar && (!self.isCallReceiver || !CALL_IS_ACTIVE(self.callStatus))) {
            self.noAvatarView.hidden = YES;
            self.avatarView.hidden = NO;
            self.avatarView.image = self.callParticipant.avatar;
        } else {
            self.noAvatarView.hidden = NO;
            self.avatarView.hidden = YES;
            if (self.color) {
                self.noAvatarView.backgroundColor = self.color;
            }
            self.noAvatarLabel.text = [NSString firstCharacter:self.callParticipant.name];
        }
        
        self.switchCameraView.hidden = YES;
    } else {
        if (!self.remoteVideoView) {
            CGRect remoteVideoFrame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);

            // Use MetalKit on recent devices and GLKit on old ones.
            RTC_OBJC_TYPE(RTCMTLVideoView) *remoteVideoView = [[RTC_OBJC_TYPE(RTCMTLVideoView) alloc] initWithFrame:remoteVideoFrame];
            if ([remoteVideoView isConfigured]) {
                remoteVideoView.delegate = self;
                self.remoteVideoView = remoteVideoView;
            } else {
                DDLogError(@"%@ MetalKit video view creation failed (fallback to RTCEAGLVideoView)", LOG_TAG);
            }

            // Fallback to EAGL video view if MetalKit failed.
            if (!self.remoteVideoView) {
                RTC_OBJC_TYPE(RTCEAGLVideoView) *remoteVideoView = [[RTC_OBJC_TYPE(RTCEAGLVideoView) alloc] initWithFrame:remoteVideoFrame];
                remoteVideoView.delegate = self;
                self.remoteVideoView = remoteVideoView;
            }

            CALayer *remoteVideoViewLayer = self.remoteVideoView.layer;
            [remoteVideoViewLayer setMasksToBounds:YES];
            [remoteVideoViewLayer setCornerRadius:14];
            self.remoteVideoView.userInteractionEnabled = YES;
            self.remoteVideoView.hidden = YES;
            self.remoteVideoView.clipsToBounds = YES;
            [self insertSubview:self.remoteVideoView atIndex:0];
            [self.callParticipant attachWithRenderer:(id<RTC_OBJC_TYPE(RTCVideoRenderer)>)self.remoteVideoView];

            self.doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleDoubleTapGesture:)];
            self.doubleTapGestureRecognizer.numberOfTapsRequired = 2;
            [self.remoteVideoView addGestureRecognizer:self.doubleTapGestureRecognizer];
            
            [self.tapGestureRecognizer requireGestureRecognizerToFail:self.doubleTapGestureRecognizer];
            
            UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(didPinchVideo:)];
            [self.remoteVideoView addGestureRecognizer:pinchGestureRecognizer];
            
            [self bringSubviewToFront:self.nameView];
        } else {
            [self.callParticipant attachWithRenderer:(id<RTC_OBJC_TYPE(RTCVideoRenderer)>)self.remoteVideoView];
            [self updateVideoFrame];
        }
        
        self.remoteVideoView.hidden = NO;
        self.avatarView.hidden = YES;
        self.noAvatarView.hidden = YES;
        
        if (CALL_IS_ACTIVE(self.callParticipant.callStatus) && [self.callParticipant remoteActiveCamera] > 0) {
            self.switchCameraView.hidden = NO;
        } else {
            self.switchCameraView.hidden = YES;
        }
    }
    
    if (self.callParticipant.isAudioMute && CALL_IS_ACTIVE(self.callParticipant.callStatus)) {
        self.microMuteView.hidden = NO;
    } else {
        self.microMuteView.hidden = YES;
    }
    
    if (CALL_IS_ON_HOLD(self.callStatus) || CALL_IS_ON_HOLD(self.callParticipant.callStatus)) {
        self.pauseView.hidden = NO;
        self.overlayView.hidden = NO;
    } else {
        self.pauseView.hidden = YES;
        self.overlayView.hidden = YES;
    }
    
    if (self.callParticipant.currentGeolocation && CALL_IS_ACTIVE(self.callParticipant.callStatus)) {
        self.locationView.hidden = NO;
    } else {
        self.locationView.hidden = YES;
    }
    
    // The info must be displayed only if we are sure the participant does not support group calls.
    if ([self.callParticipant isGroupSupported] == CallGroupSupportNo && self.nbParticipants > 2 && CALL_IS_ACTIVE(self.callParticipant.callStatus)) {
        self.infoView.hidden = NO;
    } else {
        self.infoView.hidden = YES;
    }
    
    if (self.nbParticipants > 2 && !CALL_IS_ACTIVE(self.callParticipant.callStatus)) {
        self.cancelView.hidden = NO;
        self.nameViewLeadingConstraint.constant = (self.nameViewTrailingConstraint.constant * 2) + self.cancelViewWidthConstraint.constant;
    } else {
        self.cancelView.hidden = YES;
        self.nameViewLeadingConstraint.constant = self.nameViewTrailingConstraint.constant;
    }
    
    if (self.callParticipant.isScreenSharing && CALL_IS_ACTIVE(self.callParticipant.callStatus)) {
        self.fullScreenView.hidden = NO;
    } else {
        self.fullScreenView.hidden = YES;
    }
    
    if (self.callParticipantViewAspect == CallParticipantViewAspectFullScreen) {
        self.fullScreenImageView.image = [UIImage imageNamed:@"MinimizeIcon"];
    } else {
        self.fullScreenImageView.image = [UIImage imageNamed:@"FullScreenIcon"];
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
    
    ApplicationDelegate *delegate = (ApplicationDelegate *)[[UIApplication sharedApplication] delegate];
    TwinmeApplication *twinmeApplication = [delegate twinmeApplication];
    if ([twinmeApplication isVideoInFitMode] && self.nbParticipants == 2 && self.isVideoCall && !self.isVideoInitialized && self.fitVideoSize.width > 0 && self.fitVideoSize.height > 0) {
        self.isVideoInitialized = YES;
        self.frame = CGRectMake(self.parentViewWidth * 0.5 - self.fitVideoSize.width * 0.5, self.parentViewHeight * 0.5 - self.fitVideoSize.height * 0.5, self.fitVideoSize.width, self.fitVideoSize.height);
        [self updateVideoFrame];
    }
    
    if (self.deferredMinZoom) {
        [self minZoom];
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
            if (self.nbParticipants == 2) {
                self.isVideoInitialized = NO;
            }
            [self.delegate didTapCallParticipantView:self];
        }
    }
}

- (void)handleInfoTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleInfoTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didTapInfoCallParticipantView:)]) {
            [self.delegate didTapInfoCallParticipantView:self];
        }
    }
}

- (void)handleCancelTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleCancelTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didTapCancelCallParticipantView:)]) {
            [self.delegate didTapCancelCallParticipantView:self];
        }
    }
}

- (void)handleFullScreenTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleFullScreenTapGesture: %@", LOG_TAG, sender);
        
    if (sender.state == UIGestureRecognizerStateEnded) {
        
        if (self.callParticipantViewAspect == CallParticipantViewAspectFullScreen) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(didTapMinimizeSharingScreenCallParticipantView:)]) {
                [self.delegate didTapMinimizeSharingScreenCallParticipantView:self];
            }
        } else {
            if (self.delegate && [self.delegate respondsToSelector:@selector(didTapFullScreenSharingScreenCallParticipantView:)]) {
                [self.delegate didTapFullScreenSharingScreenCallParticipantView:self];
            }
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
    
    if ([self.callParticipant remoteActiveCamera] > 0) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didPinchRemoteVideo:gestureState:)]) {
            CGFloat scale = pinchGestureRecognizer.scale;
            CGFloat value = 1;
            
            if (pinchGestureRecognizer.state == UIGestureRecognizerStateBegan) {
                if (scale >= 1.0) {
                    value = 1.0;
                } else {
                    value = -1.0;
                }
            } else {
                if (scale >= self.lastScale) {
                    value = 1.0;
                } else {
                    value = -1.0;
                }
            }
            
            self.lastScale = scale;
            [self.delegate didPinchRemoteVideo:value gestureState:pinchGestureRecognizer.state];
        }
        
        return;
    }
    
    if (self.callParticipantViewAspect == CallParticipantViewAspectFullScreen || (self.nbParticipants == 2 && self.callParticipantViewMode == CallParticipantViewModeSmallLocale)) {

        if (CGSizeEqualToSize(CGSizeZero, self.fillVideoSize) || CGSizeEqualToSize(CGSizeZero, self.fitVideoSize)) {
            return;
        }
        
        [self bringSubviewToFront:self.zoomLevelView];
        [self bringSubviewToFront:self.zoomLevelLabel];
        
        if (pinchGestureRecognizer.state == UIGestureRecognizerStateBegan) {
            pinchGestureRecognizer.scale = self.zoom;
            [UIView animateWithDuration:0.3 delay:0. options: UIViewAnimationOptionCurveEaseIn animations:^{
                self.zoomLevelView.alpha = 1.0;
                self.zoomLevelLabel.alpha = 1.0;
            } completion:^(BOOL finished) {
                self.zoomLevelView.hidden = NO;
                self.zoomLevelLabel.hidden = NO;
            }];
        } else if (pinchGestureRecognizer.state == UIGestureRecognizerStateEnded) {
            [UIView animateWithDuration:0.5 delay:0. options: UIViewAnimationOptionCurveEaseIn animations:^{
                self.zoomLevelView.alpha = 0.0;
                self.zoomLevelLabel.alpha = 0.0;
            } completion:^(BOOL finished) {
                self.zoomLevelView.hidden = YES;
                self.zoomLevelLabel.hidden = YES;
            }];
        }
        
        CGFloat scale = pinchGestureRecognizer.scale;
        CGFloat scaleWidth = self.bounds.size.width * scale;
        CGFloat scaleHeight = self.bounds.size.height * scale;
        
        CGFloat maxWidth = self.fillVideoSize.width * ZOOM_MAX;
        CGFloat maxHeight = self.fillVideoSize.height * ZOOM_MAX;
        
        if (scaleWidth > self.fillVideoSize.width) {
            if (maxWidth < scaleWidth) {
                self.zoom = maxWidth /  self.fillVideoSize.width;
            } else {
                self.zoom = scaleWidth /  self.fillVideoSize.width;
            }
            scaleWidth = self.fillVideoSize.width;
        } else if (scaleWidth < self.fitVideoSize.width) {
            self.zoom = scaleWidth /  self.fillVideoSize.width;
            scaleWidth = self.fitVideoSize.width;
        }
        
        if (scaleHeight > self.fillVideoSize.height) {
            if (maxHeight < scaleHeight) {
                self.zoom = maxHeight /  self.fillVideoSize.height;
            } else {
                self.zoom = scaleHeight /  self.fillVideoSize.height;
            }
            scaleHeight = self.fillVideoSize.height;
        } else if (scaleHeight < self.fitVideoSize.height) {
            self.zoom = scaleHeight /  self.fillVideoSize.height;
            scaleHeight = self.fitVideoSize.height;
        }
        
        float zoomMin = self.fitVideoSize.height / self.fillVideoSize.height;
        if (self.zoom > ZOOM_MAX) {
            self.zoom = ZOOM_MAX;
        } else if (self.zoom < zoomMin) {
            self.zoom = zoomMin;
        }
        
        CGFloat zoomPercent = self.zoom * 100;
        self.zoomLevelLabel.text = [NSString stringWithFormat:@"%.0f%%", zoomPercent];
        
        if (isnan(scaleWidth) || isnan(scaleHeight)) {
            return;
        }
                        
        self.frame = CGRectMake(self.parentViewWidth * 0.5 - scaleWidth * 0.5, self.parentViewHeight * 0.5 - scaleHeight * 0.5, scaleWidth, scaleHeight);
        
        ApplicationDelegate *delegate = (ApplicationDelegate *)[[UIApplication sharedApplication] delegate];
        TwinmeApplication *twinmeApplication = [delegate twinmeApplication];
        if (self.nbParticipants == 2) {
            [twinmeApplication setIsVideoInFitMode:[self isVideoInFitMode]];
        }
        
        [self updateVideoFrame];
    }
}

- (void)minZoom {
    DDLogVerbose(@"%@ minZoom", LOG_TAG);
    
    CGRect bounds = self.bounds;
    if (self.fitVideoSize.height == 0 && self.videoSize.width > 0 && self.videoSize.height > 0) {
        CGRect remoteVideoFrame = AVMakeRectWithAspectRatioInsideRect(self.videoSize, bounds);
        self.fitVideoSize = remoteVideoFrame.size;
    }
    
    if (self.fitVideoSize.width == 0 || self.fitVideoSize.height == 0) {
        self.deferredMinZoom = YES;
        return;
    }
    
    self.deferredMinZoom = NO;
    
    if (self.fitVideoSize.width != 0 && self.fillVideoSize.height != 0) {
        self.zoom = self.fitVideoSize.height / self.fillVideoSize.height;
        
        self.frame = CGRectMake(self.parentViewWidth * 0.5 - self.fitVideoSize.width * 0.5, self.parentViewHeight * 0.5 - self.fitVideoSize.height * 0.5, self.fitVideoSize.width, self.fitVideoSize.height);

        [self updateVideoFrame];
    }
}

- (void)resetZoom {
    DDLogVerbose(@"%@ resetZoom", LOG_TAG);
    
    if (self.fillVideoSize.width != 0 && self.fillVideoSize.height != 0) {
        self.zoom = 1;
        
        self.frame = CGRectMake(self.parentViewWidth * 0.5 - self.fillVideoSize.width * 0.5, self.parentViewHeight * 0.5 - self.fillVideoSize.height * 0.5, self.fillVideoSize.width, self.fillVideoSize.height);

        [self updateVideoFrame];
    }
}

@end
