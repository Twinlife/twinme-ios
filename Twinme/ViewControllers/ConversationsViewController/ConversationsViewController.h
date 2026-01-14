/*
 *  Copyright (c) 2019-2026 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <TwinmeCommon/AbstractTwinmeViewController.h>

typedef enum {
    SearchFilterAll,
    SearchFilterContacts,
    SearchFilterGroup,
    SearchFilterMessage
} SearchFilter;

//
// Protocol: ConversationsActionDelegate
//

@class UIConversation;
@class TwinmeNavigationController;
@protocol TLOriginator;

@protocol ConversationsActionDelegate <NSObject>

- (void)didTapConversation:(nonnull UIConversation *)uiConversation;

- (void)didLongPressConversation:(nonnull UIConversation *)uiConversation;

@end

//
// Protocol: SearchSectionDelegate
//

@protocol SearchSectionDelegate <NSObject>

- (void)didTapAll:(int)tag;

@end

//
// Interface: ConversationsViewController
//

@interface ConversationsViewController : AbstractTwinmeViewController

+ (void)showViewWithSubject:(nonnull id<TLOriginator>)subject navigationController:(nonnull TwinmeNavigationController *)navigationController;

@end
