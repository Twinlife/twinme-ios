/*
 *  Copyright (c) 2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

//
// Interface: UIBackupWord
//

@interface UIBackupWord : NSObject

- (nonnull instancetype)initWithWord:(nullable NSString *)word position:(int)position;

- (nullable NSString *)getWord;

- (void)updateWord:(nullable NSString *)word;

- (int)getPosition;

@end
