/*
 *  Copyright (c) 2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "UIWelcome.h"

#import <Utils/NSString+Utils.h>

#import <TwinmeCommon/ApplicationDelegate.h>
#import <TwinmeCommon/TwinmeApplication.h>

//
// Interface: UIWelcome ()
//

@interface UIWelcome ()

@property (nonatomic) NSString *message;
@property (nonatomic) UIImage *image;

@end

//
// Implementation: UIWelcome
//

@implementation UIWelcome

- (nonnull instancetype)initWithWelcomePart:(WelcomePart)welcomePart {
        
    self = [super init];
    
    if (self) {
        _welcomePart = welcomePart;
        
        [self initWelcomePart];
    }
    return self;
}

- (void)initWelcomePart {
    
    ApplicationDelegate *delegate = (ApplicationDelegate *)[[UIApplication sharedApplication] delegate];
    TwinmeApplication *twinmeApplication = [delegate twinmeApplication];
     
    BOOL darkMode = [twinmeApplication darkModeEnable];
    
    switch (self.welcomePart) {
        case WelcomePartOne:
            self.message = TwinmeLocalizedString(@"welcome_view_controller_step1_message", nil);
            self.image = darkMode ? [UIImage imageNamed:@"OnboardingStep1Dark"] : [UIImage imageNamed:@"OnboardingStep1"];;
            break;
            
        case WelcomePartTwo:
            self.message = TwinmeLocalizedString(@"welcome_view_controller_step2_message", nil);
            self.image = darkMode ? [UIImage imageNamed:@"OnboardingStep2Dark"] : [UIImage imageNamed:@"OnboardingStep2"];
            break;
            
        case WelcomePartThree:
            self.message = TwinmeLocalizedString(@"welcome_view_controller_step3_message", nil);
            self.image = darkMode ? [UIImage imageNamed:@"OnboardingStep3Dark"] : [UIImage imageNamed:@"OnboardingStep3"];
            break;
            
        case WelcomePartFour:
            self.message = TwinmeLocalizedString(@"quality_of_services_view_controller_step2_message", nil);
            self.image = darkMode ? [UIImage imageNamed:@"QualityServiceStep2Dark"]:[UIImage imageNamed:@"QualityServiceStep2"];
            break;
                        
        default:
            break;
    }
}

- (nonnull NSString *)getMessage {
    
    return self.message;
}

- (nullable UIImage *)getImage {
    
    return self.image;
}

@end
