/*
 *  Copyright (c) 2017-2024 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Christian Jacquemot (Christian.Jacquemot@twinlife-systems.com)
 *   Stephane Carrez (Stephane.Carrez@twin.life)
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <Twinlife/TLTwinlife.h>
#import <Twinlife/TLAccountService.h>
#import <Twinlife/TLFilter.h>
#import <Twinlife/TLTwincodeOutboundService.h>

#import <Twinme/TLTwinmeContext.h>
#import <Twinme/TLGroupMember.h>
#import <Twinme/TLSpace.h>
#import <Twinme/TLContact.h>
#import <Twinme/TLGroup.h>
#import <Twinme/TLCallReceiver.h>

#import "MainService.h"
#import <TwinmeCommon/AbstractTwinmeService+Protected.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static const int GET_CURRENT_SPACE = 1 << 0;
static const int GET_CURRENT_SPACE_DONE = 1 << 1;
static const int GET_SPACES = 1 << 2;
static const int GET_SPACES_DONE = 1 << 3;
static const int SUBSCRIBE_FEATURE = 1 << 4;
static const int SUBSCRIBE_FEATURE_DONE = 1 << 5;
static const int GET_CONTACTS = 1 << 6;
static const int GET_CONTACTS_DONE = 1 << 7;
static const int GET_PENDING_NOTIFICATIONS = 1 << 10;
static const int GET_PENDING_NOTIFICATIONS_DONE = 1 << 11;
static const int SET_CURRENT_SPACE = 1 << 17;
static const int SET_CURRENT_SPACE_DONE = 1 << 18;
static const int GET_CONVERSATIONS = 1 << 19;
static const int GET_CONVERSATIONS_DONE = 1 << 20;
static const int GET_SPACE_NOTIFICATIONS = 1 << 21;
static const int GET_SPACE_NOTIFICATIONS_DONE = 1 << 22;
static const int GET_TRANSFER_CALL = 1 << 12;
static const int GET_TRANSFER_CALL_DONE = 1 << 13;
static const int SET_LEVEL = 1 << 23;
static const int CREATE_LEVEL = 1 << 24;
static const int DELETE_LEVEL = 1 << 25;

//
// Interface: MainService ()
//

@class MainServiceTwinmeContextDelegate;
@class MainServiceAccountServiceDelegate;

@interface MainService ()

@property (nonatomic) int work;
@property (nonatomic, nullable) TLSpace *space;

@property (nonatomic, nonnull) NSString *productId;
@property (nonatomic, nonnull) NSString *purchaseToken;
@property (nonatomic, nonnull) NSString *purchaseOrderId;

@property (nonatomic) MainServiceAccountServiceDelegate *accountServiceDelegate;

- (void)onOperation;

- (void)onSetCurrentSpace:(nonnull TLSpace *)space;

- (void)onCreateSpace:(nonnull TLSpace *)space;

- (void)onUpdateSpace:(TLSpace *)space;

- (void)onDeleteSpace:(nonnull NSUUID *)spaceId;

- (void)onCreateProfile:(nonnull TLProfile *)profile;

- (void)onUpdateProfile:(TLProfile *)profile;

- (void)onCreateCallReceiver:(nonnull TLCallReceiver *)callReceiver;

- (void)onUpdateCallReceiver:(TLCallReceiver *)callReceiver;

- (void)onDeleteCallReceiver:(nonnull NSUUID *)callReceiverId;

- (void)onUpdatePendingNotifications:(BOOL)hasPendingNotifications;

- (void)onGetConversations:(BOOL)hasConversations;

- (void)onSubscribeUpdate:(TLBaseServiceErrorCode)errorCode;

- (void)onErrorWithOperationId:(int)operationId errorCode:(TLBaseServiceErrorCode)errorCode errorParameter:(NSString *)errorParameter;

- (void)onFatalErrorWithErrorCode:(TLBaseServiceErrorCode)errorCode databaseError:(NSError *)databaseError;

- (void)onOpenURL:(NSURL *)url;

@end

//
// Interface: MainServiceTwinmeContextDelegate
//

@interface MainServiceTwinmeContextDelegate : AbstractTwinmeContextDelegate

- (nonnull instancetype)initWithService:(nonnull MainService *)service;

@end

//
// Implementation: MainServiceTwinmeContextDelegate
//

#undef LOG_TAG
#define LOG_TAG @"MainServiceTwinmeContextDelegate"

@implementation MainServiceTwinmeContextDelegate

- (nonnull instancetype)initWithService:(nonnull MainService *)service {
    DDLogVerbose(@"%@ initWithService: %@", LOG_TAG, service);
    
    self = [super initWithService:service];
    return self;
}

- (void)onCreateProfileWithRequestId:(int64_t)requestId profile:(nonnull TLProfile *)profile {
    DDLogVerbose(@"%@ onCreateProfileWithRequestId: %lld profile: %@", LOG_TAG, requestId, profile);
    
    [(MainService *)self.service onCreateProfile:profile];
}

- (void)onUpdateProfileWithRequestId:(int64_t)requestId profile:(nonnull TLProfile *)profile {
    DDLogVerbose(@"%@ onUpdateProfileWithRequestId: %lld profile: %@", LOG_TAG, requestId, profile);
    
    [(MainService *)self.service onUpdateProfile:profile];
}

- (void)onSetCurrentSpaceWithRequestId:(int64_t)requestId space:(TLSpace *)space {
    DDLogVerbose(@"%@ onSetCurrentSpaceWithRequestId: %lld space: %@", LOG_TAG, requestId, space);

    // Could be a SET_LEVEL or CREATE_LEVEL operation.
    [self.service finishOperation:requestId];
    
    [(MainService *)self.service onSetCurrentSpace:space];
}

- (void)onCreateSpaceWithRequestId:(int64_t)requestId space:(TLSpace *)space {
    DDLogVerbose(@"%@ onCreateSpaceWithRequestId: %lld space: %@", LOG_TAG, requestId, space);

    // Could be a CREATE_LEVEL operation.
    [self.service finishOperation:requestId];
    
    [(MainService *)self.service onCreateSpace:space];
}

- (void)onUpdateSpaceWithRequestId:(int64_t)requestId space:(TLSpace *)space {
    DDLogVerbose(@"%@ onUpdateSpaceWithRequestId: %lld space: %@", LOG_TAG, requestId, space);
    
    [(MainService *)self.service onUpdateSpace:space];
}

- (void)onDeleteSpaceWithRequestId:(int64_t)requestId spaceId:(NSUUID *)spaceId {
    DDLogVerbose(@"%@ onDeleteSpaceWithRequestId: %lld spaceId: %@", LOG_TAG, requestId, spaceId);
    
    [(MainService *)self.service onDeleteSpace:spaceId];
}

- (void)onUpdatePendingNotificationsWithRequestId:(int64_t)requestId hasPendingNotifications:(BOOL)hasPendingNotifications {
    DDLogVerbose(@"%@ onUpdatePendingNotificationsWithRequestId: %lld hasPendingNotifications: %@", LOG_TAG, requestId, hasPendingNotifications ? @"YES" : @"NO");
    
    [(MainService *)self.service onUpdatePendingNotifications:hasPendingNotifications];
}

- (void)onCreateCallReceiverWithRequestId:(int64_t)requestId callReceiver:(TLCallReceiver *)callReceiver {
    DDLogVerbose(@"%@ onCreateCallReceiverWithRequestId: %lld callReceiver: %@", LOG_TAG, requestId, callReceiver);

    [(MainService *) self.service onCreateCallReceiver:callReceiver];
}

- (void)onUpdateCallReceiverWithRequestId:(int64_t)requestId callReceiver:(TLCallReceiver *)callReceiver {
    DDLogVerbose(@"%@ onUpdateCallReceiverWithRequestId: %lld callReceiver: %@", LOG_TAG, requestId, callReceiver);

    [(MainService *) self.service onUpdateCallReceiver:callReceiver];
}

- (void)onDeleteCallReceiverWithRequestId:(int64_t)requestId callReceiverId:(NSUUID *)callReceiverId {
    DDLogVerbose(@"%@ onDeleteCallReceiverWithRequestId: %lld callReceiverId: %@", LOG_TAG, requestId, callReceiverId);

    [(MainService *) self.service onDeleteCallReceiver:callReceiverId];
}

- (void)onErrorWithRequestId:(int64_t)requestId errorCode:(TLBaseServiceErrorCode)errorcode errorParameter:(NSString *)errorParameter {
    
    int operationId = [self.service getOperation:requestId];
    if (!operationId) {
        return;
    }
    
    [self.service onErrorWithOperationId:operationId errorCode:errorcode errorParameter:errorParameter];
    [self.service onOperation];
}

- (void)onFatalErrorWithErrorCode:(TLBaseServiceErrorCode)errorCode databaseError:(NSError *)databaseError {
    DDLogVerbose(@"%@ onFatalErrorWithErrorCode: %d databaseError: %@", LOG_TAG, errorCode, databaseError);
    
    [(MainService *)self.service onFatalErrorWithErrorCode:errorCode databaseError:databaseError];
}

- (void)onOpenURL:(NSURL *)url {
    DDLogVerbose(@"%@ onOpenURL: %@", LOG_TAG, url);
    
    [(MainService *)self.service onOpenURL:url];
}

@end

//
// Interface: MainServiceAccountServiceDelegate
//

@interface MainServiceAccountServiceDelegate : NSObject <TLAccountServiceDelegate>

@property (weak) MainService *service;

- (instancetype)initWithService:(MainService *)service;

@end

//
// Implementation: MainServiceAccountServiceDelegates
//

#undef LOG_TAG
#define LOG_TAG @"MainServiceAccountServiceDelegate"

@implementation MainServiceAccountServiceDelegate

- (instancetype)initWithService:(MainService *)service {
    DDLogVerbose(@"%@ initWithService: %@", LOG_TAG, service);
    
    self = [super init];
    
    if (self) {
        _service = service;
    }
    return self;
}

- (void)onSubscribeUpdateWithRequestId:(int64_t)requestId errorCode:(TLBaseServiceErrorCode)errorCode {
    DDLogVerbose(@"%@ onSubscribeUpdateWithRequestId: %lld  errorCode: %d", LOG_TAG, requestId, errorCode);
    
    int operationId = [self.service getOperation:requestId];
    if (!operationId) {
        return;
    }
    
    [self.service onSubscribeUpdate:errorCode];
}

@end


//
// Implementation: MainService
//

#undef LOG_TAG
#define LOG_TAG @"MainService"

@implementation MainService

- (instancetype)initWithTwinmeContext:(TLTwinmeContext *)twinmeContext delegate:(id<MainServiceDelegate>)delegate {
    DDLogVerbose(@"%@ initWithTwinmeContext: %@ delegate: %@", LOG_TAG, twinmeContext, delegate);
    
    self = [super initWithTwinmeContext:twinmeContext tag:LOG_TAG delegate:delegate];
    
    if (self) {
        self.twinmeContextDelegate = [[MainServiceTwinmeContextDelegate alloc] initWithService:self];
        [self.twinmeContext addDelegate:self.twinmeContextDelegate];
    }
    return self;
}

- (void)setCurrentSpace:(nonnull TLSpace *)space {
    DDLogVerbose(@"%@ setSpace: %@", LOG_TAG, space);
    
    [self showProgressIndicator];
    int64_t requestId = [self newOperation:SET_CURRENT_SPACE];
    [self.twinmeContext setCurrentSpaceWithRequestId:requestId space:space];
    
    if (!space.settings.isSecret) {
        [self.twinmeContext setDefaultSpace:space];
    }
}

- (void)getSpaces {
    DDLogVerbose(@"%@ getSpaces", LOG_TAG);
    
    self.state &= ~(GET_SPACES | GET_SPACES_DONE);
    [self startOperation];
}

- (void)getConversations {
    DDLogVerbose(@"%@ getConversations", LOG_TAG);
    
    self.state &= ~(GET_CONVERSATIONS | GET_CONVERSATIONS_DONE);
    [self startOperation];
}

- (void)getContacts {
    DDLogVerbose(@"%@ getContacts", LOG_TAG);
    
    self.state &= ~(GET_CONTACTS | GET_CONTACTS_DONE);
    [self startOperation];
}

- (void)parseUriWithUri:(nonnull NSURL *)uri withBlock:(nonnull void (^)(TLBaseServiceErrorCode errorCode, TLTwincodeURI *_Nullable twincodeUri))block {
    DDLogVerbose(@"%@ parseUriWithUri: %@", LOG_TAG, uri);
    
    dispatch_async(self.twinmeContext.twinlife.twinlifeQueue, ^{
        [[self.twinmeContext getTwincodeOutboundService] parseUriWithUri:uri withBlock:^(TLBaseServiceErrorCode errorCode, TLTwincodeURI *uri) {
            dispatch_async(dispatch_get_main_queue(), ^{
                block(errorCode, uri);
            });
        }];
    });
}

- (void)verifyAuthenticateWithURI:(nonnull NSURL *)uri withBlock:(nonnull void (^)(TLBaseServiceErrorCode errorCode, TLContact *_Nullable contact))block {
    DDLogVerbose(@"%@ verifyAuthenticateWithURI: %@", LOG_TAG, uri);

    [self parseUriWithUri:uri withBlock:^(TLBaseServiceErrorCode errorCode, TLTwincodeURI *twincodeURI) {
        if (errorCode != TLBaseServiceErrorCodeSuccess) {
            block(errorCode, nil);
        } else {
            [self.twinmeContext verifyContactWithUri:twincodeURI trustMethod:TLTrustMethodLink withBlock:^(TLBaseServiceErrorCode errorCode, TLContact *contact) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    block(errorCode, contact);
                });
            }];
        }
    }];
}

- (void)setLevelWithName:(NSString *)name {
    DDLogVerbose(@"%@ setLevelWithName: %@", LOG_TAG, name);
    
    if ([name length] > 0) {
        [self.twinmeContext setLevelWithRequestId:[self newOperation:SET_LEVEL] name:name];
    }
}

- (void)createLevelWithName:(NSString *)name {
    DDLogVerbose(@"%@ createLevelWithName: %@", LOG_TAG, name);
    
    if ([name length] > 0) {
        [self.twinmeContext createLevelWithRequestId:[self newOperation:CREATE_LEVEL] name:name];
    }
}

- (void)deleteLevelWithName:(NSString *)name {
    DDLogVerbose(@"%@ deleteLevelWithName: %@", LOG_TAG, name);
    
    if ([name length] > 0) {
        [self.twinmeContext deleteLevelWithRequestId:[self newOperation:DELETE_LEVEL] name:name];
    }
}

- (void)subscribeFeature:(nonnull NSString*)productId purchaseToken:(nonnull NSString *)purchaseToken purchaseOrderId:(nonnull NSString *)purchaseOrderId {
    DDLogVerbose(@"%@ subscribeFeature: %@ purchaseToken: %@ purchaseOrderId: %@", LOG_TAG, productId, purchaseToken, purchaseOrderId);
    
    self.productId = productId;
    self.purchaseToken = purchaseToken;
    self.purchaseOrderId = purchaseOrderId;
    
    self.work |= SUBSCRIBE_FEATURE;
    self.state &= ~(SUBSCRIBE_FEATURE | SUBSCRIBE_FEATURE_DONE);
    [self showProgressIndicator];
    [self startOperation];
}

- (void)dispose {
    DDLogVerbose(@"%@ dispose", LOG_TAG);
    
    [self.twinmeContext removeDelegate:self.twinmeContextDelegate];
}

#pragma mark - Private methods

- (void)onOperation {
    DDLogVerbose(@"%@ onOperation", LOG_TAG);
    
    if (!self.isTwinlifeReady) {
        return;
    }
    
    //
    // Step 1: get the current space.
    //

    if ((self.state & GET_CURRENT_SPACE) == 0) {
        self.state |= GET_CURRENT_SPACE;
        
        [self.twinmeContext getCurrentSpaceWithBlock:^(TLBaseServiceErrorCode errorCode, TLSpace *space) {
            self.space = space;
            self.state |= GET_CURRENT_SPACE_DONE;
            dispatch_async(dispatch_get_main_queue(), ^{
                if (space) {
                    [(id<MainServiceDelegate>)self.delegate onUpdateSpace:space];
                } else {
                    [(id<MainServiceDelegate>)self.delegate onGetDefaultProfileNotFound];
                }
            });
            [self onOperation];
        }];
        return;
    }
    if ((self.state & GET_CURRENT_SPACE_DONE) == 0) {
        return;
    }

    //
    // Step 2
    //

    if ((self.state & GET_PENDING_NOTIFICATIONS) == 0) {
        self.state |= GET_PENDING_NOTIFICATIONS;

        [self.twinmeContext getSpaceNotificationStatsWithBlock:^(TLBaseServiceErrorCode errorCode, TLNotificationServiceNotificationStat *stats) {
            self.state |= GET_PENDING_NOTIFICATIONS_DONE;
            dispatch_async(dispatch_get_main_queue(), ^{
                [(id<MainServiceDelegate>)self.delegate onUpdatePendingNotifications:stats.pendingCount > 0];
            });
            [self onOperation];
        }];
        return;
    }
    if ((self.state & GET_PENDING_NOTIFICATIONS_DONE) == 0) {
        return;
    }

    //
    // Step 3
    //

    if ((self.state & GET_CONVERSATIONS) == 0) {
        self.state |= GET_CONVERSATIONS;
        
        [self.twinmeContext findConversationsWithPredicate:^BOOL(id<TLOriginator> originator) {
            return [self.twinmeContext isCurrentSpace:originator];
        } withBlock:^(NSMutableArray<id<TLConversation>> *conversations) {
            self.state |= GET_CONVERSATIONS_DONE;
            dispatch_async(dispatch_get_main_queue(), ^{
                [(id<MainServiceDelegate>)self.delegate onGetConversations:conversations.count > 0];
            });
            [self onOperation];
        }];
        return;
    }
    
    if ((self.state & GET_CONVERSATIONS_DONE) == 0) {
        return;
    }

    //
    // Step 4
    //

    if ((self.state & GET_TRANSFER_CALL) == 0) {
        self.state |= GET_TRANSFER_CALL;
        
        TLFilter *filter = [TLFilter alloc];
        filter.acceptWithObject = ^BOOL(id<TLDatabaseObject> object) {
            TLCallReceiver *callReceiver = (TLCallReceiver *)object;
            
            return callReceiver.isTransfer;
        };
        [self.twinmeContext findCallReceiversWithFilter:filter withBlock:^(NSMutableArray<TLCallReceiver *> *callReceivers) {
            [self onGetTransfertCall:callReceivers];
        }];
        return;
    }
    
    if ((self.state & GET_TRANSFER_CALL_DONE) == 0) {
        return;
    }

    //
    // Step 5: get the list of spaces.
    //
    if ((self.state & GET_SPACES) == 0) {
        self.state |= GET_SPACES;

        [self.twinmeContext findSpacesWithPredicate:^BOOL(TLSpace *space) {
            return YES;
        } withBlock:^(NSMutableArray<TLSpace *> *spaces) {
            self.state |= GET_SPACES_DONE;
            [self runOnGetSpaces:spaces];
            [self onOperation];
        }];
        return;
    }
    if ((self.state & GET_SPACES_DONE) == 0) {
        return;
    }
        
    //
    // Step 6
    //

    if ((self.state & GET_CONTACTS) == 0) {
        self.state |= GET_CONTACTS;

        [self.twinmeContext findContactsWithFilter:[self.twinmeContext createSpaceFilter] withBlock:^(NSMutableArray<TLContact *> *contacts) {
            self.state |= GET_CONTACTS_DONE;
            dispatch_async(dispatch_get_main_queue(), ^{
                [(id<MainServiceDelegate>)self.delegate onGetContacts:(int)contacts.count];
            });
            [self onOperation];
        }];
        return;
    }
    
    if ((self.state & GET_CONTACTS_DONE) == 0) {
        return;
    }
    
    //
    // Step 6: get the pending space notifications.
    //
    if ((self.state & GET_SPACE_NOTIFICATIONS) == 0) {
        self.state |= GET_SPACE_NOTIFICATIONS;
        
        [self.twinmeContext getNotificationStatsWithBlock:^(TLBaseServiceErrorCode errorCode, NSDictionary<NSUUID *, TLNotificationServiceNotificationStat *> *spacesWithNotifications) {
            self.state |= GET_SPACE_NOTIFICATIONS_DONE;
            dispatch_async(dispatch_get_main_queue(), ^{
                [(id<MainServiceDelegate>)self.delegate onGetSpacesNotifications:spacesWithNotifications];
            });
            [self onOperation];
        }];
        return;
    }
    if ((self.state & GET_SPACE_NOTIFICATIONS_DONE) == 0) {
        return;
    }
    
    if ((self.work & SUBSCRIBE_FEATURE) != 0) {
        if ((self.state & SUBSCRIBE_FEATURE) == 0) {
            self.state |= SUBSCRIBE_FEATURE;
            
            int64_t requestId = [self newOperation:SUBSCRIBE_FEATURE];
            [[self.twinmeContext getAccountService] subscribeFeatureWithRequestId:requestId merchantId:TLMerchantIdentificationTypeApple purchaseProductId:self.productId purchaseToken:self.purchaseToken purchaseOrderId:self.purchaseOrderId];
            return;
        }
        if ((self.state & SUBSCRIBE_FEATURE_DONE) == 0) {
            return;
        }
    }
    
    //
    // Last Step
    //
    
    [self hideProgressIndicator];
}

- (void)onTwinlifeOnline {
    DDLogVerbose(@"%@ onTwinlifeOnline", LOG_TAG);
    
    if (self.restarted) {
        self.restarted = NO;
        
        if (((self.state & SUBSCRIBE_FEATURE) != 0 ) && ((self.state & SUBSCRIBE_FEATURE_DONE) == 0)) {
            self.state &= ~SUBSCRIBE_FEATURE;
        }
    }
}

- (void)onSetCurrentSpace:(nonnull TLSpace *)space {
    DDLogVerbose(@"%@ onSetCurrentSpace: %@", LOG_TAG, space);

    self.space = space;
    self.state |= SET_CURRENT_SPACE_DONE;
    self.state &= ~(GET_PENDING_NOTIFICATIONS | GET_PENDING_NOTIFICATIONS_DONE | GET_CONVERSATIONS | GET_CONVERSATIONS_DONE | GET_CONTACTS | GET_CONTACTS_DONE);
    [self runOnSetCurrentSpace:space];
    [self onOperation];
}

- (void)onCreateSpace:(nonnull TLSpace *)space {
    DDLogVerbose(@"%@ onCreateSpace: %@", LOG_TAG, space);

    dispatch_async(dispatch_get_main_queue(), ^{
        [(id<MainServiceDelegate>)self.delegate onCreateSpace:space];
    });
}

- (void)onUpdateSpace:(TLSpace *)space {
    DDLogVerbose(@"%@ onUpdateSpace: %@", LOG_TAG, space);
    
    [self runOnUpdateSpace:space];
}

- (void)onDeleteSpace:(nonnull NSUUID *)spaceId {
    DDLogVerbose(@"%@ onDeleteSpace: %@", LOG_TAG, spaceId);
    
    [self runOnDeleteSpace:spaceId];

    if (self.space != nil && [spaceId isEqual:self.space.uuid]) {
        self.space = nil;
        self.state = 0;
        [self onOperation];
    }
}

- (void)onCreateProfile:(nonnull TLProfile *)profile {
    DDLogVerbose(@"%@ onCreateProfile: %@", LOG_TAG, profile);
    
    if ([self.twinmeContext isCurrentProfile:profile]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [(id<MainServiceDelegate>)self.delegate onUpdateDefaultProfile:profile];
        });
    }
}

- (void)onUpdateProfile:(nonnull TLProfile *)profile {
    DDLogVerbose(@"%@ onUpdateProfile: %@", LOG_TAG, profile);
    
    if ([self.twinmeContext isCurrentProfile:profile]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [(id<MainServiceDelegate>)self.delegate onUpdateDefaultProfile:profile];
        });
    }
}

- (void)onGetTransfertCall:(NSArray *)callReceivers {
    DDLogVerbose(@"%@ onGetTransfertCall: %@", LOG_TAG, callReceivers);
    
    self.state |= GET_TRANSFER_CALL_DONE;
    
    if (callReceivers.count > 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [(id<MainServiceDelegate>)self.delegate onGetTransfertCall:[callReceivers objectAtIndex:0]];
        });
    }
    [self onOperation];
}

- (void)onCreateCallReceiver:(TLCallReceiver *)callReceiver {
    DDLogVerbose(@"%@ onCreateCallReceiver: %@", LOG_TAG, callReceiver);
        
    if (callReceiver.isTransfer) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [(id<MainServiceDelegate>)self.delegate onCreateTransfertCall:callReceiver];
        });
    }
}

- (void)onUpdateCallReceiver:(TLCallReceiver *)callReceiver {
    DDLogVerbose(@"%@ onUpdateCallReceiver: %@", LOG_TAG, callReceiver);
        
    if (callReceiver.isTransfer) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [(id<MainServiceDelegate>)self.delegate onUpdateTransfertCall:callReceiver];
        });
    }
}

- (void)onDeleteCallReceiver:(NSUUID *)callReceiverId {
    DDLogVerbose(@"%@ onDeleteCallReceiver: %@", LOG_TAG, callReceiverId);

    dispatch_async(dispatch_get_main_queue(), ^{
        [(id<MainServiceDelegate>)self.delegate onDeleteTransfertCall:callReceiverId];
    });
}

- (void)onUpdatePendingNotifications:(BOOL)hasPendingNotifications {
    DDLogVerbose(@"%@ onUpdatePendingNotifications: %@", LOG_TAG, hasPendingNotifications ? @"YES" : @"NO");

    dispatch_async(dispatch_get_main_queue(), ^{
        [(id<MainServiceDelegate>)self.delegate onUpdatePendingNotifications:hasPendingNotifications];
    });
    self.state &= ~(GET_SPACE_NOTIFICATIONS | GET_SPACE_NOTIFICATIONS_DONE);
    [self onOperation];
}

- (void)onGetConversations:(BOOL)hasConversations {
    DDLogVerbose(@"%@ onGetConversations: %@", LOG_TAG, hasConversations ? @"YES" : @"NO");

    dispatch_async(dispatch_get_main_queue(), ^{
        [(id<MainServiceDelegate>)self.delegate onGetConversations:hasConversations];
    });
}

- (void)onOpenURL:(NSURL *)url {
    DDLogVerbose(@"%@ onOpenURL: %@", LOG_TAG, url);

    dispatch_async(dispatch_get_main_queue(), ^{
        [(id<MainServiceDelegate>)self.delegate onOpenURL:url];
    });
}

- (void)onSubscribeUpdate:(TLBaseServiceErrorCode)errorCode {
    DDLogVerbose(@"%@ onSubscribeUpdate: %d", LOG_TAG, errorCode);
    
    // When we are offline or failed to send the request, we must retry.
    if (errorCode == TLBaseServiceErrorCodeTwinlifeOffline) {

        self.restarted = YES;
        return;
    }

    self.state |= SUBSCRIBE_FEATURE_DONE;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (errorCode == TLBaseServiceErrorCodeSuccess) {
            [(id<MainServiceDelegate>)self.delegate onSubscribeSuccess];
        } else {
            [(id<MainServiceDelegate>)self.delegate onSubscribeFailed:errorCode];
        }
    });
    [self onOperation];
}

- (void)onFatalErrorWithErrorCode:(TLBaseServiceErrorCode)errorCode databaseError:(NSError *)databaseError {
    DDLogVerbose(@"%@ onFatalErrorWithErrorCode: %d databaseError:%@", LOG_TAG, errorCode, databaseError);

    dispatch_async(dispatch_get_main_queue(), ^{
        [(id<MainServiceDelegate>)self.delegate onFatalError:errorCode databaseError:databaseError];
    });
}

- (void)onErrorWithOperationId:(int)operationId errorCode:(TLBaseServiceErrorCode)errorCode errorParameter:(NSString *)errorParameter {
    DDLogVerbose(@"%@ onErrorWithOperationId: %d errorCode: %d errorParameter: %@", LOG_TAG, operationId, errorCode, errorParameter);
    
    // Wait for reconnection
    if (errorCode == TLBaseServiceErrorCodeTwinlifeOffline) {
        self.restarted = YES;
        return;
    }
    
    if (operationId == GET_CURRENT_SPACE) {
        self.state |= GET_CURRENT_SPACE_DONE;

        if (errorCode == TLBaseServiceErrorCodeItemNotFound) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [(id<MainServiceDelegate>)self.delegate onGetDefaultProfileNotFound];
            });
            return;
        }
    }
    
    // Trying to create an invalid skredboard level: do nothing.
    if (operationId == CREATE_LEVEL && errorCode == TLBaseServiceErrorCodeBadRequest) {
        return;
    }
    
    // Trying to change the skredboard level but new level does not exist: do nothing.
    if (operationId == SET_LEVEL && (errorCode == TLBaseServiceErrorCodeItemNotFound || errorCode == TLBaseServiceErrorCodeBadRequest)) {
        return;
    }
    
    // Trying to delete an invalid skredboard: do nothing.
    if (operationId == DELETE_LEVEL && (errorCode == TLBaseServiceErrorCodeItemNotFound || errorCode == TLBaseServiceErrorCodeBadRequest)) {
        return;
    }    

    [super onErrorWithOperationId:operationId errorCode:errorCode errorParameter:errorParameter];
}

@end
