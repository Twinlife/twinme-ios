/*
 *  Copyright (c) 2017-2021 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Christian Jacquemot (Christian.Jacquemot@twinlife-systems.com)
 *   Chedi Baccari (Chedi.Baccari@twinlife-systems.com)
 */

#import <Twinlife/TLConversationService.h>

#import "TimeItem.h"

static NSUUID *nullUUID;

//
// Implementation: TimeItem
//

@implementation TimeItem

+ (void)initialize {
    
    nullUUID = [[NSUUID alloc] initWithUUIDString:@"00000000-0000-0000-0000-000000000000"];
}

- (TimeItem*)initWithTimestamp:(int64_t)timestamp {
    
    self = [super initWithType:ItemTypeTime descriptorId:[[TLDescriptorId alloc] initWithTwincodeOutboundId:nullUUID sequenceId:ITEM_DEFAULT_SEQUENCE_ID] timestamp:timestamp];
    
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
    [string appendString:@"TimeItem\n"];
    [self appendTo:string];
    return string;
}

@end
