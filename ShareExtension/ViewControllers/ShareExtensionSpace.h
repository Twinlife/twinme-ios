/*
 *  Copyright (c) 2021-2024 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <UIKit/UIKit.h>

#import <Twinme/TLSpace.h>

@interface ShareExtensionSpace : NSObject

@property (nonatomic) TLSpace *space;
@property (nonatomic) NSString *nameSpace;
@property (nonatomic) UIImage *avatarSpace;
@property (nonatomic) BOOL isCurrentSpace;

- (instancetype)initWithSpace:(TLSpace *)space;

- (void)setSpace:(TLSpace *)space;

- (void)updateAvatar:(UIImage *)avatar;

@end
