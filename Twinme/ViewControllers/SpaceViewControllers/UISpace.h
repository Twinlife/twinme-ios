/*
 *  Copyright (c) 2019-2024 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

//
// Interface: UISpace
//

@class TLSpace;
@class TLSpaceSettings;

@interface UISpace : NSObject

@property (nonatomic) TLSpace *space;
@property (nonatomic) TLSpaceSettings *spaceSettings;
@property (nonatomic) NSString *nameSpace;
@property (nonatomic) NSString *nameProfile;
@property (nonatomic) UIImage *avatar;
@property (nonatomic) UIImage *avatarSpace;
@property (nonatomic) BOOL isCurrentSpace;
@property (nonatomic) BOOL hasNotification;

- (instancetype)initWithSpace:(TLSpace *)space defaultSpaceSettings:(TLSpaceSettings *)defaultSpaceSettings;

- (void)setSpace:(TLSpace *)space defaultSpaceSettings:(TLSpaceSettings *)defaultSpaceSettings;

- (void)updateSpaceSettings:(TLSpace *)space defaultSpaceSettings:(TLSpaceSettings *)defaultSpaceSettings;

- (BOOL)hasProfile;

@end
