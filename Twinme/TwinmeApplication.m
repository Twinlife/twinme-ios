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
#import "SpaceSetting.h"
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
#define VISUALIZATION_MAP @"VisualizationMap"
#define DISPLAY_MODE @"DefaultDisplayMode"
#define HAPTIC_FEEDBACK_MODE @"DefaultHapticFeedbackMode"
#define FIRST_SHOW_UPGRADE_SCREEN @"FirstShowUpgradeScreen"
#define LAST_SHOW_UPGRADE_SCREEN @"LastShowUpgradeScreen"
#define HAPTIC_FEEDBACK_ENABLE @"DefaultHapticFeedbackEnable"
#define SOUND_EFFECTS_ENABLE @"SoundEffectsEnable"
#define CAN_SHOW_UPGRADE_SCREEN @"CanShowUpgradeScreen"
#define SCREEN_LOCK @"ScreenLock"
#define TIMEOUT_SCREEN_LOCK @"TimeoutScreenLock"
#define HIDE_LAST_SCREEN @"HideLastScreen"
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
#define SHOW_ONBOARDING_BACKUP @"ShowOnboardingBackup"
#define SHOW_ONBOARDING_RESTORE @"ShowOnboardingRestore"
#define SHOW_ONBOARDING_VERIFY_BACKUP @"ShowOnboardingVerifyBackup"
#define SHOW_ONBOARDING_BACKUP_BETA @"ShowOnboardingBackupBeta"
#define SHOW_ONBOARDING_SHARE_CONTACT @"ShowOnboardingShareContact"
#define SHOW_WARNING_EDIT_MESSAGE @"ShowWarningEditMessage"
#define SHOW_WARNING_LOCATION_BACKGROUND @"ShowWarningLocationBackground"
#define SHOW_WARNING_LOCATION_FINE @"ShowWarningLocationFine"
#define DEFAULT_TAB @"DefaultTab"
#define ALLOW_EPHEMERAL_MESSAGE @"AllowEphemeralMessage"
#define TIMEOUT_EPHEMERAL_MESSAGE @"TimeoutEphemeralMessage"
#define HIDE_RECENT_CALLS @"HideRecentCalls"
#define IS_VIDEO_IN_FIT_MODE @"IsVideoInFitMode"
#define CALL_QUALITY_COUNT @"CallQualityCount"
#define CALL_QUALITY_LAST_DATE @"CallQualityLastDate"
#define LAST_UPDATED_VERSION @"LastUpdatedVersion"
#define QUALITY_MEDIA @"QualityMedia"
#define DISPLAY_CALLS_MODE @"DisplayCallsMode"
#define PROFILE_UPDATE_MODE @"ProfileUpdateMode"
#define SHOW_GROUP_CALL_ANIMATION @"DefaultShowGroupCallAnimation"
#define SHOW_SPACE_ONBOARDING @"ShowSpaceOnboarding"
#define INVITATION_SUBSCRIPTION_IMAGE @"InvitationSubscriptionImage"
#define INVITATION_SUBSCRIPTION_TWINCODE @"InvitationSubscriptionTwincode"
#define SHOW_CLICK_TO_CALL_DESCRIPTION_COUNT @"ShowClickToCallDescriptionCount"
#define AUDIO_ITEM_RATE @"AudioItemRate"
#define LAST_BACKUP @"LastBackup"
#define FIRST_INSTALLATION_WITH_BACKUP @"FirstInstallationWithBackup"
#define LAST_ALERT_BACKUP @"LastAlertBackup"
#define ICE_TRANSPORT_MODE @"IceTransportMode"
#define SHARE_INVITATION_MODE @"ShareInvitationMode"

#define DEFAULT_COLOR @"#00AEFF"

#define AUDIO_PLAYER_RATE_SLOW 0.5f
#define AUDIO_PLAYER_RATE_NORMAL 1.0f
#define AUDIO_PLAYER_RATE_FAST   1.5f
#define AUDIO_PLAYER_RATE_VERY_FAST 2.0f

static const int64_t CALL_QUALITY_MIN_DURATION = 5 * 60;
static const int64_t CALL_QUALITY_ASK_FREQUENCY = 10;
static const int64_t CALL_QUALITY_INTERVAL_DATE = 10 * 60 * 60 * 24;

