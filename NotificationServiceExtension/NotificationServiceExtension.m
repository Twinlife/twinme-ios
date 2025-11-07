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
#include <notify.h>

#import <PushKit/PushKit.h>
#import <UserNotifications/UserNotifications.h>
#import <AudioToolbox/AudioToolbox.h>

#import <WebRTC/RTCLogging.h>
#import <WebRTC/RTCSSLAdapter.h>

#import <Twinlife/TLTwinlife.h>
#import <Twinlife/TLManagementService.h>
#import <Twinlife/TLPeerConnectionService.h>
#import <Twinlife/TLAccountService.h>
#import <Twinlife/TLConnectivityService.h>
#import <Twinlife/TLConversationService.h>
#import <Twinlife/TLNotificationService.h>
#import <Twinlife/TLPeerConnectionService.h>
#import <Twinlife/TLRepositoryService.h>
#import <Twinlife/TLTwincodeFactoryService.h>
#import <Twinlife/TLTwincodeInboundService.h>
#import <Twinlife/TLTwincodeOutboundService.h>
#import <Twinlife/TLImageService.h>
#import <Twinlife/TLTwinlifeContext.h>
#import <Twinlife/TLJobService.h>
#import <Twinlife/TLPeerConnectionService.h>
#import <Twinlife/TLPeerCallService.h>
#import <Twinlife/TLCryptoService.h>

#import <Twinme/TLPushNotificationContent.h>
#import <Twinme/TLNotificationCenter.h>
#import <Twinme/TLTwinmeConfiguration.h>
#import <Twinme/TLMessage.h>
#import <Twinme/TLTyping.h>
#import <Twinme/TLOriginator.h>
#import <Twinme/TLContact.h>
#import <Twinme/TLGroup.h>
#import <Twinme/TLGroupMember.h>
#import <Twinme/TLRoomCommand.h>
#import <Twinme/TLRoomCommandResult.h>
#import <Twinme/TLTwinmeApplication.h>
#import <Twinme/TLTwinmeContext.h>

#import <Notification/NotificationSettings.h>
#import <Notification/NotificationTools.h>

#import <Utils/NSString+Utils.h>

#import "NotificationServiceExtension.h"

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

#define TwinmeLocalizedString(key, comment) [NSString localizedStringForKey:(key) replaceValue:(comment)]
#define NOTIFICATION_TIMEOUT (23*1000)
#define CHECK_INVOCATION_DELAY  1.5     // Check whether we have pending invocations each 1.5s
#define DISCONNECT_DELAY 0.5            // Delay to wait before disconnecting from Twinme server after onTerminate (500ms).
#define FLUSH_NOTIFICATIONS_DELAY 0.5   // Delay to wait before flushing the notifications after onTwinlifeOffline (500ms).
#define HAVE_NOTIFICATION_FILTERING (YES)

static NSString *APPLICATION_NAME = @"twinme";

@class NotificationServicePeerConnectionServiceDelegate;
@class NotificationServiceConversationServiceDelegate;

/**
 * There is only one instance of the NotificationService created when the service extension is created. It creates the Twinlife context,
 * the Twinme context and implements the API of the TLNotificationCenter interface. It manages the start of the extension, the
 * connection and disconnection to the OpenFire server when this is necessary.
 *
 * Each time a notification is received, a NotificationServiceExtension instance is created and the didReceiveNotificationRequest
 * operation is called. We can receive several notifications at the same time and must be prepared to handle them.
 * The NotificationServiceExtension instance is added to a list maintained by the NotificationService.
 *
 * The NotificationTools is used to prepare the notification according to the user settings and rules that are common with the
 * application. When a notification is hidden, the NotificationTools will return a null instance and we must try to hide/delete the
 * received notification (which is not allowed in the extension as explained in WWDC 17's Best Practices and What’s New in User Notifications,
 * starting at 22:17 min in the video, there is no written documentation about it).
 *
 * When a message is received, the oldest NotificationServiceExtension is removed from the notifications queue and updated with
 * the content of the message. It is then placed in the readyNotifications queue. The completion handler associated with the
 * notification MUST NOT be called immediately. We MUST wait for the termination of all P2P sessions, then close the OpenFire
 * session, close the database. This is to make sure we are able to report and handle all the pending work related to the P2P.
 *
 * While P2P operations are executed, we also track whether there are some message read, message deleted, conversation reset
 * and other operations that don't produce a new message. These actions are tracked and used to replace the generic "Notifications"
 * message by a localize message that is more appropriate.
 *
 * When all P2P sessions are closed, we schedule a timer after 500ms to close properly the OpenFire connection, stop the Twinlife
 * service and close the database. Once this is done, the flushNotifications operation is called and this triggers the execution of
 * all the completion handlers of notifications that have been resolved.
 *
 * At the last resort, the serviceExtensionTimeWillExpire is called on a notification when it's processing time took too long.
 * We flush immediatly the resolved notification by calling flushNotifications.
 */

//
// Interface: Configuration
//

@interface Configuration : TLTwinmeConfiguration

@end

typedef enum {
    SilentNotificationTypeSynchronize,
    SilentNotificationTypeMessageRead,
    SilentNotificationTypeMessageDeleted,
    SilentNotificationTypeResetConversation,
    SilentNotificationTypeMessageJoinGroup,
    SilentNotificationTypeMessageLeaveGroup
} SilentNotificationType;

//
// Interface: NotificationService
//

@interface NotificationService : TLTwinmeApplication <TLNotificationCenter, TLJob>

