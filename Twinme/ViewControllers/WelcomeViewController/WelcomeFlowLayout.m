/*
 *  Copyright (c) 2023 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "WelcomeFlowLayout.h"

//
// Implementation: WelcomeFlowLayout
//

@implementation WelcomeFlowLayout

- (BOOL)flipsHorizontallyInOppositeLayoutDirection {
    
    if ([[UIApplication sharedApplication] userInterfaceLayoutDirection] == UIUserInterfaceLayoutDirectionRightToLeft) {
        return YES;
    }
    
    return NO;
}

@end
