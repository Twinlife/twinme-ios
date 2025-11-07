/*
 *  Copyright (c) 2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "AbstractConfirmView.h"

//
// Interface: OnboardingConfirmView
//

@interface OnboardingConfirmView : AbstractConfirmView

- (void)initWithTitle:(NSString *)title message:(NSString *)message image:(UIImage *)image action:(NSString *)action actionColor:(UIColor *)actionColor cancel:(NSString *)cancel;

- (void)hideCancelAction;

@end
