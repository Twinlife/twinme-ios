/*
 *  Copyright (c) 2026 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "UIPollResult.h"

#import <Twinlife/TLConversationService.h>

//
// Implementation: UIPollResult
//

@implementation UIPollResult

- (nonnull instancetype)initWithChoice:(nonnull TLChoice *)choice {
    self = [super init];
    
    if (self) {
        self.choice = choice;
        self.count = 0;
        self.isSelected = NO;
        self.voters = [[NSMutableArray alloc]init];
    }
    return self;
}

- (nonnull NSString *)getChoiceLabel {
    
    return self.choice.label;
}

@end
