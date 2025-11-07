/*
 *  Copyright (c) 2016-2024 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Chedi Baccari (Chedi.Baccari@twinlife-systems.com)
 *   Christian Jacquemot (Christian.Jacquemot@twinlife-systems.com)
 *   Stephane Carrez (Stephane.Carrez@twin.life)
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 *   Romain Kolb (romain.kolb@skyrock.com)
 */

#import <CocoaLumberjack.h>

#import <Twinlife/TLTwinlife.h>
#import <Twinlife/TLConfigIdentifier.h>
#import <Twinme/TLProfile.h>
#import <Twinme/TLSpaceSettings.h>
#import <AudioToolbox/AudioToolbox.h>
#import <UserNotifications/UserNotifications.h>

#import "NotificationSettings.h"

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

#define SOUND_ENABLE @"DefaultSoundEnable"
#define DISPLAY_NOTIFICATION_SENDER @"DefaultDisplayNotificationSender"
#define DISPLAY_NOTIFICATION_CONTENT @"DefaultDisplayNotificationContent"
#define DISPLAY_NOTIFICATION_LIKE @"DefaultDisplayNotificationLike"
#define CHAT_NOTIFICATION @"DefaultTextNotification"
#define AUDIO_CALL_NOTIFICATION @"DefaultAudioCallNotification"
#define VIDEO_CALL_NOTIFICATION @"DefaultVideoCallNotification"
#define CHAT_NOTIFICATION_SOUND @"DefaultTextNotificationSound"
#define AUDIO_CALL_NOTIFICATION_SOUND @"DefaultAudioCallNotificationSound"
#define VIDEO_CALL_NOTIFICATION_SOUND @"DefaultVideoCallNotificationSound"
#define CHAT_VIBRATION @"DefaultTextVibration"
#define AUDIO_CALL_VIBRATION @"DefaultAudioCallVibration"
#define VIDEO_CALL_VIBRATION @"DefaultVideoCallVibration"
#define NOTIFICATION_BADGE_NUMBER_KEY @"notificationBadgeNumber"

// Use new names for the notification sound since the format is changed.
#define CHAT_NOTIFICATION_SOUND_V2       @"DefaultTextNotificationSoundV2"
#define AUDIO_CALL_NOTIFICATION_SOUND_V2 @"DefaultAudioCallNotificationSoundV2"
#define VIDEO_CALL_NOTIFICATION_SOUND_V2 @"DefaultVideoCallNotificationSoundV2"

#define SOUND_CONFIG_FIELD_SEPARATOR      @"\n"

static TLBooleanSharedConfigIdentifier *soundEnableConfig;
static TLBooleanSharedConfigIdentifier *displayNotificationSenderConfig;
static TLBooleanSharedConfigIdentifier *displayNotificationContentConfig;
static TLBooleanSharedConfigIdentifier *displayNotificationLikeConfig;

// Audio and video call vibration
static TLBooleanSharedConfigIdentifier *audioCallVibrationConfig;
static TLBooleanSharedConfigIdentifier *videoCallVibrationConfig;
static TLBooleanSharedConfigIdentifier *chatVibrationConfig;

// Audio and video call sounds
static TLBooleanSharedConfigIdentifier *audioCallRingConfig;
static TLBooleanSharedConfigIdentifier *videoCallRingConfig;
static TLBooleanSharedConfigIdentifier *chatRingConfig;

static TLStringSharedConfigIdentifier *chatSoundConfig;
static TLStringSharedConfigIdentifier *audioCallSoundConfig;
static TLStringSharedConfigIdentifier *videoCallSoundConfig;

//
// Interface: NotificationSound
//

@interface NotificationSoundSetting ()

@property (readonly, nullable) TLStringSharedConfigIdentifier *config;

- (nonnull instancetype)initWithSettings:(nonnull NotificationSoundSetting *)settings config:(nonnull TLStringSharedConfigIdentifier *)config;

