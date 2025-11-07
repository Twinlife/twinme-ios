/*
 *  Copyright (c) 2017-2023 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Christian Jacquemot (Christian.Jacquemot@twinlife-systems.com)
 *   Chedi Baccari (Chedi.Baccari@twinlife-systems.com)
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 *   Stephane Carrez (Stephane.Carrez@twin.life)
 */

#import <Twinlife/TLConversationService.h>

#import "Item.h"
#import "ConversationViewController.h"

//
// Interface: Item ()
//

@interface Item ()

@property CGFloat deleteProgressValue;
@property NSTimer *timer;

@end

//
// Implementation: Item
//

@implementation Item

- (instancetype)initWithType:(ItemType)type descriptor:(TLDescriptor *)descriptor {
    
    self = [super init];
    
    if (self) {
        _deleteProgressValue = 0;
        _type = type;
        _descriptorId = descriptor.descriptorId;
        _replyTo = descriptor.replyTo;
        _createdTimestamp = descriptor.createdTimestamp;
        _updatedTimestamp = descriptor.updatedTimestamp;
        _sentTimestamp = descriptor.sentTimestamp;
        _receivedTimestamp = descriptor.receivedTimestamp;
        _readTimestamp = descriptor.readTimestamp;
        _deletedTimestamp = descriptor.deletedTimestamp;
        _peerDeletedTimestamp = descriptor.peerDeletedTimestamp;
        _expireTimeout = descriptor.expireTimeout;
        _corners = ITEM_TOP_LEFT | ITEM_TOP_RIGHT | ITEM_BOTTOM_LEFT | ITEM_BOTTOM_RIGHT;
        _state = ItemStateDefault;
        if (_peerDeletedTimestamp && _deletedTimestamp) {
            _state = ItemStateBothDeleted;
        } else if (_peerDeletedTimestamp) {
            _state = ItemStatePeerDeleted;
        } else if (_deletedTimestamp) {
            _state = ItemStateDeleted;
        } else if (_receivedTimestamp == -1) {
            _state = ItemStateNotSent;
        } else if (_readTimestamp) {
            if (_readTimestamp != -1) {
                _state = ItemStateRead;
            }
        } else if (_receivedTimestamp) {
            _state = ItemStateReceived;
        } else {
            _state = ItemStateSending;
        }
        _visibleAvatar = NO;
        _copyAllowed = NO;
        _selected = NO;
        _forwarded = [descriptor getDescriptorAnnotationWithType:TLDescriptorAnnotationTypeForwarded] != nil;
        _likeDescriptorAnnotations = [descriptor getDescriptorAnnotationsWithType:TLDescriptorAnnotationTypeLike];
        _mode = ItemModeNormal;
        _replyAllowed = YES;

        _deleteProgressValue = 0;
    }
    return self;
}

- (instancetype)initWithType:(ItemType)type descriptor:(TLDescriptor *)descriptor replyToDescriptor:(TLDescriptor *)replyToDescriptor {
    
    self = [self initWithType:type descriptor:descriptor];
    
    if (self) {
        _replyToDescriptor = replyToDescriptor;
    }
    
    return self;
}

- (instancetype)initWithType:(ItemType)type descriptorId:(TLDescriptorId *)descriptorId timestamp:(int64_t)timestamp {
    
    self = [super init];
    
    if (self) {
        _deleteProgressValue = 0;
        _type = type;
        _descriptorId = descriptorId;
        _createdTimestamp = timestamp;
        _updatedTimestamp = 0;
        _sentTimestamp = 0;
        _receivedTimestamp = 0;
        _readTimestamp = 0;
        _deletedTimestamp = 0;
        _peerDeletedTimestamp = 0;
        _expireTimeout = 0;
        _corners = ITEM_TOP_LEFT | ITEM_TOP_RIGHT | ITEM_BOTTOM_LEFT | ITEM_BOTTOM_RIGHT;
        _state = ItemStateDefault;
        _visibleAvatar = NO;
        _copyAllowed = NO;
        _forwarded = NO;
        _selected = NO;
        _mode = ItemModeNormal;
        _replyAllowed = YES;
        
        _deleteProgressValue = 0;
    }
    return self;
}

- (BOOL)isPeerItem {
    
    NSAssert(YES, @"abstract method");
    return NO;
}

- (BOOL)isEditedtem {
    
    return NO;
}

- (BOOL)needsUpdateReadTimestamp {
    
    return self.readTimestamp == 0 || self.readTimestamp < self.updatedTimestamp;
}

- (BOOL)isDeletedItem {
    
    return self.state == ItemStateDeleted || self.state == ItemStateBothDeleted;
}

- (BOOL)isAvailableItem {
    
    return YES;
}

- (BOOL)isFileItemExist {
    
    return YES;
}

- (BOOL)isClearLocalItem {
    
    return NO;
}

- (BOOL)isEphemeralItem {
    
    return self.expireTimeout > 0;
}

- (NSUUID *)peerTwincodeOutboundId {
    
    return nil;
}

- (BOOL)isSamePeer:(Item *)item {
    
    return self.peerTwincodeOutboundId == nil;
}

- (int64_t)timestamp {
    
    NSAssert(YES, @"abstract method");
    return -1;
}

- (CGFloat)deleteProgress {
    
    return self.deleteProgressValue;
}

- (void)startDeleteItem {
    
    if (!self.timer) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.025 target:self selector:@selector(timerFire) userInfo:nil repeats:YES];
    }
}

