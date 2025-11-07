/*
 *  Copyright (c) 2020-2021 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "CustomAppearance.h"

#import <Twinme/TLSpace.h>

#import <TwinmeCommon/Design.h>
#import "UIColor+Hex.h"
#import "SpaceSetting.h"

@interface CustomAppearance ()

@property (nonatomic) TLSpaceSettings *spaceSettings;

@property (nonatomic) DisplayMode displayMode;
@property (nonatomic) UIColor *messageBackgroundColor;

@end

//
// Implementation: CustomAppearance
//

@implementation CustomAppearance : NSObject

- (instancetype)init {
    
    self = [super init];
    
    if (self) {
        _spaceSettings = [[TLSpaceSettings alloc] init];
        _displayMode = DisplayModeLight;
        _messageBackgroundColor = Design.ITEM_BACKGROUND_COLOR;
    }
    
    return self;
}

- (instancetype)initWithSpaceSettings:(TLSpaceSettings *)spaceSettings {
    
    self = [super init];
    
    if (self) {
        _spaceSettings = spaceSettings;
        [self setCurrentMode:[[self.spaceSettings getStringWithName:PROPERTY_DISPLAY_MODE defaultValue:[NSString stringWithFormat:@"%d",DisplayModeSystem]]intValue]];
        _messageBackgroundColor = Design.ITEM_BACKGROUND_COLOR;
    }
    return self;
}

- (TLSpaceSettings *)getSpaceSettings {
    
    return self.spaceSettings;
}

- (DisplayMode)getCurrentMode {
    
    return self.displayMode;
}

- (UIColor *)getMainColor {
    
    if (self.spaceSettings.style) {
        return [UIColor colorWithHexString:self.spaceSettings.style alpha:1.0];
    }
    
    return [UIColor colorWithHexString:Design.DEFAULT_COLOR alpha:1.0];
}

- (UIColor *)getConversationBackgroundColor {
    
    if (self.displayMode == DisplayModeLight) {
        return [self.spaceSettings getColorWithName:PROPERTY_CONVERSATION_BACKGROUND_COLOR defaultValue:Design.CONVERSATION_BACKGROUND_COLOR];
    }
    
    return [self.spaceSettings getColorWithName:PROPERTY_DARK_CONVERSATION_BACKGROUND_COLOR defaultValue:[UIColor blackColor]];
}

- (UIColor *)getConversationBackgroundDefaultColor {
    
    if (self.displayMode == DisplayModeLight) {
        return Design.CONVERSATION_BACKGROUND_COLOR;
    }
    
    return [UIColor blackColor];
}

- (NSUUID *)getConversationBackgroundImageId {
    
    if (self.displayMode == DisplayModeLight) {
        return [self.spaceSettings getUUIDWithName:PROPERTY_CONVERSATION_BACKGROUND_IMAGE];
    }
    
    return [self.spaceSettings getUUIDWithName:PROPERTY_DARK_CONVERSATION_BACKGROUND_IMAGE];
}

- (NSUUID *)getConversationBackgroundImageId:(DisplayMode)mode {
    
    if (mode == DisplayModeLight) {
        return [self.spaceSettings getUUIDWithName:PROPERTY_CONVERSATION_BACKGROUND_IMAGE];
    }
    
    return [self.spaceSettings getUUIDWithName:PROPERTY_DARK_CONVERSATION_BACKGROUND_IMAGE];
}

- (UIColor *)getConversationBackgroundText {
    
    if (self.displayMode == DisplayModeLight) {
        return [self.spaceSettings getColorWithName:PROPERTY_CONVERSATION_BACKGROUND_TEXT defaultValue:Design.TIME_COLOR];
    }
    
    return [self.spaceSettings getColorWithName:PROPERTY_DARK_CONVERSATION_BACKGROUND_TEXT defaultValue:Design.TIME_COLOR];
}

- (UIColor *)getConversationBackgroundTextDefaultColor {
    
    return Design.TIME_COLOR;
}

- (UIColor *)getMessageBackgroundColor {
    
    if (self.displayMode == DisplayModeLight) {
        return [self.spaceSettings getColorWithName:PROPERTY_MESSAGE_BACKGROUND_COLOR defaultValue:self.messageBackgroundColor];
    }
    
    return [self.spaceSettings getColorWithName:PROPERTY_DARK_MESSAGE_BACKGROUND_COLOR defaultValue:self.messageBackgroundColor];
}

- (UIColor *)getMessageBackgroundDefaultColor {
    
    return self.messageBackgroundColor;
}

- (UIColor *)getPeerMessageBackgroundColor {
    
    if (self.displayMode == DisplayModeLight) {
        return [self.spaceSettings getColorWithName:PROPERTY_PEER_MESSAGE_BACKGROUND_COLOR defaultValue:[UIColor whiteColor]];
    }
    
    return [self.spaceSettings getColorWithName:PROPERTY_DARK_PEER_MESSAGE_BACKGROUND_COLOR defaultValue:[UIColor colorWithRed:72./255. green:72./255. blue:72./255. alpha:1]];
}

- (UIColor *)getPeerMessageBackgroundDefaultColor {
    
    if (self.displayMode == DisplayModeLight) {
        return [UIColor whiteColor];
    }
    
    return [UIColor colorWithRed:72./255. green:72./255. blue:72./255. alpha:1];
}

- (UIColor *)getMessageBorderColor {
    
    if (self.displayMode == DisplayModeLight) {
        return [self.spaceSettings getColorWithName:PROPERTY_MESSAGE_BORDER_COLOR defaultValue:[UIColor clearColor]];
    }
    
    return [self.spaceSettings getColorWithName:PROPERTY_DARK_MESSAGE_BORDER_COLOR defaultValue:[UIColor clearColor]];
}

- (UIColor *)getMessageBorderDefaultColor {
    
    return [UIColor clearColor];
}

- (UIColor *)getPeerMessageBorderColor {
    
    if (self.displayMode == DisplayModeLight) {
        return [self.spaceSettings getColorWithName:PROPERTY_PEER_MESSAGE_BORDER_COLOR defaultValue:[UIColor clearColor]];
    }
    
    return [self.spaceSettings getColorWithName:PROPERTY_DARK_PEER_MESSAGE_BORDER_COLOR defaultValue:[UIColor clearColor]];
}

- (UIColor *)getPeerMessageBorderDefaultColor {
    
    return [UIColor clearColor];
}

- (UIColor *)getMessageTextColor {
    
    if (self.displayMode == DisplayModeLight) {
        return [self.spaceSettings getColorWithName:PROPERTY_MESSAGE_TEXT_COLOR defaultValue:[UIColor whiteColor]];
    }
    
    return [self.spaceSettings getColorWithName:PROPERTY_DARK_MESSAGE_TEXT_COLOR defaultValue:[UIColor whiteColor]];
}

- (UIColor *)getMessageTextDefaultColor {
    
    return [UIColor whiteColor];
}

- (UIColor *)getPeerMessageTextColor {
    
    if (self.displayMode == DisplayModeLight) {
        return [self.spaceSettings getColorWithName:PROPERTY_PEER_MESSAGE_TEXT_COLOR defaultValue:[UIColor blackColor]];
    }
    
    return [self.spaceSettings getColorWithName:PROPERTY_DARK_PEER_MESSAGE_TEXT_COLOR defaultValue:[UIColor whiteColor]];
}

- (UIColor *)getPeerMessageTextDefaultColor {
    
    if (self.displayMode == DisplayModeLight) {
        return [UIColor blackColor];
    }
    
    return [UIColor whiteColor];
}

- (void)setCurrentMode:(DisplayMode)mode {
    
    if (mode == DisplayModeSystem) {
        if (@available(iOS 13.0, *)) {
            if ([UIScreen mainScreen].traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark){
                mode = DisplayModeDark;
            } else {
                mode = DisplayModeLight;
            }
        } else {
            mode = DisplayModeLight;
        }
    }
    
    self.displayMode = mode;
}

- (void)setMainColor:(NSString *)color {
    
    self.spaceSettings.style = color;
}

- (void)setDefaultMessageBackgroundColor:(UIColor *)color {
    
    self.messageBackgroundColor = color;
}

- (void)setConversationBackgroundColor:(UIColor *)color {
    
    if (!color) {
        color = Design.CONVERSATION_BACKGROUND_COLOR;
    }
    
    if (self.displayMode == DisplayModeLight) {
        [self.spaceSettings setColorWithName:PROPERTY_CONVERSATION_BACKGROUND_COLOR value:color];
    } else {
        [self.spaceSettings setColorWithName:PROPERTY_DARK_CONVERSATION_BACKGROUND_COLOR value:color];
    }
}

- (void)setConversationBackgroundImageId:(NSUUID *)imageId {
    
    if (self.displayMode == DisplayModeLight) {
        [self.spaceSettings setUUIDWithName:PROPERTY_CONVERSATION_BACKGROUND_IMAGE value:imageId];
    } else {
        [self.spaceSettings setUUIDWithName:PROPERTY_DARK_CONVERSATION_BACKGROUND_IMAGE value:imageId];
    }
}

- (void)setConversationBackgroundText:(UIColor *)color {
    
    if (!color) {
        if (self.displayMode == DisplayModeLight) {
            [self.spaceSettings removeWithName:PROPERTY_CONVERSATION_BACKGROUND_TEXT];
        } else {
            [self.spaceSettings removeWithName:PROPERTY_DARK_CONVERSATION_BACKGROUND_TEXT];
        }
        return;
    }
    
    if (self.displayMode == DisplayModeLight) {
        [self.spaceSettings setColorWithName:PROPERTY_CONVERSATION_BACKGROUND_TEXT value:color];
    } else {
        [self.spaceSettings setColorWithName:PROPERTY_DARK_CONVERSATION_BACKGROUND_TEXT value:color];
    }
}

- (void)setMessageBackgroundColor:(UIColor *)color {
    
    if (!color) {
        if (self.displayMode == DisplayModeLight) {
            [self.spaceSettings removeWithName:PROPERTY_MESSAGE_BACKGROUND_COLOR];
        } else {
            [self.spaceSettings removeWithName:PROPERTY_DARK_MESSAGE_BACKGROUND_COLOR];
        }
        return;
    }
    
    if (self.displayMode == DisplayModeLight) {
        [self.spaceSettings setColorWithName:PROPERTY_MESSAGE_BACKGROUND_COLOR value:color];
    } else {
        [self.spaceSettings setColorWithName:PROPERTY_DARK_MESSAGE_BACKGROUND_COLOR value:color];
    }
}

- (void)setPeerMessageBackgroundColor:(UIColor *)color {
    
    if (!color) {
        if (self.displayMode == DisplayModeLight) {
            [self.spaceSettings removeWithName:PROPERTY_PEER_MESSAGE_BACKGROUND_COLOR];
        } else {
            [self.spaceSettings removeWithName:PROPERTY_DARK_PEER_MESSAGE_BACKGROUND_COLOR];
        }
        return;
    }
    
    if (self.displayMode == DisplayModeLight) {
        [self.spaceSettings setColorWithName:PROPERTY_PEER_MESSAGE_BACKGROUND_COLOR value:color];
    } else {
        [self.spaceSettings setColorWithName:PROPERTY_DARK_PEER_MESSAGE_BACKGROUND_COLOR value:color];
    }
}

- (void)setMessageBorderColor:(UIColor *)color {
    
    if (!color) {
        if (self.displayMode == DisplayModeLight) {
            [self.spaceSettings removeWithName:PROPERTY_MESSAGE_BORDER_COLOR];
        } else {
            [self.spaceSettings removeWithName:PROPERTY_DARK_MESSAGE_BORDER_COLOR];
        }
        return;
    }
    
    if (self.displayMode == DisplayModeLight) {
        [self.spaceSettings setColorWithName:PROPERTY_MESSAGE_BORDER_COLOR value:color];
    } else {
        [self.spaceSettings setColorWithName:PROPERTY_DARK_MESSAGE_BORDER_COLOR value:color];
    }
}

- (void)setPeerMessageBorderColor:(UIColor *)color {
    
    if (!color) {
        if (self.displayMode == DisplayModeLight) {
            [self.spaceSettings removeWithName:PROPERTY_PEER_MESSAGE_BORDER_COLOR];
        } else {
            [self.spaceSettings removeWithName:PROPERTY_DARK_PEER_MESSAGE_BORDER_COLOR];
        }
        return;
    }
    
    if (self.displayMode == DisplayModeLight) {
        [self.spaceSettings setColorWithName:PROPERTY_PEER_MESSAGE_BORDER_COLOR value:color];
    } else {
        [self.spaceSettings setColorWithName:PROPERTY_DARK_PEER_MESSAGE_BORDER_COLOR value:color];
    }
}

- (void)setMessageTextColor:(UIColor *)color {
    
    if (!color) {
        if (self.displayMode == DisplayModeLight) {
            [self.spaceSettings removeWithName:PROPERTY_MESSAGE_TEXT_COLOR];
        } else {
            [self.spaceSettings removeWithName:PROPERTY_DARK_MESSAGE_TEXT_COLOR];
        }
        return;
    }
    
    if (self.displayMode == DisplayModeLight) {
        [self.spaceSettings setColorWithName:PROPERTY_MESSAGE_TEXT_COLOR value:color];
    } else {
        [self.spaceSettings setColorWithName:PROPERTY_DARK_MESSAGE_TEXT_COLOR value:color];
    }
}

- (void)setPeerMessageTextColor:(UIColor *)color {
    
    if (!color) {
        if (self.displayMode == DisplayModeLight) {
            [self.spaceSettings removeWithName:PROPERTY_PEER_MESSAGE_TEXT_COLOR];
        } else {
            [self.spaceSettings removeWithName:PROPERTY_DARK_PEER_MESSAGE_TEXT_COLOR];
        }
        return;
    }
    
    if (self.displayMode == DisplayModeLight) {
        [self.spaceSettings setColorWithName:PROPERTY_PEER_MESSAGE_TEXT_COLOR value:color];
    } else {
        [self.spaceSettings setColorWithName:PROPERTY_DARK_PEER_MESSAGE_TEXT_COLOR value:color];
    }
}

- (void)resetToDefaultValues {
    
    [self setMainColor:Design.DEFAULT_COLOR];
    [self setDefaultMessageBackgroundColor:Design.ITEM_BACKGROUND_COLOR];
    
    [self.spaceSettings removeWithName:PROPERTY_CONVERSATION_BACKGROUND_COLOR];
    [self.spaceSettings removeWithName:PROPERTY_CONVERSATION_BACKGROUND_IMAGE];
    [self.spaceSettings removeWithName:PROPERTY_CONVERSATION_BACKGROUND_TEXT];
    [self.spaceSettings removeWithName:PROPERTY_MESSAGE_BACKGROUND_COLOR];
    [self.spaceSettings removeWithName:PROPERTY_PEER_MESSAGE_BACKGROUND_COLOR];
    [self.spaceSettings removeWithName:PROPERTY_MESSAGE_BORDER_COLOR];
    [self.spaceSettings removeWithName:PROPERTY_PEER_MESSAGE_BORDER_COLOR];
    [self.spaceSettings removeWithName:PROPERTY_MESSAGE_TEXT_COLOR];
    [self.spaceSettings removeWithName:PROPERTY_PEER_MESSAGE_TEXT_COLOR];
    [self.spaceSettings removeWithName:PROPERTY_DARK_CONVERSATION_BACKGROUND_COLOR];
    [self.spaceSettings removeWithName:PROPERTY_DARK_CONVERSATION_BACKGROUND_IMAGE];
    [self.spaceSettings removeWithName:PROPERTY_DARK_CONVERSATION_BACKGROUND_TEXT];
    [self.spaceSettings removeWithName:PROPERTY_DARK_MESSAGE_BACKGROUND_COLOR];
    [self.spaceSettings removeWithName:PROPERTY_DARK_PEER_MESSAGE_BACKGROUND_COLOR];
    [self.spaceSettings removeWithName:PROPERTY_DARK_MESSAGE_BORDER_COLOR];
    [self.spaceSettings removeWithName:PROPERTY_DARK_PEER_MESSAGE_BORDER_COLOR];
    [self.spaceSettings removeWithName:PROPERTY_DARK_MESSAGE_TEXT_COLOR];
    [self.spaceSettings removeWithName:PROPERTY_DARK_PEER_MESSAGE_TEXT_COLOR];
}

- (UIImage *)createImageWithColor:(UIColor *)color {
    
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
