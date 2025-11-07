/*
 *  Copyright (c) 2023 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

@class TLCallReceiver;

@interface UICallReceiver : NSObject

@property (nonatomic, nonnull) TLCallReceiver *callReceiver;
@property (nonatomic, nonnull) NSString *name;
@property (nonatomic, nullable) UIImage *avatar;

- (nonnull instancetype)initWithCallReceiver:(nonnull TLCallReceiver *)callReceiver ;

- (nonnull instancetype)initWithCallReceiver:(nonnull TLCallReceiver *)callReceiver avatar:(nonnull UIImage *)avatar;

- (void)updateCallReceiver:(nonnull TLCallReceiver *)callReceiver ;

- (void)updateAvatar:(nonnull UIImage *)avatar;

@end
