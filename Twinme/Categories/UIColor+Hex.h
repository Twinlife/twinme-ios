/*
 *  Copyright (c) 2019-2020 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

//
// Interface: UIColor (Hex)
//

@interface UIColor (Hex)

+ (UIColor *)colorWithHexString:(NSString *)hexString alpha:(float)alpha;

+ (NSString *)hexStringWithColor:(UIColor *)color;

@end
