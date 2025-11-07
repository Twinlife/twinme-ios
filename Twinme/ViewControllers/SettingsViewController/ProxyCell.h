/*
 *  Copyright (c) 2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

//
// Interface: ProxyCell
//

@interface ProxyCell : UITableViewCell

- (void)bindWithProxy:(NSString *)proxy showError:(BOOL)showError hideSeparator:(BOOL)hideSeparator;

@end
