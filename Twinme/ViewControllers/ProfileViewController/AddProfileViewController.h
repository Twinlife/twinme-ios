/*
 *  Copyright (c) 2020-2024 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <TwinmeCommon/AbstractTwinmeViewController.h>

@class TLTwincodeURI;

//
// Interface: AddProfileViewController
//

@interface AddProfileViewController : AbstractTwinmeViewController

@property (nonatomic) BOOL fromCreateSpace;
@property (nonatomic) BOOL firstProfile;
@property (nonatomic) BOOL fromContactsTab;
@property (nonatomic) BOOL fromConversationsTab;
@property (nonatomic) NSURL *invitationURL;
@property (nonatomic) NSString *lastLevelName;

@end
