/*
 *  Copyright (c) 2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */


//
// Interface: RestoreWordCell
//

@class UIBackupWord;

@interface RestoreWordCell : UICollectionViewCell

- (void)bind:(UIBackupWord *)backupWord currentWord:(BOOL)currentWord;

- (void)bindWithPosition:(int)position currentWord:(BOOL)currentWord;

@end
