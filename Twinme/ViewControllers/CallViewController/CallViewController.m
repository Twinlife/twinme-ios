/*
 *  Copyright (c) 2014-2024 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Zhuoyu Ma (Zhuoyu.Ma@twinlife-systems.com)
 *   Christian Jacquemot (Christian.Jacquemot@twinlife-systems.com)
 *   Leiqiang Zhong (Leiqiang.Zhong@twinlife-systems.com)
 *   Marouane Qasmi (Marouane.Qasmi@twinlife-systems.com)
 *   Chedi Baccari (Chedi.Baccari@twinlife-systems.com)
 *   Thibaud David (contact@thibauddavid.com)
 *   Stephane Carrez (Stephane.Carrez@twin.life)
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <AVKit/AVKit.h>

#import <WebRTC/RTCVideoTrack.h>
#import <WebRTC/RTCVideoRenderer.h>

#import <Twinlife/TLImageService.h>
#import <Twinlife/TLTwincodeOutboundService.h>

#import <Twinme/TLContact.h>
#import <Twinme/TLCallReceiver.h>
#import <Twinme/TLInvitation.h>
#import <Twinme/TLProfile.h>
#import <Twinme/TLSchedule.h>
#import <Twinme/TLSpace.h>

#import <Utils/NSString+Utils.h>

#import "DraggableVideoView.h"
#import "UIView+GradientBackgroundColor.h"
#import "DeviceAuthorization.h"
#import "ZoomSlider.h"
#import "CallAnimationView.h"
#import "AlertView.h"
#import "AlertMessageView.h"
#import "CallQualityView.h"
#import "DeviceAuthorization.h"
#import "DefaultConfirmView.h"
#import "AddCallParticipantViewController.h"
#import "CoachMarkViewController.h"
#import "StreamingAudioViewController.h"
#import "InAppSubscriptionViewController.h"
#import "InvitationCodeConfirmView.h"
#import "CoachMarkViewController.h"
#import "StreamingAudioViewController.h"
#import "AbstractCallParticipantView.h"
#import "CallParticipantLocaleView.h"
#import "CallParticipantRemoteView.h"
#import "CallMenuView.h"
#import "CallHoldView.h"
#import "CallCertifyView.h"
#import "CallConversationView.h"
#import "CallMapView.h"
#import "PlayerStreamingAudioView.h"
#import "OnboardingConfirmView.h"
#import "DefaultConfirmView.h"
#import "PremiumFeatureConfirmView.h"
#import "UIPremiumFeature.h"
#import "UIView+Toast.h"
#import "UIColor+Hex.h"

#import <TwinmeCommon/CallViewController.h>
#import <TwinmeCommon/AbstractTwinmeService.h>
#import <TwinmeCommon/AbstractTwinmeService+Protected.h> // SCz must fix
#import <TwinmeCommon/CallService.h>
#import <TwinmeCommon/CallState.h>
#import <TwinmeCommon/CallParticipant.h>
#import <TwinmeCommon/StreamPlayer.h>
#import <TwinmeCommon/Streamer.h>
#import <TwinmeCommon/Design.h>
#import <TwinmeCommon/CoachMark.h>
#import <TwinmeCommon/KeyCheckSessionHandler.h>
#import <TwinmeCommon/MainViewController.h>
#import <TwinmeCommon/TwinmeNavigationController.h>
#import <TwinmeCommon/UIViewController+Utils.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

#define CLOSE_DELAY 3
#define DELAY_COACH_MARK 0.5
#define DELAY_LOCATION_SERVICES_ALERT 0.5
#define DELAY_START_CERTIFY 0.8
#define DELAY_HIDE_MENU_VIDEO_CALL 3
#define MENU_ANIMATION_DURATION 0.1
#define SCALE_ANIMATION_DURATION 0.4
#define SCALE_ANIMATION_REPEAT_DELAY 7
#define SCALE_ANIMATION_BEGIN_TIME 5

static const CGFloat DESIGN_CORNER_RADIUS = 14;
static const CGFloat DESIGN_DEFAULT_MENU_MARGIN = 150;
static const CGFloat DESIGN_MARGIN_PARTICIPANT = 34;
static const CGFloat DESIGN_PARTICIPANTS_BOTTOM_MARGIN = 42;
static const CGFloat DESIGN_PARTICIPANTS_BOTTOM_LARGE_MARGIN = 228;
// static const CGFloat DESIGN_NAME_MAX_WIDTH = 280;

static UIColor *DESIGN_MENU_COLOR;
static UIColor *DESIGN_OVERLAY_COLOR;

static NSInteger TERMINATE_ALERT_VIEW_TAG = 2;

static NSInteger CONTROL_CAMERA_ASK_TAG = 1;
static NSInteger CONTROL_CAMERA_STOP_TAG = 2;
static NSInteger CONTROL_CAMERA_ANSWER_TAG = 3;

static NSInteger ONBOARDING_REMOTE_CAMERA = 1;

//
// Interface: CallViewController ()
//

@interface CallViewController () <RTC_OBJC_TYPE(RTCVideoViewDelegate), VideoZoomDelegate, CAAnimationDelegate, AbstractTwinmeDelegate, AlertViewDelegate, CallQualityViewDelegate, AddCallParticipantDelegate, CallParticipantViewDelegate, CallParticipantDelegate, InAppSubscriptionViewControllerDelegate, CoachMarkDelegate, PlayerStreamingAudioViewDelegate, CallConversationDelegate, CallMenuDelegate, CallHoldDelegate, CallMapDelegate, CallCertifyViewDelegate, AlertMessageViewDelegate, ConfirmViewDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *backImageViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *backImageViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *backImageViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *backImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *backClickableViewWidthConstraint;
@property (weak, nonatomic) IBOutlet UIView *backClickableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *certifiedRelationImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *certifiedRelationImageViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *certifiedRelationImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *transferLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *transferLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *transferLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *answerCallViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *answerCallViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *answerCallViewBottomConstraint;
@property (weak, nonatomic) IBOutlet UIView *answerCallView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *acceptViewWidthConstraint;
@property (weak, nonatomic) IBOutlet UIView *acceptView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *acceptButtonHeightConstraint;
@property (weak, nonatomic) IBOutlet UIButton *acceptButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *acceptImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *acceptImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *declineViewWidthConstraint;
@property (weak, nonatomic) IBOutlet UIView *declineView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *declineButtonHeightConstraint;
@property (weak, nonatomic) IBOutlet UIButton *declineButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *declineImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *declineImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cancelViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cancelViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cancelViewWidthConstraint;
@property (weak, nonatomic) IBOutlet UIView *cancelView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cancelButtonHeightConstraint;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cancelImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *cancelImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *menuViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *menuViewHeightConstraint;
@property (weak, nonatomic) IBOutlet CallMenuView *menuView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *playerStreamingAudioViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *playerStreamingAudioViewBottomConstraint;
@property (weak, nonatomic) IBOutlet PlayerStreamingAudioView *playerStreamingAudioView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *callHoldViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *callHoldViewBottomConstraint;
@property (weak, nonatomic) IBOutlet CallHoldView *callHoldView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *conversationViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *conversationViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *conversationViewBottomConstraint;
@property (weak, nonatomic) IBOutlet CallConversationView *conversationView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIView *addParticipantView;
@property (weak, nonatomic) IBOutlet UIButton *addParticipantButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *addParticipantImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *addParticipantImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *unreadMessageViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet UIView *unreadMessageView;
@property (weak, nonatomic) IBOutlet UIButton *unreadMessageButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *unreadMessageImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *unreadMessageImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sharedLocationViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet UIView *sharedLocationView;
@property (weak, nonatomic) IBOutlet UIButton *sharedLocationButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sharedLocationImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *sharedLocationImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *controlCameraViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet UIView *controlCameraView;
@property (weak, nonatomic) IBOutlet UIButton *controlCameraButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *controlCameraImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *controlCameraImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *terminatedLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *terminatedLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet UILabel *terminatedLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *participantsViewBottomConstraint;
@property (weak, nonatomic) IBOutlet UIView *participantsView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *noParticipantsViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *noParticipantsViewWidthConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *noParticipantsView;
@property (weak, nonatomic) IBOutlet UIView *overlayView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *zoomLevelViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *zoomLevelViewBottomConstraint;
@property (weak, nonatomic) IBOutlet UIView *zoomLevelView;
@property (weak, nonatomic) IBOutlet UILabel *zoomLevelLabel;
@property (nonatomic) AVRoutePickerView *routePickerView;

@property (nonatomic) CallCertifyView *callCertifyView;

@property (nonatomic) BOOL uiInitialized;
@property (nonatomic) id<TLOriginator> originator;
@property (nonatomic) BOOL isCallStartedInVideo;
@property (nonatomic) BOOL videoBell;
@property (nonatomic) BOOL localVideoTrackAdded;
@property (nonatomic) BOOL reverseVideo;
@property (nonatomic) NSString *contactName;
@property (nonatomic) UIImage *contactAvatar;
@property (nonatomic) CGSize remoteVideoSize;
@property (nonatomic) UIInterfaceOrientation videoOrientation;
@property (nonatomic) UIInterfaceOrientation statusBarOrientation;
@property (nonatomic) BOOL proximityMonitoringEnabled;
@property (nonatomic) BOOL connected;
@property (nonatomic) BOOL outgoingCall;
@property (nonatomic) NSTimer *chronometer;
@property (nonatomic) NSTimer *terminateTimer;
@property (nonatomic) BOOL menuHidden;
@property (nonatomic) BOOL userMessage;
@property (nonatomic) CallParticipant *participant;
@property (nonatomic, nullable) AlertView *networkAlertView;
@property (nonatomic) BOOL isSpeakerOnBeforeProximityUpdate;
@property (nonatomic) BOOL isGroupCallSubscribed;
@property (nonatomic) BOOL showCallQuality;
@property (nonatomic) BOOL showCallGroupAnimation;
@property (nonatomic) BOOL showTerminateReason;
@property (nonatomic) BOOL showCertifyView;
@property (nonatomic) BOOL hideMenuOnVideoCall;
@property (nonatomic) BOOL showRemoteCameraOnboarding;
@property (nonatomic) int elapsedTime;
@property (nonatomic) BOOL keyboardHidden;
@property (nonatomic) BOOL getDescriptorsDone;
@property (nonatomic) BOOL accessCameraGranted;

@property (nonatomic) NSMutableArray *callParticipantViews;
@property (nonatomic) CallParticipantLocaleView *callParticipantLocaleView;

@property (nonatomic) NSLayoutConstraint *mapViewTopConstraint;
@property (nonatomic) NSLayoutConstraint *mapViewBottomConstraint;
@property (nonatomic) NSLayoutConstraint *mapViewFullScreenTopConstraint;
@property (nonatomic) NSLayoutConstraint *mapViewFullScreenBottomConstraint;
@property (nonatomic) CallMapView *mapView;

@property (nonatomic) CallParticipantViewMode callParticipantViewMode;

@property (nonatomic, readonly, nonnull) CallService *callService;
@property (nonatomic, nullable) AbstractTwinmeService *twinmeService;
@property (nonatomic, nullable) AbstractTwinmeContextDelegate *twinmeServiceDelegate;

@property (nonatomic) float videoZoom;
@property (nonatomic) float remoteZoom;

@property (nonatomic) BOOL isVideoCall;
@property (nonatomic) BOOL isCallReceiver;
@property (nonatomic) BOOL participantsViewInitialized;
@property (nonatomic) BOOL showShareLocationMessage;
@property (nonatomic) BOOL startShareLocationOnLocationEnable;

@property (nonatomic) NSMutableArray *callParticipantColors;

@property (nonatomic) StreamPlayer *streamPlayer;

@property (nonatomic) WordCheckChallenge *wordCheckChallenge;

- (void)updateView:(CallStatus)callStatus;

- (void)onMessageConnectionState:(nonnull CallEventMessage *)message;

- (void)onMessageTerminateCall:(nonnull CallEventMessage *)message;

- (void)onMessageVideoUpdate:(nonnull NSNotification *)notification;

@end

//
// Implementation: CallViewController
//

#undef LOG_TAG
#define LOG_TAG @"CallViewController"

@implementation CallViewController

+ (void)initialize {
    DDLogVerbose(@"%@ initialize", LOG_TAG);
    
    DESIGN_MENU_COLOR = [UIColor colorWithRed:24./255. green:24./255. blue:24./255. alpha:1];
    DESIGN_OVERLAY_COLOR = [UIColor colorWithRed:13./255. green:13./255. blue:13./255. alpha:0.70];
}

#pragma mark - UIViewController

- (instancetype)initWithCoder:(NSCoder *)coder {
    
    self = [super initWithCoder:coder];
    
    if (self) {
        _uiInitialized = NO;
        _menuHidden = NO;
        _userMessage = NO;
        _videoZoom = 1.0;
        _remoteZoom = 1.0;
        _localVideoTrackAdded = NO;
        _isSpeakerOnBeforeProximityUpdate = NO;
        _isVideoCall = NO;
        _isCallReceiver = NO;
        _reverseVideo = NO;
        _isCallStartedInVideo = NO;
        _participantsViewInitialized = NO;
        _showCallQuality = NO;
        _showCallGroupAnimation = NO;
        _showTerminateReason = NO;
        _showCertifyView = NO;
        _showShareLocationMessage = NO;
        _startShareLocationOnLocationEnable = NO;
        _showRemoteCameraOnboarding = NO;
        _elapsedTime = 0;
        _keyboardHidden = YES;
        _getDescriptorsDone = NO;
        _hideMenuOnVideoCall = NO;
        _accessCameraGranted = NO;
        _callParticipantViewMode = CallParticipantViewModeSmallLocale;
        _callParticipantViews = [[NSMutableArray alloc]init];
        
        ApplicationDelegate *delegate = (ApplicationDelegate *)[[UIApplication sharedApplication] delegate];
        _callService = delegate.callService;
        _twinmeService = [[AbstractTwinmeService alloc] initWithTwinmeContext:self.twinmeContext tag:LOG_TAG delegate:self];
        _twinmeServiceDelegate = [[AbstractTwinmeContextDelegate alloc] initWithService:self.twinmeService];
        _isGroupCallSubscribed = [delegate.twinmeApplication isSubscribedWithFeature:TLTwinmeApplicationFeatureGroupCall];
        [self.twinmeContext addDelegate:self.twinmeServiceDelegate];
        
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)viewDidLoad {
    DDLogVerbose(@"%@ viewDidLoad %@", LOG_TAG, self);
    
    [self initViews];
    [self initCallPariticipantColor];
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
    self.proximityMonitoringEnabled = [UIDevice currentDevice].isProximityMonitoringEnabled;
    [UIDevice currentDevice].proximityMonitoringEnabled = YES;
    if ([UIDevice currentDevice].proximityMonitoringEnabled) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(proximityChanged) name:UIDeviceProximityStateDidChangeNotification object:nil];
    }
    [super viewDidLoad];
}

- (void)viewDidLayoutSubviews {
    DDLogVerbose(@"%@ viewDidLayoutSubviews", LOG_TAG);
    
    [super viewDidLayoutSubviews];
    
    [self.acceptButton updateGradientBounds];
    [self.declineButton updateGradientBounds];
    [self.cancelButton updateGradientBounds];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"StatusBarOrientationDidChange" object:nil];
    [self setupFrameSize];
    
    if (!self.participantsViewInitialized) {
        self.participantsViewInitialized = YES;
        [self updateParticipantsView];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    DDLogVerbose(@"%@ viewWillAppear: %d self: %@", LOG_TAG, animated, self);
    
    // This call was terminated and we are back, finish the view.
    CallState *call = [self.callService currentCall];
    CallStatus callStatus = call ? [call status] : CallStatusNone;
    if ((callStatus == CallStatusTerminated || callStatus == CallStatusNone) && !self.terminateTimer && !self.showCallQuality && !self.showTerminateReason) {
        [self finish];
        return;
    }
    self.callService.callParticipantDelegate = self;
    
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
    
    if (CALL_IS_ACTIVE(callStatus)) {
        [self setMenuVisible:YES];
        [self addCallParticipantAnimation];
        [self startChronometer];
        [self checkAuthorization];
    }
    [self updateView:callStatus];
    
    if ([self.callService isKeyCheckRunning]) {
        BOOL showCertifyOnboarding = self.callCertifyView ? NO : YES;
        [self startCertifyView:showCertifyOnboarding];
        self.wordCheckChallenge = [self.callService getKeyCheckCurrentWord];
        [self.callCertifyView updateWord:self.wordCheckChallenge];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    DDLogVerbose(@"%@ viewWillDisappear: %@", LOG_TAG, animated ? @"YES" : @"NO");
    
    self.callService.callParticipantDelegate = nil;
    [super viewWillDisappear:animated];
    
    self.navigationController.navigationBarHidden = NO;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
    
    // Stop the terminate timer because if it fires, it pops the current view and this may not be our view.
    if (self.terminateTimer) {
        [self.terminateTimer invalidate];
        self.terminateTimer = nil;
    }
    if (self.chronometer) {
        [self.chronometer invalidate];
        self.chronometer = nil;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    // If we are connected, start the animation.
    self.connected = [self.callService isConnected];
    if (!self.connected && !self.networkAlertView) {
        self.networkAlertView = [[AlertView alloc] initNetWorkAlertWithTitle:TwinmeLocalizedString(@"video_call_view_controller_cannot_call", nil) alertViewDelegate:self twinmeContext:self.twinmeContext viewController:self];
        [self.networkAlertView showNetworkAlertView];
    }
}

- (BOOL)prefersStatusBarHidden {
    
    return YES;
}

#pragma mark - UIViewController (Utils)
- (BOOL)hasLandscapeMode {
    DDLogVerbose(@"%@ hasLandscapeMode", LOG_TAG);
    
    return YES;
}

#pragma mark - Public methods

- (void)initCallWithOriginator:(nonnull id<TLOriginator>)originator isVideoCall:(BOOL)isVideoCall {
    DDLogVerbose(@"%@ initCallWithOriginator: %@", LOG_TAG, originator);
    
    self.originator = originator;
    self.contactName = self.originator.name;
    [self.twinmeService getImageWithContact:originator withBlock:^(UIImage *image) {
        self.contactAvatar = image;
        self.noParticipantsView.image = self.contactAvatar;
    }];
    self.outgoingCall = NO;
    self.isVideoCall = isVideoCall;
    self.isCallStartedInVideo = isVideoCall;
    
    if ([(NSObject *) originator class] == [TLCallReceiver class]) {
        self.isCallReceiver = YES;
    }
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(onMessageConnectionState:) name:CallEventMessageConnectionState object:nil];
    [notificationCenter addObserver:self selector:@selector(onMessageVideoUpdate:) name:CallEventMessageVideoUpdate object:nil];
    [notificationCenter addObserver:self selector:@selector(onMessageAudioSinkUpdate:) name:CallEventMessageAudioSinkUpdate object:nil];
    [notificationCenter addObserver:self selector:@selector(onMessageCameraSwitch:) name:CallEventMessageCameraSwitch object:nil];
    [notificationCenter addObserver:self selector:@selector(onMessageTerminateCall:) name:CallEventMessageTerminateCall object:nil];
    [notificationCenter addObserver:self selector:@selector(onMessageCallOnHold:) name:CallEventMessageCallOnHold object:nil];
    [notificationCenter addObserver:self selector:@selector(onMessageCallResumed:) name:CallEventMessageCallResumed object:nil];
    [notificationCenter addObserver:self selector:@selector(onMessageCallsMerged:) name:CallEventMessageCallsMerged object:nil];
    [notificationCenter addObserver:self selector:@selector(onMessageSharedLocationEnabled:) name:CallEventMessageSharedLocationEnabled object:nil];
    [notificationCenter addObserver:self selector:@selector(onMessageSharedLocationRestricted:) name:CallEventMessageSharedLocationRestricted object:nil];
    [notificationCenter addObserver:self selector:@selector(onMessageLocationServicesDisabled:) name:CallEventMessageLocationServicesDisabled object:nil];
    [notificationCenter addObserver:self selector:@selector(onCameraControlZoomUpdate:) name:CallEventCameraControlZoomUpdate object:nil];
}

- (void)startCallWithOriginator:(nonnull id<TLOriginator>)originator videoBell:(BOOL)videoBell isVideoCall:(BOOL)isVideoCall isCertifyCall:(BOOL)isCertifyCall {
    DDLogVerbose(@"%@ startCallWithOriginator: %@", LOG_TAG, originator);
    
    self.originator = originator;
    self.contactName = self.originator.name;
    [self.twinmeService getImageWithContact:originator withBlock:^(UIImage *image) {
        self.contactAvatar = image;
        self.noParticipantsView.image = self.contactAvatar;
    }];
    self.outgoingCall = YES;
    self.isVideoCall = isVideoCall;
    self.isCallStartedInVideo = isVideoCall;
    self.showCertifyView = isCertifyCall;
    
    if ([(NSObject *) originator class] == [TLCallReceiver class]) {
        self.isCallReceiver = YES;
    }
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(onMessageConnectionState:) name:CallEventMessageConnectionState object:nil];
    [notificationCenter addObserver:self selector:@selector(onMessageVideoUpdate:) name:CallEventMessageVideoUpdate object:nil];
    [notificationCenter addObserver:self selector:@selector(onMessageAudioSinkUpdate:) name:CallEventMessageAudioSinkUpdate object:nil];
    [notificationCenter addObserver:self selector:@selector(onMessageCameraSwitch:) name:CallEventMessageCameraSwitch object:nil];
    [notificationCenter addObserver:self selector:@selector(onMessageTerminateCall:) name:CallEventMessageTerminateCall object:nil];
    [notificationCenter addObserver:self selector:@selector(onMessageCallOnHold:) name:CallEventMessageCallOnHold object:nil];
    [notificationCenter addObserver:self selector:@selector(onMessageCallResumed:) name:CallEventMessageCallResumed object:nil];
    [notificationCenter addObserver:self selector:@selector(onMessageCallsMerged:) name:CallEventMessageCallsMerged object:nil];
    [notificationCenter addObserver:self selector:@selector(onMessageSharedLocationEnabled:) name:CallEventMessageSharedLocationEnabled object:nil];
    [notificationCenter addObserver:self selector:@selector(onMessageSharedLocationRestricted:) name:CallEventMessageSharedLocationRestricted object:nil];
    [notificationCenter addObserver:self selector:@selector(onMessageLocationServicesDisabled:) name:CallEventMessageLocationServicesDisabled object:nil];
    [notificationCenter addObserver:self selector:@selector(onCameraControlZoomUpdate:) name:CallEventCameraControlZoomUpdate object:nil];
    
    [self.callService startCallWithOriginator:originator mode:videoBell ? CallStatusOutgoingVideoBell: isVideoCall ? CallStatusOutgoingVideoCall : CallStatusOutgoingCall viewController:self];
}

- (IBAction)accept:(id)sender {
    DDLogVerbose(@"%@ accept", LOG_TAG);
    
    [self.acceptButton setEnabled:NO];
    
    [self.callService acceptCall];
    [self updateView:[self.callService callStatus]];
}

- (IBAction)decline:(id)sender {
    DDLogVerbose(@"%@ decline", LOG_TAG);
    
    [self.declineButton setEnabled:NO];
    
    [self terminateCallWithTerminateReason:TLPeerConnectionServiceTerminateReasonDecline isHoldCall:NO];
}

- (IBAction)cancel:(id)sender {
    DDLogVerbose(@"%@ cancel", LOG_TAG);
    
    [self.cancelButton setEnabled:NO];
    
    [self terminateCallWithTerminateReason:TLPeerConnectionServiceTerminateReasonCancel isHoldCall:NO];
}

- (IBAction)hangup:(id)sender {
    DDLogVerbose(@"%@ hangup", LOG_TAG);
    
    [self.menuView.hangupButton setEnabled:NO];
    
    CallStatus callStatus = [self.callService callStatus];
    if (CALL_IS_ACTIVE(callStatus)) {
        [self terminateCallWithTerminateReason:TLPeerConnectionServiceTerminateReasonSuccess isHoldCall:!self.callHoldView.isHidden];
    } else {
        [self terminateCallWithTerminateReason:TLPeerConnectionServiceTerminateReasonCancel isHoldCall:!self.callHoldView.isHidden];
    }
}

- (IBAction)cameraMute:(id)sender {
    DDLogVerbose(@"%@ cameraMute: %@", LOG_TAG, sender);
    
    BOOL isVideoAllowed = self.accessCameraGranted && (self.isCallStartedInVideo || (self.originator.capabilities.hasVideo && self.originator.identityCapabilities.hasVideo));
    
    if (!isVideoAllowed) {
        NSString *message = TwinmeLocalizedString(@"application_not_authorized_operation",nil);
        if (self.accessCameraGranted && self.originator.capabilities.hasVideo) {
            message = TwinmeLocalizedString(@"application_not_authorized_operation_by_your_contact",nil);
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication].keyWindow makeToast:message];
        });
        return;
    }
    
    if ([self.participant isRemoteCameraControl] && self.participant.remoteActiveCamera == 0) {
        DefaultConfirmView *defaultConfirmView = [[DefaultConfirmView alloc] init];
        defaultConfirmView.confirmViewDelegate = self;
        defaultConfirmView.forceDarkMode = YES;
        defaultConfirmView.tag = CONTROL_CAMERA_STOP_TAG;
        NSString *message = [NSString stringWithFormat:TwinmeLocalizedString(@"call_view_controller_camera_control_remotely", nil), self.originator.name];
        [defaultConfirmView initWithTitle:TwinmeLocalizedString(@"call_view_controller_camera_control", nil) message:message image:nil avatar:nil action: TwinmeLocalizedString(@"call_view_controller_camera_control_stop", nil) actionColor:Design.DELETE_COLOR_RED cancel:TwinmeLocalizedString(@"application_cancel", nil)];
        [self.view addSubview:defaultConfirmView];
        [defaultConfirmView showConfirmView];
        return;
    }
    
    self.isVideoCall = [self.callService isCameraMuted];
    
    [self.callService setCameraMute:!self.isVideoCall];
    [self updateView:[self.callService callStatus]];
}

- (IBAction)microMute:(id)sender {
    DDLogVerbose(@"%@ microMute: %@", LOG_TAG, sender);
    
    [self.callService setAudioMute:![self.callService isAudioMuted]];
    [self updateView:[self.callService callStatus]];
}

- (IBAction)speakerOn:(id)sender {
    DDLogVerbose(@"%@ speakerOn: %@", LOG_TAG, sender);
    
    if (self.callService.isHeadsetAvailable) {
        // Find the button inside the view and simulate a touch event to display the route selection popup.
        for (UIView *v in self.routePickerView.subviews) {
            if ([v isKindOfClass:[UIButton class]]) {
                [((UIButton *)v) sendActionsForControlEvents:UIControlEventTouchUpInside];
            }
        }
    } else {
        [self.callService setSpeaker:![self.callService isSpeakerOn]];
        [self updateView:[self.callService callStatus]];
    }
}

- (IBAction)certifyRelation:(id)sender {
    DDLogVerbose(@"%@ certifyRelation: %@", LOG_TAG, sender);
        
    CallState *call = [self.callService currentCall];
    if (call && ![call isOneOnOneVideoCall]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication].keyWindow makeToast:TwinmeLocalizedString(@"call_view_controller_certify_video_message", nil)];
        });
        return;
    }
    
    [self startCertifyView:YES];
    [self.callService startKeyCheckWithLanguage:[NSLocale currentLocale]];
    [self.menuView updateMenuState:CallMenuViewStateDefault];
}

- (IBAction)cameraControl:(id)sender {
    DDLogVerbose(@"%@ cameraControl: %@", LOG_TAG, sender);
            
    if ([self isRemoteCameraControl]) {
        DefaultConfirmView *defaultConfirmView = [[DefaultConfirmView alloc] init];
        defaultConfirmView.confirmViewDelegate = self;
        defaultConfirmView.forceDarkMode = YES;
        defaultConfirmView.tag = CONTROL_CAMERA_STOP_TAG;
        
        NSString *message;
        if ([self.participant remoteActiveCamera] > 0) {
            message = [NSString stringWithFormat:TwinmeLocalizedString(@"call_view_controller_camera_control_message", nil), self.originator.name];
        } else {
            message = [NSString stringWithFormat:TwinmeLocalizedString(@"call_view_controller_camera_control_remotely", nil), self.originator.name];
        }
        
        [defaultConfirmView initWithTitle:TwinmeLocalizedString(@"call_view_controller_camera_control", nil) message:message image:nil avatar:nil action: TwinmeLocalizedString(@"call_view_controller_camera_control_stop", nil) actionColor:Design.DELETE_COLOR_RED cancel:TwinmeLocalizedString(@"application_cancel", nil)];
        [self.view addSubview:defaultConfirmView];
        [defaultConfirmView showConfirmView];
    } else {
        if (self.isGroupCallSubscribed) {
            if (self.originator.capabilities.zoomable == TLVideoZoomableAsk) {
                if ([self.twinmeApplication startOnboarding:OnboardingTypeRemoteCamera] && !self.showRemoteCameraOnboarding) {
                    [self showCameraControlOnboarding];
                    return;
                }
                
                DefaultConfirmView *defaultConfirmView = [[DefaultConfirmView alloc] init];
                defaultConfirmView.confirmViewDelegate = self;
                defaultConfirmView.forceDarkMode = YES;
                defaultConfirmView.tag = CONTROL_CAMERA_ASK_TAG;
                NSString *message = [NSString stringWithFormat:TwinmeLocalizedString(@"call_view_controller_camera_control_ask_message", nil), self.originator.name];
                [defaultConfirmView initWithTitle:TwinmeLocalizedString(@"call_view_controller_camera_control", nil) message:message image:nil avatar:nil action: TwinmeLocalizedString(@"application_confirm", nil) actionColor:nil cancel:TwinmeLocalizedString(@"application_cancel", nil)];
                [self.view addSubview:defaultConfirmView];
                [defaultConfirmView showConfirmView];
            } else if (self.originator.capabilities.zoomable == TLVideoZoomableAllow) {
                [self.participant remoteAskControl];
            }
        } else {
            if ([self.twinmeApplication startOnboarding:OnboardingTypeRemoteCamera] && !self.showRemoteCameraOnboarding) {
                [self showCameraControlOnboarding];
            } else {
                [self showPremiumFeature:FeatureTypeGroupCall];
            }
        }
    }
        
    [self.menuView updateMenuState:CallMenuViewStateDefault];
}

- (IBAction)addCallParticipant:(id)sender {
    DDLogVerbose(@"%@ addCallParticipant", LOG_TAG);
    
    [self.twinmeApplication hideGroupCallAnimation];
    [self.addParticipantImageView.layer removeAllAnimations];
    
    CallState *callState = [self.callService currentCall];
    if (!self.isGroupCallSubscribed) {
        [self showPremiumFeature:FeatureTypeGroupCall];
        return;
    } else if (callState && self.callParticipantViews.count == 2 && [[callState mainParticipant] isGroupSupported] == CallGroupSupportNo) {
        AlertMessageView *alertMessageView = [[AlertMessageView alloc] init];
        alertMessageView.alertMessageViewDelegate = self;
        [alertMessageView initWithTitle:TwinmeLocalizedString(@"delete_account_view_controller_warning", nil) message:[NSString stringWithFormat:TwinmeLocalizedString(@"call_view_controller_not_supported_group_call_message", nil), [[callState mainParticipant] name]]];
        [self.navigationController.view addSubview:alertMessageView];
        [alertMessageView showAlertView];
        return;
    } else if (callState && self.callParticipantViews.count >= callState.maxMemberCount && callState.maxMemberCount != 0) {
        AlertMessageView *alertMessageView = [[AlertMessageView alloc] init];
        alertMessageView.alertMessageViewDelegate = self;
        [alertMessageView initWithTitle:TwinmeLocalizedString(@"delete_account_view_controller_warning", nil) message:[NSString stringWithFormat:TwinmeLocalizedString(@"call_view_controller_max_participant_message", nil), callState.maxMemberCount]];
        [self.navigationController.view addSubview:alertMessageView];
        [alertMessageView showAlertView];
        return;
    }
    
    NSMutableArray *participantsUUID = [[NSMutableArray alloc]init];
    for (AbstractCallParticipantView *callParticipantView in self.callParticipantViews) {
        if ([callParticipantView getCallParticipant]) {
            CallParticipant *callParticipant = [callParticipantView getCallParticipant];
            [participantsUUID addObject:callParticipant.participantPeerTwincodeOutboundId];
        }
    }
    
    AddCallParticipantViewController *addCallParticipantViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AddCallParticipantViewController"];
    addCallParticipantViewController.participantsUUID = participantsUUID;
    addCallParticipantViewController.maxMemberCount = MAX_CALL_GROUP_PARTICIPANTS;
    addCallParticipantViewController.addCallParticipantDelegate = self;
    TwinmeNavigationController *navigationController = [[TwinmeNavigationController alloc]initWithRootViewController:addCallParticipantViewController];
    [self.navigationController presentViewController:navigationController animated:YES completion:nil];
}

- (IBAction)addStreamingAudio:(id)sender {
    DDLogVerbose(@"%@ addStreamingAudio", LOG_TAG);
    
    [self.menuView updateMenuState:CallMenuViewStateDefault];
    
    if (!self.isGroupCallSubscribed) {
        [self showPremiumFeature:FeatureTypeStreaming];
        return;
    }
    
    StreamingAudioViewController *streamingAudioViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"StreamingAudioViewController"];
    TwinmeNavigationController *upgradeNavigationController = [[TwinmeNavigationController alloc]initWithRootViewController:streamingAudioViewController];
    [self.navigationController presentViewController:upgradeNavigationController animated:YES completion:nil];
}

- (IBAction)shareInvitation:(id)sender {
    DDLogVerbose(@"%@ shareInvitation", LOG_TAG);
    
    [self.twinmeService getImageWithProfile:self.currentSpace.profile withBlock:^(UIImage *image) {
        InvitationCodeConfirmView *invitationCodeConfirmView = [[InvitationCodeConfirmView alloc] init];
        invitationCodeConfirmView.confirmViewDelegate = self;
        invitationCodeConfirmView.forceDarkMode = YES;
        [invitationCodeConfirmView initWithTitle:self.currentSpace.profile.name message:TwinmeLocalizedString(@"group_member_view_controller_invite_personnal_relation", nil) avatar:image icon:[UIImage imageNamed:@"ActionBarAddContact"]];
        [invitationCodeConfirmView setConfirmTitle:TwinmeLocalizedString(@"add_contact_view_controller_invite", nil)];
        [self.view addSubview:invitationCodeConfirmView];
        [invitationCodeConfirmView showConfirmView];
        
        [self.menuView updateMenuState:CallMenuViewStateDefault];
    }];
}

- (IBAction)pauseCall:(id)sender {
    DDLogVerbose(@"%@ pauseCall", LOG_TAG);
    
    [self.menuView updateMenuState:CallMenuViewStateDefault];
    
    if (CALL_IS_PAUSED(self.callService.callStatus)) {
        [self.callService resumeCall];
    } else {
        [self.callService putCallOnHold];
    }
    
    [self updateMenu];
}

- (IBAction)openConversation:(id)sender {
    DDLogVerbose(@"%@ openConversation", LOG_TAG);
    
    [self.conversationView reloadData];
    self.conversationView.hidden = NO;
    self.unreadMessageImageView.image = [UIImage imageNamed:@"CallMessageIcon"];
    [self.view bringSubviewToFront:self.conversationView];
    [self.view bringSubviewToFront:self.menuView];
    
    [self.menuView updateMenuState:CallMenuViewStateDefault];
}

- (IBAction)openMap:(id)sender {
    DDLogVerbose(@"%@ openMap", LOG_TAG);
    
    [self initMap:YES];
}

- (IBAction)shareLocation:(id)sender {
    DDLogVerbose(@"%@ shareLocation", LOG_TAG);
    
    if ([self.callService isLocationStartShared]) {
        [self stopShareLocation];
        [self.menuView updateMenuState:CallMenuViewStateDefault];
    } else {
        [self initMap:NO];
        if ([self.callService canDeviceShareLocation]) {
            MKCoordinateRegion region = [self.mapView getMapRegion];
            [self startShareLocation:region.span.latitudeDelta mapLongitudeDelta:region.span.longitudeDelta];
        } else {
            self.startShareLocationOnLocationEnable = YES;
        }
    }
}

- (void)initMap:(BOOL)showMap {
    DDLogVerbose(@"%@ initMap: %@", LOG_TAG, showMap ? @"YES" : @"NO");
    
    [self.conversationView dismissKeyboard];
    
    if (!self.mapView) {
        self.mapView = [[CallMapView alloc]init];
        self.mapView.callMapDelegate = self;
        self.mapView.avatar = self.callParticipantLocaleView.avatar;
        self.mapView.name = self.callParticipantLocaleView.name;
        [self.view addSubview:self.mapView];

        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.mapView
                                                                  attribute:NSLayoutAttributeWidth
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.view
                                                                  attribute:NSLayoutAttributeWidth
                                                                 multiplier:1.0
                                                                   constant:0]];
        
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.mapView
                                                                  attribute:NSLayoutAttributeLeading
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.view
                                                                  attribute:NSLayoutAttributeLeading
                                                                 multiplier:1.0
                                                                   constant:0]];
        
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.mapView
                                                                  attribute:NSLayoutAttributeTrailing
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.view
                                                                  attribute:NSLayoutAttributeTrailing
                                                                 multiplier:1.0
                                                                   constant:0]];
        
        self.mapViewBottomConstraint = [NSLayoutConstraint constraintWithItem:self.mapView
                                                                    attribute:NSLayoutAttributeBottom
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:self.conversationView
                                                                    attribute:NSLayoutAttributeBottom
                                                                   multiplier:1.0
                                                                     constant:0];
        
        [self.view addConstraint:self.mapViewBottomConstraint];
        
        self.mapViewTopConstraint = [NSLayoutConstraint constraintWithItem:self.mapView
                                                                 attribute:NSLayoutAttributeTop
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.headerView
                                                                 attribute:NSLayoutAttributeBottom
                                                                multiplier:1.0
                                                                  constant:0];
        
        [self.view addConstraint:self.mapViewTopConstraint];
        
        self.mapViewFullScreenBottomConstraint = [NSLayoutConstraint constraintWithItem:self.mapView
                                                                    attribute:NSLayoutAttributeBottom
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:self.view
                                                                    attribute:NSLayoutAttributeBottom
                                                                   multiplier:1.0
                                                                     constant:0];
                
        self.mapViewFullScreenTopConstraint = [NSLayoutConstraint constraintWithItem:self.mapView
                                                                 attribute:NSLayoutAttributeTop
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.view
                                                                 attribute:NSLayoutAttributeTop
                                                                multiplier:1.0
                                                                  constant:0];
        
        self.mapView.frame = self.conversationView.frame;
        [self.mapView loadViews];
        
        CallState *callState = [self.callService currentCall];
        if (callState) {
            NSArray<CallParticipant *> *participants = [callState getParticipants];
            for (CallParticipant *callParticipant in participants) {
                if (callParticipant.currentGeolocation) {
                    [self.mapView updateLocation:callParticipant geolocationDescriptor:callParticipant.currentGeolocation];
                }
            }
            
            if (callState.currentGeolocation) {
                self.mapView.isLocationShared = YES;
                [self.mapView updateLocaleLocation:callState.currentGeolocation.latitude longitude:callState.currentGeolocation.longitude];
            } else if ([self.callService getCurrentLocation]) {
                CLLocation *currentLocation = [self.callService getCurrentLocation];
                [self.mapView updateLocaleLocation:currentLocation.coordinate.latitude longitude:currentLocation.coordinate.longitude];
            }
        }
        
        [self.callService initShareLocation];
    } else if (![self.callService canDeviceShareLocation]) {
        [self.callService initShareLocation];
    }
    
    self.mapView.canShareLocation = [self.callService canDeviceShareLocation];
    self.mapView.canShareBackgroundLocation = [self.callService canDeviceShareBackgroundLocation];
    [self.mapView initMapView];
    
    self.mapView.hidden = !showMap;
    [self.view bringSubviewToFront:self.mapView];
    [self.view bringSubviewToFront:self.menuView];
    
    [self.menuView updateMenuState:CallMenuViewStateDefault];
}

- (void)proximityChanged {
    DDLogVerbose(@"%@ proximityChanged", LOG_TAG);
    
    if ([[UIDevice currentDevice] proximityState] && [self.callService isSpeakerOn]) {
        self.isSpeakerOnBeforeProximityUpdate = YES;
        [self.callService setSpeaker:NO];
        [self updateView:[self.callService callStatus]];
    } else if (![[UIDevice currentDevice] proximityState]) {
        if (self.isSpeakerOnBeforeProximityUpdate) {
            self.isSpeakerOnBeforeProximityUpdate = NO;
            [self.callService setSpeaker:YES];
            [self updateView:[self.callService callStatus]];
        }
    }
}

- (void)back {
    DDLogVerbose(@"%@ back", LOG_TAG);
    
    [self finish];
    
    CallState *call = [self.callService currentCall];
    if (!call) {
        return;
    }
    
    CallStatus callStatus = [call status];
    if (CALL_IS_ACTIVE(callStatus)) {
        ApplicationDelegate *delegate = (ApplicationDelegate *)[[UIApplication sharedApplication] delegate];
        MainViewController *mainViewController = delegate.mainViewController;
        [mainViewController initCallFloatingViewWithCall:call];
    }
}

#pragma mark - RTCVideoViewDelegate

- (void)videoView:(id<RTC_OBJC_TYPE(RTCVideoRenderer)>)videoView didChangeVideoSize:(CGSize)size {
    DDLogVerbose(@"%@ videoView: %@ didChangeVideoSize: %@", LOG_TAG, videoView, NSStringFromCGSize(size));
    
}

#pragma mark - AbstractTwinmeServiceDelegate

- (void)onConnectionStatusChange:(TLConnectionStatus)connectionStatus {
    DDLogVerbose(@"%@ onConnectionStatusChange: %d", LOG_TAG, connectionStatus);
    
    if (connectionStatus == TLConnectionStatusConnected) {
        // Hide and shutdown the network alert timer.
        if (self.networkAlertView) {
            [self.networkAlertView dispose];
            self.networkAlertView = nil;
        }
        self.connected = YES;
    } else {
        self.connected = NO;
    }
}

- (void)onErrorWithErrorCode:(TLBaseServiceErrorCode)errorCode errorParameter:(NSString *)errorParameter {
    DDLogVerbose(@"%@ onErrorWithErrorCode: %d errorParameter: %@", LOG_TAG, errorCode, errorParameter);
    
    if (self.chronometer) {
        [self.chronometer invalidate];
        self.chronometer = nil;
    }
    
    if (errorCode == TLBaseServiceErrorCodeItemNotFound) {
        return;
    }
    
    if (self.uiInitialized && !self.networkAlertView) {
        AlertMessageView *alertMessageView = [[AlertMessageView alloc] init];
        alertMessageView.tag = TERMINATE_ALERT_VIEW_TAG;
        alertMessageView.alertMessageViewDelegate = self;
        alertMessageView.forceDarkMode = YES;
        [alertMessageView initWithTitle:TwinmeLocalizedString(@"application_error", nil) message:TwinmeLocalizedString(@"application_operation_failure", nil)];
        [self.view addSubview:alertMessageView];
        [alertMessageView showAlertView];
    }
}

#pragma mark - InAppSubscriptionViewControllerDelegate

- (void)onSubscribeSuccess {
    DDLogVerbose(@"%@ onSubscribeSuccess", LOG_TAG);
    
    ApplicationDelegate *delegate = (ApplicationDelegate *)[[UIApplication sharedApplication] delegate];
    self.isGroupCallSubscribed = [delegate.twinmeApplication isSubscribedWithFeature:TLTwinmeApplicationFeatureGroupCall];
    
    if (self.isGroupCallSubscribed) {
        CallState *callState = [self.callService currentCall];
        [self updateView:callState.status];
        if (callState && self.callParticipantViews.count == 2 && [[callState mainParticipant] isGroupSupported] == CallGroupSupportNo) {
            AlertMessageView *alertMessageView = [[AlertMessageView alloc] init];
            alertMessageView.alertMessageViewDelegate = self;
            [alertMessageView initWithTitle:TwinmeLocalizedString(@"delete_account_view_controller_warning", nil) message:[NSString stringWithFormat:TwinmeLocalizedString(@"call_view_controller_not_supported_group_call_message", nil), [[callState mainParticipant] name]]];
            [self.view addSubview:alertMessageView];
            [alertMessageView showAlertView];
            return;
        } else if (callState && self.callParticipantViews.count >= callState.maxMemberCount && callState.maxMemberCount != 0) {
            AlertMessageView *alertMessageView = [[AlertMessageView alloc] init];
            alertMessageView.alertMessageViewDelegate = self;
            [alertMessageView initWithTitle:TwinmeLocalizedString(@"delete_account_view_controller_warning", nil) message:[NSString stringWithFormat:TwinmeLocalizedString(@"call_view_controller_max_participant_message", nil), callState.maxMemberCount]];
            [self.view addSubview:alertMessageView];
            [alertMessageView showAlertView];
            return;
        }
        
        NSMutableArray *participantsUUID = [[NSMutableArray alloc]init];
        for (AbstractCallParticipantView *callParticipantView in self.callParticipantViews) {
            if ([callParticipantView getCallParticipant]) {
                CallParticipant *callParticipant = [callParticipantView getCallParticipant];
                [participantsUUID addObject:callParticipant.participantPeerTwincodeOutboundId];
            }
        }
        
        AddCallParticipantViewController *addCallParticipantViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AddCallParticipantViewController"];
        addCallParticipantViewController.participantsUUID = participantsUUID;
        addCallParticipantViewController.maxMemberCount = callState.maxMemberCount;
        addCallParticipantViewController.addCallParticipantDelegate = self;
        TwinmeNavigationController *navigationController = [[TwinmeNavigationController alloc]initWithRootViewController:addCallParticipantViewController];
        [self.navigationController presentViewController:navigationController animated:YES completion:nil];
    }
}

#pragma mark - CallParticipantDelegate

- (void)onAddWithParticipant:(nonnull CallParticipant *)participant {
    DDLogVerbose(@"%@ onAddWithParticipant: %@", LOG_TAG, participant);
    
    // TODO: we can optimize the add of new participant instead of guessing what must be refreshed.
    [self updateCallParticipantView];
}

- (void)onRemoveWithParticipants:(nonnull NSArray<CallParticipant *> *)participants {
    DDLogVerbose(@"%@ onRemoveWithParticipants: %@", LOG_TAG, participants);
    
    [self updateCallParticipantView];
    
    for (AbstractCallParticipantView *cpv in self.callParticipantViews) {
        if (![cpv isMainParticipant]) {
            [self.participantsView bringSubviewToFront:cpv];
        }
    }
}

- (void)onEventWithParticipant:(nonnull CallParticipant *)participant event:(CallParticipantEvent)event {
    DDLogVerbose(@"%@ onEventWithParticipant: %@", LOG_TAG, participant);
    
    if (!self.uiInitialized) {
        return;
    }
    
    AbstractCallParticipantView *callParticipantView = [self getParticipantView:participant];
    if (!callParticipantView) {
        return;
    }
        
    switch (event) {
        case CallParticipantEventConnected:
            [self updateView:[self.callService callStatus]];
            break;
            
        case CallParticipantEventIdentity:
            if ([callParticipantView isRemoteParticipant]) {
                CallParticipantRemoteView *callParticipantRemoteView = (CallParticipantRemoteView *)callParticipantView;
                callParticipantRemoteView.callParticipant = participant;
                [callParticipantView updateViews];
            }
            
            break;
            
        case CallParticipantEventAudioOn:
        case CallParticipantEventAudioOff:
        case CallParticipantEventVideoOn:
        case CallParticipantEventVideoOff:
        case CallParticipantEventHold:
        case CallParticipantEventResume:
            [self updateMenu];
            [callParticipantView updateViews];
            
            if (@available(iOS 16.0, *)) {
                [self setNeedsUpdateOfSupportedInterfaceOrientations];
            }
            
            break;
            
        case CallParticipantEventAskCameraControl:
        case CallParticipantEventCameraControlDenied:
        case CallParticipantEventCameraControlGranted:
        case CallParticipantEventCameraControlDone:
            if ([callParticipantView isRemoteParticipant]) {
                CallParticipantRemoteView *callParticipantRemoteView = (CallParticipantRemoteView *)callParticipantView;
                callParticipantRemoteView.callParticipant = participant;
            }
            
            [self updateCameraControl:participant event:event];
            [callParticipantView updateViews];
            break;
            
        case CallParticipantEventStreamStart:
        case CallParticipantEventStreamInfo:
        case CallParticipantEventStreamStop:
        case CallParticipantEventStreamPause:
        case CallParticipantEventStreamResume:
        case CallParticipantEventStreamStatus:
            [self updateStreamingPlayer:participant event:event];
            break;
            
        case CallParticipantEventKeyCheckInitiate:
        case CallParticipantEventOnKeyCheckInitiate:
        case CallParticipantEventCurrentWordChanged:
        case CallParticipantEventWordCheckResultKO:
        case CallParticipantEventTerminateKeyCheck:
            [self updateCertifyView:event];
            break;
            
        case CallParticipantEventScreenSharingOn:
            if ([callParticipantView isRemoteParticipant]) {
                CallParticipantRemoteView *callParticipantRemoteView = (CallParticipantRemoteView *)callParticipantView;
                callParticipantRemoteView.callParticipant = participant;
                [self didTapFullScreenSharingScreenCallParticipantView:callParticipantRemoteView];
            }
            break;
            
        case CallParticipantEventScreenSharingOff:
            if ([callParticipantView isRemoteParticipant]) {
                CallParticipantRemoteView *callParticipantRemoteView = (CallParticipantRemoteView *)callParticipantView;
                callParticipantRemoteView.callParticipant = participant;
                [self didTapMinimizeSharingScreenCallParticipantView:callParticipantRemoteView];
            }
           
            break;
            
        default:
            break;
    }
}

- (void)onStreamingEventWithParticipant:(nullable CallParticipant *)participant event:(StreamingEvent)event {
    DDLogVerbose(@"%@ onStreamingEventWithParticipant: %@ event: %d", LOG_TAG, participant, event);
    
    if (!self.uiInitialized) {
        return;
    }
    
    BOOL needsUpdateParticipants = NO;
    
    switch (event) {
        case StreamingEventPaused:
            [self.playerStreamingAudioView pauseStreaming];
            break;
            
        case StreamingEventPlaying:
        case StreamingEventStart:
            [self.playerStreamingAudioView resumeStreaming];
            break;
            
        case StreamingEventStop:
        case StreamingEventCompleted:
            needsUpdateParticipants = YES;
            self.streamPlayer = nil;
            [self.playerStreamingAudioView stopStreaming];
            break;
            
        case StreamingEventError:
            needsUpdateParticipants = YES;
            self.streamPlayer = nil;
            [self.playerStreamingAudioView stopStreaming];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [[UIApplication sharedApplication].keyWindow makeToast:TwinmeLocalizedString(@"streaming_audio_view_controller_error_message", nil)];
            });
            break;
            
        case StreamingEventUnsupported: {
            needsUpdateParticipants = YES;
            self.streamPlayer = nil;
            [self.playerStreamingAudioView stopStreaming];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [[UIApplication sharedApplication].keyWindow makeToast:[NSString stringWithFormat:TwinmeLocalizedString(@"streaming_audio_view_controller_unsupported_message", nil), self.contactName]];
            });
        }
            break;
            
        default:
            break;
    }
    
    if (needsUpdateParticipants) {
        [UIView animateWithDuration:0.5 animations:^{
            if (self.streamPlayer) {
                self.playerStreamingAudioView.hidden = NO;
                [self.playerStreamingAudioView setSound:self.streamPlayer.title artwork:self.streamPlayer.artwork];
            } else {
                self.playerStreamingAudioView.hidden = YES;
            }
            
            [self updateParticipantsViewConstraint];
            
            [self.view setNeedsLayout];
            [self.view layoutIfNeeded];
            
            if (self.participantsViewInitialized) {
                [self updateParticipantsView];
            }
        }];
    }
}

- (void)onPopDescriptorWithParticipant:(nonnull CallParticipant *)participant descriptor:(nonnull TLDescriptor *)descriptor {
    DDLogVerbose(@"%@ onPopDescriptorWithParticipant: %@ descriptor: %@", LOG_TAG, participant, descriptor);

    if ([descriptor isKindOfClass:[TLGeolocationDescriptor class]]) {
        self.sharedLocationView.hidden = NO;
        
        if (self.unreadMessageView.hidden) {
            self.sharedLocationViewTrailingConstraint.constant = self.headerViewHeightConstraint.constant;
        } else {
            self.sharedLocationViewTrailingConstraint.constant = 0;
        }
        
        [self hapticFeedBack:UIImpactFeedbackStyleMedium];
        
        if (self.mapView) {
            [self.mapView updateLocation:participant geolocationDescriptor:(TLGeolocationDescriptor *)descriptor];
        }
        
        AbstractCallParticipantView *callParticipantView = [self getParticipantView:participant];
        if (!callParticipantView) {
            return;
        }
        
        if ([callParticipantView isRemoteParticipant]) {
            CallParticipantRemoteView *callParticipantRemoteView = (CallParticipantRemoteView *)callParticipantView;
            callParticipantRemoteView.callParticipant = participant;
            [callParticipantView updateViews];
        }
    } else {
        self.unreadMessageView.hidden = NO;
        self.sharedLocationViewTrailingConstraint.constant = 0;
        
        if (self.conversationView.hidden) {
            self.unreadMessageImageView.image = [UIImage imageNamed:@"CallNewMessageIcon"];
            [self hapticFeedBack:UIImpactFeedbackStyleMedium];
        }
        
        [self.conversationView addDescriptor:descriptor isLocal:NO needsReload:YES name:participant.name];
    }
}

- (void)onUpdateGeolocationWithParticipant:(nonnull CallParticipant *)participant descriptor:(nonnull TLGeolocationDescriptor *)descriptor {
    DDLogVerbose(@"%@ onUpdateGeolocationWithParticipant: %@ descriptor: %@", LOG_TAG, participant, descriptor);

    self.sharedLocationView.hidden = NO;
    
    if (self.mapView) {
        [self.mapView updateLocation:participant geolocationDescriptor:descriptor];
    }
}

- (void)onDeleteDescriptorWithParticipant:(nonnull CallParticipant *)participant descriptorId:(nonnull TLDescriptorId *)descriptorId {
    DDLogVerbose(@"%@ onDeleteDescriptorWithParticipant: %@ descriptorId: %@", LOG_TAG, participant, descriptorId);

    if (self.mapView) {
        [self.mapView deleteLocation:participant.participantId];
    }
    
    AbstractCallParticipantView *callParticipantView = [self getParticipantView:participant];
    if (!callParticipantView) {
        return;
    }
    
    if ([callParticipantView isRemoteParticipant]) {
        CallParticipantRemoteView *callParticipantRemoteView = (CallParticipantRemoteView *)callParticipantView;
        callParticipantRemoteView.callParticipant = participant;
        [callParticipantView updateViews];
    }
}

#pragma mark - CallServiceMessages

- (void)onMessageConnectionState:(nonnull NSNotification *)notification {
    DDLogVerbose(@"%@ onMessageConnectionState: %@", LOG_TAG, notification);
    
    CallState *callState = [self.callService currentCall];
    
    if ([callState getTransferDirection] == TO_BROWSER) {
        [self callIsTransfered];
        return;
    }
    
    CallStatus callStatus = [self.callService callStatus];
    if (CALL_IS_ACTIVE(callStatus)) {
        [self updateView:callStatus];
        
        if (!self.hideMenuOnVideoCall) {
            [self setMenuVisible:YES];
        }
        
        [self addCallParticipantAnimation];
        [self startChronometer];
        
        dispatch_time_t startCertifyTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(DELAY_START_CERTIFY * NSEC_PER_SEC));
        dispatch_after(startCertifyTime, dispatch_get_main_queue(), ^(void){
            if (self.showCertifyView) {
                self.showCertifyView = NO;
                [self startCertifyView:YES];
                [self.callService startKeyCheckWithLanguage:[NSLocale currentLocale]];
            }
        });
        
        if (self.isCallStartedInVideo && !self.hideMenuOnVideoCall) {
            dispatch_time_t hideMenuTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(DELAY_HIDE_MENU_VIDEO_CALL * NSEC_PER_SEC));
            dispatch_after(hideMenuTime, dispatch_get_main_queue(), ^(void){
                self.hideMenuOnVideoCall = YES;
                [self setMenuVisible:NO];
            });
        }
    }
    
    [self checkAuthorization];
}

- (void)onMessageVideoUpdate:(nonnull NSNotification *)notification {
    DDLogVerbose(@"%@ onMessageVideoUpdate: %@", LOG_TAG, notification);
    
    CallState *call = [self.callService currentCall];
    
    if (self.uiInitialized) {
        
        if (!self.participant) {
            self.participant = [call mainParticipant];
        }
        
        [self.participant detachRenderer];
        
        // If we are in reverse video and the peer turned OFF the camera, switch batch to
        // displaying the camera in the local video view rectangle.
        if (self.reverseVideo && [self.participant isVideoMute]) {
            self.reverseVideo = NO;
        }
        
        [self updateView:[self.callService callStatus]];
    }
}

- (void)onMessageAudioSinkUpdate:(nonnull NSNotification *)notification {
    DDLogVerbose(@"%@ onMessageAudioSinkUpdate: %@", LOG_TAG, notification);
    
    [self updateMenu];
}

- (void)onMessageTerminateCall:(nonnull NSNotification *)notification {
    DDLogVerbose(@"%@ onMessageTerminateCall: %@", LOG_TAG, notification);
    
    CallEventMessage *message = notification.object;
    if (!message) {
        return;
    }
    
    if ([self.callService getCurrentLocation]) {
        [self.callService stopShareLocation:YES];
    }
    
    CallState *activeCall = [self.callService currentCall];
    
    if ((activeCall && ![activeCall.uuid isEqual:message.callId]) || [self.callService currentHoldCall]) {
        if (!self.callHoldView.hidden) {
            self.callHoldView.hidden = YES;
            [self.menuView.hangupButton setEnabled:YES];
            [self animateMenu:YES];
        }
        return;
    }
    
    if (self.uiInitialized) {
        [self updateView:message.callStatus];
    }
    
    if (self.showCallQuality) {
        return;
    }
    
    if (self.chronometer) {
        [self.chronometer invalidate];
        self.chronometer = nil;
    }
    
    // The peer closed the connection, display a message on the view and prepare to close it.
    if (message.terminateReason == TLPeerConnectionServiceTerminateReasonSuccess) {
        [self updateView:CallStatusTerminated];
        self.terminatedLabel.text = [NSString stringWithFormat:TwinmeLocalizedString(@"video_call_view_controller_terminate_success %@", nil), self.contactName];
        [self.terminatedLabel sizeToFit];
        
        self.showCallQuality = [self.twinmeApplication askCallQualityWithCallDuration:self.elapsedTime];
        if (self.showCallQuality) {
            CallQualityView *callQualityView = [[CallQualityView alloc]initWithDelegate:self];
            [callQualityView showInView:self];
        } else {
            self.terminateTimer = [NSTimer scheduledTimerWithTimeInterval:CLOSE_DELAY target:self selector:@selector(terminateFire:) userInfo:nil repeats:NO];
        }
        
        return;
    }
    
    // When the call was handled by the iOS UI, the AudioCallViewController was created but not displayed.
    // We must release its instance now to avoid memory leaks.
    if (!self.uiInitialized && message.terminateReason != TLPeerConnectionServiceTerminateReasonSchedule) {
        [self finish];
    } else if (message.terminateReason == TLPeerConnectionServiceTerminateReasonTransferDone) {
        [self callIsTransfered];
        self.terminateTimer = [NSTimer scheduledTimerWithTimeInterval:CLOSE_DELAY target:self selector:@selector(terminateFire:) userInfo:nil repeats:NO];
    } else if (!self.networkAlertView) {
        self.showTerminateReason = YES;
        self.terminatedLabel.text = @"";
        
        AlertMessageView *alertMessageView = [[AlertMessageView alloc] init];
        alertMessageView.tag = TERMINATE_ALERT_VIEW_TAG;
        alertMessageView.alertMessageViewDelegate = self;
        alertMessageView.forceDarkMode = YES;
        [alertMessageView initWithTitle:[self titleWithTerminateReason:message.terminateReason] message:[self messageWithTerminateReason:message.terminateReason]];
        [self.view addSubview:alertMessageView];
        [alertMessageView showAlertView];
    }
}

- (void)onMessageCameraSwitch:(nonnull NSNotification *)notification {
    DDLogVerbose(@"%@ onMessageCameraSwitch: %@", LOG_TAG, notification);
    
    if (self.callParticipantLocaleView) {
        [self.callParticipantLocaleView enableFrontCamera:self.callService.isFrontCamera];
        [self.callParticipantLocaleView updateViews];
    }
}

- (void)onMessageCallOnHold:(nonnull NSNotification *)notification {
    DDLogVerbose(@"%@ onMessageCallOnHold: %@", LOG_TAG, notification);
    
    if (self.uiInitialized) {
        [self updateView:[self.callService callStatus]];
    }
}

- (void)onMessageCallResumed:(nonnull NSNotification *)notification {
    DDLogVerbose(@"%@ onMessageCallResumed: %@", LOG_TAG, notification);
    
    if (self.uiInitialized) {
        [self updateView:[self.callService callStatus]];
    }
}

- (void)onMessageCallsMerged:(nonnull NSNotification *)notification {
    DDLogVerbose(@"%@ onMessageCallsMerged: %@", LOG_TAG, notification);
    
    if (self.uiInitialized) {
        [self updateView:[self.callService callStatus]];
    }
}

- (void)onMessageSharedLocationEnabled:(nonnull NSNotification *)notification {
    DDLogVerbose(@"%@ onMessageSharedLocationEnabled: %@", LOG_TAG, notification);
    
    if (self.uiInitialized && self.mapView) {
    
        if (self.startShareLocationOnLocationEnable && [self.callService canDeviceShareLocation]) {
            self.startShareLocationOnLocationEnable = NO;
            
            MKCoordinateRegion region = [self.mapView getMapRegion];
            [self startShareLocation:region.span.latitudeDelta mapLongitudeDelta:region.span.longitudeDelta];
        }
        
        CLLocation *currentLocation = [self.callService getCurrentLocation];
        if (currentLocation) {
            [self.mapView updateLocaleLocation:currentLocation.coordinate.latitude longitude:currentLocation.coordinate.longitude];
        }
        
        self.mapView.isLocationShared = [self.callService isLocationStartShared];
        self.mapView.canShareLocation = [self.callService canDeviceShareLocation];
        self.mapView.canShareBackgroundLocation = [self.callService canDeviceShareBackgroundLocation];
        self.mapView.canShareFineLocation = [self.callService isExactLocation];
        
        if ([self.callService isLocationStartShared]) {
            self.sharedLocationImageView.image = [UIImage imageNamed:@"ShareLocationIcon"];
            
            if (self.showShareLocationMessage) {
                self.showShareLocationMessage = NO;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[UIApplication sharedApplication].keyWindow makeToast:TwinmeLocalizedString(@"call_view_controller_location_share_message", nil)];
                });
            }
            
        } else {
            self.sharedLocationImageView.image = [UIImage imageNamed:@"CallLocationIcon"];
            self.sharedLocationImageView.image = [self.sharedLocationImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            self.sharedLocationImageView.tintColor = [UIColor whiteColor];
        }
        
        [self.mapView initMapView];
    }
}

- (void)onMessageSharedLocationRestricted:(nonnull NSNotification *)notification {
    DDLogVerbose(@"%@ onMessageSharedLocationRestricted: %@", LOG_TAG, notification);
    
    if (self.uiInitialized) {
        [DeviceAuthorization showLocationSettingsAlertInController:self];
        
        self.mapView.isLocationShared = NO;
        self.mapView.canShareLocation = NO;        
    }
}

- (void)onMessageLocationServicesDisabled:(nonnull NSNotification *)notification {
    DDLogVerbose(@"%@ onMessageLocationServicesDisabled: %@", LOG_TAG, notification);
    
    if (self.uiInitialized) {
        self.mapView.isLocationShared = NO;
        self.mapView.canShareLocation = NO;
        
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(DELAY_LOCATION_SERVICES_ALERT * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            AlertMessageView *alertMessageView = [[AlertMessageView alloc] init];
            alertMessageView.alertMessageViewDelegate = self;
            [alertMessageView initWithTitle:TwinmeLocalizedString(@"delete_account_view_controller_warning", nil) message:TwinmeLocalizedString(@"call_view_controller_location_services_disabled", nil)];
            [self.view addSubview:alertMessageView];
            [alertMessageView showAlertView];
        });
    }
}

- (void)onCameraControlZoomUpdate:(nonnull NSNotification *)notification {
    DDLogVerbose(@"%@ onCameraControlZoomUpdate: %@", LOG_TAG, notification);
    
    if (self.uiInitialized) {
        AVCaptureDevice *captureDevice = [self getCaptureDevice];
        if (captureDevice) {
            AVCaptureDeviceFormat *format = captureDevice.activeFormat;
            
            CGFloat maxZoomFactor = format.videoMaxZoomFactor;
            NSNumber *zoomPercent = notification.object;
            CGFloat zoomLevel = ([zoomPercent intValue] * maxZoomFactor / 100.f);
            [self setVideoCallZoom:zoomLevel];
        }
    }
}

#pragma mark - CAAnimationDelegate

- (void)animationDidStop:(CAAnimation *)animation finished:(BOOL)finished {
    DDLogVerbose(@"%@ animationDidStop: %@ finished:%d", LOG_TAG, animation, finished);
    
    if (finished) {
        
    }
}

#pragma mark - VideoZoomDelegate

- (nullable AVCaptureDevice *)getCaptureDevice {
    DDLogVerbose(@"%@ getCaptureDevice", LOG_TAG);
    
    // Note: WebRTC uses AVCaptureDeviceTypeBuiltInWideAngleCamera
    AVCaptureDeviceDiscoverySession *captureDeviceDiscoverySession = [AVCaptureDeviceDiscoverySession discoverySessionWithDeviceTypes:@[AVCaptureDeviceTypeBuiltInWideAngleCamera] mediaType:AVMediaTypeVideo position:self.callService.isFrontCamera ? AVCaptureDevicePositionFront : AVCaptureDevicePositionBack];
    NSArray<AVCaptureDevice *> *captureDevices = [captureDeviceDiscoverySession devices];
    
    if (captureDevices.count == 0) {
        return nil;
    } else {
        return captureDevices[0];
    }
}

- (void)updateZoom:(CGFloat)zoomLevel {
    DDLogVerbose(@"%@ updateZoom: %f", LOG_TAG, zoomLevel);
    
    AVCaptureDevice *captureDevice = [self getCaptureDevice];
    if (captureDevice) {
        AVCaptureDeviceFormat *format = captureDevice.activeFormat;
        CGFloat maxZoomFactor = format.videoMaxZoomFactor;
        [self setVideoCallZoom:(maxZoomFactor * zoomLevel)];
    }
}

#pragma mark - AlertViewDelegate

- (void)handleAcceptButtonClick:(AlertView *)alertView {
    DDLogVerbose(@"%@ handleAcceptButtonClick: %@", LOG_TAG, alertView);
    
}

- (void)handleCancelButtonClick:(AlertView *)alertView {
    DDLogVerbose(@"%@ handleCancelButtonClick: %@", LOG_TAG, alertView);
        
    if (self.networkAlertView) {
        [self.callService terminateCallWithTerminateReason:TLPeerConnectionServiceTerminateReasonConnectivityError];
        [self finish];
    }
}

- (void)handleCloseButtonClick:(AlertView *)alertView {
    DDLogVerbose(@"%@ handleCloseButtonClick: %@", LOG_TAG, alertView);
    
    if (self.networkAlertView) {
        [self.callService terminateCallWithTerminateReason:TLPeerConnectionServiceTerminateReasonConnectivityError];
        [self finish];
    }
}

#pragma mark - AlertMessageViewDelegate

- (void)didCloseAlertMessage:(nonnull AlertMessageView *)alertMessageView {
    DDLogVerbose(@"%@ didCloseAlertMessage: %@", LOG_TAG, alertMessageView);
    
    [alertMessageView closeAlertView];
}

- (void)didFinishCloseAlertMessageAnimation:(nonnull AlertMessageView *)alertMessageView {
    DDLogVerbose(@"%@ didFinishCloseAlertMessageAnimation: %@", LOG_TAG, alertMessageView);
    
    if (alertMessageView.tag == TERMINATE_ALERT_VIEW_TAG) {
        [alertMessageView removeFromSuperview];

        // Make sure to cancel the call
        [self.callService terminateCallWithTerminateReason:TLPeerConnectionServiceTerminateReasonCancel];
        [self finish];
    } else {
        [alertMessageView removeFromSuperview];
    }
}

#pragma mark - ConfirmViewDelegate

- (void)didTapConfirm:(nonnull AbstractConfirmView *)abstractConfirmView {
    DDLogVerbose(@"%@ didTapConfirm: %@", LOG_TAG, abstractConfirmView);
    
    if ([abstractConfirmView isKindOfClass:[InvitationCodeConfirmView class]]) {
        CallState *callState = [self.callService currentCall];
        if (callState) {
            [self.twinmeService createUriWithKind:TLTwincodeURIKindInvitation twincodeOutbound:self.currentSpace.profile.twincodeOutbound withBlock:^(TLBaseServiceErrorCode errorCode, TLTwincodeURI *twincodeURI) {
                if (twincodeURI && errorCode == TLBaseServiceErrorCodeSuccess) {
                    TLDescriptor *invitationDescriptor = [callState createWithTwincode:twincodeURI.twincodeId schemaId:[TLProfile SCHEMA_ID] publicKey:twincodeURI.publicKey replyTo:nil copyAllowed:YES];
                    if (![callState sendWithDescriptor:invitationDescriptor]) {
                        // Descriptor was not sent: no active participant accepts receiving messages.
                    }
                }
            }];
        }
    } else if ([abstractConfirmView isKindOfClass:[DefaultConfirmView class]]) {
        if (abstractConfirmView.tag == CONTROL_CAMERA_ASK_TAG) {
            [self.participant remoteAskControl];
        } else if (abstractConfirmView.tag == CONTROL_CAMERA_STOP_TAG) {
            [self.participant remoteStopControl];
            [self updateView:[self.callService callStatus]];
        } else if (abstractConfirmView.tag == CONTROL_CAMERA_ANSWER_TAG) {
            [self.participant remoteAnswerControlWithGrant:YES];
            [self updateView:[self.callService callStatus]];
        } else {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
        }
    } else if ([abstractConfirmView isKindOfClass:[OnboardingConfirmView class]]) {
        if (abstractConfirmView.tag == ONBOARDING_REMOTE_CAMERA) {
            [self cameraControl:nil];
        }
    } else if (([abstractConfirmView isKindOfClass:[PremiumFeatureConfirmView class]])) {
        InAppSubscriptionViewController *inAppSubscriptionViewController = [[UIStoryboard storyboardWithName:@"iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"InAppSubscriptionViewController"];
        TwinmeNavigationController *navigationController = [[TwinmeNavigationController alloc]initWithRootViewController:inAppSubscriptionViewController];
        [self.navigationController presentViewController:navigationController animated:YES completion:nil];
    }
    
    [abstractConfirmView closeConfirmView];
}

- (void)didTapCancel:(nonnull AbstractConfirmView *)abstractConfirmView {
    DDLogVerbose(@"%@ didTapCancel: %@", LOG_TAG, abstractConfirmView);
    
    [abstractConfirmView closeConfirmView];
    
    if ([abstractConfirmView isKindOfClass:[DefaultConfirmView class]]) {
        if (abstractConfirmView.tag == CONTROL_CAMERA_ANSWER_TAG) {
            [self.participant remoteAnswerControlWithGrant:NO];
        }
    } else if ([abstractConfirmView isKindOfClass:[OnboardingConfirmView class]]) {
        if (abstractConfirmView.tag == ONBOARDING_REMOTE_CAMERA) {
            [self.twinmeApplication setShowOnboardingType:OnboardingTypeRemoteCamera state:NO];
            [self cameraControl:nil];
        }
    }
}

- (void)didClose:(nonnull AbstractConfirmView *)abstractConfirmView {
    DDLogVerbose(@"%@ didClose: %@", LOG_TAG, abstractConfirmView);
    
    [abstractConfirmView closeConfirmView];
}

- (void)didFinishCloseAnimation:(nonnull AbstractConfirmView *)abstractConfirmView {
    DDLogVerbose(@"%@ didFinishCloseAnimation: %@", LOG_TAG, abstractConfirmView);

    [abstractConfirmView removeFromSuperview];
}

#pragma mark - CallQualityViewDelegate

- (void)closeCallQuality {
    DDLogVerbose(@"%@ closeCallQuality", LOG_TAG);
    
    [self finish];
}

- (void)sendCallQuality:(int)quality {
    DDLogVerbose(@"%@ sendCallQuality: %d", LOG_TAG, quality);
    
    [self.callService sendCallQuality:quality];
    [self finish];
}

#pragma mark - AddCallParticipantDelegate

- (void)addParticipantsToCall:(nonnull NSMutableArray *)contacts {
    DDLogVerbose(@"%@ addParticipantsToCall: %@", LOG_TAG, contacts);

    for (TLContact *contact in contacts) {
        [self.callService addCallParticipantWithOriginator:contact];
    }
}

#pragma mark - CallParticipantViewDelegate

- (void)didTapInfoCallParticipantView:(nonnull AbstractCallParticipantView *)callParticipantView {
    DDLogVerbose(@"%@ didTapInfoCallParticipantView: %@", LOG_TAG, callParticipantView);
    
    AlertMessageView *alertMessageView = [[AlertMessageView alloc] init];
    alertMessageView.alertMessageViewDelegate = self;
    alertMessageView.forceDarkMode = YES;
    [alertMessageView initWithTitle:TwinmeLocalizedString(@"delete_account_view_controller_warning", nil) message:[NSString stringWithFormat:TwinmeLocalizedString(@"call_view_controller_not_supported_group_call_message", nil), [callParticipantView getName]]];
    [self.view addSubview:alertMessageView];
    [alertMessageView showAlertView];
}

- (void)didTapLocationCallParticipantView:(nonnull AbstractCallParticipantView *)callParticipantView {
    DDLogVerbose(@"%@ didTapLocationCallParticipantView: %@", LOG_TAG, callParticipantView);
    
    [self initMap:YES];
    [self.mapView zoomToParticipant:[callParticipantView getParticipantId]];
}

- (void)didDoubleTapCallParticipantView:(AbstractCallParticipantView *)callParticipantView {
    DDLogVerbose(@"%@ didDoubleTapCallParticipantView: %@", LOG_TAG, callParticipantView);
    
    if (self.callParticipantViews.count > 2) {
        [self.view bringSubviewToFront:self.participantsView];
        [self.view bringSubviewToFront:self.menuView];
        [self.participantsView bringSubviewToFront:self.overlayView];
        [self.participantsView bringSubviewToFront:callParticipantView];
        [callParticipantView updateCallParticipantViewAspect];
        
        self.overlayView.hidden = NO;
        
        [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            if (callParticipantView.callParticipantViewAspect == CallParticipantViewAspectFullScreen) {
                self.overlayView.alpha = 1.0;
            } else {
                self.overlayView.alpha = 0;
            }
        } completion:^(BOOL finished) {
            self.overlayView.hidden = callParticipantView.callParticipantViewAspect == CallParticipantViewAspectFit;
        }];
    } else {
        if (self.callParticipantViewMode == CallParticipantViewModeSplitScreen) {
            self.callParticipantViewMode = CallParticipantViewModeSmallLocale;
        } else {
            self.callParticipantViewMode = CallParticipantViewModeSplitScreen;
        }
        
        [self updateParticipantsView];
        
        if (self.callParticipantViewMode != CallParticipantViewModeSplitScreen) {
            for (AbstractCallParticipantView *cpv in self.callParticipantViews) {
                if (![cpv isMainParticipant]) {
                    [self.participantsView bringSubviewToFront:cpv];
                    break;
                }
            }
        }
    }
}

- (void)didTapCallParticipantView:(AbstractCallParticipantView *)callParticipantView {
    DDLogVerbose(@"%@ didTapCallParticipantView: %@", LOG_TAG, callParticipantView);
    
    if ([callParticipantView getCallParticipant].isScreenSharing && callParticipantView.callParticipantViewAspect == CallParticipantViewAspectFullScreen) {
        return;
    }
    
    if (self.callParticipantViews.count > 2) {
        if (callParticipantView.callParticipantViewAspect == CallParticipantViewAspectFullScreen) {
            [callParticipantView updateCallParticipantViewAspect];
            
            [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                self.overlayView.alpha = 0;
            } completion:^(BOOL finished) {
                self.overlayView.hidden = YES;
            }];
        } else {
            [self singleTap];
        }
    } else {
        
        for (AbstractCallParticipantView *cpv in self.callParticipantViews) {
            if ([cpv getCallParticipant].isScreenSharing) {
                return;
            }
        }
        
        if (self.callParticipantViewMode == CallParticipantViewModeSmallLocale && ![callParticipantView isRemoteParticipant]) {
            self.callParticipantViewMode = CallParticipantViewModeSmallRemote;
            [self updateParticipantsView];
        } else if (self.callParticipantViewMode == CallParticipantViewModeSmallRemote && [callParticipantView isRemoteParticipant]) {
            self.callParticipantViewMode = CallParticipantViewModeSmallLocale;
            [self updateParticipantsView];
        } else {
            [self singleTap];
        }
        
        if (self.callParticipantViewMode != CallParticipantViewModeSplitScreen) {
            for (AbstractCallParticipantView *cpv in self.callParticipantViews) {
                if (![cpv isMainParticipant]) {
                    [self.participantsView bringSubviewToFront:cpv];
                    break;
                }
            }
        }
    }
}

- (void)didTapCancelCallParticipantView:(nonnull AbstractCallParticipantView *)callParticipantView {
    DDLogVerbose(@"%@ didTapCancelCallParticipantView: %@", LOG_TAG, callParticipantView);
    
    [self.callService terminateCallWithPeerConnectionId:[[callParticipantView getCallParticipant] peerConnectionId] terminateReason:TLPeerConnectionServiceTerminateReasonCancel];
}

- (void)didPinchLocaleVideo:(CGFloat)value gestureState:(UIGestureRecognizerState)state {
    DDLogVerbose(@"%@ didPinchLocaleVideo: %f", LOG_TAG, value);
    
    [self.view bringSubviewToFront:self.zoomLevelView];
    [self.view bringSubviewToFront:self.zoomLevelLabel];
    
    if (state == UIGestureRecognizerStateBegan) {
        [UIView animateWithDuration:0.5 delay:0. options: UIViewAnimationOptionCurveEaseIn animations:^{
            self.zoomLevelView.alpha = 1.0;
            self.zoomLevelLabel.alpha = 1.0;
        } completion:^(BOOL finished) {
            self.zoomLevelView.hidden = NO;
            self.zoomLevelLabel.hidden = NO;
        }];
    } else if (state == UIGestureRecognizerStateEnded) {
        [UIView animateWithDuration:0.5 delay:0. options: UIViewAnimationOptionCurveEaseIn animations:^{
            self.zoomLevelView.alpha = 0.0;
            self.zoomLevelLabel.alpha = 0.0;
        } completion:^(BOOL finished) {
            self.zoomLevelView.hidden = YES;
            self.zoomLevelLabel.hidden = YES;
        }];
    }
    
    CGFloat zoom = self.videoZoom + value;
    [self setVideoCallZoom:zoom];
}

- (void)didPinchRemoteVideo:(CGFloat)value gestureState:(UIGestureRecognizerState)state {
    DDLogVerbose(@"%@ didPinchRemoteVideo: %f", LOG_TAG, value);
    
    [self.view bringSubviewToFront:self.zoomLevelView];
    [self.view bringSubviewToFront:self.zoomLevelLabel];
    
    if (state == UIGestureRecognizerStateBegan) {
        [UIView animateWithDuration:0.5 delay:0. options: UIViewAnimationOptionCurveEaseIn animations:^{
            self.zoomLevelView.alpha = 1.0;
            self.zoomLevelLabel.alpha = 1.0;
        } completion:^(BOOL finished) {
            self.zoomLevelView.hidden = NO;
            self.zoomLevelLabel.hidden = NO;
        }];
    } else if (state == UIGestureRecognizerStateEnded) {
        [UIView animateWithDuration:0.5 delay:0. options: UIViewAnimationOptionCurveEaseIn animations:^{
            self.zoomLevelView.alpha = 0.0;
            self.zoomLevelLabel.alpha = 0.0;
        } completion:^(BOOL finished) {
            self.zoomLevelView.hidden = YES;
            self.zoomLevelLabel.hidden = YES;
        }];
    }
    
    if (self.remoteZoom < 15) {
        if (value == 1) {
            self.remoteZoom += 0.1;
        } else {
            self.remoteZoom -= 0.1;
        }
    } else {
        self.remoteZoom += value;
    }
        
    if (self.remoteZoom >= 100) {
        self.remoteZoom = 100;
    } else if (self.remoteZoom <= 1.0) {
        self.remoteZoom = 1.0;
    }
    
    self.zoomLevelLabel.text = [NSString stringWithFormat:@"%.0f%%", self.remoteZoom];
    
    [self.participant remoteCameraSetWithZoom:self.remoteZoom];
}

- (void)didTapFullScreenSharingScreenCallParticipantView:(nonnull AbstractCallParticipantView *)callParticipantView {
    DDLogVerbose(@"%@ didTapFullScreenSharingScreenCallParticipantView: %@", LOG_TAG, callParticipantView);
    
    [self setMenuVisible:NO];
    
    [self.view bringSubviewToFront:self.participantsView];
    [self.view bringSubviewToFront:self.menuView];
    [self.participantsView bringSubviewToFront:self.overlayView];
    [self.participantsView bringSubviewToFront:callParticipantView];
    [callParticipantView updateCallParticipantViewAspect];
    [callParticipantView minZoom];
    
    self.overlayView.hidden = NO;
    
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        if (callParticipantView.callParticipantViewAspect == CallParticipantViewAspectFullScreen) {
            self.overlayView.alpha = 1.0;
        } else {
            self.overlayView.alpha = 0;
        }
    } completion:^(BOOL finished) {
        self.overlayView.hidden = callParticipantView.callParticipantViewAspect == CallParticipantViewAspectFit;
    }];
}

- (void)didTapMinimizeSharingScreenCallParticipantView:(nonnull AbstractCallParticipantView *)callParticipantView {
    DDLogVerbose(@"%@ didTapMinimizeSharingScreenCallParticipantView: %@", LOG_TAG, callParticipantView);
    
    if (self.callParticipantViews.count == 2) {
        [self setMenuVisible:YES];
        [callParticipantView updateCallParticipantViewAspect];
        [callParticipantView resetZoom];
        
        if (self.callParticipantLocaleView) {
            [self.participantsView bringSubviewToFront:self.callParticipantLocaleView];
        }
        
        self.callParticipantViewMode = CallParticipantViewModeSmallLocale;
        [self updateParticipantsView];
                
        [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.overlayView.alpha = 0;
        } completion:^(BOOL finished) {
            self.overlayView.hidden = YES;
        }];
    } else {
        if (callParticipantView.callParticipantViewAspect == CallParticipantViewAspectFullScreen) {
            [self setMenuVisible:YES];
            [callParticipantView resetZoom];
            [callParticipantView updateCallParticipantViewAspect];
            
            [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                self.overlayView.alpha = 0;
            } completion:^(BOOL finished) {
                self.overlayView.hidden = YES;
            }];
        } else {
            [self singleTap];
        }
    }
}

- (void)didTapSwitchCameraCallParticipantView:(nonnull AbstractCallParticipantView *)callParticipantView {
    DDLogVerbose(@"%@ didTapSwitchCameraCallParticipantView: %@", LOG_TAG, callParticipantView);
 
    if (!callParticipantView.isRemoteParticipant) {
        if ([self.participant isRemoteCameraControl] && self.participant.remoteActiveCamera == 0) {
            DefaultConfirmView *defaultConfirmView = [[DefaultConfirmView alloc] init];
            defaultConfirmView.confirmViewDelegate = self;
            defaultConfirmView.forceDarkMode = YES;
            defaultConfirmView.tag = CONTROL_CAMERA_STOP_TAG;
            NSString *message = [NSString stringWithFormat:TwinmeLocalizedString(@"call_view_controller_camera_control_remotely", nil), self.originator.name];
            [defaultConfirmView initWithTitle:TwinmeLocalizedString(@"call_view_controller_camera_control", nil) message:message image:nil avatar:nil action: TwinmeLocalizedString(@"call_view_controller_camera_control_stop", nil) actionColor:Design.DELETE_COLOR_RED cancel:TwinmeLocalizedString(@"application_cancel", nil)];
            [self.view addSubview:defaultConfirmView];
            [defaultConfirmView showConfirmView];
        } else {
            BOOL isVideoAllowed = self.accessCameraGranted && (self.isCallStartedInVideo || (self.originator.capabilities.hasVideo && self.originator.identityCapabilities.hasVideo));
            if (isVideoAllowed && ![self.callService isCameraMuted]) {
                [self.callService switchCamera];
            }
        }
    } else {
        CallParticipant *callParticipant = [callParticipantView  getCallParticipant];
        [callParticipant remoteSwitchCameraWithFront:[callParticipant remoteActiveCamera] == 2];
    }
}

#pragma mark - CallCertifyViewDelegate

- (void)certifyViewCancelWord {
    DDLogVerbose(@"%@ certifyViewCancelWord", LOG_TAG);
    
    [self hapticFeedBack:UIImpactFeedbackStyleMedium];
    [self.callService addWordCheckResultWithWordIndex:self.wordCheckChallenge.index result:NO];
}

- (void)certifyViewConfirmWord {
    DDLogVerbose(@"%@ certifyViewConfirmWord", LOG_TAG);
    
    [self hapticFeedBack:UIImpactFeedbackStyleMedium];
    [self.callService addWordCheckResultWithWordIndex:self.wordCheckChallenge.index result:YES];
}

- (void)certifyViewDidFinish {
    DDLogVerbose(@"%@ certifyViewDidFinish", LOG_TAG);
    
    self.callCertifyView.hidden = YES;
    [self.callCertifyView removeFromSuperview];
    self.callCertifyView = nil;
    self.headerView.alpha = 1.0f;
    
    [self updateMenu];
    
    if (self.menuHidden) {
        self.menuHidden = NO;
        [self animateMenu:YES];
    }
}

- (void)certifyViewSingleTap {
    DDLogVerbose(@"%@ certifyViewSingleTap", LOG_TAG);
    
    [self singleTap];
}

#pragma mark - CoachMarkDelegate

- (void)didTapCoachMarkOverlay:(CoachMarkViewController *)coachMarkViewController {
    DDLogVerbose(@"%@ didTapCoachMarkOverlay: %@", LOG_TAG, coachMarkViewController);
    
    [coachMarkViewController closeView];
}

- (void)didTapCoachMarkFeature:(CoachMarkViewController *)coachMarkViewController {
    DDLogVerbose(@"%@ didTapCoachMarkFeature: %@", LOG_TAG, coachMarkViewController);
    
    [self.twinmeApplication hideCoachMark:[[coachMarkViewController getCoachMark] coachMarkTag]];
    [coachMarkViewController closeView];
    [self addCallParticipant:self.addParticipantButton];
}

- (void)didLongPressCoachMarkFeature:(CoachMarkViewController *)coachMarkViewController {
    DDLogVerbose(@"%@ didLongPressCoachMarkFeature: %@", LOG_TAG, coachMarkViewController);
    
}

#pragma mark - PlayerStreamingAudioViewDelegate

- (void)onStreamingPlayPause:(nonnull PlayerStreamingAudioView *)playerStreamingAudioView {
    DDLogVerbose(@"%@ onStreamingPlay: %@", LOG_TAG, playerStreamingAudioView);
    
    if (self.streamPlayer.streamer) {
        if (self.streamPlayer.paused) {
            [self.streamPlayer.streamer resumeStreaming];
        } else {
            [self.streamPlayer.streamer pauseStreaming];
        }
    } else {
        if (self.streamPlayer.paused) {
            [self.streamPlayer askResume];
        } else {
            [self.streamPlayer askPause];
        }
    }
}

- (void)onStreamingStop:(nonnull PlayerStreamingAudioView *)playerStreamingAudioView {
    DDLogVerbose(@"%@ onStreamingStop: %@", LOG_TAG, playerStreamingAudioView);
    
    if (self.streamPlayer.streamer) {
        [self.callService stopStreaming];
        self.streamPlayer = nil;
        
        [UIView animateWithDuration:0.5 animations:^{
            self.playerStreamingAudioView.hidden = YES;
            
            [self updateParticipantsViewConstraint];
            
            [self.view setNeedsLayout];
            [self.view layoutIfNeeded];
            
            if (self.participantsViewInitialized) {
                [self updateParticipantsView];
            }
        }];
    } else {
        [self.streamPlayer askStop];
    }
}

#pragma mark - CallConversationDelegate

- (void)closeConversation {
    DDLogVerbose(@"%@ closeConversation", LOG_TAG);
    
    self.conversationView.hidden = YES;
}

- (void)sendMessage:(NSString *)text {
    DDLogVerbose(@"%@ sendMessage: %@", LOG_TAG, text);
    
    CallState *callState = [self.callService currentCall];
    if (callState) {
        TLDescriptor *descriptor = [callState createWithMessage:text replyTo:nil copyAllowed:YES];
        if ([callState sendWithDescriptor:descriptor]) {
            self.unreadMessageView.hidden = NO;
            self.sharedLocationViewTrailingConstraint.constant = 0;
            self.unreadMessageImageView.image = [UIImage imageNamed:@"CallMessageIcon"];
            [self.conversationView addDescriptor:descriptor isLocal:YES needsReload:YES name:self.originator.identityName];
        }
    }
}

- (void)readMessage:(TLDescriptorId *)descriptorId {
    DDLogVerbose(@"%@ readMessage: %@", LOG_TAG, descriptorId);
    
    CallState *callState = [self.callService currentCall];
    if (callState) {
        for (TLDescriptor *descriptor in [callState getDescriptors]) {
            if ([descriptor.descriptorId isEqual:descriptorId]) {
                [callState markReadWithDescriptor:descriptor];
                break;
            }
        }
    }
}

#pragma mark - CallMapDelegate

- (void)closeMap {
    DDLogVerbose(@"%@ closeMap", LOG_TAG);
    
    self.mapView.hidden = YES;
}

- (void)fullScreenMap:(BOOL)isFullScreen {
    DDLogVerbose(@"%@ fullScreenMap: %@", LOG_TAG, isFullScreen ? @"YES":@"NO");
    
    [UIView animateWithDuration:0.5 animations:^{
        if (isFullScreen) {
            self.mapViewBottomConstraint.active = NO;
            self.mapViewTopConstraint.active = NO;
            
            self.mapViewFullScreenBottomConstraint.active = YES;
            self.mapViewFullScreenTopConstraint.active = YES;
            
            [self.view bringSubviewToFront:self.mapView];
        } else {
            self.mapViewFullScreenBottomConstraint.active = NO;
            self.mapViewFullScreenTopConstraint.active = NO;
            
            self.mapViewBottomConstraint.active = YES;
            self.mapViewTopConstraint.active = YES;
            
            [self.view bringSubviewToFront:self.menuView];
        }
        
        [self.view setNeedsLayout];
        [self.view setNeedsDisplay];
    }];
}

- (void)showBackgroundAlert {
    DDLogVerbose(@"%@ showBackgroundAlert", LOG_TAG);
        
    DefaultConfirmView *defaultConfirmView = [[DefaultConfirmView alloc] init];
    defaultConfirmView.confirmViewDelegate = self;
    [defaultConfirmView initWithTitle:TwinmeLocalizedString(@"call_view_controller_location_share", nil) message:TwinmeLocalizedString(@"call_view_controller_location_background_warning", nil) image:nil avatar:nil  action:TwinmeLocalizedString(@"application_authorization_go_settings", nil) actionColor:nil cancel:nil];
    [self.view addSubview:defaultConfirmView];
    [defaultConfirmView showConfirmView];
}

- (void)showExactLocationAlert {
    DDLogVerbose(@"%@ showExactLocationAlert", LOG_TAG);
        
    DefaultConfirmView *defaultConfirmView = [[DefaultConfirmView alloc] init];
    defaultConfirmView.confirmViewDelegate = self;
    [defaultConfirmView initWithTitle:TwinmeLocalizedString(@"call_view_controller_location_share", nil) message:TwinmeLocalizedString(@"call_view_controller_location_exact_warning", nil) image:nil avatar:nil  action:TwinmeLocalizedString(@"application_authorization_go_settings", nil) actionColor:nil cancel:nil];
    [self.view addSubview:defaultConfirmView];
    [defaultConfirmView showConfirmView];
}

- (void)stopShareLocation {
    DDLogVerbose(@"%@ stopShareLocation", LOG_TAG);
 
    [self.callService stopShareLocation:NO];
    
    if (self.callParticipantLocaleView) {
        self.callParticipantLocaleView.isLocationShared = NO;
        [self.callParticipantLocaleView updateViews];
    }
    
    self.sharedLocationImageView.image = [UIImage imageNamed:@"CallLocationIcon"];
    self.sharedLocationImageView.image = [self.sharedLocationImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.sharedLocationImageView.tintColor = [UIColor whiteColor];
}

- (void)startShareLocation:(double)mapLatitudeDelta mapLongitudeDelta:(double)mapLongitudeDelta {
    DDLogVerbose(@"%@ startShareLocation", LOG_TAG);
    
    self.showShareLocationMessage = YES;
    [self.callService startShareLocation:mapLatitudeDelta mapLongitudeDelta:mapLongitudeDelta];
    
    if (self.callParticipantLocaleView) {
        self.callParticipantLocaleView.isLocationShared = YES;
        [self.callParticipantLocaleView updateViews];
    }
    
    self.sharedLocationImageView.image = [UIImage imageNamed:@"ShareLocationIcon"];
    self.sharedLocationView.hidden = NO;
    
    if (self.unreadMessageView.hidden) {
        self.sharedLocationViewTrailingConstraint.constant = self.headerViewHeightConstraint.constant;
    } else {
        self.sharedLocationViewTrailingConstraint.constant = 0;
    }
}

#pragma mark - CallMenuDelegate

- (void)menuStateDidUpdated:(CallMenuViewState)callMenuViewState {
    DDLogVerbose(@"%@ menuStateDidUpdated: %d", LOG_TAG, callMenuViewState);
    
    if (callMenuViewState == CallMenuViewStateExtend) {
        self.menuViewBottomConstraint.constant = 0;
    } else {
        self.menuViewBottomConstraint.constant = DESIGN_DEFAULT_MENU_MARGIN * Design.HEIGHT_RATIO;
    }
    
    [self updateMenu];
    
    [UIView animateWithDuration:MENU_ANIMATION_DURATION animations:^{
        [self.view layoutIfNeeded];
    }];
}

#pragma mark - CallHoldDelegate

- (void)onHangupHoldCall:(CallHoldView *)callHoldView {
    DDLogVerbose(@"%@ onHangupHoldCall: %@", LOG_TAG, callHoldView);
    
    if ([self.callService currentHoldCall]) {
        [self.callService terminateCallWithCall:[self.callService currentHoldCall] terminateReason:TLPeerConnectionServiceTerminateReasonSuccess];
    }
    
    self.callHoldView.hidden = YES;
    [self animateMenu:YES];
}

- (void)onAddHoldCall:(CallHoldView *)callHoldView {
    DDLogVerbose(@"%@ onAddHoldCall: %@", LOG_TAG, callHoldView);
    
    if (!self.isGroupCallSubscribed) {
        [self showPremiumFeature:FeatureTypeGroupCall];
    } else {
        [self.callService mergeCall];
        
        self.callHoldView.hidden = YES;
        [self animateMenu:YES];
    }
}

- (void)onSwapHoldCall:(CallHoldView *)callHoldView {
    DDLogVerbose(@"%@ onSwapHoldCall: %@", LOG_TAG, callHoldView);
    
    [self.callService switchCall];
}

#pragma mark - Private methods

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    self.view.backgroundColor = [UIColor blackColor];
    
    [self setupFrameSize];
    
    self.backImageViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.backImageViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.backImageViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.backImageView.tintColor = [UIColor whiteColor];
    self.backImageView.image = [self.backImageView.image imageFlippedForRightToLeftLayoutDirection];
    
    self.backClickableViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.backClickableView.isAccessibilityElement = YES;
    UITapGestureRecognizer *backGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleBackTapGesture:)];
    [self.backClickableView addGestureRecognizer:backGestureRecognizer];
    self.backClickableView.hidden = YES;
    
    self.headerViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.nameLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.nameLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.nameLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.nameLabel.font = Design.FONT_REGULAR34;
    self.nameLabel.textColor = [UIColor whiteColor];
    self.nameLabel.text = self.contactName;
    
    self.certifiedRelationImageViewHeightConstraint.constant = Design.CERTIFIED_HEIGHT;
    self.certifiedRelationImageViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.certifiedRelationImageView.hidden = YES;
    
    if (self.originator && [self.originator isKindOfClass:[TLContact class]]) {
        TLContact *contact = (TLContact *)self.originator;
        if (contact.certificationLevel == TLCertificationLevel4) {
            self.certifiedRelationImageView.hidden = NO;
            self.nameLabelTrailingConstraint.constant = self.certifiedRelationImageViewHeightConstraint.constant + self.certifiedRelationImageViewLeadingConstraint.constant;
        }
    }
    
    self.messageLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.messageLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.messageLabel.font = Design.FONT_REGULAR34;
    self.messageLabel.textColor = [UIColor whiteColor];
    if (self.isVideoCall) {
        self.messageLabel.text = TwinmeLocalizedString(@"video_call_view_controller_calling", nil);
    } else {
        self.messageLabel.text = TwinmeLocalizedString(@"audio_call_view_controller_calling", nil);
    }
    
    self.transferLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.transferLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.transferLabel.font = Design.FONT_REGULAR34;
    self.transferLabel.textColor = [UIColor whiteColor];
    self.transferLabel.text = TwinmeLocalizedString(@"call_view_controller_transfer_call_message", nil);
    self.transferLabel.hidden = YES;
    
    self.answerCallViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.answerCallViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.answerCallViewBottomConstraint.constant *= Design.HEIGHT_RATIO;
    self.answerCallView.backgroundColor = [UIColor blackColor];
    
    self.acceptViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    
    self.acceptButtonHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    CALayer *acceptButtonLayer = self.acceptButton.layer;
    acceptButtonLayer.cornerRadius = self.acceptButtonHeightConstraint.constant * 0.5;
    acceptButtonLayer.masksToBounds = YES;
    [self.acceptButton setBackgroundColor:Design.BUTTON_GREEN_COLOR];
    
    self.acceptImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.declineViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    
    self.declineButtonHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    CALayer *declineButtonLayer = self.declineButton.layer;
    declineButtonLayer.cornerRadius = self.declineButtonHeightConstraint.constant * 0.5;
    declineButtonLayer.masksToBounds = YES;
    [self.declineButton setBackgroundColor:Design.BUTTON_RED_COLOR];
    
    self.declineImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.cancelViewBottomConstraint.constant *= Design.HEIGHT_RATIO;
    self.cancelViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.cancelViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    
    self.cancelButtonHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    CALayer *cancelButtonLayer = self.cancelButton.layer;
    cancelButtonLayer.cornerRadius = self.cancelButtonHeightConstraint.constant * 0.5;
    cancelButtonLayer.masksToBounds = YES;
    [self.cancelButton setBackgroundColor:Design.BUTTON_RED_COLOR];
    
    self.cancelImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.menuViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.menuViewBottomConstraint.constant = DESIGN_DEFAULT_MENU_MARGIN * Design.HEIGHT_RATIO;
    
    [self.menuView.hangupButton addTarget:self action:@selector(hangup:) forControlEvents:UIControlEventTouchUpInside];
    [self.menuView.microMuteButton addTarget:self action:@selector(microMute:) forControlEvents:UIControlEventTouchUpInside];
    [self.menuView.speakerOnButton addTarget:self action:@selector(speakerOn:) forControlEvents:UIControlEventTouchUpInside];
    [self.menuView.cameraMuteButton addTarget:self action:@selector(cameraMute:) forControlEvents:UIControlEventTouchUpInside];
    [self.menuView.conversationButton addTarget:self action:@selector(openConversation:) forControlEvents:UIControlEventTouchUpInside];
    [self.menuView.mapButton addTarget:self action:@selector(shareLocation:) forControlEvents:UIControlEventTouchUpInside];
    [self.menuView.streamingAudioButton addTarget:self action:@selector(addStreamingAudio:) forControlEvents:UIControlEventTouchUpInside];
    [self.menuView.invitationButton addTarget:self action:@selector(shareInvitation:) forControlEvents:UIControlEventTouchUpInside];
    [self.menuView.pauseButton addTarget:self action:@selector(pauseCall:) forControlEvents:UIControlEventTouchUpInside];
    [self.menuView.certifyButton addTarget:self action:@selector(certifyRelation:) forControlEvents:UIControlEventTouchUpInside];
    [self.menuView.cameraControlButton addTarget:self action:@selector(cameraControl:) forControlEvents:UIControlEventTouchUpInside];

    self.menuView.callMenuDelegate = self;
    
    self.conversationViewLeadingConstraint.constant = 0;
    self.conversationViewTrailingConstraint.constant = 0;
    self.conversationViewBottomConstraint.constant = (DESIGN_DEFAULT_MENU_MARGIN + DESIGN_PARTICIPANTS_BOTTOM_MARGIN) * Design.HEIGHT_RATIO;;
    
    self.conversationView.hidden = YES;
    self.conversationView.callConversationDelegate = self;
        
    self.addParticipantView.hidden = YES;
    self.addParticipantView.accessibilityLabel = TwinmeLocalizedString(@"room_members_view_controller_participants_title", nil);
    
    self.addParticipantImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    [self.addParticipantImageView setTintColor:[UIColor whiteColor]];
    
    self.unreadMessageViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.unreadMessageView.hidden = YES;
    [self.unreadMessageButton addTarget:self action:@selector(openConversation:) forControlEvents:UIControlEventTouchUpInside];
    self.unreadMessageImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.sharedLocationViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.sharedLocationView.hidden = YES;
    [self.sharedLocationButton addTarget:self action:@selector(openMap:) forControlEvents:UIControlEventTouchUpInside];
    
    self.sharedLocationImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.sharedLocationImageView.image = [self.sharedLocationImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.sharedLocationImageView.tintColor = [UIColor whiteColor];

    self.controlCameraViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.controlCameraView.hidden = YES;
    [self.controlCameraButton addTarget:self action:@selector(cameraControl:) forControlEvents:UIControlEventTouchUpInside];
    self.controlCameraImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    [self.controlCameraImageView setTintColor:Design.DELETE_COLOR_RED];
    
    self.terminatedLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.terminatedLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.terminatedLabel.font = Design.FONT_REGULAR34;
    self.terminatedLabel.textColor = [UIColor whiteColor];
    
    [self.view bringSubviewToFront:self.menuView];
    [self.view bringSubviewToFront:self.backClickableView];
    
    self.playerStreamingAudioViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.playerStreamingAudioViewBottomConstraint.constant =  DESIGN_PARTICIPANTS_BOTTOM_LARGE_MARGIN * Design.HEIGHT_RATIO;
    
    self.playerStreamingAudioView.playerStreamingAudioViewDelegate = self;
    self.playerStreamingAudioView.hidden = YES;
    
    self.callHoldViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.callHoldViewBottomConstraint.constant =  DESIGN_PARTICIPANTS_BOTTOM_LARGE_MARGIN * Design.HEIGHT_RATIO;
    
    self.callHoldView.callHoldDelegate = self;
    self.callHoldView.hidden = YES;
    
    self.overlayView.backgroundColor = DESIGN_OVERLAY_COLOR;
    self.overlayView.hidden = YES;
    self.overlayView.alpha = 0;
    self.overlayView.userInteractionEnabled = NO;
    
    self.participantsViewBottomConstraint.constant = DESIGN_PARTICIPANTS_BOTTOM_LARGE_MARGIN * Design.HEIGHT_RATIO;
    
    self.noParticipantsView.hidden = YES;
    self.noParticipantsView.clipsToBounds = YES;
    self.noParticipantsView.layer.cornerRadius = DESIGN_CORNER_RADIUS;
    
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
    
    // Only instanciate the view, we don't want to actually display it. We only need it to simulate a touch to trigger the route selection popup.
    self.routePickerView = [[AVRoutePickerView alloc] init];
    
    self.view.clipsToBounds = YES;
    self.uiInitialized = YES;
}

- (void)updateView:(CallStatus)callStatus {
    DDLogVerbose(@"%@ updateView: %d", LOG_TAG, callStatus);
    
    [self updateParticipantsViewConstraint];
    [self updateCallParticipantView];
    [self updateMenu];
    
    if (self.callParticipantViews.count > 1) {
        self.noParticipantsView.hidden = YES;
    } else {
        [self initNoParticipantView];
        self.noParticipantsView.hidden = NO;
    }
    
    if (CALL_IS_ACTIVE(callStatus)) {
        [self updateModeInCall];
    } else if (CALL_IS_ACCEPTED(callStatus)) {
        self.declineView.hidden = YES;
        self.answerCallView.hidden = YES;
        self.menuView.hidden = NO;
        self.messageLabel.text = TwinmeLocalizedString(@"video_call_view_controller_connecting", nil);
        
    } else if (CALL_IS_INCOMING(callStatus)) { // CallModeIncomingCall:
        self.declineView.hidden = NO;
        self.answerCallView.hidden = NO;
        self.menuView.hidden = YES;
        if (CALL_IS_VIDEO(callStatus)) {
            self.messageLabel.text = TwinmeLocalizedString(@"video_call_view_controller_calling", nil);
        } else {
            self.messageLabel.text = TwinmeLocalizedString(@"audio_call_view_controller_calling", nil);
        }
        
    } else if (CALL_IS_OUTGOING(callStatus)) {
        if (CALL_IS_VIDEO(callStatus)) {
            self.messageLabel.text = TwinmeLocalizedString(@"video_call_view_controller_calling", nil);
        } else {
            self.messageLabel.text = TwinmeLocalizedString(@"audio_call_view_controller_calling", nil);
        }
        self.menuView.hidden = NO;
    } else if (callStatus == CallStatusInVideoBell) {
        if (self.isVideoCall) {
            self.messageLabel.text = TwinmeLocalizedString(@"video_call_view_controller_calling", nil);
        } else {
            self.messageLabel.text = TwinmeLocalizedString(@"audio_call_view_controller_calling", nil);
        }
        self.answerCallView.hidden = YES;
        self.declineView.hidden = YES;
        self.cancelView.hidden = NO;
    } else {
        self.menuView.hidden = YES;
        self.playerStreamingAudioView.hidden = YES;
        self.menuHidden = NO;
        [self animateMenu:NO];
        self.cancelView.hidden = YES;
        self.messageLabel.hidden = YES;
        self.nameLabel.hidden = YES;
        self.certifiedRelationImageView.hidden = YES;
        self.addParticipantView.hidden = YES;
        self.unreadMessageView.hidden = YES;
        self.sharedLocationView.hidden = YES;
        self.controlCameraView.hidden = YES;
        self.terminatedLabel.hidden = NO;
        
        if (self.callCertifyView) {
            self.callCertifyView.hidden = YES;
            self.headerView.alpha = 1.0f;
        }
        
        [UIView animateWithDuration:CLOSE_DELAY delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.participantsView.alpha = 0;
        } completion:^(BOOL finished) {
        }];
    }
}

- (void)updateCertifyView:(CallParticipantEvent)event {
    DDLogVerbose(@"%@ updateCertifyView: %d", LOG_TAG, event);
    
    BOOL updateWord = NO;
    
    switch (event) {
        case CallParticipantEventKeyCheckInitiate:
            [self startCertifyView:YES];
            self.wordCheckChallenge = [self.callService getKeyCheckCurrentWord];
            updateWord = YES;
            break;
            
        case CallParticipantEventOnKeyCheckInitiate:
            self.wordCheckChallenge = [self.callService getKeyCheckCurrentWord];
            updateWord = YES;
            break;
            
        case CallParticipantEventCurrentWordChanged:
            self.wordCheckChallenge = [self.callService getKeyCheckCurrentWord];
            updateWord = YES;
            break;
            
        case CallParticipantEventWordCheckResultKO:
            [self.callService getKeyCheckPeerError];
            [self.callCertifyView certifyRelationFailed];
            break;
            
        case CallParticipantEventTerminateKeyCheck: {
            KeyCheckResult keyCheckResult = [self.callService isKeyCheckOK];
            if (keyCheckResult == KeyCheckResultYes) {
                [self.callCertifyView certifyRelationSuccess];
            }
            
            break;
        }
            
        default:
            break;
    }
    
    if (updateWord && self.callCertifyView) {
        [self.callCertifyView updateWord:self.wordCheckChallenge];
    }
}


- (void)updateStreamingPlayer:(CallParticipant *)callParticipant event:(CallParticipantEvent)event {
    DDLogVerbose(@"%@ updateStreamingPlayer: %@ event: %u", LOG_TAG, callParticipant, event);
    
    BOOL needsUpdateParticipants = NO;
    
    switch (event) {
        case CallParticipantEventStreamStart:
            if ([callParticipant streamPlayer]) {
                needsUpdateParticipants = YES;
                self.streamPlayer = [callParticipant streamPlayer];
            }
            break;
            
        case CallParticipantEventStreamStop:
            needsUpdateParticipants = YES;
            self.streamPlayer = nil;
            [self.playerStreamingAudioView stopStreaming];
            break;
            
        case CallParticipantEventStreamInfo:
            if ([callParticipant streamPlayer]) {
                self.streamPlayer = [callParticipant streamPlayer];
                [self.playerStreamingAudioView setSound:self.streamPlayer.title artwork:self.streamPlayer.artwork];
            }
            break;
            
        case CallParticipantEventStreamStatus: {
            StreamingStatus streamingStatus = callParticipant.streamingStatus;
            if (streamingStatus == StreamingStatusPlaying) {
                CallState *callState = [self.callService currentCall];
                if (callState && callState.currentStreamer.localPlayer) {
                    needsUpdateParticipants = YES;
                    self.streamPlayer = callState.currentStreamer.localPlayer;
                }
            } else if ([callParticipant streamPlayer]) {
                needsUpdateParticipants = YES;
                self.streamPlayer = [callParticipant streamPlayer];
            } else if (streamingStatus == StreamingStatusReady) {
                needsUpdateParticipants = YES;
                self.streamPlayer = nil;
            } else if (streamingStatus == StreamingStatusError) {
                [self.callService stopStreaming];
                
                needsUpdateParticipants = YES;
                self.streamPlayer = nil;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[UIApplication sharedApplication].keyWindow makeToast:TwinmeLocalizedString(@"streaming_audio_view_controller_error_message", nil)];
                });
                
            } else if (streamingStatus == StreamingStatusUnSupported) {
                [self.callService stopStreaming];
                
                needsUpdateParticipants = YES;
                self.streamPlayer = nil;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[UIApplication sharedApplication].keyWindow makeToast:[NSString stringWithFormat:TwinmeLocalizedString(@"streaming_audio_view_controller_unsupported_message", nil), self.contactName]];
                });
            }
        }
            
            break;
            
        case CallParticipantEventStreamPause:
            [self.playerStreamingAudioView pauseStreaming];
            break;
            
        case CallParticipantEventStreamResume:
            [self.playerStreamingAudioView resumeStreaming];
            break;
            
        default:
            break;
    }
    
    if (needsUpdateParticipants) {
        [UIView animateWithDuration:0.5 animations:^{
            if (self.streamPlayer) {
                self.playerStreamingAudioView.hidden = NO;
                [self.playerStreamingAudioView setSound:self.streamPlayer.title artwork:self.streamPlayer.artwork];
            } else {
                self.playerStreamingAudioView.hidden = YES;
            }
            
            [self updateParticipantsViewConstraint];
            
            [self.view setNeedsLayout];
            [self.view layoutIfNeeded];
            
            if (self.participantsViewInitialized) {
                [self updateParticipantsView];
            }
        }];
    }
    
    /*
     dispatch_async(dispatch_get_main_queue(), ^{
         [[UIApplication sharedApplication].keyWindow makeToast:TwinmeLocalizedString(@"streaming_audio_view_controller_error_message", nil)];
     });
     break;
     
 case StreamingEventUnsupported: {
         needsUpdateParticipants = YES;
         self.streamPlayer = nil;
         [self.playerStreamingAudioView stopStreaming];
         
         dispatch_async(dispatch_get_main_queue(), ^{
             [[UIApplication sharedApplication].keyWindow makeToast:[NSString stringWithFormat:TwinmeLocalizedString(@"streaming_audio_view_controller_unsupported_message", nil), self.contactName]];
         });
     */
}

