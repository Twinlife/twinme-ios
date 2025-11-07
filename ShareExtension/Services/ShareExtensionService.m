/*
 *  Copyright (c) 2021-2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 *   Stephane Carrez (Stephane.Carrez@twin.life)
 */

#import <CocoaLumberjack.h>
#import <BackgroundTasks/BackgroundTasks.h>

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
#import <Twinlife/TLPeerConnectionService.h>
#import <Twinlife/TLFilter.h>

#import <Twinme/TLTwinmeAttributes.h>
#import <Twinme/TLPushNotificationContent.h>
#import <Twinme/TLNotificationCenter.h>
#import <Twinme/TLTwinmeConfiguration.h>
#import <Twinme/TLMessage.h>
#import <Twinme/TLTyping.h>
#import <Twinme/TLOriginator.h>
#import <Twinme/TLContact.h>
#import <Twinme/TLSpace.h>
#import <Twinme/TLSpaceSettings.h>
#import <Twinme/TLGroup.h>
#import <Twinme/TLGroupMember.h>
#import <Twinme/TLRoomCommand.h>
#import <Twinme/TLRoomCommandResult.h>
#import <Twinme/TLTwinmeApplication.h>
#import <Twinme/TLTwinmeContext.h>

#import "ShareExtensionService.h"

#define ALLOW_COPY_TEXT @"DefaultAllowCopyText"
#define ALLOW_COPY_FILE @"DefaultAllowCopyFile"

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static const int GET_CURRENT_SPACE = 1 << 0;
static const int GET_CURRENT_SPACE_DONE = 1 << 1;
static const int GET_CONTACTS = 1 << 2;
static const int GET_CONTACTS_DONE = 1 << 3;
static const int GET_GROUPS = 1 << 4;
static const int GET_GROUPS_DONE = 1 << 5;
static const int PUSH_OBJECT = 1 << 7;
static const int PUSH_FILE = 1 << 8;
static const int FIND_CONTACTS_AND_GROUPS = 1 << 9;
static const int FIND_CONTACTS_AND_GROUPS_DONE = 1 << 10;

static NSString *APPLICATION_NAME = @"twinme";
static NSString *APPLICATION_SCHEME = @"twinme";

#define CONVERSATION_ACTION [NSString stringWithFormat:@"conversation.%@",[TLTwinlife TWINLIFE_DOMAIN]]

//
// Interface: Configuration
//

@interface Configuration : TLTwinmeConfiguration

@end

@implementation Configuration

