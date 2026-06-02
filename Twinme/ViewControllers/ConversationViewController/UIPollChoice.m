/*
 *  Copyright (c) 2026 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */


#import "UIPollChoice.h"

#import <Utils/NSString+Utils.h>

//
// Implementation: UIPollChoice
//

@implementation UIPollChoice

- (nonnull instancetype)initWithPosition:(int)position choice:(nonnull NSString *)choice {
    self = [super init];
    
    if (self) {
        self.position = position;
        self.choice = choice;
        self.count = 0;
        self.isSelected = NO;
        self.avatars = [[NSMutableArray alloc]init];
    }
    return self;
}

- (nonnull NSString *)getChoicePosition {
    
    return [NSString stringWithFormat:TwinmeLocalizedString(@"poll_view_choice", nil), self.position + 1];
}
@end
