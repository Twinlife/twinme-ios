/*
 *  Copyright (c) 2024 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "MessageItem.h"

@class CallConversationView;

//
// Interface: CallMessageCell
//

@interface CallMessageCell : UITableViewCell

- (void)bindWithItem:(MessageItem *)item callConversationView:(CallConversationView *)callConversationView;

@end