- (void)updateModeInCall {
    DDLogVerbose(@"%@ updateModeInCall", LOG_TAG);
    
    self.declineView.hidden = YES;
    self.menuView.hidden = NO;
    self.answerCallView.hidden = YES;
    self.addParticipantView.hidden = NO;
    
    [self showCoachMark];
    
    //self.streamingAudioView.hidden = NO;
    
    self.messageLabel.hidden = NO;
    
    if (self.callParticipantViews.count > 2 && !self.isCallReceiver && !self.originator.isGroup) {
        self.nameLabel.hidden = YES;
        self.certifiedRelationImageView.hidden = YES;
        self.nameLabelTrailingConstraint.constant = 0;
    } else {
        self.nameLabel.hidden = NO;
        
        if ([self.originator isKindOfClass:[TLContact class]]) {
            TLContact *contact = (TLContact *)self.originator;
            if (contact.certificationLevel == TLCertificationLevel4) {
                self.certifiedRelationImageView.hidden = NO;
                self.nameLabelTrailingConstraint.constant = self.certifiedRelationImageViewHeightConstraint.constant + self.certifiedRelationImageViewLeadingConstraint.constant;
            } else {
                self.certifiedRelationImageView.hidden = YES;
            }
        }
    }
    
    CallState *call = [self.callService currentCall];
    self.participant = [call mainParticipant];
    
    if ([self.participant isVideoMute]) {
        [self setMenuVisible:YES];
    }
    
    self.cancelView.hidden = YES;
    self.backClickableView.hidden = NO;
    self.controlCameraView.hidden = ![self isRemoteCameraControl];
    
    if (!self.getDescriptorsDone) {
        self.getDescriptorsDone = YES;
        
        NSMutableDictionary<NSUUID *, NSString *> *participantsName = [[NSMutableDictionary alloc]init];
        NSArray<CallParticipant *> *participants = [call getParticipants];
        BOOL isOneLocationShared = call.currentGeolocation != nil;
        
        for (CallParticipant *callParticipant in participants) {
            if (callParticipant.senderId) {
                [participantsName setObject:callParticipant.name forKey:callParticipant.senderId];
            }
            
            if (callParticipant.currentGeolocation) {
                isOneLocationShared = YES;
            }
        }
        
        self.sharedLocationView.hidden = !isOneLocationShared;
        
        if ([self.callService isLocationStartShared]) {
            self.sharedLocationImageView.image = [UIImage imageNamed:@"ShareLocationIcon"];
        } else {
            self.sharedLocationImageView.image = [UIImage imageNamed:@"CallLocationIcon"];
            self.sharedLocationImageView.image = [self.sharedLocationImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            self.sharedLocationImageView.tintColor = [UIColor whiteColor];
        }
        
        BOOL unreadMessage = NO;
        
        for (TLDescriptor *descriptor in [call getDescriptors]) {
                  
            if ([descriptor isKindOfClass:[TLObjectDescriptor class]]) {
                BOOL isLocal = ![call isPeerDescriptor:descriptor];
                NSString *name = @"";
                
                if (isLocal) {
                    name = self.originator.identityName;
                } else if ([participantsName objectForKey:descriptor.descriptorId.twincodeOutboundId]) {
                    name = [participantsName objectForKey:descriptor.descriptorId.twincodeOutboundId];
                }
                
                if (!isLocal && descriptor.readTimestamp == 0) {
                    unreadMessage = YES;
                }
        
                [self.conversationView addDescriptor:descriptor isLocal:![call isPeerDescriptor:descriptor] needsReload:NO name:name];
            }
        }
        
        self.unreadMessageView.hidden = ![self.conversationView hasDescriptors];
        
        if (self.unreadMessageView.hidden) {
            self.sharedLocationViewTrailingConstraint.constant = self.headerViewHeightConstraint.constant;
        } else {
            self.sharedLocationViewTrailingConstraint.constant = 0;
        }
        
        if (unreadMessage) {
            self.unreadMessageImageView.image = [UIImage imageNamed:@"CallNewMessageIcon"];
        } else {
            self.unreadMessageImageView.image = [UIImage imageNamed:@"CallMessageIcon"];
        }
    }
    
    if (!self.controlCameraView.hidden) {
        self.unreadMessageViewTrailingConstraint.constant = self.headerViewHeightConstraint.constant;
    } else {
        self.unreadMessageViewTrailingConstraint.constant = 0;
    }
    
    if ([self.callService currentHoldCall]) {
        CallState *holdCallState = [self.callService currentHoldCall];
        
        if (holdCallState.mainParticipant) {
            self.callHoldView.hidden = NO;
            [self.callHoldView setCallInfo:holdCallState.mainParticipant.name avatar:holdCallState.mainParticipant.avatar];
            if (self.callParticipantLocaleView && self.callParticipantViewMode == CallParticipantViewModeSmallLocale) {
                [self.participantsView bringSubviewToFront:self.callParticipantLocaleView];
            }
            [self updateParticipantsViewConstraint];
        }
    }
    
    if (@available(iOS 16.0, *)) {
        [self setNeedsUpdateOfSupportedInterfaceOrientations];
    }
    
    [self updateMenu];
}

- (void)updateCameraControl:(CallParticipant *)callParticipant event:(CallParticipantEvent)event {
    DDLogVerbose(@"%@ updateCameraControl: %@ event: %u", LOG_TAG, callParticipant, event);
    
    if (event == CallParticipantEventAskCameraControl) {
        if (!self.accessCameraGranted) {
            [callParticipant remoteAnswerControlWithGrant:NO];
            return;
        }
        DefaultConfirmView *defaultConfirmView = [[DefaultConfirmView alloc] init];
        defaultConfirmView.confirmViewDelegate = self;
        defaultConfirmView.forceDarkMode = YES;
        defaultConfirmView.tag = CONTROL_CAMERA_ANSWER_TAG;
        NSString *message = [NSString stringWithFormat:TwinmeLocalizedString(@"call_view_controller_camera_control_confirm_message", nil), self.originator.name];
        [defaultConfirmView initWithTitle:TwinmeLocalizedString(@"call_view_controller_camera_control", nil) message:message image:nil avatar:nil action: TwinmeLocalizedString(@"application_accept", nil) actionColor:nil cancel:TwinmeLocalizedString(@"application_cancel", nil)];
        [self.view addSubview:defaultConfirmView];
        [defaultConfirmView showConfirmView];
    } else if (event == CallParticipantEventCameraControlGranted) {
        self.remoteZoom = 1;
        [callParticipant remoteCameraWithMute:NO];
    } else if (event == CallParticipantEventCameraControlDenied) {
        AlertMessageView *alertMessageView = [[AlertMessageView alloc] init];
        alertMessageView.alertMessageViewDelegate = self;
        alertMessageView.forceDarkMode = YES;
        NSString *message = [NSString stringWithFormat:TwinmeLocalizedString(@"call_view_controller_camera_control_denied", nil), self.originator.name];
        [alertMessageView initWithTitle:TwinmeLocalizedString(@"call_view_controller_camera_control", nil) message:message];
        [self.view addSubview:alertMessageView];
        [alertMessageView showAlertView];
    } else if (event == CallParticipantEventCameraControlDone) {
        
    }
    
    [self updateView:[self.callService callStatus]];
}

- (void)updateMenu {
    DDLogVerbose(@"%@ updateMenu", LOG_TAG);
    
    CallStatus callStatus = [self.callService callStatus];
    BOOL isLocalVideoTrack = [self.callService localVideoTrack] != nil;
    BOOL isVideoAllowed = self.accessCameraGranted && (self.isCallStartedInVideo || (self.originator.capabilities.hasVideo && self.originator.identityCapabilities.hasVideo));
    BOOL isCameraControlAllowed = isVideoAllowed && [self isZoomableSupported] && self.originator.capabilities.zoomable != TLVideoZoomableNever && self.callParticipantViews.count == 2;
    BOOL isRemoteCameraControl = [self isRemoteCameraControl];
    
    BOOL isInCall = CALL_IS_ACTIVE(callStatus) && !CALL_IS_ON_HOLD(callStatus);
    BOOL isInPause = CALL_IS_PAUSED(callStatus);
    
    BOOL hideCertify = YES;
    if (self.originator && [self.originator isKindOfClass:[TLContact class]] && self.callParticipantViews.count == 2) {
        TLContact *contact = (TLContact *)self.originator;
        TLCertificationLevel level = contact.certificationLevel;
        if (level >= TLCertificationLevel1 && level <= TLCertificationLevel3) {
            hideCertify = NO;
        }
    }

    [self.menuView updateMenu:isInCall isAudioMuted:[self.callService isAudioMuted] isSpeakerOn:[self.callService isSpeakerOn] isCameraMuted:[self.callService isCameraMuted] isLocalVideoTrack:isLocalVideoTrack isVideoAllowed:isVideoAllowed isConversationAllowed:[self isMessageSupported] isStreamingAudioSupported:[self isStreamingSupported] isShareInvitationAllowed:self.isCallReceiver isShareLocationAllowed:[self isLocationSupported] isInPause:isInPause isLocationShared:[self.callService isLocationStartShared] hideCertify:hideCertify isCertifyRunning:[self.callService isKeyCheckRunning] audioDevice:self.callService.getCurrentAudioDevice isHeadSetAvailable:self.callService.isHeadsetAvailable isCameraControlAllowed:isCameraControlAllowed isRemoteCameraControl:isRemoteCameraControl];
}

- (BOOL)isMessageSupported {
    DDLogVerbose(@"%@ isMessageSupported", LOG_TAG);
    
    for (AbstractCallParticipantView *callParticipantView in self.callParticipantViews) {
        if (callParticipantView.isMessageSupported) {
            return YES;
        }
    }
    
    return NO;
}

- (BOOL)isLocationSupported {
    DDLogVerbose(@"%@ isLocationSupported", LOG_TAG);
    
    for (AbstractCallParticipantView *callParticipantView in self.callParticipantViews) {
        if (callParticipantView.isLocationSupported) {
            return YES;
        }
    }
    
    return NO;
}

- (BOOL)isStreamingSupported {
    DDLogVerbose(@"%@ isStreamingSupported", LOG_TAG);
    
    for (AbstractCallParticipantView *callParticipantView in self.callParticipantViews) {
        if (callParticipantView.isStreamingSupported) {
            return YES;
        }
    }
    
    return NO;
}

- (BOOL)isZoomableSupported {
    DDLogVerbose(@"%@ isZoomableSupported", LOG_TAG);
    
    for (AbstractCallParticipantView *callParticipantView in self.callParticipantViews) {
        if (callParticipantView.isZoomableSupported) {
            return YES;
        }
    }
    
    return NO;
}

- (void)updateCallParticipantView {
    DDLogVerbose(@"%@ updateCallParticipantView", LOG_TAG);
    
    CallState *callState = [self.callService currentCall];
    if (callState) {
        // Important note: call `getParticipants` only once to iterate over it due to multi-threading.
        NSArray<CallParticipant *> *participants = [callState getParticipants];
        
        for (CallParticipant *callParticipant in participants) {
            
            if (!callParticipant.transferredToParticipantId) {
                StreamingStatus streamingStatus = callParticipant.streamingStatus;
                if (!self.streamPlayer && (streamingStatus == StreamingStatusPlaying || callParticipant.streamPlayer)) {
                    [self updateStreamingPlayer:callParticipant event:CallParticipantEventStreamStatus];
                }
                
                AbstractCallParticipantView *callParticipantView = [self getParticipantView:callParticipant];
                if (!callParticipantView) {
                    CallParticipantRemoteView *callParticipantRemoteView = [[CallParticipantRemoteView alloc]init];
                    callParticipantRemoteView.callParticipant = callParticipant;
                    callParticipantRemoteView.delegate = self;
                    callParticipantRemoteView.color = [self getRandomColor];
                    [self.participantsView addSubview:callParticipantRemoteView];
                    [self.callParticipantViews addObject:callParticipantRemoteView];
                } else {
                    CallParticipantRemoteView *callParticipantRemoteView = (CallParticipantRemoteView *)callParticipantView;
                    callParticipantRemoteView.callParticipant = callParticipant;
                }
            }
        }
        
        //add locale video
        if (self.originator && !self.callParticipantLocaleView) {
            self.callParticipantLocaleView = [[CallParticipantLocaleView alloc]init];
            self.callParticipantLocaleView.name = self.originator.identityName;
            [self.twinmeService getIdentityImageWithContact:self.originator withBlock:^(UIImage *image) {
                self.callParticipantLocaleView.avatar = image;
            }];
            
            TLImageService *imageService = [self.twinmeContext getImageService];
            [imageService getImageWithImageId:self.originator.identityAvatarId kind:TLImageServiceKindNormal withBlock:^(TLBaseServiceErrorCode errorCode, UIImage *image) {
                self.callParticipantLocaleView.avatar = image;
            }];
            
            self.callParticipantLocaleView.isAudioMute = !callState.audioSourceOn;
            self.callParticipantLocaleView.isVideoMute = !callState.videoSourceOn;
            self.callParticipantLocaleView.isLocationShared = [self.callService isLocationStartShared];
            
            self.callParticipantLocaleView.delegate = self;
            
            if ([self.callService localVideoTrack] && callState.videoSourceOn) {
                self.callParticipantLocaleView.localVideoTrack = [self.callService localVideoTrack];
                self.callParticipantLocaleView.isFrontCamera = callState.frontCameraOn;
            }
            
            [self.participantsView addSubview:self.callParticipantLocaleView];
            [self.callParticipantViews addObject:self.callParticipantLocaleView];
        } else if (self.originator) {
            self.callParticipantLocaleView.isAudioMute = !callState.audioSourceOn;
            self.callParticipantLocaleView.isVideoMute = !callState.videoSourceOn;
            self.callParticipantLocaleView.isLocationShared = [self.callService isLocationStartShared];
            self.callParticipantLocaleView.name = self.originator.identityName;
            [self.twinmeService getIdentityImageWithContact:self.originator withBlock:^(UIImage *image) {
                self.callParticipantLocaleView.avatar = image;
            }];
            
            TLImageService *imageService = [self.twinmeContext getImageService];
            [imageService getImageWithImageId:self.originator.identityAvatarId kind:TLImageServiceKindNormal withBlock:^(TLBaseServiceErrorCode errorCode, UIImage *image) {
                if (image) {
                    self.callParticipantLocaleView.avatar = image;
                }
            }];
            
            if ([self.callService localVideoTrack] && callState.videoSourceOn) {
                self.callParticipantLocaleView.localVideoTrack = [self.callService localVideoTrack];
                self.callParticipantLocaleView.isFrontCamera = callState.frontCameraOn;
            }
        }
        
        if (!CALL_IS_TERMINATED([self.callService callStatus])) {
            // Important note: if we iterate and remove we must use indexes and start from the end.
            for (NSUInteger i = self.callParticipantViews.count; i > 0;) {
                i--;
                AbstractCallParticipantView *callParticipantView = self.callParticipantViews[i];
                if (callParticipantView.isRemoteParticipant && ![self isParticipantInCall:callParticipantView.getParticipantId participants:participants]) {
                    [callParticipantView removeFromSuperview];
                    [self.callParticipantViews removeObjectAtIndex:i];
                }
            }
        }
        
        if (self.participantsViewInitialized) {
            [self updateParticipantsView];
        }
        
        if (self.callParticipantViews.count >= callState.maxMemberCount && callState.maxMemberCount != 0) {
            self.addParticipantView.alpha = 0.5f;
        } else {
            self.addParticipantView.alpha = 1.f;
        }
    }
}

- (AbstractCallParticipantView *)getParticipantView:(CallParticipant *)callParticipant {
    DDLogVerbose(@"%@ getParticipantView: %@", LOG_TAG, callParticipant);
    
    for (AbstractCallParticipantView *callParticipantView in self.callParticipantViews) {
        if ([callParticipantView getParticipantId] == callParticipant.participantId) {
            return callParticipantView;
        }
    }
    
    return nil;
}

- (BOOL)isParticipantInCall:(int)participantId participants:(NSArray *)participants {
    
    for (CallParticipant *callParticipant in participants) {
        if (callParticipant.participantId == participantId) {
            return YES;
        }
    }
    
    return NO;
}

- (BOOL)isOneCameraEnableInCall {
    DDLogVerbose(@"%@ isOneCameraEnableInCall", LOG_TAG);
    
    for (AbstractCallParticipantView *callParticipantView in self.callParticipantViews) {
        if (!callParticipantView.isCameraMute) {
            return YES;
        }
    }
    
    return NO;
}

- (BOOL)isRemoteCameraControl {
    DDLogVerbose(@"%@ isRemoteCameraControl", LOG_TAG);
    
    for (AbstractCallParticipantView *callParticipantView in self.callParticipantViews) {
        if (callParticipantView.isRemoteCameraControl) {
            return YES;
        }
    }
    
    return NO;
}

- (void)updateParticipantsView {
    DDLogVerbose(@"%@ updateParticipantsView", LOG_TAG);
    
    CallState *callState = [self.callService currentCall];
    if (callState) {
        // Value returned by mainParticipant can change between two calls!
        CallParticipant *mainParticipant = [callState mainParticipant];
        int numberParticipants = (int)self.callParticipantViews.count;
        int position = 1;
        
        NSMutableString *participantsName = [[NSMutableString alloc]init];
        
        CallStatus callStatus = [self.callService callStatus];
        BOOL isVideoCall = [self isOneCameraEnableInCall];
        NSArray<AbstractCallParticipantView *> *sortedViews = [self sortViewsWithViews:self.callParticipantViews mainParticipant:mainParticipant];
        for (AbstractCallParticipantView *callParticipantView in sortedViews) {
            
            callParticipantView.callStatus = callStatus;
            callParticipantView.isVideoCall = isVideoCall;
            callParticipantView.isCallReceiver = self.isCallReceiver;
            callParticipantView.callParticipantViewMode = self.callParticipantViewMode;
            
            if ([callParticipantView isRemoteParticipant]) {
                NSString *name = [callParticipantView getName];
                if (name) {
                    [participantsName appendString:name];
                }
            }
            
            BOOL isMainParticipant = NO;
            CallParticipant *viewParticipant = [callParticipantView getCallParticipant];
            if (viewParticipant && (mainParticipant.participantId == viewParticipant.participantId || (viewParticipant.transferredFromParticipantId && mainParticipant.participantId == [viewParticipant.transferredFromParticipantId intValue]))) {
                isMainParticipant = YES;
            }
            
            BOOL isLandscape = [UIApplication sharedApplication].statusBarOrientation != UIInterfaceOrientationPortrait;
            
            [callParticipantView setPosition:isMainParticipant parentViewWidth:self.participantsView.frame.size.width parentViewHeight:self.participantsView.frame.size.height numberParticipants:numberParticipants position:position hideName:self.menuHidden isLandscape:isLandscape];
            
            position++;
            
            if (position < numberParticipants) {
                [participantsName appendString:@", "];
            }
        }
        
        if (numberParticipants == 2 && [mainParticipant isGroupSupported] != CallGroupSupportYes) {
            self.addParticipantImageView.alpha = 0.5f;
        } else {
            self.addParticipantImageView.alpha = 1.0f;
        }
        
        if (self.isCallReceiver || self.originator.isGroup) {
            self.nameLabel.text = self.contactName;
        } else {
            self.nameLabel.text = participantsName;
        }
        
        if (self.callParticipantViews.count > 1) {
            self.noParticipantsView.hidden = YES;
        } else {
            [self initNoParticipantView];
            self.noParticipantsView.hidden = NO;
        }
    }
}

- (nonnull NSArray<AbstractCallParticipantView *> *) sortViewsWithViews:(nonnull NSArray<AbstractCallParticipantView *> *)views mainParticipant:(nonnull CallParticipant *)mainParticipant {
    long numberParticipants = views.count;
    NSMutableArray<AbstractCallParticipantView *> *sortedViews = [[NSMutableArray alloc] initWithCapacity:numberParticipants];
    
    if(numberParticipants == 1){
        sortedViews[0] = views[0];
    } else if(numberParticipants > 1) {
        
        for (int i = 0; i < numberParticipants; i++) {
            sortedViews[i] = (AbstractCallParticipantView *)[NSNull null];
        }
        
        int i = 1;
        
        for(AbstractCallParticipantView *view in views){
            if([view getCallParticipant] == mainParticipant){
                sortedViews[0] = view;
            }else{
                if (i == numberParticipants){
                    sortedViews[0] = view;
                } else {
                    sortedViews[i++] = view;
                }
            }
        }
        
    }
    
    return sortedViews;
}


- (void)finish {
    DDLogVerbose(@"%@ finish %@", LOG_TAG, self);
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    
    if (self.twinmeService) {
        [self.twinmeService dispose];
        self.twinmeService = nil;
    }
    if (self.twinmeServiceDelegate) {
        [self.twinmeContext removeDelegate:self.twinmeServiceDelegate];
        self.twinmeServiceDelegate = nil;
    }
    if (self.chronometer) {
        [self.chronometer invalidate];
        self.chronometer = nil;
    }
    if (self.terminateTimer) {
        [self.terminateTimer invalidate];
        self.terminateTimer = nil;
    }
    if (self.networkAlertView) {
        [self.networkAlertView dispose];
        self.networkAlertView = nil;
    }
    
    if (self.participant) {
        [self.participant detachRenderer];
        self.participant = nil;
    }
    
    [self.addParticipantImageView.layer removeAllAnimations];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CallEventMessageConnectionState object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CallEventMessageTerminateCall object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CallEventMessageVideoUpdate object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CallEventMessageAudioSinkUpdate object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CallEventMessageCameraSwitch object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CallEventMessageCallOnHold object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CallEventMessageCallResumed object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CallEventMessageCallsMerged object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CallEventMessageSharedLocationEnabled object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CallEventMessageSharedLocationRestricted object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CallEventMessageLocationServicesDisabled object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CallEventCameraControlZoomUpdate object:nil];
    
    if ([UIDevice currentDevice].proximityMonitoringEnabled) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceProximityStateDidChangeNotification object:nil];
    }
    [UIDevice currentDevice].proximityMonitoringEnabled = self.proximityMonitoringEnabled;
    
    if ([UIApplication sharedApplication].statusBarOrientation != UIInterfaceOrientationPortrait) {
        [[UIDevice currentDevice] setValue:[NSNumber numberWithInt:UIInterfaceOrientationPortrait] forKey:@"orientation"];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)callIsTransfered {
    DDLogVerbose(@"%@ callIsTransfered %@", LOG_TAG, self);
    
    self.participantsView.hidden = YES;
    self.menuView.hidden = YES;
    self.addParticipantView.hidden = YES;
    self.messageLabel.hidden = YES;
    self.terminatedLabel.hidden = YES;
    self.transferLabel.hidden = NO;
}

