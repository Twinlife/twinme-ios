/*
 *  Copyright (c) 2024-2026 twinlife SA.
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

- (nonnull instancetype)initWithType:(TLDescriptorAnnotationType)annotationType reaction:(nullable UIReaction *)uiReaction name:(nonnull NSString *)name avatar:(nonnull UIImage *)avatar timestamp:(long)timestamp {
    
    self = [super init];
    
    if (self) {
        _annotationType = annotationType;
        _uiReaction = uiReaction;
        _name = name;
        _avatar = avatar;
        _timestamp = timestamp;
        
        [self initOrderPriority];
    }
    return self;
}

- (void)initOrderPriority {
    
    if (self.annotationType == TLDescriptorAnnotationTypeLike) {
        _orderPriority = 3;
    } else if (self.annotationType == TLDescriptorAnnotationTypeRead) {
        _orderPriority = 2;
    } else if (self.annotationType == TLDescriptorAnnotationTypeReceived) {
        _orderPriority = 1;
    } else {
        _orderPriority = 0;
    }
}

@end
