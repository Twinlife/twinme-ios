/*
 *  Copyright (c) 2021 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <TwinmeCommon/AbstractTwinmeViewController.h>

//
// Interface: ScanViewController
//

@class TLProfile;

@interface ScanViewController : AbstractTwinmeViewController

- (void)initWithProfile:(TLProfile *)profile;

@end
