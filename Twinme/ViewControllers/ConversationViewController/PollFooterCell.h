/*
 *  Copyright (c) 2026 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

//
// Protocol: PollFooterCellDelegate
//

@protocol PollFooterCellDelegate <NSObject>

- (void)didTapPollFooter;

@end

//
// Interface: PollFooterCell
//

@interface PollFooterCell : UITableViewCell

@property (weak, nonatomic) id<PollFooterCellDelegate> pollFooterCellDelegate;

- (void)bind:(BOOL)canAddChoice;

@end
