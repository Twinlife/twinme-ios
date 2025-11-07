/*
 *  Copyright (c) 2023 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

//
// Interface: TemplateSpaceCell
//

@class UITemplateSpace;

@interface TemplateSpaceCell : UITableViewCell

- (void)bindWithSpace:(UITemplateSpace *)uiTemplateSpace hideSeparator:(BOOL)hideSeparator;

@end
