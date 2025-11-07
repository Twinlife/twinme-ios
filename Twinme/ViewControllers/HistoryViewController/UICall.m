/*
 *  Copyright (c) 2022 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "UICall.h"

#import <Twinlife/TLConversationService.h>

#import "UIContact.h"

//
// Implementation: UICall
//

#undef LOG_TAG
#define LOG_TAG @"UICall"

@implementation UICall : NSObject

- (nonnull instancetype)initWithCall:(nonnull NSArray<TLCallDescriptor *> *)callDescriptors uiContact:(nonnull UIContact *)uiContact {
    
    self = [super init];
    
    if (self) {
        _callDescriptors = callDescriptors;
        _uiContact = uiContact;
    }
    return self;
}

- (nonnull TLCallDescriptor *)getLastCallDescriptor {
    
    return [self.callDescriptors firstObject];
}

- (NSUInteger)getCount {
    
    return self.callDescriptors.count;
}

@end
