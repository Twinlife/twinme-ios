/*
 *  Copyright (c) 2024 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

//
// Interface: UIAnnotation
//

@class UIReaction;

@interface UIAnnotation : NSObject

@property (nonatomic, nonnull) UIReaction *uiReaction;
@property (nonatomic, nonnull) NSString *name;
@property (nonatomic, nonnull) UIImage *avatar;

- (nonnull instancetype)initWithReaction:(nonnull UIReaction *)uiReaction name:(nonnull NSString *)name avatar:(nonnull UIImage *)avatar;

@end