- (instancetype)init {
    
    self = [super initWithName:APPLICATION_NAME applicationVersion:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"] serializers:@[[[TLMessageSerializer alloc] init], [[TLTypingSerializer alloc] init], [[TLRoomCommandSerializer alloc] init], [[TLRoomCommandResultSerializer alloc] init]] enableKeepAlive:NO enableSetup:NO enableCaches:NO enableReports:NO enableInvocations:NO enableSpaces:NO refreshBadgeDelay:-1.0];
    
    if (self) {
        // Disable the account service to prevent any connection to the server.
        self.accountServiceConfiguration.serviceOn = false;
        self.accountServiceConfiguration.defaultAuthenticationAuthority = TLAccountServiceAuthenticationAuthorityUnregistered;
        self.conversationServiceConfiguration.serviceOn = true;
        self.conversationServiceConfiguration.enableScheduler = false;
        self.conversationServiceConfiguration.lockIdentifier = 3;

        // Disable the connectivity service to prevent any connection to the server.
        self.connectivityServiceConfiguration.serviceOn = false;
        self.notificationServiceConfiguration.serviceOn = false;
        // Disable the management service.
        self.managementServiceConfiguration.saveEnvironment = false;
        self.managementServiceConfiguration.serviceOn = false;
        // Disable the P2P service.
        self.peerConnectionServiceConfiguration.serviceOn = false;
        self.peerConnectionServiceConfiguration.acceptIncomingCalls = false;
        // Disable Audio and Video.
        self.peerConnectionServiceConfiguration.enableAudioVideo = false;
        self.repositoryServiceConfiguration.serviceOn = true;
        self.twincodeFactoryServiceConfiguration.serviceOn = true;
        self.twincodeInboundServiceConfiguration.serviceOn = true;
        self.twincodeOutboundServiceConfiguration.serviceOn = true;
        self.imageServiceConfiguration.serviceOn = true;
    }
    return self;
}

@end

@class ShareServiceConversationServiceDelegate;

//
// Interface: ShareExtensionService
//

@interface ShareExtensionService()<TLNotificationCenter>

@property (nonatomic, readonly, nonnull) TLTwinmeContext *twinmeContext;
@property (nonatomic, readonly, nonnull) ShareServiceConversationServiceDelegate *shareServiceConversationServiceDelegate;
@property BOOL initialized;
@property BOOL isReady;
@property BOOL needSchedule;
@property (nonatomic) int state;
@property (nonatomic) int work;
@property (nonatomic, readonly, nonnull) NSMutableDictionary *requestIds;

@property (nonatomic, nullable) NSString *findName;
@property (nonatomic, nullable) id<TLConversation> conversation;

@property (nonatomic, nullable) TLSpace *space;

/// Initialize the first instance.
- (nonnull instancetype)init;

/// First callback invoked to setup the NotificationService.
- (void)onTwinlifeReady;

/// Finish and get the operation associated with the given requestId or returns nil if the request was not made by the service.
- (nullable NSNumber *)getOperation:(int64_t)requestId;

- (void)onGetOrCreateConversation:(nonnull id <TLConversation>)conversation;

- (void)onPushDescriptor:(nullable TLDescriptor *)descriptor;

- (void)onOperation;

@end

//
// Interface: ShareServiceConversationServiceDelegate
//

@interface ShareServiceConversationServiceDelegate:NSObject <TLConversationServiceDelegate>

@property (weak) ShareExtensionService *service;

- (nonnull nonnull instancetype)initWithService:(nonnull ShareExtensionService *)service;

@end

//
// Implementation: ShareServiceConversationServiceDelegate
//

#undef LOG_TAG
#define LOG_TAG @"ShareServiceConversationServiceDelegate"

@implementation ShareServiceConversationServiceDelegate

- (nonnull instancetype)initWithService:(nonnull ShareExtensionService *)service {
    DDLogVerbose(@"%@ initWithService: %@", LOG_TAG, service);
    
    self = [super init];
    
    if (self) {
        _service = service;
    }
    return self;
}

- (void)onGetOrCreateConversationWithRequestId:(int64_t)requestId conversation:(id <TLConversation>)conversation {
    DDLogVerbose(@"%@ onGetOrCreateConversationWithRequestId: %lld conversation: %@", LOG_TAG, requestId, conversation);

    NSNumber *operationId = [self.service getOperation:requestId];
    if (operationId == nil) {
        return;
    }
    
    [self.service onGetOrCreateConversation:conversation];
}

- (void)onPushDescriptorRequestId:(int64_t)requestId conversation:(id<TLConversation>)conversation descriptor:(TLDescriptor *)descriptor {
    DDLogVerbose(@"%@ onPushDescriptorRequestId: %lld conversation: %@ objectDescriptor: %@", LOG_TAG, requestId, conversation, descriptor);

    NSNumber *operationId = [self.service getOperation:requestId];
    if (operationId == nil) {
        return;
    }
    
    [self.service onPushDescriptor:descriptor];
}

- (void)onErrorWithRequestId:(int64_t)requestId errorCode:(TLBaseServiceErrorCode)errorCode errorParameter:(nullable NSString *)errorParameter {
    DDLogVerbose(@"%@ onErrorWithRequestId: %lld errorCode: %u errorParameter: %@", LOG_TAG, requestId, errorCode, errorParameter);

    NSNumber *operationId = [self.service getOperation:requestId];
    if (operationId == nil) {
        return;
    }
    
    if (operationId.intValue == PUSH_OBJECT || operationId.intValue == PUSH_FILE) {
        [self.service onPushDescriptor:nil];
    }
}

@end

#undef LOG_TAG
#define LOG_TAG @"ShareExtensionService"

@implementation ShareExtensionService

static ShareExtensionService *INSTANCE;

+ (void)initialize {
    
    // Create the main instance and do the Twinlife, TwinmeContext and WebRTC setup.
    INSTANCE = [[ShareExtensionService alloc] init];
}

+ (nonnull ShareExtensionService *)instance {
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
        _isReady = NO;
        _needSchedule = NO;
        _state = 0;
        _requestIds = [NSMutableDictionary dictionary];
        _shareServiceConversationServiceDelegate = [[ShareServiceConversationServiceDelegate alloc] initWithService:self];
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

- (void)start {
    DDLogVerbose(@"%@ start", LOG_TAG);
    
    @synchronized (self) {
        if (!self.initialized) {
            [self.twinmeContext addDelegate:self];
            self.initialized = YES;
        }
    }
    
    // Get the default application settings each time we are started because the application
    // could have changed them.
    BOOL allowCopyText;
    NSUserDefaults *userDefaults = [TLTwinlife getAppSharedUserDefaults];
    id object = [userDefaults objectForKey:ALLOW_COPY_TEXT];
    if (object) {
        allowCopyText = [object boolValue];
    } else {
        allowCopyText = YES;
    }
    
    BOOL allowCopyFile;
    object = [userDefaults objectForKey:ALLOW_COPY_FILE];
    if (object) {
        allowCopyFile = [object boolValue];
    } else {
        allowCopyFile = YES;
    }
    
    TLSpaceSettings *settings = [[TLSpaceSettings alloc] initWithName:@"unused" settings:nil];
    settings.messageCopyAllowed = allowCopyText;
    settings.fileCopyAllowed = allowCopyFile;
    [_twinmeContext setDefaultSpaceSettings:settings oldDefaultName:@"unused"];

    // Start Twinlife to reopen the database (the OpenFire connection is disabled: we won't connect!).
    [self.twinmeContext start];
    [self.twinmeContext applicationDidBecomeActive:nil];
}

- (void)stopWithCompletionHandler:(nonnull void (^)(TLBaseServiceErrorCode status))completionHandler {
    DDLogVerbose(@"%@ stop", LOG_TAG);
    
    if (self.needSchedule) {
        self.needSchedule = NO;
        if (@available(iOS 13.0, *)) {
            NSError *error = NULL;
            BGAppRefreshTaskRequest *request = [[BGAppRefreshTaskRequest alloc] initWithIdentifier:SCHEDULER_TASK_NAME];
            request.earliestBeginDate = [[NSDate alloc] initWithTimeIntervalSinceNow:10.0];
            [[BGTaskScheduler sharedScheduler] submitTaskRequest:request error:&error];
            DDLogVerbose(@"%@ stop task scheduled at %@ error: %@", LOG_TAG, request.earliestBeginDate, error);
        }
    }

    // Clear memory before suspending.
    self.conversation = nil;
    self.space = nil;
    self.state = 0;

    if (self.initialized) {
        [self.twinmeContext removeDelegate:self];
        [self.twinmeContext stopWithCompletionHandler:completionHandler];

        self.initialized = NO;
    } else {
        completionHandler(TLBaseServiceErrorCodeSuccess);
    }
}

- (void)onTwinlifeReady {
    DDLogVerbose(@"%@ onTwinlifeReady", LOG_TAG);
    
    @synchronized (self) {
        if (!self.isReady) {
            self.isReady = YES;
            [[self.twinmeContext getConversationService] addDelegate:self.shareServiceConversationServiceDelegate];
        }
        
        [self getContactsAndGroups];
    }
}

- (void)onIncomingCallWithContact:(id<TLOriginator>)contact peerConnectionId:(NSUUID *)peerConnectionId offer:(TLOffer *)offer {
    
}

- (void)onIncomingMigrationWithAccountMigration:(nonnull TLAccountMigration *)accountMigration peerConnectionId:(nonnull NSUUID *)peerConnectionId {

}

- (void)onJoinGroupWithGroup:(id<TLOriginator>)group conversationId:(NSUUID *)conversationId {
    
}

- (void)onNewContactWithContact:(id<TLOriginator>)contact {
    
}

- (void)onPopDescriptorWithContact:(id<TLOriginator>)contact conversationId:(NSUUID *)conversationId descriptor:(TLDescriptor *)descriptor {
    
}

- (void)onSetActiveConversationWithConversationId:(NSUUID *)conversationId {
    
}

- (void)onUnbindContactWithContact:(id<TLOriginator>)contact {
    
}

- (void)onUpdateContactWithContact:(id<TLOriginator>)contact updatedAttributes:(nonnull NSArray<TLAttributeNameValue *> *)updatedAttributes {
    
}

- (void)onUpdateDescriptorWithContact:(id<TLOriginator>)contact conversationId:(NSUUID *)conversationId descriptor:(TLDescriptor *)descriptor updateType:(TLConversationServiceUpdateType)updateType {
    
}

- (void)onUpdateAnnotationWithContact:(id<TLOriginator>)contact conversationId:(NSUUID *)conversationId descriptor:(TLDescriptor *)descriptor annotatingUser:(nonnull TLTwincodeOutbound *)annotatingUser {
    
}

- (void)updateApplicationBadgeNumber:(NSInteger)applicationBadgeNumber {
    
}

- (void)cancelWithNotificationId:(nonnull NSUUID *)notificationId {
    DDLogVerbose(@"%@ cancelWithNotificationId: %@", LOG_TAG, notificationId);

    // Do nothing because this should never be called for the share extension since it does not connect.
}

- (void)onGetOrCreateConversation:(nonnull id <TLConversation>)conversation {
    DDLogVerbose(@"%@ onGetOrCreateConversation: %@", LOG_TAG, conversation);

    if (!conversation.contactId) {
        return;
    }
    
    self.conversation = conversation;
    dispatch_async(dispatch_get_main_queue(), ^{
        [(id<ShareExtensionServiceDelegate>)self.shareExtensionServiceDelegate onGetConversation:conversation];
    });
}

- (BOOL)hasPendingRequests {
    
    @synchronized (self) {
        return self.requestIds.count > 0;
    }
}

- (void)onPushDescriptor:(nullable TLDescriptor *)descriptor {
    DDLogVerbose(@"%@ onPushDescriptor: descriptor: %@", LOG_TAG, descriptor);

    self.needSchedule = YES;
    if (![self hasPendingRequests]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            // Check again from the main UI thread that we have no pending push request.
            // It is critical that `onShareCompleted` is called only when every pushFile(), pushMessage()
            // has been completed.
            if (![self hasPendingRequests]) {
                DDLogInfo(@"%@ every pushFile is now completed, notify the view", LOG_TAG);
                [(id<ShareExtensionServiceDelegate>)self.shareExtensionServiceDelegate onShareCompleted];
            }
        });
    }
}

