/*
 *  Copyright (c) 2023 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

//
// Interface: ExportProgressCell
//

@interface ExportProgressCell : UITableViewCell

- (void)bindWithProgress:(float)progress message:(NSString *)message;

@end
