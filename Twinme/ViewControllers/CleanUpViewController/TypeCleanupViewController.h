/*
 *  Copyright (c) 2023 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <TwinmeCommon/AbstractTwinmeViewController.h>

@class TLContact;
@class TLGroup;
@class TLSpace;

//
// Interface: TypeCleanUpViewController
//

@interface TypeCleanUpViewController : AbstractTwinmeViewController

- (void)initCleanUpWithContact:(TLContact *)contact;

- (void)initCleanUpWithGroup:(TLGroup *)group;

- (void)initCleanUpWithSpace:(TLSpace *)space;

@end