- (nonnull TLSpaceSettings *)getDefaultSpaceSettings {
    
    return self.twinmeContext.defaultSpaceSettings;
}

- (void)getImageWithContact:(nonnull id<TLOriginator>)originator withBlock:(nonnull void (^)(UIImage *_Nonnull image))block {
    DDLogVerbose(@"%@ getImageWithContact: %@", LOG_TAG, originator);

    if (!originator.avatarId) {
        block([TLTwinmeAttributes DEFAULT_AVATAR]);
        return;
    }
    dispatch_async([self.twinmeContext.twinlife twinlifeQueue], ^{
        TLImageService *imageService = [self.twinmeContext getImageService];
        UIImage *image = [imageService getCachedImageWithImageId:originator.avatarId kind:TLImageServiceKindThumbnail];
        if (image != nil) {
            block(image);
            return;
        }
        
        [imageService getImageWithImageId:originator.avatarId kind:TLImageServiceKindThumbnail withBlock:^(TLBaseServiceErrorCode status, UIImage *image) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (status == TLBaseServiceErrorCodeSuccess && image) {
                    block(image);
                } else {
                    block([TLTwinmeAttributes DEFAULT_AVATAR]);
                }
            });
        }];
    });
}

- (void)getImageWithImageId:(nullable TLImageId *)imageId defaultImage:(nonnull UIImage *)defaultImage withBlock:(nonnull void (^)(UIImage *_Nonnull image))block {
    DDLogVerbose(@"%@ getImageWithImageId: %@", LOG_TAG, imageId);

    if (!imageId) {
        block(defaultImage);
        return;
    }

    dispatch_async([self.twinmeContext.twinlife twinlifeQueue], ^{
        TLImageService *imageService = [self.twinmeContext getImageService];
        UIImage *image = [imageService getCachedImageWithImageId:imageId kind:TLImageServiceKindThumbnail];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!image) {
                block(defaultImage);
            } else {
                block(image);
            }
        });
    });
}