@property (nonatomic, readonly, nonnull) TLTwinmeContext *twinmeContext;
@property (nonatomic, readonly, nonnull) TLJobService *jobService;
@property (nonatomic, readonly, nonnull) NotificationSettings *notificationSettings;
@property (nonatomic, readonly, nonnull) NotificationTools *notificationTools;
@property (nonatomic, readonly, nonnull) NotificationServicePeerConnectionServiceDelegate *notificationServicePeerConnectionServiceDelegate;
@property (nonatomic, readonly, nonnull) NotificationServiceConversationServiceDelegate *notificationServiceConversationServiceDelegate;
@property (nonatomic, readonly, nonnull) NSMutableArray<NotificationServiceExtension *> *notifications;
@property (nonatomic, readonly, nonnull) NSMutableArray<NotificationServiceExtension *> *readyNotifications;
@property (nonatomic, readonly, nonnull) NSMutableArray<NotificationServiceExtension *> *expiredNotifications;
@property (nonatomic, readonly, nonnull) NSMutableArray<id<TLOriginator>> *originators;
@property (readonly, nonnull) CFNotificationCenterRef darwinNotificationCenter;
@property long badgeNumber;
@property long currentBadgeNumber;
@property BOOL initialized;
@property BOOL isReady;
@property int readMessageCount;
@property int deleteMessageCount;
@property int resetConversationCount;
@property (nullable) TLJobId *timeoutJob;
@property (nullable) NSTimer *disconnectTimer;
@property (nullable) NSTimer *flushTimer;
@property (nullable) NSTimer *checkInvocationTimer;


/// Get the NotificationService instance (there is only one).
+ (nonnull NotificationService *)instance;

/// Initialize the first instance.
- (nonnull instancetype)init;

/// First callback invoked to setup the NotificationService.
- (void)onTwinlifeReady;

- (void)onTwinlifeOnline;

- (void)onTwinlifeOffline;

- (void)onTerminatePeerConnectionWithPeerConnectionId:(nonnull NSUUID *)peerConnectionId;

- (void)touchConversationWithConversation:(id<TLConversation>)conversation type:(SilentNotificationType)type;

/// Check whether we have pending invocations, prepare to shutdown unless we have no active P2P session.
- (void)checkInvocationsTimerHandler;

- (void)scheduleDisconnect;

/// Schedule a call to twinlife stop to suspend execution.
- (void)scheduleSuspend;

/// Schedule a time to check whether we still have pending invocations.
- (void)scheduleCheckInvocations;

/// Flush the notifications in readyNotifications and execute their completion handlers.
- (void)flushNotifications;

/// Process the notifications that have expired according to the deadline.  By passing a deadline at 0, we force the expiration
/// of all pending notifications. This is done when we have terminated the P2P connection that triggered the APNs.
/// In that case, we won't receive anything.
- (void)processExpiredNotificationsWithDeadline:(int64_t)deadline;

@end

@implementation Configuration

