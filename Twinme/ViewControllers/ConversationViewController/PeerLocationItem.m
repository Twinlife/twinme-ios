/*
 *  Copyright (c) 2019-2021 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <Twinlife/TLConversationService.h>

#import "PeerLocationItem.h"

//
// Implementation: PeerLocationItem
//

@implementation PeerLocationItem

- (instancetype)initWithGeolocationDescriptor:(TLGeolocationDescriptor *)geolocationDescriptor replyToDescriptor:(TLDescriptor *)replyToDescriptor  {
    
    self = [super initWithType:ItemTypePeerLocation descriptor:geolocationDescriptor];
    
    if (self) {
        _geolocationDescriptor= geolocationDescriptor;
    }
    return self;
}

- (void)updateGeolocationDescriptor:(TLGeolocationDescriptor *)geolocationDescriptor {
    
    self.geolocationDescriptor = geolocationDescriptor;
}

#pragma mark - Item

- (BOOL)isPeerItem {
    
    return YES;
}

- (NSUUID *)peerTwincodeOutboundId {
    
    return self.geolocationDescriptor.descriptorId.twincodeOutboundId;
}

- (BOOL)isSamePeer:(Item *)item {
    
    return [self.peerTwincodeOutboundId isEqual:item.peerTwincodeOutboundId];
}

- (int64_t)timestamp {
    
    return self.createdTimestamp;
}

#pragma mark - NSObject

- (NSString *)description {
    
    NSMutableString *string = [NSMutableString stringWithCapacity:1024];
    [string appendString:@"PeerLocationItem\n"];
    [self appendTo:string];
    return string;
}

@end

