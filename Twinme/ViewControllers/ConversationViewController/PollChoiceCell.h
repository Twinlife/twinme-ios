/*
 *  Copyright (c) 2026 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

//
// Interface: PollChoiceCell
//

@class UIPollResult;

@interface PollChoiceCell : UITableViewCell

- (void)bindWithPollResult:(UIPollResult *)pollResult textColor:(UIColor *)textColor;

@end