static const int64_t SHOW_CLICK_TO_CALL_DESCRIPTION_MAX = 5;

static TLBooleanConfigIdentifier *showWelcomeConfig;

// Display settings.
static TLBooleanConfigIdentifier *visualizationLinkConfig;
static TLBooleanConfigIdentifier *visualizationMapConfig;
static TLIntegerConfigIdentifier *hapticFeedbackModeConfig;
static TLBooleanConfigIdentifier *hapticFeedbackEnableConfig;
static TLBooleanConfigIdentifier *soundEffectsEnableConfig;
static TLIntegerConfigIdentifier *defaultTabConfig;
static TLIntegerConfigIdentifier *displayModeConfig;
static TLIntegerConfigIdentifier *displayCallsModeConfig;
static TLIntegerConfigIdentifier *emojiSizeConfig;
static TLIntegerConfigIdentifier *fontSizeConfig;
static TLBooleanConfigIdentifier *showGroupCallAnimationConfig;

// Message settings
static TLIntegerConfigIdentifier *qualityMediaConfig;

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
static TLBooleanConfigIdentifier *showOnboardingShareContact;
static TLBooleanConfigIdentifier *showOnboardingTransferCall;
static TLBooleanConfigIdentifier *showOnboardingProxy;
static TLBooleanConfigIdentifier *showOnboardingBackup;
static TLBooleanConfigIdentifier *showOnboardingRestore;
static TLBooleanConfigIdentifier *showOnboardingVerifyBackup;
static TLBooleanConfigIdentifier *showOnboardingBackupBeta;
static TLBooleanConfigIdentifier *showWarningEditMessage;
static TLBooleanConfigIdentifier *showWarningLocationBackground;
static TLBooleanConfigIdentifier *showWarningLocationFine;
static TLFloatConfigIdentifier *keyboardHeightConfig;
static TLFloatConfigIdentifier *audioItemRateConfig;

// Skred and Twinme+ settings
static TLBooleanSharedConfigIdentifier *screenLockConfig;
static TLIntegerConfigIdentifier *timeoutScreenLockConfig;
static TLBooleanConfigIdentifier *hideLastScreenConfig;
static TLBooleanConfigIdentifier *allowEphemeralMessageConfig;
static TLIntegerConfigIdentifier *timeoutEphemeralMessageConfig;
static TLBooleanConfigIdentifier *hideRecentCallsConfig;
static TLBooleanConfigIdentifier *spaceOnboardingConfig;
static TLIntegerConfigIdentifier *showClickToCallDescriptionCountConfig;

// Skred specific
static TLUUIDConfigIdentifier *invitationSubscriptionTwincodeConfig;
static TLStringConfigIdentifier *invitationSubscriptionImageConfig;

// Backup
static TLIntegerConfigIdentifier *lastBackupConfig;
static TLIntegerConfigIdentifier *firstInstallationWithBackupConfig;
static TLIntegerConfigIdentifier *lastBackupAlertConfig;

// Security Level
static TLEnumSharedConfigIdentifier *iceTransportModeConfig;

// Share Invitation
static TLEnumSharedConfigIdentifier *shareInvitationModeConfig;

//
// Interface: TwinmeApplication ()
//

@interface TwinmeApplication ()

