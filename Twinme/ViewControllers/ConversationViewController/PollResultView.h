/*
 *  Copyright (c) 2026 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "AbstractMenuView.h"

//
// Interface: PollResultView
//

//
// Protocol: AnnotationsViewDelegate
//

@class PollResultView;

@protocol PollResultViewDelegate <NSObject>

- (void)cancelPollResultView:(PollResultView *)pollResultView;

@end

@interface PollResultView : AbstractMenuView

@property (weak, nonatomic) id<PollResultViewDelegate> pollResultViewDelegate;

- (void)openMenu:(NSString *)title results:(NSMutableArray *)results;

@end
