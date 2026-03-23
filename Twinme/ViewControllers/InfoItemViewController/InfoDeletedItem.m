/*
 *  Copyright (c) 2026 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "InfoDeletedItem.h"

//
// Implementation: InfoDeletedItem
//

@implementation InfoDeletedItem

- (id)init {
    
    self = [super initWithType:ItemTypeInfoDeleted descriptorId:[Item defaultDescriptorId] timestamp:0];
    
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
    [string appendString:@"InfoDeletedItem\n"];
    [self appendTo:string];
    return string;
}

@end
