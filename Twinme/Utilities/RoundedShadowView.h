/*
 *  Copyright (c) 2017 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Christian Jacquemot (Christian.Jacquemot@twinlife-systems.com)
 *   Chedi Baccari (Chedi.Baccari@twinlife-systems.com)
 */

//
// Interface: RoundedShadowView
//

@interface RoundedShadowView : UIView

- (void)setShadowWithColor:(UIColor *)color shadowRadius:(CGFloat)shadowRadius shadowOffset:(CGSize)shadowOffset shadowOpacity:(CGFloat)shadowOpacity;

@end
