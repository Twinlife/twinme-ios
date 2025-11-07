/*
 *  Copyright (c) 2023-2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "UIReaction.h"

#import <TwinmeCommon/Design.h>

//
// Implementation: UIReaction
//

@implementation UIReaction

- (instancetype)initWithReaction:(ReactionType)reactionType image:(UIImage *)image {
    
    self = [super init];
    
    if (self) {
        _reactionType = reactionType;
        _reactionImage = image;
        _reactionTintColor = [UIColor clearColor];
    }
    return self;
}

- (instancetype)initWithDescriptorAnnotationValue:(int)value {
    
    self = [super init];
    
    if (self) {
        _reactionTintColor = [UIColor clearColor];
        [self initTypeAndImage:value];
    }
    return self;
}

- (void)initTypeAndImage:(int)value {
    
    switch (value) {
        case ReactionTypeLike:
            self.reactionType = ReactionTypeLike;
            self.reactionImage = [UIImage imageNamed:@"ReactionLike"];
            break;
            
        case ReactionTypeUnlike:
            self.reactionType = ReactionTypeUnlike;
            self.reactionImage = [UIImage imageNamed:@"ReactionUnlike"];
            break;
            
        case ReactionTypeLove:
            self.reactionType = ReactionTypeLove;
            self.reactionImage = [UIImage imageNamed:@"ReactionLove"];
            break;
            
        case ReactionTypeCry:
            self.reactionType = ReactionTypeCry;
            self.reactionImage = [UIImage imageNamed:@"ReactionCry"];
            break;
            
        case ReactionTypeFire:
            self.reactionType = ReactionTypeFire;
            self.reactionImage = [UIImage imageNamed:@"ReactionFire"];
            break;
            
        case ReactionTypeHunger:
            self.reactionType = ReactionTypeHunger;
            self.reactionImage = [UIImage imageNamed:@"ReactionHunger"];
            break;
            
        case ReactionTypeScreaming:
            self.reactionType = ReactionTypeScreaming;
            self.reactionImage = [UIImage imageNamed:@"ReactionScreaming"];
            break;
            
        case ReactionTypeSurprised:
            self.reactionType = ReactionTypeSurprised;
            self.reactionImage = [UIImage imageNamed:@"ReactionSurprised"];
            break;
            
        default:
            self.reactionType = -1;
            self.reactionImage = [UIImage imageNamed:@"ReactionUnknown"];
            self.reactionTintColor = Design.BLACK_COLOR;
            break;
    }
}

+ (nonnull UIImage *)getNotificationImageWithReactionType:(ReactionType)reactionType {
    
    if (reactionType < 0 || reactionType >= ReactionTypeCount) {
        return [UIImage imageNamed:@"ReactionUnknown"];
    }
    
    UIImage *reactionImage;
    
    switch (reactionType) {
        case ReactionTypeLike:
            reactionImage = [UIImage imageNamed:@"NotificationReactionLike"];
            break;
            
        case ReactionTypeUnlike:
            reactionImage = [UIImage imageNamed:@"NotificationReactionUnlike"];
            break;
            
        case ReactionTypeLove:
            reactionImage = [UIImage imageNamed:@"NotificationReactionLove"];
            break;
            
        case ReactionTypeCry:
            reactionImage = [UIImage imageNamed:@"NotificationReactionCry"];
            break;
            
        case ReactionTypeFire:
            reactionImage = [UIImage imageNamed:@"NotificationReactionFire"];
            break;
            
        case ReactionTypeHunger:
            reactionImage = [UIImage imageNamed:@"NotificationReactionHunger"];
            break;
            
        case ReactionTypeScreaming:
            reactionImage = [UIImage imageNamed:@"NotificationReactionScreaming"];
            break;
            
        case ReactionTypeSurprised:
            reactionImage = [UIImage imageNamed:@"NotificationReactionSurprised"];
            break;
            
        default:
            reactionImage = [UIImage imageNamed:@"ReactionUnknown"];
            break;
    }
    
    return reactionImage;
}

+ (nonnull UIColor *)getTintColorReactionType:(ReactionType)reactionType {
    
    if (reactionType < 0 || reactionType >= ReactionTypeCount) {
        return Design.BLACK_COLOR;
    }
    
    return [UIColor clearColor];
}

@end
