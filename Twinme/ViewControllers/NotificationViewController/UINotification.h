/*
 *  Copyright (c) 2022-2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

@class TLNotification;
@class TLGroupMember;

//
// Interface: UINotification
//

@interface UINotification : NSObject

@property (nonatomic, nonnull) NSMutableArray<TLNotification *> *notifications;
@property (nonatomic, nullable) UIImage *avatar;
@property (nonatomic, nullable) UIImage *annotationAvatar;
@property (nonatomic, nullable) TLGroupMember *groupMember;
@property (nonatomic) BOOL isCertifiedContact;

- (nonnull instancetype)initWithNotification:(nonnull NSMutableArray<TLNotification *> *)notifications avatar:(nullable UIImage *)avatar;

- (nonnull TLNotification *)getLastNotification;

- (void)addNotification:(nonnull TLNotification *)notification;

- (NSUInteger)getCount;

- (BOOL)isAcknowledged;

- (BOOL)sameNotification:(nonnull UINotification *)uiNotification;

- (BOOL)removeNotification:(nonnull NSUUID *)notificationId;

@end
