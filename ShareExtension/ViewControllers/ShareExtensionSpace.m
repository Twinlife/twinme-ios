/*
 *  Copyright (c) 2021-2024 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "ShareExtensionSpace.h"
#import <Twinme/TLContact.h>

@implementation ShareExtensionSpace : NSObject

- (instancetype)initWithSpace:(TLSpace *)space {
    
    self = [super init];
    
    if (self) {
        _space = space;
        
        _nameSpace = _space.settings.name;
        if (!_nameSpace) {
            _nameSpace = [TLContact ANONYMOUS_NAME];
        }
        
        _avatarSpace = [TLContact ANONYMOUS_AVATAR];

        _isCurrentSpace = false;
    }
    return self;
}

- (void)setSpace:(TLSpace *)space {
    
    _space = space;
    
    _nameSpace = _space.settings.name;
    if (!_nameSpace) {
        _nameSpace = [TLContact ANONYMOUS_NAME];
    }
}

- (void)updateAvatar:(UIImage *)avatar {
    
    self.avatarSpace = avatar;
}

@end
