/*
 *  Copyright (c) 2020 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <Twinlife/TLConversationService.h>

#import "InvitationContactItem.h"

//
// Implementation: InvitationContactItem
//

@implementation InvitationContactItem

#pragma mark - Item

- (instancetype)initWithTwincodeDescriptor:(TLTwincodeDescriptor *)twincodeDescriptor {
    self = [super initWithType:ItemTypeInvitationContact descriptor:twincodeDescriptor];
    
    if (self) {
        _twincodeDescriptor = twincodeDescriptor;
        self.copyAllowed = twincodeDescriptor.copyAllowed;
    }
    return self;
}

- (BOOL)isPeerItem {
    
    return NO;
}

- (int64_t)timestamp {
    
    return self.createdTimestamp;
}

- (void)updateTimestampsWithDescriptor:(TLDescriptor *)descriptor {
    
    // Keep the new descriptor instance.
    self.twincodeDescriptor = (TLTwincodeDescriptor *)descriptor;
    [super updateTimestampsWithDescriptor:descriptor];
}

#pragma mark - NSObject

- (NSString *)description {
    
    NSMutableString* string = [NSMutableString stringWithCapacity:1024];
    [string appendString:@"InvitationContactItem\n"];
    [self appendTo:string];
    return string;
}

@end
