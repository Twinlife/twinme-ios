/*
 *  Copyright (c) 2026 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "Item.h"

//
// Interface: PollItem
//

@class TLPollDescriptor;
@class TLChoice;

@interface PollItem : Item

@property (nonnull) TLPollDescriptor *pollDescriptor;
@property (nonnull) NSDictionary<NSUUID *, NSArray<TLChoice *> *> *votes;

- (nonnull instancetype)initWithPollDescriptor:(nonnull TLPollDescriptor *)pollDescriptor;

- (void)updateVotesWithDescriptor:(nonnull TLPollDescriptor *)pollDescriptor;

@end
