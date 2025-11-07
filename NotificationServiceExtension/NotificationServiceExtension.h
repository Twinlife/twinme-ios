/*
 *  Copyright (c) 2020-2023 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Christian Jacquemot (Christian.Jacquemot@twinlife-systems.com)
 *   Stephane Carrez (Stephane.Carrez@twin.life)
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <UserNotifications/UserNotifications.h>

@interface NotificationServiceExtension : UNNotificationServiceExtension

@property (nonatomic, nullable) UNNotificationRequest *request;
@property (nonatomic, nullable) UNMutableNotificationContent *notification;
@property (nonatomic, nullable) void (^contentHandler) (UNNotificationContent * _Nonnull);
@property (nonatomic, nullable) NSUUID *contactId;
@property (nonatomic, nullable) NSUUID *groupId;
@property int64_t deadline;
@property BOOL processing;

- (void)didReceiveNotificationRequest:(nonnull UNNotificationRequest *)request withContentHandler:(nonnull void (^)(UNNotificationContent * _Nonnull))contentHandler;

- (void)serviceExtensionTimeWillExpire;

- (void)sendDefaultNotification;

@end