- (void)terminateCallWithTerminateReason:(TLPeerConnectionServiceTerminateReason)terminateReason isHoldCall:(BOOL)isHoldCall {
    DDLogVerbose(@"%@ terminateCallWithTerminateReason: %d isHoldCall: %@", LOG_TAG, terminateReason, isHoldCall ? @"YES":@"NO");
    
    self.showCallQuality = [self.twinmeApplication askCallQualityWithCallDuration:[self.callService duration]];
    [self.callService terminateCallWithTerminateReason:terminateReason];
    
    if (self.streamPlayer.streamer) {
        [self.callService stopStreaming];
        self.streamPlayer = nil;
    }
    
    if ([self.callService getCurrentLocation]) {
        [self.callService stopShareLocation:YES];
    }
    
    if (!isHoldCall) {
        if (terminateReason == TLPeerConnectionServiceTerminateReasonSuccess) {
            self.terminatedLabel.text = TwinmeLocalizedString(@"video_call_view_controller_terminate", nil);
            [self.terminatedLabel sizeToFit];
        } else {
            self.terminatedLabel.text = @"";
        }
        
        if (self.showCallQuality) {
            CallQualityView *callQualityView = [[CallQualityView alloc]initWithDelegate:self];
            [callQualityView showInView:self];
        } else {
            [self finish];
        }
    }
    
}

