/*
 *  Copyright (c) 2024 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

@class TLGeolocationDescriptor;
@class CallParticipant;
@class MKAnnotationView;

@interface UICallParticipantLocation : NSObject

@property (nonatomic) int participantId;
@property (nonatomic, nullable) UIImage *avatar;
@property (nonatomic, nullable) NSString *name;
@property (nonatomic) double latitude;
@property (nonatomic) double longitude;
@property (nonatomic, nullable) MKAnnotationView *annotationView;


- (nonnull instancetype)initWithCallParticipant:(int)participantId name:(nullable NSString *)name avatar:(nullable UIImage *)avatar latitude:(double)latitude longitude:(double)longitude;

- (BOOL)isLocaleLocation;

- (void)updateName:(nullable NSString *)name avatar:(nullable UIImage *)avatar;

- (void)updateLatitude:(double)latitude longitude:(double)longitude;

- (void)updateAnnotation:(nullable MKAnnotationView *)annotationView;
 
@end
