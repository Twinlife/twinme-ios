/*
 *  Copyright (c) 2022 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

//
// Interface: EmojiSizeCell
//

@interface EmojiSizeCell : UITableViewCell

- (void)bindWithTitle:(NSString *)title emojiSize:(int)emojiSize checked:(BOOL)checked;

@end
