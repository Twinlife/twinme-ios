/*
 *  Copyright (c) 2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

//
// Interface: EditMessageView
//

@interface EditMessageView : UIView

- (void)updateLeading:(CGFloat)leading top:(CGFloat)top width:(CGFloat)width;

- (void)updateColor;

@end
