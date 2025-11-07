/*
 *  Copyright (c) 2023-2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

typedef enum {
    ReactionTypeLike,
    ReactionTypeUnlike,
    ReactionTypeLove,
    ReactionTypeCry,
    ReactionTypeHunger,
    ReactionTypeSurprised,
    ReactionTypeScreaming,
    ReactionTypeFire,
    ReactionTypeCount
} ReactionType;

//
// Interface: UIReaction
//

@interface UIReaction : NSObject

@property (nonatomic) ReactionType reactionType;
@property (nonatomic, nonnull) UIImage *reactionImage;
@property (nonatomic, nonnull) UIColor *reactionTintColor;

- (nonnull instancetype)initWithReaction:(ReactionType)reactionType image:(nonnull UIImage *)image;

- (nonnull instancetype)initWithDescriptorAnnotationValue:(int)value;

+ (nonnull UIImage *)getNotificationImageWithReactionType:(ReactionType)reactionType;

+ (nonnull UIColor *)getTintColorReactionType:(ReactionType)reactionType;

@end
