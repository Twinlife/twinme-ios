/*
 *  Copyright (c) 2021-2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 *   Stephane Carrez (Stephane.Carrez@twin.life)
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

//
// Protocol: ShareExtensionServiceDelegate
//

@class TLContact;
@class TLGroup;

@protocol ShareExtensionServiceDelegate

- (void)onGetContacts:(nonnull NSArray<TLContact *> *)contacts;

- (void)onUpdateContact:(nonnull TLContact *)contact avatar:(nonnull UIImage *)avatar;

- (void)onGetGroups:(nonnull NSArray *)groups;

- (void)onUpdateGroup:(nonnull TLGroup *)group avatar:(nonnull UIImage *)avatar;

- (void)onGetConversation:(nonnull id<TLConversation>)conversation;

- (void)onShareCompleted;

@end

@interface ShareExtensionService : TLTwinmeApplication

@property (nonnull) id <ShareExtensionServiceDelegate> shareExtensionServiceDelegate;

/// Get the ShareExtensionService instance (there is only one).
+ (nonnull ShareExtensionService *)instance;

/// Start the Twinlife library and open the database (we cannot and must not connect to the server).
- (void)start;

/// Stop the Twinlife library, close the database and optionaly schedule a job if something was posted.
- (void)stopWithCompletionHandler:(nonnull void (^)(TLBaseServiceErrorCode status))completionHandler;

- (BOOL)hasConversationActive:(nonnull id<TLRepositoryObject>)subject;

- (void)getConversationWithContact:(nonnull TLContact *)contact;

- (void)getConversationWithGroup:(nonnull TLGroup *)group;

- (void)pushMessage:(nonnull NSString *)message copyAllowed:(BOOL)copyAllowed;

- (void)pushFileWithPath:(nonnull NSString *)path type:(TLDescriptorType)type toBeDeleted:(BOOL)toBeDeleted copyAllowed:(BOOL)copyAllowed;

- (void)findContactsAndGroupsByName:(nonnull NSString *)name;

- (void)getContactsAndGroups;

- (void)getImageWithSpace:(nonnull TLSpace *)space withBlock:(nonnull void (^)(UIImage *_Nonnull image))block;

- (void)getImageWithContact:(nonnull id<TLOriginator>)originator withBlock:(nonnull void (^)(UIImage *_Nonnull image))block;

- (void)getImageWithGroup:(nonnull TLGroup *)group withBlock:(nonnull void (^)(UIImage *_Nonnull image))block;

/// Build a URL to redirect to the Twinme application with the given Contact/Group.  The URL allows to launch Twinme.
- (nonnull NSURL *)getConversationURLWithOriginator:(nonnull id<TLOriginator>)originator;

- (nonnull TLSpaceSettings *)getDefaultSpaceSettings;

@end