@property (nonatomic, nullable) CallService *callService;
@property BOOL showConnectedMessage;
@property NSDate *resignActiveDate;

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
        
        visualizationMapConfig = [TLBooleanConfigIdentifier defineWithName:VISUALIZATION_MAP uuid:@"C7CE54E3-D789-435B-B0F9-C20048C1873D" defaultValue:YES];
        
        hapticFeedbackModeConfig = [TLIntegerConfigIdentifier defineWithName:HAPTIC_FEEDBACK_MODE uuid:@"E9819421-CD71-4C3D-AB6A-0783F0FF4532" defaultValue:HapticFeedbackModeSystem];
        
        hapticFeedbackEnableConfig = [TLBooleanConfigIdentifier defineWithName:HAPTIC_FEEDBACK_ENABLE uuid:@"A33B5A34-1C22-4FFA-B1DB-DFB8E2338DD6" defaultValue:[self hapticFeedbackMode] != HapticFeedbackModeOff];
        
        soundEffectsEnableConfig = [TLBooleanConfigIdentifier defineWithName:SOUND_EFFECTS_ENABLE uuid:@"94DAC351-DE6C-4219-B35E-BA409078089B" defaultValue:YES];

        defaultTabConfig = [TLIntegerConfigIdentifier defineWithName:DEFAULT_TAB uuid:@"AD11179C-1510-4F1A-A4C2-0F29DC989997" defaultValue:DefaultTabConversations];

        qualityMediaConfig = [TLIntegerConfigIdentifier defineWithName:QUALITY_MEDIA uuid:@"85F98FDE-5C4E-11ED-9B6A-0242AC120002" defaultValue:QualityMediaOrginal];

        displayCallsModeConfig = [TLIntegerConfigIdentifier defineWithName:DISPLAY_CALLS_MODE uuid:@"FA50C4AC-C196-4F3F-BD68-3DE18D27F44E" defaultValue:TLDisplayCallsModeMissed];

        profileUpdateModeConfig = [TLIntegerConfigIdentifier defineWithName:PROFILE_UPDATE_MODE uuid:@"959957DA-B8EE-4506-8A5E-A5006023E13D" defaultValue:TLProfileUpdateModeDefault];

        videoCallInFitModeConfig = [TLBooleanConfigIdentifier defineWithName:IS_VIDEO_IN_FIT_MODE uuid:@"D36D6D8A-2DFF-11ED-A261-0242AC120002" defaultValue:NO];
        callQualityCountConfig = [TLIntegerConfigIdentifier defineWithName:CALL_QUALITY_COUNT uuid:@"DDD83ED6-3335-11ED-A261-0242AC120002" defaultValue:0];
        callQualityLastDateConfig = [TLIntegerConfigIdentifier defineWithName:CALL_QUALITY_LAST_DATE uuid:@"B57863E8-3336-11ED-A261-0242AC120002" defaultValue:0];
        
        lastBackupConfig = [TLIntegerConfigIdentifier defineWithName:LAST_BACKUP uuid:@"E55ECCE5-A709-4C5d-9D7D-09CDDEA8f8C5" defaultValue:0];
        lastBackupAlertConfig = [TLIntegerConfigIdentifier defineWithName:LAST_ALERT_BACKUP uuid:@"58D0333B-3972-4037-80AF-71775A12116F" defaultValue:0];
        firstInstallationWithBackupConfig = [TLIntegerConfigIdentifier defineWithName:FIRST_INSTALLATION_WITH_BACKUP defaultValue:0];
        [self setFirstInstallationWithBackup];
        
        showGroupCallAnimationConfig = [TLBooleanConfigIdentifier defineWithName:SHOW_GROUP_CALL_ANIMATION uuid:@"BB834EE6-3927-42E1-BC46-5663B2AB47DB" defaultValue:YES];
        
        iceTransportModeConfig = [TLEnumSharedConfigIdentifier defineWithName:ICE_TRANSPORT_MODE uuid:@"4B83AA59-303A-4585-9A5E-DF55CE5CC7F5" defaultValue:TLPeerConnectionServiceIceTransportModeAll];
        
        shareInvitationModeConfig = [TLEnumSharedConfigIdentifier defineWithName:SHARE_INVITATION_MODE uuid:@"84214DEC-3392-4880-BC3A-7F8203C2BD2E" defaultValue:ShareInvitationModeAsk];
        
        // Configurations not migrated between devices.
        firstInstallationConfig = [TLIntegerConfigIdentifier defineWithName:FIRST_INSTALLATION defaultValue:0];
        keyboardHeightConfig = [TLFloatConfigIdentifier defineWithName:DEFAULT_KEYBOARD_HEIGHT defaultValue:0];
        audioItemRateConfig = [TLFloatConfigIdentifier defineWithName:AUDIO_ITEM_RATE defaultValue:AUDIO_PLAYER_RATE_NORMAL];

        firstShowUpgradeScreenConfig = [TLIntegerConfigIdentifier defineWithName:FIRST_SHOW_UPGRADE_SCREEN defaultValue:0];
        
        lastShowUpgradeScreenConfig = [TLIntegerConfigIdentifier defineWithName:LAST_SHOW_UPGRADE_SCREEN defaultValue:0];
        
        // Skred and twinme+
        spaceOnboardingConfig = [TLBooleanConfigIdentifier defineWithName:SHOW_SPACE_ONBOARDING defaultValue:YES];

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
        showOnboardingBackup = [TLBooleanConfigIdentifier defineWithName:SHOW_ONBOARDING_BACKUP defaultValue:YES];
        showOnboardingRestore = [TLBooleanConfigIdentifier defineWithName:SHOW_ONBOARDING_RESTORE defaultValue:YES];
        showOnboardingVerifyBackup = [TLBooleanConfigIdentifier defineWithName:SHOW_ONBOARDING_VERIFY_BACKUP defaultValue:YES];
        showOnboardingBackupBeta = [TLBooleanConfigIdentifier defineWithName:SHOW_ONBOARDING_BACKUP_BETA defaultValue:YES];
        showOnboardingShareContact = [TLBooleanConfigIdentifier defineWithName:SHOW_ONBOARDING_SHARE_CONTACT defaultValue:YES];
        showWarningEditMessage = [TLBooleanConfigIdentifier defineWithName:SHOW_WARNING_EDIT_MESSAGE defaultValue:YES];
        
        //Skred
        showWarningLocationBackground = [TLBooleanConfigIdentifier defineWithName:SHOW_WARNING_LOCATION_BACKGROUND defaultValue:YES];
        showWarningLocationFine = [TLBooleanConfigIdentifier defineWithName:SHOW_WARNING_LOCATION_FINE defaultValue:YES];
       
        // Twinme+ and Skred
        TLBooleanConfigIdentifier *oldConfig = [TLBooleanConfigIdentifier defineWithName:SCREEN_LOCK uuid:@"D3372EA5-1CB2-4365-92E5-5780B1F982FD" defaultValue:NO];
        screenLockConfig = [TLBooleanSharedConfigIdentifier defineWithName:SCREEN_LOCK uuid:@"D3372EA5-1CB2-4365-92E5-5780B1F982FD" defaultValue:NO];
        if (oldConfig.boolValue) {
            screenLockConfig.boolValue = oldConfig.boolValue;
            [oldConfig remove];
        }
        
        timeoutScreenLockConfig = [TLIntegerConfigIdentifier defineWithName:TIMEOUT_SCREEN_LOCK uuid:@"24223BA2-822B-4867-B826-AE5430D88A4A" defaultValue:0];
        hideLastScreenConfig = [TLBooleanConfigIdentifier defineWithName:HIDE_LAST_SCREEN uuid:@"579627C5-87B5-403B-A58D-61977DFDD53A" defaultValue:NO];
        allowEphemeralMessageConfig = [TLBooleanConfigIdentifier defineWithName:ALLOW_EPHEMERAL_MESSAGE uuid:@"7837F336-8422-11EC-A8A3-0242AC120002" defaultValue:NO];
        timeoutEphemeralMessageConfig = [TLIntegerConfigIdentifier defineWithName:TIMEOUT_EPHEMERAL_MESSAGE uuid:@"585BA89F-86F3-48e0-A07C-C924C50f7C6D" defaultValue:DEFAULT_TIMEOUT_MESSAGE];
        hideRecentCallsConfig = [TLBooleanConfigIdentifier defineWithName:HIDE_RECENT_CALLS uuid:@"D983A4D5-E6E6-43D6-ACD4-1754A4E5AA91" defaultValue:NO];

        showClickToCallDescriptionCountConfig = [TLIntegerConfigIdentifier defineWithName:SHOW_CLICK_TO_CALL_DESCRIPTION_COUNT uuid:@"70D0949E-A10f-4156-8D87-EFF914C65962" defaultValue:0];

        // Skred specific
        invitationSubscriptionTwincodeConfig = [TLUUIDConfigIdentifier defineWithName:INVITATION_SUBSCRIPTION_TWINCODE uuid:@"22CA1D8D-FE44-4D94-B352-3977935FD44B"];
        invitationSubscriptionImageConfig = [TLStringConfigIdentifier defineWithName:INVITATION_SUBSCRIPTION_IMAGE uuid:@"3FAA6089-253C-4541-A9C7-3EA7D245F926"];
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
    
    TLSpaceSettings *settings = [[TLSpaceSettings alloc] initWithName:TwinmeLocalizedString(@"space_appearance_view_general_title", nil) settings:nil];
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