- (nonnull instancetype)initWithType:(NotificationSoundType)soundType name:(nullable NSString *)name soundId:(SystemSoundID)soundId soundPath:(nullable NSString *)soundPath config:(nonnull TLStringSharedConfigIdentifier *)config;

@end

//
// Interface: NotificationSettings ()
//

@interface NotificationSettings ()

@property NotificationSoundSetting *chatNotificationSound;
@property NotificationSoundSetting *audioCallNotificationSound;
@property NotificationSoundSetting *videoCallNotificationSound;
@property NotificationSoundSetting *audioVideoCallingNotificationSound;

/// Migrate the sound settings for the NotificationServiceExtension.
- (void)migrateSoundConfigurationWithName:(nonnull NSString *)name config:(nonnull TLStringSharedConfigIdentifier *)config;

/// Load the configuration sound settings from the configuration.
- (nullable NotificationSoundSetting *)loadNotificationSoundWithConfig:(nonnull TLStringSharedConfigIdentifier *)config soundType:(NotificationSoundType)soundType;

/// Save the notification sound setting in the App shared container.
- (nonnull NotificationSoundSetting *)saveNotificationSoundWithConfig:(nonnull TLStringSharedConfigIdentifier *)config notificationSound:(nonnull NotificationSoundSetting *)notificationSound;

@end

//
// Implementation: NotificationSoundSetting
//

@implementation NotificationSoundSetting

+ (NotificationSoundSetting *)getDefaultNotificationSoundWithType:(NotificationSoundType)type {
    
    switch (type) {
        case NotificationSoundTypeNotification:
            return [[NotificationSoundSetting alloc] initWithType:NotificationSoundTypeNotification name:@"twinme Notification" soundId:0 soundPath:@"twinme_notification.caf" config:chatSoundConfig];
            
        case NotificationSoundTypeAudioCall:
            return [[NotificationSoundSetting alloc] initWithType:NotificationSoundTypeAudioCall name:@"twinme audio call" soundId:0 soundPath:@"twinme_audio_call.caf" config:audioCallSoundConfig];
            
        case NotificationSoundTypeVideoCall:
            return [[NotificationSoundSetting alloc] initWithType:NotificationSoundTypeVideoCall name:@"twinme video call" soundId:0 soundPath:@"twinme_video_call.caf" config:videoCallSoundConfig];
            
        case NotificationSoundTypeAudioCalling:
            return [[NotificationSoundSetting alloc] initWithType:NotificationSoundTypeAudioCalling name:@"twinme calling" soundId:0 soundPath:@"twinme_connecting.caf"];
        
        case NotificationSoundTypeAudioRinging:
            return [[NotificationSoundSetting alloc] initWithType:NotificationSoundTypeAudioRinging name:@"twinme ringing" soundId:0 soundPath:@"twinme_ringing.caf"];
            
        case NotificationSoundTypeVideoCalling:
            return [[NotificationSoundSetting alloc] initWithType:NotificationSoundTypeVideoCalling name:@"twinme calling" soundId:0 soundPath:@"twinme_connecting.caf"];
            
        case NotificationSoundTypeAudioCallEnd:
            return [[NotificationSoundSetting alloc] initWithType:NotificationSoundTypeAudioCallEnd name:@"twinme call end" soundId:0 soundPath:@"twinme_call_end.caf"];
            
        case NotificationSoundTypeVideoCallEnd:
            return [[NotificationSoundSetting alloc] initWithType:NotificationSoundTypeVideoCallEnd name:@"twinme call end" soundId:0 soundPath:@"twinme_call_end.caf"];
    }
}