- (void)getImageWithGroup:(nonnull TLGroup *)group withBlock:(nonnull void (^)(UIImage *_Nonnull image))block {
    DDLogVerbose(@"%@ getImageWithGroup: %@", LOG_TAG, group);
    
    [self getImageWithImageId:group.groupAvatarId defaultImage:[TLTwinmeAttributes DEFAULT_GROUP_AVATAR] withBlock:block];
}

- (void)getImageWithSpace:(nonnull TLSpace *)space withBlock:(nonnull void (^)(UIImage *_Nonnull image))block {
    DDLogVerbose(@"%@ getImageWithSpace: %@", LOG_TAG, space);
    
    dispatch_async([self.twinmeContext.twinlife twinlifeQueue], ^{
        NSUUID *imageId = space.avatarId;
        if (imageId) {
            TLImageService *imageService = [self.twinmeContext getImageService];
            TLExportedImageId *exportedImageId = [imageService imageWithPublicId:imageId];
            if (exportedImageId) {
                UIImage *image = [imageService getCachedImageWithImageId:exportedImageId kind:TLImageServiceKindThumbnail];
                if (image) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        block(image);
                    });
                    return;
                }
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            block([TLTwinmeAttributes DEFAULT_AVATAR]);
        });
    });
}

- (nonnull NSURL *)getConversationURLWithOriginator:(nonnull id<TLOriginator>)originator {
    DDLogVerbose(@"%@ getConversationURLWithOriginator: %@", LOG_TAG, originator);

    NSString *url;
    if (originator.isGroup) {
        url = [NSString stringWithFormat:@"%@://%@?group=%@", APPLICATION_SCHEME, CONVERSATION_ACTION, originator.uuid.UUIDString];
    } else {
        url = [NSString stringWithFormat:@"%@://%@?contact=%@", APPLICATION_SCHEME, CONVERSATION_ACTION, originator.uuid.UUIDString];
    }

    return [[NSURL alloc] initWithString:url];
}

