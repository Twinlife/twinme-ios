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

@interface UIWelcome : NSObject

@property (nonatomic) WelcomePart welcomePart;

- (nonnull instancetype)initWithWelcomePart:(WelcomePart)welcomePart;

- (nullable UIImage *)getImage;

- (nonnull NSString *)getMessage;

@end
