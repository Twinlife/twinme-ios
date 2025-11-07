/*
 *  Copyright (c) 2022-2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <TwinmeCommon/AbstractTwinmeViewController.h>

//
// Interface: WhatsNewViewController
//

@interface WhatsNewViewController : AbstractTwinmeViewController

@property (nonatomic) BOOL updateMode;

- (void)showInView:(UIViewController *)view;

@end
