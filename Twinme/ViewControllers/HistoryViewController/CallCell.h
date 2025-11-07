/*
 *  Copyright (c) 2019-2023 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

@class UICall;

//
// Interface: CallCell
//

@interface CallCell : UITableViewCell

- (void)bindWithCall:(UICall *)uiCall hideSeparator:(BOOL)hideSeparator;

@end
