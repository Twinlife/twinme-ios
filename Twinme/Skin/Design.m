/*
 *  Copyright (c) 2016-2024 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Chedi Baccari (Chedi.Baccari@twinlife-systems.com)
 *   Christian Jacquemot (Christian.Jacquemot@twinlife-systems.com)
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <CoreText/CoreText.h>

#import <Twinlife/TLConfigIdentifier.h>
#import <TwinmeCommon/Design.h>

#import "UIImage+ImageEffects.h"
#import "UIColor+Hex.h"
#import "UICustomColor.h"

#import <TwinmeCommon/ApplicationDelegate.h>
#import <TwinmeCommon/TwinmeApplication.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static float DESIGN_REFERENCE_HEIGHT = 1334;
static float DESIGN_REFERENCE_WIDTH = 750;

static CGFloat DESIGN_DISPLAY_HEIGHT;
static CGFloat DESIGN_DISPLAY_WIDTH;

static CGFloat DESIGN_HEIGHT_RATIO;
static CGFloat DESIGN_WIDTH_RATIO;

static CGFloat DESIGN_MIN_RATIO;
static CGFloat DESIGN_MAX_RATIO;

static CGFloat DESIGN_FONT_RATIO;

static UIColor* DESIGN_BACKGROUND_COLOR_WHITE_OPACITY85;
static UIColor* DESIGN_BACKGROUND_COLOR_WHITE_OPACITY36;
static UIColor* DESIGN_BACKGROUND_COLOR_WHITE_OPACITY11;

static UIColor* DESIGN_BACKGROUND_COLOR_BLUE;
static UIColor* DESIGN_BACKGROUND_COLOR_GREY;

static UIColor* DESIGN_FONT_COLOR_DEFAULT;
static UIColor* DESIGN_FONT_COLOR_GREY;
static UIColor* DESIGN_FONT_COLOR_PROFILE_GREY;

static UIColor* DESIGN_FONT_COLOR_GREEN;
static UIColor* DESIGN_FONT_COLOR_RED;
static UIColor* DESIGN_FONT_COLOR_BLUE;

static UIColor* DESIGN_DELETE_COLOR_RED;
static UIColor* DESIGN_DELETE_BORDER_COLOR_RED;

static UIColor* DESIGN_BORDER_COLOR_GREY;
static UIColor* DESIGN_SEPARATOR_COLOR_GREY;

static UIColor* DESIGN_FONT_COLOR_DESCRIPTION;
static UIColor* DESIGN_SEGMENTED_CONTROL_TINT_COLOR;
static UIColor* DESIGN_CHECKMARK_BORDER_COLOR;
static UIColor* DESIGN_BACKGROUND_GREY_COLOR;

static UIColor* DESIGN_WHITE_COLOR;
static UIColor* DESIGN_WHITE_COLOR_20_OPACITY;
static UIColor* DESIGN_BLACK_COLOR;
static UIColor* DESIGN_LIGHT_GREY_BACKGROUND_COLOR;
static UIColor* DESIGN_NAVIGATION_BACKGROUND_COLOR;
static UIColor* DESIGN_POPUP_BACKGROUND_COLOR;
static UIColor* DESIGN_SPLASHSCREEN_LOGO_COLOR;
static UIColor* DESIGN_PLACEHOLDER_COLOR;
static UIColor* DESIGN_SWITCH_BORDER_COLOR;
static UIColor* DESIGN_AUDIO_CALL_COLOR;
static UIColor* DESIGN_VIDEO_CALL_COLOR;
static UIColor* DESIGN_CHAT_COLOR;
static UIColor* DESIGN_BUTTON_RED_COLOR;
static UIColor* DESIGN_BUTTON_GREEN_COLOR;
static UIColor* DESIGN_ACTION_CALL_COLOR;
static UIColor* DESIGN_ACTION_IMAGE_CALL_COLOR;
static UIColor* DESIGN_EDIT_AVATAR_BACKGROUND_COLOR;
static UIColor* DESIGN_EDIT_AVATAR_IMAGE_COLOR;
static UIColor* DESIGN_CONVERSATION_BACKGROUND_COLOR;
static UIColor* DESIGN_TEXTFIELD_BACKGROUND_COLOR;
static UIColor* DESIGN_TEXTFIELD_POPUP_BACKGROUND_COLOR;
static UIColor* DESIGN_TEXTFIELD_CONVERSATION_BACKGROUND_COLOR;
static UIColor* DESIGN_ITEM_BORDER_COLOR;
static UIColor* DESIGN_ACCESSORY_COLOR;
static UIColor* DESIGN_REPLY_FONT_COLOR;
static UIColor* DESIGN_REPLY_BACKGROUND_COLOR;
static UIColor* DESIGN_FORWARD_ITEM_COLOR;
static UIColor* DESIGN_FORWARD_BORDER_COLOR;
static UIColor* DESIGN_FORWARD_COMMENT_COLOR;
static UIColor* DESIGN_OVERLAY_COLOR;
static UIColor* DESIGN_AUDIO_TRACK_COLOR;
static UIColor* DESIGN_PEER_AUDIO_TRACK_COLOR;
static UIColor* DESIGN_UNSELECTED_TAB_COLOR;
static UIColor* DESIGN_TIME_COLOR;
static UIColor* DESIGN_MENU_BACKGROUND_COLOR;
static UIColor* DESIGN_MENU_REACTION_BACKGROUND_COLOR;
static UIColor* DESIGN_CUSTOM_TAB_BACKGROUND_COLOR;
static UIColor* DESIGN_ACTION_BORDER_COLOR;
static UIColor* DESIGN_ZOOM_COLOR;
static NSArray* DESIGN_BACKGROUND_GRADIENT_COLORS_BLACK;

static NSMutableArray* DESIGN_COLORS;

static UIColor* DESIGN_SHADOW_COLOR_DEFAULT;

static UIFont *DESIGN_REGULAR16;
static UIFont *DESIGN_REGULAR20;
static UIFont *DESIGN_REGULAR22;
static UIFont *DESIGN_REGULAR24;
static UIFont *DESIGN_REGULAR26;
static UIFont *DESIGN_REGULAR28;
static UIFont *DESIGN_REGULAR30;
static UIFont *DESIGN_REGULAR32;
static UIFont *DESIGN_REGULAR34;
static UIFont *DESIGN_REGULAR36;
static UIFont *DESIGN_REGULAR40;
static UIFont *DESIGN_REGULAR44;
static UIFont *DESIGN_REGULAR50;
static UIFont *DESIGN_REGULAR58;
static UIFont *DESIGN_REGULAR64;
static UIFont *DESIGN_REGULAR68;

static UIFont *DESIGN_MEDIUM16;
static UIFont *DESIGN_MEDIUM20;
static UIFont *DESIGN_MEDIUM24;
static UIFont *DESIGN_MEDIUM26;
static UIFont *DESIGN_MEDIUM28;
static UIFont *DESIGN_MEDIUM30;
static UIFont *DESIGN_MEDIUM32;
static UIFont *DESIGN_MEDIUM34;
static UIFont *DESIGN_MEDIUM36;
static UIFont *DESIGN_MEDIUM38;
static UIFont *DESIGN_MEDIUM40;
static UIFont *DESIGN_MEDIUM42;
static UIFont *DESIGN_MEDIUM44;
static UIFont *DESIGN_MEDIUM54;

static UIFont *DESIGN_MEDIUM_ITALIC28;
static UIFont *DESIGN_MEDIUM_ITALIC36;
static UIFont *DESIGN_MEDIUM_ITALIC40;

static UIFont *DESIGN_BOLD20;
static UIFont *DESIGN_BOLD26;
static UIFont *DESIGN_BOLD28;
static UIFont *DESIGN_BOLD34;
static UIFont *DESIGN_BOLD36;
static UIFont *DESIGN_BOLD44;
static UIFont *DESIGN_BOLD68;
static UIFont *DESIGN_BOLD88;

static UIFont *DESIGN_FONT_EMOJI_EXTRA_EXTRA_LARGE;
static UIFont *DESIGN_FONT_EMOJI_EXTRA_LARGE;
static UIFont *DESIGN_FONT_EMOJI_LARGE;
static UIFont *DESIGN_FONT_EMOJI_MEDIUM;
static UIFont *DESIGN_FONT_EMOJI_SMALL;

//
// To be reviewed
//

static UIColor* DESIGN_BLUE_NORMAL;

static UIColor* DESIGN_GREY_ITEM;

static float DESIGN_SHADOW_OPACITY = 0.14;
static CGSize DESIGN_SHADOW_OFFSET;
static CGFloat DESIGN_SHADOW_RADIUS;

static int DESIGN_BACKGROUND_WIDTH = 256;
static int DESIGN_BACKGROUND_HEIGHT;
static CGFloat DESIGN_SEPARATOR_HEIGHT;
static CGFloat DESIGN_BORDER_WIDTH;
static CGFloat DESIGN_AVATAR_HEIGHT;
static CGFloat DESIGN_AVATAR_LEADING;
static CGFloat DESIGN_NAME_TRAILING;
static CGFloat DESIGN_ACCESSORY_HEIGHT;
static CGFloat DESIGN_CERTIFIED_HEIGHT;
static CGFloat DESIGN_CELL_HEIGHT;
static CGFloat DESIGN_DESCRIPTION_HEIGHT;
static CGFloat DESIGN_SETTING_CELL_HEIGHT;
static CGFloat DESIGN_SETTING_SECTION_HEIGHT;
static CGFloat DESIGN_INVITATION_LINE_SPACING;
static CGFloat DESIGN_TEXT_WIDTH_PADDING;
static CGFloat DESIGN_TEXT_HEIGHT_PADDING;
static CGFloat DESIGN_MESSAGE_CELL_MAX_WIDTH;
static CGFloat DESIGN_PEER_MESSAGE_CELL_MAX_WIDTH;
static CGFloat DESIGN_REPLY_IMAGE_MAX_WIDTH;
static CGFloat DESIGN_REPLY_IMAGE_MAX_HEIGHT;
static CGFloat DESIGN_REPLY_VIEW_IMAGE_TOP;
static CGFloat DESIGN_SWIPE_WIDTH_TO_REPLY;
static CGFloat DESIGN_CHECKMARK_BORDER_WIDTH;
static CGFloat DESIGN_IMAGE_CELL_MAX_WIDTH;
static CGFloat DESIGN_IMAGE_CELL_MAX_HEIGHT;
static CGFloat DESIGN_FORWARDED_IMAGE_CELL_MAX_HEIGHT;
static CGFloat DESIGN_FORWARDED_SMALL_IMAGE_CELL_MAX_HEIGHT;
static CGFloat DESIGN_ANNOTATION_CELL_WIDTH_NORMAL;
static CGFloat DESIGN_ANNOTATION_CELL_WIDTH_LARGE;
static CGFloat DESIGN_BUTTON_PADDING;

static float DESIGN_CONTAINER_RADIUS = 11;
static float DESIGN_POPUP_RADIUS = 14;

static float DESIGN_SWITCH_WIDTH = 29;
static float DESIGN_SWITCH_HEIGHT = 20;

static float DESIGN_PROGESS_VIEW_HEIGHT = 5;

static CGFloat DESIGN_ANIMATION_VIEW_DURATION = 0.3;

static CFMutableCharacterSetRef DESIGN_EMOJI_CHARACTER_SET;

static NSString *MAIN_STYLE = @"MainStyle";
static NSString *DEFAULT_COLOR = @"#00AEFF";
static TLStringConfigIdentifier *mainStyleConfig;

//
// Implementation: Design
//

#undef LOG_TAG
#define LOG_TAG @"Design"

@implementation Design

+ (void)initialize {
    DDLogVerbose(@"%@ initialize", LOG_TAG);
    
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    DESIGN_DISPLAY_HEIGHT = screenSize.height;
    DESIGN_DISPLAY_WIDTH  = screenSize.width;

    mainStyleConfig = [TLStringConfigIdentifier defineWithName:MAIN_STYLE uuid:@"B2977B13-1899-4A41-9244-365B40ADBBB9"];

    if (DESIGN_REFERENCE_HEIGHT *  DESIGN_DISPLAY_WIDTH < DESIGN_REFERENCE_WIDTH * DESIGN_DISPLAY_HEIGHT) {
        DESIGN_HEIGHT_RATIO = DESIGN_DISPLAY_WIDTH / DESIGN_REFERENCE_WIDTH;
    } else {
        DESIGN_HEIGHT_RATIO = DESIGN_DISPLAY_HEIGHT / DESIGN_REFERENCE_HEIGHT;
    }
    DESIGN_WIDTH_RATIO = DESIGN_HEIGHT_RATIO;
    
    DESIGN_MIN_RATIO = MIN(DESIGN_HEIGHT_RATIO, DESIGN_WIDTH_RATIO);
    DESIGN_MAX_RATIO = MAX(DESIGN_HEIGHT_RATIO, DESIGN_WIDTH_RATIO);
    
    DESIGN_FONT_RATIO = MIN(DESIGN_DISPLAY_HEIGHT / DESIGN_REFERENCE_HEIGHT, 0.5);
    
    DESIGN_BACKGROUND_COLOR_BLUE = [UIColor colorWithRed:0./255. green:174./255. blue:255./255. alpha:1];
    
    DESIGN_FONT_COLOR_GREEN = [UIColor colorWithRed:82./255. green:204./255. blue:122./255. alpha:1];
    DESIGN_FONT_COLOR_RED = [UIColor colorWithRed:240./255. green:105./255. blue:105./255. alpha:1];
    DESIGN_FONT_COLOR_BLUE = [UIColor colorWithRed:74./255. green:144./255. blue:226./255. alpha:1];
  
    DESIGN_DELETE_COLOR_RED = [UIColor colorWithRed:253./255. green:96./255. blue:93./255. alpha:1];
    
    DESIGN_DELETE_BORDER_COLOR_RED = [UIColor colorWithRed:221./255. green:0./255. blue:0./255. alpha:1];
    
    DESIGN_BORDER_COLOR_GREY = [UIColor colorWithRed:243./255. green:243./255. blue:243./255. alpha:1];
    
    DESIGN_EDIT_AVATAR_BACKGROUND_COLOR = [UIColor colorWithRed:243./255. green:243./255. blue:243./255. alpha:1];
    DESIGN_EDIT_AVATAR_IMAGE_COLOR  = [UIColor colorWithRed:200./255. green:200./255.  blue:200./255. alpha:1];
    
    DESIGN_EDIT_AVATAR_BACKGROUND_COLOR = [UIColor colorWithRed:243./255. green:243./255.  blue:243./255.  alpha:1];
    DESIGN_EDIT_AVATAR_IMAGE_COLOR  = [UIColor colorWithRed:200./255. green:200./255.  blue:200./255.  alpha:1];
    
    DESIGN_ITEM_BORDER_COLOR = [UIColor colorWithRed:218./255. green:218./255. blue:218./255. alpha:1.0];
    DESIGN_FONT_COLOR_GREY = [UIColor colorWithRed:178./255. green:178./255. blue:178./255. alpha:1.0];
    DESIGN_FONT_COLOR_PROFILE_GREY = [UIColor colorWithRed:143./255. green:150./255. blue:164./255. alpha:1.0];
    DESIGN_ACCESSORY_COLOR = [UIColor colorWithRed:209./255. green:209./255. blue:214./255. alpha:1.0];
    DESIGN_SHADOW_COLOR_DEFAULT =  [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2];
    DESIGN_OVERLAY_COLOR = [UIColor colorWithRed:13./255. green:13./255. blue:13./255. alpha:0.46];
    DESIGN_AUDIO_TRACK_COLOR = [UIColor colorWithRed:51./255. green:51./255. blue:51./255. alpha:1];
    DESIGN_UNSELECTED_TAB_COLOR = [UIColor colorWithRed:119./255. green:138./255. blue:159./255. alpha:1.0];
    DESIGN_FORWARD_ITEM_COLOR = [UIColor colorWithRed:241./255. green:241./255. blue:241./255. alpha:1.0];
    DESIGN_FORWARD_BORDER_COLOR = [UIColor colorWithRed:227./255. green:227./255. blue:227./255. alpha:1.0];
    DESIGN_FONT_COLOR_DESCRIPTION = [UIColor colorWithRed:142./255. green:142./255. blue:147./255. alpha:1.0];
    DESIGN_CHECKMARK_BORDER_COLOR = [UIColor colorWithRed:114./255. green:140./255. blue:161./255. alpha:0.56];
    DESIGN_ACTION_BORDER_COLOR = [UIColor colorWithRed:84./255. green:84./255. blue:84./255. alpha:1.0];
    DESIGN_TEXTFIELD_POPUP_BACKGROUND_COLOR = [UIColor colorWithRed:213./255. green:215./255. blue:224./255. alpha:0.3];
    DESIGN_ZOOM_COLOR = [UIColor colorWithRed:255./255. green:161./255. blue:0./255. alpha:1.0];
    
    UIColor *blackGradientColorStart = [UIColor colorWithRed:0/255. green:0/255. blue:0/255. alpha:0];
    UIColor *blackGradientColorEnd = [UIColor colorWithRed:0/255. green:0/255. blue:0/255. alpha:1.0];
    DESIGN_BACKGROUND_GRADIENT_COLORS_BLACK = @[(id)blackGradientColorStart.CGColor, (id)blackGradientColorEnd.CGColor];
    
    [self setupFont];
    [self setupMainColors];
    [self setupColors];
    
    //
    // To be reviewed
    //
    
    DESIGN_BLUE_NORMAL = [UIColor colorWithRed:0./255. green:174./255. blue:255./255. alpha:1];
    
    DESIGN_SHADOW_OFFSET = CGSizeMake(0, 6);
    DESIGN_SHADOW_RADIUS = 12 * DESIGN_HEIGHT_RATIO;
    
    DESIGN_BACKGROUND_HEIGHT = DESIGN_BACKGROUND_WIDTH * (DESIGN_DISPLAY_HEIGHT / DESIGN_DISPLAY_WIDTH);
    
    DESIGN_SEPARATOR_HEIGHT = 0.5;
    DESIGN_BORDER_WIDTH = 2;
    DESIGN_AVATAR_HEIGHT = 86 * DESIGN_HEIGHT_RATIO;
    DESIGN_AVATAR_LEADING = 42 * DESIGN_WIDTH_RATIO;
    DESIGN_NAME_TRAILING = 38 * DESIGN_WIDTH_RATIO;
    DESIGN_ACCESSORY_HEIGHT = 26 * DESIGN_HEIGHT_RATIO;
    DESIGN_CERTIFIED_HEIGHT = 28 * DESIGN_HEIGHT_RATIO;
    DESIGN_CELL_HEIGHT = 124 * DESIGN_HEIGHT_RATIO;
    DESIGN_DESCRIPTION_HEIGHT = 162 * DESIGN_HEIGHT_RATIO;
    DESIGN_SETTING_CELL_HEIGHT = 120 * DESIGN_HEIGHT_RATIO;
    DESIGN_SETTING_SECTION_HEIGHT = 140 * DESIGN_HEIGHT_RATIO;
    DESIGN_INVITATION_LINE_SPACING = 4 * DESIGN_HEIGHT_RATIO;
    
    DESIGN_TEXT_WIDTH_PADDING = 32 * DESIGN_WIDTH_RATIO;
    DESIGN_TEXT_HEIGHT_PADDING = 16 * DESIGN_HEIGHT_RATIO;
    DESIGN_MESSAGE_CELL_MAX_WIDTH = 502 * DESIGN_WIDTH_RATIO;
    DESIGN_PEER_MESSAGE_CELL_MAX_WIDTH = 408 * DESIGN_WIDTH_RATIO;
    DESIGN_REPLY_IMAGE_MAX_WIDTH = 290 * DESIGN_WIDTH_RATIO;
    DESIGN_REPLY_IMAGE_MAX_HEIGHT = 290 * DESIGN_HEIGHT_RATIO;
    DESIGN_REPLY_VIEW_IMAGE_TOP = 28 * DESIGN_HEIGHT_RATIO;
    DESIGN_SWIPE_WIDTH_TO_REPLY = 120 * DESIGN_HEIGHT_RATIO;
    DESIGN_IMAGE_CELL_MAX_WIDTH = 500 * DESIGN_WIDTH_RATIO;
    DESIGN_IMAGE_CELL_MAX_HEIGHT = 889 * DESIGN_HEIGHT_RATIO;
    DESIGN_FORWARDED_IMAGE_CELL_MAX_HEIGHT = 240 * DESIGN_HEIGHT_RATIO;
    DESIGN_FORWARDED_SMALL_IMAGE_CELL_MAX_HEIGHT = 120 * DESIGN_HEIGHT_RATIO;
    DESIGN_ANNOTATION_CELL_WIDTH_NORMAL = 60 * DESIGN_WIDTH_RATIO;
    DESIGN_ANNOTATION_CELL_WIDTH_LARGE = 70 * DESIGN_WIDTH_RATIO;
    DESIGN_BUTTON_PADDING = 40 * DESIGN_WIDTH_RATIO;
    
    DESIGN_CHECKMARK_BORDER_WIDTH = 0.5;
}

+ (float) getAdjustFontSize {
    
    ApplicationDelegate *delegate = (ApplicationDelegate *)[[UIApplication sharedApplication] delegate];
    TwinmeApplication *twinmeApplication = [delegate twinmeApplication];
    
    float adjustFontSize = 0;
    switch (twinmeApplication.fontSize) {
        case FontSizeSystem: {
            UIContentSizeCategory uiContentSizeCategory = [UIApplication sharedApplication].preferredContentSizeCategory;
            if ([uiContentSizeCategory isEqualToString:UIContentSizeCategoryExtraSmall]) {
                adjustFontSize = -2;
            } else if ([uiContentSizeCategory isEqualToString:UIContentSizeCategorySmall]) {
                adjustFontSize = -1;
            } else if ([uiContentSizeCategory isEqualToString:UIContentSizeCategoryLarge]) {
                adjustFontSize = 1;
            } else if ([uiContentSizeCategory isEqualToString:UIContentSizeCategoryExtraLarge]) {
                adjustFontSize = 2;
            } else if ([uiContentSizeCategory isEqualToString:UIContentSizeCategoryExtraExtraLarge]) {
                adjustFontSize = 3;
            } else if ([uiContentSizeCategory isEqualToString:UIContentSizeCategoryExtraExtraExtraLarge]) {
                adjustFontSize = 4;
            }
        }
            break;
            
        case FontSizeSmall:
            adjustFontSize = -2;
            break;
            
        case FontSizeLarge:
            adjustFontSize = +2;
            break;
            
        case FontSizeExtraLarge:
            adjustFontSize = +4;
            break;
            
        default:
            break;
    }
    
    return adjustFontSize;
}

+ (void)setupFont {
    DDLogVerbose(@"%@ setupFont", LOG_TAG);
    
    float adjustFontSize = [Design getAdjustFontSize];
    
    DESIGN_REGULAR16 = [UIFont systemFontOfSize:(16 * DESIGN_FONT_RATIO) + adjustFontSize weight:UIFontWeightRegular];
    DESIGN_REGULAR20 = [UIFont systemFontOfSize:(20 * DESIGN_FONT_RATIO) + adjustFontSize weight:UIFontWeightRegular];
    DESIGN_REGULAR22 = [UIFont systemFontOfSize:(22 * DESIGN_FONT_RATIO) + adjustFontSize weight:UIFontWeightRegular];
    DESIGN_REGULAR24 = [UIFont systemFontOfSize:(24 * DESIGN_FONT_RATIO) + adjustFontSize weight:UIFontWeightRegular];
    DESIGN_REGULAR26 = [UIFont systemFontOfSize:(26 * DESIGN_FONT_RATIO) + adjustFontSize weight:UIFontWeightRegular];
    DESIGN_REGULAR28 = [UIFont systemFontOfSize:(28 * DESIGN_FONT_RATIO) + adjustFontSize weight:UIFontWeightRegular];
    DESIGN_REGULAR30 = [UIFont systemFontOfSize:(30 * DESIGN_FONT_RATIO) + adjustFontSize weight:UIFontWeightRegular];
    DESIGN_REGULAR32 = [UIFont systemFontOfSize:(32 * DESIGN_FONT_RATIO) + adjustFontSize weight:UIFontWeightRegular];
    DESIGN_REGULAR34 = [UIFont systemFontOfSize:(34 * DESIGN_FONT_RATIO) + adjustFontSize weight:UIFontWeightRegular];
    DESIGN_REGULAR36 = [UIFont systemFontOfSize:(36 * DESIGN_FONT_RATIO) + adjustFontSize weight:UIFontWeightRegular];
    DESIGN_REGULAR40 = [UIFont systemFontOfSize:(40 * DESIGN_FONT_RATIO) + adjustFontSize weight:UIFontWeightRegular];
    DESIGN_REGULAR44 = [UIFont systemFontOfSize:(44 * DESIGN_FONT_RATIO) + adjustFontSize weight:UIFontWeightRegular];
    DESIGN_REGULAR50 = [UIFont systemFontOfSize:(50 * DESIGN_FONT_RATIO) + adjustFontSize weight:UIFontWeightRegular];
    DESIGN_REGULAR58 = [UIFont systemFontOfSize:(58 * DESIGN_FONT_RATIO) + adjustFontSize weight:UIFontWeightRegular];
    DESIGN_REGULAR64 = [UIFont systemFontOfSize:(64 * DESIGN_FONT_RATIO) + adjustFontSize weight:UIFontWeightRegular];
    DESIGN_REGULAR68 = [UIFont systemFontOfSize:(68 * DESIGN_FONT_RATIO) + adjustFontSize weight:UIFontWeightRegular];
    
    DESIGN_MEDIUM16 = [UIFont systemFontOfSize:(16 * DESIGN_FONT_RATIO) + adjustFontSize weight:UIFontWeightMedium];
    DESIGN_MEDIUM20 = [UIFont systemFontOfSize:(20 * DESIGN_FONT_RATIO) + adjustFontSize weight:UIFontWeightMedium];
    DESIGN_MEDIUM24 = [UIFont systemFontOfSize:(24 * DESIGN_FONT_RATIO) + adjustFontSize weight:UIFontWeightMedium];
    DESIGN_MEDIUM26 = [UIFont systemFontOfSize:(26 * DESIGN_FONT_RATIO) + adjustFontSize weight:UIFontWeightMedium];
    DESIGN_MEDIUM28 = [UIFont systemFontOfSize:(28 * DESIGN_FONT_RATIO) + adjustFontSize weight:UIFontWeightMedium];
    DESIGN_MEDIUM30 = [UIFont systemFontOfSize:(30 * DESIGN_FONT_RATIO) + adjustFontSize weight:UIFontWeightMedium];
    DESIGN_MEDIUM32 = [UIFont systemFontOfSize:(32 * DESIGN_FONT_RATIO) + adjustFontSize weight:UIFontWeightMedium];
    DESIGN_MEDIUM34 = [UIFont systemFontOfSize:(34 * DESIGN_FONT_RATIO) + adjustFontSize weight:UIFontWeightMedium];
    DESIGN_MEDIUM36 = [UIFont systemFontOfSize:(36 * DESIGN_FONT_RATIO) + adjustFontSize weight:UIFontWeightMedium];
    DESIGN_MEDIUM38 = [UIFont systemFontOfSize:(38 * DESIGN_FONT_RATIO) + adjustFontSize weight:UIFontWeightMedium];
    DESIGN_MEDIUM40 = [UIFont systemFontOfSize:(40 * DESIGN_FONT_RATIO) + adjustFontSize weight:UIFontWeightMedium];
    DESIGN_MEDIUM42 = [UIFont systemFontOfSize:(42 * DESIGN_FONT_RATIO) + adjustFontSize weight:UIFontWeightMedium];
    DESIGN_MEDIUM44 = [UIFont systemFontOfSize:(44 * DESIGN_FONT_RATIO) + adjustFontSize weight:UIFontWeightMedium];
    DESIGN_MEDIUM54 = [UIFont systemFontOfSize:(54 * DESIGN_FONT_RATIO) + adjustFontSize weight:UIFontWeightMedium];
    
    DESIGN_MEDIUM_ITALIC28 = [UIFont italicSystemFontOfSize:(28 * DESIGN_FONT_RATIO) + adjustFontSize];
    DESIGN_MEDIUM_ITALIC36 = [UIFont italicSystemFontOfSize:(36 * DESIGN_FONT_RATIO) + adjustFontSize];
    DESIGN_MEDIUM_ITALIC40 = [UIFont italicSystemFontOfSize:(40 * DESIGN_FONT_RATIO) + adjustFontSize];
    
    DESIGN_BOLD20 = [UIFont systemFontOfSize:(20 * DESIGN_FONT_RATIO) + adjustFontSize weight:UIFontWeightBold];
    DESIGN_BOLD26 = [UIFont systemFontOfSize:(26 * DESIGN_FONT_RATIO) + adjustFontSize weight:UIFontWeightBold];
    DESIGN_BOLD28 = [UIFont systemFontOfSize:(28 * DESIGN_FONT_RATIO) + adjustFontSize weight:UIFontWeightBold];
    DESIGN_BOLD34 = [UIFont systemFontOfSize:(34 * DESIGN_FONT_RATIO) + adjustFontSize weight:UIFontWeightBold];
    DESIGN_BOLD36 = [UIFont systemFontOfSize:(36 * DESIGN_FONT_RATIO) + adjustFontSize weight:UIFontWeightBold];
    DESIGN_BOLD44 = [UIFont systemFontOfSize:(44 * DESIGN_FONT_RATIO) + adjustFontSize weight:UIFontWeightBold];
    DESIGN_BOLD68 = [UIFont systemFontOfSize:(68 * DESIGN_FONT_RATIO) + adjustFontSize weight:UIFontWeightBold];
    DESIGN_BOLD88 = [UIFont systemFontOfSize:(88 * DESIGN_FONT_RATIO) + adjustFontSize weight:UIFontWeightBold];
    
    ApplicationDelegate *delegate = (ApplicationDelegate *)[[UIApplication sharedApplication] delegate];
    TwinmeApplication *twinmeApplication = [delegate twinmeApplication];
    
    if (twinmeApplication.emojiSize == EmojiSizeSmall) {
        DESIGN_FONT_EMOJI_EXTRA_EXTRA_LARGE = [UIFont systemFontOfSize:(100 * DESIGN_FONT_RATIO) + adjustFontSize weight:UIFontWeightBold];
        DESIGN_FONT_EMOJI_EXTRA_LARGE = [UIFont systemFontOfSize:(80 * DESIGN_FONT_RATIO) + adjustFontSize weight:UIFontWeightBold];
        DESIGN_FONT_EMOJI_LARGE = [UIFont systemFontOfSize:(60 * DESIGN_FONT_RATIO) + adjustFontSize weight:UIFontWeightBold];
        DESIGN_FONT_EMOJI_MEDIUM = [UIFont systemFontOfSize:(40 * DESIGN_FONT_RATIO) + adjustFontSize weight:UIFontWeightBold];
        DESIGN_FONT_EMOJI_SMALL = [UIFont systemFontOfSize:(32 * DESIGN_FONT_RATIO) + adjustFontSize weight:UIFontWeightBold];
    } else if (twinmeApplication.emojiSize == EmojiSizeStandard) {
        DESIGN_FONT_EMOJI_EXTRA_EXTRA_LARGE = [UIFont systemFontOfSize:(120 * DESIGN_FONT_RATIO) + adjustFontSize weight:UIFontWeightBold];
        DESIGN_FONT_EMOJI_EXTRA_LARGE = [UIFont systemFontOfSize:(100 * DESIGN_FONT_RATIO) + adjustFontSize weight:UIFontWeightBold];
        DESIGN_FONT_EMOJI_LARGE = [UIFont systemFontOfSize:(80 * DESIGN_FONT_RATIO) + adjustFontSize weight:UIFontWeightBold];
        DESIGN_FONT_EMOJI_MEDIUM = [UIFont systemFontOfSize:(60 * DESIGN_FONT_RATIO) + adjustFontSize weight:UIFontWeightBold];
        DESIGN_FONT_EMOJI_SMALL = [UIFont systemFontOfSize:(40 * DESIGN_FONT_RATIO) + adjustFontSize weight:UIFontWeightBold];
    } else {
        DESIGN_FONT_EMOJI_EXTRA_EXTRA_LARGE = [UIFont systemFontOfSize:(140 * DESIGN_FONT_RATIO) + adjustFontSize weight:UIFontWeightBold];
        DESIGN_FONT_EMOJI_EXTRA_LARGE = [UIFont systemFontOfSize:(120 * DESIGN_FONT_RATIO) + adjustFontSize weight:UIFontWeightBold];
        DESIGN_FONT_EMOJI_LARGE = [UIFont systemFontOfSize:(100 * DESIGN_FONT_RATIO) + adjustFontSize weight:UIFontWeightBold];
        DESIGN_FONT_EMOJI_MEDIUM = [UIFont systemFontOfSize:(80 * DESIGN_FONT_RATIO) + adjustFontSize weight:UIFontWeightBold];
        DESIGN_FONT_EMOJI_SMALL = [UIFont systemFontOfSize:(60 * DESIGN_FONT_RATIO) + adjustFontSize weight:UIFontWeightBold];
    }
}

+ (void)setupColors {
    DDLogVerbose(@"%@ setupColors", LOG_TAG);
    
    ApplicationDelegate *delegate = (ApplicationDelegate *)[[UIApplication sharedApplication] delegate];
    TwinmeApplication *twinmeApplication = [delegate twinmeApplication];
    
    switch (twinmeApplication.displayMode) {
        case DisplayModeSystem:
            if (@available(iOS 13.0, *)) {
                if ([UIScreen mainScreen].traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark){
                    [self setupDarkColors];
                } else {
                    [self setupLightColors];
                }
            } else {
                [self setupLightColors];
            }
            break;
            
        case DisplayModeLight:
            [self setupLightColors];
            break;
            
        case DisplayModeDark:
            [self setupDarkColors];
            break;
        default:
            break;
    }
}

+ (void)setupDarkColors {
    DDLogVerbose(@"%@ setupDarkColors", LOG_TAG);
    
    DESIGN_WHITE_COLOR = [UIColor blackColor];
    DESIGN_WHITE_COLOR_20_OPACITY = [UIColor colorWithWhite:0.0 alpha:0.2];
    DESIGN_BLACK_COLOR = [UIColor whiteColor];
    DESIGN_FONT_COLOR_DEFAULT = [UIColor whiteColor];
    DESIGN_LIGHT_GREY_BACKGROUND_COLOR = [UIColor blackColor];
    DESIGN_NAVIGATION_BACKGROUND_COLOR = [UIColor blackColor];
    DESIGN_POPUP_BACKGROUND_COLOR = [UIColor colorWithRed:72./255. green:72./255. blue:72./255. alpha:1];
    DESIGN_BACKGROUND_COLOR_WHITE_OPACITY85 = [UIColor colorWithWhite:0 alpha:0.85];
    DESIGN_BACKGROUND_COLOR_WHITE_OPACITY36 = [UIColor colorWithWhite:0 alpha:0.36];
    DESIGN_BACKGROUND_COLOR_WHITE_OPACITY11 = [UIColor colorWithWhite:0 alpha:0.11];
    DESIGN_REPLY_BACKGROUND_COLOR = [UIColor colorWithRed:100./255. green:100./255. blue:100./255. alpha:1];
    DESIGN_REPLY_FONT_COLOR = [UIColor colorWithRed:200./255. green:200./255. blue:200./255. alpha:1];
    DESIGN_PLACEHOLDER_COLOR = [UIColor colorWithRed:199./255. green:199./255. blue:204./255. alpha:1];
    DESIGN_SWITCH_BORDER_COLOR = [UIColor colorWithRed:44./255. green:48./255. blue:51./255. alpha:1.0];
    DESIGN_AUDIO_CALL_COLOR = [UIColor colorWithRed:0/255. green:174./255. blue:255./255. alpha:1.0];
    DESIGN_VIDEO_CALL_COLOR = [UIColor colorWithRed:225./255. green:35./255. blue:93./255. alpha:1.0];
    DESIGN_CHAT_COLOR = [UIColor colorWithRed:78/255. green:229./255. blue:184./255. alpha:1.0];
    DESIGN_BUTTON_RED_COLOR = [UIColor colorWithRed:253./255. green:96./255. blue:93./255. alpha:1.0];
    DESIGN_BUTTON_GREEN_COLOR = [UIColor colorWithRed:0./255. green:195./255. blue:194./255. alpha:1.0];
    DESIGN_ACTION_CALL_COLOR = [UIColor colorWithRed:24./255. green:26./255. blue:30./255. alpha:1.0];
    DESIGN_ACTION_IMAGE_CALL_COLOR = [UIColor colorWithRed:120./255. green:138./255. blue:149./255. alpha:1.0];
    DESIGN_CONVERSATION_BACKGROUND_COLOR = [UIColor blackColor];
    DESIGN_GREY_ITEM = [UIColor colorWithRed:72./255. green:72./255. blue:72./255. alpha:1];
    DESIGN_SEPARATOR_COLOR_GREY = [UIColor colorWithRed:199./255. green:199./255. blue:255./255. alpha:0.3];
    DESIGN_BACKGROUND_COLOR_GREY = [UIColor colorWithRed:72./255. green:72./255. blue:72./255. alpha:1];
    DESIGN_SPLASHSCREEN_LOGO_COLOR = [UIColor whiteColor];
    DESIGN_TEXTFIELD_BACKGROUND_COLOR = [UIColor colorWithRed:72./255. green:72./255. blue:72./255. alpha:1];
    DESIGN_TEXTFIELD_CONVERSATION_BACKGROUND_COLOR = [UIColor blackColor];
    DESIGN_PEER_AUDIO_TRACK_COLOR = [UIColor colorWithRed:199./255. green:199./255. blue:199./255. alpha:1];
    DESIGN_TIME_COLOR = [UIColor colorWithRed:110./255. green:110./255. blue:110./255. alpha:0.8];
    DESIGN_FORWARD_COMMENT_COLOR = [UIColor colorWithRed:72./255. green:72./255. blue:72./255. alpha:1];
    DESIGN_BACKGROUND_GREY_COLOR = [UIColor blackColor];
    DESIGN_MENU_BACKGROUND_COLOR = [UIColor colorWithRed:72./255. green:72./255. blue:72./255. alpha:1];
    DESIGN_MENU_REACTION_BACKGROUND_COLOR = [UIColor colorWithRed:72./255. green:72./255. blue:72./255. alpha:1];
    DESIGN_CUSTOM_TAB_BACKGROUND_COLOR = [UIColor colorWithRed:24./255. green:27./255. blue:34./255. alpha:1];
    
    if (@available(iOS 13.0, *)) {
        DESIGN_SEGMENTED_CONTROL_TINT_COLOR = [UIColor blackColor];
    } else {
        DESIGN_SEGMENTED_CONTROL_TINT_COLOR = [UIColor whiteColor];
    }
}

+ (void)setupLightColors {
    DDLogVerbose(@"%@ setupLightColors", LOG_TAG);
    
    DESIGN_WHITE_COLOR = [UIColor whiteColor];
    DESIGN_WHITE_COLOR_20_OPACITY = [UIColor colorWithWhite:1.0 alpha:0.2];
    DESIGN_BLACK_COLOR = [UIColor blackColor];
    DESIGN_FONT_COLOR_DEFAULT = [UIColor colorWithRed:44./255. green:44./255. blue:44./255. alpha:1];
    DESIGN_LIGHT_GREY_BACKGROUND_COLOR = [UIColor colorWithRed:249./255. green:249./255. blue:249./255. alpha:1];
    DESIGN_NAVIGATION_BACKGROUND_COLOR = [UIColor colorWithRed:0 green:174./255. blue:255./255. alpha:1];
    DESIGN_POPUP_BACKGROUND_COLOR = [UIColor whiteColor];
    DESIGN_BACKGROUND_COLOR_WHITE_OPACITY85 = [UIColor colorWithWhite:1 alpha:0.85];
    DESIGN_BACKGROUND_COLOR_WHITE_OPACITY36 = [UIColor colorWithWhite:1 alpha:0.36];
    DESIGN_BACKGROUND_COLOR_WHITE_OPACITY11 = [UIColor colorWithWhite:1 alpha:0.11];
    DESIGN_REPLY_BACKGROUND_COLOR = [UIColor colorWithRed:231./255. green:231./255. blue:231./255. alpha:1];
    DESIGN_REPLY_FONT_COLOR = [UIColor colorWithRed:121./255. green:121./255. blue:121./255. alpha:1];
    DESIGN_PLACEHOLDER_COLOR = [UIColor colorWithRed:195./255. green:196./255. blue:198./255. alpha:1];
    DESIGN_SWITCH_BORDER_COLOR = [UIColor colorWithRed:119./255. green:138./255. blue:159./255. alpha:1.0];
    DESIGN_AUDIO_CALL_COLOR = [UIColor colorWithRed:0/255. green:174./255. blue:255./255. alpha:1.0];
    DESIGN_VIDEO_CALL_COLOR = [UIColor colorWithRed:247./255. green:114./255. blue:114./255. alpha:1.0];
    DESIGN_CHAT_COLOR = [UIColor colorWithRed:78/255. green:229./255. blue:184./255. alpha:1.0];
    DESIGN_BUTTON_RED_COLOR = [UIColor colorWithRed:255./255. green:81./255. blue:85./255. alpha:1.0];
    DESIGN_BUTTON_GREEN_COLOR = [UIColor colorWithRed:49./255. green:230./255. blue:204./255. alpha:1.0];
    DESIGN_ACTION_CALL_COLOR = [UIColor whiteColor];
    DESIGN_ACTION_IMAGE_CALL_COLOR = [UIColor blackColor];
    DESIGN_CONVERSATION_BACKGROUND_COLOR = [UIColor whiteColor];
    DESIGN_GREY_ITEM = [UIColor colorWithRed:243./255. green:243./255. blue:243./255. alpha:1];
    DESIGN_SEPARATOR_COLOR_GREY = [UIColor colorWithRed:199./255. green:199./255. blue:204./255. alpha:1];
    DESIGN_BACKGROUND_COLOR_GREY = [UIColor colorWithRed:239./255. green:239./255. blue:239./255. alpha:1];
    DESIGN_SPLASHSCREEN_LOGO_COLOR = [UIColor colorWithRed:48./255. green:48./255. blue:48./255. alpha:1];
    DESIGN_TEXTFIELD_BACKGROUND_COLOR = [UIColor colorWithRed:213./255. green:215./255. blue:224./255. alpha:0.3];
    DESIGN_TEXTFIELD_CONVERSATION_BACKGROUND_COLOR = [UIColor colorWithRed:248./255. green:248./255. blue:248./255. alpha:1];
    DESIGN_PEER_AUDIO_TRACK_COLOR = [UIColor colorWithRed:51./255. green:51./255. blue:51./255. alpha:1];
    DESIGN_TIME_COLOR = [UIColor colorWithRed:110./255. green:110./255. blue:110./255. alpha:0.4];
    DESIGN_FORWARD_COMMENT_COLOR = [UIColor whiteColor];
    DESIGN_BACKGROUND_GREY_COLOR = [UIColor colorWithRed:239./255. green:239./255. blue:239./255. alpha:1.0];
    DESIGN_MENU_BACKGROUND_COLOR = [UIColor colorWithRed:249./255. green:249./255. blue:249./255. alpha:1];
    DESIGN_MENU_REACTION_BACKGROUND_COLOR = [UIColor blackColor];
    DESIGN_CUSTOM_TAB_BACKGROUND_COLOR = [UIColor whiteColor];
    
    if (@available(iOS 13.0, *)) {
        DESIGN_SEGMENTED_CONTROL_TINT_COLOR = [UIColor colorWithRed:118./255. green:118./255. blue:128./255. alpha:0.12];
    } else {
        DESIGN_SEGMENTED_CONTROL_TINT_COLOR = [UIColor whiteColor];
    }
}

+ (void)setupMainColors {
    DDLogVerbose(@"%@ setupMainColors", LOG_TAG);

    DESIGN_COLORS = [[NSMutableArray alloc]init];
    [DESIGN_COLORS addObject:[[UICustomColor alloc]initWithColor:nil]];
    [DESIGN_COLORS addObject:[[UICustomColor alloc]initWithColor:@"#4B90E2"]];
    [DESIGN_COLORS addObject:[[UICustomColor alloc]initWithColor:@"#F07675"]];
    [DESIGN_COLORS addObject:[[UICustomColor alloc]initWithColor:@"#9DEDB4"]];
    [DESIGN_COLORS addObject:[[UICustomColor alloc]initWithColor:@"#9DDBED"]];
    [DESIGN_COLORS addObject:[[UICustomColor alloc]initWithColor:@"#89AC8F"]];
    [DESIGN_COLORS addObject:[[UICustomColor alloc]initWithColor:@"#E99616"]];
    [DESIGN_COLORS addObject:[[UICustomColor alloc]initWithColor:@"#F0CB26"]];
    [DESIGN_COLORS addObject:[[UICustomColor alloc]initWithColor:@"#EBBDBF"]];
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

+ (CGFloat)MIN_RATIO {
    
    return DESIGN_MIN_RATIO;
}

+ (CGFloat)MAX_RATIO {
    
    return DESIGN_MAX_RATIO;
}

+ (UIColor *)BACKGROUND_COLOR_WHITE_OPACITY85 {
    
    return DESIGN_BACKGROUND_COLOR_WHITE_OPACITY85;
}

+ (UIColor *)BACKGROUND_COLOR_WHITE_OPACITY36 {
    
    return DESIGN_BACKGROUND_COLOR_WHITE_OPACITY36;
}

+ (UIColor *)BACKGROUND_COLOR_WHITE_OPACITY11 {
    
    return DESIGN_BACKGROUND_COLOR_WHITE_OPACITY11;
}

+ (UIColor *)BACKGROUND_COLOR_BLUE {
    
    return DESIGN_BACKGROUND_COLOR_BLUE;
}

+ (UIColor *)BACKGROUND_COLOR_GREY {
    
    return DESIGN_BACKGROUND_COLOR_GREY;
}

+ (UIColor *)FONT_COLOR_DEFAULT {
    
    return DESIGN_FONT_COLOR_DEFAULT;
}

+ (UIColor *)FONT_COLOR_GREY {
    
    return DESIGN_FONT_COLOR_GREY;
}

+ (UIColor *)FONT_COLOR_PROFILE_GREY {
    
    return DESIGN_FONT_COLOR_PROFILE_GREY;
}

+ (UIColor *)FONT_COLOR_GREEN {
    
    return DESIGN_FONT_COLOR_GREEN;
}

+ (UIColor *)FONT_COLOR_RED {
    
    return DESIGN_FONT_COLOR_RED;
}

+ (UIColor *)FONT_COLOR_BLUE {
    
    return DESIGN_FONT_COLOR_BLUE;
}

+ (UIColor *)DELETE_COLOR_RED {
    
    return DESIGN_DELETE_COLOR_RED;
}

+ (UIColor *)DELETE_BORDER_COLOR_RED {
    
    return DESIGN_DELETE_BORDER_COLOR_RED;
}

+ (UIColor *)BORDER_COLOR_GREY {
    
    return DESIGN_BORDER_COLOR_GREY;
}

+ (UIColor *)SEPARATOR_COLOR_GREY {
    
    return DESIGN_SEPARATOR_COLOR_GREY;
}

+ (UIColor *)FONT_COLOR_DESCRIPTION {
    
    return DESIGN_FONT_COLOR_DESCRIPTION;
}

+ (UIColor *)SHADOW_COLOR_DEFAULT {
    
    return DESIGN_SHADOW_COLOR_DEFAULT;
}

+ (UIColor *)WHITE_COLOR {
    
    return DESIGN_WHITE_COLOR;
}

+ (UIColor *)WHITE_COLOR_20_OPACITY {
    
    return DESIGN_WHITE_COLOR_20_OPACITY;
}

+ (UIColor *)BLACK_COLOR {
    
    return DESIGN_BLACK_COLOR;
}

+ (UIColor *)LIGHT_GREY_BACKGROUND_COLOR {
    
    return DESIGN_LIGHT_GREY_BACKGROUND_COLOR;
}

+ (UIColor *)NAVIGATION_BACKGROUND_COLOR {
    
    return DESIGN_NAVIGATION_BACKGROUND_COLOR;
}

+ (UIColor *)POPUP_BACKGROUND_COLOR {
    
    return DESIGN_POPUP_BACKGROUND_COLOR;
}

+ (UIColor *)SPLASHSCREEN_LOGO_COLOR {
    
    return DESIGN_SPLASHSCREEN_LOGO_COLOR;
}

+ (UIColor *)PLACEHOLDER_COLOR {
    
    return DESIGN_PLACEHOLDER_COLOR;
}

+ (UIColor *)SWITCH_BORDER_COLOR {
    
    return DESIGN_SWITCH_BORDER_COLOR;
}

+ (UIColor *)AUDIO_CALL_COLOR {
    
    return DESIGN_AUDIO_CALL_COLOR;
}

+ (UIColor *)VIDEO_CALL_COLOR {
    
    return DESIGN_VIDEO_CALL_COLOR;
}

+ (UIColor *)CHAT_COLOR {
    
    return DESIGN_CHAT_COLOR;
}

+ (UIColor *)BUTTON_RED_COLOR {
    
    return DESIGN_BUTTON_RED_COLOR;
}

+ (UIColor *)BUTTON_GREEN_COLOR {
    
    return DESIGN_BUTTON_GREEN_COLOR;
}

+ (UIColor *)ACTION_CALL_COLOR {
    
    return DESIGN_ACTION_CALL_COLOR;
}

+ (UIColor *)ACTION_IMAGE_CALL_COLOR {
    
    return DESIGN_ACTION_IMAGE_CALL_COLOR;
}

+ (UIColor *)EDIT_AVATAR_BACKGROUND_COLOR {
    
    return DESIGN_EDIT_AVATAR_BACKGROUND_COLOR;
}

+ (UIColor *)EDIT_AVATAR_IMAGE_COLOR {
    
    return DESIGN_EDIT_AVATAR_IMAGE_COLOR;
}

+ (UIColor *)CONVERSATION_BACKGROUND_COLOR {
    
    return DESIGN_CONVERSATION_BACKGROUND_COLOR;
}

+ (UIColor *)TEXTFIELD_CONVERSATION_BACKGROUND_COLOR {
    
    return DESIGN_TEXTFIELD_CONVERSATION_BACKGROUND_COLOR;
}

+ (UIColor *)TEXTFIELD_BACKGROUND_COLOR {
    
    return DESIGN_TEXTFIELD_BACKGROUND_COLOR;
}

+ (UIColor *)TEXTFIELD_POPUP_BACKGROUND_COLOR {
    
    return DESIGN_TEXTFIELD_POPUP_BACKGROUND_COLOR;
}

+ (UIColor *)NAVIGATION_BAR_BACKGROUND_COLOR {
    
    UIColor *backgroundColor = Design.MAIN_COLOR;
    
    ApplicationDelegate *delegate = (ApplicationDelegate *)[[UIApplication sharedApplication] delegate];
    TwinmeApplication *twinmeApplication = [delegate twinmeApplication];
    
    switch (twinmeApplication.displayMode) {
        case DisplayModeSystem:
            if (@available(iOS 13.0, *) ) {
                if ([UIScreen mainScreen].traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark){
                    backgroundColor = DESIGN_NAVIGATION_BACKGROUND_COLOR;
                }
            }
            break;
            
        case DisplayModeDark:
            backgroundColor = DESIGN_NAVIGATION_BACKGROUND_COLOR;
            break;
            
        default:
            break;
    }
    
    
    
    return backgroundColor;
}

+ (UIColor *)ITEM_BORDER_COLOR {
    
    return DESIGN_ITEM_BORDER_COLOR;
}

+ (UIColor *)ACCESSORY_COLOR {
    
    return DESIGN_ACCESSORY_COLOR;
}

+ (UIColor *)REPLY_FONT_COLOR {
    
    return DESIGN_REPLY_FONT_COLOR;
}

+ (UIColor *)REPLY_BACKGROUND_COLOR {
    
    return DESIGN_REPLY_BACKGROUND_COLOR;
}

+ (UIColor *)FORWARD_ITEM_COLOR {
    
    return DESIGN_FORWARD_ITEM_COLOR;
}

+ (UIColor *)FORWARD_BORDER_COLOR {
    
    return DESIGN_FORWARD_BORDER_COLOR;
}

+ (UIColor *)FORWARD_COMMENT_COLOR {
    
    return DESIGN_FORWARD_COMMENT_COLOR;
}

+ (UIColor *)OVERLAY_COLOR {
    
    return DESIGN_OVERLAY_COLOR;
}

+ (UIColor *)AUDIO_TRACK_COLOR {
    
    return DESIGN_AUDIO_TRACK_COLOR;
}

+ (UIColor *)PEER_AUDIO_TRACK_COLOR {
    
    return DESIGN_PEER_AUDIO_TRACK_COLOR;
}

+ (UIColor *)UNSELECTED_TAB_COLOR {
    
    return DESIGN_UNSELECTED_TAB_COLOR;
}

+ (UIColor *)TIME_COLOR {
    
    return DESIGN_TIME_COLOR;
}

+ (UIColor *)CUSTOM_TAB_BACKGROUND_COLOR {
    
    return DESIGN_CUSTOM_TAB_BACKGROUND_COLOR;
}

+ (UIColor *)SEGMENTED_CONTROL_TINT_COLOR {
    
    return DESIGN_SEGMENTED_CONTROL_TINT_COLOR;
}

+ (UIColor *)CHECKMARK_BORDER_COLOR {
    
    return DESIGN_CHECKMARK_BORDER_COLOR;
}

+ (UIColor *)GREY_BACKGROUND_COLOR {
    
    return DESIGN_BACKGROUND_GREY_COLOR;
}

+ (UIColor *)MENU_BACKGROUND_COLOR {
    
    return DESIGN_MENU_BACKGROUND_COLOR;
}

+ (UIColor *)MENU_REACTION_BACKGROUND_COLOR {
    
    return DESIGN_MENU_REACTION_BACKGROUND_COLOR;
}

+ (UIColor *)ACTION_BORDER_COLOR {
    
    return DESIGN_ACTION_BORDER_COLOR;
}

+ (UIColor *)ZOOM_COLOR {
    
    return DESIGN_ZOOM_COLOR;
}

+ (NSArray *)BACKGROUND_GRADIENT_COLORS_BLACK {
    
    return DESIGN_BACKGROUND_GRADIENT_COLORS_BLACK;
}

+ (NSMutableArray *)COLORS {
    
    for (UICustomColor *customColor in DESIGN_COLORS) {
        customColor.selectedColor = NO;
    }
    
    return DESIGN_COLORS;
}

+ (UIColor *)MAIN_COLOR {
    
    NSString *color = mainStyleConfig.stringValue;
    if (color) {
        return [UIColor colorWithHexString:color alpha:1.0];
    } else {
        return [UIColor colorWithHexString:DEFAULT_COLOR alpha:1.0];
    }
}

+ (NSString *)MAIN_STYLE {
    
    NSString *color = mainStyleConfig.stringValue;

    if (color) {
        return color;
    } else {
        return DEFAULT_COLOR;
    }
}

+ (NSString *)DEFAULT_COLOR {
    
    return DEFAULT_COLOR;
}

+ (void)setMainColor:(NSString *)mainColor {
    
    if (!mainColor || [mainColor isEqualToString:@""]) {
        [mainStyleConfig remove];
    } else {
        mainStyleConfig.stringValue = mainColor;
    }
}

+ (UIFont *)FONT_REGULAR16 {
    
    return DESIGN_REGULAR16;
}

+ (UIFont *)FONT_REGULAR20 {
    
    return DESIGN_REGULAR20;
}

+ (UIFont *)FONT_REGULAR22 {
    
    return DESIGN_REGULAR22;
}

+ (UIFont *)FONT_REGULAR24 {
    
    return DESIGN_REGULAR24;
}

+ (UIFont *)FONT_REGULAR26 {
    
    return DESIGN_REGULAR26;
}

+ (UIFont *)FONT_REGULAR28 {
    
    return DESIGN_REGULAR28;
}

+ (UIFont *)FONT_REGULAR30 {
    
    return DESIGN_REGULAR30;
}

+ (UIFont *)FONT_REGULAR32 {
    
    return DESIGN_REGULAR32;
}

+ (UIFont *)FONT_REGULAR34 {
    
    return DESIGN_REGULAR34;
}

+ (UIFont *)FONT_REGULAR36 {
    
    return DESIGN_REGULAR36;
}

+ (UIFont *)FONT_REGULAR40 {
    
    return DESIGN_REGULAR40;
}

+ (UIFont *)FONT_REGULAR44 {
    
    return DESIGN_REGULAR44;
}

+ (UIFont *)FONT_REGULAR50 {
    
    return DESIGN_REGULAR50;
}

+ (UIFont *)FONT_REGULAR58 {
    
    return DESIGN_REGULAR58;
}

+ (UIFont *)FONT_REGULAR64 {
    
    return DESIGN_REGULAR64;
}

+ (UIFont *)FONT_REGULAR68 {
    
    return DESIGN_REGULAR68;
}

+ (UIFont *)FONT_MEDIUM16 {
    
    return DESIGN_MEDIUM16;
}

+ (UIFont *)FONT_MEDIUM20 {
    
    return DESIGN_MEDIUM20;
}

+ (UIFont *)FONT_MEDIUM24 {
    
    return DESIGN_MEDIUM24;
}

+ (UIFont *)FONT_MEDIUM26 {
    
    return DESIGN_MEDIUM26;
}

+ (UIFont *)FONT_MEDIUM28 {
    
    return DESIGN_MEDIUM28;
}

+ (UIFont *)FONT_MEDIUM30 {
    
    return DESIGN_MEDIUM30;
}

+ (UIFont *)FONT_MEDIUM32 {
    
    return DESIGN_MEDIUM32;
}

+ (UIFont *)FONT_MEDIUM34 {
    
    return DESIGN_MEDIUM34;
}

+ (UIFont *)FONT_MEDIUM36 {
    
    return DESIGN_MEDIUM36;
}

+ (UIFont *)FONT_MEDIUM38 {
    
    return DESIGN_MEDIUM38;
}

+ (UIFont *)FONT_MEDIUM40 {
    
    return DESIGN_MEDIUM40;
}

+ (UIFont *)FONT_MEDIUM42 {
    
    return DESIGN_MEDIUM42;
}

+ (UIFont *)FONT_MEDIUM44 {
    
    return DESIGN_MEDIUM44;
}

+ (UIFont *)FONT_MEDIUM54 {
    
    return DESIGN_MEDIUM54;
}

+ (UIFont *)FONT_MEDIUM_ITALIC28 {
    
    return DESIGN_MEDIUM_ITALIC28;
}

+ (UIFont *)FONT_MEDIUM_ITALIC36 {
    
    return DESIGN_MEDIUM_ITALIC36;
}

+ (UIFont *)FONT_MEDIUM_ITALIC40 {
    
    return DESIGN_MEDIUM_ITALIC40;
}

+ (UIFont *)FONT_BOLD20 {
    
    return DESIGN_BOLD20;
}

+ (UIFont *)FONT_BOLD26 {
    
    return DESIGN_BOLD26;
}

+ (UIFont *)FONT_BOLD28 {
    
    return DESIGN_BOLD28;
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

+ (UIFont *)FONT_BOLD88 {
    
    return DESIGN_BOLD88;
}

+ (void)scaleEdgeInsetVertically:(UIButton *)button {
    
    float width = button.frame.size.width;
    float top = button.imageEdgeInsets.top;
    float bottom = button.imageEdgeInsets.bottom;
    float left = button.imageEdgeInsets.left;
    float right = button.imageEdgeInsets.right;
    float imageWidth = width - left - right;
    float scaledWidth = width * DESIGN_WIDTH_RATIO;
    float scaledImageWidth = imageWidth * DESIGN_HEIGHT_RATIO;
    float scaledTop = top * DESIGN_HEIGHT_RATIO;
    float scaledBottom = bottom * DESIGN_HEIGHT_RATIO;
    float scaledLeft = left / (left + right) * (scaledWidth - scaledImageWidth);
    float scaledRight = right / (left + right) * (scaledWidth - scaledImageWidth);
    button.imageEdgeInsets = UIEdgeInsetsMake(scaledTop, scaledLeft, scaledBottom, scaledRight);
}

+ (void)scaleEdgeInsetHorizontally:(UIButton *)button {
    
    float height = button.frame.size.height;
    float top = button.imageEdgeInsets.top;
    float bottom = button.imageEdgeInsets.bottom;
    float left = button.imageEdgeInsets.left;
    float right = button.imageEdgeInsets.right;
    float imageHeight = height - top - bottom;
    float scaledHeight = height * DESIGN_HEIGHT_RATIO;
    float scaledImageHeight = imageHeight * DESIGN_WIDTH_RATIO;
    float scaledTop = top / (top + bottom) * (scaledHeight - scaledImageHeight);
    float scaledBottom = bottom / (top + bottom) * (scaledHeight - scaledImageHeight);
    float scaledLeft = left * DESIGN_WIDTH_RATIO;
    float scaledRight = right * DESIGN_WIDTH_RATIO;
    button.imageEdgeInsets = UIEdgeInsetsMake(scaledTop, scaledLeft, scaledBottom, scaledRight);
}
//
// To be reviewed
//

+ (UIColor *)BLUE_NORMAL {
    
    return DESIGN_BLUE_NORMAL;
}

+ (UIColor *)GREY_ITEM {
    
    return DESIGN_GREY_ITEM;
}

+ (float)SHADOW_OPACITY {
    
    return DESIGN_SHADOW_OPACITY;
}

+ (CGSize)SHADOW_OFFSET {
    
    return DESIGN_SHADOW_OFFSET;
}

+ (CGFloat)SHADOW_RADIUS {
    
    return DESIGN_SHADOW_RADIUS;
}

+ (CGSize)switchSize {
    
    return CGSizeMake(DESIGN_SWITCH_WIDTH, DESIGN_SWITCH_HEIGHT);
}

//
// Unicode Character
//

+ (NSString *)PLUS_SIGN {
    
    return @"\uff0b";
}

//
// Size
//

+ (CGFloat)SEPARATOR_HEIGHT {
    
    return DESIGN_SEPARATOR_HEIGHT;
}

+ (CGFloat)ITEM_BORDER_WIDTH {
    
    return DESIGN_BORDER_WIDTH;
}

+ (CGFloat)AVATAR_HEIGHT {
    
    return DESIGN_AVATAR_HEIGHT;
}

+ (CGFloat)AVATAR_LEADING {
    
    return DESIGN_AVATAR_LEADING;
}

+ (CGFloat)NAME_TRAILING {
    
    return DESIGN_NAME_TRAILING;
}

+ (CGFloat)ACCESSORY_HEIGHT {
    
    return DESIGN_ACCESSORY_HEIGHT;
}

+ (CGFloat)CERTIFIED_HEIGHT {
    
    return DESIGN_CERTIFIED_HEIGHT;
}

+ (CGFloat)CELL_HEIGHT {
    
    return round(DESIGN_CELL_HEIGHT);
}

+ (CGFloat)DESCRIPTION_HEIGHT {
    
    return round(DESIGN_DESCRIPTION_HEIGHT);
}

+ (CGFloat)SETTING_CELL_HEIGHT {
    
    return round(DESIGN_SETTING_CELL_HEIGHT);
}

+ (CGFloat)SETTING_SECTION_HEIGHT {
    
    return round(DESIGN_SETTING_SECTION_HEIGHT);
}

+ (CGFloat)INVITATION_LINE_SPACING {
    
    return round(DESIGN_INVITATION_LINE_SPACING);
}

+ (CGFloat)STANDARD_NAVIGATION_BAR_HEIGHT {
    
    UINavigationController *navigationController = [[UINavigationController alloc]init];
    CGFloat navigationBarHeight = navigationController.navigationBar.frame.size.height;
    navigationController = nil;
    return navigationBarHeight;
}

+ (CGFloat)TEXT_WIDTH_PADDING {
    
    return DESIGN_TEXT_WIDTH_PADDING;
}

+ (CGFloat)TEXT_HEIGHT_PADDING {
    
    return DESIGN_TEXT_HEIGHT_PADDING;
}

+ (CGFloat)MESSAGE_CELL_MAX_WIDTH {
    
    return DESIGN_MESSAGE_CELL_MAX_WIDTH;
}

+ (CGFloat)PEER_MESSAGE_CELL_MAX_WIDTH {
    
    return DESIGN_PEER_MESSAGE_CELL_MAX_WIDTH;
}

+ (CGFloat)REPLY_IMAGE_MAX_WIDTH {
    
    return DESIGN_REPLY_IMAGE_MAX_WIDTH;
}

+ (CGFloat)REPLY_IMAGE_MAX_HEIGHT {
    
    return DESIGN_REPLY_IMAGE_MAX_HEIGHT;
}

+ (CGFloat)REPLY_VIEW_IMAGE_TOP {
    
    return DESIGN_REPLY_VIEW_IMAGE_TOP;
}

+ (CGFloat)SWIPE_WIDTH_TO_REPLY {
    
    return DESIGN_SWIPE_WIDTH_TO_REPLY;
}

+ (CGFloat)CHECKMARK_BORDER_WIDTH {
    
    return DESIGN_CHECKMARK_BORDER_WIDTH;
}

+ (CGFloat)IMAGE_CELL_MAX_WIDTH {
    
    return DESIGN_IMAGE_CELL_MAX_WIDTH;
}

+ (CGFloat)IMAGE_CELL_MAX_HEIGHT {
    
    return DESIGN_IMAGE_CELL_MAX_HEIGHT;
}

+ (CGFloat)FORWARDED_IMAGE_CELL_MAX_HEIGHT {
    
    return DESIGN_FORWARDED_IMAGE_CELL_MAX_HEIGHT;
}

+ (CGFloat)FORWARDED_SMALL_IMAGE_CELL_MAX_HEIGHT {
    
    return DESIGN_FORWARDED_SMALL_IMAGE_CELL_MAX_HEIGHT;
}

+ (CGFloat)ANNOTATION_CELL_WIDTH_NORMAL {
    
    return DESIGN_ANNOTATION_CELL_WIDTH_NORMAL;
}

+ (CGFloat)ANNOTATION_CELL_WIDTH_LARGE {
    
    return DESIGN_ANNOTATION_CELL_WIDTH_LARGE;
}

+ (CGFloat)BUTTON_PADDING {
    
    return DESIGN_BUTTON_PADDING;
}

+ (CGFloat)PROGRESS_VIEW_SCALE {
    
    UIProgressView *progressView = [[UIProgressView alloc]init];
    return DESIGN_PROGESS_VIEW_HEIGHT / progressView.frame.size.height;
}

//
// Radius
//

+ (CGFloat)CONTAINER_RADIUS {
    
    return DESIGN_CONTAINER_RADIUS;
}

+ (CGFloat)POPUP_RADIUS {
    
    return DESIGN_POPUP_RADIUS;
}

//
// Emoji
//

+ (CFMutableCharacterSetRef)EMOJI_CHARACTER_SET {
    
    if (!DESIGN_EMOJI_CHARACTER_SET) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            DESIGN_EMOJI_CHARACTER_SET = CFCharacterSetCreateMutableCopy(kCFAllocatorDefault, CTFontCopyCharacterSet(CTFontCreateWithName(CFSTR("AppleColorEmoji"), 0.0, NULL)));
            CFCharacterSetRemoveCharactersInString(DESIGN_EMOJI_CHARACTER_SET, CFSTR(" 0123456789#*"));
        });
    }
    
    return DESIGN_EMOJI_CHARACTER_SET;
}

+ (UIFont *)getEmojiFont:(int)nbEmoji {
    
    if (nbEmoji == 1) {
        return DESIGN_FONT_EMOJI_EXTRA_EXTRA_LARGE;
    } else if (nbEmoji == 2) {
        return DESIGN_FONT_EMOJI_EXTRA_LARGE;
    } else if (nbEmoji == 3) {
        return DESIGN_FONT_EMOJI_LARGE;
    } else if (nbEmoji == 4) {
        return DESIGN_FONT_EMOJI_MEDIUM;
    }
    
    return DESIGN_FONT_EMOJI_SMALL;
}

+ (UIFont *)getSampleEmojiFont:(EmojiSize)emojiSize {
    
    float adjustFontSize = [Design getAdjustFontSize];
    
    if (emojiSize == EmojiSizeSmall) {
        return [UIFont systemFontOfSize:(100 * DESIGN_FONT_RATIO) + adjustFontSize weight:UIFontWeightBold];
    } else if (emojiSize == EmojiSizeStandard) {
        return [UIFont systemFontOfSize:(120 * DESIGN_FONT_RATIO) + adjustFontSize weight:UIFontWeightBold];
    } else {
        return [UIFont systemFontOfSize:(140 * DESIGN_FONT_RATIO) + adjustFontSize weight:UIFontWeightBold];
    }
}

//
// Animation show / close view like AbstractConfimeView
//

+ (CGFloat)ANIMATION_VIEW_DURATION {
    
    return DESIGN_ANIMATION_VIEW_DURATION;
}

@end
