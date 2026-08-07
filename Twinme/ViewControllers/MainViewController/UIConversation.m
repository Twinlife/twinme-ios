/*
 *  Copyright (c) 2018-2024 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <Twinlife/TLConversationService.h>

#import <Twinme/TLTwinmeContext.h>
#import <Twinme/TLContact.h>
#import <Twinme/TLGroup.h>
#import <Twinme/TLMessage.h>

#import <Notification/NotificationSettings.h>
#import <Utils/NSString+Utils.h>

#import "UIConversation.h"
#import "UIContact.h"

#import <TwinmeCommon/Design.h>

#import "MenuConversationShorcutView.h"

//
// Implementation: UIConversation
//

@implementation UIConversation : NSObject

- (instancetype)initWithConversationId:(NSUUID *)conversationId uiContact:(UIContact *)uiContact {
    
    self = [super init];
    
    if (self) {
        _conversationId = conversationId;
        _uiContact = uiContact;
    }
    return self;
}

- (void)setDescriptor:(TLDescriptor *)descriptor {
    
    self.lastDescriptor = descriptor;
}

- (NSString *)getInformation {
    return @"";
}

- (NSString *)getMessage {
        
    if (self.lastDescriptor && self.lastDescriptor.getType == TLDescriptorTypeObjectDescriptor) {
        TLObjectDescriptor *objectDescriptor = (TLObjectDescriptor *)self.lastDescriptor;
        return objectDescriptor.message;
    }
    
    return @"";
}

- (NSAttributedString *)getLastMessage {
    
    NSAttributedString *lastMessage = [[NSAttributedString alloc]initWithString:@""];
    
    if (self.lastDescriptor) {
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
                
            case TLDescriptorTypePollDescriptor: {
                lastMessage = [[NSAttributedString alloc]initWithString:TwinmeLocalizedString(@"notification_center_poll_message_received", nil)];
                break;
            }
                
            case TLDescriptorTypeCallDescriptor: {
                TLCallDescriptor *callDescriptor = (TLCallDescriptor *)self.lastDescriptor;
            
                if (!callDescriptor.isAccepted && callDescriptor.isIncoming) {
                    lastMessage = [[NSAttributedString alloc]initWithString:TwinmeLocalizedString(@"calls_view_missed_call", nil)];
                } else if (callDescriptor.isIncoming) {
                    lastMessage = [[NSAttributedString alloc]initWithString:TwinmeLocalizedString(@"calls_view_incoming_call", nil)];
                } else {
                    lastMessage = [[NSAttributedString alloc]initWithString:TwinmeLocalizedString(@"calls_view_outgoing_call", nil)];
                }
                
                break;
            }
                
            case TLDescriptorTypeClearDescriptor: {
                lastMessage = [[NSAttributedString alloc]initWithString:TwinmeLocalizedString(@"notification_center_cleanup_conversation", nil)];
                break;
            }
                
            case TLDescriptorTypeInvitationDescriptor:
                lastMessage = [[NSAttributedString alloc]initWithString:TwinmeLocalizedString(@"notification_center_invitation_group_received", nil)];
                break;
                
            case TLDescriptorTypeTwincodeDescriptor: {
                TLTwincodeDescriptor *twincodeDescriptor = (TLTwincodeDescriptor *)self.lastDescriptor;
                if ([twincodeDescriptor.schemaId isEqual:[TLContactShareDescriptor CONTACT_SHARE_SCHEMA_ID]]) {
                    lastMessage = [[NSAttributedString alloc]initWithString:TwinmeLocalizedString(@"notification_center_connection_request", nil)];
                } else {
                    lastMessage = [[NSAttributedString alloc]initWithString:TwinmeLocalizedString(@"notification_center_invitation_received", nil)];
                }
                break;
            }
                
            case TLDescriptorTypeContactShareDescriptor: {
                TLContactShareDescriptor *contactShareDescriptor = (TLContactShareDescriptor *)self.lastDescriptor;
                if ([self isLocalDescriptor]) {
                    lastMessage = [[NSAttributedString alloc]initWithString:[NSString stringWithFormat:TwinmeLocalizedString(@"conversation_view_share_contact_item_local_message", nil), self.uiContact.name, contactShareDescriptor.name]];
                } else {
                    lastMessage = [[NSAttributedString alloc]initWithString:[NSString stringWithFormat:TwinmeLocalizedString(@"conversation_view_share_contact_item_peer_message", nil), contactShareDescriptor.name]];
                }
            }
                
            default:
                break;
        }
    }
    
    return lastMessage;
}

- (NSString *)getLastMessageDate {
    
    NSString *dateMessage = @"";
    
    if (self.lastDescriptor) {
        dateMessage = [NSString formatTimeInterval:self.lastDescriptor.createdTimestamp / 1000];
    }
    
    return dateMessage;
}

- (double)usageScore {
    
    return [self.uiContact usageScore];
}

- (int64_t)lastMessageDate {
    
    if (self.lastDescriptor) {
        return self.lastDescriptor.createdTimestamp;
    }
    
    return [self.uiContact lastMessageDate];
}

- (BOOL)isLastDescriptorUnread {
    
    return self.lastDescriptor && self.lastDescriptor.readTimestamp == 0 && ![self isLocalDescriptor];
}

- (BOOL)isLocalDescriptor {
    
    return [self.lastDescriptor isTwincodeOutbound:self.uiContact.contact.twincodeOutboundId];
}

- (BOOL)isSilentMode {
    
    BOOL silentMode = NO;
    int64_t silentExpiration;
    
    if ([self.uiContact.contact isKindOfClass:[TLGroup class]]) {
        TLGroup * group = (TLGroup *)self.uiContact.contact;
        silentMode = [group getBooleanWithName:PROPERTY_CONVERSATION_SILENT_MODE defaultValue:NO];
        silentExpiration = [group getNumberWithName:PROPERTY_CONVERSATION_SILENT_MODE_EXPIRATION defaultValue:0];
    } else {
        TLContact *contact = (TLContact *)self.uiContact.contact;
        silentMode = [contact getBooleanWithName:PROPERTY_CONVERSATION_SILENT_MODE defaultValue:NO];
        silentExpiration = [contact getNumberWithName:PROPERTY_CONVERSATION_SILENT_MODE_EXPIRATION defaultValue:0];
    }
    
    
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970];
    if (silentExpiration > 0 && silentExpiration < timeInterval) {
        silentMode = NO;
    }
    
    return silentMode;
}

@end