+ (NSArray<NotificationSoundSetting *> *)getNotificationSoundsWithType:(NotificationSoundType)type {
    
    switch (type) {
        case NotificationSoundTypeNotification:
            return [[NSArray alloc] initWithObjects:
                    [[NotificationSoundSetting alloc] initWithType:NotificationSoundTypeNotification name:@"twinme Notification" soundId:0 soundPath:@"twinme_notification.caf"],
                    [[NotificationSoundSetting alloc] initWithType:NotificationSoundTypeNotification name:@"Default notification sound" soundId:1007 soundPath:nil],
                    nil];
            
        case NotificationSoundTypeAudioCall:
            return [[NSArray alloc] initWithObjects:
                    [[NotificationSoundSetting alloc] initWithType:NotificationSoundTypeAudioCall name:@"twinme audio call" soundId:0 soundPath:@"twinme_audio_call.caf"],
                    [[NotificationSoundSetting alloc] initWithType:NotificationSoundTypeAudioCall name:@"twinme video call" soundId:0 soundPath:@"twinme_video_call.caf"],
                    nil];
        case NotificationSoundTypeVideoCall:
            return [[NSArray alloc] initWithObjects:
                    [[NotificationSoundSetting alloc] initWithType:NotificationSoundTypeVideoCall name:@"twinme audio call" soundId:0 soundPath:@"twinme_audio_call.caf"],
                    [[NotificationSoundSetting alloc] initWithType:NotificationSoundTypeVideoCall name:@"twinme video call" soundId:0 soundPath:@"twinme_video_call.caf"],
                    nil];
        
        case NotificationSoundTypeAudioCalling:
        case NotificationSoundTypeAudioRinging:
        case NotificationSoundTypeAudioCallEnd:
        case NotificationSoundTypeVideoCalling:
        case NotificationSoundTypeVideoCallEnd:
            return [[NSArray alloc] init];
    }
}

#pragma mark - Public methods

- (nonnull instancetype)initWithType:(NotificationSoundType)soundType name:(nullable NSString *)name soundId:(SystemSoundID)soundId soundPath:(nullable NSString *)soundPath config:(nonnull TLStringSharedConfigIdentifier *)config {

    self = [super init];
    if (self) {
        _soundType = soundType;
        _soundName = name;
        _soundPath = soundPath;
        _soundId = soundId;
        _config = config;
    }
    return self;
}

- (nonnull instancetype)initWithType:(NotificationSoundType)soundType name:(nonnull NSString *)name soundId:(SystemSoundID)soundId soundPath:(nullable NSString *)soundPath {
    
    self = [super init];
    if (self) {
        _soundType = soundType;
        _soundName = name;
        _soundPath = soundPath;
        _soundId = soundId;
    }
    return self;
}

- (nonnull instancetype)initWithSettings:(nonnull NotificationSoundSetting *)settings config:(nonnull TLStringSharedConfigIdentifier *)config {
    
    self = [super init];
    if (self) {
        _soundType = settings.soundType;
        _soundName = settings.soundName;
        _soundPath = settings.soundPath;
        _soundId = settings.soundId;
        _config = config;
    }
    return self;
}

- (nullable id)initWithCoder:(nonnull NSCoder *)coder {
    
    self = [super init];
    if (self) {
        self.soundName = [coder decodeObjectForKey:@"soundName"];
        self.soundPath = [coder decodeObjectForKey:@"soundPath"];
        self.soundId = [coder decodeInt32ForKey:@"soundId"];
    }
    return self;
}

- (void)encodeWithCoder:(nonnull NSCoder *)coder {
    
    [coder encodeObject:self.soundName forKey:@"soundName"];
    [coder encodeObject:self.soundPath forKey:@"soundPath"];
    [coder encodeInt32:self.soundId forKey:@"soundId"];
}

- (BOOL)isAvailable {
    
    if (self.soundPath) {
        return [[NSBundle mainBundle] pathForResource:self.soundPath ofType:nil] != nil;
    }
    
    return YES;
}

- (UNNotificationSound *)getSoundForLocalNotification {
    
    if (self.soundPath) {
        return [UNNotificationSound soundNamed:self.soundPath];
    }
    
    return [UNNotificationSound defaultSound];
}

- (void)save {
    
    if (self.config) {
        if (self.soundPath) {
            self.config.stringValue = [NSString stringWithFormat:@"%@\n%d\n%@", self.soundName, self.soundId, self.soundPath];
        } else {
            self.config.stringValue = [NSString stringWithFormat:@"%@\n%d\n", self.soundName, self.soundId];
        }
    }
}

