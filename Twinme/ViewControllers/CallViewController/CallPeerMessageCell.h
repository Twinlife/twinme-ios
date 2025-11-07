/*
 *  Copyright (c) 2024 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "PeerMessageItem.h"

@class CallConversationView;

//
// Interface: CallPeerMessageCell
//

@interface CallPeerMessageCell : UITableViewCell

- (void)bindWithItem:(PeerMessageItem *)item callConversationView:(CallConversationView *)callConversationView ;

@end
