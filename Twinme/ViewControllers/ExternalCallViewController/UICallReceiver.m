/*
 *  Copyright (c) 2023 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "UICallReceiver.h"

#import <Twinme/TLCallReceiver.h>

//
// Implementation: UICallReceiver
//

#undef LOG_TAG
#define LOG_TAG @"UICallReceiver"

@implementation UICallReceiver : NSObject

- (nonnull instancetype)initWithCallReceiver:(nonnull TLCallReceiver *)callReceiver {
    
    self = [super init];
    
    if (self) {
        _callReceiver = callReceiver;
        _name = _callReceiver.name;
    }
    return self;
}

- (nonnull instancetype)initWithCallReceiver:(nonnull TLCallReceiver *)callReceiver avatar:(nonnull UIImage *)avatar {
    
    self = [super init];
    
    if (self) {
        _callReceiver = callReceiver;
        _name = _callReceiver.name;
        _avatar = avatar;
    }
    return self;
}

- (void)updateCallReceiver:(nonnull TLCallReceiver *)callReceiver {
    
    self.callReceiver = callReceiver;
    
    self.name = self.callReceiver.name;
}

- (void)updateAvatar:(nonnull UIImage *)avatar {
    
    self.avatar = avatar;
}

@end
