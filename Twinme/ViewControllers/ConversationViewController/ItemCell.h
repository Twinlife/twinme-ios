/*
 *  Copyright (c) 2017-2021 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Christian Jacquemot (Christian.Jacquemot@twinlife-systems.com)
 *   Chedi Baccari (Chedi.Baccari@twinlife-systems.com)
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 *   Stephane Carrez (Stephane.Carrez@twin.life)
 */

@class Item;
@class TLDescriptorId;
@class TLDescriptorAnnotation;
@class ConversationViewController;
@class AsyncImageLoader;
@class AsyncVideoLoader;
@class AsyncManager;

@protocol DeleteActionDelegate;
@protocol MenuActionDelegate;
@protocol ReplyItemDelegate;
@protocol SelectItemDelegate;
@protocol ReactionViewDelegate;

//
// Protocol: ReplyItemDelegate
//

@protocol ReplyItemDelegate <NSObject>

- (void)didSelectReplyTo:(TLDescriptorId *)replyTo;

- (void)swipeToReplyToItem:(Item *)item;

@end

//
// Protocol: AnnotationActionDelegate
//

@protocol AnnotationActionDelegate <NSObject>

- (void)didTapAnnotation:(TLDescriptorId *)descriptord;

@end

//
// Interface: ItemCell
//

@interface ItemCell : UITableViewCell

@property (weak, nonatomic) Item *item;
@property (weak, nonatomic) id<DeleteActionDelegate> deleteActionDelegate;
@property (weak, nonatomic) id<MenuActionDelegate> menuActionDelegate;
@property (weak, nonatomic) id<ReplyItemDelegate> replyItemDelegate;
@property (weak, nonatomic) id<SelectItemDelegate> selectItemDelegate;
@property (weak, nonatomic) id<ReactionViewDelegate> reactionViewDelegate;
@property (strong, nonatomic) UIPanGestureRecognizer *panGestureRecognizer;
@property (strong, nonatomic) AsyncImageLoader *replyImageLoader;
@property (strong, nonatomic) AsyncVideoLoader *replyVideoLoader;
@property (nonatomic) BOOL isSelectItemMode;

- (void)bindWithItem:(Item *)item conversationViewController:(ConversationViewController *)conversationViewController;

- (void)bindWithItem:(Item *)item conversationViewController:(ConversationViewController *)conversationViewController asyncManager:(AsyncManager *)asyncManager;

- (void)startDeleteAnimation;

- (void)deleteEphemeralItem;

- (void)onSwipeInsideContentView:(UIPanGestureRecognizer *)panGesture;

- (CGFloat)annotationWidth:(TLDescriptorAnnotation *)descriptorAnnotation;

- (CGFloat)annotationCollectionWidth;

@end
