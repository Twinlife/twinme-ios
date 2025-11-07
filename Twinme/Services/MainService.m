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
static const int GET_PENDING_NOTIFICATIONS = 1 << 2;
static const int GET_PENDING_NOTIFICATIONS_DONE = 1 << 3;
static const int SET_CURRENT_SPACE = 1 << 4;
static const int SET_CURRENT_SPACE_DONE = 1 << 5;
static const int GET_CONVERSATIONS = 1 << 6;
static const int GET_CONVERSATIONS_DONE = 1 << 7;
static const int GET_PROFILES = 1 << 8;
static const int GET_PROFILES_DONE = 1 << 9;
static const int UPDATE_SPACE = 1 << 10;
static const int UPDATE_SPACE_DONE = 1 << 11;
static const int GET_TRANSFER_CALL = 1 << 12;
static const int GET_TRANSFER_CALL_DONE = 1 << 13;
static const int GET_CONTACTS = 1 << 14;
static const int GET_CONTACTS_DONE = 1 << 15;

//
// Interface: MainService ()
//

@class MainServiceTwinmeContextDelegate;

@interface MainService ()

@property (nonatomic) int work;
@property (nonatomic, nullable) TLProfile *profile;
@property (nonatomic, nullable) TLSpace *space;

- (void)onOperation;

- (void)onSetCurrentSpace:(nonnull TLSpace *)space;

- (void)onUpdateSpace:(TLSpace *)space;

- (void)onCreateProfile:(nonnull TLProfile *)profile;

- (void)onUpdateProfile:(TLProfile *)profile;

- (void)onGetProfiles:(nonnull NSArray *)profiles;

- (void)onDeleteProfile:(nonnull NSUUID *)profileId;

- (void)onCreateCallReceiver:(nonnull TLCallReceiver *)callReceiver;

- (void)onUpdateCallReceiver:(TLCallReceiver *)callReceiver;

- (void)onDeleteCallReceiver:(nonnull NSUUID *)callReceiverId;

- (void)onUpdatePendingNotifications:(BOOL)hasPendingNotifications;

- (void)onGetConversations:(BOOL)hasConversations;

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
    
    [(MainService *)self.service onSetCurrentSpace:space];
}

- (void)onUpdateSpaceWithRequestId:(int64_t)requestId space:(TLSpace *)space {
    DDLogVerbose(@"%@ onUpdateSpaceWithRequestId: %lld space: %@", LOG_TAG, requestId, space);
    
    [(MainService *)self.service onUpdateSpace:space];
}

- (void)onUpdatePendingNotificationsWithRequestId:(int64_t)requestId hasPendingNotifications:(BOOL)hasPendingNotifications {
    DDLogVerbose(@"%@ onUpdatePendingNotificationsWithRequestId: %lld hasPendingNotifications: %@", LOG_TAG, requestId, hasPendingNotifications ? @"YES" : @"NO");
    
    [(MainService *)self.service onUpdatePendingNotifications:hasPendingNotifications];
}

- (void)onDeleteProfileWithRequestId:(int64_t)requestId profileId:(nonnull NSUUID *)profileId {
    DDLogVerbose(@"%@ onDeleteProfileWithRequestId: %lld profile: %@", LOG_TAG, requestId, profileId);
    
    [(MainService *)self.service onDeleteProfile:profileId];
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


- (void)activeProfile:(nonnull TLProfile *)profile {
    DDLogVerbose(@"%@ activeProfile: %@", LOG_TAG, profile);
    
    self.profile = profile;
    
    self.work = UPDATE_SPACE;
    self.state &= ~(UPDATE_SPACE | UPDATE_SPACE_DONE);
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
    if ((self.state & GET_PROFILES) == 0) {
        self.state |= GET_PROFILES;

        [self.twinmeContext getProfilesWithBlock:^(TLBaseServiceErrorCode errorCode, NSArray<TLProfile *> *list) {
            [self onGetProfiles:list];
        }];
        return;
    }
    
    if ((self.state & GET_PROFILES_DONE) == 0) {
        return;
    }

    //
    // Step 5
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
    // We must update the current profile.
    //
    if (self.space && self.profile && (self.work & UPDATE_SPACE) != 0) {
        if ((self.state & UPDATE_SPACE) == 0) {
            self.state |= UPDATE_SPACE;
            
            int64_t requestId = [self newOperation:UPDATE_SPACE];
            DDLogVerbose(@"%@ updateSpaceWithRequestId: %lld space: %@ profile: %@", LOG_TAG, requestId, self.space, self.profile);
            
            [self.twinmeContext updateSpaceWithRequestId:requestId space:self.space profile:self.profile];
            return;
        }
        
        if ((self.state & UPDATE_SPACE_DONE) == 0) {
            return;
        }
    }
    
    //
    // Last Step
    //
    
    [self hideProgressIndicator];
}

- (void)onSetCurrentSpace:(nonnull TLSpace *)space {
    DDLogVerbose(@"%@ onSetCurrentSpace: %@", LOG_TAG, space);
    
    self.state |= SET_CURRENT_SPACE_DONE;
    self.state &= ~(GET_PENDING_NOTIFICATIONS | GET_PENDING_NOTIFICATIONS_DONE | GET_CONVERSATIONS | GET_CONVERSATIONS_DONE | GET_CONTACTS | GET_CONTACTS_DONE);
    [self runOnSetCurrentSpace:space];
    [self onOperation];
}

- (void)onUpdateSpace:(TLSpace *)space {
    DDLogVerbose(@"%@ onUpdateSpace: %@", LOG_TAG, space);
    
    self.state |= UPDATE_SPACE_DONE;
    [self runOnUpdateSpace:space];
}

- (void)onCreateProfile:(TLProfile *)profile {
    DDLogVerbose(@"%@ onCreateProfile: %@", LOG_TAG, profile);
    
    if ([self.twinmeContext isCurrentProfile:profile]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [(id<MainServiceDelegate>)self.delegate onUpdateDefaultProfile:profile];
        });
    }
}

- (void)onUpdateProfile:(TLProfile *)profile {
    DDLogVerbose(@"%@ onUpdateProfile: %@", LOG_TAG, profile);
    
    if ([self.twinmeContext isCurrentProfile:profile]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [(id<MainServiceDelegate>)self.delegate onUpdateDefaultProfile:profile];
        });
    }
}

- (void)onDeleteProfile:(NSUUID *)profileId {
    DDLogVerbose(@"%@ onDeleteProfile: %@", LOG_TAG, profileId);

    dispatch_async(dispatch_get_main_queue(), ^{
        [(id<MainServiceDelegate>)self.delegate onDeleteProfile:profileId];
    });
    [self onOperation];
}

- (void)onGetProfiles:(NSArray *)profiles {
    DDLogVerbose(@"%@ onGetProfiles: %@", LOG_TAG, profiles);
    
    self.state |= GET_PROFILES_DONE;

    dispatch_async(dispatch_get_main_queue(), ^{
        [(id<MainServiceDelegate>)self.delegate onGetProfiles:profiles];
    });
    [self onOperation];
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

    [super onErrorWithOperationId:operationId errorCode:errorCode errorParameter:errorParameter];
}

@end
