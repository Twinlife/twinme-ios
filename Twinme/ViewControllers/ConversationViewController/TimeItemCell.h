/*
 *  Copyright (c) 2017-2021 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Christian Jacquemot (Christian.Jacquemot@twinlife-systems.com)
 *   Chedi Baccari (Chedi.Baccari@twinlife-systems.com)
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "ItemCell.h"

//
// Interface: TimeItemCell
//

@class TimeItem;
@class ConversationViewController;
@protocol MenuActionDelegate;

@interface TimeItemCell : UITableViewCell

@property (weak, nonatomic) Item *item;
@property (nonatomic) UILabel *messageLabel;
@property (nonatomic) UIView *overlayView;
@property (weak, nonatomic) id<MenuActionDelegate> menuActionDelegate;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier topMargin:(CGFloat)topMargin bottomMargin:(CGFloat)bottomMargin;

- (void)bindWithItem:(Item *)item conversationViewController:(ConversationViewController *)conversationViewController;

@end
