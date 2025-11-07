/*
 *  Copyright (c) 2023 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "AbstractMenuView.h"

typedef enum {
    MenuDateTimeTypeStartDate,
    MenuDateTimeTypeStartHour,
    MenuDateTimeTypeEndDate,
    MenuDateTimeTypeEndHour
} MenuDateTimeType;

//
// Protocol: MenuDateTimeViewDelegate
//

@class MenuDateTimeView;

@protocol MenuDateTimeViewDelegate <NSObject>

- (void)menuDateTimeDidClosed:(MenuDateTimeView *)menuDateTimeView menuDateTimeType:(MenuDateTimeType)menuDateTimeType date:(NSDate *)date;

@end

//
// Interface: MenuDateTimeView
//

@interface MenuDateTimeView : AbstractMenuView

@property (weak, nonatomic) id<MenuDateTimeViewDelegate> menuDateTimeViewDelegate;
@property (nonatomic) MenuDateTimeType menuDateTimeType;

- (void)setMenuDateTimeTypeWithType:(MenuDateTimeType)menuDateTimeType;

- (void)openMenu:(NSDate *)minimumDate date:(NSDate *)date;

@end
