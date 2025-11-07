/*
 *  Copyright (c) 2023-2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "UIOnboarding.h"

#import <Utils/NSString+Utils.h>

//
// Interface: UIOnboarding ()
//

@interface UIOnboarding ()

@property (nonatomic) NSString *message;
@property (nonatomic) UIImage *image;
@property (nonatomic) BOOL hideActionView;

@end

//
// Implementation: UIOnboarding
//

@implementation UIOnboarding

- (nonnull instancetype)initWithOnboardingType:(OnboardingExternalCall)onboardingType hideActionView:(BOOL)hideActionView {
        
    self = [super init];
    
    if (self) {
        _onboardingType = onboardingType;
        _hideActionView = hideActionView;
        
        [self initOnboardingInformation];
    }
    return self;
}

- (void)initOnboardingInformation {
    
    NSMutableString *message = [[NSMutableString alloc] initWithString:@""];
    
    switch (self.onboardingType) {
        case OnboardingExternalCallPartOne:
            [message appendString:TwinmeLocalizedString(@"create_external_call_view_controller_onboarding_part_1_message_1", nil)];
            [message appendString:@"\n\n"];
            [message appendString:TwinmeLocalizedString(@"create_external_call_view_controller_onboarding_part_1_message_2", nil)];
            [message appendString:@"\n\n"];
            [message appendString:@"    • "];
            [message appendString:TwinmeLocalizedString(@"create_external_call_view_controller_onboarding_part_1_message_3", nil)];
            [message appendString:@"\n"];
            [message appendString:@"    • "];
            [message appendString:TwinmeLocalizedString(@"create_external_call_view_controller_onboarding_part_1_message_4", nil)];
            [message appendString:@"\n"];
            [message appendString:@"    • "];
            [message appendString:TwinmeLocalizedString(@"create_external_call_view_controller_onboarding_part_1_message_5", nil)];
            [message appendString:@"\n"];
            [message appendString:@"    • "];
            [message appendString:TwinmeLocalizedString(@"create_external_call_view_controller_onboarding_part_1_message_6", nil)];
            self.image = [UIImage imageNamed:@"OnboardingClickToCall"];
            break;
            
        case OnboardingExternalCallPartTwo:
            [message appendString:TwinmeLocalizedString(@"create_external_call_view_controller_onboarding_part_2_message_1", nil)];
            [message appendString:@"\n\n"];
            [message appendString:@"    • "];
            [message appendString:TwinmeLocalizedString(@"create_external_call_view_controller_onboarding_part_2_message_2", nil)];
            [message appendString:@"\n"];
            [message appendString:@"    • "];
            [message appendString:TwinmeLocalizedString(@"create_external_call_view_controller_onboarding_part_2_message_3", nil)];
            [message appendString:@"\n"];
            [message appendString:@"    • "];
            [message appendString:TwinmeLocalizedString(@"create_external_call_view_controller_onboarding_part_2_message_4", nil)];
            self.image = [UIImage imageNamed:@"OnboardingClickToCall2"];
            break;
            
        case OnboardingExternalCallPartThree:
            [message appendString:TwinmeLocalizedString(@"create_external_call_view_controller_onboarding_part_3_message_1", nil)];
            [message appendString:@"\n\n"];
            [message appendString:@"    • "];
            [message appendString:TwinmeLocalizedString(@"create_external_call_view_controller_onboarding_part_3_message_2", nil)];
            [message appendString:@"\n"];
            [message appendString:@"    • "];
            [message appendString:TwinmeLocalizedString(@"create_external_call_view_controller_onboarding_part_3_message_3", nil)];
            [message appendString:@"\n"];
            [message appendString:@"    • "];
            [message appendString:TwinmeLocalizedString(@"create_external_call_view_controller_onboarding_part_3_message_4", nil)];
            [message appendString:@"\n"];
            [message appendString:@"    • "];
            [message appendString:TwinmeLocalizedString(@"create_external_call_view_controller_onboarding_part_3_message_5", nil)];
            self.image = [UIImage imageNamed:@"OnboardingClickToCall3"];
            break;
            
        case OnboardingExternalCallPartFour:
            [message appendString:TwinmeLocalizedString(@"create_external_call_view_controller_onboarding_part_4_message_1", nil)];
            [message appendString:@"\n\n"];
            [message appendString:@"    • "];
            [message appendString:TwinmeLocalizedString(@"create_external_call_view_controller_onboarding_part_4_message_2", nil)];
            [message appendString:@"\n"];
            [message appendString:@"    • "];
            [message appendString:TwinmeLocalizedString(@"create_external_call_view_controller_onboarding_part_4_message_3", nil)];
            [message appendString:@"\n\n"];
            [message appendString:TwinmeLocalizedString(@"create_external_call_view_controller_onboarding_part_4_message_4", nil)];
            self.image = [UIImage imageNamed:@"OnboardingClickToCall4"];
            break;
            
        default:
            break;
    }
    
    self.message = message;
}

- (nonnull NSString *)getMessage {
    
    return self.message;
}

- (nullable UIImage *)getImage {
    
    return self.image;;
}

- (BOOL)hideAction {
    
    return self.hideActionView;
}

@end
