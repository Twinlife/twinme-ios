/*
 *  Copyright (c) 2026 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "UIPollResultVoter.h"

//
// Implementation: UIPollResultVoter
//

@implementation UIPollResultVoter

- (nonnull instancetype)initWithName:(nullable NSString *)name avatar:(nonnull UIImage *)avatar {
    self = [super init];
    
    if (self) {
        self.name = name;
        self.avatar = avatar;
    }
    return self;
}

@end
