/*
 *  Copyright (c) 2023 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

@class Item;

//
// Interface: DocumentCell
//

@interface DocumentCell : UICollectionViewCell

- (void)bindWithItem:(Item *)item isSelectable:(BOOL)isSelectable;

@end
