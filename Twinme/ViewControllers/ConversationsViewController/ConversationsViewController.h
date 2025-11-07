/*
 *  Copyright (c) 2019-2020 twinlife SA.
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

@protocol ConversationsActionDelegate <NSObject>

- (void)didTapConversation:(UIConversation *)uiConversation;

- (void)didLongPressConversation:(UIConversation *)uiConversation;

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

@end
