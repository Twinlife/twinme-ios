/*
 *  Copyright (c) 2017 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Christian Jacquemot (Christian.Jacquemot@twinlife-systems.com)
 */

//
// Interface: RoundedShadowImageView
//

@interface RoundedShadowImageView : UIImageView

- (void)setShadowWithColor:(UIColor *)color shadowRadius:(CGFloat)shadowRadius shadowOffset:(CGSize)shadowOffset shadowOpacity:(CGFloat)shadowOpacity;

@end
