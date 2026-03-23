/*
 *  Copyright (c) 026 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

//
// Protocol: WeeklyScheduleDelegate
//

@class UIScheduleDay;

@protocol WeeklyScheduleDelegate <NSObject>

- (void)didSelectDay:(UIScheduleDay *)scheduleDay;

@end

//
// Interface: WeeklyScheduleCell
//

@interface WeeklyScheduleCell : UITableViewCell

@property (weak, nonatomic) id<WeeklyScheduleDelegate> weeklyScheduleDelegate;

- (void)bind:(CGFloat)width days:(NSMutableArray *)days;

@end