- (void)getConversationWithContact:(nonnull TLContact *)contact {
    DDLogVerbose(@"%@ getConversationWithContact: %@", LOG_TAG, contact);
    
    id<TLConversation> conversation = [[self.twinmeContext getConversationService] getOrCreateConversationWithSubject:contact create:YES];
    [self onGetOrCreateConversation:conversation];
}

- (void)getConversationWithGroup:(nonnull TLGroup *)group {
    DDLogVerbose(@"%@ getConversationWithGroup: %@", LOG_TAG, group);
    
    id<TLConversation> conversation = [[self.twinmeContext getConversationService] getConversationWithSubject:group];
    if (conversation) {
        self.conversation = conversation;
        [(id<ShareExtensionServiceDelegate>)self.shareExtensionServiceDelegate onGetConversation:conversation];
    }
}

- (BOOL)hasConversationActive:(nonnull id<TLRepositoryObject>)subject {
    DDLogVerbose(@"%@ hasConversationActive: %@", LOG_TAG, subject);
    
    id<TLConversation> conversation = [[self.twinmeContext getConversationService] getConversationWithSubject:subject];
    return conversation && [conversation isActive];
}

- (void)pushMessage:(nonnull NSString *)message copyAllowed:(BOOL)copyAllowed {
    DDLogVerbose(@"%@ pushMessage: %@ copyAllowed: %d", LOG_TAG, message, copyAllowed);
    
    int64_t requestId = [self newOperation:PUSH_OBJECT];
    [self.twinmeContext pushObjectWithRequestId:requestId conversation:self.conversation sendTo:nil replyTo:nil message:message copyAllowed:copyAllowed expireTimeout:0];
}

