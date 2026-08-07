/*
 *  Copyright (c) 2026 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "ShareContactItem.h"

#import <Twinlife/TLConversationService.h>

//
// Implementation: ShareContactItem
//

@implementation ShareContactItem

- (instancetype)initWithContactShareDescriptor:(TLContactShareDescriptor *)contactShareDescriptor {
    
    self = [super initWithType:ItemTypeShareContact descriptor:contactShareDescriptor replyToDescriptor:nil];
    
    if (self) {
        _contactShareDescriptor = contactShareDescriptor;
        self.copyAllowed = NO;
    }
    return self;
}

- (instancetype)initWithTwincodeDescriptor:(TLTwincodeDescriptor *)twincodeDescriptor {
    
    self = [super initWithType:ItemTypeShareContact descriptor:twincodeDescriptor replyToDescriptor:nil];
    
    if (self) {
        _twincodeDescriptor = twincodeDescriptor;
        self.copyAllowed = NO;
    }
    return self;
}


#pragma mark - Item

- (BOOL)isPeerItem {
    
    return NO;
}

- (int64_t)timestamp {
    
    return self.createdTimestamp;
}

#pragma mark - NSObject

- (NSString *)description {
    
    NSMutableString* string = [NSMutableString stringWithCapacity:1024];
    [string appendString:@"ShareContactItem\n"];
    [self appendTo:string];
    return string;
}

@end