- (instancetype)init {
    
    self = [super initWithName:APPLICATION_NAME applicationVersion:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"] serializers:@[[[TLMessageSerializer alloc] init], [[TLTypingSerializer alloc] init], [[TLRoomCommandSerializer alloc] init], [[TLRoomCommandResultSerializer alloc] init]] enableKeepAlive:NO enableSetup:NO enableCaches:NO enableReports:NO enableInvocations:YES enableSpaces:NO refreshBadgeDelay:-1.0];
    
    if (self) {
        // Disable auto registration.
        self.accountServiceConfiguration.serviceOn = true;
        self.accountServiceConfiguration.defaultAuthenticationAuthority = TLAccountServiceAuthenticationAuthorityUnregistered;
        self.conversationServiceConfiguration.serviceOn = true;
        // We can now enable the conversation scheduler and perform outgoing P2P connection
        // to send pending operations.  This rely heavily on the saving of lastRetryDate and delayPos
        // in the conversation table either by the application itself, or, by the extension.
        self.conversationServiceConfiguration.enableScheduler = true;
        self.conversationServiceConfiguration.lockIdentifier = 2;
        self.connectivityServiceConfiguration.serviceOn = true;
        self.notificationServiceConfiguration.serviceOn = true;
        // Don't save the environment in the extension.
        self.managementServiceConfiguration.saveEnvironment = false;
        self.peerConnectionServiceConfiguration.serviceOn = true;
        self.peerConnectionServiceConfiguration.acceptIncomingCalls = true;
        // Disable Audio and Video.
        self.peerConnectionServiceConfiguration.enableAudioVideo = false;
        self.repositoryServiceConfiguration.serviceOn = true;
        self.twincodeFactoryServiceConfiguration.serviceOn = true;
        self.twincodeInboundServiceConfiguration.serviceOn = true;
        self.twincodeOutboundServiceConfiguration.serviceOn = true;
        self.imageServiceConfiguration.serviceOn = true;
        self.peerCallServiceConfiguration.serviceOn = true;
        self.cryptoServiceConfiguration.serviceOn = true;
    }
    return self;
}

@end

//
// Interface: NotificationServicePeerConnectionServiceDelegate
//

@interface NotificationServicePeerConnectionServiceDelegate : NSObject <TLPeerConnectionServiceDelegate>

@property (weak) NotificationService *service;

- (nonnull instancetype)initWithService:(nonnull NotificationService *)service;

@end

//
// Implementation: NotificationServicePeerConnectionServiceDelegate
//

#undef LOG_TAG
#define LOG_TAG @"NotificationServicePeerConnectionServiceDelegate"

@implementation NotificationServicePeerConnectionServiceDelegate

- (nonnull instancetype)initWithService:(nonnull NotificationService *)service {
    DDLogVerbose(@"%@ initWithService: %@", LOG_TAG, service);
    
    self = [super init];
    if (self) {
        _service = service;
    }
    return self;
}

- (void)onTerminatePeerConnectionWithPeerConnectionId:(nonnull NSUUID *)peerConnectionId terminateReason:(TLPeerConnectionServiceTerminateReason)terminateReason {
    DDLogVerbose(@"%@ onTerminatePeerConnectionWithPeerConnectionId: %@ terminateReason: %d", LOG_TAG, peerConnectionId, terminateReason);
    
    [self.service onTerminatePeerConnectionWithPeerConnectionId:peerConnectionId];
}

@end

//
// Interface: NotificationServiceConversationServiceDelegate
//

@interface NotificationServiceConversationServiceDelegate:NSObject <TLConversationServiceDelegate>

@property (weak) NotificationService *service;

- (nonnull nonnull instancetype)initWithService:(nonnull NotificationService *)service;

@end

//
// Implementation: NotificationServiceConversationServiceDelegate
//

#undef LOG_TAG
#define LOG_TAG @"NotificationServiceConversationServiceDelegate"

@implementation NotificationServiceConversationServiceDelegate

- (nonnull instancetype)initWithService:(nonnull NotificationService *)service {
    DDLogVerbose(@"%@ initWithService: %@", LOG_TAG, service);
    
    self = [super init];
    
    if (self) {
        _service = service;
    }
    return self;
}

- (void)onUpdateDescriptorWithRequestId:(int64_t)requestId conversation:(id<TLConversation>)conversation descriptor:(TLDescriptor *)descriptor updateType:(TLConversationServiceUpdateType)updateType {
    DDLogVerbose(@"%@ onUpdateDescriptorWithRequestId: %lld conversation: %@ descriptor: %@ updateType: %u", LOG_TAG, requestId, conversation, descriptor, updateType);

    [self.service touchConversationWithConversation:conversation type:SilentNotificationTypeSynchronize];
}

- (void)onMarkDescriptorReadWithRequestId:(int64_t)requestId conversation:(id<TLConversation>)conversation descriptor:(TLDescriptor *)descriptor {
    DDLogVerbose(@"%@ onMarkDescriptorReadWithRequestId: %lld conversation: %@ descriptor: %@", LOG_TAG, requestId, conversation, descriptor);
    
    [self.service touchConversationWithConversation:conversation type:SilentNotificationTypeMessageRead];
}

- (void)onDeleteDescriptorsWithRequestId:(int64_t)requestId conversation:(id<TLConversation>)conversation descriptors:(NSArray<TLDescriptorId *> *)descriptors {
    DDLogVerbose(@"%@ onDeleteDescriptorsWithRequestId: %lld conversation: %@ descriptors: %@", LOG_TAG, requestId, conversation, descriptors);
    
    [self.service touchConversationWithConversation:conversation type:SilentNotificationTypeMessageDeleted];
}

- (void)onJoinGroupRequestWithRequestId:(int64_t)requestId group:(id <TLGroupConversation>)group invitation:(TLInvitationDescriptor *)invitation memberId:(NSUUID *)memberId {
    DDLogVerbose(@"%@ onJoinGroupWithRequestId: %lld group: %@ invitation: %@ memberId: %@", LOG_TAG, requestId, group, invitation, memberId);
    
    [self.service touchConversationWithConversation:group type:SilentNotificationTypeMessageJoinGroup];
}

- (void)onJoinGroupResponseWithRequestId:(int64_t)requestId group:(id <TLGroupConversation>)group invitation:(TLInvitationDescriptor *)invitation {
    DDLogVerbose(@"%@ onJoinGroupResponseWithRequestId: %lld group: %@ invitation: %@", LOG_TAG, requestId, group, invitation);
    
    [self.service touchConversationWithConversation:group type:SilentNotificationTypeMessageJoinGroup];
}

- (void)onLeaveGroupWithRequestId:(int64_t)requestId group:(id <TLGroupConversation>)group memberId:(NSUUID *)memberId {
    DDLogVerbose(@"%@ onLeaveGroupWithRequestId: %lld group: %@ memberId: %@", LOG_TAG, requestId, group, memberId);

    [self.service touchConversationWithConversation:group type:SilentNotificationTypeMessageLeaveGroup];
}

- (void)onResetConversationWithRequestId:(int64_t)requestId conversation:(id <TLConversation>)conversation clearMode:(TLConversationServiceClearMode)clearMode {
    DDLogVerbose(@"%@ onResetConversationWithRequestId: %lld conversation: %@ clearMode: %d", LOG_TAG, requestId, conversation, clearMode);
    
    [self.service touchConversationWithConversation:conversation type:SilentNotificationTypeResetConversation];
}

- (void)onDeleteGroupConversationWithRequestId:(int64_t)requestId conversationId:(NSUUID *)conversationId groupId:(NSUUID *)groupId {
    DDLogVerbose(@"%@ onDeleteGroupConversationWithRequestId: %lld conversationId: %@ groupId: %@", LOG_TAG, requestId, conversationId, groupId);

}

@end

#undef LOG_TAG
#define LOG_TAG @"NotificationService"

@implementation NotificationService

static NotificationService *INSTANCE;

+ (void)initialize {
    
    // Create the main instance and do the Twinlife, TwinmeContext and WebRTC setup.
    INSTANCE = [[NotificationService alloc] init];
}

+ (nonnull NotificationService *)instance {
    DDLogVerbose(@"%@ instance", LOG_TAG);
    
    return INSTANCE;
}

- (instancetype)init {
    DDLogVerbose(@"%@ init", LOG_TAG);
    
    self = [super init];
    
    if (self) {
        // Setup to log on the iOS system console.
        [DDLog addLogger:[DDOSLogger sharedInstance]];

        _twinmeContext = [[TLTwinmeContext alloc] initWithTwinmeApplication:self configuration:[[Configuration alloc] init]];
        _jobService = [_twinmeContext getJobService];
        _notificationSettings = [[NotificationSettings alloc] init];
        _notificationTools = [[NotificationTools alloc] initWithTwinmeContext:_twinmeContext settings:_notificationSettings];
        _notificationServicePeerConnectionServiceDelegate = [[NotificationServicePeerConnectionServiceDelegate alloc] initWithService:self];
        _isReady = NO;
        _badgeNumber = 0;
        _notificationServiceConversationServiceDelegate = [[NotificationServiceConversationServiceDelegate alloc] initWithService:self];
        _notifications = [[NSMutableArray alloc] init];
        _readyNotifications = [[NSMutableArray alloc] init];
        _expiredNotifications = [[NSMutableArray alloc] init];
        _originators = [[NSMutableArray alloc] init];
        _darwinNotificationCenter = CFNotificationCenterGetDarwinNotifyCenter();

        [NotificationSettings initializeSettings];
        RTCInitializeSSL();
        
#if defined(NDEBUG)
        RTCSetMinDebugLogLevel(RTCLoggingSeverityWarning);
#endif
    }
    return self;
}

- (id<TLNotificationCenter>)allocNotificationCenterWithTwinmeContext:(TLTwinmeContext *)twinmeContext {
    DDLogVerbose(@"%@ allocNotificationCenterWithTwinmeContext: %@", LOG_TAG, twinmeContext);
    
    [super allocNotificationCenterWithTwinmeContext:twinmeContext];
    return self;
}

- (void)onTwinlifeReady {
    DDLogVerbose(@"%@ onTwinlifeReady", LOG_TAG);
    
    @synchronized (self) {
        if (!self.isReady) {
            self.isReady = YES;
            [[self.twinmeContext getConversationService] addDelegate:self.notificationServiceConversationServiceDelegate];
            [[self.twinmeContext getPeerConnectionService] addDelegate:self.notificationServicePeerConnectionServiceDelegate];
        }

        // Reset the configuration to start in fresh configuration.
        self.deleteMessageCount = 0;
        self.readMessageCount = 0;
        self.resetConversationCount = 0;
        [self.originators removeAllObjects];
    }
    [self reloadBadgeNumber];
}

- (void)onTwinlifeOnline {
    DDLogVerbose(@"%@ onTwinlifeOnline", LOG_TAG);

    @synchronized (self) {
        if (self.disconnectTimer && self.notifications.count > 0) {
            [self.disconnectTimer invalidate];
            self.disconnectTimer = nil;
        }
    }

    // Start the check invocation timer only when we are connected.
    [self scheduleCheckInvocations];
}

- (void)onTwinlifeOffline {
    DDLogVerbose(@"%@ onTwinlifeOffline status: %d", LOG_TAG, [self.twinmeContext status]);

    // If Twinlife is still active, ignore this offline.
    if ([self.twinmeContext status] == TLTwinlifeStatusStarted) {

        return;
    }

    // We are now offline and Twinlife is stopped.
    // Setup a timer in the main queue to flush the notifications in 500ms.
    // This delay allows us to close the database before flushing the notification and being stopped.
    [self processExpiredNotificationsWithDeadline:0];
    [self scheduleSuspend];
}

- (void)onIncomingMigrationWithAccountMigration:(nonnull TLAccountMigration *)accountMigration peerConnectionId:(nonnull NSUUID *)peerConnectionId {
    DDLogVerbose(@"%@ onIncomingMigrationWithAccountMigration: %@", LOG_TAG, peerConnectionId);

}

- (void)onTerminatePeerConnectionWithPeerConnectionId:(nonnull NSUUID *)peerConnectionId {
    DDLogVerbose(@"%@ onTerminatePeerConnectionWithPeerConnectionId: %@", LOG_TAG, peerConnectionId);

    long sessionCount = [self activeSessionCount];
    if (sessionCount == 0) {
        [self scheduleDisconnect];
    }
}

- (void)disconnectTimerHandler {
    DDLogVerbose(@"%@ disconnectTimerHandler", LOG_TAG);

    @synchronized (self) {
        self.disconnectTimer = nil;
        long sessionCount = [self activeSessionCount];

        // If there is an active P2P connection or some pending invocation, don't disconnect.
        if (sessionCount != 0 || [self.twinmeContext hasPendingInvocations]) {
            DDLogVerbose(@"%@ disconnect ignore active sessions=%ld", LOG_TAG, sessionCount);

            // It is possible that the checkInvocationTimer was disabled, because we continue waiting
            // make sure it is enabled again.
            if (!self.checkInvocationTimer) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self scheduleCheckInvocations];
                });
            }
            return;
        }
        if (self.checkInvocationTimer) {
            [self.checkInvocationTimer invalidate];
            self.checkInvocationTimer = nil;
        }
    }
    BOOL flushNotifications = [self.twinmeContext isConnected] == NO;

    // Stop Twinlife to shutdown the OpenFire connection and close the database.
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.twinmeContext stopWithCompletionHandler:nil];
    });

    if (flushNotifications) {
        [self processExpiredNotificationsWithDeadline:0];
    }
}

