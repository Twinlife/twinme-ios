/*
 *  Copyright (c) 2016-2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Marouane Qasmi (Marouane.Qasmi@twinlife-systems.com)
 *   Chedi Baccari (Chedi.Baccari@twinlife-systems.com)
 *   Christian Jacquemot (Christian.Jacquemot@twinlife-systems.com)
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

typedef enum {
    InvitationModeOnlyInvite,
    InvitationModeInvite,
    InvitationModeScan
} InvitationMode;

#import <TwinmeCommon/AbstractTwinmeViewController.h>

//
// Interface: AddContactViewController
//

@class TLProfile;

@interface AddContactViewController : AbstractTwinmeViewController

- (void)initWithProfile:(nonnull TLProfile *)profile invitationMode:(InvitationMode)invitationMode;

@end
