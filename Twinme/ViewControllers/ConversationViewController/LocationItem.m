/*
 *  Copyright (c) 2019-2021 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <Twinlife/TLConversationService.h>

#import "LocationItem.h"

//
// Implementation: LocationItem
//

@implementation LocationItem

- (instancetype)initWithGeolocationDescriptor:(TLGeolocationDescriptor *)geolocationDescriptor replyToDescriptor:(TLDescriptor *)replyToDescriptor  {
    
    self = [super initWithType:ItemTypeLocation descriptor:geolocationDescriptor replyToDescriptor:replyToDescriptor];
    
    if (self) {
        _geolocationDescriptor = geolocationDescriptor;
    }
    return self;
}

- (void)updateGeolocationDescriptor:(TLGeolocationDescriptor *)geolocationDescriptor {
    
    self.geolocationDescriptor = geolocationDescriptor;
}

#pragma mark - Item

- (BOOL)isPeerItem {
    
    return NO;
}

- (int64_t)timestamp {
    
    return self.createdTimestamp;
}

#pragma mark - NSObject

- (NSString *)description {
    
    NSMutableString *string = [NSMutableString stringWithCapacity:1024];
    [string appendString:@"LocationItem\n"];
    [self appendTo:string];
    return string;
}

@end

