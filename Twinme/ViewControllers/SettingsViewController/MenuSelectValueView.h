/*
 *  Copyright (c) 2022 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "AbstractMenuView.h"

typedef enum {
    MenuSelectValueTypeImageSize,
    MenuSelectValueTypeVideoSize,
    MenuSelectValueTypeDisplayCallsMode,
    MenuSelectValueTypeProfileUpdateMode
} MenuSelectValueType;

//
// Protocol: MenuSelectValueDelegate
//

@class MenuSelectValueView;

@protocol MenuSelectValueDelegate <NSObject>

- (void)cancelMenuSelectValue:(MenuSelectValueView *)menuSelectValueView;

- (void)selectValue:(MenuSelectValueView *)menuSelectValueView value:(int)value;

@end

//
// Interface: MenuSelectValueView
//

@interface MenuSelectValueView : AbstractMenuView

@property (weak, nonatomic) id<MenuSelectValueDelegate> menuSelectValueDelegate;
@property (nonatomic) MenuSelectValueType menuSelectValueType;

- (void)setMenuSelectValueTypeWithType:(MenuSelectValueType)menuSelectValueType;

@end
