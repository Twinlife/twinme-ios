/*
 *  Copyright (c) 2018-2024 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

@class UIConversation;
@class UIContactTag;

@protocol TLOriginator;

@interface UIContact : NSObject

@property (nonatomic, nonnull) id<TLOriginator> contact;
@property (nonatomic, nonnull) NSString *name;
@property (nonatomic, nullable) UIImage *avatar;
@property (nonatomic, nullable) UIContactTag *contactTag;
@property (nonatomic) BOOL isCertified;

@property (nonatomic, nullable, weak) UIConversation* uiConversation;

- (nonnull instancetype)initWithContact:(nonnull id<TLOriginator>)contact;

- (nonnull instancetype)initWithContact:(nonnull id<TLOriginator>)contact avatar:(nonnull UIImage *)avatar;

- (void)setContact:(nonnull id<TLOriginator>)contact;

- (void)setContact:(nonnull id<TLOriginator>)contact avatar:(nonnull UIImage *)avatar;

- (void)updateAvatar:(nullable UIImage *)avatar;

- (double)usageScore;

- (int64_t)lastMessageDate;

@end
