/*
 *  Copyright (c) 2021 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "DesignExtension.h"

static float DESIGN_REFERENCE_HEIGHT = 1334;
static float DESIGN_REFERENCE_WIDTH = 750;

// static float DESIGN_REFERENCE_DISPLAY_HEIGHT = 667;
// static float DESIGN_REFERENCE_DISPLAY_WIDTH = 375;

static CGFloat DESIGN_DISPLAY_HEIGHT;
static CGFloat DESIGN_DISPLAY_WIDTH;

static CGFloat DESIGN_HEIGHT_RATIO;
static CGFloat DESIGN_WIDTH_RATIO;
static CGFloat DESIGN_FONT_RATIO;

static UIFont *DESIGN_REGULAR28;
static UIFont *DESIGN_REGULAR34;
static UIFont *DESIGN_REGULAR36;
static UIFont *DESIGN_MEDIUM32;
static UIFont *DESIGN_MEDIUM34;
static UIFont *DESIGN_BOLD26;
static UIFont *DESIGN_BOLD34;
static UIFont *DESIGN_BOLD36;
static UIFont *DESIGN_BOLD44;
static UIFont *DESIGN_BOLD68;

static UIColor *DESIGN_WHITE_COLOR;
static UIColor *DESIGN_BLACK_COLOR;
static UIColor *DESIGN_FONT_COLOR_DEFAULT;
static UIColor *DESIGN_LIGHT_GREY_BACKGROUND_COLOR;
static UIColor *DESIGN_NAVIGATION_BACKGROUND_COLOR;
static UIColor *DESIGN_SEPARATOR_COLOR_GREY;
static UIColor *DESIGN_BACKGROUND_COLOR_GREY;
static UIColor *DESIGN_POPUP_BACKGROUND_COLOR;

@implementation DesignExtension

+ (void)initialize {
    
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    DESIGN_DISPLAY_HEIGHT = screenSize.height;
    DESIGN_DISPLAY_WIDTH  = screenSize.width;
    
    if (DESIGN_REFERENCE_HEIGHT *  DESIGN_DISPLAY_WIDTH < DESIGN_REFERENCE_WIDTH * DESIGN_DISPLAY_HEIGHT) {
        DESIGN_HEIGHT_RATIO = DESIGN_DISPLAY_WIDTH / DESIGN_REFERENCE_WIDTH;
    } else {
        DESIGN_HEIGHT_RATIO = DESIGN_DISPLAY_HEIGHT / DESIGN_REFERENCE_HEIGHT;
    }
    DESIGN_WIDTH_RATIO = DESIGN_HEIGHT_RATIO;
    
    DESIGN_FONT_RATIO = MIN(DESIGN_DISPLAY_HEIGHT / DESIGN_REFERENCE_HEIGHT, 0.5);
    
    DESIGN_REGULAR28 = [UIFont systemFontOfSize:(28 * DESIGN_FONT_RATIO)];
    DESIGN_REGULAR34 = [UIFont systemFontOfSize:(34 * DESIGN_FONT_RATIO)];
    DESIGN_REGULAR36 = [UIFont systemFontOfSize:(36 * DESIGN_FONT_RATIO)];
    DESIGN_MEDIUM32 = [UIFont systemFontOfSize:(32 * DESIGN_FONT_RATIO) weight:UIFontWeightMedium];
    DESIGN_MEDIUM34 = [UIFont systemFontOfSize:(34 * DESIGN_FONT_RATIO) weight:UIFontWeightMedium];
    DESIGN_BOLD26 = [UIFont systemFontOfSize:(26 * DESIGN_FONT_RATIO) weight:UIFontWeightBold];
    DESIGN_BOLD34 = [UIFont systemFontOfSize:(34 * DESIGN_FONT_RATIO) weight:UIFontWeightBold];
    DESIGN_BOLD36 = [UIFont systemFontOfSize:(36 * DESIGN_FONT_RATIO) weight:UIFontWeightBold];
    DESIGN_BOLD44 = [UIFont systemFontOfSize:(44 * DESIGN_FONT_RATIO) weight:UIFontWeightBold];
    DESIGN_BOLD68 = [UIFont systemFontOfSize:(68 * DESIGN_FONT_RATIO) weight:UIFontWeightBold];
    
    [self setupColors];
}

+ (void)setupColors {
    
    if ([UIScreen mainScreen].traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark){
        [self setupDarkColors];
    } else {
        [self setupLightColors];
    }
}

+ (void)setupDarkColors {
    
    DESIGN_WHITE_COLOR = [UIColor blackColor];
    DESIGN_BLACK_COLOR = [UIColor whiteColor];
    DESIGN_FONT_COLOR_DEFAULT = [UIColor whiteColor];
    DESIGN_LIGHT_GREY_BACKGROUND_COLOR = [UIColor blackColor];
    DESIGN_NAVIGATION_BACKGROUND_COLOR = [UIColor blackColor];
    DESIGN_SEPARATOR_COLOR_GREY = [UIColor colorWithRed:199./255. green:199./255. blue:255./255. alpha:0.3];
    DESIGN_BACKGROUND_COLOR_GREY = [UIColor colorWithRed:72./255. green:72./255. blue:72./255. alpha:1];
    DESIGN_POPUP_BACKGROUND_COLOR = [UIColor colorWithRed:72./255. green:72./255. blue:72./255. alpha:1];
}

+ (void)setupLightColors {
    
    DESIGN_WHITE_COLOR = [UIColor whiteColor];
    DESIGN_BLACK_COLOR = [UIColor blackColor];
    DESIGN_FONT_COLOR_DEFAULT = [UIColor colorWithRed:44./255. green:44./255. blue:44./255. alpha:1];
    DESIGN_LIGHT_GREY_BACKGROUND_COLOR = [UIColor colorWithRed:249./255. green:249./255. blue:249./255. alpha:1];
    DESIGN_NAVIGATION_BACKGROUND_COLOR = [UIColor colorWithRed:0 green:174./255. blue:255./255. alpha:1];
    DESIGN_SEPARATOR_COLOR_GREY = [UIColor colorWithRed:199./255. green:199./255. blue:204./255. alpha:1];
    DESIGN_BACKGROUND_COLOR_GREY = [UIColor colorWithRed:239./255. green:239./255. blue:239./255. alpha:1];
    DESIGN_POPUP_BACKGROUND_COLOR = [UIColor whiteColor];
}

+ (CGFloat)REFERENCE_HEIGHT {
    
    return DESIGN_REFERENCE_HEIGHT;
}

+ (CGFloat)REFERENCE_WIDTH {
    
    return DESIGN_REFERENCE_WIDTH;
}

+ (CGFloat)DISPLAY_HEIGHT {
    
    return DESIGN_DISPLAY_HEIGHT;
}

+ (CGFloat)DISPLAY_WIDTH {
    
    return DESIGN_DISPLAY_WIDTH;
}

+ (CGFloat)HEIGHT_RATIO {
    
    return DESIGN_HEIGHT_RATIO;
}

+ (CGFloat)WIDTH_RATIO {
    
    return DESIGN_WIDTH_RATIO;
}

+ (UIFont *)FONT_REGULAR28 {
    
    return DESIGN_REGULAR28;
}

+ (UIFont *)FONT_REGULAR34 {
    
    return DESIGN_REGULAR34;
}

+ (UIFont *)FONT_REGULAR36 {
    
    return DESIGN_REGULAR36;
}

+ (UIFont *)FONT_MEDIUM32 {
    
    return DESIGN_MEDIUM32;
}

+ (UIFont *)FONT_MEDIUM34 {
 
    return DESIGN_MEDIUM34;
}

+ (UIFont *)FONT_BOLD26 {
    
    return DESIGN_BOLD26;
}

+ (UIFont *)FONT_BOLD34 {
    
    return DESIGN_BOLD34;
}

+ (UIFont *)FONT_BOLD36 {
    
    return DESIGN_BOLD36;
}

+ (UIFont *)FONT_BOLD44 {
    
    return DESIGN_BOLD44;
}

+ (UIFont *)FONT_BOLD68 {
    
    return DESIGN_BOLD68;
}

+ (UIColor *)WHITE_COLOR {
    
    return DESIGN_WHITE_COLOR;
}

+ (UIColor *)BLACK_COLOR {
    
    return DESIGN_BLACK_COLOR;
}

+ (UIColor *)FONT_COLOR_DEFAULT {
    
    return DESIGN_FONT_COLOR_DEFAULT;
}

+ (UIColor *)LIGHT_GREY_BACKGROUND_COLOR {
    
    return DESIGN_LIGHT_GREY_BACKGROUND_COLOR;
}

+ (UIColor *)NAVIGATION_BACKGROUND_COLOR {
    
    return DESIGN_NAVIGATION_BACKGROUND_COLOR;
}

+ (UIColor *)SEPARATOR_COLOR_GREY {
    
    return DESIGN_SEPARATOR_COLOR_GREY;
}

+ (UIColor *)BACKGROUND_COLOR_GREY {
    
    return DESIGN_BACKGROUND_COLOR_GREY;
}

+ (UIColor *)POPUP_BACKGROUND_COLOR {
    
    return DESIGN_POPUP_BACKGROUND_COLOR;
}

@end
