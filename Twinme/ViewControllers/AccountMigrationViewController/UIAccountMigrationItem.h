/*
 *  Copyright (c) 2026 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

//
// Interface: UIAccountMigrationItem
//

@interface UIAccountMigrationItem : NSObject

- (nonnull instancetype)initWithPosition:(int)position text:(nonnull NSString *)text;

- (int)getPosition;

- (nonnull NSString *)getText;

@end
