/*
 *  Copyright (c) 2023 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

//
// Interface: UIPremiumFeatureDetail
//

@interface UIPremiumFeatureDetail : NSObject

@property (nonatomic, nonnull) UIImage *featureDetailImage;
@property (nonatomic, nonnull) NSString *featureDetailMessage;

- (nonnull instancetype)initWithMessage:(nonnull NSString *)message image:(nonnull UIImage *)image;

@end
