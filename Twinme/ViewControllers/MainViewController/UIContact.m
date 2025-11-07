/*
 *  Copyright (c) 2018-2024 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "UIContact.h"

#import <Twinme/TLContact.h>
#import <Twinme/TLTwinmeAttributes.h>

#import "UIConversation.h"
#import "UIContactTag.h"

//
// Implementation: UIContact
//

#undef LOG_TAG
#define LOG_TAG @"UIContact"

@implementation UIContact : NSObject

- (instancetype)initWithContact:(id<TLOriginator>)contact {
    
    self = [super init];
    
    if (self) {
        _contact = contact;
        _name = _contact.name;
 
        [self updateContactTag];
    }
    return self;
}

- (nonnull instancetype)initWithContact:(nonnull id<TLOriginator>)contact avatar:(nonnull UIImage *)avatar {
    
    self = [super init];
    
    if (self) {
        _contact = contact;
        _name = _contact.name;
        _avatar = avatar;
 
        [self updateContactTag];
    }
    return self;
}

- (void)setContact:(id<TLOriginator>)contact {
    
    _contact = contact;
    
    self.name = _contact.name;

    [self updateContactTag];
}

- (void)setContact:(id<TLOriginator>)contact avatar:(nonnull UIImage *)avatar {
    
    [self setContact:contact];
    [self updateAvatar:avatar];
}

- (void)updateAvatar:(nullable UIImage *)avatar {
    
    if ([_contact hasPeer] && avatar) {
        self.avatar = avatar;
    } else {
        if (_contact.isGroup) {
            self.avatar = [TLTwinmeAttributes DEFAULT_GROUP_AVATAR];
        } else {
            self.avatar = [TLTwinmeAttributes DEFAULT_AVATAR];
        }
    }
}

- (BOOL)isCertified {
    
    if ([(NSObject *)self.contact isKindOfClass:[TLContact class]]) {
        TLContact *c = (TLContact *)self.contact;
        return [c certificationLevel] == TLCertificationLevel4;
    } else {
        return NO;
    }
}

- (double)usageScore {
    
    return [self.contact usageScore];
}

- (int64_t)lastMessageDate {
    
    return [self.contact lastMessageDate];
}

- (void)updateContactTag {
    
    if ([(NSObject *)self.contact isKindOfClass:[TLContact class]]) {
        TLContact *c = (TLContact *)self.contact;
        if (![c hasPeer]) {
            self.contactTag = [[UIContactTag alloc]initWithTag:ContactTagRevoked];
        } else if (![c hasPrivatePeer]) {
            self.contactTag = [[UIContactTag alloc]initWithTag:ContactTagPending];
        } else {
            self.contactTag = nil;
        }
    } else {
        self.contactTag = nil;
    }
}

@end