//
// Security Level
//

- (TLPeerConnectionServiceIceTransportMode)iceTransportMode {
    
    return iceTransportModeConfig.enumValue;
}

- (void)setIceTransportModeWithMode:(TLPeerConnectionServiceIceTransportMode)iceTransportMode {
    
    iceTransportModeConfig.enumValue = iceTransportMode;
}

//
// Share Invitation Mode
//

- (ShareInvitationMode)shareInvitationMode {
    
    return shareInvitationModeConfig.enumValue;
}

- (void)setShareInvitationModeWithMode:(ShareInvitationMode)shareInvitationMode {
    
    shareInvitationModeConfig.enumValue = shareInvitationMode;
}

//
// Audio Player
//

- (CGFloat)getAudioPlayerRate {
    
    return audioItemRateConfig.floatValue;
}

- (void)updateAudioPlayerRate {
    
    if (audioItemRateConfig.floatValue == AUDIO_PLAYER_RATE_NORMAL) {
        audioItemRateConfig.floatValue = AUDIO_PLAYER_RATE_FAST;
    } else if (audioItemRateConfig.floatValue == AUDIO_PLAYER_RATE_FAST) {
        audioItemRateConfig.floatValue = AUDIO_PLAYER_RATE_VERY_FAST;
    } else if (audioItemRateConfig.floatValue == AUDIO_PLAYER_RATE_VERY_FAST) {
        audioItemRateConfig.floatValue = AUDIO_PLAYER_RATE_SLOW;
    } else {
        audioItemRateConfig.floatValue = AUDIO_PLAYER_RATE_NORMAL;
    }
}

