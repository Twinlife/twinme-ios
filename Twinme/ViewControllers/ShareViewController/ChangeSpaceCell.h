/*
 *  Copyright (c) 2022 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

@class UISpace;

//
// Interface: ChangeSpaceCell
//

@interface ChangeSpaceCell : UITableViewCell

- (void)bindWithSpace:(UISpace *)uiSpace;

@end
