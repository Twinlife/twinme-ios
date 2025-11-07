/*
 *  Copyright (c) 2023 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

@class UIExport;

//
// Interface: ExportContentCell
//

@interface ExportContentCell : UITableViewCell

- (void)bindWithExport:(UIExport *)uiExport;

@end
