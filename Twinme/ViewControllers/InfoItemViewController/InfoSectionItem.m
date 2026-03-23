/*
 *  Copyright (c) 2026 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "InfoSectionItem.h"

#import <Twinlife/TLConversationService.h>

//
// Implementation: InfoSectionItem
//

@implementation InfoSectionItem

- (id)initWithTitle:(NSString *)title {
    
    self = [super initWithType:ItemTypeInfoSection descriptorId:[Item defaultDescriptorId] timestamp:0];
    
    if (self) {
        _title = title;
    }
    
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
    [string appendString:@"InfoSectionItem\n"];
    [self appendTo:string];
    return string;
}

@end
