/*
 *  Copyright (c) 2023-2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

typedef enum {
    FeatureTypeClickToCall,
    FeatureTypeConversation,
    FeatureTypeGroupCall,
    FeatureTypeSpaces,
    FeatureTypeStreaming,
    FeatureTypeTransfertCall,
    FeatureTypeRemoteControl
} FeatureType;

@class UIPremiumFeatureDetail;
@class TLSpaceSettings;

//
// Interface: UIPremiumFeature
//

@interface UIPremiumFeature : NSObject

@property (nonatomic) FeatureType featureType;
@property (nonatomic, nonnull) TLSpaceSettings *spaceSettings;
@property (nonatomic, nonnull) NSMutableArray<UIPremiumFeatureDetail *> *featureDetails;

- (nonnull instancetype)initWithFeatureType:(FeatureType)featureType spaceSettings:(nullable TLSpaceSettings *)spaceSettings;

- (nonnull NSString *)getTitle;

- (nonnull NSString *)getSubTitle;

- (nullable UIImage *)getImage;

@end
