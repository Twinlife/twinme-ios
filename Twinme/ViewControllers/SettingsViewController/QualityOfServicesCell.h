/*
 *  Copyright (c) 2024 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

//
// Interface: QualityOfServicesCell
//

@class UIQuality;

@protocol QualityOfServicesDelegate;

@interface QualityOfServicesCell : UICollectionViewCell

@property (weak, nonatomic) id<QualityOfServicesDelegate> qualityOfServicesDelegate;

- (void)bindWithQuality:(UIQuality *)uiQuality hideAction:(BOOL)hideAction;

@end
