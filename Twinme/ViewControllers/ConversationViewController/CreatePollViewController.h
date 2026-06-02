/*
 *  Copyright (c) 2026 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <TwinmeCommon/AbstractTwinmeViewController.h>


@protocol CreatePollViewControllerDelegate <NSObject>

- (void)createPollWithMultipleAnswersAllowed:(BOOL)multipleAnswersAllowed question:(nonnull NSString *)question choices:(nonnull NSArray<TLChoice *> *)choices;

@end


//
// Interface: CreatePollViewController
//

@interface CreatePollViewController : AbstractTwinmeViewController

@property (nullable, nonatomic) id<CreatePollViewControllerDelegate> delegate;

@end
