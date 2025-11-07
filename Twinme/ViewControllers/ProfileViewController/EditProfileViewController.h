/*
 *  Copyright (c) 2021 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "AbstractShowViewController.h"

//
// Interface: EditProfileViewController
//

@class TLProfile;
@class UITemplateSpace;

@interface EditProfileViewController : AbstractShowViewController

- (void)initWithProfile:(TLProfile *)profile;

- (void)initWithSpace:(TLSpace *)space;

- (void)initWithSpace:(TLSpace *)space templateSpace:(UITemplateSpace *)templateSpace;

@end