#pragma mark - NSObject

- (BOOL)isEqual:(id)object {
    
    if (self == object) {
        return YES;
    }
    if (!object || ![object isKindOfClass:[NotificationSoundSetting class]]) {
        return NO;
    }
    NotificationSoundSetting *notificationSound = (NotificationSoundSetting *)object;
    if (self.soundPath) {
        return [self.soundPath isEqualToString:notificationSound.soundPath];
    } else {
        return self.soundId == notificationSound.soundId;
    }
}

- (NSUInteger)hash {
    
    NSUInteger result = 17;
    if (self.soundPath) {
        result = 31 * result + self.soundPath.hash;
    } else {
        result = 31 * result + self.soundId;
    }
    return result;
}

@end

//
// Implementation: NotificationSettings
//

#undef LOG_TAG
#define LOG_TAG @"NotificationSettings"

@implementation NotificationSettings

+ (void)initializeSettings {
    DDLogVerbose(@"%@ initializeSettings", LOG_TAG);
    
    soundEnableConfig = [TLBooleanSharedConfigIdentifier defineWithName:SOUND_ENABLE uuid:@"4383A4B4-F091-4EB5-93E7-4C7A01E6A31D" defaultValue:YES];
    displayNotificationSenderConfig = [TLBooleanSharedConfigIdentifier defineWithName:DISPLAY_NOTIFICATION_SENDER uuid:@"2BA7FFAC-7992-4828-B2F3-D27A6F5D9AAB" defaultValue:YES];
    displayNotificationContentConfig = [TLBooleanSharedConfigIdentifier defineWithName:DISPLAY_NOTIFICATION_CONTENT uuid:@"C3B015D9-01C9-40E8-8239-98084D4C2D3F" defaultValue:YES];
    displayNotificationLikeConfig = [TLBooleanSharedConfigIdentifier defineWithName:DISPLAY_NOTIFICATION_LIKE uuid:@"8A368FF8-6E37-4B82-8227-AAF9B916CDBE" defaultValue:YES];
    
    audioCallVibrationConfig = [TLBooleanSharedConfigIdentifier defineWithName:AUDIO_CALL_VIBRATION uuid:@"CA705D70-9029-4746-9719-274EA0F29F7C" defaultValue:YES];
    videoCallVibrationConfig = [TLBooleanSharedConfigIdentifier defineWithName:VIDEO_CALL_VIBRATION uuid:@"8412B66C-19E6-4D86-ADBF-BFF0FDDA1C2D" defaultValue:YES];
    chatVibrationConfig = [TLBooleanSharedConfigIdentifier defineWithName:CHAT_VIBRATION uuid:@"73D907A5-BDD2-44E4-8FA5-78E170A84421" defaultValue:YES];
    
    audioCallRingConfig = [TLBooleanSharedConfigIdentifier defineWithName:AUDIO_CALL_NOTIFICATION uuid:@"EA25E83B-772E-456F-BF87-65745C80CCD1" defaultValue:YES];
    videoCallRingConfig = [TLBooleanSharedConfigIdentifier defineWithName:VIDEO_CALL_NOTIFICATION uuid:@"BD58A3FF-5EFE-491D-8FDC-21F61C87CE0C" defaultValue:YES];
    chatRingConfig = [TLBooleanSharedConfigIdentifier defineWithName:CHAT_NOTIFICATION uuid:@"58F00122-5ED8-41CC-966A-572AA0B20B4A" defaultValue:YES];
    
    // Sound configuration (must use iOS specific UUID since it is not compatible with Android).
    chatSoundConfig = [TLStringSharedConfigIdentifier defineWithName:CHAT_NOTIFICATION_SOUND_V2 uuid:@"52980016-A689-4302-BAB8-2B35CDABA68E"];
    audioCallSoundConfig = [TLStringSharedConfigIdentifier defineWithName:AUDIO_CALL_NOTIFICATION_SOUND_V2 uuid:@"8664FF24-9758-41F8-B8F4-18B4AF5460B3"];
    videoCallSoundConfig = [TLStringSharedConfigIdentifier defineWithName:VIDEO_CALL_NOTIFICATION_SOUND_V2 uuid:@"30984647-CBF8-43C8-862D-2DF0488E7825"];
}

