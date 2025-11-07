/*
 *  Copyright (c) 2017-2021 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Christian Jacquemot (Christian.Jacquemot@twinlife-systems.com)
 *   Chedi Baccari (Chedi.Baccari@twinlife-systems.com)
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <Twinlife/TLConversationService.h>

#import <Twinme/TLMessage.h>

#import "MessageItem.h"

//
// Implementation: MessageItem
//

@implementation MessageItem

- (instancetype)initWithObjectDescriptor:(TLObjectDescriptor *)objectDescriptor replyToDescriptor:(TLDescriptor *)replyToDescriptor {
    
    self = [super initWithType:ItemTypeMessage descriptor:objectDescriptor replyToDescriptor:replyToDescriptor];
    
    if (self) {
        _content = objectDescriptor.message;
        _objectDescriptor = objectDescriptor;
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

- (BOOL)isEditedtem {
    
    return self.objectDescriptor.isEdited;
}

- (void)appendTo:(NSMutableString *)string {
    
    [super appendTo:string];
    
    [string appendFormat:@" content: %@\n", self.content];
}

#pragma mark - NSObject

- (NSString *)description {
    
    NSMutableString *string = [NSMutableString stringWithCapacity:1024];
    [string appendString:@"MessageItem\n"];
    [self appendTo:string];
    return string;
}

@end

