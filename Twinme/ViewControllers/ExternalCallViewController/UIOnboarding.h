/*
 *  Copyright (c) 2023-2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

typedef enum {
    OnboardingExternalCallPartOne,
    OnboardingExternalCallPartTwo,
    OnboardingExternalCallPartThree,
    OnboardingExternalCallPartFour
} OnboardingExternalCall;

//
// Interface: UIOnboarding
//

@interface UIOnboarding : NSObject

@property (nonatomic) OnboardingExternalCall onboardingType;

- (nonnull instancetype)initWithOnboardingType:(OnboardingExternalCall)onboardingType hideActionView:(BOOL)hideActionView;

- (nullable UIImage *)getImage;

- (nonnull NSString *)getMessage;

- (BOOL)hideAction;

@end
