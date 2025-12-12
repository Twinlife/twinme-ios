/*
 *  Copyright (c) 2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "TwinmeSlider.h"

#define SLIDER_INSET -20
#define THUMB_INSET -10

//
// Interface: TwinmeSlider
//

@interface TwinmeSlider ()

@end

//
// Implementation: TwinmeTextField
//

@implementation TwinmeSlider

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    
    CGRect bounds = CGRectInset(self.bounds, SLIDER_INSET, SLIDER_INSET);
    return CGRectContainsPoint(bounds, point);
}

- (CGRect)thumbRectForBounds:(CGRect)bounds trackRect:(CGRect)rect value:(float)value {
    
    CGRect thumb = [super thumbRectForBounds:bounds trackRect:rect value:value];
    return CGRectInset(thumb, THUMB_INSET, THUMB_INSET);
}

@end
