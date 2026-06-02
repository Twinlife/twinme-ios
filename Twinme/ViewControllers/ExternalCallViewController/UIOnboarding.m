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

@property (nonatomic, nullable) NSString *title;
@property (nonatomic) NSString *message;
@property (nonatomic, nullable) UIImage *image;
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
            [message appendString:TwinmeLocalizedString(@"create_external_call_view_onboarding_part_1_message_1", nil)];
            [message appendString:@"\n\n"];
            [message appendString:TwinmeLocalizedString(@"create_external_call_view_onboarding_part_1_message_2", nil)];
            [message appendString:@"\n\n"];
            [message appendString:@"    • "];
            [message appendString:TwinmeLocalizedString(@"create_external_call_view_onboarding_part_1_message_3", nil)];
            [message appendString:@"\n"];
            [message appendString:@"    • "];
            [message appendString:TwinmeLocalizedString(@"create_external_call_view_onboarding_part_1_message_4", nil)];
            [message appendString:@"\n"];
            [message appendString:@"    • "];
            [message appendString:TwinmeLocalizedString(@"create_external_call_view_onboarding_part_1_message_5", nil)];
            [message appendString:@"\n"];
            [message appendString:@"    • "];
            [message appendString:TwinmeLocalizedString(@"create_external_call_view_onboarding_part_1_message_6", nil)];
            self.image = [UIImage imageNamed:@"OnboardingClickToCall"];
            self.title = nil;
            break;
            
        case OnboardingExternalCallPartTwo:
            [message appendString:TwinmeLocalizedString(@"create_external_call_view_onboarding_part_2_message_1", nil)];
            [message appendString:@"\n\n"];
            [message appendString:@"    • "];
            [message appendString:TwinmeLocalizedString(@"create_external_call_view_onboarding_part_2_message_2", nil)];
            [message appendString:@"\n"];
            [message appendString:@"    • "];
            [message appendString:TwinmeLocalizedString(@"create_external_call_view_onboarding_part_2_message_3", nil)];
            [message appendString:@"\n"];
            [message appendString:@"    • "];
            [message appendString:TwinmeLocalizedString(@"create_external_call_view_onboarding_part_2_message_4", nil)];
            self.image = [UIImage imageNamed:@"OnboardingClickToCall2"];
            self.title = TwinmeLocalizedString(@"create_external_call_view_onboarding_title_2", nil);
            break;
            
        case OnboardingExternalCallPartThree:
            [message appendString:TwinmeLocalizedString(@"create_external_call_view_onboarding_part_3_message_1", nil)];
            [message appendString:@"\n\n"];
            [message appendString:@"    • "];
            [message appendString:TwinmeLocalizedString(@"create_external_call_view_onboarding_part_3_message_2", nil)];
            [message appendString:@"\n"];
            [message appendString:@"    • "];
            [message appendString:TwinmeLocalizedString(@"create_external_call_view_onboarding_part_3_message_3", nil)];
            [message appendString:@"\n"];
            [message appendString:@"    • "];
            [message appendString:TwinmeLocalizedString(@"create_external_call_view_onboarding_part_3_message_4", nil)];
            [message appendString:@"\n"];
            [message appendString:@"    • "];
            [message appendString:TwinmeLocalizedString(@"create_external_call_view_onboarding_part_3_message_5", nil)];
            self.image = [UIImage imageNamed:@"OnboardingClickToCall3"];
            self.title = TwinmeLocalizedString(@"create_external_call_view_onboarding_title_3", nil);
            break;
            
        case OnboardingExternalCallPartFour:
            [message appendString:TwinmeLocalizedString(@"create_external_call_view_onboarding_part_4_message_1", nil)];
            [message appendString:@"\n\n"];
            [message appendString:@"    • "];
            [message appendString:TwinmeLocalizedString(@"create_external_call_view_onboarding_part_4_message_2", nil)];
            [message appendString:@"\n"];
            [message appendString:@"    • "];
            [message appendString:TwinmeLocalizedString(@"create_external_call_view_onboarding_part_4_message_3", nil)];
            [message appendString:@"\n\n"];
            [message appendString:TwinmeLocalizedString(@"create_external_call_view_onboarding_part_4_message_4", nil)];
            self.image = [UIImage imageNamed:@"OnboardingClickToCall4"];
            self.title = TwinmeLocalizedString(@"create_external_call_view_onboarding_title_4", nil);
            break;
            
        default:
            break;
    }
    
    self.message = message;
}

- (nullable NSString *)getTitle {
    
    return self.title;
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
