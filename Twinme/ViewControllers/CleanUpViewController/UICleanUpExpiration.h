/*
 *  Copyright (c) 2023 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

typedef enum {
    ExpirationTypeAll,
    ExpirationTypeValue,
    ExpirationTypeDate
} ExpirationType;

typedef enum {
    ExpirationPeriodOneDay,
    ExpirationPeriodOneWeek,
    ExpirationPeriodOneMonth,
    ExpirationPeriodThreeMonths,
    ExpirationPeriodSixMonths,
    ExpirationPeriodOneYear,
} ExpirationPeriod;

//
// Interface: UICleanUpExpiration
//

@interface UICleanUpExpiration : NSObject

@property (nonatomic) ExpirationType expirationType;
@property (nonatomic) ExpirationPeriod expirationPeriod;
@property (nonatomic, nullable) NSDate *expirationDate;

- (nonnull instancetype)initWithExpirationType:(ExpirationType)expirationType expirationDate:(nullable NSDate *)date;

- (nonnull instancetype)initWithExpirationType:(ExpirationType)expirationType expirationPeriod:(ExpirationPeriod)expirationPeriod;

- (void)setPeriod:(ExpirationPeriod)period;

- (void)setDate:(nonnull NSDate *)date;

- (nonnull NSString *)getTitle;

- (nonnull NSString *)getValue;

- (int64_t)clearDate;

@end
