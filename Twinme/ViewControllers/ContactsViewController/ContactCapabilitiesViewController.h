/*
 *  Copyright (c) 2021 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "AbstractCapabilitiesViewController.h"

//
// Interface: ContactCapabilitiesViewController
//

@class TLContact;

@interface ContactCapabilitiesViewController : AbstractCapabilitiesViewController

- (void)initWithContact:(TLContact *)contact;

@end
