/*
 *  Copyright (c) 2021 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "UIMenuItemAction.h"

//
// Implementation: UIMenuItemAction
//

@implementation UIMenuItemAction

- (instancetype)initWithTitle:(NSString *)title image:(UIImage *)image actionType:(ActionType)actionType {
    
    self = [super init];
    
    if (self) {
        _title = title;
        _image = image;
        _actionType = actionType;
    }
    return self;
}

@end