- (void)checkInvocationsTimerHandler {
    DDLogVerbose(@"%@ checkInvocationsTimerHandler", LOG_TAG);

    BOOL canStop;
    @synchronized (self) {
        self.checkInvocationTimer = nil;
        long sessionCount = [self activeSessionCount];

        // If there is an active P2P connection, don't disconnect.
        canStop = (sessionCount == 0 && ![self.twinmeContext hasPendingInvocations]);
    }

    if (canStop) {
        [self scheduleDisconnect];
    } else {
        [self scheduleCheckInvocations];
    }
}

- (void)didReceiveNotification:(nonnull NotificationServiceExtension *)notification {
    DDLogVerbose(@"%@ didReceiveNotification count: %ld expired: %ld", LOG_TAG, (long)self.notifications.count, (long)self.expiredNotifications.count);
    
    @synchronized (self) {
        if (!self.initialized) {
            [self.twinmeContext addDelegate:self];
            self.initialized = YES;
        }
        self.twinmeContext.enableInvocations = YES;

        [self.notifications addObject:notification];
        
        // A new notification is received, invalidate the disconnect timer in case it is scheduled.
        if (self.disconnectTimer) {
            [self.disconnectTimer invalidate];
            self.disconnectTimer = nil;
        }
    }
    // Start Twinlife so that we activate the com.twinlife.ConnectionMonitor thread to setup the OpenFire websocket.
    if ([self.twinmeContext status] != TLTwinlifeStatusStarted) {
        [self.twinmeContext start];
    } else {
        [self.twinmeContext connect];
    }

    if (!self.timeoutJob) {
        [self.notificationSettings reload];
        [self scheduleTimeout];
    }
    
    // Activate the timer to check that we have finished to process the pending invocations (only if we are connected).
    if ([self.twinmeContext isConnected]) {
        [self scheduleCheckInvocations];
    }
    
    // Decode the notification content: it could be an incoming Audio/Video APNS notification (China issue).
    // The fetchCompletionHandler is called by the Job Service when we are going to be suspended.
    [self.twinmeContext didReceiveIncomingPushWithPayload:notification.notification.userInfo application:nil completionHandler:^(TLBaseServiceErrorCode errorCode, TLPushNotificationContent *notificationContent) {
        [self didReceiveNotificationWithContent:notificationContent];
    } terminateCompletionHandler:^(TLBaseServiceErrorCode errorCode) {
        DDLogVerbose(@"%@ didReceiveIncomingPush fetch completion handler called: flushing notifications", LOG_TAG);
        [self flushNotifications];
    }];
}

