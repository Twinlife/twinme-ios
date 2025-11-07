/*
 *  Copyright (c) 2023 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

typedef enum {
    ContactTagPending,
    ContactTagRevoked
} ContactTag;

@interface UIContactTag : NSObject

@property (nonatomic, nonnull) NSString *title;
@property (nonatomic, nonnull) UIColor *backgroundColor;
@property (nonatomic, nonnull) UIColor *foregroundColor;
@property (nonatomic) ContactTag contactTag;

- (nonnull instancetype)initWithTag:(ContactTag)contactTag;

@end
