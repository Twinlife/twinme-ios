/*
 *  Copyright (c) 2017-2024 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Christian Jacquemot (Christian.Jacquemot@twinlife-systems.com)
 *   Chedi Baccari (Chedi.Baccari@twinlife-systems.com)
 *   Stephane Carrez (Stephane.Carrez@twin.life)
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <Twinlife/TLConversationService.h>
#import <Twinme/TLMessage.h>

#import "PeerMessageItem.h"

//
// Interface: PeerMessageItem
//

@interface PeerMessageItem ()

@property NSUUID *twincodeOutboundId;

@end

//
// Implementation: PeerMessageItem
//

@implementation PeerMessageItem

- (instancetype)initWithObjectDescriptor:(TLObjectDescriptor *)objectDescriptor replyToDescriptor:(TLDescriptor *)replyToDescriptor {
    
    self = [super initWithType:ItemTypePeerMessage descriptor:objectDescriptor replyToDescriptor:replyToDescriptor];
    
    if (self) {
        _content = objectDescriptor.message;
        _twincodeOutboundId = objectDescriptor.descriptorId.twincodeOutboundId;
        _objectDescriptor = objectDescriptor;
        self.copyAllowed = objectDescriptor.copyAllowed;
    }
    return self;
}

#pragma mark - Item

- (BOOL)isPeerItem {
    
    return YES;
}

- (NSUUID *)peerTwincodeOutboundId {
    
    return self.twincodeOutboundId;
}

- (BOOL)isSamePeer:(Item *)item {
    
    return [self.peerTwincodeOutboundId isEqual:item.peerTwincodeOutboundId];
}

- (int64_t)timestamp {
    
    return self.createdTimestamp;
}

- (void)appendTo:(NSMutableString*)string {
    
    [super appendTo:string];
    
    [string appendFormat:@" content: %@\n", self.content];
}

- (BOOL)isEditedtem {
    
    return self.objectDescriptor.isEdited;
}

#pragma mark - NSObject

- (NSString *)description {
    
    NSMutableString *string = [NSMutableString stringWithCapacity:1024];
    [string appendString:@"PeerMessageItem\n"];
    [self appendTo:string];
    return string;
}

@end