- (void)handleBackTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleBackTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        [self finish];
        
        CallState *call = [self.callService currentCall];
        if (!call) {
            return;
        }
        
        CallStatus callStatus = [call status];
        if (CALL_IS_ACTIVE(callStatus) || CALL_IS_ACCEPTED(callStatus)) {
            ApplicationDelegate *delegate = (ApplicationDelegate *)[[UIApplication sharedApplication] delegate];
            MainViewController *mainViewController = delegate.mainViewController;
            [mainViewController initCallFloatingViewWithCall:call];
        }
    }
}

- (void)setupFrameSize {
    DDLogVerbose(@"%@ setupFrameSize", LOG_TAG);
    
    if (!self.statusBarOrientation || self.statusBarOrientation != [[UIApplication sharedApplication] statusBarOrientation]) {
        
        self.statusBarOrientation = [[UIApplication sharedApplication] statusBarOrientation];
        self.participantsViewInitialized = NO;
    }
}

- (void)setMenuVisible:(BOOL)visible {
    DDLogVerbose(@"%@ setMenuVisible: %@", LOG_TAG, visible ? @"YES" : @"NO");
    
    CallStatus callStatus = [self.callService callStatus];
    if (!CALL_IS_ACTIVE(callStatus)) {
        return;
    }
    
    if (self.menuHidden != visible) {
        return;
    }
    
    self.menuHidden = !visible;
    
    [self animateMenu:YES];
}

