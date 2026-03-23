/*
 *  Copyright (c) 2026 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "InfoDateItem.h"

//
// Implementation: InfoDateItem
//

@implementation InfoDateItem

- (instancetype)initWithType:(InfoItemType)infoItemType name:(NSString *)name image:(UIImage *)avatar {
    
    self = [super initWithType:ItemTypeInfoDate descriptorId:[Item defaultDescriptorId] timestamp:0];
    
    if (self) {
        _infoItemType = infoItemType;
        _name = name;
        _avatar = avatar;
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
    [string appendString:@"InfoDateItem\n"];
    [self appendTo:string];
    return string;
}

@end
