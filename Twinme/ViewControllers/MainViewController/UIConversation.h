/*
 *  Copyright (c) 2018-2020 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

@class UIContact;
@class TLDescriptor;

@interface UIConversation : NSObject

@property (nonatomic) NSUUID *conversationId;
@property (nonatomic) UIContact *uiContact;
@property (nonatomic) TLDescriptor *lastDescriptor;

- (instancetype)initWithConversationId:(NSUUID *)conversationId uiContact:(UIContact *)uiContact;

- (NSString *)getInformation;

- (NSAttributedString *)getLastMessage;

- (NSString *)getMessage;

- (NSString *)getLastMessageDate;

- (double)usageScore;

- (int64_t)lastMessageDate;

- (void)setDescriptor:(TLDescriptor *)descriptor;

- (BOOL)isLastDescriptorUnread;

- (BOOL)isLocalDescriptor;

@end
