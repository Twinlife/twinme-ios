/*
 *  Copyright (c) 2023 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

//
// Interface: ReactionCell
//

@class UIReaction;

@interface ReactionCell : UICollectionViewCell

- (void)bindWithReaction:(UIReaction *)uiReaction;

@end
