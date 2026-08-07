/*
 *  Copyright (c) 2026 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "AbstractMenuView.h"

typedef NS_ENUM(NSInteger, SilentModeDuration) {
    SilentModeDurationOneHour,
    SilentModeDurationEightHours,
    SilentModeDurationOneDay,
    SilentModeDurationOneWeek,
    SilentModeDurationIndefinitely
};

@class UIConversation;
@class MenuConversationShorcutView;

@protocol MenuConversationShorcutDelegate <NSObject>

- (void)resetConversation:(nonnull MenuConversationShorcutView *)menuConversationShorcutView conversation:(nonnull UIConversation *)uiConversation;

- (void)showOriginator:(nonnull MenuConversationShorcutView *)menuConversationShorcutView conversation:(nonnull UIConversation *)uiConversation;

- (void)saveConversationSettings:(nonnull MenuConversationShorcutView *)menuConversationShorcutView conversation:(nonnull UIConversation *)uiConversation silentMode:(BOOL)silentMode silentModeExpiration:(long)silentModeExpiration notificationReaction:(BOOL)notificationReaction;

- (void)selectSilentModeDuration:(nonnull MenuConversationShorcutView *)menuConversationShorcutView conversation:(nonnull UIConversation *)uiConversation;

@end

//
// Interface: MenuConversationShorcutView
//

@interface MenuConversationShorcutView : AbstractMenuView

@property (weak, nonatomic) id<MenuConversationShorcutDelegate> menuConversationShorcutDelegate;

- (void)openMenu:(nonnull UIConversation *)uiConversation silentMode:(BOOL)silentMode notificationReaction:(BOOL)notificationReaction silentExpiration:(int64_t)silentExpiration;

@end
