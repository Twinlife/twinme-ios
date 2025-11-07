/*
 *  Copyright (c) 2020 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "UICustomColor.h"

//
// Implementation: UICustomColor
//

@implementation UICustomColor : NSObject

- (instancetype)initWithColor:(NSString *)color {
    
    self = [super init];
    
    if (self) {
        _color = color;
        _selectedColor = NO;
    }
    return self;
}

- (void)setColorSpace:(NSString *)color {
    
    _color = color;
}

- (void)setSelectedColor:(BOOL)selected {
    
    _selectedColor = selected;
}

@end
