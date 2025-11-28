/*
 *  Copyright (c) 2022 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

//
// Interface: AddCommentCell
//

@protocol AddCommentDelegate;

@class TLSpaceSettings;

@interface AddCommentCell : UITableViewCell

@property (weak, nonatomic) id<AddCommentDelegate> addCommentDelegate;

- (void)bind:(nonnull TLSpaceSettings *)spaceSettings;

@end
