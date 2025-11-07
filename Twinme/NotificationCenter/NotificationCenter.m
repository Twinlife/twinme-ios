/*
 *  Copyright (c) 2015-2024 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Christian Jacquemot (Christian.Jacquemot@twinlife-systems.com)
 *   Chedi Baccari (Chedi.Baccari@twinlife-systems.com)
 *   Stephane Carrez (Stephane.Carrez@twin.life)
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <Twinlife/TLAttributeNameValue.h>
#import <Twinlife/TLConversationService.h>
#import <Twinlife/TLPeerConnectionService.h>
#import <Twinlife/TLImageService.h>
#import <Twinlife/TLNotificationService.h>
#import <Twinlife/TLRepositoryService.h>

#import <Twinme/TLTwinmeContext.h>
#import <Twinme/TLOriginator.h>
#import <Twinme/TLContact.h>
#import <Twinme/TLCallReceiver.h>
#import <Twinme/TLGroup.h>
#import <Twinme/TLGroupMember.h>
#import <Twinme/TLMessage.h>
#import <Twinme/TLSpace.h>
#import <Twinme/TLTwinmeAttributes.h>

#import <Notification/NotificationSettings.h>
#import <Notification/NotificationTools.h>

#import <Utils/NSString+Utils.h>

#import <TwinmeCommon/NotificationCenter.h>
#import <TwinmeCommon/ApplicationDelegate.h>
#import <TwinmeCommon/MainViewController.h>
#import <TwinmeCommon/TwinmeNavigationController.h>
#import <TwinmeCommon/NotificationSound.h>
#import <TwinmeCommon/TwinmeApplication.h>
#import <TwinmeCommon/CallService.h>
#import <TwinmeCommon/AccountMigrationService.h>
#import <TwinmeCommon/CallViewController.h>
#import <TwinmeCommon/UIViewController+Utils.h>

#import "ConversationsViewController.h"
#import "ConversationViewController.h"
#import "AcceptGroupInvitationViewController.h"
#import "ShowContactViewController.h"
#import "ShowGroupViewController.h"
#import "ShowRoomViewController.h"
#import "ShowExternalCallViewController.h"
#import "AcceptInvitationViewController.h"
#import "ApplicationAssertion.h"

#import "NotificationView.h"

#import "SpaceSetting.h"

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

//
// Interface: SystemNotification
//

typedef enum {
    SystemNotificationTypeIncomingCall,
    SystemNotificationTypeNewMessage,
    SystemNotificationTypeContact
} SystemNotificationType;

@interface SystemNotification ()

@property (readonly) SystemNotificationType type;
@property (readonly, nonnull) NSUUID *notificationId;
@property (nullable) NotificationView *notificationView;

- (instancetype)initWithType:(SystemNotificationType)type notificationId:(nonnull NSUUID *)notificationId;

@end

//
// Implementation: SystemNotification
//

@implementation SystemNotification

- (instancetype)initWithType:(SystemNotificationType)type notificationId:(nonnull NSUUID *)notificationId {
    
    self = [super init];
    
    if (self) {
        _type = type;
        _notificationId = notificationId;
    }
    return self;
}

@end

//
// Interface: IncomingCallNotification
//

@interface IncomingCallNotification ()

@property (readonly, nonnull) id<TLOriginator> originator;
@property BOOL accepted;
@property (nullable) CallViewController *callViewController;

- (nonnull instancetype)initWithNotificationId:(nullable NSUUID *)peerConnectionId originator:(id<TLOriginator>)originator audio:(BOOL)audio video:(BOOL)video videoBell:(BOOL)videoBell;

@end

//
// Implementation: IncomingCallNotification
//

@implementation IncomingCallNotification

- (instancetype)initWithNotificationId:(NSUUID *)notificationId originator:(id<TLOriginator>)originator audio:(BOOL)audio video:(BOOL)video videoBell:(BOOL)videoBell {
    
    self = [super initWithType:SystemNotificationTypeIncomingCall notificationId:notificationId];
    
    if (self) {
        _originator = originator;
        _audio = audio;
        _video = video;
        _videoBell = videoBell;
        _missed = NO;
        _accepted = NO;
    }
    return self;
}

@end

//
// Interface: NewMessageNotification
//

@interface NewMessageNotification : SystemNotification

@property (readonly) NSUUID *conversationId;
@property (readonly) id<TLOriginator> contact;
@property (readonly) NSMutableSet<NSString *> *pendingNotifications;

- (instancetype)initWithNotificationId:(nonnull NSUUID *)notificationId contact:(id<TLOriginator>)contact conversationId:(NSUUID *)conversationId;

@end

//
// Implementation: NewMessageNotification
//

@implementation NewMessageNotification

- (instancetype)initWithNotificationId:(nonnull NSUUID *)notificationId contact:(id<TLOriginator>)contact conversationId:(NSUUID *)conversationId {
    
    self = [super initWithType:SystemNotificationTypeNewMessage notificationId:notificationId];
    if (self) {
        _contact = contact;
        _conversationId = conversationId;
        _pendingNotifications = [[NSMutableSet alloc] init];
        [_pendingNotifications addObject:notificationId.UUIDString];
    }
    return self;
}

@end

//
// Interface: ContactNotification
//

@interface ContactNotification : SystemNotification

@property (readonly, nonnull) TLContact *contact;
@property (readonly, nullable) TLDescriptorId *invitationId;

- (nonnull instancetype)initWithNotificationId:(nonnull NSUUID *)notificationId contact:(nonnull TLContact *)contact invitationId:(nullable TLDescriptorId *)invitationId;

@end

//
// Implementation: ContactNotification
//

@implementation ContactNotification

- (nonnull instancetype)initWithNotificationId:(nonnull NSUUID *)notificationId contact:(TLContact *)contact invitationId:(TLDescriptorId *)invitationId {
    
    self = [super initWithType:SystemNotificationTypeContact notificationId:notificationId];
    if (self) {
        _contact = contact;
        _invitationId = invitationId;
    }
    return self;
}

@end

//
// Interface: NotificationCenter ()
//

@interface NotificationCenter () <NotificationViewDelegate>

@property (nonatomic) CallService *callService;
@property (nonatomic) AccountMigrationService *accountMigrationService;
@property BOOL inBackground;
@property int notificationId;
@property (nonatomic, readonly, nonnull) NSMutableDictionary<NSUUID *, SystemNotification *> *notifications;
@property (nonatomic, readonly, nonnull) NSMutableDictionary<NSUUID *, NewMessageNotification *> *conversationId2Notifications;
@property (nonatomic, readonly, nonnull) NSMutableDictionary<NSUUID *, IncomingCallNotification *> *notificationId2Notifications;
@property (nonatomic, nullable) NSMutableSet<NSString *> *pendingNotificationsToDelete;
@property BOOL incomingCallNotifications;
@property int64_t backgroundTime;

- (nullable IncomingCallNotification *)cancelNotificationWithNotificationId:(nonnull NSUUID *)notificationId;

- (nonnull UIImage *)getAvatarWithOriginator:(nonnull id<TLOriginator>)originator;

@end

//
// Implementation: NotificationCenter
//

#undef LOG_TAG
#define LOG_TAG @"NotificationCenter"

@implementation NotificationCenter

- (nonnull instancetype)initWithTwinmeApplication:(nonnull TwinmeApplication *)twinmeApplication twinmeContext:(nonnull TLTwinmeContext *)twinmeContext {
    DDLogVerbose(@"%@ initWithTwinmeApplication: %@ twinmeContext: %@", LOG_TAG, twinmeApplication, twinmeContext);
    
    self = [super initWithTwinmeContext:twinmeContext settings:twinmeApplication.settings];
    
    if (self) {
        _inBackground = YES;
        _notificationId = 0;
        _notifications = [[NSMutableDictionary alloc] init];
        _conversationId2Notifications = [[NSMutableDictionary alloc] init];
        _notificationId2Notifications = [[NSMutableDictionary alloc] init];
        _incomingCallNotifications = YES;
        _backgroundTime = 0;
        [UNUserNotificationCenter currentNotificationCenter].delegate = self;
        [twinmeContext addDelegate:self];
    }
    return self;
}

- (void)initWithCallService:(nonnull CallService *)callService accountMigrationService:(nonnull AccountMigrationService *)accountMigrationService {
    DDLogVerbose(@"%@ initWithCallService: %@ accountMigrationService: %@", LOG_TAG, callService, accountMigrationService);
    
    self.callService = callService;
    self.accountMigrationService = accountMigrationService;
}

#pragma mark - Application Delegate

- (void)applicationDidEnterBackground:(UIApplication *)application {
    DDLogVerbose(@"%@ applicationDidEnterBackground: %@", LOG_TAG, application);
    
    self.inBackground = YES;
    self.backgroundTime = [[NSDate date] timeIntervalSince1970] * 1000;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    DDLogVerbose(@"%@ applicationDidBecomeActive: %@", LOG_TAG, application);
    
    self.inBackground = NO;

    // Force a refresh of the notification badge if we were put into background for more than 30s.
    int64_t now = [[NSDate date] timeIntervalSince1970] * 1000;
    if (now - self.backgroundTime > 30 * 1000L) {
        [self.twinmeContext getDefaultSpaceWithBlock:^(TLBaseServiceErrorCode errorCode, TLSpace *space) {
            [self.twinmeContext scheduleRefreshNotifications];
        }];
    }
}

- (nullable IncomingCallNotification *)createIncomingCallNotificationWithOriginator:(nonnull id<TLOriginator>)originator notificationId:(nonnull NSUUID *)notificationId audio:(BOOL)audio video:(BOOL)video videoBell:(BOOL)videoBell {
    DDLogVerbose(@"%@ createIncomingCallNotificationWithOriginator: %@ notificationId: %@ audio: %@ video: %@ videoBell: %@", LOG_TAG, originator, notificationId, audio ? @"YES" : @"NO", video ? @"YES" : @"NO", videoBell ? @"YES" : @"NO");
    
    if (!video && !audio) {
        return nil;
    }
    
    NotificationInfo *notificationInfo = [self createNotificationIncomingCallWithContact:originator video:video notificationId:notificationId];
    
    IncomingCallNotification *incomingCallNotification = [[IncomingCallNotification alloc] initWithNotificationId:notificationId originator:originator audio:audio video:video videoBell:videoBell];
    @synchronized(self) {
        // If this notification was already triggered, don't raise it again.
        if (self.notificationId2Notifications[notificationId]) {
            return (IncomingCallNotification *)self.notificationId2Notifications[notificationId];
        }
        self.notifications[notificationId] = incomingCallNotification;
        self.notificationId2Notifications[notificationId] = incomingCallNotification;
    }
    
    // For the Audio/Video call, the sound is played and managed by the CallService.
    // Handle the vibration here.
    BOOL hasSounds = [self.settings hasSoundEnable];
    if (hasSounds) {
        if (video) {
            if ([self.settings hasVibrationWithType:NotificationSoundTypeVideoCall]) {
                AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
            }
            
        } else if (audio) {
            if ([self.settings hasVibrationWithType:NotificationSoundTypeAudioCall]) {
                AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
            }
        }
    }
    
    if (self.inBackground) {
        [self postNotificationWithNotificationInfo:notificationInfo];
        
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *title = originator.name;
            NSString *message = notificationInfo.alertTitle;
         
            UIImage *avatar = [self getAvatarWithOriginator:originator];
            
            if (title) {
                NotificationView *notificationView = [[NotificationView alloc] initWithNotificationId:notificationId title:title message:message avatar:avatar notificationSound:nil actionButtons:YES notificationViewDelegate:self];
                incomingCallNotification.notificationView = notificationView;
                
                [notificationView showInView:[[[UIApplication sharedApplication] delegate] window]];
            } else {
                [self.twinmeContext assertionWithAssertPoint:[ApplicationAssertPoint INVALID_TITLE], [TLAssertValue initWithSubject:originator], nil];
            }
        });
    }
    return incomingCallNotification;
}

#pragma mark - TLTwinmeContext observer

- (void)onAcknowledgeNotificationWithRequestId:(int64_t)requestId notification:(TLNotification *)notification {
    DDLogVerbose(@"%@ onAcknowledgeNotificationWithRequestId: %lld notification: %@", LOG_TAG, requestId, notification);
    
    [self deleteSystemNotification:notification.uuid];
}

- (void)onDeleteNotificationsWithList:(nonnull NSArray<NSUUID *> *)list {
    DDLogVerbose(@"%@ onDeleteNotificationsWithList: %@", LOG_TAG, list);
    
    for (NSUUID *notificationId in list) {
        [self deleteSystemNotification:notificationId];
    }
}

#pragma mark - TLNotificationCenter protocol

- (void)onIncomingCallWithContact:(TLContact *)contact peerConnectionId:(NSUUID *)peerConnectionId offer:(TLOffer *)offer {
    DDLogVerbose(@"%@ onIncomingCallWithContact: %@ peerConnectionId: %@ offer: %@", LOG_TAG, contact, peerConnectionId, offer);
    
    [self.callService startCallWithPeerConnectionId:peerConnectionId originator:contact offer:offer inBackground:self.inBackground fromPushKit:NO];
}

- (void)onIncomingMigrationWithAccountMigration:(nonnull TLAccountMigration *)accountMigration peerConnectionId:(nonnull NSUUID *)peerConnectionId {
    DDLogVerbose(@"%@ onIncomingMigrationWithAccountMigration: %@ peerConnectionId: %@", LOG_TAG, accountMigration, peerConnectionId);

    [self.accountMigrationService incomingMigrationWithPeerConnectionId:peerConnectionId accountMigration:accountMigration];
}

- (void)onPopDescriptorWithContact:(id<TLOriginator>)contact conversationId:(NSUUID *)conversationId descriptor:(TLDescriptor *)descriptor {
    DDLogVerbose(@"%@ onPopDescriptorWithContact: %@ conversationId: %@ descriptor: %@", LOG_TAG, contact, conversationId, descriptor);
    
    NotificationInfo *notificationInfo = [self createNotificationDescriptorWithContact:contact conversationId:conversationId descriptor:descriptor notificationId:nil];
    if (!notificationInfo) {
        return;
    }
    
    [self messageNotificationWithContact:contact notification:notificationInfo conversationId:conversationId descriptor:descriptor];
}

- (void)messageNotificationWithContact:(nonnull id<TLOriginator>)contact notification:(nullable NotificationInfo *)notificationInfo conversationId:(nullable NSUUID *)conversationId descriptor:(nullable TLDescriptor *)descriptor {
    DDLogVerbose(@"%@ messageNotificationWithContact: %@ conversationId: %@ descriptor: %@", LOG_TAG, contact, conversationId, descriptor);
    
    if (!notificationInfo) {
        return;
    }
    
    SystemNotification *notification;
    if (conversationId) {
        @synchronized(self) {
            NewMessageNotification *newMessageNotification = self.conversationId2Notifications[conversationId];
            if (newMessageNotification) {
                [newMessageNotification.pendingNotifications addObject:notificationInfo.identifier.UUIDString];
            } else {
                newMessageNotification = [[NewMessageNotification alloc] initWithNotificationId:notificationInfo.identifier contact:contact conversationId:conversationId];
                self.notifications[notificationInfo.identifier] = newMessageNotification;
                self.conversationId2Notifications[conversationId] = newMessageNotification;
            }
            notification = newMessageNotification;
        }
    } else {
        notification = [[ContactNotification alloc] initWithNotificationId:notificationInfo.identifier contact:(TLContact *)contact invitationId:nil];
    }
    
    if (![self showNotification:contact]) {
        return;
    }
    
    if (self.inBackground) {
        [self postNotificationWithNotificationInfo:notificationInfo];
        
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIImage *avatar = [self getAvatarWithOriginator:notificationInfo.originator];
            
            NotificationSound* notificationSound;
            if (notificationInfo.alertSound) {
                notificationSound = [[NotificationSound alloc] initWithSettings:notificationInfo.soundSettings];
            }
            
            if (notificationInfo.alertPrivateTitle && notificationInfo.alertBody) {
                NotificationView *notificationView = [[NotificationView alloc] initWithNotificationId:notificationInfo.identifier title:notificationInfo.alertPrivateTitle message:notificationInfo.alertBody avatar:avatar notificationSound:notificationSound actionButtons:NO notificationViewDelegate:self];
                notification.notificationView = notificationView;
                
                // Vibrate only in the foreground and when sounds and vibration is enabled.
                if (notificationInfo.vibrate) {
                    AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
                }
                [notificationView showInView:[[[UIApplication sharedApplication] delegate]window]];
            } else {
                [self.twinmeContext assertionWithAssertPoint:[ApplicationAssertPoint INVALID_TITLE], [TLAssertValue initWithSubject:contact], nil];
            }
        });
    }
}
- (void)onUpdateDescriptorWithContact:(nonnull id<TLOriginator>)contact conversationId:(nonnull NSUUID *)conversationId descriptor:(nonnull TLDescriptor *)descriptor updateType:(TLConversationServiceUpdateType)updateType {
    DDLogVerbose(@"%@ onUpdateDescriptorWithContact: %@ conversationId: %@ descriptor: %@ updateType: %d", LOG_TAG, contact, conversationId, descriptor, updateType);

}

- (void)onUpdateAnnotationWithContact:(id<TLOriginator>)contact conversationId:(NSUUID *)conversationId descriptor:(TLDescriptor *)descriptor annotatingUser:(nonnull TLTwincodeOutbound *)annotatingUser {
    DDLogVerbose(@"%@ onUpdateAnnotationWithContact: %@ conversationId: %@ descriptor: %@ annotatingUser: %@", LOG_TAG, contact, conversationId, descriptor, annotatingUser);
    
    NotificationInfo *notificationInfo = [self createNotificationAnnotationWithContact:contact conversationId:conversationId descriptor:descriptor annotatingUser:annotatingUser notificationId:nil];
    if (!notificationInfo) {
        return;
    }
    
    [self messageNotificationWithContact:contact notification:notificationInfo conversationId:conversationId descriptor:descriptor];
}

- (void)onSetActiveConversationWithConversationId:(nonnull NSUUID *)conversationId {
    DDLogVerbose(@"%@ onSetActiveConversationWithConversationId: %@", LOG_TAG, conversationId);
    
    BOOL created = NO;
    @synchronized(self) {
        NewMessageNotification *notification = self.conversationId2Notifications[conversationId];
        if (notification) {
            [self.conversationId2Notifications removeObjectForKey:conversationId];
            [self.notifications removeObjectForKey:notification.notificationId];
            if (self.pendingNotificationsToDelete) {
                for (NSString *notificationId in notification.pendingNotifications) {
                    [self.pendingNotificationsToDelete addObject:notificationId];
                }
            } else {
                self.pendingNotificationsToDelete = notification.pendingNotifications;
                created = YES;
            }
        }
    }
    
    // Cancel the system notifications in 500ms to collect several notifications to cancel.
    if (created) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void) {
            [self cancelSystemNotifications];
        });
    }
}

- (void)onJoinGroupWithGroup:(id<TLOriginator>)group conversationId:(NSUUID *)conversationId {
    DDLogVerbose(@"%@ onJoinGroupWithGroup: %@ conversationId: %@", LOG_TAG, group, conversationId);
    
    NotificationInfo *notificationInfo = [self createNotificationJoinGroupWithGroup:group conversationId:conversationId notificationId:nil];
    if (!notificationInfo) {
        return;
    }
    
    [self messageNotificationWithContact:group notification:notificationInfo conversationId:conversationId descriptor:nil];
}

- (void)onNewContactWithContact:(id<TLOriginator>)contact {
    DDLogVerbose(@"%@ onNewContactWithContact: %@", LOG_TAG, contact);
    
    NotificationInfo *notificationInfo = [self createNotificationNewContactWithContact:contact notificationId:nil];
    if (!notificationInfo) {
        return;
    }
    
    [self messageNotificationWithContact:contact notification:notificationInfo conversationId:nil descriptor:nil];
}

- (void)onUnbindContactWithContact:(id<TLOriginator>)contact {
    DDLogVerbose(@"%@ onUnbindContactWithContact: %@", LOG_TAG, contact);
    
    NotificationInfo *notificationInfo = [self createNotificationUnbindContactWithContact:contact notificationId:nil];
    if (!notificationInfo) {
        return;
    }
    
    [self messageNotificationWithContact:contact notification:notificationInfo conversationId:nil descriptor:nil];
}

- (void)onUpdateContactWithContact:(id<TLOriginator>)contact updatedAttributes:(nonnull NSArray<TLAttributeNameValue *> *)updatedAttributes {
    DDLogVerbose(@"%@ onUpdateContactWithContact: %@ updatedAttributes: %@", LOG_TAG, contact, updatedAttributes);
    
    NotificationInfo *notificationInfo = [self createNotificationUpdateContactWithContact:contact updatedAttributes:updatedAttributes notificationId:nil];
    if (!notificationInfo) {
        return;
    }
    
    [self messageNotificationWithContact:contact notification:notificationInfo conversationId:nil descriptor:nil];
}

- (void)updateApplicationBadgeNumber:(NSInteger)applicationBadgeNumber {
    DDLogVerbose(@"%@ updateApplicationBadgeNumber: %ld", LOG_TAG, (long)applicationBadgeNumber);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIApplication sharedApplication].applicationIconBadgeNumber = applicationBadgeNumber;
        
        [self.settings updateNotificationBadgeNumber:applicationBadgeNumber];
    });
}

#pragma mark - UNUserNotificationCenter Delegate

- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification  withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler {
    DDLogVerbose(@"%@ userNotificationCenter: %@ notification: %@ completionHandler: %@", LOG_TAG, center, notification, completionHandler);
    
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response  withCompletionHandler:(void (^)(void))completionHandler {
    DDLogVerbose(@"%@ userNotificationCenter: %@ response: %@ completionHandler: %@", LOG_TAG, center, response, completionHandler);
    
    UNNotification *notification = response.notification;
    UNNotificationRequest *request = notification.request;
    NSUUID *notificationId =  [[NSUUID alloc] initWithUUIDString:request.identifier];
    
    if (notificationId) {
        [self.twinmeContext getNotificationWithNotificationId:notificationId withBlock:^(TLBaseServiceErrorCode status, TLNotification *notification) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (notification) {
                    [self handleNotification:notification];
                }
                completionHandler();
            });
        }];
        return;
    }
    
    NSUUID *contactId = [[NSUUID alloc] initWithUUIDString:request.content.userInfo[@"contactId"]];
    if (contactId) {
        [self.twinmeContext getContactWithContactId:contactId withBlock:^(TLBaseServiceErrorCode errorCode, TLContact *contact) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self handleFakeNotificationConversationWithOriginator:contact];
                completionHandler();
            });
        }];
        return;
    }
    
    NSUUID *groupId = [[NSUUID alloc] initWithUUIDString:request.content.userInfo[@"groupId"]];
    if (groupId) {
        [self.twinmeContext getGroupWithGroupId:groupId withBlock:^(TLBaseServiceErrorCode errorCode, TLGroup *group) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self handleFakeNotificationConversationWithOriginator:group];
                completionHandler();
            });
        }];
        return;
    }
    
    // Call notification handler but we don't really handle the notification.
    completionHandler();
}

- (void)handleNotification:(TLNotification *)notification {
    
    [self dismissModalViewController];
    
    ApplicationDelegate *delegate = (ApplicationDelegate *)[[UIApplication sharedApplication] delegate];
    MainViewController *mainViewController = delegate.mainViewController;
    TwinmeNavigationController *selectedNavigationController = mainViewController.selectedViewController;
    if ([selectedNavigationController.topViewController isKindOfClass:[CallViewController class]]) {
        CallViewController *callViewConroller = (CallViewController *) selectedNavigationController.topViewController;
        [callViewConroller back];
    }
    [selectedNavigationController popToRootViewControllerAnimated:NO];
    
    id<TLRepositoryObject> subject = notification.subject;

    if ([subject conformsToProtocol:@protocol(TLOriginator)]) {
        id<TLOriginator> originator = (id<TLOriginator>) subject;
        if (originator.space && ![self.twinmeContext isCurrentSpace:originator]) {
            int64_t requestId = [self.twinmeContext newRequestId];
            [self.twinmeContext setCurrentSpaceWithRequestId:requestId space:originator.space];
            
            TLSpaceSettings *spaceSettings = originator.space.settings;
            if ([originator.space.settings getBooleanWithName:PROPERTY_DEFAULT_APPEARANCE_SETTINGS defaultValue:YES]) {
                spaceSettings = self.twinmeContext.defaultSpaceSettings;
            }
            
            if (![Design.MAIN_STYLE isEqualToString:spaceSettings.style]) {
                [Design setMainColor:spaceSettings.style];
            }
        }
    }
    
    switch (notification.notificationType) {
        case TLNotificationTypeNewTextMessage:
        case TLNotificationTypeNewImageMessage:
        case TLNotificationTypeNewAudioMessage:
        case TLNotificationTypeNewVideoMessage:
        case TLNotificationTypeNewFileMessage:
        case TLNotificationTypeNewGeolocation:
        case TLNotificationTypeResetConversation:
        case TLNotificationTypeUpdatedAnnotation: {
            [mainViewController selectTab:3];
            selectedNavigationController = mainViewController.selectedViewController;
            mainViewController.selectedViewController.navigationBarHidden = NO;
            
            ConversationViewController *conversationViewController = (ConversationViewController *)[mainViewController.storyboard instantiateViewControllerWithIdentifier:@"ConversationViewController"];
            [conversationViewController initWithContact:(id<TLOriginator>)subject];
            [selectedNavigationController pushViewController:conversationViewController animated:YES];
            
            break;
        }
            
        case TLNotificationTypeMissedVideoCall:
        case TLNotificationTypeMissedAudioCall:
        case TLNotificationTypeNewContact:
        case TLNotificationTypeUpdatedContact:
        case TLNotificationTypeUpdatedAvatarContact:
        case TLNotificationTypeDeletedContact: {
            [mainViewController selectTab:2];
            selectedNavigationController = mainViewController.selectedViewController;
            if ([(NSObject *)subject isKindOfClass:[TLCallReceiver class]]) {
                TLCallReceiver *callReceiver = (TLCallReceiver *)subject;
                ShowExternalCallViewController *showExternalCallViewController = [[UIStoryboard storyboardWithName:@"ExternalCall" bundle:nil] instantiateViewControllerWithIdentifier:@"ShowExternalCallViewController"];
                [showExternalCallViewController initWithCallReceiver:callReceiver];
                [selectedNavigationController pushViewController:showExternalCallViewController animated:YES];
            }  else if ([(NSObject *)subject isKindOfClass:[TLGroup class]]) {
                TLGroup * group = (TLGroup *)subject;
                ShowGroupViewController *showGroupViewController = [[UIStoryboard storyboardWithName:@"Group" bundle:nil] instantiateViewControllerWithIdentifier:@"ShowGroupViewController"];
                [showGroupViewController initWithGroup:group];
                [selectedNavigationController pushViewController:showGroupViewController animated:YES];
            } else {
                TLContact *contact = (TLContact *)subject;
                if (contact.isTwinroom) {
                    ShowRoomViewController *showRoomViewController = [[UIStoryboard storyboardWithName:@"Room" bundle:nil] instantiateViewControllerWithIdentifier:@"ShowRoomViewController"];
                    [showRoomViewController initWithRoom:contact];
                    [selectedNavigationController pushViewController:showRoomViewController animated:YES];
                } else {
                    ShowContactViewController *showContactViewController = [[UIStoryboard storyboardWithName:@"Contact" bundle:nil] instantiateViewControllerWithIdentifier:@"ShowContactViewController"];
                    [showContactViewController initWithContact:contact];
                    [selectedNavigationController pushViewController:showContactViewController animated:YES];
                }
            }
            
            break;
        }
            
        case TLNotificationTypeNewGroupJoined: {
            [mainViewController selectTab:3];
            ShowGroupViewController *showGroupViewController = [[UIStoryboard storyboardWithName:@"Group" bundle:nil] instantiateViewControllerWithIdentifier:@"ShowGroupViewController"];
            [showGroupViewController initWithGroup:(TLGroup *)subject];
            [selectedNavigationController pushViewController:showGroupViewController animated:YES];
            break;
        }
            
        case TLNotificationTypeNewGroupInvitation: {
            AcceptGroupInvitationViewController *acceptGroupInvitationViewController = (AcceptGroupInvitationViewController *)[mainViewController.storyboard instantiateViewControllerWithIdentifier:@"AcceptGroupInvitationViewController"];
            [acceptGroupInvitationViewController initWithInvitationId:notification.descriptorId contactId:subject.objectId];
            [acceptGroupInvitationViewController showInView:mainViewController.view];
            break;
        }
            
        case TLNotificationTypeNewContactInvitation: {
            AcceptInvitationViewController *acceptInvitationViewController = (AcceptInvitationViewController *)[mainViewController.storyboard instantiateViewControllerWithIdentifier:@"AcceptInvitationViewController"];
            if ([subject isKindOfClass:[TLGroup class]]) {
                [acceptInvitationViewController initWithProfile:nil url:nil descriptorId:notification.descriptorId originatorId:subject.objectId isGroup:YES notification:notification popToRootViewController:NO];
                [acceptInvitationViewController showInView:mainViewController.view];
            } else if ([subject isKindOfClass:[TLContact class]]) {
                [acceptInvitationViewController initWithProfile:nil url:nil descriptorId:notification.descriptorId originatorId:subject.objectId isGroup:NO notification:notification popToRootViewController:NO];
                [acceptInvitationViewController showInView:mainViewController.view];
            } else if ([subject isKindOfClass:[TLGroupMember class]]){
                TLGroupMember *groupMember = (TLGroupMember *)subject;
                id<TLOriginator> owner = groupMember.group;
                if ([owner isGroup]) {
                    TLGroup *group = (TLGroup *)owner;
                    [acceptInvitationViewController initWithProfile:nil url:nil descriptorId:notification.descriptorId originatorId:group.uuid isGroup:YES notification:notification popToRootViewController:NO];
                    [acceptInvitationViewController showInView:mainViewController.view];
                }
            }
            break;
        }
            
        case TLNotificationTypeDeletedGroup:
        default:
            break;
    }
}

- (void)handleFakeNotificationConversationWithOriginator:(id<TLOriginator>)originator {
    DDLogVerbose(@"%@ handleFakeNotificationConversationWithOriginator: %@", LOG_TAG, originator);
    
    [self dismissModalViewController];
    ApplicationDelegate *delegate = (ApplicationDelegate *)[[UIApplication sharedApplication] delegate];
    MainViewController *mainViewController = delegate.mainViewController;
    
    TwinmeNavigationController *selectedNavigationController = mainViewController.selectedViewController;
    if ([selectedNavigationController.topViewController isKindOfClass:[ConversationViewController class]]) {
        [selectedNavigationController popViewControllerAnimated:NO];
    }
    
    ConversationViewController *conversationViewController = (ConversationViewController *)[mainViewController.storyboard instantiateViewControllerWithIdentifier:@"ConversationViewController"];
    [conversationViewController initWithContact:originator];
    [selectedNavigationController pushViewController:conversationViewController animated:YES];
}

#pragma mark - NotificationViewDelegate

- (void)handleSwipeActionWithNotificationId:(nonnull NSUUID *)notificationId {
    DDLogVerbose(@"%@ handleSwipeActionWithNotificationId: %@", LOG_TAG, notificationId);
    
    SystemNotification *notification = [self cancelNotificationWithNotificationId:notificationId];
    if (!notification) {
        return;
    }
    
    switch (notification.type) {
        case SystemNotificationTypeIncomingCall: {
            [self.callService terminateCallWithTerminateReason:TLPeerConnectionServiceTerminateReasonDecline];
            break;
        }
            
        default:
            break;
    }
}

- (void)handleTapActionWithNotificationId:(nonnull NSUUID *)notificationId {
    DDLogVerbose(@"%@ handleTapActionWithNotificationId: %@", LOG_TAG, notificationId);
    
    SystemNotification *notification = [self cancelNotificationWithNotificationId:notificationId];
    if (notification) {
        switch (notification.type) {
            case SystemNotificationTypeIncomingCall: {
                IncomingCallNotification *incomingCallNotification = (IncomingCallNotification *)notification;
                if (incomingCallNotification.missed) {
                    [self showContactWithNotification:notification];
                } else {
                    [self incomingCallWithNotification:incomingCallNotification];
                }
            }
                return;
                
            default:
                break;
        }
    }
    
    [self.twinmeContext getNotificationWithNotificationId:notificationId withBlock:^(TLBaseServiceErrorCode status, TLNotification *notification) {
        if (status == TLBaseServiceErrorCodeSuccess && notification) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self handleNotification:notification];
            });
        }
    }];
}

- (void)handleAcceptActionWithNotificationId:(nonnull NSUUID *)notificationId {
    DDLogVerbose(@"%@ handleAcceptActionWithNotificationId: %@", LOG_TAG, notificationId);
    
    SystemNotification *notification = [self cancelNotificationWithNotificationId:notificationId];
    if (!notification) {
        return;
    }
    
    switch (notification.type) {
        case SystemNotificationTypeIncomingCall: {
            IncomingCallNotification *incomingCallNotification = (IncomingCallNotification *)notification;
            [self acceptIncomingCallWithNotification:incomingCallNotification];
            break;
        }
            
        default:
            break;
    }
}

- (void)handleDeclineActionWithNotificationId:(nonnull NSUUID *)notificationId {
    DDLogVerbose(@"%@ handleDeclineActionWithNotificationId: %@", LOG_TAG, notificationId);
    
    SystemNotification *notification = [self cancelNotificationWithNotificationId:notificationId];
    if (!notification) {
        return;
    }
    
    switch (notification.type) {
        case SystemNotificationTypeIncomingCall: {
            [self.callService terminateCallWithTerminateReason:TLPeerConnectionServiceTerminateReasonDecline];
            break;
        }
            
        default:
            break;
    }
}

#pragma mark - Private methods

- (void)postNotificationWithNotificationInfo:(nonnull NotificationInfo *)notificationInfo {
    DDLogVerbose(@"%@ postNotificationWithNotificationInfo: %@", LOG_TAG, notificationInfo);
    
    UNMutableNotificationContent *notificationContent = [[UNMutableNotificationContent alloc] init];
    notificationContent.title = notificationInfo.alertTitle;
    notificationContent.subtitle = notificationInfo.alertBody;
    notificationContent.categoryIdentifier = @"NOTIFICATION";
    notificationContent.sound = notificationInfo.alertSound;
    
    // In background, either play the selected sound or the vibration, not both at the same time.
    // The selected sound is in fact not played but the phone will vibrate.
    if (notificationInfo.vibrate) {
        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
    }
    
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:notificationInfo.identifier.UUIDString content:notificationContent trigger:nil];
    
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    [center addNotificationRequest:request withCompletionHandler:^(NSError *error) {
    }];
}

- (void)incomingCallWithNotification:(IncomingCallNotification *)incomingCallNotification {
    DDLogVerbose(@"%@ incomingCallWithNotification: %@", LOG_TAG, incomingCallNotification);
    
    ApplicationDelegate *delegate = (ApplicationDelegate *)[[UIApplication sharedApplication] delegate];
    MainViewController *mainViewController = delegate.mainViewController;
    [mainViewController closeSideMenu:NO];
    [self dismissModalViewController];
    CallViewController *callViewController = (CallViewController *)[[UIStoryboard storyboardWithName:@"Call" bundle:nil] instantiateViewControllerWithIdentifier:@"CallViewController"];
    [callViewController initCallWithOriginator:incomingCallNotification.originator isVideoCall:incomingCallNotification.video];
    dispatch_async(dispatch_get_main_queue(), ^{
        [mainViewController.selectedViewController pushViewController:callViewController animated:NO];
    });
}

- (void)acceptIncomingCallWithNotification:(IncomingCallNotification *)incomingCallNotification {
    DDLogVerbose(@"%@ acceptIncomingCallWithNotification: %@", LOG_TAG, incomingCallNotification);
    
    [self.callService acceptCallWithCallkitUUID:incomingCallNotification.notificationId];
    
    ApplicationDelegate *delegate = (ApplicationDelegate *)[[UIApplication sharedApplication] delegate];
    MainViewController *mainViewController = delegate.mainViewController;
    [mainViewController closeSideMenu:NO];
    [self dismissModalViewController];
    CallViewController *callViewController = (CallViewController *)[[UIStoryboard storyboardWithName:@"Call" bundle:nil] instantiateViewControllerWithIdentifier:@"CallViewController"];
    incomingCallNotification.accepted = YES;
    [callViewController initCallWithOriginator:incomingCallNotification.originator isVideoCall:incomingCallNotification.video];
    dispatch_async(dispatch_get_main_queue(), ^{
        [mainViewController.selectedViewController pushViewController:callViewController animated:NO];
    });
}

- (void)missedCallNotificationWithOriginator:(nonnull id<TLOriginator>)originator video:(BOOL)video{
    DDLogVerbose(@"%@ missedCallNotificationWithOriginator: %@ video: %d", LOG_TAG, originator, video);
    
    NotificationInfo *notificationInfo = [self createNotificationMissedCallWithContact:originator video:video];
    if (!notificationInfo) {
        return;
    }
    
    [self messageNotificationWithContact:originator notification:notificationInfo conversationId:nil descriptor:nil];
}

- (void)showContactWithNotification:(SystemNotification *)systemNotification {
    DDLogVerbose(@"%@ showContactWithNotification: %@", LOG_TAG, systemNotification);
    
    [self dismissModalViewController];
    ApplicationDelegate *delegate = (ApplicationDelegate *)[[UIApplication sharedApplication] delegate];
    MainViewController *mainViewController = delegate.mainViewController;
    [mainViewController closeSideMenu:NO];
    
    ShowContactViewController *showContactViewController = (ShowContactViewController *)[[UIStoryboard storyboardWithName:@"Contact" bundle:nil] instantiateViewControllerWithIdentifier:@"ShowContactViewController"];
    if (systemNotification.type == SystemNotificationTypeContact) {
        ContactNotification *contactNotification = (ContactNotification *) systemNotification;
        [showContactViewController initWithContact:contactNotification.contact];
    } else if (systemNotification.type == SystemNotificationTypeIncomingCall) {
        IncomingCallNotification *incomingCallNotification = (IncomingCallNotification *) systemNotification;
        [showContactViewController initWithContact:(TLContact *)incomingCallNotification.originator];
    }
    
    [mainViewController.selectedViewController pushViewController:showContactViewController animated:YES];
}

- (SystemNotification *)cancelNotificationWithNotificationId:(nonnull NSUUID *)notificationId {
    DDLogVerbose(@"%@ cancelNotificationWithNotificationId: %@", LOG_TAG, notificationId);
    
    SystemNotification *notification;
    @synchronized (self) {
        notification = self.notifications[notificationId];
    }
    if (notification) {
        [self cancelNotification:notification];
        return notification;
    }
    return nil;
}

- (void)cancelWithNotificationId:(nonnull NSUUID *)notificationId {
    DDLogVerbose(@"%@ cancelWithNotificationId: %@", LOG_TAG, notificationId);

    @synchronized (self) {
        [self.notifications removeObjectForKey:notificationId];
    }
    [self deleteSystemNotification:notificationId];
}

- (void)cancelNotification:(SystemNotification *)notification {
    DDLogVerbose(@"%@ cancelNotification: %@", LOG_TAG, notification);
    
    @synchronized (self) {
        [self.notifications removeObjectForKey:notification.notificationId];
    }
    [self deleteSystemNotification:notification.notificationId];

    dispatch_async(dispatch_get_main_queue(), ^{
        if (notification.notificationView) {
            NotificationView *notificationView = notification.notificationView;
            notification.notificationView = nil;
            [notificationView hideNotification];
        }
    });
    
    switch (notification.type) {
        case SystemNotificationTypeIncomingCall: {
            IncomingCallNotification *incomingCallNotification = (IncomingCallNotification *)notification;
            if (incomingCallNotification.notificationId) {
                @synchronized(self) {
                    [self.notificationId2Notifications removeObjectForKey:incomingCallNotification.notificationId];
                }
            }
            break;
        }
            
        case SystemNotificationTypeNewMessage: {
            NewMessageNotification *newMessageNotification = (NewMessageNotification *)notification;
            @synchronized(self) {
                [self.conversationId2Notifications removeObjectForKey:newMessageNotification.conversationId];
            }
            break;
        }
            
        case SystemNotificationTypeContact:
            break;
    }
}

- (void)deleteSystemNotification:(NSUUID *)notificationId {
    
    BOOL created;
    @synchronized (self) {
        created = self.pendingNotificationsToDelete == nil;
        if (created) {
            self.pendingNotificationsToDelete = [[NSMutableSet alloc] init];
        }
        [self.pendingNotificationsToDelete addObject:notificationId.UUIDString];
    }

    // Cancel the system notifications in 500ms to collect several notifications to cancel.
    if (created) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void) {
            [self cancelSystemNotifications];
        });
    }
}

- (void)cancelSystemNotifications {
    
    NSMutableSet<NSString *> *pendingNotifications;
    @synchronized (self) {
        pendingNotifications = self.pendingNotificationsToDelete;
        self.pendingNotificationsToDelete = nil;
    }

    if (pendingNotifications) {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];

        [center removeDeliveredNotificationsWithIdentifiers:[pendingNotifications allObjects]];
    }
}

- (void)dismissModalViewController {
    DDLogVerbose(@"%@ dismissModalViewController", LOG_TAG);
    
    UIViewController *topViewController = [UIViewController topViewController];
    if ([topViewController isKindOfClass:[UISearchController class]]) {
        UIViewController *presentingViewController = topViewController.presentingViewController;
        if (presentingViewController.parentViewController && presentingViewController.parentViewController.presentingViewController) {
            [presentingViewController.parentViewController dismissViewControllerAnimated:NO completion:^{
            }];
        }
    } else if (topViewController.presentingViewController) {
        [topViewController dismissViewControllerAnimated:NO completion:^{
        }];
    } else if (topViewController.presentedViewController) {
        [topViewController.presentedViewController dismissViewControllerAnimated:NO completion:^{
        }];
    }
}

- (nonnull UIImage *)getAvatarWithOriginator:(nonnull id<TLOriginator>)originator {
    
    TLImageService *imageService = [self.twinmeContext getImageService];
    
    UIImage *image = nil;
    TLImageId *imageId = [originator avatarId];
    if (imageId) {
        image = [imageService getCachedImageWithImageId:imageId kind:TLImageServiceKindThumbnail];
    }
    if (!image) {
        if (originator.isGroup) {
            image = [TLTwinmeAttributes DEFAULT_GROUP_AVATAR];
        } else {
            image = [TLTwinmeAttributes DEFAULT_AVATAR];
        }
    }
    return image;
}

- (BOOL)showNotification:(nonnull id<TLOriginator>)originator {
    
    if (!originator.space) {
        return YES;
    }
    
    BOOL allowNotification = [originator.space.settings getBooleanWithName:PROPERTY_DISPLAY_NOTIFICATIONS defaultValue:YES];
    if (allowNotification || (!self.inBackground && !allowNotification && [self.twinmeContext isCurrentSpace:originator])) {
        return YES;
    }
    
    return NO;
}

@end
