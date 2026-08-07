/*
 *  Copyright (c) 2026 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

//
// Interface: ShareContactCell
//

@interface ShareContactCell : UITableViewCell

- (void)bindWithName:(NSString *)name avatar:(UIImage *)avatar;

@end
