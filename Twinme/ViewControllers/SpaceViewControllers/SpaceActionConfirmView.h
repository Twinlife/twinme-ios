/*
 *  Copyright (c) 2024 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "AbstractConfirmView.h"

typedef enum {
    SpaceActionConfirmTypeMoveContact,
    SpaceActionConfirmTypeProfile,
    SpaceActionConfirmTypeSecret
} SpaceActionConfirmType;

//
// Interface: SpaceActionConfirmView
//

@interface SpaceActionConfirmView : AbstractConfirmView

@property (nonatomic) SpaceActionConfirmType spaceActionConfirmType;

- (void)initWithTitle:(nonnull NSString *)title message:(nonnull NSString *)message spaceName:(nonnull NSString *)spaceName spaceStyle:(nullable NSString *)spaceStyle avatar:(nullable UIImage *)avatar icon:(nullable UIImage *)icon confirmTitle:(nonnull NSString *)confirmTitle cancelTitle:(nonnull NSString *)cancelTitle;

@end
