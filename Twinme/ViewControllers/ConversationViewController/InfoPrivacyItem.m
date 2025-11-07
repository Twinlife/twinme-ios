/*
 *  Copyright (c) 2017 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Phetsana Phommarinh (pphommarinh@skyrock.com)
 */

#import <Twinlife/TLConversationService.h>

#import "InfoPrivacyItem.h"

static NSUUID *nullUUID;

@implementation InfoPrivacyItem

+ (void)initialize {
    
    nullUUID = [[NSUUID alloc] initWithUUIDString:@"00000000-0000-0000-0000-000000000001"];
}

- (InfoPrivacyItem *)init {
    self = [super initWithType:ItemTypeInfoPrivacy descriptorId:[[TLDescriptorId alloc] initWithTwincodeOutboundId:nullUUID sequenceId:ITEM_DEFAULT_SEQUENCE_ID] timestamp:0];
    
    return self;
}

@end
