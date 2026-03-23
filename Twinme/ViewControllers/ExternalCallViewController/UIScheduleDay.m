/*
 *  Copyright (c) 2026 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "UIScheduleDay.h"

//
// Implementation : UIScheduleDay
//

@implementation UIScheduleDay

- (instancetype)initWithDay:(nonnull NSString *)day dayOfWeek:(TLDayOfWeek)dayOfWeek isSelected:(BOOL)isSelected {
    self = [super init];
    
    if (self) {
        _day = day;
        _dayOfWeek = dayOfWeek;
        _isSelected = isSelected;
    }
    
    return self;
}


@end
