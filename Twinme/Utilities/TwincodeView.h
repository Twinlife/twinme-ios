/*
 *  Copyright (c) 2021 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

//
// Interface: TwincodeView
//

@interface TwincodeView : UIViewController

- (instancetype)initWithName:(NSString *)name avatar:(UIImage *)avatar qrcode:(UIImage *)qrcode twincodeId:(NSUUID *)twincodeId;

- (UIImage *)screenshot;

@end
