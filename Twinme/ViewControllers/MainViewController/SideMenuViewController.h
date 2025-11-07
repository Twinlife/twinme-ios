/*
 *  Copyright (c) 2020-2024 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <TwinmeCommon/AbstractTwinmeViewController.h>

@class UISpace;

//
// Protocol: DefaultProfileDelegate
//

@protocol DefaultProfileDelegate <NSObject>

- (void)addContact;

- (void)showProfile;

@end

//
// Protocol: SideSpaceDelegate
//

@protocol SideSpaceDelegate <NSObject>

- (void)showSpace:(UISpace *)uiSpace;

- (void)setCurrentSpace:(UISpace *)uiSpace;

@end

//
// Interface: SideMenuViewController
//

@interface SideMenuViewController : AbstractTwinmeViewController

- (void)resetContentOffset;

- (void)setUISpaces:(NSArray *)uiSpaces;

- (void)setSpace:(UISpace *)space;

- (void)setTransferCall:(TLCallReceiver *)callReceiver;

- (void)deleteTransferCall:(NSUUID *)callReceiverId;

- (void)reloadMenu;

- (void)openSideMenu;

- (void)closeSideMenu;

- (void)refreshTable;

@end
