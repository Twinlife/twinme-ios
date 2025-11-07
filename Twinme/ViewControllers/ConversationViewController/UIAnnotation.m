/*
 *  Copyright (c) 2024 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "UIAnnotation.h"

//
// Implementation: UIAnnotation
//

@implementation UIAnnotation

- (nonnull instancetype)initWithReaction:(nonnull UIReaction *)uiReaction name:(nonnull NSString *)name avatar:(nonnull UIImage *)avatar {
    
    self = [super init];
    
    if (self) {
        _uiReaction = uiReaction;
        _name = name;
        _avatar = avatar;
    }
    return self;
}

@end
