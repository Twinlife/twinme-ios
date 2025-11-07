/*
 *  Copyright (c) 2020 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <Twinlife/TLConversationService.h>

#import "PeerInvitationContactItem.h"

//
// Implementation: PeerInvitationContactItem
//

@implementation PeerInvitationContactItem

- (instancetype)initWithTwincodeDescriptor:(TLTwincodeDescriptor *)twincodeDescriptor {
    
    self = [super initWithType:ItemTypePeerInvitationContact descriptor:twincodeDescriptor];
    
    if (self) {
        _twincodeDescriptor = twincodeDescriptor;
    }
    return self;
}

#pragma mark - Item

- (BOOL)isPeerItem {
    
    return YES;
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
    
    NSMutableString *string = [NSMutableString stringWithCapacity:1024];
    [string appendString:@"PeerInvitationContactItem\n"];
    [self appendTo:string];
    return string;
}

@end
