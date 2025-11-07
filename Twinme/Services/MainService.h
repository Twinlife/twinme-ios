/*
 *  Copyright (c) 2017-2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Christian Jacquemot (Christian.Jacquemot@twinlife-systems.com)
 *   Stephane Carrez (Stephane.Carrez@twin.life)
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <TwinmeCommon/AbstractTwinmeService.h>

//
// Protocol: MainServiceDelegate
//

@class TLProfile;
@class TLContact;
@class TLGroup;
@protocol TLConversation;
@protocol TLGroupConversation;
@class TLTwinmeContext;
@class TLTwincodeURI;

@protocol MainServiceDelegate <AbstractTwinmeDelegate, CurrentSpaceTwinmeDelegate>

- (void)onCreateSpace:(nonnull TLSpace *)space;

- (void)onDeleteSpace:(nonnull NSUUID *)spaceId;

- (void)onGetSpaces:(nonnull NSArray *)spaces;

- (void)onUpdateDefaultProfile:(nonnull TLProfile *)profile;

- (void)onGetDefaultProfileNotFound;

- (void)onUpdatePendingNotifications:(BOOL)hasPendingNotifications;

- (void)onGetConversations:(BOOL)hasConversations;

- (void)onGetContacts:(int)nbContacts;

- (void)onGetTransfertCall:(nonnull TLCallReceiver *)callReceiver;

- (void)onCreateTransfertCall:(nonnull TLCallReceiver *)callReceiver;

- (void)onUpdateTransfertCall:(nonnull TLCallReceiver *)callReceiver;

- (void)onDeleteTransfertCall:(nonnull NSUUID *)callReceiverId;

- (void)onOpenURL:(nonnull NSURL *)url;

- (void)onFatalError:(TLBaseServiceErrorCode)errorCode databaseError:(nullable NSError *)databaseError;

@optional - (void)onUpdateSpace:(nonnull TLSpace *)space;

@optional - (void)onSubscribeSuccess;

@optional - (void)onSubscribeFailed:(TLBaseServiceErrorCode)errorCode;

@optional - (void)onGetSpacesNotifications:(nonnull NSDictionary<NSUUID *, TLNotificationServiceNotificationStat *> *)spacesNotifications;

@end

//
// Interface: MainService
//

@interface MainService : AbstractTwinmeService

- (nonnull instancetype)initWithTwinmeContext:(nonnull TLTwinmeContext *)twinmeContext delegate:(nonnull id<MainServiceDelegate>)delegate;

- (void)setCurrentSpace:(nonnull TLSpace *)space;

- (void)getConversations;

- (void)getSpaces;

- (void)setLevelWithName:(nonnull NSString *)name;

- (void)createLevelWithName:(nonnull NSString *)name;

- (void)deleteLevelWithName:(nonnull NSString *)name;

- (void)subscribeFeature:(nonnull NSString*)productId purchaseToken:(nonnull NSString *)purchaseToken purchaseOrderId:(nonnull NSString *)purchaseOrderId;

- (void)getContacts;

- (void)parseUriWithUri:(nonnull NSURL *)uri withBlock:(nonnull void (^)(TLBaseServiceErrorCode errorCode, TLTwincodeURI *_Nullable twincodeUri))block;

- (void)verifyAuthenticateWithURI:(nonnull NSURL *)uri withBlock:(nonnull void (^)(TLBaseServiceErrorCode errorCode, TLContact *_Nullable contact))block;

@end
