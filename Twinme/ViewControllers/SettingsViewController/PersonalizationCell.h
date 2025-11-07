/*
 *  Copyright (c) 2020 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

//
// Interface: PersonalizationCell
//

@interface PersonalizationCell : UITableViewCell

- (void)bindWithTitle:(NSString *)title checked:(BOOL)checked;

@end
