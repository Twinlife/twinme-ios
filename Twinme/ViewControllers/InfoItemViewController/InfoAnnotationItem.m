/*
 *  Copyright (c) 2026 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "InfoAnnotationItem.h"

//
// Implementation: InfoAnnotationItem
//

@implementation InfoAnnotationItem

- (instancetype)initWithAnnotation:(nonnull UIAnnotation *)annotation {
    
    self = [super initWithType:ItemTypeInfoAnnotation descriptorId:[Item defaultDescriptorId] timestamp:0];
    
    if (self) {
        _annotation = annotation;
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
    [string appendString:@"InfoAnnotationItem\n"];
    [self appendTo:string];
    return string;
}

@end
