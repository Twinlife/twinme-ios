/*
 *  Copyright (c) 2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

//
// Interface: WordCompletionCell
//

@interface WordCompletionCell : UITableViewCell

- (void)bindWithWord:(NSString *)word backgroundColor:(UIColor *)backgroundColor;

@end
