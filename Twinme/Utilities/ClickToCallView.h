/*
 *  Copyright (c) 2023 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

//
// Interface: ClickToCallView
//

@interface ClickToCallView : UIViewController

- (instancetype)initWithName:(NSString *)name avatar:(UIImage *)avatar qrcode:(UIImage *)qrcode twincodeId:(NSUUID *)twincodeId message:(NSString *)message;

- (UIImage *)screenshot;

@end
