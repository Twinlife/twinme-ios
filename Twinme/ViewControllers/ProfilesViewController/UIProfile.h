/*
 *  Copyright (c) 2020-2024 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

@class TLProfile;

//
// Interfece UIProfile
//

@interface UIProfile : NSObject

@property (nonatomic, nonnull) TLProfile *profile;
@property (nonatomic, nonnull) NSString *name;
@property (nonatomic, nullable) UIImage *avatar;

- (nonnull instancetype)initWithProfile:(nonnull TLProfile *)profile;

- (void)setProfile:(nonnull TLProfile *)profile;

- (void)updateAvatar:(nonnull UIImage *)avatar;

@end
