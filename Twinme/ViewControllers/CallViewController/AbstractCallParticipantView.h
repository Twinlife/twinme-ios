/*
 *  Copyright (c) 2024 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <TwinmeCommon/CallStatus.h>

typedef enum {
    CallParticipantViewAspectFit,
    CallParticipantViewAspectFullScreen
} CallParticipantViewAspect;

typedef enum {
    CallParticipantViewModeSmallLocale,
    CallParticipantViewModeSmallRemote,
    CallParticipantViewModeSplitScreen
} CallParticipantViewMode;


@class CallParticipant;
@protocol CallParticipantViewDelegate;

//
// Interface: AbstractCallParticipantView
//

@interface AbstractCallParticipantView : UIView

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameViewBottomConstraint;
@property (weak, nonatomic) IBOutlet UIView *nameView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *avatarView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *microMuteViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *microMuteViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *microMuteViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *microMuteView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pauseViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pauseViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pauseViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *pauseView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *infoViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *infoViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *infoViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *infoView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *switchCameraHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *switchCameraBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *switchCameraLeadingConstraint;
@property (weak, nonatomic) IBOutlet UIView *switchCameraView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *switchCameraBackgroundViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *switchCameraBackgroundView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *switchCameraImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *switchCameraImageView;
@property (weak, nonatomic) IBOutlet UIView *overlayView;
@property (nonatomic) CGSize videoSize;
@property (nonatomic) CGSize fillVideoSize;
@property (nonatomic) CGSize fitVideoSize;
@property (nonatomic) CGFloat parentViewWidth;
@property (nonatomic) CGFloat parentViewHeight;
@property (nonatomic) int nbParticipants;
@property (nonatomic) BOOL mainParticipant;
@property (nonatomic) BOOL isVideoCall;
@property (nonatomic) BOOL isCallReceiver;
@property (nonatomic) BOOL isLandscape;
@property (nonatomic) CallStatus callStatus;

@property (weak, nonatomic) id<CallParticipantViewDelegate> delegate;
@property (nonatomic) CallParticipantViewAspect callParticipantViewAspect;
@property (nonatomic) CallParticipantViewMode callParticipantViewMode;

- (void)setPosition:(BOOL)isMainParticipant parentViewWidth:(float)parentViewWidth parentViewHeight:(float)parentViewHeight numberParticipants:(int)numberParticipants position:(int)position hideName:(BOOL)hideName isLandscape:(BOOL)isLandscape;

- (BOOL)isMainParticipant;

- (BOOL)isRemoteParticipant;

- (BOOL)isCameraMute;

- (BOOL)isMessageSupported;

- (BOOL)isStreamingSupported;

- (BOOL)isZoomableSupported;

- (BOOL)isRemoteCameraControl;

- (NSString *)getName;

- (CallParticipant *)getCallParticipant;

- (int)getParticipantId;

- (void)initViews;

- (void)updateViews;

- (void)updateCallParticipantViewAspect;

- (void)minZoom;

- (void)resetZoom;

@end
