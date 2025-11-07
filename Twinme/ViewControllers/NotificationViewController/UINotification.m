/*
 *  Copyright (c) 2022-2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <Twinlife/TLNotificationService.h>

#import "UINotification.h"

//
// Interface: UINotification
//

@implementation UINotification

- (nonnull instancetype)initWithNotification:(nonnull NSMutableArray<TLNotification *> *)notifications avatar:(nullable UIImage *)avatar {
    
    self = [super init];
    if (self) {
        _notifications = notifications;
        _avatar = avatar;
        _groupMember = nil;
        _isCertifiedContact = NO;
    }
    return self;
}

- (nonnull TLNotification *)getLastNotification {
    
    return [self.notifications firstObject];
}

- (void)addNotification:(nonnull TLNotification *)notification {
    
    [self.notifications insertObject:notification atIndex:0];
}

- (NSUInteger)getCount {
    
    return self.notifications.count;
}

- (BOOL)isAcknowledged {
    
    for (TLNotification *notification in self.notifications) {
        if (!notification.acknowledged) {
            return NO;
        }
    }
    
    return YES;
}

- (BOOL)sameNotification:(nonnull UINotification *)uiNotification {
    
    TLNotification *first = [self getLastNotification];
    TLNotification *second = [uiNotification getLastNotification];
    return first.subject == second.subject && self.groupMember == uiNotification.groupMember && ![self isNotificationNotBeGrouped:second.notificationType] && first.notificationType == second.notificationType;
}

- (BOOL)isNotificationNotBeGrouped:(TLNotificationType)notificationType {
    
    return notificationType == TLNotificationTypeNewGroupInvitation || notificationType == TLNotificationTypeNewGroupJoined || notificationType == TLNotificationTypeNewContactInvitation || notificationType == TLNotificationTypeDeletedGroup || notificationType == TLNotificationTypeNewContact;
}

- (BOOL)removeNotification:(nonnull NSUUID *)notificationId {
    
    for (TLNotification *notification in self.notifications) {
        if ([notificationId isEqual:notification.uuid]) {
            [self.notifications removeObject:notification];
            return YES;
        }
    }
    return NO;
}

@end
