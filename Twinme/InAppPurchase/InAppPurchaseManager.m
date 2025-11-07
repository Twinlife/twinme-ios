/*
 *  Copyright (c) 2022 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import "InAppPurchaseManager.h"

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static InAppPurchaseManager *sharedInstance = nil;

//
// Interface: InAppPurchaseManager ()
//

@interface InAppPurchaseManager () <SKProductsRequestDelegate,SKPaymentTransactionObserver>

@property (weak, nonatomic) id<InAppPurchaseManagerDelegate> inAppPurchaseManagerDelegate;

@property (nonatomic) SKProductsRequest *request;
@property (nonatomic) NSArray *productIdentifiers;
@property (nonatomic) NSArray *products;

@property (nonatomic) BOOL restoreMode;

@end

//
// Implementation: InAppPurchaseManager
//

#undef LOG_TAG
#define LOG_TAG @"InAppPurchaseManager"

@implementation InAppPurchaseManager

+ (InAppPurchaseManager *)sharedInstance:(id<InAppPurchaseManagerDelegate>)inAppPurchaseManagerDelegate {
    
    if (sharedInstance == nil) {
        sharedInstance = [[InAppPurchaseManager alloc] initWithDelegate:inAppPurchaseManagerDelegate];
    }
    
    return sharedInstance;
}


- (instancetype)initWithDelegate:(id<InAppPurchaseManagerDelegate>)inAppPurchaseManagerDelegate {
    
    self = [super init];
    
    if (self) {
        _restoreMode = NO;
        _inAppPurchaseManagerDelegate = inAppPurchaseManagerDelegate;
    }
    return self;
}

- (void)getProducts {
    DDLogVerbose(@"%@ getProducts", LOG_TAG);
    
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"product_ids" withExtension:@"plist"];
    self.productIdentifiers = [NSArray arrayWithContentsOfURL:url];
    
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    
    [self validateProductIdentifiers:self.productIdentifiers];
}

- (void)validateProductIdentifiers:(NSArray *)productIdentifiers {
    DDLogVerbose(@"%@ validateProductIdentifiers: %@", LOG_TAG, productIdentifiers);
    
    SKProductsRequest *productsRequest = [[SKProductsRequest alloc]
                                          initWithProductIdentifiers:[NSSet setWithArray:productIdentifiers]];
    
    self.request = productsRequest;
    productsRequest.delegate = self;
    [productsRequest start];
}

#pragma mark - SKProductsRequestDelegate

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    DDLogVerbose(@"%@ productsRequest: %@ didReceiveResponse: %@", LOG_TAG, request, response);
    
    self.products = response.products;
    
    if ([self.inAppPurchaseManagerDelegate respondsToSelector:@selector(onGetProducts:)]) {
        [self.inAppPurchaseManagerDelegate onGetProducts:self.products];
    }
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    DDLogVerbose(@"%@ productsRequest: %@ didFailWithError: %@", LOG_TAG, request, error);
    
}

- (void)subscribeProductWithProductId:(NSString *)productId {
    DDLogVerbose(@"%@ subscribeProductWithProductId: %@", LOG_TAG, productId);
    
    for (SKProduct *product in self.products) {
        if ([product.productIdentifier isEqualToString:productId]) {
            SKPayment *payment = [SKPayment paymentWithProduct:product];
            [[SKPaymentQueue defaultQueue] addPayment:payment];
            break;
        }
    }
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    DDLogVerbose(@"%@ paymentQueue: %@ updatedTransactions: %@", LOG_TAG, queue, transactions);
    
    for (SKPaymentTransaction *transaction in transactions) {
        
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
            default:
                break;
        }
    };
    
    if (self.restoreMode) {
        self.restoreMode = NO;
        [self.inAppPurchaseManagerDelegate onTransactionRestored];
    }
}

- (void)completeTransaction:(SKPaymentTransaction *)transaction {
    DDLogVerbose(@"%@ completeTransaction: %@", LOG_TAG, transaction);
    
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    
    [self verifyReceipt:transaction];
}

- (void)restoreTransaction:(SKPaymentTransaction *)transaction {
    DDLogVerbose(@"%@ restoreTransaction: %@", LOG_TAG, transaction);
    
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    
    if ([self isTransactionValid:transaction]) {
        [self verifyReceipt:transaction];
    }
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction {
    DDLogVerbose(@"%@ failedTransaction: %@", LOG_TAG, transaction);
    
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    
    if ([self.inAppPurchaseManagerDelegate respondsToSelector:@selector(onTransactionFailed:)]) {
        [self.inAppPurchaseManagerDelegate onTransactionFailed:transaction];
    }
}

- (void)restoreCompletedTransactions {
    DDLogVerbose(@"%@ restoreCompletedTransactions", LOG_TAG);
    
    self.restoreMode = YES;
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

- (BOOL)isTransactionValid:(SKPaymentTransaction *)transaction {
    DDLogVerbose(@"%@ isTransactionExpire: %@", LOG_TAG, transaction);
    
    if (transaction.originalTransaction.transactionState == SKPaymentTransactionStatePurchased) {
        
        NSString *productId = transaction.originalTransaction.payment.productIdentifier;
        NSDate *transactionDate = transaction.originalTransaction.transactionDate;
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDate *endSubscriptionDate;
    
        if ([productId isEqualToString:ONE_MONTH_SUBSCRIPTION_ID]) {
            endSubscriptionDate = [calendar dateByAddingUnit:NSCalendarUnitMonth value:1 toDate:transactionDate options:0];
        } else if ([productId isEqualToString:SIX_MONTHS_SUBSCRIPTION_ID]) {
            endSubscriptionDate = [calendar dateByAddingUnit:NSCalendarUnitMonth value:6 toDate:transactionDate options:0];
        } else if ([productId isEqualToString:ONE_YEAR_SUBSCRIPTION_ID]) {
            endSubscriptionDate = [calendar dateByAddingUnit:NSCalendarUnitMonth value:12 toDate:transactionDate options:0];
        }
    
        if (endSubscriptionDate && [endSubscriptionDate compare:[NSDate date]] == NSOrderedDescending) {
            return YES;
        }
    }
    
    return NO;
}

- (void)verifyReceipt:(SKPaymentTransaction *)transaction {
    DDLogVerbose(@"%@ verifyReceipt", LOG_TAG);
    
    NSURL *receiptURL = [[NSBundle mainBundle] appStoreReceiptURL];
    NSData *receipt = [NSData dataWithContentsOfURL:receiptURL];

    if (!receipt) {
        if (!self.restoreMode && [self.inAppPurchaseManagerDelegate respondsToSelector:@selector(onTransactionFailed:)]) {
            [self.inAppPurchaseManagerDelegate onTransactionFailed:transaction];
        }
    } else {
        NSString *encodedReceipt = [receipt base64EncodedStringWithOptions:0];
        if ([self.inAppPurchaseManagerDelegate respondsToSelector:@selector(onTransactionSuccess:receipt:)]) {
            [self.inAppPurchaseManagerDelegate onTransactionSuccess:transaction receipt:encodedReceipt];
        }
    }

}

@end
