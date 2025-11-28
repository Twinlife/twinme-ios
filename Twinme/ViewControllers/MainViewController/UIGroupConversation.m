/*
 *  Copyright (c) 2018-2020 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <Twinlife/TLConversationService.h>

#import <Twinme/TLGroupMember.h>
#import <Twinme/TLContact.h>
#import <Twinme/TLMessage.h>

#import "UIGroupConversation.h"
#import "UIConversation.h"

#import <Utils/NSString+Utils.h>

#import <TwinmeCommon/Design.h>

//
// Implementation: UIGroupConversation
//

#undef LOG_TAG
#define LOG_TAG @"UIGroupConversation"

@implementation UIGroupConversation : UIConversation

- (instancetype)initWithConversationId:(NSUUID *)conversationId uiContact:(UIContact *)uiContact groupConversationStateType:(TLGroupConversationStateType)groupConversationStateType {
    
    self = [super init];
    
    if (self) {
        self.conversationId = conversationId;
        self.uiContact = uiContact;
        _groupMemberCount = 0;
        _groupConversationStateType = groupConversationStateType;
    }
    return self;
}

- (NSAttributedString *)getLastMessage {
    
    NSAttributedString *lastMessage = [[NSAttributedString alloc]initWithString:@""];
    
    if (self.lastDescriptor) {
        NSString *memberName = @"";
        for (TLGroupMember *member in self.groupMembers) {
            if ([self.lastDescriptor isTwincodeOutbound:member.peerTwincodeOutboundId]) {
                if (member.memberName && ![member.memberName isEqual:@""]) {
                    memberName = member.memberName;
                }
                break;
            }
        }
        
        switch (self.lastDescriptor.getType) {
            case TLDescriptorTypeObjectDescriptor: {
                TLObjectDescriptor *objectDescriptor = (TLObjectDescriptor *)self.lastDescriptor;
                NSString *message = objectDescriptor.message;
                @try {
                    lastMessage = [NSString formatText:message fontSize:Design.FONT_REGULAR28.pointSize fontColor:[UIColor colorWithRed:115./255. green:138./255. blue:161./255. alpha:1.0] fontSearch:nil];
                } @catch (NSException *exception) {
                    lastMessage = [[NSAttributedString alloc]initWithString:message];
                }
                
                break;
            }
            case TLDescriptorTypeImageDescriptor: {
                lastMessage = [[NSAttributedString alloc]initWithString:TwinmeLocalizedString(@"notification_center_photo_message_received", nil)];
                break;
            }
                
            case TLDescriptorTypeVideoDescriptor: {
                lastMessage = [[NSAttributedString alloc]initWithString:TwinmeLocalizedString(@"notification_center_video_message_received", nil)];
                break;
            }
                
            case TLDescriptorTypeAudioDescriptor: {
                lastMessage = [[NSAttributedString alloc]initWithString:TwinmeLocalizedString(@"notification_center_audio_message_received", nil)];
                break;
            }
                
            case TLDescriptorTypeNamedFileDescriptor: {
                lastMessage = [[NSAttributedString alloc]initWithString:TwinmeLocalizedString(@"notification_center_file_message_received", nil)];
                break;
            }
                
            case TLDescriptorTypeCallDescriptor: {
                TLCallDescriptor *callDescriptor = (TLCallDescriptor *)self.lastDescriptor;
                if (!callDescriptor.isAccepted && callDescriptor.isIncoming) {
                    lastMessage = [[NSAttributedString alloc]initWithString:TwinmeLocalizedString(@"history_view_controller_missed_call", nil)];
                } else if (callDescriptor.isIncoming) {
                    lastMessage = [[NSAttributedString alloc]initWithString:TwinmeLocalizedString(@"history_view_controller_incoming_call", nil)];
                } else {
                    lastMessage = [[NSAttributedString alloc]initWithString:TwinmeLocalizedString(@"history_view_controller_outgoing_call", nil)];
                }
                
                break;
            }
                
            case TLDescriptorTypeClearDescriptor: {
                lastMessage = [[NSAttributedString alloc]initWithString:TwinmeLocalizedString(@"notification_center_message_cleanup_conversation", nil)];
                break;
            }
                
            case TLDescriptorTypeInvitationDescriptor:
            case TLDescriptorTypeTwincodeDescriptor: {
                lastMessage = [[NSAttributedString alloc]initWithString:TwinmeLocalizedString(@"notification_center_group_invitation_received", nil)];
                break;
            }
            default:
                break;
        }
        
        if (memberName) {
            NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]initWithString:memberName];
            if (![memberName isEqual:@""]) {
                [attributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:@" : "]];
            }
            [attributedString appendAttributedString:lastMessage];
            return attributedString;
        } else {
            return lastMessage;
        }
    } else if (self.groupConversationStateType == TLGroupConversationStateCreated) {
        lastMessage = [[NSAttributedString alloc]initWithString:TwinmeLocalizedString(@"conversation_view_controller_invitation_accepted", nil)];
    }
    
    return lastMessage;
}

- (void)setVisibleMembers:(NSMutableArray *)uiMemberList {
    
    self.groupMemberTwincodeOutboundIds = uiMemberList;
    self.groupMembers = nil;
    self.groupAvatars = [[NSMutableArray alloc] init];
}

- (void)addMembersAvatar:(UIImage *)groupMemberAvatar {
    
    [self.groupAvatars addObject:groupMemberAvatar];
}

- (NSMutableArray *)updateVisibleMembers:(NSMutableDictionary<NSUUID*,TLGroupMember*> *)members groupMemberTwincodeId:(NSUUID *)groupMemberTwincodeId groupMemberAvatar:(UIImage *)groupMemberAvatar {
    
    // This member was not found, remove it from our list.
    if (groupMemberTwincodeId && ![members objectForKey:groupMemberTwincodeId]) {
        [self.groupMemberTwincodeOutboundIds removeObject:groupMemberTwincodeId];
    }

    if (groupMemberAvatar) {
        [self.groupAvatars addObject:groupMemberAvatar];
    }

    NSMutableArray *result = [[NSMutableArray alloc] init];
    self.groupMembers = [[NSMutableArray alloc] init];
    for (NSUUID *member in self.groupMemberTwincodeOutboundIds) {
        if ([members objectForKey:member]) {
            [self.groupMembers addObject:[members objectForKey:member]];
        } else {
            [result addObject:member];
        }
    }
    
    return result;
}

- (NSString *)getInformation {
    
    if (!self.groupMembers || self.groupMembers.count == 0) {
        return @"";
    }
    
    NSString *result = @"";
    for (TLGroupMember *member in self.groupMembers) {
        if (member.name) {
            if ([result length] > 0) {
                result = [result stringByAppendingString:@", "];
            }
            result = [result stringByAppendingString:member.name];
        }
    }
    return result;
}

@end
