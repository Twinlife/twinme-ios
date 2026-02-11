/*
 *  Copyright (c) 2023 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

//
// Interface: TemplateExternalCallCell
//

@class UITemplateExternalCall;

@interface TemplateExternalCallCell : UITableViewCell

- (void)bindWithTemplate:(UITemplateExternalCall *)uiTemplateExternalCall hideSeparator:(BOOL)hideSeparator;

@end
