/*
 *  Copyright (c) 2021 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

//
// Interface: SideSpaceCell
//

@class UISpace;
@protocol SideSpaceDelegate;

@interface SideSpaceCell : UITableViewCell

@property (weak, nonatomic) id<SideSpaceDelegate> sideSpaceDelegate;

- (void)bindWithSpace:(UISpace *)uiSpace isCurrentSpace:(BOOL)isCurrentSpace isSecretSpace:(BOOL)isSecretSpace;

@end
