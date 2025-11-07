/*
 *  Copyright (c) 2019 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <TwinmeCommon/AbstractTwinmeViewController.h>
#import "EditSpaceViewController.h"

//
// Interface: ContactsSpaceViewController
//

@class TLSpace;

@interface ContactsSpaceViewController : AbstractTwinmeViewController

@property (weak, nonatomic) id<ContactsSpaceDelegate> contactsSpaceDelegate;

- (void)initWithSpace:(TLSpace *)space;

- (void)initWithContacts:(NSMutableArray *)contacts;

@end
