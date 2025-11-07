/*
 *  Copyright (c) 2019-2020 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "UIMoveContact.h"

//
// Implementation: UIMoveContact
//

@implementation UIMoveContact

- (instancetype)initWithContact:(id<TLOriginator>)contact {
    
    self = [super initWithContact:contact];
    
    if (self) {
        _canMove = YES;
    }
    return self;
}

- (instancetype)initWithContact:(id<TLOriginator>)contact avatar:(UIImage *)avatar {
    
    self = [super initWithContact:contact avatar:(UIImage *)avatar];
    
    if (self) {
        _canMove = YES;
    }
    return self;
}

@end
