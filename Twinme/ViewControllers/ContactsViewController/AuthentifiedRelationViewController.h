/*
 *  Copyright (c) 2024 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <TwinmeCommon/AbstractTwinmeViewController.h>

//
// Interface: AuthentifiedRelationViewController
//

@class TLContact;

@interface AuthentifiedRelationViewController : AbstractTwinmeViewController

- (void)initWithContact:(TLContact *)contact;

@end
