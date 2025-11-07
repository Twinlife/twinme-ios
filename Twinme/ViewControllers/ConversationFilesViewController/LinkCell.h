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
// Interface: LinkCell
//

@interface LinkCell : UICollectionViewCell

- (void)bindWithItem:(Item *)item asyncManager:(AsyncManager *)asyncManager  isSelectable:(BOOL)isSelectable showPreview:(BOOL)showPreview;

@end
