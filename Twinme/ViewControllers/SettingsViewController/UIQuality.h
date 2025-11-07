/*
 *  Copyright (c) 2024 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

typedef enum {
    QualityOfServicesPartOne,
    QualityOfServicesPartTwo,
    QualityOfServicesPartThree
} QualityOfServicesPart;

//
// Interface: UIQuality
//

@interface UIQuality : NSObject

@property (nonatomic) QualityOfServicesPart qualityOfServicesPart;

- (nonnull instancetype)initWithQualityOfServicesPart:(QualityOfServicesPart)qualityOfServicesPart;

- (nullable UIImage *)getImage;

- (nonnull NSString *)getMessage;

- (BOOL)hideAction;

@end
