/*
 *  Copyright (c) 2026 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <TwinmeCommon/AbstractTwinmeViewController.h>

@class TLContact;

//
// Protocol: ShareContactViewDelegate
//

@protocol ShareContactViewDelegate <NSObject>

- (void)didCancelShareContactView;

- (void)didSelectContactToShare:(nonnull TLContact *)contact;

@end

//
// Interface: ShareContactViewController
//

@interface ShareContactViewController : AbstractTwinmeViewController

@property (weak, nonatomic, nullable) id<ShareContactViewDelegate> shareContactViewDelegate;

- (void)initWithContact:(nonnull TLContact *)contact;

@end
