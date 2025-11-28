/*
 *  Copyright (c) 2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

//
// Interface: ProxyView
//

@interface ProxyView : UIViewController

- (instancetype)initWithProxy:(NSString *)proxy qrcode:(UIImage *)qrcode message:(NSString *)message;

- (UIImage *)screenshot;

@end
