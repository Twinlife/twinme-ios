/*
 *  Copyright (c) 2026 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

@class UICall;

//
// Interface: LastCallCell
//

@interface LastCallCell : UITableViewCell

- (void)bindWithCall:(UICall *)uiCall hideSeparator:(BOOL)hideSeparator;

@end
