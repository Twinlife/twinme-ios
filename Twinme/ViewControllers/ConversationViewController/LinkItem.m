/*
 *  Copyright (c) 2022 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <Twinlife/TLConversationService.h>

#import <Twinme/TLMessage.h>

#import "LinkItem.h"

//
// Implementation: LinkItem
//

@implementation LinkItem

- (instancetype)initWithObjectDescriptor:(TLObjectDescriptor *)objectDescriptor replyToDescriptor:(TLDescriptor *)replyToDescriptor url:(NSURL *)url {
    
    self = [super initWithType:ItemTypeLink descriptor:objectDescriptor replyToDescriptor:replyToDescriptor];
    
    if (self) {
        _objectDescriptor = objectDescriptor;
        _content = objectDescriptor.message;
        _url = url;
        self.copyAllowed = objectDescriptor.copyAllowed;
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

- (void)appendTo:(NSMutableString *)string {
    
    [super appendTo:string];
    
    [string appendFormat:@" content: %@\n", self.content];
    [string appendFormat:@" url: %@\n", self.url];
}

#pragma mark - NSObject

- (NSString *)description {
    
    NSMutableString *string = [NSMutableString stringWithCapacity:1024];
    [string appendString:@"LinkItem\n"];
    [self appendTo:string];
    return string;
}

@end

