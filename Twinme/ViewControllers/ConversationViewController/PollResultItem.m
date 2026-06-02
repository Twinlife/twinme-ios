/*
 *  Copyright (c) 2026 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "PollResultItem.h"

//
// Implementation: PollResultItem
//

@implementation PollResultItem

- (nonnull instancetype)initWithType:(PollResultItemType)pollResultItemType title:(nonnull NSString *)title avatar:(nullable UIImage *)avatar {
    
    self = [super init];
    
    if (self) {
        self.pollResultItemType = pollResultItemType;
        self.title = title;
        self.avatar = avatar;
    }
    return self;
}

@end
