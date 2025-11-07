/*
 *  Copyright (c) 2022 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Christian Jacquemot (Christian.Jacquemot@twinlife-systems.com)
 */

#import <Foundation/Foundation.h>

#import <StoreKit/StoreKit.h>

#define ONE_MONTH_SUBSCRIPTION_ID @"subscription.one_month_auto_renew_20221010"
#define SIX_MONTHS_SUBSCRIPTION_ID @"subscription.six_month_auto_renew_20221010"
#define ONE_YEAR_SUBSCRIPTION_ID @"subscription.one_year_auto_renew_20221010"

@protocol InAppPurchaseManagerDelegate <NSObject>

- (void)onGetProducts:(NSArray *)products;

- (void)onTransactionSuccess:(SKPaymentTransaction *)transaction receipt:(NSString *)receipt;

- (void)onTransactionRestored;

- (void)onTransactionFailed:(SKPaymentTransaction *)transaction;

@end

@interface InAppPurchaseManager : NSObject

+ (nonnull InAppPurchaseManager *)sharedInstance:(nonnull id<InAppPurchaseManagerDelegate>)inAppPurchaseManagerDelegate;

- (nonnull instancetype)initWithDelegate:(nonnull id<InAppPurchaseManagerDelegate>)inAppPurchaseManagerDelegate;

- (void)subscribeProductWithProductId:(nonnull NSString *)productId;

- (void)restoreCompletedTransactions;

- (void)getProducts;

@end
