/*
 *  Copyright (c) 2021 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "LastVersion.h"

@implementation LastVersion

- (NSString *)getMajorChanges {
    
    NSMutableString *majorChanges = [[NSMutableString alloc]initWithString:@""];
    
    for (NSString *changes in self.majorChanges) {
        if (![majorChanges isEqual:@""]) {
            [majorChanges appendString:@"\n"];
        }
        [majorChanges appendString:changes];
    }
    
    return majorChanges;
}

- (NSString *)getMinorChanges {
    
    NSMutableString *minorChanges = [[NSMutableString alloc]initWithString:@""];
    
    for (NSString *changes in self.minorChanges) {
        if (![minorChanges isEqual:@""]) {
            [minorChanges appendString:@"\n"];
        }
        [minorChanges appendString:changes];
    }
    
    return minorChanges;
}

@end
