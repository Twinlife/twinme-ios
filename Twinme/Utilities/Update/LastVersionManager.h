/*
 *  Copyright (c) 2022 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

@class LastVersion;

@interface LastVersionManager : NSObject

@property(nullable) LastVersion *lastVersion;

- (void)getLastVersion;

- (BOOL)isNewVersionAvailable;

- (BOOL)isMajorVersionWithUpdate:(BOOL)update;

- (BOOL)isVersionUpdated;

- (BOOL)isCurrentVersion;

@end
