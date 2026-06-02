/*
 *  Copyright (c) 2026 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */


@class UIPollChoice;

//
// Protocol: PollAddChoiceCellDelegate
//

@protocol PollAddChoiceCellDelegate <NSObject>

- (void)didUpdateChoice:(nonnull UIPollChoice *)pollChoice text:(nonnull NSString *)text;

- (void)didReturnChoice:(nonnull UIPollChoice *)pollChoice;

- (void)didEndEditingChoice:(nonnull UIPollChoice *)pollChoice;

@end

//
// Interface: PollAddChoiceCell
//

@interface PollAddChoiceCell : UITableViewCell

@property (weak, nonatomic) id<PollAddChoiceCellDelegate> pollAddChoiceCellDelegate;

- (void)bindWithChoice:(nonnull UIPollChoice *)pollChoice;

@end
