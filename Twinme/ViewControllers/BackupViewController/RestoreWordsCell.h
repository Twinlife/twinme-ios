/*
 *  Copyright (c) 2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

//
// Protocol: RestoreWordsDelegate
//

@protocol RestoreWordsDelegate <NSObject>

- (void)didTapPasteWords;

- (void)didEnterAllWords;

- (void)updateWords:(NSArray *)words;

@end

//
// Interface: RestoreWordsCell
//

@class MnemonicCodeUtils;

@interface RestoreWordsCell : UITableViewCell

@property (weak, nonatomic) id<RestoreWordsDelegate> restoreWordsDelegate;

- (void)bind:(MnemonicCodeUtils *)mnemonicCodeUtils words:(NSArray *)words;

@end
