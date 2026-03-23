/*
 *  Copyright (c) 2024-2026 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <Twinlife/TLConversationService.h>

//
// Interface: UIAnnotation
//


@class UIReaction;

@interface UIAnnotation : NSObject

@property (nonatomic) TLDescriptorAnnotationType annotationType;
@property (nonatomic, nullable) UIReaction *uiReaction;
@property (nonatomic, nonnull) NSString *name;
@property (nonatomic, nonnull) UIImage *avatar;
@property (nonatomic) long timestamp;
@property (nonatomic) int orderPriority;

- (nonnull instancetype)initWithType:(TLDescriptorAnnotationType)annotationType reaction:(nullable UIReaction *)uiReaction name:(nonnull NSString *)name avatar:(nonnull UIImage *)avatar timestamp:(long)timestamp;

@end
