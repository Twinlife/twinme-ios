/*
 *  Copyright (c) 2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

//
// Interface: UIInvitationCode
//

@class TLInvitation;

@interface UIInvitationCode : NSObject

@property (nonatomic, nonnull) TLInvitation *invitation;
@property (nonatomic, nonnull) NSString *code;
@property (nonatomic) long expirationDate;

- (nonnull instancetype)initWithTitle:(nonnull TLInvitation *)invitation code:(nonnull NSString *)code expirationDate:(long)expirationDate;

- (nonnull NSString *)formatExpirationDate;

- (BOOL)hasExpired;

@end
