/*
 *  Copyright (c) 2024 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "AbstractBottomSheetView.h"

//
// Interface: DefaultConfirmView
//

@interface DefaultConfirmView : AbstractBottomSheetView

- (void)initWithTitle:(NSString *)title message:(NSString *)message image:(UIImage *)image avatar:(UIImage *)avatar action:(NSString *)action actionColor:(UIColor *)actionColor cancel:(NSString *)cancel;

- (void)useLargeImage;

- (void)hideCancelAction;

@end
