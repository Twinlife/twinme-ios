/*
 *  Copyright (c) 2024 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "AbstractConfirmView.h"

//
// Interface: DeleteSpaceConfirmView
//

@interface DeleteSpaceConfirmView : AbstractConfirmView

- (void)initWithTitle:(nonnull NSString *)title message:(nonnull NSString *)message spaceName:(nonnull NSString *)spaceName spaceStyle:(nullable NSString *)spaceStyle avatar:(nullable UIImage *)avatar icon:(nullable UIImage *)icon;

@end
