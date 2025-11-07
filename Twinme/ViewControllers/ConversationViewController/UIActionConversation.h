/*
 *  Copyright (c) 2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

typedef enum {
    ConversationActionTypeCamera,
    ConversationActionTypeFile,
    ConversationActionTypeGallery,
    ConversationActionTypeLocation,
    ConversationActionTypeManageConversation,
    ConversationActionTypeMediasAndFiles,
    ConversationActionTypeReset
} ConversationActionType;

@class TLSpaceSettings;

//
// Interface: UIActionConversation
//

@interface UIActionConversation : NSObject

@property (nonatomic) ConversationActionType conversationActionType;
@property (nonatomic, nonnull) TLSpaceSettings *spaceSettings;
@property (nonatomic, nonnull) NSString *title;
@property (nonatomic, nonnull) UIImage *icon;
@property (nonatomic, nonnull) UIColor *iconColor;

- (nonnull instancetype)initWithConversationActionType:(ConversationActionType)conversationActionType spaceSettings:(nullable TLSpaceSettings *)spaceSettings;;

@end