- (void)pushFileWithPath:(nonnull NSString *)path type:(TLDescriptorType)type toBeDeleted:(BOOL)toBeDeleted copyAllowed:(BOOL)copyAllowed {
    DDLogVerbose(@"%@ pushFileWithPath: %@ type: %d toBeDeleted: %d copyAllowed: %d", LOG_TAG, path, type, toBeDeleted, copyAllowed);
    
    int64_t requestId = [self newOperation:PUSH_FILE];
    [self.twinmeContext pushFileWithRequestId:requestId conversation:self.conversation sendTo:nil replyTo:nil path:path type:type toBeDeleted:toBeDeleted copyAllowed:copyAllowed expireTimeout:0];
}

- (void)findContactsAndGroupsByName:(nonnull NSString *)name {
    DDLogVerbose(@"%@ findContactsAndGroupsByName: %@", LOG_TAG, name);
    
    self.findName = [name.lowercaseString stringByFoldingWithOptions:NSDiacriticInsensitiveSearch locale:[NSLocale currentLocale]];
    self.work = FIND_CONTACTS_AND_GROUPS;
    self.state &= ~(FIND_CONTACTS_AND_GROUPS | FIND_CONTACTS_AND_GROUPS_DONE);
    [self onOperation];
}

- (void)getContactsAndGroups {
    DDLogVerbose(@"%@ getContactsAndGroups", LOG_TAG);
    
    self.state &= ~(GET_CONTACTS | GET_CONTACTS_DONE);
    self.state &= ~(GET_GROUPS | GET_GROUPS_DONE);
    [self onOperation];
}

- (int64_t)newOperation:(int) operationId {
    DDLogVerbose(@"%@ newOperation: %d", LOG_TAG, operationId);
    
    int64_t requestId = [self.twinmeContext newRequestId];
    @synchronized (self.requestIds) {
        self.requestIds[[NSNumber numberWithLongLong:requestId]] = [NSNumber numberWithInt:operationId];
    }
    return requestId;
}

- (nullable NSNumber *)getOperation:(int64_t)requestId {
    DDLogVerbose(@"%@ getOperation: %lld", LOG_TAG, requestId);
    
    NSNumber *operationId;
    NSNumber *lRequestId = [NSNumber numberWithLongLong:requestId];
    @synchronized(self.requestIds) {
        operationId = self.requestIds[lRequestId];
        if (operationId != nil) {
            [self.requestIds removeObjectForKey:lRequestId];
        }
    }
    return operationId;
}

- (void)finishOperation:(int64_t)requestId {
    DDLogVerbose(@"%@ finishOperation: %lld", LOG_TAG, requestId);
    
    NSNumber *lRequestId = [NSNumber numberWithLongLong:requestId];
    @synchronized(self.requestIds) {
        [self.requestIds removeObjectForKey:lRequestId];
    }
}

