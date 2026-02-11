/*
 *  Copyright (c) 2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

typedef enum {
    WelcomePartOne,
    WelcomePartTwo,
    WelcomePartThree,
    WelcomePartFour
} WelcomePart;

//
// Interface: UIWelcome
//

@class TLSpaceSettings;

@interface UIWelcome : NSObject

@property (nonatomic) WelcomePart welcomePart;

@property (nonatomic, nullable) TLSpaceSettings *spaceSettings;

- (nonnull instancetype)initWithWelcomePart:(WelcomePart)welcomePart spaceSettings:(nullable TLSpaceSettings *)spaceSettings;

- (nullable UIImage *)getImage;

- (nonnull NSString *)getMessage;

@end