- (void)animateMenu:(BOOL)animated {
    DDLogVerbose(@"%@ animateMenu", LOG_TAG);
    
    float duration = animated ? 0.5 : 0;
    
    [UIView animateWithDuration:duration animations:^{
        if (!self.menuHidden) {
            if (self.callCertifyView) {
                self.headerView.alpha = 0.5;
            } else {
                self.headerView.alpha = 1.0;
            }
            
            self.menuView.alpha = 1.0;
            self.headerViewTopConstraint.constant = 0;
            self.menuViewBottomConstraint.constant = DESIGN_DEFAULT_MENU_MARGIN * Design.HEIGHT_RATIO;
        } else {
            self.headerView.alpha = 0;
            self.menuView.alpha = 0;
            self.headerViewTopConstraint.constant = -self.headerViewHeightConstraint.constant;
            self.menuViewBottomConstraint.constant = self.menuViewHeightConstraint.constant;
        }
        
        [self updateParticipantsViewConstraint];
        
        [self.view setNeedsLayout];
        [self.view layoutIfNeeded];
        
        [self updateParticipantsView];
    }];
}

- (void)initNoParticipantView {
    DDLogVerbose(@"%@ initNoParticipantView", LOG_TAG);
    
    self.noParticipantsViewWidthConstraint.constant = Design.DISPLAY_WIDTH - (DESIGN_MARGIN_PARTICIPANT * 2 * Design.WIDTH_RATIO);
    self.noParticipantsViewHeightConstraint.constant = (self.participantsView.frame.size.height * 0.5) - (DESIGN_MARGIN_PARTICIPANT * Design.WIDTH_RATIO);
    
    self.noParticipantsView.image = self.contactAvatar;
}

