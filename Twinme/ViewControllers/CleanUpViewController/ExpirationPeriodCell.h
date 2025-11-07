/*
 *  Copyright (c) 2023 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

@class UICleanUpExpiration;

//
// Interface: ExpirationPeriodCell
//

@interface ExpirationPeriodCell : UITableViewCell

- (void)bindWithExpiration:(UICleanUpExpiration *)cleanUpExpiration displayValue:(BOOL)displayValue checked:(BOOL)checked hideSeparator:(BOOL)hideSeparator;

@end
