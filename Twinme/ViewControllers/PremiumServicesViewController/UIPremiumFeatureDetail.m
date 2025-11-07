/*
 *  Copyright (c) 2023 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "UIPremiumFeatureDetail.h"

//
// Implementation: UIPremiumFeatureDetail
//

@implementation UIPremiumFeatureDetail

- (nonnull instancetype)initWithMessage:(nonnull NSString *)message image:(nonnull UIImage *)image {
    
    self = [super init];
    
    if (self) {
        _featureDetailMessage = message;
        _featureDetailImage = image;
    }
    return self;
}

@end
