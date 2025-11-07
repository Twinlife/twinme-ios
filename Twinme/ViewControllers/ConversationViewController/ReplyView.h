/*
 *  Copyright (c) 2021 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

@class Item;
@class AsyncManager;
@class TLTwinmeContext;

@protocol ReplyViewDelegate;

//
// Interface: ReplyView
//

@interface ReplyView : UIView

@property (weak, nonatomic) id<ReplyViewDelegate> replyViewDelegate;

- (instancetype)initWithContext:(TLTwinmeContext *)twinmeContext;

- (void)showReply:(Item *)item contactName:(NSString *)contactName;

- (void)finish;

- (void)showOverlayView;

- (void)hideOverlayView;

@end