- (DisplayMode)displayMode {
    
    return displayModeConfig.intValue;
}

- (void)setDisplayModeWithMode:(DisplayMode)displayMode {
    
    displayModeConfig.intValue = displayMode;
}

- (BOOL)darkModeEnable:(TLSpaceSettings *)spaceSettings {
    
    DisplayMode displayMode = [[spaceSettings getStringWithName:PROPERTY_DISPLAY_MODE defaultValue:[NSString stringWithFormat:@"%d", DisplayModeSystem]]intValue];
    
    BOOL darkMode = NO;
    switch (displayMode) {
         case DisplayModeSystem:
            if ([UIScreen mainScreen].traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark){
                darkMode = YES;
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

- (BOOL)visualizationMap {
    
    return visualizationMapConfig.boolValue;
}

- (void)setVisualizationMapWithState:(BOOL)state {
    
    visualizationMapConfig.boolValue = state;
}

- (HapticFeedbackMode)hapticFeedbackMode {
    
    return hapticFeedbackModeConfig.intValue;
}

- (void)setHapticFeedbackModeWithMode:(HapticFeedbackMode)hapticFeedbackMode {
    
    hapticFeedbackModeConfig.intValue = hapticFeedbackMode;
}

- (BOOL)allowHapticFeedback {
    
    return hapticFeedbackEnableConfig.boolValue;
}

- (void)setHapticFeedbackEnableWithState:(BOOL)state {
    
    hapticFeedbackEnableConfig.boolValue = state;
}

- (BOOL)allowSoundEffects {
    
    return soundEffectsEnableConfig.boolValue;
}

- (void)setSoundEffectsEnableWithState:(BOOL)state {
    
    soundEffectsEnableConfig.boolValue = state;
}

- (DefaultTab)defaultTab {
    
    return defaultTabConfig.intValue;
}

- (void)setDefaultTabWithTab:(DefaultTab)defaultTab {
    
    defaultTabConfig.intValue = defaultTab;
}

- (QualityMedia)qualityMedia {
    
    return qualityMediaConfig.intValue;
}

- (void)setQualityMediaWithQuality:(QualityMedia)qualityMedia {
    
    qualityMediaConfig.intValue = qualityMedia;
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
// Backup
//

- (BOOL)showBackupWarning {
    DDLogVerbose(@"%@ showBackupWarning", LOG_TAG);

    int64_t oneDay = 60 * 60 * 24;
    int64_t oneMonth = 30 * oneDay;
    
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970];
    int64_t diffTimeSinceLastBackup = timeInterval - lastBackupConfig.int64Value;
    int64_t diffTimeFirstInstallationBackup = timeInterval - firstInstallationWithBackupConfig.int64Value;
    
    if ((diffTimeSinceLastBackup > oneMonth && lastBackupConfig.int64Value != 0) || (diffTimeFirstInstallationBackup > oneMonth)) {
                     
        if (lastBackupAlertConfig.int64Value == 0) {
            return YES;
        }
        
        int64_t diffTimeSinceLastBackupBackupAlert = timeInterval - lastBackupAlertConfig.int64Value;
        if (diffTimeSinceLastBackupBackupAlert > oneMonth) {
            return YES;
        }
    }
        
    return NO;
}

- (void)setLastAlertBackup {
    DDLogVerbose(@"%@ setLastAlertBackup", LOG_TAG);
    
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970];
    lastBackupAlertConfig.int64Value = timeInterval;
}

- (void)setLastBackupDate {
    DDLogVerbose(@"%@ setLastBackupDate", LOG_TAG);
    
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970];
    lastBackupConfig.int64Value = timeInterval;
}

- (void)setFirstInstallationWithBackup {
    DDLogVerbose(@"%@ setFirstInstallationWithBackup", LOG_TAG);
    
    if (firstInstallationWithBackupConfig.int64Value == 0) {
        NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970];
        firstInstallationWithBackupConfig.int64Value = timeInterval;
    }
}

