/*
 *  Copyright (c) 2016 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Chedi Baccari (Chedi.Baccari@twinlife-systems.com)
 *   Christian Jacquemot (Christian.Jacquemot@twinlife-systems.com)
 */

#import "DashedLine.h"

//
// Interface: DashedLine ()
//

@interface DashedLine ()

@property UIColor *strokeColor;

@end

//
// Implementation: DashedLine
//

@implementation DashedLine

- (void)drawRect:(CGRect)rect {
    
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(contextRef, self.strokeColor.CGColor);
    CGContextSetLineWidth(contextRef, MIN(rect.size.width, rect.size.height));
    CGFloat lengths[2] = {2, 2};
    CGContextSetLineDash(contextRef, 0, lengths, 2);
    CGContextTranslateCTM(contextRef, rect.origin.x, rect.origin.y);
    CGContextMoveToPoint(contextRef, 0, 0);
    if (rect.size.width > rect.size.height) {
        CGContextAddLineToPoint(contextRef, rect.size.width, 0);
    } else {
        CGContextAddLineToPoint(contextRef, 0, rect.size.height);
    }
    CGContextStrokePath(contextRef);
}

@end
