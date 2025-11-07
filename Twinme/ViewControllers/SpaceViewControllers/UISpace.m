/*
 *  Copyright (c) 2019-2020 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "UISpace.h"

#import <Twinme/TLProfile.h>
#import <Twinme/TLContact.h>
#import <Twinme/TLSpace.h>

#import <Twinme/TLSpaceSettings.h>

#import "SpaceSetting.h"

#import <Utils/NSString+Utils.h>

//
// Implementation: UISpace
//

@implementation UISpace

- (instancetype)initWithSpace:(TLSpace *)space defaultSpaceSettings:(TLSpaceSettings *)defaultSpaceSettings {
    
    self = [super init];
    
    if (self) {
        _space = space;
        
        _spaceSettings = _space.settings;
        if ([_space.settings getBooleanWithName:PROPERTY_DEFAULT_APPEARANCE_SETTINGS defaultValue:YES]) {
            _spaceSettings = defaultSpaceSettings;
        }
                
        _nameSpace = _space.settings.name;
        if (!_nameSpace) {
            _nameSpace = TwinmeLocalizedString(@"space_appearance_view_controller_general_title", nil);
        }
        
        _nameProfile = _space.profile.name;
        if (!_nameProfile) {
            _nameProfile = [TLContact ANONYMOUS_NAME];
        }
#if 0
        _avatar = profileAvatar;
        if (!_avatar) {
            _avatar = [TLContact ANONYMOUS_AVATAR];
        }
        
        _avatarSpace = avatar;
        if (!_avatarSpace) {
            _avatarSpace = [TLContact ANONYMOUS_AVATAR];
        }
#endif
        _avatar = [TLContact ANONYMOUS_AVATAR];
        _hasNotification = false;
        _isCurrentSpace = false;
    }
    return self;
}

- (void)setSpace:(TLSpace *)space defaultSpaceSettings:(TLSpaceSettings *)defaultSpaceSettings {
    
    _space = space;
    
    _spaceSettings = _space.settings;
    if ([_space.settings getBooleanWithName:PROPERTY_DEFAULT_APPEARANCE_SETTINGS defaultValue:YES]) {
        _spaceSettings = defaultSpaceSettings;
    }
    
    _nameSpace = _space.settings.name;
    if (!_nameSpace) {
        _nameSpace = [TLContact ANONYMOUS_NAME];
    }
    
    _nameProfile = _space.profile.name;
    if (!_nameProfile) {
        _nameProfile = [TLContact ANONYMOUS_NAME];
    }
}

- (void)updateSpaceSettings:(TLSpace *)space defaultSpaceSettings:(TLSpaceSettings *)defaultSpaceSettings {
    
    _spaceSettings = space.settings;
    if ([space.settings getBooleanWithName:PROPERTY_DEFAULT_APPEARANCE_SETTINGS defaultValue:YES]) {
        _spaceSettings = defaultSpaceSettings;
    }
}

- (BOOL)hasProfile {
    
    return _space.profile != nil;
}

@end
