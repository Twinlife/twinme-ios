/*
 *  Copyright (c) 2020-2024 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Christian Jacquemot (Christian.Jacquemot@twinlife-systems.com)
 *   Stephane Carrez (Stephane.Carrez@twin.life)
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "NotificationSettings.h"
#import <Twinlife/TLNotificationService.h>

@class TLTwinmeContext;
@class TLDescriptor;
@class TLContact;
@class TLNotification;
@class TLAttributeNameValue;
@class UNNotificationSound;
@protocol TLOriginator;

//
// Interface: NotificationInfo
//

@interface NotificationInfo : NSObject

@property TLNotificationType type;
@property (nullable) NSString *alertBody;
@property (nullable) UNNotificationSound *alertSound;
@property (nullable) NSString *alertTitle;
@property (nullable) NSString *alertPrivateTitle;
@property (nullable) NSUUID *identifier;
@property (nullable) NSDictionary<NSString *, id <NSSecureCoding>> *userInfo;
@property (nullable) TLNotification *notification;
@property (nullable) id<TLOriginator> originator;
@property (nullable) NotificationSoundSetting *soundSettings;
@property BOOL vibrate;

@end

//
// Interface: NotificationTools
//

@interface NotificationTools : NSObject

@property (nonatomic, readonly, nonnull) TLTwinmeContext *twinmeContext;
@property (nonatomic, readonly, nonnull) NotificationSettings *settings;

- (nonnull instancetype)initWithTwinmeContext:(nonnull TLTwinmeContext *)twinmeContext settings:(nonnull NotificationSettings *)settings;

/// Create a new notification for a new message/descriptor.
- (nullable NotificationInfo *)createNotificationDescriptorWithContact:(nonnull id<TLOriginator>)contact conversationId:(nonnull NSUUID *)conversationId descriptor:(nonnull TLDescriptor *)descriptor notificationId:(nullable NSUUID *)notificationId;

/// Create a new notification for a change in annotation on a descriptor.
- (nullable NotificationInfo *)createNotificationAnnotationWithContact:(nonnull id<TLOriginator>)contact conversationId:(nonnull NSUUID *)conversationId descriptor:(nonnull TLDescriptor *)descriptor annotatingUser:(nullable TLTwincodeOutbound *)annotatingUser notificationId:(nullable NSUUID *)notificationId;

/// Create a new notification after a user joined the group.
- (nullable NotificationInfo *)createNotificationJoinGroupWithGroup:(nonnull id<TLOriginator>)group conversationId:(nonnull NSUUID *)conversationId notificationId:(nullable NSUUID *)notificationId;

/// Create a new notification for a new contact.
- (nullable NotificationInfo *)createNotificationNewContactWithContact:(nonnull id<TLOriginator>)contact notificationId:(nullable NSUUID *)notificationId;

/// Create a new notification when a contact is removed.
- (nullable NotificationInfo *)createNotificationUnbindContactWithContact:(nonnull id<TLOriginator>)contact notificationId:(nullable NSUUID *)notificationId;

/// Create a new notification when the contact name or picture was modified.
- (nullable NotificationInfo *)createNotificationUpdateContactWithContact:(nonnull id<TLOriginator>)contact updatedAttributes:(nonnull NSArray<TLAttributeNameValue *> *)updatedAttributes notificationId:(nullable NSUUID *)notificationId;

/// Create a new notification after an audio or video call is missed.
- (nullable NotificationInfo *)createNotificationMissedCallWithContact:(nonnull id<TLOriginator>)contact video:(BOOL)video;

/// Create a new notification for an incoming audio or video call when PushKit cannot be used.
- (nullable NotificationInfo *)createNotificationIncomingCallWithContact:(nonnull id<TLOriginator>)contact video:(BOOL)video notificationId:(nullable NSUUID *)notificationId;

/// Create a new notification with a message.
- (nullable NotificationInfo *)contactNotificationWithContact:(nonnull id<TLOriginator>)contact notificationMessage:(nonnull NSString *)notificationMessage type:(TLNotificationType)type canRing:(BOOL)canRing notificationId:(nullable NSUUID *)notificationId;

@end
