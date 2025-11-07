/*
 *  Copyright (c) 2018 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <Twinlife/TLConversationService.h>

#import "NameItem.h"

static NSUUID *nullUUID;

//
// Implementation: NameItem
//

@implementation NameItem

+ (void)initialize {
    
    nullUUID = [[NSUUID alloc] initWithUUIDString:@"00000000-0000-0000-0000-000000000000"];
}

- (NameItem *)initWithTimestamp:(int64_t)timestamp name:(NSString *)name {
    
    self = [super initWithType:ItemTypeName descriptorId:[[TLDescriptorId alloc] initWithTwincodeOutboundId:nullUUID sequenceId:ITEM_DEFAULT_SEQUENCE_ID] timestamp:timestamp];
    
    if (self) {
        _name = name;
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
    [string appendString:@"NameItem\n"];
    [self appendTo:string];
    return string;
}

@end