- (void)clearLastBackupDate {
    DDLogVerbose(@"%@ clearLastBackupDate", LOG_TAG);
    
    lastBackupConfig.int64Value = 0;
}

- (int64_t)lastBackupDate {
    DDLogVerbose(@"%@ lastBackupDate", LOG_TAG);
    
    return lastBackupConfig.int64Value;
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

//
// Skred plus upgrade
//

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
    
    if ([self isSubscribedWithFeature:TLTwinmeApplicationFeatureGroupCall] || [self inCall] || !canShowUpgradeScreenConfig.boolValue) {
        return NO;
    }

    int64_t oneDay = 60 * 60 * 24;
    int64_t threeDay = 3 * oneDay;
    int64_t oneWeek = 7 * oneDay;
    int64_t twoWeek = 14 * oneDay;
    
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

//
// Privacy
//

- (BOOL)isScreenLock {
    DDLogVerbose(@"%@ isScreenLock", LOG_TAG);

    return screenLockConfig.boolValue;
}

- (void)setScreenLockWithState:(BOOL)state {
    
    screenLockConfig.boolValue = state;
}

- (int)getTimeoutScreenLock {
    
    return timeoutScreenLockConfig.intValue;
}

- (void)setTimeoutScreenLockWithTime:(int)time {
    
    timeoutScreenLockConfig.intValue = time;
}

- (BOOL)isLastScreenHidden {
    DDLogVerbose(@"%@ isLastScreenHidden", LOG_TAG);

    return hideLastScreenConfig.boolValue;
}

- (void)setHideLastScreenWithState:(BOOL)state {
    
    hideLastScreenConfig.boolValue = state;
}

- (void)setResignActiveDateWithDate:(NSDate *)date {
    
    self.resignActiveDate = date;
}

- (BOOL)showLockScreen {
    
    if (!screenLockConfig.boolValue) {
        return NO;
    }
    
    if (!self.resignActiveDate) {
        return YES;
    }
    
    NSDate *lockDate = [self.resignActiveDate dateByAddingTimeInterval:timeoutScreenLockConfig.intValue];
    
    if ([lockDate compare:[NSDate date]] == NSOrderedAscending) {
        return YES;
    }
    
    return NO;
}

//
// Ephemeral message
//

- (BOOL)allowEphemeralMessage {
    
    return allowEphemeralMessageConfig.boolValue;
}

- (void)setAllowEphemeralMessageWithState:(BOOL)state {
    
    allowEphemeralMessageConfig.boolValue = state;
}

- (int)getTimeoutEphemeralMessage {

    return timeoutEphemeralMessageConfig.intValue;
}

- (void)setTimeoutEphemeralMessageWithTime:(int)time {
    
    timeoutEphemeralMessageConfig.intValue = time;
}

- (BOOL)isRecentCallsHidden {
    DDLogVerbose(@"%@ isRecentCallsHidden", LOG_TAG);

    return hideRecentCallsConfig.boolValue;
}

- (void)setHideRecentCallsWithState:(BOOL)state {
    
    hideRecentCallsConfig.boolValue = state;
}

- (BOOL)startWarningEditMessage {
    
    return showWarningEditMessage.boolValue;
}

- (void)setShowWarningEditMessageWithState:(BOOL)state {
    
    showWarningEditMessage.boolValue = state;
}

//
// Warning Location Background
//

- (BOOL)startWarningLocationBackground {
    
    return showWarningLocationBackground.boolValue;
}

- (void)setShowWarningLocationBackgroundWithState:(BOOL)state {
    
    showWarningLocationBackground.boolValue = state;
}


//
// Warning Location Fine
//

- (BOOL)startWarningLocationFine {
    
    return showWarningLocationFine.boolValue;
}

- (void)setShowWarningLocationFineWithState:(BOOL)state {
    
    showWarningLocationFine.boolValue = state;
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
            
        case OnboardingTypeBackup:
            return showOnboardingBackup.boolValue;
            
        case OnboardingTypeRestore:
            return showOnboardingRestore.boolValue;
            
        case OnboardingTypeVerifyBackup:
            return showOnboardingVerifyBackup.boolValue;
            
        case OnboardingTypeBackupBeta:
            return showOnboardingBackupBeta.boolValue;
            
        case OnboardingTypeShareContact:
            return showOnboardingShareContact.boolValue;
            
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
            
        case OnboardingTypeBackup:
            showOnboardingBackup.boolValue = state;
            break;
            
        case OnboardingTypeRestore:
            showOnboardingRestore.boolValue = state;
            break;
            
        case OnboardingTypeVerifyBackup:
            showOnboardingVerifyBackup.boolValue = state;
            break;
            
        case OnboardingTypeBackupBeta:
            showOnboardingBackupBeta.boolValue = state;
            break;
            
        case OnboardingTypeShareContact:
            showOnboardingShareContact.boolValue = state;
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
    showOnboardingBackup.boolValue = YES;
    showOnboardingRestore.boolValue = YES;
    showOnboardingVerifyBackup.boolValue = YES;
    showOnboardingBackupBeta.boolValue = YES;
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
// Invitation subscription
//

- (NSString *)getInvitationSubscriptionImage {
    
    return invitationSubscriptionImageConfig.stringValue;
}

- (void)setInvitationSubscriptionImageWithImage:(NSString *)image {
    
    invitationSubscriptionImageConfig.stringValue = image;
}

- (NSUUID *)getInvitationSubscriptionTwincode {
    
    return invitationSubscriptionTwincodeConfig.uuidValue;
}

- (void)setInvitationSubscriptionTwincodeWithTwincode:(NSUUID *)twincode {
    
    invitationSubscriptionTwincodeConfig.uuidValue = twincode;
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

//
// Space onboarding
//

- (BOOL)showSpaceOnboarding {
    
    return spaceOnboardingConfig.boolValue;
}

- (void)hideSpaceOnboarding {
    
    spaceOnboardingConfig.boolValue = NO;
}

//
// Click to call description
//

- (BOOL)showClickToCallDescription {
    
    int value = showClickToCallDescriptionCountConfig.intValue;
    if (value < SHOW_CLICK_TO_CALL_DESCRIPTION_MAX) {
        showClickToCallDescriptionCountConfig.intValue = value + 1;
        return YES;
    }
    
    return NO;
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
