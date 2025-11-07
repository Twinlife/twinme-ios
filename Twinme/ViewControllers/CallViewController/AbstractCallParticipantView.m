/*
 *  Copyright (c) 2022 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <WebRTC/RTCVideoTrack.h>
#import <WebRTC/RTCEAGLVideoView.h>

#import "AbstractCallParticipantView.h"

#import <TwinmeCommon/CallViewController.h>

#import <TwinmeCommon/Design.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

#define DESIGN_BACKGROUND_COLOR [UIColor colorWithRed:60./255. green:60./255. blue:60./255. alpha:1]

static const CGFloat DESIGN_CORNER_RADIUS = 14;
static const CGFloat DESIGN_MARGIN_PARTICIPANT = 34;
static const CGFloat DESIGN_THUMBNAIL_PARTICIPANT_WIDTH = 220;
static const CGFloat DESIGN_THUMBNAIL_PARTICIPANT_HEIGHT = 280;
static CGFloat MARGIN_PARTICIPANT;
static CGFloat THUMBNAIL_PARTICIPANT_WIDTH;
static CGFloat THUMBNAIL_PARTICIPANT_HEIGHT;

//
// Interface: AbstractCallParticipantView
//

@interface AbstractCallParticipantView ()

@property int position;

@property CGFloat x;
@property CGFloat y;
@property CGFloat width;
@property CGFloat height;
@property CGFloat mainParticipantWidth;
@property CGFloat mainParticipantHeight;

@property BOOL isDraggable;
@property CGPoint lastClosestCornerUnit;

@property BOOL hideName;

@end

//
// Implementation: AbstractCallParticipantView
//

#undef LOG_TAG
#define LOG_TAG @"AbstractCallParticipantView"

@implementation AbstractCallParticipantView

- (void)minZoom {
    DDLogVerbose(@"%@ minZoom", LOG_TAG);
}

- (void)resetZoom {
    DDLogVerbose(@"%@ resetZoom", LOG_TAG);
}


- (BOOL)isRemoteParticipant {
    DDLogVerbose(@"%@ isRemoteParticipant", LOG_TAG);
    
    return NO;
}

- (BOOL)isMessageSupported {
    DDLogVerbose(@"%@ isMessageSupported", LOG_TAG);
    
    return NO;
}

- (BOOL)isStreamingSupported {
    DDLogVerbose(@"%@ isStreamingSupported", LOG_TAG);
    
    return NO;
}

- (BOOL)isZoomableSupported {
    DDLogVerbose(@"%@ isZoomableSupported", LOG_TAG);
    
    return NO;
}

- (BOOL)isCameraMute {
    DDLogVerbose(@"%@ isCameraMute", LOG_TAG);
    
    return YES;
}


- (BOOL)isRemoteCameraControl {
    DDLogVerbose(@"%@ isRemoteCameraControl", LOG_TAG);
    
    return NO;
}

- (NSString *)getName {
    DDLogVerbose(@"%@ getName", LOG_TAG);
    
    return nil;
}

- (CallParticipant *)getCallParticipant {
    DDLogVerbose(@"%@ getCallParticipant", LOG_TAG);
    
    return nil;
}

- (int)getParticipantId {
    DDLogVerbose(@"%@ getParticipantId", LOG_TAG);
    
    return -1;
}

- (void)setPosition:(BOOL)isMainParticipant parentViewWidth:(float)parentViewWidth parentViewHeight:(float)parentViewHeight numberParticipants:(int)numberParticipants position:(int)position hideName:(BOOL)hideName isLandscape:(BOOL)isLandscape {
    DDLogVerbose(@"%@ setPosition: %@ parentViewHeight: %f numberParticipants: %d position: %d hideName: %@ isLandscape: %@", LOG_TAG, isMainParticipant ? @"YES":@"NO", parentViewHeight, numberParticipants, position, hideName ? @"YES":@"NO", isLandscape ? @"YES":@"NO");
    
    BOOL orientationChanged = self.isLandscape != isLandscape;
    
    self.parentViewWidth = parentViewWidth;
    self.parentViewHeight = parentViewHeight;
        
    self.nbParticipants = numberParticipants;
    
    self.position = position;
    self.isLandscape = isLandscape;
    
    self.mainParticipantWidth = [self getMainParticipantWidth];
    self.mainParticipantHeight = [self getMainParticipantHeight];
    
    self.hideName = hideName;
    
    if (!CALL_IS_TERMINATED(self.callStatus)) {
        self.mainParticipant = isMainParticipant;
    }
    
    CGFloat participantWidth = 0;
    CGFloat participantHeight = 0;
    CGFloat participantX = 0;
    CGFloat participantY = 0;
    if ([self isMainParticipant]) {
        participantWidth = self.mainParticipantWidth;
        participantHeight = self.mainParticipantHeight;
        if (self.isLandscape) {
            if (!CALL_IS_ACTIVE(self.callStatus) && self.nbParticipants == 2) {
                participantX = (parentViewWidth * 0.5) - (participantWidth * 0.5);
            } else {
                participantX = 0;
            }
        } else {
            participantX = MARGIN_PARTICIPANT;
        }
        if ((!self.isVideoCall || !CALL_IS_ACTIVE(self.callStatus)) && self.nbParticipants == 2) {
            participantY = (parentViewHeight * 0.5) - (participantHeight * 0.5);
        } else {
            participantY = 0;
        }
    } else {
        participantWidth = [self getParticipantWidth];
        participantHeight = [self getParticipantHeight];
        participantX = [self getParticipantX:participantWidth];
        participantY = [self getParticipantY:participantHeight];
    }
        
    if (self.width != participantWidth || self.height != participantHeight || self.x != participantX || self.y != participantY) {
        self.width = participantWidth;
        self.height = participantHeight;
        self.x = participantX;
        self.y = participantY;
        
        self.frame = CGRectMake(self.x, self.y, self.width, self.height);
    }
        
    if (self.nbParticipants == 2 && !self.isCallReceiver) {
        self.nameView.hidden = YES;
    } else {
        self.nameView.hidden = hideName;
    }
    
    if (self.nbParticipants == 2 && CALL_IS_ACTIVE(self.callStatus) && self.isVideoCall && self.callParticipantViewMode != CallParticipantViewModeSplitScreen && ![self isMainParticipant]) {
        self.isDraggable = YES;
    } else {
        self.isDraggable = NO;
    }
    
    if (self.isDraggable && (self.lastClosestCornerUnit.y != 0 || orientationChanged)) {
        if (self.lastClosestCornerUnit.y == 0) {
            self.lastClosestCornerUnit = [self closestCornerUnit];
        }
        [self moveToCornerUnit:self.lastClosestCornerUnit animated:NO];
    }
    
    if (self.nbParticipants == 2 && self.isVideoCall && self.callParticipantViewMode == CallParticipantViewModeSmallLocale && self.isRemoteParticipant) {
        self.fillVideoSize = self.frame.size;
    }
    
    [self updateViews];
}

- (BOOL)isMainParticipant {
    DDLogVerbose(@"%@ isMainParticipant", LOG_TAG);
    
    if (self.isVideoCall && self.nbParticipants == 2 && self.callParticipantViewMode != CallParticipantViewModeSplitScreen) {
        if ([self isRemoteParticipant] && self.callParticipantViewMode == CallParticipantViewModeSmallLocale) {
            return YES;
        } else if (![self isRemoteParticipant] && self.callParticipantViewMode == CallParticipantViewModeSmallRemote) {
            return YES;
        }
        
        return NO;
    }
    return self.mainParticipant;
}

- (void)updateCallParticipantViewAspect {
    DDLogVerbose(@"%@ updateCallParticipantViewAspect", LOG_TAG);
    
    [UIView animateWithDuration:0.5 delay:0.0 usingSpringWithDamping:0.6 initialSpringVelocity:1.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        if (self.callParticipantViewAspect == CallParticipantViewAspectFit) {
            self.callParticipantViewAspect = CallParticipantViewAspectFullScreen;
            
            if (self.isLandscape) {
                self.frame = CGRectMake(0, 0, self.parentViewWidth, self.parentViewHeight);
            } else {
                self.frame = CGRectMake(MARGIN_PARTICIPANT, 0, Design.DISPLAY_WIDTH - (MARGIN_PARTICIPANT * 2), self.parentViewHeight);
            }
            
            self.fillVideoSize = self.frame.size;
            if (self.videoSize.width > 0 && self.videoSize.height > 0) {
                CGRect videoFrame = AVMakeRectWithAspectRatioInsideRect(self.videoSize, self.frame);
                self.fitVideoSize = videoFrame.size;
            }
        } else {
            self.callParticipantViewAspect = CallParticipantViewAspectFit;
            self.frame = CGRectMake(self.x, self.y, self.width, self.height);
        }
        
        [self updateViews];
    } completion:^(BOOL finished) {
    }];
}

- (CGFloat)getMainParticipantWidth {
    DDLogVerbose(@"%@ getMainParticipantWidth", LOG_TAG);
    
    if (self.isLandscape) {
        return [self getLandscapeMainParticipantWidth];
    }
    
    return [self getPortraitMainParticipantWidth];
}

- (CGFloat)getPortraitMainParticipantWidth {
    DDLogVerbose(@"%@ getPortraitMainParticipantWidth", LOG_TAG);
    
    if (self.nbParticipants != 2 && self.nbParticipants % 2 == 0) {
        return (Design.DISPLAY_WIDTH - (MARGIN_PARTICIPANT * 3)) * 0.5f ;
    }

    return Design.DISPLAY_WIDTH - (MARGIN_PARTICIPANT * 2);
}

- (CGFloat)getLandscapeMainParticipantWidth {
    DDLogVerbose(@"%@ getLandscapeMainParticipantWidth", LOG_TAG);
    
    if (self.nbParticipants == 2 && self.isVideoCall && CALL_IS_ACTIVE(self.callStatus) && self.callParticipantViewMode != CallParticipantViewModeSplitScreen) {
        return self.parentViewWidth;
    } else if (self.nbParticipants == 2) {
        return (self.parentViewWidth - MARGIN_PARTICIPANT) * 0.5f;
    } else if (self.nbParticipants == 3 || self.nbParticipants == 6) {
        return (self.parentViewWidth - (MARGIN_PARTICIPANT * 2)) / 3.f;
    } else if (self.nbParticipants == 5) {
        return (self.parentViewWidth - (MARGIN_PARTICIPANT * 2)) * 0.5f;
    } else if (self.nbParticipants == 4 || self.nbParticipants == 7 || self.nbParticipants == 8) {
        return (self.parentViewWidth - (MARGIN_PARTICIPANT * 3)) * 0.25f;
    }
    
    return self.parentViewWidth;
}

- (CGFloat)getMainParticipantHeight {
    DDLogVerbose(@"%@ getMainParticipantHeight", LOG_TAG);

    if (self.isLandscape) {
        return [self getLandscapeMainParticipantHeight];
    }
    
    return [self getPortraitMainParticipantHeight];
}

- (CGFloat)getPortraitMainParticipantHeight {
    DDLogVerbose(@"%@ getPortraitMainParticipantHeight", LOG_TAG);

    if (self.nbParticipants == 2 && self.isVideoCall && CALL_IS_ACTIVE(self.callStatus) && self.callParticipantViewMode != CallParticipantViewModeSplitScreen) {
        return self.parentViewHeight;
    } else if (self.nbParticipants == 2 || self.nbParticipants == 4) {
        return (self.parentViewHeight - MARGIN_PARTICIPANT) * 0.5f;
    } else if (self.nbParticipants == 3) {
        return (self.parentViewHeight - MARGIN_PARTICIPANT) * 0.67f;
    } else if (self.nbParticipants == 5 || self.nbParticipants == 6) {
        return (self.parentViewHeight - (MARGIN_PARTICIPANT * 2)) / 3.f;
    }

    return (self.parentViewHeight - (MARGIN_PARTICIPANT * 3)) / 4.f;
}

- (CGFloat)getLandscapeMainParticipantHeight {
    DDLogVerbose(@"%@ getLandscapeMainParticipantHeight", LOG_TAG);

    if (self.nbParticipants == 6 || self.nbParticipants == 8) {
        return (self.parentViewHeight - MARGIN_PARTICIPANT) * 0.5f;
    }

    return self.parentViewHeight;
}

- (CGFloat)getParticipantWidth {
    DDLogVerbose(@"%@ getParticipantWidth", LOG_TAG);
    
    if (self.isLandscape) {
        return [self getLandscapeParticipantWidth];
    }
    
    return [self getPortraitParticipantWidth];
}

- (CGFloat)getPortraitParticipantWidth {
    DDLogVerbose(@"%@ getPortraitParticipantWidth", LOG_TAG);
    
    if (self.nbParticipants == 2 && self.isVideoCall && CALL_IS_ACTIVE(self.callStatus) && self.callParticipantViewMode != CallParticipantViewModeSplitScreen) {
        return THUMBNAIL_PARTICIPANT_WIDTH;
    } else if (self.nbParticipants == 2) {
        return [self getMainParticipantWidth];
    }

    return (Design.DISPLAY_WIDTH - (MARGIN_PARTICIPANT * 3)) * 0.5f;
}

- (CGFloat)getLandscapeParticipantWidth {
    DDLogVerbose(@"%@ getLandscapeParticipantWidth", LOG_TAG);
    
    if (self.nbParticipants == 2 && self.isVideoCall && CALL_IS_ACTIVE(self.callStatus) && self.callParticipantViewMode != CallParticipantViewModeSplitScreen) {
        return THUMBNAIL_PARTICIPANT_WIDTH;
    } else if (self.nbParticipants % 2 == 0 || self.nbParticipants == 3 || self.nbParticipants == 7) {
        return [self getMainParticipantWidth];
    } else {
        return (self.parentViewWidth - self.mainParticipantWidth - (MARGIN_PARTICIPANT * 2)) * 0.5;
    }
}

- (CGFloat)getParticipantHeight {
    DDLogVerbose(@"%@ getParticipantHeight", LOG_TAG);
    
    if (self.isLandscape) {
        return [self getLandscapeParticipantHeight];
    }
    
    return [self getPortraitParticipantHeight];
}

- (CGFloat)getPortraitParticipantHeight {
    DDLogVerbose(@"%@ getPortraitParticipantHeight", LOG_TAG);
    
    if (self.nbParticipants == 2 && self.isVideoCall && CALL_IS_ACTIVE(self.callStatus) && self.callParticipantViewMode != CallParticipantViewModeSplitScreen) {
        return THUMBNAIL_PARTICIPANT_HEIGHT;
    } else if (self.isVideoCall && !CALL_IS_ACTIVE(self.callStatus) && self.nbParticipants == 2) {
        return self.parentViewHeight;
    } else if (self.nbParticipants == 3) {
        return (self.parentViewHeight - MARGIN_PARTICIPANT) * 0.33f;
    }

    return [self getMainParticipantHeight];
}

- (CGFloat)getLandscapeParticipantHeight {
    DDLogVerbose(@"%@ getLandscapeParticipantHeight", LOG_TAG);
    
    if (self.nbParticipants == 2 && self.isVideoCall && CALL_IS_ACTIVE(self.callStatus) && self.callParticipantViewMode != CallParticipantViewModeSplitScreen) {
        return THUMBNAIL_PARTICIPANT_HEIGHT;
    } else if (self.isVideoCall && !CALL_IS_ACTIVE(self.callStatus) && self.nbParticipants == 2) {
        return self.parentViewHeight;
    } else if (self.nbParticipants > 4) {
        return (self.parentViewHeight - MARGIN_PARTICIPANT) * 0.5f;
    }

    return [self getMainParticipantHeight];
}

- (CGFloat)getParticipantX:(CGFloat)participantWidth {
    DDLogVerbose(@"%@ getParticipantX", LOG_TAG);
    
    if (self.isLandscape) {
        return [self getLandscapeParticipantX:participantWidth];
    }
    
    return [self getPortraitParticipantX:participantWidth];
}

- (CGFloat)getPortraitParticipantX:(CGFloat)participantWidth {
    DDLogVerbose(@"%@ getPortraitParticipantX", LOG_TAG);
    
    if (self.nbParticipants == 2 && self.isVideoCall && CALL_IS_ACTIVE(self.callStatus) && self.callParticipantViewMode != CallParticipantViewModeSplitScreen) {
        return Design.DISPLAY_WIDTH - (MARGIN_PARTICIPANT * 2) - participantWidth;
    } else if (self.nbParticipants == 2) {
        return MARGIN_PARTICIPANT;
    } else if (self.nbParticipants % 2 != 0) {
        if (self.position % 2 == 0) {
            return MARGIN_PARTICIPANT;
        } else {
            return participantWidth + (MARGIN_PARTICIPANT * 2);
        }
    } else {
        if (self.position % 2 == 0) {
            return participantWidth + (MARGIN_PARTICIPANT * 2);
        } else {
            return MARGIN_PARTICIPANT;
        }
    }
}

- (CGFloat)getLandscapeParticipantX:(CGFloat)participantWidth {
    DDLogVerbose(@"%@ getLandscapeParticipantX", LOG_TAG);
    
    if (self.nbParticipants == 2 && self.isVideoCall && CALL_IS_ACTIVE(self.callStatus) && self.callParticipantViewMode != CallParticipantViewModeSplitScreen) {
        return self.parentViewWidth - (MARGIN_PARTICIPANT * 2) - participantWidth;
    } else if (self.nbParticipants == 2) {
        return self.mainParticipantWidth + MARGIN_PARTICIPANT;
    } else if (self.nbParticipants == 3) {
        if (self.position == 2) {
            return self.mainParticipantWidth + MARGIN_PARTICIPANT;
        } else {
            return self.mainParticipantWidth + participantWidth + (MARGIN_PARTICIPANT * 2);
        }
    } else if (self.nbParticipants == 4 || self.nbParticipants == 8) {
        return (self.mainParticipantWidth * (self.position - 1))  + (MARGIN_PARTICIPANT * (self.position - 1));
    } else if (self.nbParticipants == 5) {
        if (self.position == 2 || self.position == 4) {
            return self.mainParticipantWidth + MARGIN_PARTICIPANT;
        } else {
            return self.mainParticipantWidth + participantWidth + (MARGIN_PARTICIPANT * 2);
        }
    } else if (self.nbParticipants == 6) {
        if (self.position == 2 || self.position == 5) {
            return self.mainParticipantWidth + MARGIN_PARTICIPANT;
        } else if (self.position == 3 || self.position == 6) {
            return (self.mainParticipantWidth * 2) + (MARGIN_PARTICIPANT * 2);
        }
    } else if (self.nbParticipants == 7) {
        if (self.position == 2 || self.position == 5) {
            return self.mainParticipantWidth + MARGIN_PARTICIPANT;
        } else if (self.position == 3 || self.position == 6) {
            return (self.mainParticipantWidth * 2) + (MARGIN_PARTICIPANT * 2);
        } else {
            return (self.mainParticipantWidth * 3) + (MARGIN_PARTICIPANT * 3);
        }
    }
    
    return 0;
}

- (CGFloat)getParticipantY:(CGFloat)participantHeight {
    DDLogVerbose(@"%@ getParticipantY", LOG_TAG);
    
    if (self.isLandscape) {
        return [self getLandscapeParticipantY:participantHeight];
    }
    
    return [self getPortraitParticipantY:participantHeight];
}

- (CGFloat)getPortraitParticipantY:(CGFloat)participantHeight {
    DDLogVerbose(@"%@ getPortraitParticipantY", LOG_TAG);
    
    if (self.isVideoCall && !CALL_IS_ACTIVE(self.callStatus) && self.nbParticipants == 2) {
        return 0;
    } else if (self.nbParticipants == 2 && self.isVideoCall && CALL_IS_ACTIVE(self.callStatus) && self.callParticipantViewMode != CallParticipantViewModeSplitScreen) {
        return MARGIN_PARTICIPANT;
    } else if (self.nbParticipants < 4) {
        return self.mainParticipantHeight + MARGIN_PARTICIPANT;
    } else if (self.nbParticipants == 4) {
        if (self.position > 2) {
            return participantHeight + MARGIN_PARTICIPANT;
        }
    } else if (self.nbParticipants == 5) {
        if (self.position < 4) {
            return participantHeight + MARGIN_PARTICIPANT;
        } else {
            return (participantHeight * 2) + (MARGIN_PARTICIPANT * 2);
        }
    } else if (self.nbParticipants == 6) {
        if (self.position < 3) {
            return 0;
        } else if (self.position < 5) {
            return participantHeight + MARGIN_PARTICIPANT;
        } else {
            return (participantHeight * 2) + (MARGIN_PARTICIPANT * 2);
        }
    } else if (self.nbParticipants == 7) {
        if (self.position < 4) {
            return participantHeight + MARGIN_PARTICIPANT;
        } else if (self.position < 6) {
            return (participantHeight * 2) + (MARGIN_PARTICIPANT * 2);
        } else {
            return (participantHeight * 3) + (MARGIN_PARTICIPANT * 3);
        }
    } else if (self.nbParticipants == 8) {
        if (self.position < 3) {
            return 0;
        } else if (self.position < 5) {
            return participantHeight + MARGIN_PARTICIPANT;
        } else if (self.position < 7) {
            return (participantHeight * 2) + (MARGIN_PARTICIPANT * 2);
        } else {
            return (participantHeight * 3) + (MARGIN_PARTICIPANT * 3);
        }
    }

    return 0;
}

- (CGFloat)getLandscapeParticipantY:(CGFloat)participantHeight {
    DDLogVerbose(@"%@ getLandscapeParticipantY", LOG_TAG);
    
    if (self.nbParticipants < 5) {
        return 0;
    } else if (self.nbParticipants < 7) {
        if (self.position > 3) {
            return participantHeight + MARGIN_PARTICIPANT;
        }
    } else if (self.nbParticipants < 9) {
        if (self.position > 4) {
            return participantHeight + MARGIN_PARTICIPANT;
        }
    }
    return 0;
}

- (void)updateViews {
    DDLogVerbose(@"%@ updateViews", LOG_TAG);
    
    NSString *name = [self getName];
    if (name) {
        self.nameLabel.text = name;
    }
    
    self.nameView.hidden = (self.nbParticipants == 2 && !self.isCallReceiver) || !name || self.hideName;
}

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    MARGIN_PARTICIPANT = Design.WIDTH_RATIO * DESIGN_MARGIN_PARTICIPANT;
    THUMBNAIL_PARTICIPANT_WIDTH = Design.WIDTH_RATIO * DESIGN_THUMBNAIL_PARTICIPANT_WIDTH;
    THUMBNAIL_PARTICIPANT_HEIGHT = Design.HEIGHT_RATIO * DESIGN_THUMBNAIL_PARTICIPANT_HEIGHT;
    
    self.callParticipantViewAspect = CallParticipantViewAspectFit;
    
    self.mainParticipant = NO;
    self.isDraggable = NO;
    self.isLandscape = NO;
    self.hideName = NO;
    self.lastClosestCornerUnit = CGPointZero;
    
    self.clipsToBounds = YES;
    self.userInteractionEnabled = YES;
    [self.layer setMasksToBounds:YES];
    [self.layer setCornerRadius:DESIGN_CORNER_RADIUS];
    self.layer.backgroundColor = DESIGN_BACKGROUND_COLOR.CGColor;
    
    self.nameViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.nameViewBottomConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.nameViewLeadingConstraint.constant = self.nameViewBottomConstraint.constant;
    self.nameViewTrailingConstraint.constant = self.nameViewBottomConstraint.constant;
    
    self.nameView.backgroundColor = [UIColor blackColor];
    self.nameView.clipsToBounds = YES;
    self.nameView.layer.cornerRadius = 9;
    
    self.nameLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.nameLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.nameLabel.textColor = [UIColor whiteColor];
    self.nameLabel.font = Design.FONT_REGULAR28;
    
    self.avatarView.layer.cornerRadius = DESIGN_CORNER_RADIUS;
    self.avatarView.clipsToBounds = YES;
   
    self.microMuteViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.microMuteViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.microMuteViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.microMuteView.hidden = YES;
    
    self.pauseViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.pauseViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.pauseViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.pauseView.hidden = YES;
    
    self.infoViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.infoViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.infoViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.infoView.hidden = YES;
    self.infoView.userInteractionEnabled = YES;
    self.infoView.tintColor = Design.DELETE_COLOR_RED;
    
    self.switchCameraHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.switchCameraBottomConstraint.constant *= Design.HEIGHT_RATIO;
    self.switchCameraLeadingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.switchCameraView.hidden = YES;
    self.switchCameraView.userInteractionEnabled = YES;
    
    self.switchCameraImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.switchCameraImageView.tintColor = [UIColor blackColor];
    
    self.switchCameraBackgroundViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    [self.switchCameraBackgroundView setBackgroundColor:[UIColor whiteColor]];
    self.switchCameraBackgroundView.layer.cornerRadius = self.switchCameraBackgroundViewHeightConstraint.constant * 0.5;
    self.switchCameraBackgroundView.layer.masksToBounds = NO;
    
    self.overlayView.backgroundColor = Design.OVERLAY_COLOR;
    self.overlayView.hidden = YES;
}

#pragma mark - Touch Methods

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [super touchesMoved:touches withEvent:event];
    
    if (!self.isDraggable || self.callParticipantViewAspect == CallParticipantViewAspectFullScreen) {
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
    
    if (!self.isDraggable || self.callParticipantViewAspect == CallParticipantViewAspectFullScreen) {
        return;
    }
    
    [self moveToClosestCornerAnimated:YES];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [super touchesCancelled:touches withEvent:event];
    
    if (!self.isDraggable || self.callParticipantViewAspect == CallParticipantViewAspectFullScreen) {
        return;
    }
    
    [self moveToClosestCornerAnimated:YES];
}

#pragma mark - Math

- (CGPoint)closestCornerUnit {
    
    CGFloat xCenter = self.parentViewWidth * 0.5;
    CGFloat yCenter = self.parentViewHeight * 0.5;
    
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
    
    self.lastClosestCornerUnit = [self closestCornerUnit];
    [self moveToCornerUnit:self.lastClosestCornerUnit animated:animated];
}

#pragma mark - Private Commands

- (void)moveToCornerUnit:(CGPoint)unit animated:(BOOL)animated {
    
    if (!self.superview)
        return;
    
    CGFloat xCenter = self.parentViewWidth * 0.5;
    CGFloat yCenter = self.parentViewHeight * 0.5;
    
    CGFloat xWidth = (self.parentViewWidth - self.width - (MARGIN_PARTICIPANT * 4));
    if (self.isLandscape) {
        xWidth = (self.parentViewWidth - self.width - (MARGIN_PARTICIPANT * 2));
    }
    CGFloat yHeight = (self.parentViewHeight - self.height - (MARGIN_PARTICIPANT * 2));
    
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
