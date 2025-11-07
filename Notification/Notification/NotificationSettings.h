/*
 *  Copyright (c) 2020-2024 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Christian Jacquemot (Christian.Jacquemot@twinlife-systems.com)
 *   Stephane Carrez (Stephane.Carrez@twin.life)
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <AudioToolbox/AudioToolbox.h>

@class UNNotificationSound;

typedef enum {
    NotificationSoundTypeNotification,
    NotificationSoundTypeAudioCall,
    NotificationSoundTypeAudioCalling,
    NotificationSoundTypeAudioRinging,
    NotificationSoundTypeAudioCallEnd,
    NotificationSoundTypeVideoCall,
    NotificationSoundTypeVideoCallEnd,
    NotificationSoundTypeVideoCalling
} NotificationSoundType;

//
// Interface: NotificationSound
//

@interface NotificationSoundSetting : NSObject <NSCoding>

@property NotificationSoundType soundType;
@property (nullable) NSString *soundName;
@property (nullable) NSString *soundPath;
@property int soundId;

+ (nonnull NotificationSoundSetting *)getDefaultNotificationSoundWithType:(NotificationSoundType)type;

+ (nonnull NSArray<NotificationSoundSetting *> *)getNotificationSoundsWithType:(NotificationSoundType)type;

- (nonnull instancetype)initWithType:(NotificationSoundType)soundType name:(nonnull NSString *)name soundId:(SystemSoundID)soundId soundPath:(nullable NSString *)soundPath;

- (BOOL)isAvailable;

- (nonnull UNNotificationSound *)getSoundForLocalNotification;

@end

//
// Interface: NotificationSettings
//

@interface NotificationSettings : NSObject

+ (void)initializeSettings;

//
// Settings preferences management
//

- (void)reload;

- (BOOL)hasNotificationSoundWithType:(NotificationSoundType)type;

- (void)setNotificationSoundWithType:(NotificationSoundType)type state:(BOOL)state;

- (BOOL)hasVibrationWithType:(NotificationSoundType)type;

- (void)setVibrationWithType:(NotificationSoundType)type state:(BOOL)state;

- (nonnull NotificationSoundSetting *)getNotificationSoundWithType:(NotificationSoundType)type;

- (void)setNotificationSoundWithType:(NotificationSoundType)type notificationSound:(nonnull NotificationSoundSetting *)notificationSound;

- (BOOL)hasSoundEnable;

- (void)setSoundEnableWithState:(BOOL)state;

- (BOOL)hasDisplayNotificationSender;

- (void)setDisplayNotificationSenderWithState:(BOOL)state;

- (BOOL)hasDisplayNotificationContent;

- (void)setDisplayNotificationContentWithState:(BOOL)state;

- (BOOL)hasDisplayNotificationLike;

- (void)setDisplayNotificationLikeWithState:(BOOL)state;

- (void)updateNotificationBadgeNumber:(NSInteger)applicationBadgeNumber;

- (NSInteger)getNotificationBadgeNumber;

@end
