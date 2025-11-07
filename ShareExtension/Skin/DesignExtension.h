/*
 *  Copyright (c) 2021 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>

//
// Interface: DesignExtension
//

@interface DesignExtension : NSObject

+ (CGFloat)REFERENCE_HEIGHT;

+ (CGFloat)REFERENCE_WIDTH;

+ (CGFloat)DISPLAY_HEIGHT;

+ (CGFloat)DISPLAY_WIDTH;

+ (CGFloat)HEIGHT_RATIO;

+ (CGFloat)WIDTH_RATIO;

+ (UIFont *)FONT_REGULAR28;

+ (UIFont *)FONT_REGULAR34;

+ (UIFont *)FONT_REGULAR36;

+ (UIFont *)FONT_MEDIUM32;

+ (UIFont *)FONT_MEDIUM34;

+ (UIFont *)FONT_BOLD26;

+ (UIFont *)FONT_BOLD34;

+ (UIFont *)FONT_BOLD36;

+ (UIFont *)FONT_BOLD44;

+ (UIFont *)FONT_BOLD68;

+ (UIColor *)WHITE_COLOR;

+ (UIColor *)BLACK_COLOR;

+ (UIColor *)FONT_COLOR_DEFAULT;

+ (UIColor *)LIGHT_GREY_BACKGROUND_COLOR;

+ (UIColor *)NAVIGATION_BACKGROUND_COLOR;

+ (UIColor *)SEPARATOR_COLOR_GREY;

+ (UIColor *)BACKGROUND_COLOR_GREY;

+ (UIColor *)POPUP_BACKGROUND_COLOR;

@end
