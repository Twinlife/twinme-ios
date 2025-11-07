/*
 *  Copyright (c) 2018-2020 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

@class TLGroupMember;

#import "UIConversation.h"

@interface UIGroupConversation : UIConversation

@property (nonatomic) NSUInteger groupMemberCount;
@property (nonatomic) NSMutableArray *groupMembers;
@property (nonatomic) NSMutableArray *groupMemberTwincodeOutboundIds;
@property (nonatomic) NSMutableArray<UIImage *> *groupAvatars;
@property (nonatomic) TLGroupConversationStateType groupConversationStateType;

- (instancetype)initWithConversationId:(NSUUID *)conversationId uiContact:(UIContact *)uiContact groupConversationStateType:(TLGroupConversationStateType)groupConversationStateType;

- (void)setVisibleMembers:(NSMutableArray *)uiMemberList;

- (NSMutableArray *)updateVisibleMembers:(NSMutableDictionary<NSUUID*,TLGroupMember*> *)members groupMemberTwincodeId:(NSUUID *)groupMemberTwincodeId groupMemberAvatar:(UIImage *)groupMemberAvatar;

- (void)addMembersAvatar:(UIImage *)groupMemberAvatar;

@end
