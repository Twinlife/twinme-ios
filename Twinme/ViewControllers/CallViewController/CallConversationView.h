/*
 *  Copyright (c) 2024 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <Twinlife/TLConversationService.h>

//
// Protocol: CallConversationDelegate
//

@protocol CallConversationDelegate <NSObject>

- (void)closeConversation;

- (void)sendMessage:(NSString *)text;

- (void)readMessage:(TLDescriptorId *)descriptorId;

@end

//
// Interface: CallConversationView
//

@class Item;

@interface CallConversationView : UIView

@property (weak, nonatomic) id<CallConversationDelegate> callConversationDelegate;

- (void)addDescriptor:(TLDescriptor *)descriptor isLocal:(BOOL)isLocal needsReload:(BOOL)needsReload name:(NSString *)name;

- (void)reloadData;

- (CGFloat)getTopMarginWithMask:(int)mask item:(Item *)item;

- (CGFloat)getBottomMarginWithMask:(int)mask item:(Item *)item;

- (CGFloat)getRadiusWithMask:(int)mask;

- (BOOL)hasDescriptors;

@end
