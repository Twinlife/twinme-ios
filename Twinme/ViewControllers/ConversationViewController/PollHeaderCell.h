/*
 *  Copyright (c) 2026 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

//
// Protocol: PollHeaderCellDelegate
//

@protocol PollHeaderCellDelegate <NSObject>

- (void)didUpdateQuestion:(nonnull NSString *)text;

- (void)didEndEditing:(nonnull NSString *)text;

- (void)didUpdateAllowMultipleChoice:(BOOL)allowMutlipleChoice;

@end

//
// Interface: PollHeaderCell
//

@interface PollHeaderCell : UITableViewHeaderFooterView

@property (weak, nonatomic) id<PollHeaderCellDelegate> pollHeaderCellDelegate;

- (void)bind:(nonnull NSString *)question allowMultipleChoice:(BOOL)allowMultipleChoice beginEditing:(BOOL)beginEditing;

@end
