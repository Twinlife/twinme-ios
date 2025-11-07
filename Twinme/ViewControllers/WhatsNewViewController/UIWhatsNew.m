/*
 *  Copyright (c) 2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "UIWhatsNew.h"

//
// Implementation: UIWhatsNew
//

@implementation UIWhatsNew

- (nonnull instancetype)initWithImage:(nullable UIImage *)image message:(nonnull NSString *)message {

    self = [super init];
    
    if (self) {
        _image = image;
        _message = message;
    }
    return self;
}

@end
