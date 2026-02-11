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

@class TLSpaceSettings;

@interface UIQuality : NSObject

@property (nonatomic) QualityOfServicesPart qualityOfServicesPart;
@property (nonatomic, nonnull) TLSpaceSettings *spaceSettings;

- (nonnull instancetype)initWithQualityOfServicesPart:(QualityOfServicesPart)qualityOfServicesPart spaceSettings:(nullable TLSpaceSettings *)spaceSettings;

- (nullable UIImage *)getImage;

- (nonnull NSString *)getMessage;

- (BOOL)hideAction;

@end