- (instancetype)init {
    DDLogVerbose(@"%@ init", LOG_TAG);
    
    self = [super init];
    if (self) {
        // Migrate the sound parameters for the NotificationService extension app.
        [self migrateSoundConfigurationWithName:CHAT_NOTIFICATION_SOUND config:chatSoundConfig];
        [self migrateSoundConfigurationWithName:AUDIO_CALL_NOTIFICATION_SOUND config:audioCallSoundConfig];
        [self migrateSoundConfigurationWithName:VIDEO_CALL_NOTIFICATION_SOUND config:videoCallSoundConfig];
        [self reload];
    }
    
    return self;
}

- (void)reload {
    DDLogVerbose(@"%@ reload", LOG_TAG);

    self.chatNotificationSound = nil;
    self.audioCallNotificationSound = nil;
    self.videoCallNotificationSound = nil;
    self.audioVideoCallingNotificationSound = nil;
}

- (BOOL)hasNotificationSoundWithType:(NotificationSoundType)type {
    DDLogVerbose(@"%@ hasNotificationSoundWithType: %u", LOG_TAG, type);
    
    switch (type) {
        case NotificationSoundTypeNotification:
            return chatRingConfig.boolValue;
            
        case NotificationSoundTypeAudioCall:
            return audioCallRingConfig.boolValue;
            
        case NotificationSoundTypeVideoCall:
            return videoCallRingConfig.boolValue;
            
        default:
            return NO;
    }
}

- (void)setNotificationSoundWithType:(NotificationSoundType)type state:(BOOL)state {
    DDLogVerbose(@"%@ setNotificationSoundWithType: %u state: %@", LOG_TAG, type, state ? @"YES" : @"NO");
    
    switch (type) {
        case NotificationSoundTypeNotification:
            chatRingConfig.boolValue = state;
            break;
            
        case NotificationSoundTypeAudioCall:
            audioCallRingConfig.boolValue = state;
            break;
            
        case NotificationSoundTypeVideoCall:
            videoCallRingConfig.boolValue = state;
            break;
            
        case NotificationSoundTypeAudioCalling:
        case NotificationSoundTypeAudioRinging:
        case NotificationSoundTypeAudioCallEnd:
        case NotificationSoundTypeVideoCalling:
        case NotificationSoundTypeVideoCallEnd:
            // No vibration and not configurable.
            break;
    }
}

- (BOOL)hasVibrationWithType:(NotificationSoundType)type {
    DDLogVerbose(@"%@ hasVibrationWithType: %u", LOG_TAG, type);
    
    switch (type) {
        case NotificationSoundTypeNotification:
            return chatVibrationConfig.boolValue;
            
        case NotificationSoundTypeAudioCall:
            return audioCallVibrationConfig.boolValue;
            
        case NotificationSoundTypeVideoCall:
            return videoCallVibrationConfig.boolValue;
            
        default:
            return NO;
    }
}

- (void)setVibrationWithType:(NotificationSoundType)type state:(BOOL)state {
    DDLogVerbose(@"%@ setVibrationWithType: %u state: %@", LOG_TAG, type, state ? @"YES" : @"NO");
    
    switch (type) {
        case NotificationSoundTypeNotification:
            chatVibrationConfig.boolValue = state;
            break;
            
        case NotificationSoundTypeAudioCall:
            audioCallVibrationConfig.boolValue = state;
            break;
            
        case NotificationSoundTypeVideoCall:
            videoCallVibrationConfig.boolValue = state;
            break;
            
        case NotificationSoundTypeAudioCalling:
        case NotificationSoundTypeAudioRinging:
        case NotificationSoundTypeAudioCallEnd:
        case NotificationSoundTypeVideoCalling:
        case NotificationSoundTypeVideoCallEnd:
            // No vibration and not configurable.
            break;
    }
}

