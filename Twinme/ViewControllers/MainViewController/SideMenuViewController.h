/*
 *  Copyright (c) 2020-2024 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <TwinmeCommon/AbstractTwinmeViewController.h>

@class UIProfile;

//
// Protocol: DefaultProfileDelegate
//

@protocol DefaultProfileDelegate <NSObject>

- (void)addContact;

- (void)showProfile;

@end

//
// Interface: SideMenuViewController
//

@interface SideMenuViewController : AbstractTwinmeViewController

- (void)setUIProfiles:(NSArray *)uiProfiles;

- (void)setProfile:(UIProfile *)profile;

- (void)setTransferCall:(TLCallReceiver *)callReceiver;

- (void)deleteTransferCall:(NSUUID *)callReceiverId;

- (void)reloadMenu;

- (void)openSideMenu;

- (void)closeSideMenu;

- (void)refreshTable;

@end
