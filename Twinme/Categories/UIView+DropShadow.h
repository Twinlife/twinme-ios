/*
 *  Copyright (c) 2017 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Thibaud David (contact@thibauddavid.com)
 */

//
// Interface: UIView (DropShadow)
//

@interface UIView (DropShadow)

- (void)addDropShadowWithColor:(UIColor *)color shadowRadius:(CGFloat)shadowRadius shadowOffset:(CGSize)shadowOffset;

- (void)addDropShadowWithColor:(UIColor *)color shadowRadius:(CGFloat)shadowRadius shadowOffset:(CGSize)shadowOffset opacity:(CGFloat)opacity;

- (void)updateRoundedShadowPath;

- (void)updateShadowPath;

@end