- (NotificationSoundSetting *)getNotificationSoundWithType:(NotificationSoundType)type {
    DDLogVerbose(@"%@ getNotificationSoundWithType: %u", LOG_TAG,type);
    
    switch (type) {
        case NotificationSoundTypeNotification:
            if (!self.chatNotificationSound) {
                NotificationSoundSetting *chatNotificationSound = [self loadNotificationSoundWithConfig:chatSoundConfig soundType:type];
                if (!chatNotificationSound || ![chatNotificationSound isAvailable]) {
                    chatNotificationSound = [NotificationSoundSetting getDefaultNotificationSoundWithType:NotificationSoundTypeNotification];
                }
                self.chatNotificationSound = chatNotificationSound;
            }
            return self.chatNotificationSound;
            
        case NotificationSoundTypeAudioCall:
            if (!self.audioCallNotificationSound) {
                NotificationSoundSetting *audioCallNotificationSound = [self loadNotificationSoundWithConfig:audioCallSoundConfig soundType:type];
                if (!audioCallNotificationSound|| ![audioCallNotificationSound isAvailable]) {
                    audioCallNotificationSound = [NotificationSoundSetting getDefaultNotificationSoundWithType:NotificationSoundTypeAudioCall];
                }
                self.audioCallNotificationSound = audioCallNotificationSound;
            }
            return self.audioCallNotificationSound;
            
        case NotificationSoundTypeAudioCalling:
        case NotificationSoundTypeVideoCalling:
            // For now, same sound for audio and video and not configurable by user.
            self.audioVideoCallingNotificationSound = [NotificationSoundSetting getDefaultNotificationSoundWithType:type];
            return self.audioVideoCallingNotificationSound;
            
        case NotificationSoundTypeAudioRinging:
        case NotificationSoundTypeAudioCallEnd:
        case NotificationSoundTypeVideoCallEnd:
            // For now, same sound for audio and video and not configurable by user.
            return [NotificationSoundSetting getDefaultNotificationSoundWithType:type];
            
        case NotificationSoundTypeVideoCall:
            if (!self.videoCallNotificationSound) {
                NotificationSoundSetting *videoCallNotificationSound = [self loadNotificationSoundWithConfig:videoCallSoundConfig soundType:type];
                if (!videoCallNotificationSound || ![videoCallNotificationSound isAvailable]) {
                    videoCallNotificationSound = [NotificationSoundSetting getDefaultNotificationSoundWithType:NotificationSoundTypeVideoCall];
                }
                self.videoCallNotificationSound = videoCallNotificationSound;
            }
            return self.videoCallNotificationSound;
    }
}

- (void)setNotificationSoundWithType:(NotificationSoundType)type notificationSound:(NotificationSoundSetting*)notificationSound {
    
    switch (type) {
        case NotificationSoundTypeNotification:
            self.chatNotificationSound = [self saveNotificationSoundWithConfig:chatSoundConfig notificationSound:notificationSound];
            break;
            
        case NotificationSoundTypeAudioCall:
            self.audioCallNotificationSound = [self saveNotificationSoundWithConfig:audioCallSoundConfig notificationSound:notificationSound];
            break;
            
        case NotificationSoundTypeVideoCall:
            self.videoCallNotificationSound = [self saveNotificationSoundWithConfig:videoCallSoundConfig notificationSound:notificationSound];
            break;
            
        case NotificationSoundTypeAudioRinging:
        case NotificationSoundTypeAudioCalling:
        case NotificationSoundTypeAudioCallEnd:
        case NotificationSoundTypeVideoCalling:
        case NotificationSoundTypeVideoCallEnd:
            // Not configurable.
            break;
    }
}

- (void)setSoundEnableWithState:(BOOL)state {

    soundEnableConfig.boolValue = state;
}

- (BOOL)hasSoundEnable {
    
    return soundEnableConfig.boolValue;
}

- (void)setDisplayNotificationSenderWithState:(BOOL)state {
    
    displayNotificationSenderConfig.boolValue = state;
}

