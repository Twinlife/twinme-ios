/*
 *  Copyright (c) 2021 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

//
// Interface: TimeoutCell
//

@class UITimeout;

@interface TimeoutCell : UITableViewCell

- (void)bindWithTimeout:(UITimeout *)timeout hideSeparator:(BOOL)hideSeparator;

@end
