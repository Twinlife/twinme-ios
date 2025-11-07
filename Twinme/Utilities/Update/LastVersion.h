/*
 *  Copyright (c) 2021-2022 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

@interface LastVersion : NSObject

@property (nullable) NSString *versionNumber;
@property (nullable) NSMutableArray *updateImages;
@property (nullable) NSMutableArray *updateImagesDark;
@property (nullable) NSMutableArray *minorChanges;
@property (nullable) NSMutableArray *majorChanges;
@property NSOperatingSystemVersion minOsVersion;
@property NSOperatingSystemVersion version;

- (nonnull NSString *)getMajorChanges;

- (nonnull NSString *)getMinorChanges;

@end
