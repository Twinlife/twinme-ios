/*
 *  Copyright (c) 2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <TwinmeCommon/AbstractTwinmeViewController.h>

@class TLSNIProxyDescriptor;

//
// Interface: AddProxyViewController
//

@interface AddProxyViewController : AbstractTwinmeViewController

@property (weak, nonatomic, nullable) TLSNIProxyDescriptor *proxyDescriptor;

@end