- (void)onOperation {
    DDLogVerbose(@"%@ onOperation", LOG_TAG);
    
    if (!self.isReady) {
        return;
    }
    
    //
    // Step 1: get the current space.
    //
    if ((self.state & GET_CURRENT_SPACE) == 0) {
        self.state |= GET_CURRENT_SPACE;
        
        [self.twinmeContext getCurrentSpaceWithBlock:^(TLBaseServiceErrorCode errorCode, TLSpace *space) {
            
            self.state |= GET_CURRENT_SPACE_DONE;
            self.space = space;
            dispatch_async(dispatch_get_main_queue(), ^{
                self.state |= GET_CURRENT_SPACE_DONE;
                self.space = space;
                [self onOperation];
            });
            [self onOperation];
        }];
        return;
    }
    if ((self.state & GET_CURRENT_SPACE_DONE) == 0) {
        return;
    }
    
    //
    // Step 2: We must get the list of contacts for the space.
    //
    if ((self.state & GET_CONTACTS) == 0) {
        self.state |= GET_CONTACTS;

        TLFilter *filter = [self.twinmeContext createSpaceFilter];
        filter.acceptWithObject = ^BOOL(id<TLDatabaseObject> object) {
            TLContact *contact = (TLContact *)object;
            
            return [contact hasPeer];
        };

        DDLogVerbose(@"%@ findContactsWithFilter: %@", LOG_TAG, filter);
        [self.twinmeContext findContactsWithFilter:filter withBlock:^(NSMutableArray<TLContact *> *contacts) {
            self.state |= GET_CONTACTS_DONE;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.shareExtensionServiceDelegate onGetContacts:contacts];
            });
            [self onOperation];
        }];
        return;
    }
    if ((self.state & GET_CONTACTS_DONE) == 0) {
        return;
    }
    
    //
    // Step 3: get the list of groups before the conversations.
    //
    if ((self.state & GET_GROUPS) == 0) {
        self.state |= GET_GROUPS;

        [self.twinmeContext findGroupsWithFilter:[self.twinmeContext createSpaceFilter] withBlock:^(NSMutableArray<TLGroup *> *groups) {
            self.state |= GET_GROUPS_DONE;
            dispatch_async(dispatch_get_main_queue(), ^{
                [(id<ShareExtensionServiceDelegate>)self.shareExtensionServiceDelegate onGetGroups:groups];
            });
            [self onOperation];
        }];
        return;
    }
    if ((self.state & GET_GROUPS_DONE) == 0) {
        return;
    }

    //
    // We must search for a contact and group with some name.
    //
    if ((self.work & FIND_CONTACTS_AND_GROUPS) != 0) {
        if ((self.state & FIND_CONTACTS_AND_GROUPS) == 0) {
            self.state |= FIND_CONTACTS_AND_GROUPS;
            
            TLFilter *contactFilter = [self.twinmeContext createSpaceFilter];
            contactFilter.acceptWithObject = ^BOOL(id<TLDatabaseObject> object) {
                TLContact *contact = (TLContact *)object;
                NSString *contactName = [contact.name stringByFoldingWithOptions:NSDiacriticInsensitiveSearch locale:[NSLocale currentLocale]];
                return [contact hasPeer] && [contact.space.uuid isEqual:self.space.uuid] && [contactName.lowercaseString containsString:self.findName];
            };
           
            [self.twinmeContext findContactsWithFilter:contactFilter withBlock:^(NSMutableArray<TLContact *> *contacts) {
                self.state |= FIND_CONTACTS_AND_GROUPS_DONE;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [(id<ShareExtensionServiceDelegate>)self.shareExtensionServiceDelegate onGetContacts:contacts];
                });
                [self onOperation];
            }];

            TLFilter *groupFilter = [self.twinmeContext createSpaceFilter];
            groupFilter.acceptWithObject = ^BOOL(id<TLDatabaseObject> object) {
                TLGroup *group = (TLGroup *)object;
                NSString *groupName = [group.name stringByFoldingWithOptions:NSDiacriticInsensitiveSearch locale:[NSLocale currentLocale]];
                return [group.space.uuid isEqual:self.space.uuid] && [groupName.lowercaseString containsString:self.findName];
            };
            [self.twinmeContext findGroupsWithFilter:groupFilter withBlock:^(NSMutableArray<TLGroup *> *groups) {
                self.state |= FIND_CONTACTS_AND_GROUPS_DONE;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [(id<ShareExtensionServiceDelegate>)self.shareExtensionServiceDelegate onGetGroups:groups];
                });
                [self onOperation];
            }];
            return;
        }
        if ((self.state & FIND_CONTACTS_AND_GROUPS_DONE) == 0) {
            return;
        }
    }
}

@end