- (void)didReceiveNotificationWithContent:(nullable TLPushNotificationContent *)notificationContent {
    DDLogVerbose(@"%@ didReceiveNotificationWithContent: %@", LOG_TAG, notificationContent);

    if (notificationContent && notificationContent.originator) {
        switch (notificationContent.operation) {
            case TLPeerConnectionServiceNotificationOperationAudioCall:
            {
                [self dispatchNotificationWithBlock:^(NSUUID *notificationId) {
                    if (!notificationId) {
                        notificationId = notificationContent.sessionId;
                    }
                    return [self.notificationTools createNotificationIncomingCallWithContact:(TLContact *)notificationContent.originator video:NO notificationId:notificationId];
                }];
                [self scheduleDisconnect];
                break;
            }

            case TLPeerConnectionServiceNotificationOperationVideoBell:
            case TLPeerConnectionServiceNotificationOperationVideoCall:
            {
                [self dispatchNotificationWithBlock:^(NSUUID *notificationId) {
                    if (!notificationId) {
                        notificationId = notificationContent.sessionId;
                    }
                    return [self.notificationTools createNotificationIncomingCallWithContact:(TLContact *)notificationContent.originator video:YES notificationId:notificationId];
                }];
                [self scheduleDisconnect];
                break;
            }

            default:
                // We know the contact or group, remember it in case we don't get a useful notification.
                @synchronized (self) {
                    [self.originators addObject:notificationContent.originator];
                }
                break;
        }
    }
}

- (void)reloadBadgeNumber {
    DDLogVerbose(@"%@ reloadBadgeNumber", LOG_TAG);

    long currentBadgeNumber = [self.notificationSettings getNotificationBadgeNumber];
    @synchronized (self) {
        self.currentBadgeNumber = currentBadgeNumber;
        self.badgeNumber = currentBadgeNumber;
    }
}

- (void)flushNotifications {
    DDLogVerbose(@"%@ flushNotifications", LOG_TAG);

    // Step 1: update the badge.
    long badgeNumber = -1;
    @synchronized (self) {
        if (self.flushTimer) {
            [self.flushTimer invalidate];
            self.flushTimer = nil;
        }

        if (self.badgeNumber != self.currentBadgeNumber) {
            badgeNumber = self.badgeNumber;
            self.currentBadgeNumber = badgeNumber;
        }
    }
    // Save the new value of the badge number.
    if (badgeNumber >= 0) {
        DDLogVerbose(@"%@ updateNotificationBadgeNumber: %ld", LOG_TAG, badgeNumber);
        [self.notificationSettings updateNotificationBadgeNumber:badgeNumber];
    }

    // Step 2: Call the completion handlers for notifications that are ready.
    @synchronized (self) {
        for (NotificationServiceExtension *notification in self.readyNotifications) {
            if (notification.contentHandler && notification.notification) {
                notification.notification.badge = [NSNumber numberWithLong:self.badgeNumber];
                notification.contentHandler(notification.notification);
                notification.contentHandler = nil;
            }
        }
        [self.readyNotifications removeAllObjects];
    }

    // Step 3: handle the last chance notification.
    [self flushExpiringNotifications];

    // Step 4: we are almost frozen at this step, iOS will terminate all opened sockets, timers will not fire.
}

- (void)flushExpiringNotifications {
    DDLogVerbose(@"%@ flushExpiringNotifications", LOG_TAG);

    @synchronized (self) {
        for (NotificationServiceExtension *notification in self.expiredNotifications) {
            [notification sendDefaultNotification];
        }

        [self.expiredNotifications removeAllObjects];
    }
}

- (void)suspendTimerHandler {
    DDLogVerbose(@"%@ suspendTimerHandler", LOG_TAG);

    // Stop Twinlife to shutdown the OpenFire connection and close the database.
    [self.twinmeContext stopWithCompletionHandler:nil];
}

- (long)activeSessionCount {
    DDLogVerbose(@"%@ activeSessionCount", LOG_TAG);

    return [[self.twinmeContext getPeerConnectionService] sessionCount];
}

#pragma mark - TLNotificationCenter

- (void)onIncomingCallWithContact:(id<TLOriginator>)contact peerConnectionId:(NSUUID *)peerConnectionId offer:(TLOffer *)offer {
    DDLogVerbose(@"%@ onIncomingCallWithContact: %@ peerConnectionId: %@ offer: %@", LOG_TAG, contact, peerConnectionId, offer);

}

- (void)onJoinGroupWithGroup:(id<TLOriginator>)group conversationId:(NSUUID *)conversationId {
    DDLogVerbose(@"%@ onJoinGroupWithGroup: %@ conversationId: %@", LOG_TAG, group, conversationId);
    
    [self dispatchNotificationWithBlock:^(NSUUID *notificationId) {
        return [self.notificationTools createNotificationJoinGroupWithGroup:group conversationId:conversationId notificationId:notificationId];
    }];
}

