/*
 *  Copyright (c) 2026 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

typedef enum {
    PollResultItemTypeChoice,
    PollResultItemTypeVoter
} PollResultItemType;


//
// Interface: UIPollResult
//

@interface PollResultItem : NSObject

@property (nonatomic, nonnull) NSString *title;
@property (nonatomic, nullable) UIImage *avatar;
@property (nonatomic) PollResultItemType pollResultItemType;

- (nonnull instancetype)initWithType:(PollResultItemType)pollResultItemType title:(nonnull NSString *)title avatar:(nullable UIImage *)avatar;

@end
