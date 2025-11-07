/*
 *  Copyright (c) 2018 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "UIInvitation.h"

#import <Twinlife/TLConversationService.h>

//
// Implementation: UIInvitation
//

#undef LOG_TAG
#define LOG_TAG @"UIInvitation"

@implementation UIInvitation : UIContact

- (bool)peerFailure {
    
    return self.invitationDescriptor.receivedTimestamp < 0;
}

@end