- (void)onNewContactWithContact:(id<TLOriginator>)contact {
    DDLogVerbose(@"%@ onNewContactWithContact: %@", LOG_TAG, contact);
    
    [self dispatchNotificationWithBlock:^(NSUUID *notificationId) {
        return [self.notificationTools createNotificationNewContactWithContact:contact notificationId:notificationId];
    }];
}

- (void)onPopDescriptorWithContact:(id<TLOriginator>)contact conversationId:(NSUUID *)conversationId descriptor:(TLDescriptor *)descriptor {
    DDLogVerbose(@"%@ onPopDescriptorWithContact: %@ conversationId: %@ descriptor: %@", LOG_TAG, contact, conversationId, descriptor);
    
    [self dispatchNotificationWithBlock:^(NSUUID *notificationId) {
        return [self.notificationTools createNotificationDescriptorWithContact:contact conversationId:conversationId descriptor:descriptor notificationId:notificationId];
    }];
}

- (void)onSetActiveConversationWithConversationId:(NSUUID *)conversationId {
    
}

- (void)onUnbindContactWithContact:(id<TLOriginator>)contact {
    DDLogVerbose(@"%@ onUnbindContactWithContact: %@", LOG_TAG, contact);
    
    [self dispatchNotificationWithBlock:^(NSUUID *notificationId) {
        return [self.notificationTools createNotificationUnbindContactWithContact:contact notificationId:notificationId];
    }];
}

- (void)onUpdateContactWithContact:(id<TLOriginator>)contact updatedAttributes:(nonnull NSArray<TLAttributeNameValue *> *)updatedAttributes {
    DDLogVerbose(@"%@ onUpdateContactWithContact: %@", LOG_TAG, contact);
    
    [self dispatchNotificationWithBlock:^(NSUUID *notificationId) {
        return [self.notificationTools createNotificationUpdateContactWithContact:contact updatedAttributes:updatedAttributes notificationId:notificationId];
    }];
}

- (void)onUpdateDescriptorWithContact:(id<TLOriginator>)contact conversationId:(NSUUID *)conversationId descriptor:(TLDescriptor *)descriptor updateType:(TLConversationServiceUpdateType)updateType {
    DDLogVerbose(@"%@ onUpdateDescriptorWithContact: %@ conversationId: %@ descriptor: %@ updateType: %d", LOG_TAG, contact, conversationId, descriptor, updateType);

}

- (void)onUpdateAnnotationWithContact:(id<TLOriginator>)contact conversationId:(NSUUID *)conversationId descriptor:(TLDescriptor *)descriptor annotatingUser:(nonnull TLTwincodeOutbound *)annotatingUser {
    DDLogVerbose(@"%@ onUpdateDescriptorWithContact: %@ conversationId: %@ descriptor: %@ annotatingUser: %@", LOG_TAG, contact, conversationId, descriptor, annotatingUser);

    [self dispatchNotificationWithBlock:^(NSUUID *notificationId) {
        return [self.notificationTools createNotificationAnnotationWithContact:contact conversationId:conversationId descriptor:descriptor annotatingUser:annotatingUser notificationId:notificationId];
    }];
}

- (void)updateApplicationBadgeNumber:(NSInteger)applicationBadgeNumber {
    DDLogVerbose(@"%@ updateApplicationBadgeNumber: %d", LOG_TAG, (int)applicationBadgeNumber);

    // Note: the badge number computed by the notification service extension is not correct
    // because the notification service does not load all the contacts.  Therefore the TwinmeContext
    // cannot identify the contacts which are relevant or not and many pending notifications are not
    // taken into account.  Instead, we use the AppShared area to store the badge number and use it.
    // We have to increment ourselves the badge counter each time we add some notification.
}

- (void)cancelWithNotificationId:(nonnull NSUUID *)notificationId {
    DDLogVerbose(@"%@ cancelWithNotificationId: %@", LOG_TAG, notificationId);

    UNUserNotificationCenter *userNotificationCenter = [UNUserNotificationCenter currentNotificationCenter];
    
    NSMutableArray *list = [[NSMutableArray alloc] init];
    [list addObject:notificationId.UUIDString];
    [userNotificationCenter removeDeliveredNotificationsWithIdentifiers:list];
}

#pragma mark - Notification support

- (void)touchConversationWithConversation:(id<TLConversation>)conversation type:(SilentNotificationType)type {
    DDLogVerbose(@"%@ touchConversationWithConversation: %@ type: %d", LOG_TAG, conversation, type);

    @synchronized (self) {
        switch (type) {
            case SilentNotificationTypeMessageRead:
                self.readMessageCount++;
                break;
                
            case SilentNotificationTypeMessageDeleted:
                self.deleteMessageCount++;
                break;
                
            case SilentNotificationTypeResetConversation:
                self.resetConversationCount++;
                break;
                
            default:
                break;
        }
    }
}

