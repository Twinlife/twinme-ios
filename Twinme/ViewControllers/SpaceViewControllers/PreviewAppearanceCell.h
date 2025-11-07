/*
 *  Copyright (c) 2022 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <TwinmeCommon/Design.h>

//
// Interface: PreviewAppearanceCell
//

@class CustomAppearance;

@interface PreviewAppearanceCell : UITableViewCell

- (void)bindWithAppearance:(CustomAppearance *)customAppearance conversationBackgroundImage:(UIImage *)backgroundImage;

@end
