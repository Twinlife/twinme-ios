/*
 *  Copyright (c) 2024 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "UIQuality.h"

#import <Twinme/TLSpace.h>
#import <Twinme/TLSpaceSettings.h>

#import <Utils/NSString+Utils.h>

#import <TwinmeCommon/ApplicationDelegate.h>
#import <TwinmeCommon/TwinmeApplication.h>

//
// Interface: UIQuality ()
//

@interface UIQuality ()

@property (nonatomic) NSString *message;
@property (nonatomic) UIImage *image;

@end

//
// Implementation: UIOnboarding
//

@implementation UIQuality

- (nonnull instancetype)initWithQualityOfServicesPart:(QualityOfServicesPart)qualityOfServicesPart spaceSettings:(nullable TLSpaceSettings *)spaceSettings {
        
    self = [super init];
    
    if (self) {
        _qualityOfServicesPart = qualityOfServicesPart;
        _spaceSettings = spaceSettings;
        
        [self initQualityOfServicesInformation];
    }
    return self;
}

- (void)initQualityOfServicesInformation {
    
    ApplicationDelegate *delegate = (ApplicationDelegate *)[[UIApplication sharedApplication] delegate];
    TwinmeApplication *twinmeApplication = [delegate twinmeApplication];
     
    BOOL darkMode = [twinmeApplication darkModeEnable:self.spaceSettings];
    
    switch (self.qualityOfServicesPart) {
        case QualityOfServicesPartOne:
            self.message = TwinmeLocalizedString(@"quality_of_services_view_controller_step1_message", nil);
            self.image = darkMode ? [UIImage imageNamed:@"OnboardingStep2Dark"]:[UIImage imageNamed:@"OnboardingStep2"];
            break;
            
        case QualityOfServicesPartTwo:
            self.message = TwinmeLocalizedString(@"quality_of_services_view_controller_step2_message", nil);
            self.image = darkMode ? [UIImage imageNamed:@"QualityServiceStep2Dark"]:[UIImage imageNamed:@"QualityServiceStep2"];
            break;
            
        case QualityOfServicesPartThree:
            self.message = TwinmeLocalizedString(@"quality_of_services_view_controller_step3_message", nil);
            self.image = [UIImage imageNamed:@"QualityServiceStep3"];
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

- (BOOL)hideAction {
    
    return self.qualityOfServicesPart != QualityOfServicesPartTwo;
}

@end
