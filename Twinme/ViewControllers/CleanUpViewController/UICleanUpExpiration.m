/*
 *  Copyright (c) 2023 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "UICleanUpExpiration.h"

#import <Utils/NSString+Utils.h>

//
// Implementation: UIStorage
//

@implementation UICleanUpExpiration

- (nonnull instancetype)initWithExpirationType:(ExpirationType)expirationType expirationDate:(nullable NSDate *)date {
    
    self = [super init];
    
    if (self) {
        _expirationType = expirationType;
        _expirationDate = date;
    }
    return self;
}

- (nonnull instancetype)initWithExpirationType:(ExpirationType)expirationType expirationPeriod:(ExpirationPeriod)expirationPeriod {
    
    self = [super init];
    
    if (self) {
        _expirationType = expirationType;
        _expirationPeriod = expirationPeriod;
    }
    return self;
}

- (void)setPeriod:(ExpirationPeriod)period {
    
    self.expirationPeriod = period;
}

- (void)setDate:(NSDate *)date {
    
    self.expirationDate = date;
}

- (nonnull NSString *)getTitle {
    
    NSString *title;
    
    switch (self.expirationType) {
        case ExpirationTypeAll:
            title = TwinmeLocalizedString(@"cleanup_view_controller_all", nil);
            break;
            
        case ExpirationTypeDate:
            title = TwinmeLocalizedString(@"cleanup_view_controller_prior_to", nil);
            break;
            
        case ExpirationTypeValue:
            title = TwinmeLocalizedString(@"cleanup_view_controller_older_than", nil);
            break;
            
        default:
            break;
    }
    
    return title;
}

- (nonnull NSString *)getValue {
    
    NSString *value = @"";
    
    if (self.expirationType == ExpirationTypeValue) {
        switch (self.expirationPeriod) {
            case ExpirationPeriodOneDay:
                value = TwinmeLocalizedString(@"application_timeout_day", nil);
                break;
                
            case ExpirationPeriodOneWeek:
                value = TwinmeLocalizedString(@"application_timeout_week", nil);
                break;
                
            case ExpirationPeriodOneMonth:
                value = TwinmeLocalizedString(@"application_timeout_month", nil);
                break;
                
            case ExpirationPeriodThreeMonths:
                value = [NSString stringWithFormat:TwinmeLocalizedString(@"cleanup_view_controller_month", nil), 3];
                break;
                
            case ExpirationPeriodSixMonths:
                value = [NSString stringWithFormat:TwinmeLocalizedString(@"cleanup_view_controller_month", nil), 6];
                break;
                
            case ExpirationPeriodOneYear:
                value = TwinmeLocalizedString(@"cleanup_view_controller_one_year", nil);
                break;
                
            default:
                break;
        }
    } else if (self.expirationType == ExpirationTypeDate) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"YYYY/MM/dd"];
        value = [dateFormatter stringFromDate:self.expirationDate];
    }
    
    return value;
}

- (int64_t)clearDate {
    
    int64_t date = LONG_MAX;
    if (self.expirationType == ExpirationTypeValue) {
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *components = [[NSDateComponents alloc] init];
        NSDate *now = [NSDate date];
        
        switch (self.expirationPeriod) {
            case ExpirationPeriodOneDay:
                [components setDay:-1];
                break;
                
            case ExpirationPeriodOneWeek:
                [components setDay:-7];
                break;
                
            case ExpirationPeriodOneMonth:
                [components setMonth:-1];
                break;
                
            case ExpirationPeriodThreeMonths:
                [components setMonth:-3];
                break;
                
            case ExpirationPeriodSixMonths:
                [components setMonth:-6];
                break;
                
            case ExpirationPeriodOneYear:
                [components setYear:-1];
                break;
                
            default:
                break;
        }
        
        self.expirationDate = [calendar dateByAddingComponents:components toDate:now options:0];
        date = [self.expirationDate timeIntervalSince1970] * 1000;
    } else if (self.expirationType == ExpirationTypeDate && self.expirationDate) {
        date = [self.expirationDate timeIntervalSince1970] * 1000;
    }
    
    return date;
}

@end
