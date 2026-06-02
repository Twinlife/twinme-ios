/*
 *  Copyright (c) 2026 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

//
// Interface: UIPollResultVoter
//

@interface UIPollResultVoter : NSObject

@property (nonatomic, nullable) NSString *name;
@property (nonatomic, nonnull) UIImage *avatar;

- (nonnull instancetype)initWithName:(nullable NSString *)name avatar:(nonnull UIImage *)avatar;

@end

