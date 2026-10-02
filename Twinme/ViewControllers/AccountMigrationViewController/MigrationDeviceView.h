/*
 *  Copyright (c) 2026 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <UIKit/UIKit.h>

//
// Interface: MigrationDeviceView
//

@interface MigrationDeviceView : UIView

- (void)updateProgress:(CGFloat)progress animated:(BOOL)animated;
- (void)updateColors:(nonnull UIColor *)backgroundColor progressColor:(nonnull UIColor *)progressColor;

@end
