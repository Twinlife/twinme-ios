/*
 *  Copyright (c) 2021 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <UIKit/UIKit.h>

//
// Interface: EphemeralView
//

@interface EphemeralView : UIView

- (void)updateWithPercent:(CGFloat)percent color:(UIColor *)color size:(CGFloat)size;

@end
