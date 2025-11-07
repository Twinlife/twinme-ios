/*
 *  Copyright (c) 2018-2020 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <TwinmeCommon/AbstractTwinmeViewController.h>

//
// Interface: AcceptGroupInvitationViewController
//

#import <TwinmeCommon/GroupService.h>

@interface AcceptGroupInvitationViewController : AbstractTwinmeViewController

- (void)initWithInvitationId:(TLDescriptorId *)invitationId contactId:(NSUUID *)contactId;

- (void)showInView:(UIView *)view;

@end
