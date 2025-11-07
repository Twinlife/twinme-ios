/*
 *  Copyright (c) 2020-2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Christian Jacquemot (Christian.Jacquemot@twinlife-systems.com)
 *   Stephane Carrez (Stephane.Carrez@twin.life)
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <Twinlife/TLTwincode.h>
#import <Twinlife/TLAttributeNameValue.h>
#import <Twinlife/TLConversationService.h>
#import <Twinlife/TLNotificationService.h>
#import <Twinlife/TLRepositoryService.h>
#import <Twinlife/TLTwincodeOutboundService.h>

#import <Twinme/TLContact.h>
#import <Twinme/TLGroup.h>
#import <Twinme/TLGroupMember.h>
#import <Twinme/TLMessage.h>
#import <Twinme/TLTwinmeContext.h>
#import <Twinme/TLOriginator.h>

#import <Utils/NSString+Utils.h>

#import "NotificationSettings.h"
#import "NotificationTools.h"

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static const BOOL SYSTEM_NOTIFICATION_ON_CONTACT_UPDATE = NO; // Skred does not notify on contact update.

//
// Implementation: NotificationInfo
//

#undef LOG_TAG
#define LOG_TAG @"NotificationInfo"

@implementation NotificationInfo

@end

//
// Implementation: NotificationTools
//

#undef LOG_TAG
#define LOG_TAG @"NotificationTools"

@implementation NotificationTools

- (nonnull instancetype)initWithTwinmeContext:(nonnull TLTwinmeContext *)twinmeContext settings:(nonnull NotificationSettings *)settings {
    
    self = [super init];
    if (self) {
        _twinmeContext = twinmeContext;
        _settings = settings;
    }
    return self;
}

#pragma mark - TLNotificationCenter protocol

- (nullable NotificationInfo *)createNotificationDescriptorWithContact:(nonnull id<TLOriginator>)contact conversationId:(nonnull NSUUID *)conversationId descriptor:(nonnull TLDescriptor *)descriptor notificationId:(nullable NSUUID *)notificationId {
    DDLogVerbose(@"%@ createNotificationDescriptorWithContact: %@ conversationId: %@ descriptor: %@", LOG_TAG, contact, conversationId, descriptor);
    
    TLNotificationType type;
    NSString *notificationMessage = nil;
    NSString *notificationBackgroundMessage = nil;
    
    BOOL displayNotificationSender = [self.settings hasDisplayNotificationSender] && !contact.identityCapabilities.hasDiscreet;
    BOOL displayNotificationContent = [self.settings hasDisplayNotificationContent] && !contact.identityCapabilities.hasDiscreet;
    
    switch (descriptor.getType) {
        case TLDescriptorTypeObjectDescriptor: {
            TLObjectDescriptor *objectDescriptor = (TLObjectDescriptor *) descriptor;
            NSString *notificationMessage = objectDescriptor.message;
            
            if (notificationMessage == nil) {
                return nil;
            }
            
            if (displayNotificationContent && descriptor.expireTimeout <= 0) {
                notificationBackgroundMessage = notificationMessage;
            } else {
                notificationBackgroundMessage = TwinmeLocalizedString(@"notification_center_message_received", nil);
            }
            
            type = TLNotificationTypeNewTextMessage;
            break;
        }
            
        case TLDescriptorTypeImageDescriptor:
            
            if (displayNotificationSender && displayNotificationContent) {
                notificationBackgroundMessage = TwinmeLocalizedString(@"notification_center_photo_message", nil);
            } else if (displayNotificationSender && !displayNotificationContent) {
                notificationBackgroundMessage = TwinmeLocalizedString(@"notification_center_message_received", nil);
            } else if (!displayNotificationSender && displayNotificationContent) {
                notificationBackgroundMessage = TwinmeLocalizedString(@"notification_center_photo_message_received", nil);
            } else {
                notificationBackgroundMessage = TwinmeLocalizedString(@"notification_center_message_received", nil);
            }
            
            notificationMessage = TwinmeLocalizedString(@"notification_center_photo_message", nil);
            type = TLNotificationTypeNewImageMessage;
            break;
            
        case TLDescriptorTypeAudioDescriptor:
            
            if (displayNotificationSender && displayNotificationContent) {
                notificationBackgroundMessage = TwinmeLocalizedString(@"notification_center_audio_message", nil);
            } else if (displayNotificationSender && !displayNotificationContent) {
                notificationBackgroundMessage = TwinmeLocalizedString(@"notification_center_message_received", nil);
            } else if (!displayNotificationSender && displayNotificationContent) {
                notificationBackgroundMessage = TwinmeLocalizedString(@"notification_center_audio_message_received", nil);
            } else {
                notificationBackgroundMessage = TwinmeLocalizedString(@"notification_center_message_received", nil);
            }
            
            notificationMessage = TwinmeLocalizedString(@"notification_center_audio_message", nil);
            type = TLNotificationTypeNewAudioMessage;
            break;
            
        case TLDescriptorTypeVideoDescriptor:
            
            if (displayNotificationSender && displayNotificationContent) {
                notificationBackgroundMessage = TwinmeLocalizedString(@"notification_center_video_message", nil);
            } else if (displayNotificationSender && !displayNotificationContent) {
                notificationBackgroundMessage = TwinmeLocalizedString(@"notification_center_message_received", nil);
            } else if (!displayNotificationSender && displayNotificationContent) {
                notificationBackgroundMessage = TwinmeLocalizedString(@"notification_center_video_message_received", nil);
            } else {
                notificationBackgroundMessage = TwinmeLocalizedString(@"notification_center_message_received", nil);
            }
            
            notificationMessage = TwinmeLocalizedString(@"notification_center_video_message", nil);
            type = TLNotificationTypeNewVideoMessage;
            break;
            
        case TLDescriptorTypeNamedFileDescriptor:
            
            if (displayNotificationSender && displayNotificationContent) {
                notificationBackgroundMessage = TwinmeLocalizedString(@"notification_center_file_message", nil);
            } else if (displayNotificationSender && !displayNotificationContent) {
                notificationBackgroundMessage = TwinmeLocalizedString(@"notification_center_message_received", nil);
            } else if (!displayNotificationSender && displayNotificationContent) {
                notificationBackgroundMessage = TwinmeLocalizedString(@"notification_center_file_message_received", nil);
            } else {
                notificationBackgroundMessage = TwinmeLocalizedString(@"notification_center_message_received", nil);
            }
            
            notificationMessage = TwinmeLocalizedString(@"notification_center_file_message", nil);
            type = TLNotificationTypeNewFileMessage;
            break;
            
        case TLDescriptorTypeInvitationDescriptor:
            type = TLNotificationTypeNewGroupInvitation;
            
            if (displayNotificationSender && displayNotificationContent) {
                notificationBackgroundMessage = TwinmeLocalizedString(@"notification_center_group_invitation", nil);
            } else if (displayNotificationSender && !displayNotificationContent) {
                notificationBackgroundMessage = TwinmeLocalizedString(@"notification_center_message_received", nil);
            } else if (!displayNotificationSender && displayNotificationContent) {
                notificationBackgroundMessage = TwinmeLocalizedString(@"notification_center_group_invitation_received", nil);
            } else {
                notificationBackgroundMessage = TwinmeLocalizedString(@"notification_center_message_received", nil);
            }
            
            notificationMessage = TwinmeLocalizedString(@"notification_center_group_invitation", nil);
            
            break;
            
        case TLDescriptorTypeTwincodeDescriptor:
            type = TLNotificationTypeNewContactInvitation;
            
            if (displayNotificationSender && displayNotificationContent) {
                notificationBackgroundMessage = TwinmeLocalizedString(@"notification_center_group_invitation", nil);
            } else if (displayNotificationSender && !displayNotificationContent) {
                notificationBackgroundMessage = TwinmeLocalizedString(@"notification_center_message_received", nil);
            } else if (!displayNotificationSender && displayNotificationContent) {
                notificationBackgroundMessage = TwinmeLocalizedString(@"notification_center_group_invitation_received", nil);
            } else {
                notificationBackgroundMessage = TwinmeLocalizedString(@"notification_center_message_received", nil);
            }
            
            notificationMessage = TwinmeLocalizedString(@"notification_center_group_invitation", nil);
            
            break;

        case TLDescriptorTypeGeolocationDescriptor:
            type = TLNotificationTypeNewGeolocation;
                
            if (displayNotificationSender && displayNotificationContent) {
                notificationBackgroundMessage = TwinmeLocalizedString(@"notification_center_geolocation_message", nil);
            } else if (displayNotificationSender && !displayNotificationContent) {
                notificationBackgroundMessage = TwinmeLocalizedString(@"notification_center_message_received", nil);
            } else if (!displayNotificationSender && displayNotificationContent) {
                notificationBackgroundMessage = TwinmeLocalizedString(@"notification_center_geolocation_message_received", nil);
            } else {
                notificationBackgroundMessage = TwinmeLocalizedString(@"notification_center_message_received", nil);
            }
            
            notificationMessage = TwinmeLocalizedString(@"notification_center_geolocation_message", nil);
                
            break;
                
        case TLDescriptorTypeClearDescriptor:
            type = TLNotificationTypeResetConversation;

            if (displayNotificationSender && displayNotificationContent) {
                notificationBackgroundMessage = TwinmeLocalizedString(@"notification_view_controller_item_cleanup_conversation", nil);
            } else if (displayNotificationSender && !displayNotificationContent) {
                notificationBackgroundMessage = TwinmeLocalizedString(@"notification_center_message_received", nil);
            } else if (!displayNotificationSender && displayNotificationContent) {
                notificationBackgroundMessage = TwinmeLocalizedString(@"notification_center_message_cleanup_conversation", nil);
            } else {
                notificationBackgroundMessage = TwinmeLocalizedString(@"notification_center_message_received", nil);
            }
            
            notificationMessage = TwinmeLocalizedString(@"notification_view_controller_item_cleanup_conversation", nil);

            break;

        default:
            return nil;
    }
    
    return [self messageNotificationWithContact:contact notificationMessage:notificationMessage notificationBackgroundMessage:notificationBackgroundMessage type:type canRing:true descriptor:descriptor annotatingUser:nil notificationId:notificationId];
}

- (nullable NotificationInfo *)createNotificationAnnotationWithContact:(nonnull id<TLOriginator>)contact conversationId:(nonnull NSUUID *)conversationId descriptor:(nonnull TLDescriptor *)descriptor annotatingUser:(nullable TLTwincodeOutbound *)annotatingUser notificationId:(nullable NSUUID *)notificationId {
    DDLogVerbose(@"%@ createNotificationDescriptorWithContact: %@ conversationId: %@ descriptor: %@ annotatingUser: %@", LOG_TAG, contact, conversationId, descriptor, annotatingUser);
    
    NSString *notificationMessage = TwinmeLocalizedString(@"notification_center_reaction_message", nil);
    NSString *notificationBackgroundMessage = TwinmeLocalizedString(@"notification_center_reaction_message_received", nil);

    return [self messageNotificationWithContact:contact notificationMessage:notificationMessage notificationBackgroundMessage:notificationBackgroundMessage type:TLNotificationTypeUpdatedAnnotation canRing:true descriptor:descriptor annotatingUser:annotatingUser notificationId:notificationId];
}

- (nullable NotificationInfo *)messageNotificationWithContact:(nonnull id<TLOriginator>)contact notificationMessage:(nonnull NSString *)notificationMessage notificationBackgroundMessage:(nonnull NSString *)notificationBackgroundMessage type:(TLNotificationType)type canRing:(BOOL)canRing descriptor:(nullable TLDescriptor *)descriptor annotatingUser:(nullable TLTwincodeOutbound *)annotatingUser notificationId:(nullable NSUUID *)notificationId {
    DDLogVerbose(@"%@ messageNotificationWithContact: %@ notificationMessage: %@ notificationBackgroundMessage: %@ type: %d canRing: %d descriptor: %@ notificationId: %@ annotatingUser: %@", LOG_TAG, contact, notificationMessage, notificationBackgroundMessage, type, canRing, descriptor, notificationId, annotatingUser);
    
    NotificationSoundSetting* notificationSound = nil;
    BOOL hasSounds = canRing && [self.settings hasSoundEnable];
    if (hasSounds && [self.settings hasNotificationSoundWithType:NotificationSoundTypeNotification]) {
        notificationSound = [self.settings getNotificationSoundWithType:NotificationSoundTypeNotification];
    }
    
    // For a group notification, we receive the message on the member conversationId and we must associate
    // the notification to the group conversationId so that onSetActiveConversation() can remove the notification.
    if ([(NSObject *)contact class] == [TLGroup class]) {
        id<TLConversation> conversation = [[self.twinmeContext getConversationService] getConversationWithSubject:contact];
        if (!conversation) {
            return nil;
        }
    }
    
    if (type == TLNotificationTypeUpdatedAnnotation && ![descriptor isTwincodeOutbound:contact.twincodeOutboundId]) {
        return nil;
    }
    
    TLDescriptorId *descriptorId = (descriptor ? descriptor.descriptorId : nil);
    TLNotification *notification = [self.twinmeContext createNotificationWithType:type notificationId:notificationId subject:contact descriptorId:descriptorId annotatingUser:annotatingUser];
    if (!notification || (type == TLNotificationTypeUpdatedAnnotation && ![self.settings hasDisplayNotificationLike])) {
        return nil;
    }
    
    if (type == TLNotificationTypeUpdatedAnnotation) {
        BOOL displayNotificationContent = [self.settings hasDisplayNotificationSender] && [self.settings hasDisplayNotificationContent] && !contact.identityCapabilities.hasDiscreet;
        int value = notification.annotationValue;
        NSString *emoji = [self emojiFromAnnotationValue:value];
        if (emoji.length > 0 && displayNotificationContent) {
            notificationBackgroundMessage = [NSString stringWithFormat:TwinmeLocalizedString(@"notification_center_reaction", nil), emoji];
        }
    }
    
    NSString *callerName;
    id<TLOriginator> originatorForAvatar;
    if ([(NSObject *)contact isKindOfClass:[TLGroupMember class]]) {
        TLGroupMember *groupMember = (TLGroupMember *)contact;
    
        NSString *notificationName = groupMember.name;
        
        if (notification.notificationType == TLNotificationTypeUpdatedAnnotation) {
            notificationName = notification.user.name;
        }
        
#if 0
        // Get layout direction from the main UI thread.
        __block UIUserInterfaceLayoutDirection direction;
        dispatch_sync(dispatch_get_main_queue(), ^{ direction = [[UIApplication sharedApplication] userInterfaceLayoutDirection]; });
        if (direction == UIUserInterfaceLayoutDirectionRightToLeft) {
            callerName = [NSString stringWithFormat:@"%@ - %@", groupMember.name, groupMember.group.name];
        } else {
            callerName = [NSString stringWithFormat:@"%@ - %@", groupMember.group.name, groupMember.name];
        }
#endif
        callerName = [NSString stringWithFormat:@"%@ - %@", groupMember.owner.name, notificationName];
        
        if (type == TLNotificationTypeNewContactInvitation) {
            originatorForAvatar = groupMember;
        } else {
            originatorForAvatar = groupMember.group;
        }
    } else {
        callerName = contact.name;
        originatorForAvatar = contact;
    }
    
    // TBD
    // int count = [newMessageNotification getAndIncrementCount];
    NotificationInfo *localNotification = [[NotificationInfo alloc] init];
    localNotification.notification = notification;
    localNotification.alertSound = nil;
    localNotification.alertPrivateTitle = callerName;
    localNotification.originator = originatorForAvatar;
    localNotification.notification = notification;
    if ([self.settings hasDisplayNotificationSender] && !originatorForAvatar.identityCapabilities.hasDiscreet) {
        localNotification.alertTitle = callerName;
    }
    
    localNotification.alertBody = notificationBackgroundMessage;
    localNotification.identifier = notification.uuid;
    localNotification.userInfo = @{@"notificationId": localNotification.identifier.UUIDString};
    
    // In background, either play the selected sound or the vibration, not both at the same time.
    // The selected sound is in fact not played but the phone will vibrate.
    if (hasSounds) {
        if (notificationSound) {
            localNotification.alertSound = [notificationSound getSoundForLocalNotification];
            localNotification.soundSettings = notificationSound;
        } else {
            localNotification.vibrate = [self.settings hasVibrationWithType:NotificationSoundTypeNotification];
        }
    }
    
    return localNotification;
}

- (nullable NotificationInfo *)createNotificationJoinGroupWithGroup:(nonnull id<TLOriginator>)group conversationId:(nonnull NSUUID *)conversationId notificationId:(nullable NSUUID *)notificationId {
    DDLogVerbose(@"%@ createNotificationJoinGroupWithGroup: %@ conversationId: %@", LOG_TAG, group, conversationId);
    
    NSString *notificationMessage = TwinmeLocalizedString(@"notification_center_join_group", nil);
    return [self messageNotificationWithContact:group notificationMessage:notificationMessage notificationBackgroundMessage:notificationMessage type:TLNotificationTypeNewGroupJoined  canRing:false descriptor:nil annotatingUser:nil notificationId:notificationId];
}

- (nullable NotificationInfo *)createNotificationNewContactWithContact:(nonnull id<TLOriginator>)contact notificationId:(nullable NSUUID *)notificationId {
    DDLogVerbose(@"%@ createNotificationNewContactWithContact: %@", LOG_TAG, contact);
    
    return [self contactNotificationWithContact:(TLContact *)contact notificationMessage:TwinmeLocalizedString(@"notification_center_new_contact", nil) type:TLNotificationTypeNewContact canRing:true notificationId:notificationId];
}

- (nullable NotificationInfo *)createNotificationUnbindContactWithContact:(nonnull id<TLOriginator>)contact notificationId:(nullable NSUUID *)notificationId {
    DDLogVerbose(@"%@ createNotificationUnbindContactWithContact: %@", LOG_TAG, contact);
    
    return [self contactNotificationWithContact:(TLContact *)contact notificationMessage:TwinmeLocalizedString(@"notification_center_deleted_contact", nil) type:TLNotificationTypeDeletedContact canRing:true notificationId:notificationId];
}

- (nullable NotificationInfo *)createNotificationUpdateContactWithContact:(nonnull id<TLOriginator>)contact updatedAttributes:(nonnull NSArray<TLAttributeNameValue *> *)updatedAttributes notificationId:(nullable NSUUID *)notificationId {
    DDLogVerbose(@"%@ createNotificationUpdateContactWithContact: %@ updatedAttributes: %@", LOG_TAG, contact, updatedAttributes);
    
    // Check if name was changed (use pointer comparison since the same object is used).
    if ([TLAttributeNameValue getAttributeWithName:TL_TWINCODE_NAME list:updatedAttributes] != nil) {
        return [self contactNotificationWithContact:(TLContact *)contact notificationMessage:TwinmeLocalizedString(@"notification_center_updated_contact_name", nil) type:TLNotificationTypeUpdatedContact canRing:true notificationId:nil];
    }
    
    if ([TLAttributeNameValue getAttributeWithName:TL_TWINCODE_AVATAR_ID list:updatedAttributes] != nil) {
        return [self contactNotificationWithContact:(TLContact *)contact notificationMessage:TwinmeLocalizedString(@"notification_center_updated_contact_avatar", nil) type:TLNotificationTypeUpdatedAvatarContact canRing:true notificationId:notificationId];
    }
    
    return nil;
}

- (nullable NotificationInfo *)createNotificationMissedCallWithContact:(nonnull id<TLOriginator>)contact video:(BOOL)video {
    DDLogVerbose(@"%@ createNotificationMissedCallWithContact: %@ video: %d", LOG_TAG, contact, video);
    NSString *message;
    TLNotificationType type;
        
    NSString *calleeName;
    if ([contact hasPrivateIdentity] && !contact.identityCapabilities.hasDiscreet) {
        calleeName = contact.identityName;
    }
    
    if (!calleeName) {
        if (video) {
            type = TLNotificationTypeMissedVideoCall;
        } else {
            type = TLNotificationTypeMissedAudioCall;
        }
        message = TwinmeLocalizedString(@"history_view_controller_missed_call", nil);
    } else {
        if (video) {
            type = TLNotificationTypeMissedVideoCall;
            message = [NSString stringWithFormat:TwinmeLocalizedString(@"notification_center_missed_video_call_to %@", nil), calleeName];
        } else {
            type = TLNotificationTypeMissedAudioCall;
            message = [NSString stringWithFormat:TwinmeLocalizedString(@"notification_center_missed_audio_call_to %@", nil), calleeName];
        }
    }
    
    return [self contactNotificationWithContact:contact notificationMessage:message type:type canRing:true notificationId:nil];
}

- (nullable NotificationInfo *)createNotificationIncomingCallWithContact:(nonnull id<TLOriginator>)contact video:(BOOL)video notificationId:(nullable NSUUID *)notificationId {
    DDLogVerbose(@"%@ createNotificationIncomingCallWithContact: %@ video: %d notificationId: %@", LOG_TAG, contact, video, notificationId);
    
    NSString *message;
    TLNotificationType type;
    
    NSString *calleeName;
    if ([contact hasPrivateIdentity] && !contact.identityCapabilities.hasDiscreet) {
        calleeName = contact.identityName;
    }
    
    if (!calleeName) {
        if (video) {
            type = TLNotificationTypeMissedVideoCall;
            message = TwinmeLocalizedString(@"conversation_view_controller_video_call", nil);
        } else {
            type = TLNotificationTypeMissedAudioCall;
            message = TwinmeLocalizedString(@"conversation_view_controller_audio_call", nil);
        }
    } else {
        if (video) {
            type = TLNotificationTypeMissedVideoCall;
            message = [NSString stringWithFormat:TwinmeLocalizedString(@"notification_center_video_call_to %@", nil), calleeName];
        } else {
            type = TLNotificationTypeMissedAudioCall;
            message = [NSString stringWithFormat:TwinmeLocalizedString(@"notification_center_audio_call_to %@", nil), calleeName];
        }
    }
        
    return [self contactNotificationWithContact:contact notificationMessage:message type:type canRing:true notificationId:notificationId];
}

- (nullable NotificationInfo *)contactNotificationWithContact:(nonnull id<TLOriginator>)contact notificationMessage:(NSString *)notificationMessage type:(TLNotificationType)type canRing:(BOOL)canRing notificationId:(nullable NSUUID *)notificationId {
    DDLogVerbose(@"%@ contactNotificationWithContact: %@ notificationMessage: %@ type: %d canRing: %d notificationId: %@", LOG_TAG, contact, notificationMessage, type, canRing, notificationId);
    
    NotificationInfo *localNotification = [[NotificationInfo alloc] init];
    localNotification.type = type;
    localNotification.originator = contact;
    
    // Twinme raises the system notification for contact update but Skred does not.
    if (SYSTEM_NOTIFICATION_ON_CONTACT_UPDATE || (type != TLNotificationTypeUpdatedAvatarContact && type != TLNotificationTypeUpdatedContact)) {
        
        NotificationSoundSetting *notificationSound = nil;
        BOOL hasSounds = canRing && [self.settings hasSoundEnable];
        if (hasSounds && [self.settings hasNotificationSoundWithType:NotificationSoundTypeNotification]) {
            notificationSound = [self.settings getNotificationSoundWithType:NotificationSoundTypeNotification];
        }
        localNotification.alertPrivateTitle = contact.name;

        if (!contact.identityCapabilities.hasDiscreet) {
            localNotification.alertTitle = contact.name;
        } else {
            localNotification.alertTitle = TwinmeLocalizedString(@"application_name", nil);
        }
        
        localNotification.alertBody = notificationMessage;
        
        // In background, either play the selected sound or the vibration, not both at the same time.
        // The selected sound is in fact not played but the phone will vibrate.
        if (hasSounds) {
            if (notificationSound) {
                localNotification.alertSound = [notificationSound getSoundForLocalNotification];
                localNotification.soundSettings = notificationSound;
            } else {
                localNotification.vibrate = [self.settings hasVibrationWithType:NotificationSoundTypeNotification];
            }
        }
    }
    
    localNotification.notification = [self.twinmeContext createNotificationWithType:type notificationId:notificationId subject:contact descriptorId:nil annotatingUser:nil];
    if (!localNotification.notification) {
        return nil;
    }
    localNotification.identifier = localNotification.notification.uuid;
    localNotification.userInfo = @{@"notificationId": localNotification.identifier.UUIDString};
    return localNotification.alertTitle ? localNotification : nil;
}

- (NSString *)emojiFromAnnotationValue:(int)annotationValue {
    DDLogVerbose(@"%@ emojiFromAnnotationValue: %d", LOG_TAG, annotationValue);
    
    NSString *emoji = @"";
    switch (annotationValue) {
        case 0:
            emoji = @"👍";
            break;
            
        case 1:
            emoji = @"👎";
            break;
            
        case 2:
            emoji = @"❤️";
            break;
            
        case 3:
            emoji = @"😢";
            break;
            
        case 4:
            emoji = @"😂";
            break;
            
        case 5:
            emoji = @"😲";
            break;
            
        case 6:
            emoji = @"😱";
            break;
            
        case 7:
            emoji = @"🔥";
            break;
            
        default:
            break;
    }
        
    return emoji;
}

@end

