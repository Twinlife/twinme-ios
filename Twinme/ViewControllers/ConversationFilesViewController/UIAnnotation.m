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

- (nonnull instancetype)initWithType:(TLDescriptorAnnotationType)annotationType reaction:(nullable UIReaction *)uiReaction name:(nonnull NSString *)name avatar:(nonnull UIImage *)avatar value:(long)value {
    
    self = [super init];
    
    if (self) {
        _annotationType = annotationType;
        _uiReaction = uiReaction;
        _name = name;
        _avatar = avatar;
        _value = value;
        
        [self initOrderPriority];
    }
    return self;
}

- (void)initOrderPriority {
    
    if (self.annotationType == TLDescriptorAnnotationTypeError) {
        _orderPriority = 0;
    } else if (self.annotationType == TLDescriptorAnnotationTypeLike) {
        _orderPriority = 1;
    } else if (self.annotationType == TLDescriptorAnnotationTypeRead) {
        _orderPriority = 2;
    } else if (self.annotationType == TLDescriptorAnnotationTypeReceived) {
        _orderPriority = 3;
    } else {
        _orderPriority = 4;
    }
}

@end
