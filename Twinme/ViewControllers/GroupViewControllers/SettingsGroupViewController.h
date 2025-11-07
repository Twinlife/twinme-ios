/*
 *  Copyright (c) 2024 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <TwinmeCommon/AbstractTwinmeViewController.h>

//
// Protocol: SettingsGroupDelegate
//

@protocol SettingsGroupDelegate <NSObject>

- (void)updatePermissions:(BOOL)allowInvitation allowMessage:(BOOL)allowMessage allowInviteMemberAsContact:(BOOL)allowInviteMemberAsContact;

@end

//
// Interface: SettingsGroupViewController
//

@class TLGroup;

@interface SettingsGroupViewController : AbstractTwinmeViewController

@property (weak, nonatomic) id<SettingsGroupDelegate> delegate;

- (void)initWithGroup:(TLGroup *)group;

- (void)initWithPermissions:(BOOL)allowInvitation allowMessage:(BOOL)allowMessage allowInviteMemberAsContact:(BOOL)allowInviteMemberAsContact;

@end
