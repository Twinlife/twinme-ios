/*
 *  Copyright (c) 2023 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

//
// Protocol: ItemSelectedActionViewDelegate
//

@protocol ItemSelectedActionViewDelegate <NSObject>

- (void)didTapShareAction;

- (void)didTapDeleteAction;

@end

//
// Interface: ItemSelectedActionView
//

@interface ItemSelectedActionView : UIView

@property (weak, nonatomic) id<ItemSelectedActionViewDelegate> itemSelectedActionViewDelegate;

- (void)updateSelectedItems:(int)count;

@end