- (void)startCertifyView:(BOOL)showOnboarding {
    DDLogVerbose(@"%@ startCertifyView", LOG_TAG);
    
    if (!self.callCertifyView) {
        self.callCertifyView = [[CallCertifyView alloc]init];
        self.callCertifyView.callCertifyViewDelegate = self;
        self.callCertifyView.avatar = self.callParticipantLocaleView.avatar;
        self.callCertifyView.name = self.originator.name;
        [self.twinmeService getImageWithContact:self.originator withBlock:^(UIImage *image) {
            self.callCertifyView.avatar = image;
        }];
        [self.view addSubview:self.callCertifyView];
        
        [NSLayoutConstraint activateConstraints:@[
            [self.callCertifyView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
            [self.callCertifyView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
            [self.callCertifyView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
            [self.callCertifyView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        ]];
        
        [self.callCertifyView updateMessage];
    }
    
    self.callCertifyView.hidden = NO;
    self.headerView.alpha = 0.5f;
    [self.view bringSubviewToFront:self.callCertifyView];
    [self.view bringSubviewToFront:self.menuView];
    
    [self updateMenu];
    
    if (!self.menuHidden) {
        self.menuHidden = YES;
        [self animateMenu:YES];
    }
    
    if (showOnboarding) {
        [self showCertifyByVideoCallOnboarding];
    }
}

- (void)showCertifyByVideoCallOnboarding {
    DDLogVerbose(@"%@ showCertifyByVideoCallOnboarding", LOG_TAG);
    
    if (!self.isCallReceiver) {
        
        OnboardingConfirmView *onboardingConfirmView = [[OnboardingConfirmView alloc] init];
        onboardingConfirmView.confirmViewDelegate = self;
        onboardingConfirmView.forceDarkMode = YES;
        
        UIImage *image = [self.twinmeApplication darkModeEnable:[self currentSpaceSettings]] ? [UIImage imageNamed:@"OnboardingAuthentifiedRelationDark"] : [UIImage imageNamed:@"OnboardingAuthentifiedRelation"];
        NSString *message = [NSString stringWithFormat:TwinmeLocalizedString(@"call_view_controller_certify_onboarding_start_message", nil), self.contactName];
        
        [onboardingConfirmView initWithTitle:TwinmeLocalizedString(@"authentified_relation_view_controller_to_be_certified_title", nil) message:message image:image action:TwinmeLocalizedString(@"authentified_relation_view_controller_start", nil) actionColor:nil cancel:nil];
        [onboardingConfirmView hideCancelAction];
        NSMutableAttributedString *attributedTitle = [[NSMutableAttributedString alloc] initWithString:TwinmeLocalizedString(@"authentified_relation_view_controller_to_be_certified_title", nil) attributes:[NSDictionary dictionaryWithObjectsAndKeys:Design.FONT_BOLD36, NSFontAttributeName, Design.FONT_COLOR_DEFAULT, NSForegroundColorAttributeName, nil]];
        [onboardingConfirmView updateTitle:attributedTitle];
        
        [self.view addSubview:onboardingConfirmView];
        [onboardingConfirmView showConfirmView];
    }
}

- (void)updateParticipantsViewConstraint {
    DDLogVerbose(@"%@ updateParticipantsViewConstraint", LOG_TAG);
    
    int playerHeight = 0;
    if (!self.playerStreamingAudioView.hidden) {
        playerHeight  = self.playerStreamingAudioViewHeightConstraint.constant;
    }
    
    int callHoldHeight = 0;
    if (!self.callHoldView.hidden) {
        callHoldHeight  = self.callHoldViewHeightConstraint.constant;
    }
    
    if (!self.menuHidden) {
        self.participantsViewBottomConstraint.constant = (DESIGN_PARTICIPANTS_BOTTOM_LARGE_MARGIN * Design.HEIGHT_RATIO) + playerHeight + callHoldHeight;
        self.playerStreamingAudioViewBottomConstraint.constant = (DESIGN_PARTICIPANTS_BOTTOM_LARGE_MARGIN * Design.HEIGHT_RATIO) + callHoldHeight;
        self.callHoldViewBottomConstraint.constant = (DESIGN_PARTICIPANTS_BOTTOM_LARGE_MARGIN * Design.HEIGHT_RATIO);
    } else {
        self.participantsViewBottomConstraint.constant = (DESIGN_PARTICIPANTS_BOTTOM_MARGIN * Design.HEIGHT_RATIO) + playerHeight + callHoldHeight;
        self.playerStreamingAudioViewBottomConstraint.constant = (DESIGN_PARTICIPANTS_BOTTOM_MARGIN * Design.HEIGHT_RATIO) + callHoldHeight;
        self.callHoldViewBottomConstraint.constant = (DESIGN_PARTICIPANTS_BOTTOM_MARGIN * Design.HEIGHT_RATIO);
    }
}

- (void)singleTap {
    DDLogVerbose(@"%@ singleTap", LOG_TAG);
    
    // When the call is terminated, close the view when the user taps on it.
    CallStatus callStatus = [self.callService callStatus];
    if ((callStatus == CallStatusNone || callStatus == CallStatusTerminated) && !self.showCallQuality) {
        [self finish];
        return;
    }
    
    if (self.callParticipantLocaleView.hidden) {
        return;
    }
    
    self.menuHidden = !self.menuHidden;
    
    [self animateMenu:YES];
}

- (void)setVideoCallZoom:(float)zoomLevel {
    DDLogVerbose(@"%@ setVideoCallZoom: %f", LOG_TAG, zoomLevel);
    
    AVCaptureDevice *captureDevice = [self getCaptureDevice];
    if (captureDevice) {
        AVCaptureDeviceFormat *format = captureDevice.activeFormat;
        CGFloat maxZoomFactor = format.videoMaxZoomFactor;
                
        self.videoZoom = zoomLevel;
        if (self.videoZoom >= maxZoomFactor) {
            self.videoZoom = maxZoomFactor;
        } else if (self.videoZoom <= 1.0) {
            self.videoZoom = 1.0;
        }

        CGFloat zoomPercent = (self.videoZoom / maxZoomFactor) * 100;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.zoomLevelLabel.text = [NSString stringWithFormat:@"%.0f%%", zoomPercent];
        });
        
        NSError *error = nil;
        if ([captureDevice lockForConfiguration:&error]) {
            [captureDevice rampToVideoZoomFactor:self.videoZoom withRate:2.0];
            [captureDevice unlockForConfiguration];
        }
    }
}

- (void)startChronometer {
    DDLogVerbose(@"%@ startChronometer", LOG_TAG);
    
    if (self.chronometer) {
        [self.chronometer invalidate];
        self.chronometer = nil;
    }
    self.chronometer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(chronometerTimerFire:) userInfo:nil repeats:YES];
    [self chronometerTimerFire:self.chronometer];
}

- (void)chronometerTimerFire:(NSTimer *)timer {
    DDLogVerbose(@"%@ chronometerTimerFire: %@", LOG_TAG, timer);
    
    self.elapsedTime = [self.callService duration];
    if (self.elapsedTime < 3600) {
        self.messageLabel.text = [NSString convertWithInterval:self.elapsedTime format:@"mm:ss"];
    } else {
        self.messageLabel.text = [NSString convertWithInterval:self.elapsedTime format:@"HH:mm:ss"];
    }
}

- (void)terminateFire:(NSTimer *)timer {
    DDLogVerbose(@"%@ terminateFire: %@", LOG_TAG, timer);
    
    if (!self.showCallQuality) {
        [self finish];
    }
}

- (NSString *)titleWithTerminateReason:(TLPeerConnectionServiceTerminateReason)terminateReason {
    DDLogVerbose(@"%@ titleWithTerminateReason: %d", LOG_TAG, terminateReason);
    
    if (terminateReason == TLPeerConnectionServiceTerminateReasonSchedule) {
        return TwinmeLocalizedString(@"show_call_view_controller_schedule_call", nil);
    }
    
    return TwinmeLocalizedString(@"application_name", nil);
}

- (NSString *)messageWithTerminateReason:(TLPeerConnectionServiceTerminateReason)terminateReason {
    DDLogVerbose(@"%@ messageWithTerminateReason: %d", LOG_TAG, terminateReason);
    
    if (!self.contactName) {
        return TwinmeLocalizedString(@"video_call_view_controller_terminate", nil);
    }
    
    switch(terminateReason) {
        case TLPeerConnectionServiceTerminateReasonBusy:
            return [NSString stringWithFormat:TwinmeLocalizedString(@"video_call_view_controller_terminate_busy %@", nil), self.contactName];
            
        case TLPeerConnectionServiceTerminateReasonCancel:
            return [NSString stringWithFormat:TwinmeLocalizedString(@"video_call_view_controller_terminate_cancel %@", nil), self.contactName];
            
        case TLPeerConnectionServiceTerminateReasonConnectivityError:
            return TwinmeLocalizedString(@"video_call_view_controller_terminate_connectivity_error", nil);
            
        case TLPeerConnectionServiceTerminateReasonDecline:
            return [NSString stringWithFormat:TwinmeLocalizedString(@"video_call_view_controller_terminate_decline %@", nil), self.contactName];
            
        case TLPeerConnectionServiceTerminateReasonDisconnected:
            return TwinmeLocalizedString(@"video_call_view_controller_terminate_disconnected_error", nil);
            
        case TLPeerConnectionServiceTerminateReasonNotAuthorized:
            return TwinmeLocalizedString(@"video_call_view_controller_terminate_not_authorized", nil);
            
        case TLPeerConnectionServiceTerminateReasonGone:
            return [NSString stringWithFormat:TwinmeLocalizedString(@"video_call_view_controller_terminate_gone %@", nil), self.contactName];
            
        case TLPeerConnectionServiceTerminateReasonRevoked:
            return [NSString stringWithFormat:TwinmeLocalizedString(@"video call terminated: %@ has revoked this identity", nil), self.contactName];
            
        case TLPeerConnectionServiceTerminateReasonSuccess:
            return [NSString stringWithFormat:TwinmeLocalizedString(@"video_call_view_controller_terminate_success %@", nil), self.contactName];
            
        case TLPeerConnectionServiceTerminateReasonTimeout:
            if (self.outgoingCall) {
                return [NSString stringWithFormat:TwinmeLocalizedString(@"video_call_view_controller_terminate_timeout %@", nil), self.contactName];
            }
            return TwinmeLocalizedString(@"video_call_view_controller_terminate", nil);
            
        case TLPeerConnectionServiceTerminateReasonSchedule:
            if(self.outgoingCall){
                TLSchedule *schedule = self.originator.capabilities.schedule;
                
                if (schedule && schedule.timeRanges.count > 0) {
                    TLDateTimeRange *dateTimeRange = (TLDateTimeRange *)[schedule.timeRanges objectAtIndex:0];
                    TLDateTime *start = dateTimeRange.start;
                    TLDateTime *end = dateTimeRange.end;
                    
                    if ([start.date isEqual:end.date]) {
                        return [NSString stringWithFormat:TwinmeLocalizedString(@"show_call_view_controller_schedule_from_to", nil), [start.date formatDate], [start.time formatTime], [end.time formatTime]];
                    } else {
                        return [NSString stringWithFormat:@"%@ %@", [start formatDateTime], [end formatDateTime]];
                    }
                }
                
                return TwinmeLocalizedString(@"show_call_view_controller_schedule_message", nil);
            }
            
        default: {
            NSString *reason;
            if (self.elapsedTime > 0) {
                reason = [NSString stringWithFormat:TwinmeLocalizedString(@"call_view_controller_error_call_interrupted", nil), terminateReason];
            } else {
                reason = [NSString stringWithFormat:TwinmeLocalizedString(@"call_view_controller_error_call_not_go_thru", nil), terminateReason];
            }
                        
            return [NSString stringWithFormat:@"%@\n%@", reason, TwinmeLocalizedString(@"call_view_controller_try_to_call_back", nil)];
        }
    }
}

- (void)showCoachMark {
    DDLogVerbose(@"%@ showCoachMark", LOG_TAG);
    
    if ([self.twinmeApplication showCoachMark:TAG_COACH_MARK_ADD_PARTICIPANT_TO_CALL]) {
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(DELAY_COACH_MARK * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            CoachMarkViewController *coachMarkViewController = (CoachMarkViewController *)[[UIStoryboard storyboardWithName:@"iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"CoachMarkViewController"];
            CGRect clipRect = CGRectMake(self.addParticipantView.frame.origin.x, self.addParticipantView.frame.origin.y + self.addParticipantView.frame.size.height, self.addParticipantView.frame.size.height, self.addParticipantView.frame.size.height);
            CoachMark *coachMark = [[CoachMark alloc]initWithMessage:TwinmeLocalizedString(@"call_view_controller_coach_mark", nil) tag:TAG_COACH_MARK_ADD_PARTICIPANT_TO_CALL alignLeft:NO onTop:NO featureRect:clipRect featureRadius:self.addParticipantView.frame.size.height * 0.5f];
            [coachMarkViewController initWithCoachMark:coachMark];
            coachMarkViewController.delegate = self;
            [coachMarkViewController showInView:self.navigationController];
        });
    }
}

- (void)addCallParticipantAnimation {
    DDLogVerbose(@"%@ addCallParticipantAnimation", LOG_TAG);
    
    if ([self.twinmeApplication showGroupCallAnimation] && !self.showCallGroupAnimation) {
        self.showCallGroupAnimation = YES;
        CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
        animationGroup.beginTime = CACurrentMediaTime() + SCALE_ANIMATION_BEGIN_TIME;
        animationGroup.duration = SCALE_ANIMATION_REPEAT_DELAY;
        animationGroup.repeatCount = INFINITY;
        
        CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale.xy"];
        scaleAnimation.fromValue = @1.0;
        scaleAnimation.toValue = @1.4;
        scaleAnimation.autoreverses = YES;
        scaleAnimation.duration = SCALE_ANIMATION_DURATION;
        scaleAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        animationGroup.animations = @[scaleAnimation];
        
        [self.addParticipantImageView.layer addAnimation:animationGroup forKey:@"scale"];
    }
}

- (void)initCallPariticipantColor {
    DDLogVerbose(@"%@ initCallPariticipantColor", LOG_TAG);
    
    self.callParticipantColors = [[NSMutableArray alloc]init];
    [self.callParticipantColors addObject:[UIColor colorWithHexString:@"#F5B000" alpha:1.0]];
    [self.callParticipantColors addObject:[UIColor colorWithHexString:@"#85CE79" alpha:1.0]];
    [self.callParticipantColors addObject:[UIColor colorWithHexString:@"#6DB8C2" alpha:1.0]];
    [self.callParticipantColors addObject:[UIColor colorWithHexString:@"#4CD0D9" alpha:1.0]];
    [self.callParticipantColors addObject:[UIColor colorWithHexString:@"#4C8DD9" alpha:1.0]];
    [self.callParticipantColors addObject:[UIColor colorWithHexString:@"#704CD9" alpha:1.0]];
    [self.callParticipantColors addObject:[UIColor colorWithHexString:@"#E36F04" alpha:1.0]];
    [self.callParticipantColors addObject:[UIColor colorWithHexString:@"#7991CE" alpha:1.0]];
    [self.callParticipantColors addObject:[UIColor colorWithHexString:@"#F53B00" alpha:1.0]];
    [self.callParticipantColors addObject:[UIColor colorWithHexString:@"#E15A5A" alpha:1.0]];
    [self.callParticipantColors addObject:[UIColor colorWithHexString:@"#96A655" alpha:1.0]];
}

- (UIColor *)getRandomColor {
    DDLogVerbose(@"%@ getRandomColor", LOG_TAG);
    
    if (self.callParticipantColors && self.callParticipantColors.count > 0) {
        NSUInteger random = arc4random() % self.callParticipantColors.count;
        UIColor *randomColor = [self.callParticipantColors objectAtIndex:random];
        [self.callParticipantColors removeObjectAtIndex:random];
        return randomColor;
    }
    
    return Design.GREY_BACKGROUND_COLOR;
}

- (void)keyboardWillShow:(NSNotification *)notification {
    DDLogVerbose(@"%@ keyboardWillShow: %@", LOG_TAG, notification);
    
    if (!self.keyboardHidden) {
        return;
    }
    
    self.keyboardHidden = NO;
    NSDictionary *info = [notification userInfo];
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    if ([self.twinmeApplication getDefaultKeyboardHeight] != keyboardSize.height) {
        [self.twinmeApplication setDefaultKeyboardHeight:keyboardSize.height];
    }
    
    self.conversationViewBottomConstraint.constant = [self.twinmeApplication getDefaultKeyboardHeight];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    DDLogVerbose(@"%@ keyboardWillHide: %@", LOG_TAG, notification);
    
    self.keyboardHidden = YES;
    
    self.conversationViewBottomConstraint.constant = (DESIGN_DEFAULT_MENU_MARGIN + DESIGN_PARTICIPANTS_BOTTOM_MARGIN) * Design.HEIGHT_RATIO;
}

- (void)keyboardWillChangeFrame:(NSNotification *)notification {
    DDLogVerbose(@"%@ keyboardWillChangeFrame: %@", LOG_TAG, notification);
    
    NSDictionary *info = [notification userInfo];
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    self.conversationViewBottomConstraint.constant = keyboardSize.height;
}

- (void)showPremiumFeature:(FeatureType)featureType{
    DDLogVerbose(@"%@ showPremiumFeature: %d", LOG_TAG, featureType);
    
    PremiumFeatureConfirmView *premiumFeatureConfirmView = [[PremiumFeatureConfirmView alloc] init];
    premiumFeatureConfirmView.confirmViewDelegate = self;
    premiumFeatureConfirmView.forceDarkMode = YES;
    [premiumFeatureConfirmView initWithPremiumFeature:[[UIPremiumFeature alloc]initWithFeatureType:featureType spaceSettings:self.currentSpaceSettings] parentViewController:self];
    [self.view addSubview:premiumFeatureConfirmView];
    [premiumFeatureConfirmView showConfirmView];
}
 
- (void)showCameraControlOnboarding {
    DDLogVerbose(@"%@ showCameraControlOnboarding", LOG_TAG);
    
    self.showRemoteCameraOnboarding = YES;
    
    OnboardingConfirmView *onboardingConfirmView = [[OnboardingConfirmView alloc] init];
    onboardingConfirmView.confirmViewDelegate = self;
    onboardingConfirmView.tag = ONBOARDING_REMOTE_CAMERA;
    onboardingConfirmView.forceDarkMode = YES;
    [onboardingConfirmView initWithTitle:TwinmeLocalizedString(@"call_view_controller_camera_control_needs_help", nil) message: TwinmeLocalizedString(@"call_view_controller_camera_control_onboarding_part_2", nil) image:[UIImage imageNamed:@"OnboardingControlCamera"] action:TwinmeLocalizedString(@"application_ok", nil) actionColor:nil cancel:TwinmeLocalizedString(@"application_do_not_display", nil)];
    
    [self.view addSubview:onboardingConfirmView];
    [onboardingConfirmView showConfirmView];
}

- (void)checkAuthorization {
    DDLogVerbose(@"%@ checkAuthorization", LOG_TAG);
    
    AVAuthorizationStatus cameraAuthorizationStatus = [DeviceAuthorization deviceCameraAuthorizationStatus];
    
    switch (cameraAuthorizationStatus) {
        case AVAuthorizationStatusNotDetermined: {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                // The completionHandler is called from another thread: current thread is not the main thread!
                self.accessCameraGranted = granted;
                if (granted) {
                    AVAudioSessionRecordPermission audioSessionRecordPermission = [DeviceAuthorization deviceMicrophonePermissionStatus];
                    switch (audioSessionRecordPermission) {
                        case AVAudioSessionRecordPermissionUndetermined: {
                            [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
                                dispatch_async(dispatch_get_main_queue(), ^(void){
                                    if (!granted) {
                                        dispatch_async(dispatch_get_main_queue(), ^(void){
                                            [self terminateCallWithTerminateReason:TLPeerConnectionServiceTerminateReasonNotAuthorized isHoldCall:NO];
                                            [DeviceAuthorization showMicrophoneCameraSettingsAlertInController:self];
                                        });
                                    } else {
                                        [self updateMenu];
                                    }
                                });
                            }];
                            break;
                        }
                            
                        case AVAudioSessionRecordPermissionDenied: {
                            // Current thread is not the main thread!
                            dispatch_async(dispatch_get_main_queue(), ^(void) {
                                [self terminateCallWithTerminateReason:TLPeerConnectionServiceTerminateReasonNotAuthorized isHoldCall:NO];
                                [DeviceAuthorization showMicrophoneCameraSettingsAlertInController:self];
                            });
                            break;
                        }
                            
                        case AVAudioSessionRecordPermissionGranted:
                            dispatch_async(dispatch_get_main_queue(), ^(void){
                                [self updateMenu];
                            });
                            
                            break;
                    }
                } else if (self.isCallStartedInVideo) {
                    // Current thread is not the main thread!
                    dispatch_async(dispatch_get_main_queue(), ^(void) {
                        [self terminateCallWithTerminateReason:TLPeerConnectionServiceTerminateReasonNotAuthorized isHoldCall:NO];
                        [DeviceAuthorization showMicrophoneCameraSettingsAlertInController:self];
                    });
                } else {
                    AVAudioSessionRecordPermission audioSessionRecordPermission = [DeviceAuthorization deviceMicrophonePermissionStatus];
                    switch (audioSessionRecordPermission) {
                        case AVAudioSessionRecordPermissionUndetermined: {
                            [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
                                dispatch_async(dispatch_get_main_queue(), ^(void){
                                    if (!granted) {
                                        [self terminateCallWithTerminateReason:TLPeerConnectionServiceTerminateReasonNotAuthorized isHoldCall:NO];
                                        [DeviceAuthorization showMicrophoneCameraSettingsAlertInController:self];
                                    } else {
                                        [self updateMenu];
                                    }
                                });
                            }];
                            break;
                        }
                            
                        case AVAudioSessionRecordPermissionDenied:
                            [self terminateCallWithTerminateReason:TLPeerConnectionServiceTerminateReasonNotAuthorized isHoldCall:NO];
                            [DeviceAuthorization showMicrophoneCameraSettingsAlertInController:self];
                            break;
                            
                        case AVAudioSessionRecordPermissionGranted:
                            dispatch_async(dispatch_get_main_queue(), ^(void){
                                [self updateMenu];
                            });
                            break;
                    }
                }
            }];
            break;
        }
            
        case AVAuthorizationStatusRestricted:
        case AVAuthorizationStatusDenied: {
            self.accessCameraGranted = NO;
            if (self.isCallStartedInVideo) {
                [self terminateCallWithTerminateReason:TLPeerConnectionServiceTerminateReasonNotAuthorized isHoldCall:NO];
                [DeviceAuthorization showMicrophoneCameraSettingsAlertInController:self];
            } else {
                AVAudioSessionRecordPermission audioSessionRecordPermission = [DeviceAuthorization deviceMicrophonePermissionStatus];
                switch (audioSessionRecordPermission) {
                    case AVAudioSessionRecordPermissionUndetermined: {
                        [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
                            dispatch_async(dispatch_get_main_queue(), ^(void){
                                if (!granted) {
                                    [self terminateCallWithTerminateReason:TLPeerConnectionServiceTerminateReasonNotAuthorized isHoldCall:NO];
                                    [DeviceAuthorization showMicrophoneCameraSettingsAlertInController:self];
                                } else {
                                    [self updateMenu];
                                }
                            });
                        }];
                        break;
                    }
                        
                    case AVAudioSessionRecordPermissionDenied:
                        [self terminateCallWithTerminateReason:TLPeerConnectionServiceTerminateReasonNotAuthorized isHoldCall:NO];
                        [DeviceAuthorization showMicrophoneCameraSettingsAlertInController:self];
                        break;
                        
                    case AVAudioSessionRecordPermissionGranted:
                        dispatch_async(dispatch_get_main_queue(), ^(void){
                            [self updateMenu];
                        });
                        break;
                }
            }
            
            break;
        }
            
        case AVAuthorizationStatusAuthorized: {
            self.accessCameraGranted = YES;
            AVAudioSessionRecordPermission audioSessionRecordPermission = [DeviceAuthorization deviceMicrophonePermissionStatus];
            switch (audioSessionRecordPermission) {
                case AVAudioSessionRecordPermissionUndetermined: {
                    [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
                        dispatch_async(dispatch_get_main_queue(), ^(void){
                            if (!granted) {
                                [self terminateCallWithTerminateReason:TLPeerConnectionServiceTerminateReasonNotAuthorized isHoldCall:NO];
                                [DeviceAuthorization showMicrophoneCameraSettingsAlertInController:self];
                            } else {
                                [self updateMenu];
                            }
                        });
                    }];
                    break;
                }
                    
                case AVAudioSessionRecordPermissionDenied:
                    [self terminateCallWithTerminateReason:TLPeerConnectionServiceTerminateReasonNotAuthorized isHoldCall:NO];
                    [DeviceAuthorization showMicrophoneCameraSettingsAlertInController:self];
                    break;
                    
                case AVAudioSessionRecordPermissionGranted:
                    dispatch_async(dispatch_get_main_queue(), ^(void){
                        [self updateMenu];
                    });
                    break;
            }
            break;
        }
    }
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    self.nameLabel.font = Design.FONT_REGULAR34;
    self.messageLabel.font = Design.FONT_REGULAR34;
    self.terminatedLabel.font = Design.FONT_REGULAR34;
    self.transferLabel.font = Design.FONT_REGULAR34;
    self.zoomLevelLabel.font = Design.FONT_BOLD44;
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    self.nameLabel.textColor = [UIColor whiteColor];
    self.messageLabel.textColor = [UIColor whiteColor];
    self.terminatedLabel.textColor = [UIColor whiteColor];
    self.transferLabel.textColor = [UIColor whiteColor];
}

@end
