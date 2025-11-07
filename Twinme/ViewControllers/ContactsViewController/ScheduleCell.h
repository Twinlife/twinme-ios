/*
 *  Copyright (c) 2024 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */


typedef enum {
    ScheduleTypeStart,
    ScheduleTypeEnd
} ScheduleType;

//
// Protocol: ScheduleDelegate
//

@protocol ScheduleDelegate <NSObject>

- (void)scheduleDate:(ScheduleType)scheduleType;

- (void)scheduleTime:(ScheduleType)scheduleType;

@end

@class TLDate;
@class TLTime;

//
// Interface: ScheduleCell
//

@interface ScheduleCell : UITableViewCell

@property (weak, nonatomic) id<ScheduleDelegate> scheduleDelegate;

- (void)bind:(ScheduleType)scheduleType date:(TLDate *)date time:(TLTime *)time;

@end
