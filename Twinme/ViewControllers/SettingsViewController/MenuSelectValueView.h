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
    MenuSelectValueTypeQualityMedia,
    MenuSelectValueTypeDisplayCallsMode,
    MenuSelectValueTypeEditSpace,
    MenuSelectValueTypeProfileUpdateMode,
    MenuSelectValueTypeTimeoutEphemeralMessage,
    MenuSelectValueTypeTimeoutLockScreen,
    MenuSelectValueTypeCallZoomable,
    MenuSelectValueTypeExternalCallExpiration,
    MenuSelectValueTypeExternalCallType,
    MenuSelectValueTypeSecurityLevel,
    MenuSelectValueTypeSilentModeDuration,
    MenuSelectValueTypeShareInvitation
} MenuSelectValueType;

//
// Protocol: MenuSelectValueDelegate
//

@class MenuSelectValueView;

@protocol MenuSelectValueDelegate <NSObject>

- (void)cancelMenuSelectValue:(nonnull MenuSelectValueView *)menuSelectValueView;

@optional - (void)selectValue:(nonnull MenuSelectValueView *)menuSelectValueView value:(int)value;

@optional - (void)selectTimeout:(nonnull MenuSelectValueView *)menuSelectValueView uiTimeout:(nonnull UITimeout *)uiTimeout;

@end

//
// Interface: MenuSelectValueView
//

@class MenuSendOptionsView;

@interface MenuSelectValueView : AbstractMenuView

@property (weak, nonatomic) id<MenuSelectValueDelegate> menuSelectValueDelegate;
@property (nonatomic) MenuSelectValueType menuSelectValueType;
@property (nonatomic, nullable) MenuSendOptionsView *menuSendOptionsView;

- (void)setMenuSelectValueTypeWithType:(MenuSelectValueType)menuSelectValueType defaultValue:(int)defaultValue;

- (void)setSelectedValueWithValue:(int)value;

@end
