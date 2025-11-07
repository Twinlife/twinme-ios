/*
 *  Copyright (c) 2023 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "UIContactTag.h"

#import <Utils/NSString+Utils.h>

static UIColor *DESIGN_PENDING_BACKGROUND_COLOR;
static UIColor *DESIGN_PENDING_BORDER_COLOR;

@implementation UIContactTag

- (nonnull instancetype)initWithTag:(ContactTag)contactTag {
    
    self = [super init];
    
    if (self) {
        _contactTag = contactTag;
        [self initTagInfo];
    }
    return self;
}

- (void)initTagInfo {
    
    switch (self.contactTag) {
        case ContactTagPending:
            self.title = TwinmeLocalizedString(@"show_contact_view_controller_pending", nil);
            self.backgroundColor = [UIColor colorWithRed:255./255. green:147./255. blue:0./255. alpha:0.12];
            self.foregroundColor = [UIColor colorWithRed:255./255. green:147./255. blue:0./255. alpha:1];
            break;
            
        case ContactTagRevoked:
            self.title = TwinmeLocalizedString(@"show_contact_view_controller_revoked", nil);
            self.backgroundColor = [UIColor colorWithRed:253./255. green:96./255. blue:93./255. alpha:0.12];
            self.foregroundColor = [UIColor colorWithRed:253./255. green:96./255. blue:93./255. alpha:1];
            break;
            
        default:
            break;
    }
}

@end