- (void)dispatchNotificationWithBlock:(nullable NotificationInfo * (^)(NSUUID *notificationId))block {
    DDLogVerbose(@"%@ dispatchNotificationWithBlock", LOG_TAG);

    // Find a system notification that can be used to get its notification id for the creation
    // of our notification.  We mark the system notification with processing=YES and keep it in
    // the list until it is really processed and updated with the notification IFF it was created.
    NotificationServiceExtension *notification = nil;
    NSUUID *notificationId = nil;
    @synchronized (self) {
        for (notification in self.notifications) {
            if (!notification.processing) {
                notification.processing = YES;
                
                notificationId = [[NSUUID alloc] initWithUUIDString:notification.request.identifier];
                break;
            }
        }
    }

    NotificationInfo *info = block(notificationId);

    // No system notification to post, backtrack: the system notification is available.
    if (!info) {
        if (notification) {
            @synchronized (self) {
                notification.processing = NO;
            }
        }
        return;
    }

    if (notification) {
        notification.notification.title = info.alertTitle;
        notification.notification.body = info.alertBody;
        notification.notification.userInfo = info.userInfo;
        if (info.alertSound) {
            notification.notification.sound = info.alertSound;
        }

        @synchronized (self) {
            self.badgeNumber++;
            notification.notification.badge = [NSNumber numberWithInteger:self.badgeNumber];

            // Move it to the ready queue.
            [self.notifications removeObject:notification];
            [self.readyNotifications addObject:notification];
        }
        return;
    }

    // Send other notifications to the iOS notification center.
    UNMutableNotificationContent *notificationContent = [[UNMutableNotificationContent alloc] init];
    notificationId = info.identifier;
    notificationContent.title = info.alertTitle;
    notificationContent.subtitle = info.alertBody;
    notificationContent.categoryIdentifier = @"NOTIFICATION";
    @synchronized (self) {
        self.badgeNumber++;
        notification.notification.badge = [NSNumber numberWithInteger:self.badgeNumber];
    }
    notificationContent.sound = info.alertSound;
    
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:notificationId.UUIDString content:notificationContent trigger:nil];
    
    // Each time we post a notification, we seem to get more credit to run.
    UNUserNotificationCenter *userNotificationCenter = [UNUserNotificationCenter currentNotificationCenter];
    [userNotificationCenter addNotificationRequest:request withCompletionHandler:^(NSError *error) {
        
    }];
}

- (void)scheduleCheckInvocations {
    DDLogVerbose(@"%@ scheduleCheckInvocations", LOG_TAG);

    // Setup a timer in the main queue to check if we still have pending invocation
    // and if not, whether we can close and proceed with the shutdown.
    dispatch_async(dispatch_get_main_queue(), ^{
        @synchronized (self) {
            if (!self.checkInvocationTimer) {
                DDLogVerbose(@"%@ schedule checkInvocation timer in 1.5s", LOG_TAG);

                self.checkInvocationTimer = [NSTimer scheduledTimerWithTimeInterval:CHECK_INVOCATION_DELAY target:self selector:@selector(checkInvocationsTimerHandler) userInfo:nil repeats:NO];
            }
        }
    });
}

- (void)scheduleDisconnect {
    DDLogVerbose(@"%@ scheduleDisconnect", LOG_TAG);

    // Setup a timer in the main queue to close the websocket connection in 500ms.
    dispatch_async(dispatch_get_main_queue(), ^{
        @synchronized (self) {
            if (!self.disconnectTimer) {
                DDLogVerbose(@"%@ schedule disconnect timer in 500ms", LOG_TAG);

                self.disconnectTimer = [NSTimer scheduledTimerWithTimeInterval:DISCONNECT_DELAY target:self selector:@selector(disconnectTimerHandler) userInfo:nil repeats:NO];
            }
        }
    });
}

- (void)scheduleSuspend {
    DDLogVerbose(@"%@ scheduleSuspend", LOG_TAG);

    dispatch_async(dispatch_get_main_queue(), ^{
        @synchronized (self) {
            if (!self.flushTimer && self.readyNotifications.count + self.expiredNotifications.count > 0) {
                DDLogVerbose(@"%@ schedule suspend timer in 500ms", LOG_TAG);

                self.flushTimer = [NSTimer scheduledTimerWithTimeInterval:FLUSH_NOTIFICATIONS_DELAY target:self selector:@selector(suspendTimerHandler) userInfo:nil repeats:NO];
            }
        }
    });
}

- (void)scheduleTimeout {
    DDLogVerbose(@"%@ scheduleTimeout", LOG_TAG);

    if (self.timeoutJob) {
        return;
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        @synchronized (self) {
            if (self.notifications.count > 0) {
                NotificationServiceExtension *first = [self.notifications firstObject];

                NSDate *d = [NSDate dateWithTimeIntervalSince1970:first.deadline / 1000.0];
                self.timeoutJob = [self.jobService scheduleWithJob:self deadline:d priority:TLJobPriorityMessage];

            } else if (!self.disconnectTimer && [self activeSessionCount] == 0) {
                // We have no pending notification, there is no P2P session, make sure we disconnect the WebSocket.
                self.disconnectTimer = [NSTimer scheduledTimerWithTimeInterval:DISCONNECT_DELAY target:self selector:@selector(disconnectTimerHandler) userInfo:nil repeats:NO];
            }
        }
    });
}

- (void)processExpiredNotificationsWithDeadline:(int64_t)deadline {
    DDLogVerbose(@"%@ processExpiredNotificationsWithDeadline: %lld", LOG_TAG, deadline);

    long notificationCount;
    long expiredCount;
    @synchronized (self) {

        // Cancel the expiration job.
        if (self.timeoutJob) {
            [self.timeoutJob cancel];
            self.timeoutJob = nil;
        }

        // Identify notifications that are going to expire: they are at beginning of the notifications array.
        int originatorIndex = 0;
        for (NotificationServiceExtension *notification in self.notifications) {
            if (deadline > 0 && notification.deadline > deadline) {
                break;
            }

            // When sender names are not displayed, keep the notification anonymous.
            if (![self.notificationSettings hasDisplayNotificationSender]) {
                notification.notification.title = @"";

            } else if (self.originators.count > 0) {
                // Find either a contact or a group that can be associated with the notification (best effort).
                id<TLOriginator> originator = [self.originators objectAtIndex:originatorIndex];
                
                if (originatorIndex + 1 < self.originators.count) {
                    originatorIndex++;
                } else {
                    originatorIndex = 0;
                }
                if ([originator isGroup]) {
                    notification.groupId = [originator uuid];
                } else {
                    notification.contactId = [originator uuid];
                }
                notification.notification.title = [originator name];
            } else {
                notification.notification.title = @"";
            }

            // Add it to the expiration queue.
            [self.expiredNotifications addObject:notification];
        }

        expiredCount = self.expiredNotifications.count;
        if (expiredCount > 0) {
            [self.notifications removeObjectsInArray:self.expiredNotifications];
        }

        notificationCount = self.notifications.count;
    }

    if (deadline == 0) {
        return;
    }

    if (notificationCount == 0) {
        // Disconnect, shutdown and then call flushNotifications+flushExpiringNotifications.
        [self scheduleDisconnect];
    } else {

        // Don't wait, flush the expired notifications.
        // We still have some pending notifications: it should be safe to continue.
        if (expiredCount > 0) {
            [self flushExpiringNotifications];
        }

        [self scheduleTimeout];
    }
}

