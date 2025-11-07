/*
 *  Copyright (c) 2016-2020 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Chedi Baccari (Chedi.Baccari@twinlife-systems.com)
 *   Christian Jacquemot (Christian.Jacquemot@twinlife-systems.com)
 */

//
// Protocol: NotificationViewDelegate
//

@protocol NotificationViewDelegate <NSObject>

- (void)handleSwipeActionWithNotificationId:(nonnull NSUUID *)notificationId;

- (void)handleTapActionWithNotificationId:(nonnull NSUUID *)notificationId;

- (void)handleAcceptActionWithNotificationId:(nonnull NSUUID *)notificationId;

- (void)handleDeclineActionWithNotificationId:(nonnull NSUUID *)notificationId;

@end

//
// Interface: NotificationView
//

@class NotificationSound;

@interface NotificationView : UIViewController

- (nonnull instancetype)initWithNotificationId:(nonnull NSUUID *)notificationId title:(nonnull NSString *)title message:(nonnull NSString *)message avatar:(nonnull UIImage *)avatar notificationSound:(nullable NotificationSound *)notificationSound actionButtons:(BOOL)actionButtons notificationViewDelegate:(nonnull id<NotificationViewDelegate>)notificationViewDelegate;

- (void)showInView:(nonnull UIView*)view;

- (void)hideNotification;

@end
