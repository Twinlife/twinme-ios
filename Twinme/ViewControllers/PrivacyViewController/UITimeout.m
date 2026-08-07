/*
 *  Copyright (c) 2021 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "UITimeout.h"

//
// Implementation: UITimeout
//

@implementation UITimeout

- (instancetype)initWithTitle:(NSString *)title timeout:(int64_t)timeout {
    
    self = [super init];
    
    if (self) {
        _title = title;
        _timeout = timeout;
    }
    return self;
}

@end
