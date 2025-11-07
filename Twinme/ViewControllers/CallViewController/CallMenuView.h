/*
 *  Copyright (c) 2022 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

typedef enum {
    CallMenuViewStateDefault,
    CallMenuViewStateExtend
} CallMenuViewState;

//
// Protocol: CallMenuDelegate
//

@protocol CallMenuDelegate <NSObject>

- (void)menuStateDidUpdated:(CallMenuViewState)callMenuViewState;

@end

@class AudioDevice;

//
// Interface: CallQualityView
//

@interface CallMenuView : UIView

@property (weak, nonatomic) IBOutlet UIButton *hangupButton;
@property (weak, nonatomic) IBOutlet UIButton *cameraMuteButton;
@property (weak, nonatomic) IBOutlet UIButton *microMuteButton;
@property (weak, nonatomic) IBOutlet UIButton *speakerOnButton;
@property (weak, nonatomic) IBOutlet UIButton *conversationButton;
@property (weak, nonatomic) IBOutlet UIButton *invitationButton;
@property (weak, nonatomic) IBOutlet UIButton *streamingAudioButton;
@property (weak, nonatomic) IBOutlet UIButton *pauseButton;
@property (weak, nonatomic) IBOutlet UIButton *certifyButton;
@property (weak, nonatomic) IBOutlet UIButton *cameraControlButton;

@property (weak, nonatomic) id<CallMenuDelegate> callMenuDelegate;

- (void)updateMenu:(BOOL)isInCall isAudioMuted:(BOOL)isAudioMuted isSpeakerOn:(BOOL)isSpeakerOn isCameraMuted:(BOOL)isCameraMuted isLocalVideoTrack:(BOOL)isLocalVideoTrack isVideoAllowed:(BOOL)isVideoAllowed isConversationAllowed:(BOOL)isConversationAllowed isStreamingAudioSupported:(BOOL)isStreamingAudioSupported isShareInvitationAllowed:(BOOL)isShareInvitationAllowed isInPause:(BOOL)isInPause hideCertify:(BOOL)hideCertify isCertifyRunning:(BOOL)isCertifyRunning audioDevice:(AudioDevice *)audioDevice isHeadSetAvailable:(BOOL)isHeadSetAvailable isCameraControlAllowed:(BOOL)isCameraControlAllowed isRemoteCameraControl:(BOOL)isRemoteCameraControl;

- (void)updateMenuState:(CallMenuViewState)callMenuViewState;

@end
