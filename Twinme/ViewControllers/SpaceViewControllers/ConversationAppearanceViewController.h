/*
 *  Copyright (c) 2020-2022 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <TwinmeCommon/AbstractTwinmeViewController.h>
#import "CustomAppearance.h"

//
// Interface: ConversationAppearanceViewController
//

@protocol SpaceAppearanceDelegate;

@interface ConversationAppearanceViewController : AbstractTwinmeViewController

@property (weak, nonatomic) id<SpaceAppearanceDelegate> spaceAppearanceDelegate;

- (void)initWithSpace:(TLSpace *)space;

- (void)initWithDefaultSpaceSettings;

- (void)initWithCustomAppearance:(CustomAppearance *)customAppearance conversationBackgroundLightImage:(UIImage *)conversationBackgroundLightImage conversationBackgroundDarkImage:(UIImage *)conversationBackgroundDarkImage;

@end
