/*
 *  Copyright (c) 2016-2024 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Chedi Baccari (Chedi.Baccari@twinlife-systems.com)
 *   Christian Jacquemot (Christian.Jacquemot@twinlife-systems.com)
 *   Stephane Carrez (Stephane.Carrez@twin.life)
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <WebRTC/RTCAudioSession.h>
#import <WebRTC/RTCAudioSessionConfiguration.h>

#import <Twinlife/TLTwinlife.h>
#import <Twinlife/TLConfigIdentifier.h>
#import <Twinme/TLSpaceSettings.h>

#import <TwinmeCommon/TwinmeApplication.h>

#import <TwinmeCommon/Design.h>
#import <TwinmeCommon/NotificationCenter.h>
#import <TwinmeCommon/NotificationSound.h>
#import <TwinmeCommon/CallService.h>
#import <TwinmeCommon/CallState.h>
#import <TwinmeCommon/ApplicationDelegate.h>
#import "LastVersion.h"
#import "LastVersionManager.h"
#import "CoachMarkManager.h"
#import <Utils/NSString+Utils.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

#define FIRST_INSTALLATION @"FirstInstallation"
#define SHOW_WELCOME_SCREEN @"DefaultShowWelcomeScreen"
#define ALLOW_COPY_TEXT @"DefaultAllowCopyText"
#define ALLOW_COPY_FILE @"DefaultAllowCopyFile"
#define DEFAULT_KEYBOARD_HEIGHT @"DefaultKeyboardHeight"
#define FONT_SIZE @"DefaultFontSize"
#define EMOJI_SIZE @"EmojiSize"
#define VISUALIZATION_LINK @"VisualizationLink"
#define DISPLAY_MODE @"DefaultDisplayMode"
#define HAPTIC_FEEDBACK_MODE @"DefaultHapticFeedbackMode"
#define FIRST_SHOW_UPGRADE_SCREEN @"FirstShowUpgradeScreen_2023"
#define LAST_SHOW_UPGRADE_SCREEN @"LastShowUpgradeScreen_2023"
#define CAN_SHOW_UPGRADE_SCREEN @"CanShowUpgradeScreen"
#define LAST_SHOW_ENABLE_NOTIFICATION_SCREEN @"LastShowEnableNotificationScreen"
#define SHOW_ONBOARDING_CERTIFIED_RELATION @"ShowOnboardingCertifiedRelation"
#define SHOW_ONBOARDING_EXTERNAL_CALL @"ShowOnboardingExternalCall"
#define SHOW_ONBOARDING_PROFILE @"ShowOnboardingProfile"
#define SHOW_ONBOARDING_SPACE @"ShowOnboardingSpace"
#define SHOW_ONBOARDING_TRANSFER @"ShowOnboardingTransfer"
#define SHOW_ONBOARDING_ENTER_MINI_CODE @"ShowOnboardingEnterMiniCode"
#define SHOW_ONBOARDING_MINI_CODE @"ShowOnboardingMiniCode"
#define SHOW_ONBOARDING_REMOTE_CAMERA @"ShowOnboardingRemoteCamera"
#define SHOW_ONBOARDING_REMOTE_CAMERA_SETTINGS @"ShowOnboardingRemoteCameraSettings"
#define SHOW_ONBOARDING_TRANSFER_CALL @"ShowOnboardingTransferCall"
#define SHOW_ONBOARDING_PROXY @"ShowOnboardingProxy"
#define SHOW_WARNING_EDIT_MESSAGE @"ShowWarningEditMessage"
#define DEFAULT_TAB @"DefaultTab"
#define IS_VIDEO_IN_FIT_MODE @"IsVideoInFitMode"
#define CALL_QUALITY_COUNT @"CallQualityCount"
#define CALL_QUALITY_LAST_DATE @"CallQualityLastDate"
#define LAST_UPDATED_VERSION @"LastUpdatedVersion"
#define SEND_IMAGE_SIZE @"SendImageSize"
#define SEND_VIDEO_SIZE @"SendVideoSize"
#define DISPLAY_CALLS_MODE @"DisplayCallsMode"
#define PROFILE_UPDATE_MODE @"ProfileUpdateMode"
#define SHOW_GROUP_CALL_ANIMATION @"DefaultShowGroupCallAnimation"

#define DEFAULT_COLOR @"#00AEFF"

static const int64_t CALL_QUALITY_MIN_DURATION = 5 * 60;
static const int64_t CALL_QUALITY_ASK_FREQUENCY = 10;
static const int64_t CALL_QUALITY_INTERVAL_DATE = 10 * 60 * 60 * 24;

static TLBooleanConfigIdentifier *showWelcomeConfig;

// Display settings.
static TLBooleanConfigIdentifier *visualizationLinkConfig;
static TLIntegerConfigIdentifier *hapticFeedbackModeConfig;
static TLIntegerConfigIdentifier *defaultTabConfig;
static TLIntegerConfigIdentifier *displayModeConfig;
static TLIntegerConfigIdentifier *displayCallsModeConfig;
static TLIntegerConfigIdentifier *emojiSizeConfig;
static TLIntegerConfigIdentifier *fontSizeConfig;
static TLBooleanConfigIdentifier *showGroupCallAnimationConfig;

// Message settings
static TLIntegerConfigIdentifier *sendImageSizeConfig;
static TLIntegerConfigIdentifier *sendVideoSizeConfig;

// Behavior settings
static TLIntegerConfigIdentifier *profileUpdateModeConfig;

// The allowCopyText and allowCopyFile must be saved in the app group for the ShareExtension.
static TLBooleanSharedConfigIdentifier *allowCopyTextConfig;
static TLBooleanSharedConfigIdentifier *allowCopyFileConfig;

// Call
static TLBooleanConfigIdentifier *videoCallInFitModeConfig;
static TLIntegerConfigIdentifier *callQualityCountConfig;
static TLIntegerConfigIdentifier *callQualityLastDateConfig;

// Internal settings (they are not transfered by account migration).
static TLBooleanConfigIdentifier *canShowUpgradeScreenConfig;
static TLIntegerConfigIdentifier *firstInstallationConfig;
static TLIntegerConfigIdentifier *lastShowUpgradeScreenConfig;
static TLIntegerConfigIdentifier *lastShowEnableNotificationScreenConfig;
static TLIntegerConfigIdentifier *firstShowUpgradeScreenConfig;
static TLBooleanConfigIdentifier *showOnboardingCertifiedRelationConfig;
static TLBooleanConfigIdentifier *showOnboardingExternalCallConfig;
static TLBooleanConfigIdentifier *showOnboardingProfileConfig;
static TLBooleanConfigIdentifier *showOnboardingSpaceConfig;
static TLBooleanConfigIdentifier *showOnboardingTransferConfig;
static TLBooleanConfigIdentifier *showOnboardingEnterMiniCodeConfig;
static TLBooleanConfigIdentifier *showOnboardingMiniCodeConfig;
static TLBooleanConfigIdentifier *showOnboardingRemoteCamera;
static TLBooleanConfigIdentifier *showOnboardingRemoteCameraSettings;
static TLBooleanConfigIdentifier *showOnboardingTransferCall;
static TLBooleanConfigIdentifier *showOnboardingProxy;
static TLBooleanConfigIdentifier *showWarningEditMessage;
static TLFloatConfigIdentifier *keyboardHeightConfig;


//
// Interface: TwinmeApplication ()
//

@interface TwinmeApplication ()

@property (nonatomic, nullable) CallService *callService;
@property BOOL showConnectedMessage;

@end

//
// Implementation: TwinmeApplication
//

#undef LOG_TAG
#define LOG_TAG @"TwinmeApplication"

@implementation TwinmeApplication
@synthesize showConnectedMessage = _showConnectedMessage;

- (instancetype)init {
    DDLogVerbose(@"%@ init", LOG_TAG);
    
    self = [super init];
    if (self) {
        _settings = [[NotificationSettings alloc] init];
        
        _lastVersionManager = [[LastVersionManager alloc] init];
        [_lastVersionManager getLastVersion];
        
        _coachMarkManager = [[CoachMarkManager alloc] init];
        _showConnectedMessage = YES;
        
        [NotificationSettings initializeSettings];

        showWelcomeConfig = [TLBooleanConfigIdentifier defineWithName:SHOW_WELCOME_SCREEN uuid:@"04E86861-71B6-40A0-9BAB-9AE58CC2E765" defaultValue:YES];

        allowCopyTextConfig = [TLBooleanSharedConfigIdentifier defineWithName:ALLOW_COPY_TEXT uuid:@"3FC4574E-79CD-4CD6-8FD4-AC541162C312" defaultValue:YES];
        allowCopyFileConfig = [TLBooleanSharedConfigIdentifier defineWithName:ALLOW_COPY_FILE uuid:@"1A3E0E6E-78FE-448B-A671-7C5B4BA6AC72" defaultValue:YES];

        displayModeConfig = [TLIntegerConfigIdentifier defineWithName:DISPLAY_MODE uuid:@"44CE232D-4BA3-4295-8B27-7BD9981AD555" defaultValue:DisplayModeSystem];

        fontSizeConfig = [TLIntegerConfigIdentifier defineWithName:FONT_SIZE uuid:@"8961B734-1D70-407B-A02B-0F673FB2F8BC" defaultValue:FontSizeSystem];

        emojiSizeConfig = [TLIntegerConfigIdentifier defineWithName:EMOJI_SIZE uuid:@"5CDAfAE4-FFE8-4754-A178-4f8C5DC834E0" defaultValue:EmojiSizeStandard];
        
        visualizationLinkConfig = [TLBooleanConfigIdentifier defineWithName:VISUALIZATION_LINK uuid:@"4B143BC6-1590-4889-B46A-2B54BCf5DBA8" defaultValue:YES];
        hapticFeedbackModeConfig = [TLIntegerConfigIdentifier defineWithName:HAPTIC_FEEDBACK_MODE uuid:@"E9819421-CD71-4C3D-AB6A-0783F0FF4532" defaultValue:HapticFeedbackModeSystem];
        
        defaultTabConfig = [TLIntegerConfigIdentifier defineWithName:DEFAULT_TAB uuid:@"AD11179C-1510-4F1A-A4C2-0F29DC989997" defaultValue:DefaultTabConversations];

        sendImageSizeConfig = [TLIntegerConfigIdentifier defineWithName:SEND_IMAGE_SIZE uuid:@"85F98FDE-5C4E-11ED-9B6A-0242AC120002" defaultValue:SendImageSizeOriginal];
        sendVideoSizeConfig = [TLIntegerConfigIdentifier defineWithName:SEND_VIDEO_SIZE uuid:@"E476F52F-C863-4463-BAB4-B89C875E601F" defaultValue:SendVideoSizeOriginal];

        displayCallsModeConfig = [TLIntegerConfigIdentifier defineWithName:DISPLAY_CALLS_MODE uuid:@"FA50C4AC-C196-4F3F-BD68-3DE18D27F44E" defaultValue:TLDisplayCallsModeMissed];

        profileUpdateModeConfig = [TLIntegerConfigIdentifier defineWithName:PROFILE_UPDATE_MODE uuid:@"959957DA-B8EE-4506-8A5E-A5006023E13D" defaultValue:TLProfileUpdateModeNone];

        videoCallInFitModeConfig = [TLBooleanConfigIdentifier defineWithName:IS_VIDEO_IN_FIT_MODE uuid:@"D36D6D8A-2DFF-11ED-A261-0242AC120002" defaultValue:NO];
        callQualityCountConfig = [TLIntegerConfigIdentifier defineWithName:CALL_QUALITY_COUNT uuid:@"DDD83ED6-3335-11ED-A261-0242AC120002" defaultValue:0];
        callQualityLastDateConfig = [TLIntegerConfigIdentifier defineWithName:CALL_QUALITY_LAST_DATE uuid:@"B57863E8-3336-11ED-A261-0242AC120002" defaultValue:0];

        showGroupCallAnimationConfig = [TLBooleanConfigIdentifier defineWithName:SHOW_GROUP_CALL_ANIMATION uuid:@"BB834EE6-3927-42E1-BC46-5663B2AB47DB" defaultValue:YES];

        // Configurations not migrated between devices.
        firstInstallationConfig = [TLIntegerConfigIdentifier defineWithName:FIRST_INSTALLATION defaultValue:0];
        keyboardHeightConfig = [TLFloatConfigIdentifier defineWithName:DEFAULT_KEYBOARD_HEIGHT defaultValue:0];

        firstShowUpgradeScreenConfig = [TLIntegerConfigIdentifier defineWithName:FIRST_SHOW_UPGRADE_SCREEN defaultValue:0];
        
        lastShowUpgradeScreenConfig = [TLIntegerConfigIdentifier defineWithName:LAST_SHOW_UPGRADE_SCREEN defaultValue:0];
        
        canShowUpgradeScreenConfig = [TLBooleanConfigIdentifier defineWithName:CAN_SHOW_UPGRADE_SCREEN defaultValue:NO];

        lastShowEnableNotificationScreenConfig = [TLIntegerConfigIdentifier defineWithName:LAST_SHOW_ENABLE_NOTIFICATION_SCREEN defaultValue:0];

        showOnboardingCertifiedRelationConfig = [TLBooleanConfigIdentifier defineWithName:SHOW_ONBOARDING_CERTIFIED_RELATION defaultValue:YES];
        showOnboardingExternalCallConfig = [TLBooleanConfigIdentifier defineWithName:SHOW_ONBOARDING_EXTERNAL_CALL defaultValue:YES];
        showOnboardingProfileConfig = [TLBooleanConfigIdentifier defineWithName:SHOW_ONBOARDING_PROFILE defaultValue:YES];
        showOnboardingSpaceConfig = [TLBooleanConfigIdentifier defineWithName:SHOW_ONBOARDING_SPACE defaultValue:YES];
        showOnboardingTransferConfig = [TLBooleanConfigIdentifier defineWithName:SHOW_ONBOARDING_TRANSFER defaultValue:YES];
        showOnboardingEnterMiniCodeConfig = [TLBooleanConfigIdentifier defineWithName:SHOW_ONBOARDING_ENTER_MINI_CODE defaultValue:YES];
        showOnboardingMiniCodeConfig = [TLBooleanConfigIdentifier defineWithName:SHOW_ONBOARDING_MINI_CODE defaultValue:YES];
        showOnboardingRemoteCamera = [TLBooleanConfigIdentifier defineWithName:SHOW_ONBOARDING_REMOTE_CAMERA defaultValue:YES];
        showOnboardingRemoteCameraSettings = [TLBooleanConfigIdentifier defineWithName:SHOW_ONBOARDING_REMOTE_CAMERA_SETTINGS defaultValue:YES];
        showOnboardingTransferCall = [TLBooleanConfigIdentifier defineWithName:SHOW_ONBOARDING_TRANSFER_CALL defaultValue:YES];
        showOnboardingProxy = [TLBooleanConfigIdentifier defineWithName:SHOW_ONBOARDING_PROXY defaultValue:YES];
        showWarningEditMessage = [TLBooleanConfigIdentifier defineWithName:SHOW_WARNING_EDIT_MESSAGE defaultValue:YES];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contentSizeCategoryDidChangeNotification:) name:UIContentSizeCategoryDidChangeNotification object:nil];
    return self;
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIContentSizeCategoryDidChangeNotification object:nil];
}

- (id<TLNotificationCenter>)allocNotificationCenterWithTwinmeContext:(TLTwinmeContext *)twinmeContext {
    DDLogVerbose(@"%@ allocNotificationCenterWithTwinmeContext: %@ not implemented", LOG_TAG, twinmeContext);
    
    [super allocNotificationCenterWithTwinmeContext:twinmeContext];

    self.notificationCenter = [[NotificationCenter alloc] initWithTwinmeApplication:self twinmeContext:twinmeContext];
    return self.notificationCenter;
}

- (BOOL)showWelcomeScreen {
    DDLogVerbose(@"%@ showWelcomeScreen", LOG_TAG);
    
    return showWelcomeConfig.boolValue;
}

- (void)hideWelcomeScreen {
    DDLogVerbose(@"%@ hideWelcomeScreen", LOG_TAG);

    [self setEnableWelcomeScreen:NO];
}

- (BOOL)settingWelcomeScreen {
    DDLogVerbose(@"%@ settingWelcomeScreen", LOG_TAG);

    return showWelcomeConfig.boolValue;
}

- (void)setEnableWelcomeScreen:(BOOL)enable {
    DDLogVerbose(@"%@ setEnableWelcomeScreen: %@", LOG_TAG, enable ? @"YES" : @"NO");
    
    showWelcomeConfig.boolValue = enable;
}

- (void)restoreWelcomeScreen {
    DDLogVerbose(@"%@ restoreWelcomeScreen", LOG_TAG);
    
    [showWelcomeConfig remove];
}

- (BOOL)hasNotificationSoundWithType:(NotificationSoundType)type {
    DDLogVerbose(@"%@ hasNotificationSoundWithType: %u", LOG_TAG, type);
    
    return [self.settings hasNotificationSoundWithType:type];
}

- (void)setNotificationSoundWithType:(NotificationSoundType)type state:(BOOL)state {
    DDLogVerbose(@"%@ setNotificationSoundWithType: %u state: %@", LOG_TAG, type, state ? @"YES" : @"NO");
    
    [self.settings setNotificationSoundWithType:type state:state];
}

- (BOOL)hasVibrationWithType:(NotificationSoundType)type {
    DDLogVerbose(@"%@ hasVibrationWithType: %u", LOG_TAG, type);
    
    return [self.settings hasVibrationWithType:type];
}

- (void)setVibrationWithType:(NotificationSoundType)type state:(BOOL)state {
    DDLogVerbose(@"%@ setVibrationWithType: %u state: %@", LOG_TAG, type, state ? @"YES" : @"NO");
    
    [self.settings setVibrationWithType:type state:state];
}

- (NotificationSound *)getNotificationSoundWithType:(NotificationSoundType)type {
    DDLogVerbose(@"%@ getNotificationSoundWithType: %u", LOG_TAG,type);
    
    NotificationSoundSetting *sound = [self.settings getNotificationSoundWithType:type];
    return [[NotificationSound alloc] initWithSettings:sound];
}

- (void)setNotificationSoundWithType:(NotificationSoundType)type notificationSound:(NotificationSound*)notificationSound {
    
    [self.settings setNotificationSoundWithType:type notificationSound:notificationSound];
}

- (void)setSoundEnableWithState:(BOOL)state {
    
    [self.settings setSoundEnableWithState:state];
}

- (BOOL)hasSoundEnable {
    
    return [self.settings hasSoundEnable];
}

- (void)setDisplayNotificationSenderWithState:(BOOL)state {
    
    [self.settings setDisplayNotificationSenderWithState:state];
}

- (BOOL)hasDisplayNotificationSender {
    
    return [self.settings hasDisplayNotificationSender];
}

- (void)setDisplayNotificationContentWithState:(BOOL)state {
    
    [self.settings setDisplayNotificationContentWithState:state];
}

- (BOOL)hasDisplayNotificationContent {
    
    return [self.settings hasDisplayNotificationContent];
}

- (void)setDisplayNotificationLikeWithState:(BOOL)state {
    
    [self.settings setDisplayNotificationLikeWithState:state];
}

- (BOOL)hasDisplayNotificationLike {
    
    return [self.settings hasDisplayNotificationLike];
}

- (BOOL)allowCopyText {
    
    return allowCopyTextConfig.boolValue;
}

- (void)setAllowCopyTextWithState:(BOOL)state {
    
    allowCopyTextConfig.boolValue = state;
}

- (BOOL)allowCopyFile {
    
    return allowCopyFileConfig.boolValue;
}

- (void)setAllowCopyFileWithState:(BOOL)state {
    
    allowCopyFileConfig.boolValue = state;
}

- (TLSpaceSettings *)defaultSpaceSettings {
    
    TLSpaceSettings *settings = [[TLSpaceSettings alloc] initWithName:TwinmeLocalizedString(@"space_appearance_view_controller_general_title", nil) settings:nil];
    settings.messageCopyAllowed = allowCopyTextConfig.boolValue;
    settings.fileCopyAllowed = allowCopyFileConfig.boolValue;
    return settings;
}

- (CGFloat)getDefaultKeyboardHeight {
    
    return keyboardHeightConfig.floatValue;
}

- (void)setDefaultKeyboardHeight:(CGFloat)keyboardHeight {
    
    if (keyboardHeightConfig.floatValue == keyboardHeight || keyboardHeight == 0) {
        return;
    }
    
    keyboardHeightConfig.floatValue = keyboardHeight;
}

- (DisplayMode)displayMode {
    
    return displayModeConfig.intValue;
}

- (void)setDisplayModeWithMode:(DisplayMode)displayMode {
    
    displayModeConfig.intValue = displayMode;
}

- (BOOL)darkModeEnable {
    
    BOOL darkMode = NO;
    
    switch ([self displayMode]) {
        case DisplayModeSystem:
            if (@available(iOS 13.0, *)) {
                if ([UIScreen mainScreen].traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark){
                    darkMode = YES;
                }
            }
            break;
            
        case DisplayModeDark:
            darkMode = YES;
            break;
        default:
            break;
    }
    
    return darkMode;
}

- (FontSize)fontSize {
    
    return fontSizeConfig.intValue;
}

- (void)setFontSizeWithSize:(FontSize)fontSize {
    
    fontSizeConfig.intValue = fontSize;
}

- (EmojiSize)emojiSize {
    
    return emojiSizeConfig.intValue;
}

- (void)setEmojiSizeWithSize:(EmojiSize)emojiSize {
    
    emojiSizeConfig.intValue = emojiSize;
}

- (BOOL)visualizationLink {
    
    return visualizationLinkConfig.boolValue;
}

- (void)setVisualizationLinkWithState:(BOOL)state {
    
    visualizationLinkConfig.boolValue = state;
}

- (HapticFeedbackMode)hapticFeedbackMode {
    
    return hapticFeedbackModeConfig.intValue;
}

- (void)setHapticFeedbackModeWithMode:(HapticFeedbackMode)hapticFeedbackMode {
    
    hapticFeedbackModeConfig.intValue = hapticFeedbackMode;
}

- (DefaultTab)defaultTab {
    
    return defaultTabConfig.intValue;
}

- (void)setDefaultTabWithTab:(DefaultTab)defaultTab {
    
    defaultTabConfig.intValue = defaultTab;
}

- (SendImageSize)sendImageSize {
    
    return sendImageSizeConfig.intValue;
}

- (void)setSendImageSizeWithSize:(SendImageSize)sendImageSize {
    
    sendImageSizeConfig.intValue = sendImageSize;
}

- (SendVideoSize)sendVideoSize {
    
    return sendVideoSizeConfig.intValue;
}

- (void)setSendVideoSizeWithSize:(SendVideoSize)sendVideoSize {
    
    sendVideoSizeConfig.intValue = sendVideoSize;
}

- (TLDisplayCallsMode)displayCallsMode {
    
    return displayCallsModeConfig.intValue;
}

- (void)setDisplayCallsModeWithMode:(TLDisplayCallsMode)displayCallsMode {
    
    displayCallsModeConfig.intValue = displayCallsMode;
}

- (TLProfileUpdateMode)profileUpdateMode {
    
    return profileUpdateModeConfig.intValue;
}

- (void)setProfileUpdateModeWithMode:(TLProfileUpdateMode)profileUpdateMode {
    
    profileUpdateModeConfig.intValue = profileUpdateMode;
}

//
// Call
//

- (BOOL)inCall {

    CallService *callService = self.callService;
    if (!callService) {
        ApplicationDelegate *delegate = (ApplicationDelegate *)[[UIApplication sharedApplication] delegate];
        callService = delegate.callService;
        self.callService = callService;
    }

    CallState *call = [callService currentCall];
    CallStatus callStatus = call ? [call status] : CallStatusTerminated;

    DDLogVerbose(@"%@ inCall: %d", LOG_TAG, callStatus);
    return callStatus != CallStatusTerminated;
}

- (BOOL)isVideoInFitMode {
    DDLogVerbose(@"%@ isVideoInFitMode", LOG_TAG);

    return videoCallInFitModeConfig.boolValue;
}

- (void)setIsVideoInFitMode:(BOOL)state {
    
    videoCallInFitModeConfig.boolValue = state;
}

- (BOOL)askCallQualityWithCallDuration:(int)duration {
    DDLogVerbose(@"%@ askCallQualityWithCallDuration: %d", LOG_TAG, duration);
    
    if (duration > CALL_QUALITY_MIN_DURATION) {
        int callCount = callQualityCountConfig.intValue + 1;
        int64_t lastDate = callQualityLastDateConfig.int64Value;
        BOOL askCallQuality = NO;
        
        if (lastDate == 0) {
            askCallQuality = YES;
        } else {
            NSDate *callQualityDate = [[NSDate dateWithTimeIntervalSince1970:lastDate] dateByAddingTimeInterval:CALL_QUALITY_INTERVAL_DATE];
            
            if ([callQualityDate compare:[NSDate date]] == NSOrderedAscending || callCount >= CALL_QUALITY_ASK_FREQUENCY) {
                askCallQuality = YES;
            }
        }
        
        if (askCallQuality) {
            callCount = 0;
            callQualityLastDateConfig.int64Value = [[NSDate date] timeIntervalSince1970];
        }
        
        callQualityCountConfig.intValue = callCount;
        
        return askCallQuality;
    }
    
    return NO;
}

//
// Access twinme management
//

- (BOOL)showConnectedMessage {
    
    return _showConnectedMessage;
}

- (void)setShowConnectedMessage:(BOOL)enable {
    DDLogVerbose(@"%@ setShowConnectedMessage: %@", LOG_TAG, enable ? @"YES" : @"NO");
    
    _showConnectedMessage = enable;
}

- (BOOL)canShowUpgradeScreenAtStart {
    
    return canShowUpgradeScreenConfig.boolValue;
}

- (void)setCanShowUpgradeScreenWithState:(BOOL)state {
    DDLogVerbose(@"%@ setCanShowUpgradeScreenWithState: %@", LOG_TAG, state ? @"YES" : @"NO");
    
    canShowUpgradeScreenConfig.boolValue = state;
}

- (void)setFirstInstallation {
    DDLogVerbose(@"%@ setFirstInstallation", LOG_TAG);
    
    if (firstInstallationConfig.int64Value == 0) {
        NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970];
        firstInstallationConfig.int64Value = timeInterval;
    }
}

- (BOOL)showUpgradeScreen {
    
    if (!canShowUpgradeScreenConfig.boolValue || [self inCall]) {
        return NO;
    }
    
    int64_t oneDay = 60 * 60 * 24;
    int64_t threeDay = 3 * oneDay;
    int64_t oneWeek = 7 * oneDay;
    int64_t twoWeek = 2 * oneWeek;
    
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970];
    
    if (firstInstallationConfig.int64Value > 0 && firstShowUpgradeScreenConfig.intValue == 0) {
        int64_t diffTimeSinceFirstInstallation = timeInterval -firstInstallationConfig.int64Value;
        if (diffTimeSinceFirstInstallation < twoWeek) {
            return NO;
        }
    }
        
    if (firstShowUpgradeScreenConfig.intValue == 0) {
        firstShowUpgradeScreenConfig.intValue = timeInterval;
        lastShowUpgradeScreenConfig.intValue = timeInterval;
        return YES;
    }
    
    long diffTimeSinceFirstShow = timeInterval - firstShowUpgradeScreenConfig.intValue;
    long diffTimeSinceLastShow = timeInterval - lastShowUpgradeScreenConfig.intValue;
    
    BOOL showScreen = NO;
        
    if (diffTimeSinceFirstShow < oneWeek && diffTimeSinceLastShow > threeDay) {
        showScreen = YES;
    } else if (diffTimeSinceLastShow > twoWeek) {
        showScreen = YES;
    }

    if (showScreen) {
        lastShowUpgradeScreenConfig.intValue = timeInterval;
    }
    
    return showScreen;
}

- (BOOL)startWarningEditMessage {
    
    return showWarningEditMessage.boolValue;
}

- (void)setShowWarningEditMessageWithState:(BOOL)state {
    
    showWarningEditMessage.boolValue = state;
}

- (BOOL)startOnboarding:(OnboardingType)onboardingType {
        
    switch (onboardingType) {
        case OnboardingTypeCertifiedRelation:
            return showOnboardingCertifiedRelationConfig.boolValue;
            
        case OnboardingTypeExternalCall:
            return showOnboardingExternalCallConfig.boolValue;
            
        case OnboardingTypeProfile:
            return showOnboardingProfileConfig.boolValue;
            
        case OnboardingTypeSpace:
            return showOnboardingSpaceConfig.boolValue;
            
        case OnboardingTypeTransfer:
            return showOnboardingTransferConfig.boolValue;
            
        case OnboardingTypeEnterMiniCode:
            return showOnboardingEnterMiniCodeConfig.boolValue;
            
        case OnboardingTypeMiniCode:
            return showOnboardingMiniCodeConfig.boolValue;
            
        case OnboardingTypeRemoteCamera:
            return showOnboardingRemoteCamera.boolValue;
            
        case OnboardingTypeRemoteCameraSettings:
            return showOnboardingRemoteCameraSettings.boolValue;
            
        case OnboardingTypeTransferCall:
            return showOnboardingTransferCall.boolValue;
            
        case OnboardingTypeProxy:
            return showOnboardingProxy.boolValue;
            
        default:
            return NO;
    }
}

- (void)setShowOnboardingType:(OnboardingType)onboardingType state:(BOOL)state {
    
    switch (onboardingType) {
        case OnboardingTypeCertifiedRelation:
            showOnboardingCertifiedRelationConfig.boolValue = state;
            break;
            
        case OnboardingTypeExternalCall:
            showOnboardingExternalCallConfig.boolValue = state;
            break;
            
        case OnboardingTypeProfile:
            showOnboardingProfileConfig.boolValue = state;
            break;
            
        case OnboardingTypeSpace:
            showOnboardingSpaceConfig.boolValue = state;
            break;
            
        case OnboardingTypeTransfer:
            showOnboardingTransferConfig.boolValue = state;
            break;
            
        case OnboardingTypeEnterMiniCode:
            showOnboardingEnterMiniCodeConfig.boolValue = state;
            break;
            
        case OnboardingTypeMiniCode:
            showOnboardingMiniCodeConfig.boolValue = state;
            break;
            
        case OnboardingTypeRemoteCamera:
            showOnboardingRemoteCamera.boolValue = state;
            break;
            
        case OnboardingTypeRemoteCameraSettings:
            showOnboardingRemoteCameraSettings.boolValue = state;
            break;
            
        case OnboardingTypeTransferCall:
            showOnboardingTransferCall.boolValue = state;
            break;
            
        case OnboardingTypeProxy:
            showOnboardingProxy.boolValue = state;
            break;
            
        default:
            break;
    }
}

- (void)resetOnboarding {
    
    showOnboardingCertifiedRelationConfig.boolValue = YES;
    showOnboardingExternalCallConfig.boolValue = YES;
    showOnboardingProfileConfig.boolValue = YES;
    showOnboardingSpaceConfig.boolValue = YES;
    showOnboardingTransferConfig.boolValue = YES;
    showOnboardingEnterMiniCodeConfig.boolValue = YES;
    showOnboardingMiniCodeConfig.boolValue = YES;
    showOnboardingRemoteCamera.boolValue = YES;
    showOnboardingRemoteCameraSettings.boolValue = YES;
    showOnboardingTransferCall.boolValue = YES;
    showOnboardingProxy.boolValue = YES;
}

//
//  Update
//

- (BOOL)showWhatsNew {

    int64_t oneDay = 60 * 60 * 24;
    int64_t period = 20 * oneDay;
    
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970];
    if (firstInstallationConfig.int64Value > 0) {
        int64_t diffTimeSinceFirstInstallation = timeInterval - firstInstallationConfig.int64Value;
        if (diffTimeSinceFirstInstallation < period) {
            return NO;
        }
    }
    
    return ![self inCall] && [self.lastVersionManager isVersionUpdated];
}

//
// Enable Notification
//

- (BOOL)showEnableNotificationScreen {

    int64_t oneDay = 60 * 60 * 24;
    
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970];
    
    long diffTimeSinceLastShow = timeInterval - lastShowEnableNotificationScreenConfig.int64Value;
    
    BOOL showScreen = diffTimeSinceLastShow > oneDay;
    if (showScreen) {
        lastShowEnableNotificationScreenConfig.int64Value = timeInterval;
    }
    
    return showScreen;
}

//
//  CoachMark
//

- (BOOL)showCoachMark {
    
    return [self.coachMarkManager showCoachMark];
}

- (void)setShowCoachMark:(BOOL)showCoachMark {
    
    [self.coachMarkManager setShowCoachMark:showCoachMark];
}

- (BOOL)showCoachMark:(CoachMarkTag)coachMarkTag {
    
    return [self.coachMarkManager showCoachMark:coachMarkTag];
}

- (void)hideCoachMark:(CoachMarkTag)coachMarkTag {
    
    [self.coachMarkManager hideCoachMark:coachMarkTag];
}

- (void)hideAllCoachMark {
    
    [self.coachMarkManager hideAllCoachMark];
}

//
// Group call animation
//

- (BOOL)showGroupCallAnimation {
    
    return showGroupCallAnimationConfig.boolValue;
}

- (void)hideGroupCallAnimation {

    showGroupCallAnimationConfig.boolValue = NO;
}

#pragma mark - Private methods

- (void)onErrorWithErrorCode:(TLBaseServiceErrorCode)errorCode message:(NSString *)message {
    DDLogVerbose(@"%@ onErrorWithErrorCode: %d message: %@", LOG_TAG, errorCode, message);
}

- (void)contentSizeCategoryDidChangeNotification:(NSNotification *)notification {
    DDLogVerbose(@"%@ contentSizeCategoryDidChangeNotification: %@", LOG_TAG, notification);
    
    [Design setupFont];
}

@end
