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

typedef enum {
    CleanUpTypeLocal,
    CleanUpTypeBoth
} CleanUpType;

//
// Interface: CleanUpViewController
//

@interface CleanUpViewController : AbstractTwinmeViewController

@property (nonatomic) CleanUpType cleanUpType;

- (void)initCleanUpWithContact:(TLContact *)contact;

- (void)initCleanUpWithGroup:(TLGroup *)group;

- (void)initCleanUpWithSpace:(TLSpace *)space;

- (void)initCleanUpApplication;

@end
