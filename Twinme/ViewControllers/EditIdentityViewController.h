/*
 *  Copyright (c) 2016-2021 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Marouane Qasmi (Marouane.Qasmi@twinlife-systems.com)
 *   Chedi Baccari (Chedi.Baccari@twinlife-systems.com)
 *   Christian Jacquemot (Christian.Jacquemot@twinlife-systems.com)
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "AbstractShowViewController.h"

//
// Interface: EditIdentityViewController
//

@class TLProfile;

@interface EditIdentityViewController : AbstractShowViewController

- (void)initWithContact:(TLContact *)contact;

- (void)initWithGroup:(TLGroup *)group;

- (void)initWithCallReceiver:(TLCallReceiver *)callReceiver;


@end