- (void)runJob {
    DDLogVerbose(@"%@ runJob", LOG_TAG);
    
    self.timeoutJob = nil;

    [self processExpiredNotificationsWithDeadline:[[NSDate date] timeIntervalSince1970] * 1000];
}

@end

//
// Implementation: NotificationServiceExtension
//

#undef LOG_TAG
#define LOG_TAG @"NotificationServiceExtension"

@implementation NotificationServiceExtension

static void darwinNotificationObserver(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    DDLogVerbose(@"%@ darwinNotificationObserver name: %@", LOG_TAG, name);

    NotificationServiceExtension *request = (__bridge NotificationServiceExtension *)observer;
    NotificationService *notificationService = [NotificationService instance];

    [request unregisterDarwinNotificationCenter];

    // Better flush what we did now since the extension is going to shutdown soon.
    [notificationService reloadBadgeNumber];
    [notificationService flushNotifications];

    // Send default content.
    [request sendDefaultNotification];
}

- (void)didReceiveNotificationRequest:(UNNotificationRequest *)request withContentHandler:(void (^)(UNNotificationContent * _Nonnull))contentHandler {
    DDLogVerbose(@"%@ didReceiveNotificationRequest request: %@", LOG_TAG, request);
    
    NotificationService *notificationService = [NotificationService instance];
    
    self.contentHandler = contentHandler;
    self.request = request;
    self.notification = [request.content mutableCopy];
    self.deadline = [[NSDate date] timeIntervalSince1970] * 1000 + NOTIFICATION_TIMEOUT;

    CFNotificationCenterAddObserver(notificationService.darwinNotificationCenter, (__bridge const void *)(self), darwinNotificationObserver, TL_NOTIFY_APP_FOREGROUND, NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
    CFNotificationCenterAddObserver(notificationService.darwinNotificationCenter, (__bridge const void *)(self), darwinNotificationObserver, TL_NOTIFY_APP_BACKGROUND, NULL, CFNotificationSuspensionBehaviorDeliverImmediately);

    CFNotificationCenterPostNotification(notificationService.darwinNotificationCenter, TL_NOTIFY_APNS, nil, nil, YES);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 100 * NSEC_PER_MSEC), dispatch_get_main_queue(), ^{
        if (self.request == request) {
            [self unregisterDarwinNotificationCenter];
            [notificationService didReceiveNotification:self];
        }
    });
}

- (void)unregisterDarwinNotificationCenter {
    DDLogVerbose(@"%@ unregisterDarwinNotificationCenter", LOG_TAG);

    NotificationService *notificationService = [NotificationService instance];
    CFNotificationCenterRemoveEveryObserver(notificationService.darwinNotificationCenter, (__bridge const void *)(self));
}

- (void)serviceExtensionTimeWillExpire {
    DDLogVerbose(@"%@ serviceExtensionTimeWillExpire", LOG_TAG);
    
    NotificationService *notificationService = [NotificationService instance];

    // Better flush what we did now since the extension is going to shutdown soon.
    [notificationService flushNotifications];

    // Send default content.
    [self sendDefaultNotification];
}

- (void)sendDefaultNotification {
    DDLogVerbose(@"%@ sendDefaultNotification", LOG_TAG);

    NotificationService *notificationService = [NotificationService instance];

    self.request = nil;
    if (self.contentHandler) {
        // If we have the com.apple.developer.usernotifications.filtering entitlement,
        // we can filter the notification to avoid the annoying message.
        // This is possible only for iOS >= 13.3 so the issue remains for iOS 13.0 up to 13.2
        if (HAVE_NOTIFICATION_FILTERING) {
            if (@available(iOS 13.3, *)) {
                self.contentHandler([[UNNotificationContent alloc] init]);
                self.notification = nil;
                return;
            }
        }

        if (notificationService.readMessageCount > 0) {
            self.notification.body = TwinmeLocalizedString(@"notification_center_message_read", nil);
        } else if (notificationService.deleteMessageCount > 0) {
            self.notification.body = TwinmeLocalizedString(@"notification_center_message_deleted", nil);
        } else if (notificationService.resetConversationCount > 0) {
            self.notification.body = TwinmeLocalizedString(@"notification_center_message_reset_conversation", nil);
        } else {
            self.notification.body = TwinmeLocalizedString(@"notification_center_message_synchronize", nil);
        }

        // Set an identifier on the notification so that we can redirect to the contact/group conversation.
        if (self.contactId) {
            self.notification.userInfo = @{@"contactId": self.contactId.UUIDString};
        } else if (self.groupId) {
            self.notification.userInfo = @{@"groupId": self.groupId.UUIDString};
        }
        self.contentHandler(self.notification);
        self.contentHandler = nil;
    }
    self.notification = nil;

    /**
     * In WWDC 17's Best Practices and What’s New in User Notifications, Teja states:
     * "     All work should be either about modifying or enhancing this notification. The service extension also doesn't have the power to drop this notification or prevent it from
     *  being displayed. This notification will get delivered to the device. If instead you want to launch your application in the background and run some additional processing,
     *  you should send a silent notification. You can also send a silent notification and launch your app in the background and your app can determine whether or not to
     *  schedule a local notification if you want to present a conditional notification."
     */
#if 0
    if (self.request) {
        UNUserNotificationCenter *userNotificationCenter = [UNUserNotificationCenter currentNotificationCenter];
        
        NSMutableArray *list = [[NSMutableArray alloc] init];
        [list addObject:self.request.identifier];
        [userNotificationCenter removeDeliveredNotificationsWithIdentifiers:list];
    }
#endif
}

@end

