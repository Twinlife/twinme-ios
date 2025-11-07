/*
 *  Copyright (c) 2019-2020 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import "UIColor+Hex.h"

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

//
// Implementation: UIColor (Hex)
//

#undef LOG_TAG
#define LOG_TAG @"UIColor+Hex"

@implementation UIColor (Hex)

+ (UIColor *)colorWithHexString:(NSString *)hexString alpha:(float)alpha {
    DDLogVerbose(@"%@ colorWithHexString: %@ alpha: %f", LOG_TAG, hexString, alpha);
    
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    if ([hexString hasPrefix:@"#"]) {
        [scanner setScanLocation:1];
    }
    [scanner scanHexInt:&rgbValue];
    
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16) / 255. green:((rgbValue & 0xFF00) >> 8) / 255. blue:(rgbValue & 0xFF) / 255. alpha:alpha];
}

+ (NSString *)hexStringWithColor:(UIColor *)color {
    
    if (!color) {
        return nil;
    }
    
    const CGFloat *components = CGColorGetComponents(color.CGColor);
    size_t nbComponents = CGColorGetNumberOfComponents(color.CGColor);
    
    CGFloat red;
    CGFloat green;
    CGFloat blue;
    CGFloat alpha;
    
    if (nbComponents == 2) {
        red = components[0];
        green = components[0];
        blue = components[0];
        alpha = components[1];
    } else {
        red = components[0];
        green = components[1];
        blue = components[2];
        alpha = components[3];
    }
    
    if (alpha == 1.0) {
        return [NSString stringWithFormat:@"%02X%02X%02X", (int)(red * 255), (int)(green * 255), (int)(blue * 255)];
    }
    
    return [NSString stringWithFormat:@"%02X%02X%02X%02X", (int)(red * 255), (int)(green * 255), (int)(blue * 255), (int)(alpha * 255)];
}

@end
