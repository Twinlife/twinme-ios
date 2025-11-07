/*
 *  Copyright (c) 2022 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <Utils/NSString+Utils.h>

#import "CallMenuView.h"

#import <TwinmeCommon/Design.h>
#import <TwinmeCommon/CallService.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

#define DESIGN_MENU_COLOR [UIColor colorWithRed:24./255. green:24./255. blue:24./255. alpha:1]

static const CGFloat DESIGN_CORNER_RADIUS = 14;
static const CGFloat DESIGN_ICON_PAUSE_CALL_HEIGHT = 32;
static const CGFloat DESIGN_ICON_RESUME_CALL_HEIGHT = 40;

//
// Interface: CallMenuView ()
//

@interface CallMenuView()

@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *slideMarkViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *slideMarkViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *slideMarkViewWidthConstraint;
@property (weak, nonatomic) IBOutlet UIView *slideMarkView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *actionViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *actionViewWidthConstraint;
@property (weak, nonatomic) IBOutlet UIView *actionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *hangupViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *hangupViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet UIView *hangupView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *hangupImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *hangupImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cameraMuteViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *cameraMuteView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cameraMuteImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *cameraMuteImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *microMuteViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *microMuteView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *microMuteImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *microMuteImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *speakerOnViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *speakerOnViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *speakerOnViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *speakerOnView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *speakerOnImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *speakerOnImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *conversationViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *conversationViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *conversationView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *conversationImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *conversationImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *invitationViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *invitationViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *invitationView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *invitationImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *invitationImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *streamingAudioViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *streamingAudioViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *streamingAudioView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *streamingAudioImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *streamingAudioImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pauseViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pauseViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *pauseView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pauseImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *pauseImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *certifyViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *certifyViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *certifyView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *certifyImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *certifyImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cameraControlViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cameraControlViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *cameraControlView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cameraControlImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *cameraControlImageView;

@property (nonatomic) CallMenuViewState callMenuViewState;

@end

//
// Implementation: CallMenuView
//

#undef LOG_TAG
#define LOG_TAG @"CallMenuView"

@implementation CallMenuView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    DDLogVerbose(@"%@ initWithCoder", LOG_TAG);
    
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        UIView *callMenuView = [[[NSBundle mainBundle] loadNibNamed:@"CallMenuView" owner:self options:nil] objectAtIndex:0];
        callMenuView.frame = self.bounds;
        callMenuView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:callMenuView];
        [self initViews];
    }
    
    return self;
}

- (void)updateSourceAudioIcon:(AudioDevice *)audioDevice {
     DDLogVerbose(@"%@ updateSourceAudioIcon", LOG_TAG);
          
    UIImage *sourceAudioImage;
    switch (audioDevice.type) {
         case AudioDeviceTypeSpeakerPhone:
             sourceAudioImage = [UIImage imageNamed:@"LoudSpeakerActionCallOn"];
             break;
             
         case AudioDeviceTypeWiredHeadset:
            sourceAudioImage = [UIImage imageNamed:@"AudioHeadPhoneIcon"];
             break;
             
         case AudioDeviceTypeEarPiece:
            sourceAudioImage = [UIImage imageNamed:@"AudioPhoneSpeakerIcon"];
             break;
             
         case AudioDeviceTypeBluetooth:
            sourceAudioImage = [UIImage imageNamed:@"AudioBluetoothIcon"];
             break;
             
         case AudioDeviceTypeDefault:
         case AudioDeviceTypeNone:
            sourceAudioImage = [UIImage imageNamed:@"LoudSpeakerActionCallOff"];
             break;
             
         default:
             break;
     }
    
    self.speakerOnImageView.image = sourceAudioImage;
    [self.speakerOnImageView setTintColor:[UIColor blackColor]];
 }

- (void)updateMenu:(BOOL)isInCall isAudioMuted:(BOOL)isAudioMuted isSpeakerOn:(BOOL)isSpeakerOn isCameraMuted:(BOOL)isCameraMuted isLocalVideoTrack:(BOOL)isLocalVideoTrack isVideoAllowed:(BOOL)isVideoAllowed isConversationAllowed:(BOOL)isConversationAllowed isStreamingAudioSupported:(BOOL)isStreamingAudioSupported isShareInvitationAllowed:(BOOL)isShareInvitationAllowed isInPause:(BOOL)isInPause hideCertify:(BOOL)hideCertify isCertifyRunning:(BOOL)isCertifyRunning audioDevice:(AudioDevice *)audioDevice isHeadSetAvailable:(BOOL)isHeadSetAvailable isCameraControlAllowed:(BOOL)isCameraControlAllowed isRemoteCameraControl:(BOOL)isRemoteCameraControl {
    DDLogVerbose(@"%@ updateMenu", LOG_TAG);
    
    if (isInCall) {
        self.microMuteView.alpha = 1.0;
        self.microMuteButton.enabled = YES;
        self.cameraMuteView.alpha = 1.0;
        self.cameraMuteButton.enabled = YES;
        self.speakerOnView.alpha = 1.0;
        self.speakerOnButton.enabled = YES;
        self.conversationView.alpha = 1.0;
        self.conversationButton.enabled = YES;
        self.streamingAudioView.alpha = 1.0;
        self.streamingAudioButton.enabled = YES;
        self.invitationView.alpha = 1.0;
        self.invitationButton.enabled = YES;
        self.certifyView.alpha = 1.0;
        self.certifyButton.enabled = YES;
        self.cameraControlView.alpha = 1.0;
        self.cameraControlButton.enabled = YES;
    } else {
        self.microMuteView.alpha = 0.5;
        self.microMuteButton.enabled = NO;
        self.cameraMuteView.alpha = 0.5;
        self.cameraMuteButton.enabled = NO;
        self.conversationView.alpha = 0.5;
        self.conversationButton.enabled = NO;
        self.streamingAudioView.alpha = 0.5;
        self.streamingAudioButton.enabled = NO;
        self.certifyView.alpha = 0.5;
        self.certifyButton.enabled = NO;
        self.cameraControlView.alpha = 0.5;
        self.cameraControlButton.enabled = NO;
    }
    
    self.microMuteButton.hidden = NO;
    if (isAudioMuted) {
        self.microMuteImageView.image = [UIImage imageNamed:@"MuteActionCallOn"];
    } else {
        self.microMuteImageView.image = [UIImage imageNamed:@"MuteActionCallOff"];
    }
    
    if (!isHeadSetAvailable) {
        if (isSpeakerOn) {
            self.speakerOnImageView.image = [UIImage imageNamed:@"LoudSpeakerActionCallOn"];
        } else {
            self.speakerOnImageView.image = [UIImage imageNamed:@"LoudSpeakerActionCallOff"];
        }
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            self.speakerOnImageView.image = [UIImage imageNamed:@"LoudSpeakerActionCallOn"];
            [self.speakerOnButton setEnabled:NO];
            self.speakerOnView.alpha = 0.5;
        }
    } else {
        [self updateSourceAudioIcon:audioDevice];
    }
    
    if (isCameraMuted) {
        self.cameraMuteImageView.image = [UIImage imageNamed:@"VideoMuteActionCallOn"];
    } else {
        self.cameraMuteImageView.image = [UIImage imageNamed:@"VideoMuteActionCallOff"];
    }
    
    if (isInPause) {
        self.pauseImageView.image = [UIImage imageNamed:@"CallResumeIcon"];
        self.pauseImageViewHeightConstraint.constant = DESIGN_ICON_RESUME_CALL_HEIGHT * Design.HEIGHT_RATIO;
    } else {
        self.pauseImageView.image = [UIImage imageNamed:@"CallPauseIcon"];
        self.pauseImageViewHeightConstraint.constant = DESIGN_ICON_PAUSE_CALL_HEIGHT * Design.HEIGHT_RATIO;
    }
        
    if (isVideoAllowed && isInCall) {
        self.cameraMuteView.alpha = 1.0;
    } else {
        self.cameraMuteView.alpha = 0.5;
    }
    
    if (isCertifyRunning) {
        self.cameraMuteView.alpha = 0.5;
        self.cameraMuteButton.enabled = NO;
        self.conversationView.alpha = 0.5;
        self.conversationButton.enabled = NO;
        self.streamingAudioView.alpha = 0.5;
        self.streamingAudioButton.enabled = NO;
        self.invitationView.alpha = 0.5;
        self.invitationButton.enabled = NO;
        self.certifyView.alpha = 0.5;
        self.certifyButton.enabled = NO;
        self.cameraControlView.alpha = 0.5;
        self.cameraControlButton.enabled = NO;
    }
    
    if (isConversationAllowed) {
        self.conversationView.hidden = NO;
    } else {
        self.conversationView.hidden = YES;
    }
    
    if (isStreamingAudioSupported) {
        self.streamingAudioView.hidden = NO;
    } else {
        self.streamingAudioView.hidden = YES;
    }
    
    if (isShareInvitationAllowed) {
        self.invitationView.hidden = NO;
    } else {
        self.invitationView.hidden = YES;
    }
    
    if (isCameraControlAllowed) {
        self.cameraControlView.hidden = NO;
        self.cameraControlImageView.tintColor = isRemoteCameraControl ? Design.DELETE_COLOR_RED : [UIColor blackColor];
    } else {
        self.cameraControlView.hidden = YES;
    }
    
    self.certifyView.hidden = hideCertify;
    
    int viewPosition = 1;
    float buttonWidth = self.conversationViewHeightConstraint.constant;
    float buttonMargin = self.pauseViewLeadingConstraint.constant;
    
    if (isStreamingAudioSupported) {
        self.streamingAudioViewLeadingConstraint.constant = buttonWidth * viewPosition + buttonMargin * viewPosition;
        viewPosition++;
    }
    
    if (isShareInvitationAllowed) {
        self.invitationViewLeadingConstraint.constant = buttonWidth * viewPosition + buttonMargin * viewPosition;
        viewPosition++;
    }
    
    if (!hideCertify) {
        self.certifyViewLeadingConstraint.constant = buttonWidth * viewPosition + buttonMargin * viewPosition;
        viewPosition++;
    }
    
    if (isCameraControlAllowed) {
        self.cameraControlViewLeadingConstraint.constant = buttonWidth * viewPosition + buttonMargin * viewPosition;
    }
}

- (void)updateMenuState:(CallMenuViewState)callMenuViewState {
    DDLogVerbose(@"%@ updateMenuState", LOG_TAG);
    
    self.callMenuViewState = callMenuViewState;
    
    [self animateMenu];
}

#pragma mark - Private methods

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    self.callMenuViewState = CallMenuViewStateDefault;
    
    self.backgroundView.backgroundColor = DESIGN_MENU_COLOR;
    self.backgroundView.clipsToBounds = YES;
    self.backgroundView.layer.cornerRadius = DESIGN_CORNER_RADIUS;
        
    self.slideMarkViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.slideMarkViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.slideMarkViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.slideMarkView.backgroundColor = [UIColor colorWithRed:244./255. green:244./255. blue:244./255. alpha:1.0];
    self.slideMarkView.layer.cornerRadius = self.slideMarkViewHeightConstraint.constant * 0.5;
    self.slideMarkView.clipsToBounds = YES;

    self.cameraMuteViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    [self.cameraMuteButton setBackgroundColor:[UIColor whiteColor]];
    CALayer *cameraMuteButtonLayer = self.cameraMuteButton.layer;
    cameraMuteButtonLayer.cornerRadius = self.cameraMuteViewHeightConstraint.constant * 0.5;
    cameraMuteButtonLayer.masksToBounds = NO;
    
    self.cameraMuteImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    [self.cameraMuteImageView setTintColor:[UIColor blackColor]];
    
    self.microMuteViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    [self.microMuteButton setBackgroundColor:[UIColor whiteColor]];
    CALayer *microMuteButtonLayer = self.microMuteButton.layer;
    microMuteButtonLayer.cornerRadius = self.microMuteViewHeightConstraint.constant * 0.5;
    microMuteButtonLayer.masksToBounds = NO;
    
    self.microMuteImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    [self.microMuteImageView setTintColor:[UIColor blackColor]];
    
    self.speakerOnViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.speakerOnViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.speakerOnViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    [self.speakerOnButton setBackgroundColor:[UIColor whiteColor]];
    CALayer *speakerOnButtonLayer = self.speakerOnButton.layer;
    speakerOnButtonLayer.cornerRadius = self.speakerOnViewHeightConstraint.constant * 0.5;
    speakerOnButtonLayer.masksToBounds = NO;
    
    self.speakerOnImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    [self.speakerOnImageView setTintColor:[UIColor blackColor]];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [self.speakerOnButton setEnabled:NO];
    }
    
    self.hangupViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.hangupViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    
    [self.hangupButton setBackgroundColor:Design.BUTTON_RED_COLOR];
    CALayer *hangupButtonLayer = self.hangupButton.layer;
    hangupButtonLayer.cornerRadius = self.hangupViewHeightConstraint.constant * 0.5;
    hangupButtonLayer.masksToBounds = NO;
    self.hangupButton.accessibilityLabel = TwinmeLocalizedString(@"audio_call_view_controller_hangup", nil);
    
    self.hangupImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.hangupImageView.image = [self.hangupImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.hangupImageView setTintColor:[UIColor whiteColor]];
    
    self.conversationViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.conversationViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.conversationImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    [self.conversationImageView setTintColor:[UIColor blackColor]];
    
    [self.conversationButton setBackgroundColor:[UIColor whiteColor]];
    CALayer *conversationButtonLayer = self.conversationButton.layer;
    conversationButtonLayer.cornerRadius = self.conversationViewHeightConstraint.constant * 0.5;
    conversationButtonLayer.masksToBounds = NO;
    
    self.invitationViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
        
    self.invitationImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    [self.invitationImageView setTintColor:[UIColor blackColor]];
    
    [self.invitationButton setBackgroundColor:[UIColor whiteColor]];
    CALayer *invitationButtonLayer = self.invitationButton.layer;
    invitationButtonLayer.cornerRadius = self.invitationViewHeightConstraint.constant * 0.5;
    invitationButtonLayer.masksToBounds = NO;
    
    self.streamingAudioView.accessibilityLabel = TwinmeLocalizedString(@"streaming_audio_view_controller_title", nil);

    self.streamingAudioViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.streamingAudioViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
        
    self.streamingAudioImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    [self.streamingAudioImageView setTintColor:[UIColor blackColor]];
    
    [self.streamingAudioButton setBackgroundColor:[UIColor whiteColor]];
    CALayer *streamingAudioButtonLayer = self.streamingAudioButton.layer;
    streamingAudioButtonLayer.cornerRadius = self.streamingAudioViewHeightConstraint.constant * 0.5;
    streamingAudioButtonLayer.masksToBounds = NO;
    
    self.pauseViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.pauseViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.pauseImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    [self.pauseImageView setTintColor:[UIColor blackColor]];
    
    [self.pauseButton setBackgroundColor:[UIColor whiteColor]];
    CALayer *pauseAudioButtonLayer = self.pauseButton.layer;
    pauseAudioButtonLayer.cornerRadius = self.pauseViewHeightConstraint.constant * 0.5;
    pauseAudioButtonLayer.masksToBounds = NO;
    
    self.certifyViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.certifyViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.certifyImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.certifyImageView.image = [self.certifyImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.certifyImageView setTintColor:[UIColor blackColor]];
    
    [self.certifyButton setBackgroundColor:[UIColor whiteColor]];
    CALayer *certifyButtonLayer = self.certifyButton.layer;
    certifyButtonLayer.cornerRadius = self.certifyViewHeightConstraint.constant * 0.5;
    certifyButtonLayer.masksToBounds = NO;
    
    self.cameraControlViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.cameraControlViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.cameraControlImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.cameraControlImageView.image = [self.cameraControlImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.cameraControlImageView setTintColor:[UIColor blackColor]];
    
    [self.cameraControlButton setBackgroundColor:[UIColor whiteColor]];
    CALayer *cameraControlButtonLayer = self.cameraControlButton.layer;
    cameraControlButtonLayer.cornerRadius = self.cameraControlViewHeightConstraint.constant * 0.5;
    cameraControlButtonLayer.masksToBounds = NO;
        
    self.actionViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.actionViewWidthConstraint.constant = (self.pauseViewHeightConstraint.constant * 5) + (self.pauseViewLeadingConstraint.constant * 4);
    
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    [self addGestureRecognizer:panGestureRecognizer];
}

-(void)handlePanGesture:(UIPanGestureRecognizer *)recognizer {
    DDLogVerbose(@"%@ handlePanGesture: %@", LOG_TAG, recognizer);
    
    CGPoint velocity = [recognizer velocityInView:self];
    BOOL isDownGesture = NO;
    if (velocity.y > 0) {
        isDownGesture = YES;
    }
    
    BOOL needsUpdate = NO;
    if (isDownGesture && self.callMenuViewState == CallMenuViewStateExtend) {
        needsUpdate = YES;
        self.callMenuViewState = CallMenuViewStateDefault;
    } else if (!isDownGesture && self.callMenuViewState == CallMenuViewStateDefault) {
        needsUpdate = YES;
        self.callMenuViewState = CallMenuViewStateExtend;
    }
    
    if (needsUpdate) {
        [self animateMenu];
    }
}

- (void)animateMenu {
    DDLogVerbose(@"%@ animateMenu", LOG_TAG);
    
    if ([self.callMenuDelegate respondsToSelector:@selector(menuStateDidUpdated:)]) {
        [self.callMenuDelegate menuStateDidUpdated:self.callMenuViewState];
    }
}

@end
