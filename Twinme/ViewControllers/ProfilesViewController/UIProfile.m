/*
 *  Copyright (c) 2020-2024 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "UIProfile.h"

#import <Twinme/TLProfile.h>

//
// Implementation: UIProfile
//

#undef LOG_TAG
#define LOG_TAG @"UIProfile"

@implementation UIProfile : NSObject

- (nonnull instancetype)initWithProfile:(nonnull TLProfile *)profile {
    
    self = [super init];
    if (self) {
        _profile = profile;
        _name = profile.name ? profile.name : @"";
    }
    return self;
}

- (void)setProfile:(nonnull TLProfile *)profile {
    
    self.profile = profile;
    
    self.name = profile.name ? profile.name : @"";
}

- (void)updateAvatar:(nonnull UIImage *)avatar {
    
    self.avatar = avatar;
}

@end
