/*
 *  Copyright (c) 2026 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "InfoCopyItem.h"

//
// Implementation: InfoCopyItem
//

@implementation InfoCopyItem

- (id)init {
    
    self = [super initWithType:ItemTypeInfoCopy descriptorId:[Item defaultDescriptorId] timestamp:0];
    
    return self;
}

- (BOOL)isPeerItem {
    
    return NO;
}

- (int64_t)timestamp {
    
    return self.createdTimestamp;
}

#pragma mark - NSObject

- (NSString *)description {
    
    NSMutableString *string = [NSMutableString stringWithCapacity:1024];
    [string appendString:@"InfoCopyItem\n"];
    [self appendTo:string];
    return string;
}

@end
