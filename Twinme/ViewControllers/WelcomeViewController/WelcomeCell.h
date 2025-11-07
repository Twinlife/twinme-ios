/*
 *  Copyright (c) 2019-2020 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

//
// Interface: WelcomeCell
//

@interface WelcomeCell : UICollectionViewCell

- (void)bindWithTitle:(NSString *)title image:(UIImage *)image font:(UIFont *)font;

@end
