/*
 *  Copyright (c) 2022 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "AbstractMenuView.h"

@class UITimeout;

typedef enum {
    MenuSelectValueTypeImageSize,
    MenuSelectValueTypeVideoSize,
    MenuSelectValueTypeDisplayCallsMode,
    MenuSelectValueTypeEditSpace,
    MenuSelectValueTypeProfileUpdateMode,
    MenuSelectValueTypeTimeoutEphemeralMessage,
    MenuSelectValueTypeTimeoutLockScreen,
    MenuSelectValueTypeCallZoomable
} MenuSelectValueType;

//
// Protocol: MenuSelectValueDelegate
//

@class MenuSelectValueView;

@protocol MenuSelectValueDelegate <NSObject>

- (void)cancelMenuSelectValue:(MenuSelectValueView *)menuSelectValueView;

@optional - (void)selectValue:(MenuSelectValueView *)menuSelectValueView value:(int)value;

@optional - (void)selectTimeout:(MenuSelectValueView *)menuSelectValueView uiTimeout:(UITimeout *)uiTimeout;

@end

//
// Interface: MenuSelectValueView
//

@class MenuSendOptionsView;

@interface MenuSelectValueView : AbstractMenuView

@property (weak, nonatomic) id<MenuSelectValueDelegate> menuSelectValueDelegate;
@property (nonatomic) MenuSelectValueType menuSelectValueType;
@property (nonatomic, nullable) MenuSendOptionsView *menuSendOptionsView;

- (void)setMenuSelectValueTypeWithType:(MenuSelectValueType)menuSelectValueType;

- (void)setSelectedValueWithValue:(int)value;

@end
