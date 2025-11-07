/*
 *  Copyright (c) 2024 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "AbstractCapabilitiesViewController.h"

@class TLGroup;

@interface GroupCapabilitiesViewController : AbstractCapabilitiesViewController

- (void)initWithGroup:(TLGroup *)group;

@end
