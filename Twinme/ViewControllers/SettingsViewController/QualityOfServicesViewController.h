/*
 *  Copyright (c) 2022-2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

//
// Protocol: QualityOfServicesDelegate
//

@protocol QualityOfServicesDelegate <NSObject>

- (void)didTouchSettings;

@end

#import <TwinmeCommon/AbstractTwinmeViewController.h>

//
// Interface: QualityOfServicesViewController
//

@interface QualityOfServicesViewController : AbstractTwinmeViewController

- (void)showInView:(UIViewController*)view;

@end
