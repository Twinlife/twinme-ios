/*
 *  Copyright (c) 2023 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

@class Item;
@class AsyncManager;

//
// Interface: MediaCell
//

@interface MediaCell : UICollectionViewCell

- (void)bindWithItem:(Item *)item asyncManager:(AsyncManager *)asyncManager size:(CGFloat)size isSelectable:(BOOL)isSelectable;

@end
