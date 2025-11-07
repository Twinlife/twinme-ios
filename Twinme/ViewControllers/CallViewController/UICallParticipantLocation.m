/*
 *  Copyright (c) 2024 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "UICallParticipantLocation.h"

#import <MapKit/MapKit.h>

@implementation UICallParticipantLocation

- (nonnull instancetype)initWithCallParticipant:(int)participantId name:(nullable NSString *)name avatar:(nullable UIImage *)avatar latitude:(double)latitude longitude:(double)longitude {
    
    self = [super init];
    
    if (self) {
        _participantId = participantId;
        _name = name;
        _avatar = avatar;
        _latitude = latitude;
        _longitude = longitude;
    }
    return self;
}

- (void)updateName:(nullable NSString *)name avatar:(nullable UIImage *)avatar {
    
    self.name = name;
    self.avatar = avatar;
}

- (void)updateLatitude:(double)latitude longitude:(double)longitude {
    
    self.latitude = latitude;
    self.longitude = longitude;
}

- (void)updateAnnotation:(MKAnnotationView *)annotationView {
    
    self.annotationView = annotationView;
}

- (BOOL)isLocaleLocation {
    
    return self.participantId == -1;
}

@end
