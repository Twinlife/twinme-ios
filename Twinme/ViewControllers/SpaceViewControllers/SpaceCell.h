/*
 *  Copyright (c) 2019-2023 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "SpacesViewController.h"

@class UISpace;

//
// Interface: SpaceCell
//

@interface SpaceCell : UITableViewCell

@property (weak, nonatomic) id<SpaceActionDelegate> spaceActionDelegate;

- (void)bindWithSpace:(UISpace *)uiSpace hideSeparator:(BOOL)hideSeparator;

@end
