/*
 *  Copyright (c) 2026 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */


#import <Twinme/TLTimeRange.h>

//
// Interface: DayCell
//

@interface UIScheduleDay : NSObject

@property (nonatomic, nonnull) NSString *day;
@property (nonatomic) TLDayOfWeek dayOfWeek;
@property (nonatomic) BOOL isSelected;

- (instancetype)initWithDay:(nonnull NSString *)day dayOfWeek:(TLDayOfWeek)dayOfWeek isSelected:(BOOL)isSelected;

@end
