/*
 *  Copyright (c) 2020 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "UIRoomMember.h"

#import <Twinlife/TLTwincodeOutboundService.h>

#import <Twinme/TLTwinmeAttributes.h>

//
// Implementation: UIRoomMember
//

@implementation UIRoomMember : NSObject

- (nonnull instancetype)initWithTwincodeOutbound:(nonnull TLTwincodeOutbound *)twincodeOutbound avatar:(nullable UIImage *)avatar {
    
    self = [super init];
    
    if (self) {
        _twincodeOutbound = twincodeOutbound;
        _name = [twincodeOutbound name];
        _avatar = avatar;
    }
    return self;
}

- (void)setTwincodeOutbound:(nonnull TLTwincodeOutbound *)twincodeOutbound avatar:(nonnull UIImage *)avatar {
    
    _twincodeOutbound = twincodeOutbound;
    _name = [twincodeOutbound name];
    _avatar = avatar;
}

@end
