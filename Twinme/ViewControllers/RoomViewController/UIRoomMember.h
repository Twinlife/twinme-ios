/*
 *  Copyright (c) 2020 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

//
// Interface: UIRoomMember
//

@class TLTwincodeOutbound;

@interface UIRoomMember : NSObject

@property (nonatomic, nonnull) TLTwincodeOutbound *twincodeOutbound;
@property (nonatomic, nonnull) NSString *name;
@property (nonatomic, nonnull) UIImage *avatar;

- (nonnull instancetype)initWithTwincodeOutbound:(nonnull TLTwincodeOutbound *)twincodeOutbound avatar:(nullable UIImage *)avatar;

- (void)setTwincodeOutbound:(nonnull TLTwincodeOutbound *)twincodeOutbound avatar:(nonnull UIImage *)avatar;

@end
