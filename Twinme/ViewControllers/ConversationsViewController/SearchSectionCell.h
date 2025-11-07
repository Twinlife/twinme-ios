/*
 *  Copyright (c) 2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

//
// Interface: SearchSectionCell
//

@protocol SearchSectionDelegate;
@class UICustomTab;

@interface SearchSectionCell : UITableViewCell

@property (weak, nonatomic) id<SearchSectionDelegate> searchSectionDelegate;

- (void)bindWithSearchFilter:(UICustomTab *)customTab showAllAction:(BOOL)showAllAction;

@end
