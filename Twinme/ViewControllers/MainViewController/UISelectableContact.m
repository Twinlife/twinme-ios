/*
 *  Copyright (c) 2019-2020 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "UISelectableContact.h"

//
// Implementation: UISelectableContact
//

@implementation UISelectableContact

- (instancetype)initWithContact:(id<TLOriginator>)contact avatar:(UIImage *)avatar {
    
    self = [super initWithContact:contact avatar:avatar];
    
    if (self) {
        _isSelected = false;
    }
    return self;
}

@end