- (BOOL)hasDisplayNotificationSender {
    
    return displayNotificationSenderConfig.boolValue;
}

- (void)setDisplayNotificationContentWithState:(BOOL)state {
    
    displayNotificationContentConfig.boolValue = state;
}

- (BOOL)hasDisplayNotificationContent {
    
    return displayNotificationContentConfig.boolValue;
}

- (void)setDisplayNotificationLikeWithState:(BOOL)state {
    
    displayNotificationLikeConfig.boolValue = state;
}

- (BOOL)hasDisplayNotificationLike {
    
    return displayNotificationLikeConfig.boolValue;
}

- (void)updateNotificationBadgeNumber:(NSInteger)applicationBadgeNumber {

    NSUserDefaults *userDefaults = [TLTwinlife getAppSharedUserDefaults];

    [userDefaults setInteger:applicationBadgeNumber forKey:NOTIFICATION_BADGE_NUMBER_KEY];
    [userDefaults synchronize];
}

- (NSInteger)getNotificationBadgeNumber {

    NSUserDefaults *userDefaults = [TLTwinlife getAppSharedUserDefaults];
    id object = [userDefaults objectForKey:NOTIFICATION_BADGE_NUMBER_KEY];
    if (!object) {
        return 0;
    }

    return [object integerValue];
}

#pragma mark - Private methods

- (nonnull NotificationSoundSetting *)saveNotificationSoundWithConfig:(nonnull TLStringSharedConfigIdentifier *)config notificationSound:(nonnull NotificationSoundSetting *)notificationSound {
    DDLogVerbose(@"%@ saveNotificationSoundWithConfig: %@ notificationSound: %@", LOG_TAG, notificationSound, notificationSound);

    NotificationSoundSetting *setting = [[NotificationSoundSetting alloc] initWithSettings:notificationSound config:config];
    [setting save];
    return setting;
}

- (void)migrateSoundConfigurationWithName:(nonnull NSString *)name config:(nonnull TLStringSharedConfigIdentifier *)config {
    DDLogVerbose(@"%@ migrateSoundConfigurationWithName: %@ config: %@", LOG_TAG, name, config);
    
    // Get the setting from the app shared group container, if we find it, it's migrated.
    NSUserDefaults *userDefaults = [TLTwinlife getAppSharedUserDefaults];
    NSUserDefaults *oldDefaults = [NSUserDefaults standardUserDefaults];
    id object = [userDefaults objectForKey:name];
    if (!object) {
        object = [oldDefaults objectForKey:name];
        if (!object) {
            return;
        }
    }
    // unarchiveObjectWithData is deprecated and we only use it for the migration of the old
    // sound settings format to the new settings.  This migrateSoundConfigurationWithName could
    // be removed in 2025 or 2026.
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    
    NSData *encodedObject = object;
    NotificationSoundSetting *notificationSound = [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
    if (notificationSound) {
        [self saveNotificationSoundWithConfig:config notificationSound:notificationSound];
    }
    [userDefaults removeObjectForKey:name];
    [oldDefaults removeObjectForKey:name];
#pragma clang diagnostic pop
}


- (nullable NotificationSoundSetting *)loadNotificationSoundWithConfig:(nonnull TLStringSharedConfigIdentifier *)config soundType:(NotificationSoundType)soundType{
    DDLogVerbose(@"%@ loadNotificationSoundWithConfig: %@", LOG_TAG, config);
    
    NSString *value = config.stringValue;
    if (!value) {
        return nil;
    }

    NSArray<NSString *> *components = [value componentsSeparatedByString:SOUND_CONFIG_FIELD_SEPARATOR];
    if (components.count < 3) {
        return nil;
    }
    NSString *soundName = components[0];
    SystemSoundID soundId = (SystemSoundID) [components[1] integerValue];
    NSString *soundPath = components[2].length > 0 ? components[2] : nil;

    return [[NotificationSoundSetting alloc] initWithType:soundType name:soundName soundId:soundId soundPath:soundPath];
}

@end