- (void)timerFire {
    
    if (self.deleteProgressValue >= 100) {
        self.deleteProgressValue = 100.0;
        [self.timer invalidate];
        self.timer = nil;
    }
    
    self.deleteProgressValue = self.deleteProgressValue + 0.5;
}

- (void)resetState {
    
    if (self.state != ItemStateDeleted && self.state != ItemStateBothDeleted) {
        self.state = ItemStateDefault;
    }
}

- (BOOL)hasLikeAnnotationWithValue:(int)value {
    
    for (TLDescriptorAnnotation *descriptorAnnotation in self.likeDescriptorAnnotations) {
        if (descriptorAnnotation.value == value) {
            return YES;
        }
    }
    return NO;
}

- (void)updateAnnotationsWithDescriptor:(TLDescriptor *)descriptor {
    
    self.forwarded = [descriptor getDescriptorAnnotationWithType:TLDescriptorAnnotationTypeForwarded] != nil;
    self.likeDescriptorAnnotations = [descriptor getDescriptorAnnotationsWithType:TLDescriptorAnnotationTypeLike];
}

- (void)updateTimestampsWithDescriptor:(TLDescriptor *)descriptor {
    
    self.createdTimestamp = descriptor.createdTimestamp;
    self.sentTimestamp = descriptor.sentTimestamp;
    self.expireTimeout = descriptor.expireTimeout;
    
    // Temporary fix - should be handled in the library
    if (self.receivedTimestamp <= 0 || self.receivedTimestamp < descriptor.updatedTimestamp) {
        self.receivedTimestamp = descriptor.receivedTimestamp;
    }
    if (self.readTimestamp <= 1 || self.readTimestamp < descriptor.updatedTimestamp) { // 1 is correct see in ConversationViewController
        self.readTimestamp = descriptor.readTimestamp;
    }
    
    self.updatedTimestamp = descriptor.updatedTimestamp;
    self.deletedTimestamp = descriptor.deletedTimestamp;
    self.peerDeletedTimestamp = descriptor.peerDeletedTimestamp;
        
    [self updateState];
}

- (void)updateState {

    if (self.peerDeletedTimestamp && self.deletedTimestamp) {
        self.state = ItemStateBothDeleted;
    } else if (self.peerDeletedTimestamp) {
        self.state = ItemStatePeerDeleted;
    } else if (self.deletedTimestamp) {
        self.state = ItemStateDeleted;
    } else if (self.receivedTimestamp == -1) {
        self.state = ItemStateNotSent;
    } else if (self.readTimestamp) {
        if (self.readTimestamp != -1) {
            self.state = ItemStateRead;
        } else {
            self.state = ItemStateDefault;
        }
    } else if (self.receivedTimestamp) {
        self.state = ItemStateReceived;
    } else {
        self.state = ItemStateSending;
    }
}

- (NSURL *)getURL {
    
    return nil;
}

- (NSString *)getExtension {
    
    return nil;
}

- (int64_t)getLength {
    
    return 0;
}

- (int64_t)getDuration {
    
    return 0;
}

- (int)getHeight {
    
    return 0;
}

- (int)getWidth {
    
    return 0;
}

- (NSString *)getInformation {
    
    return @"";
}

- (void)appendTo:(NSMutableString*)string {
    
    [string appendFormat:@" type:                 %u\n", self.type];
    [string appendFormat:@" descriptorId:         %@\n", self.descriptorId];
    [string appendFormat:@" createdTimestamp:     %lld\n", self.createdTimestamp];
    [string appendFormat:@" updatedTimestamp:     %lld\n", self.updatedTimestamp];
    [string appendFormat:@" sentTimestamp:        %lld\n", self.sentTimestamp];
    [string appendFormat:@" receivedTimestamp:    %lld\n", self.receivedTimestamp];
    [string appendFormat:@" readTimestamp:        %lld\n", self.readTimestamp];
    [string appendFormat:@" deletedTimestamp:     %lld\n", self.deletedTimestamp];
    [string appendFormat:@" peerDeletedTimestamp: %lld\n", self.peerDeletedTimestamp];
    [string appendString:@" corners:              "];
    if (self.corners & ITEM_TOP_LEFT) {
        [string appendString:@"|TOP_LEFT"];
    }
    if (self.corners & ITEM_TOP_RIGHT) {
        [string appendString:@"|TOP_RIGHT"];
    }
    if (self.corners & ITEM_BOTTOM_RIGHT) {
        [string appendString:@"|BOTTOM_RIGHT"];
    }
    if (self.corners & ITEM_BOTTOM_LEFT) {
        [string appendString:@"|BOTTOM_LEFT"];
    }
    [string appendString:@"\n"];
    [string appendFormat:@" state:                %u\n", self.state];
}

- (NSComparisonResult)compareWithItem:(nonnull Item *)second {

    if (self.timestamp < second.timestamp) {
        return NSOrderedAscending;
    }
    if (self.timestamp > second.timestamp) {
        return NSOrderedDescending;
    }
    
    // Peer item first.
    if (self.isPeerItem && !second.isPeerItem) {
        return NSOrderedAscending;
    }
    if (!self.isPeerItem && second.isPeerItem) {
        return NSOrderedDescending;
    }
    return self.descriptorId.sequenceId < second.descriptorId.sequenceId ? NSOrderedAscending : NSOrderedDescending;
}

#pragma mark - NSObject

- (NSString *)description {
    
    NSMutableString *string = [NSMutableString stringWithCapacity:1024];
    [string appendString:@"Item\n"];
    [self appendTo:string];
    return string;
}

@end
