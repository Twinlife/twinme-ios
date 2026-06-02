/*
 *  Copyright (c) 2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

//
// Interface: FAQCell
//

@class UIFAQArticle;

@interface FAQCell : UITableViewCell

- (void)bindWithArticle:(UIFAQArticle *)uiFAQArticle hideSeparator:(BOOL)hideSeparator;

@end
