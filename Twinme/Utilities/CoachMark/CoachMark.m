/*
 *  Copyright (c) 2022 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <TwinmeCommon/CoachMark.h>

//
// Implementation: CoachMark
//

@implementation CoachMark

- (instancetype)initWithMessage:(NSString *)message tag:(CoachMarkTag)tag alignLeft:(BOOL)alignLeft onTop:(BOOL)onTop featureRect:(CGRect)featureRect featureRadius:(CGFloat)featureRadius {
    
    self = [super init];
    
    if (self) {
        self.message = message;
        self.coachMarkTag = tag;
        self.alignLeft = alignLeft;
        self.onTop = onTop;
        self.featureRect = featureRect;
        self.featureRadius = featureRadius;
    }
    
    return self;
}

@end
