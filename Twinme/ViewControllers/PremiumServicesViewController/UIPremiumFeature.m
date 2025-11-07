/*
 *  Copyright (c) 2023-2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "UIPremiumFeature.h"

#import "UIPremiumFeatureDetail.h"

#import <Utils/NSString+Utils.h>
#import <TwinmeCommon/ApplicationDelegate.h>
#import <TwinmeCommon/TwinmeApplication.h>

//
// Implementation: UIExport
//

@implementation UIPremiumFeature

- (nonnull instancetype)initWithFeatureType:(FeatureType)featureType {
    
    self = [super init];
    
    if (self) {
        _featureType = featureType;
        _featureDetails = [[NSMutableArray alloc]init];
        [self initFeatureDetails];
    }
    return self;
}

- (nonnull NSString *)getTitle {
    
    NSString *title = @"";
    
    switch (self.featureType) {
        case FeatureTypeClickToCall:
            title = TwinmeLocalizedString(@"premium_services_view_controller_click_to_call_title", nil);
            break;
            
        case FeatureTypeConversation:
            title = TwinmeLocalizedString(@"premium_services_view_controller_conversation_title", nil);
            break;
            
        case FeatureTypeGroupCall:
            title = TwinmeLocalizedString(@"premium_services_view_controller_group_call_title", nil);
            break;
            
        case FeatureTypePrivacy:
            title = TwinmeLocalizedString(@"premium_services_view_controller_privacy_title", nil);
            break;
            
        case FeatureTypeSpaces:
            title = TwinmeLocalizedString(@"premium_services_view_controller_space_title", nil);
            break;
            
        case FeatureTypeStreaming:
            title = TwinmeLocalizedString(@"premium_services_view_controller_streaming_title", nil);
            break;
            
        case FeatureTypeTransfertCall:
            title = TwinmeLocalizedString(@"premium_services_view_controller_transfert_title", nil);
            break;
            
        case FeatureTypeRemoteControl:
            title = TwinmeLocalizedString(@"premium_services_view_controller_camera_control_title", nil);
            break;
            
        default:
            break;
    }
    
    return title;
}

- (nonnull NSString *)getSubTitle {
    
    NSString *subTitle = @"";
    
    switch (self.featureType) {
        case FeatureTypeClickToCall:
            subTitle = TwinmeLocalizedString(@"premium_services_view_controller_click_to_call_subtitle", nil);
            break;
            
        case FeatureTypeConversation:
            subTitle = TwinmeLocalizedString(@"premium_services_view_controller_conversation_subtitle", nil);
            break;
            
        case FeatureTypeGroupCall:
            subTitle = TwinmeLocalizedString(@"premium_services_view_controller_group_call_subtitle", nil);
            break;
            
        case FeatureTypePrivacy:
            subTitle = TwinmeLocalizedString(@"premium_services_view_controller_privacy_subtitle", nil);
            break;
            
        case FeatureTypeSpaces:
            subTitle = TwinmeLocalizedString(@"premium_services_view_controller_space_subtitle", nil);
            break;
            
        case FeatureTypeStreaming:
            subTitle = TwinmeLocalizedString(@"premium_services_view_controller_streaming_subtitle", nil);
            break;
            
        case FeatureTypeTransfertCall:
            subTitle = TwinmeLocalizedString(@"premium_services_view_controller_transfert_subtitle", nil);
            break;
            
        case FeatureTypeRemoteControl:
            subTitle = TwinmeLocalizedString(@"premium_services_view_controller_camera_control_subtitle", nil);
            break;
            
        default:
            break;
    }
    
    return subTitle;
}

- (UIImage *)getImage {

    ApplicationDelegate *delegate = (ApplicationDelegate *)[[UIApplication sharedApplication] delegate];
    TwinmeApplication *twinmeApplication = [delegate twinmeApplication];
     
    BOOL darkMode = [twinmeApplication darkModeEnable];
    
    UIImage *featureImage;
    switch (self.featureType) {
        case FeatureTypeClickToCall:
            featureImage = darkMode ? [UIImage imageNamed:@"PremiumFeatureClickToCallDark"]:[UIImage imageNamed:@"PremiumFeatureClickToCall"];
            break;
            
        case FeatureTypeConversation:
            featureImage = darkMode ? [UIImage imageNamed:@"PremiumFeatureConversationDark"]:[UIImage imageNamed:@"PremiumFeatureConversation"];
            break;
            
        case FeatureTypeGroupCall:
            featureImage = darkMode ? [UIImage imageNamed:@"PremiumFeatureGroupCallDark"]:[UIImage imageNamed:@"PremiumFeatureGroupCall"];
            break;
            
        case FeatureTypePrivacy:
            featureImage = darkMode ? [UIImage imageNamed:@"PremiumFeaturePrivacyDark"]:[UIImage imageNamed:@"PremiumFeaturePrivacy"];
            break;
            
        case FeatureTypeSpaces:
            featureImage = darkMode ? [UIImage imageNamed:@"PremiumFeatureSpaceDark"]:[UIImage imageNamed:@"PremiumFeatureSpace"];
            break;
            
        case FeatureTypeStreaming:
            featureImage = darkMode ? [UIImage imageNamed:@"PremiumFeatureStreamingDark"]:[UIImage imageNamed:@"PremiumFeatureStreaming"];
            break;
            
        case FeatureTypeTransfertCall:
            featureImage = [UIImage imageNamed:@"PremiumFeatureTransfertCall"];
            break;
            
        case FeatureTypeRemoteControl:
            featureImage = [UIImage imageNamed:@"OnboardingControlCamera"];
            break;
            
        default:
            break;
    }
    
    return featureImage;
}

- (void)initFeatureDetails {
    
    ApplicationDelegate *delegate = (ApplicationDelegate *)[[UIApplication sharedApplication] delegate];
    TwinmeApplication *twinmeApplication = [delegate twinmeApplication];
     
    BOOL darkMode = [twinmeApplication darkModeEnable];

    switch (self.featureType) {
        case FeatureTypeClickToCall:
            [self.featureDetails addObject:[[UIPremiumFeatureDetail alloc]initWithMessage:TwinmeLocalizedString(@"premium_services_view_controller_click_to_call_description_1", nil) image:darkMode ? [UIImage imageNamed:@"PremiumClickToCallDarkIcon1"]:[UIImage imageNamed:@"PremiumClickToCallIcon1"]]];
            [self.featureDetails addObject:[[UIPremiumFeatureDetail alloc]initWithMessage:TwinmeLocalizedString(@"premium_services_view_controller_click_to_call_description_2", nil) image:darkMode ? [UIImage imageNamed:@"PremiumClickToCallDarkIcon2"]:[UIImage imageNamed:@"PremiumClickToCallIcon2"]]];
            [self.featureDetails addObject:[[UIPremiumFeatureDetail alloc]initWithMessage:TwinmeLocalizedString(@"premium_services_view_controller_click_to_call_description_3", nil) image:darkMode ? [UIImage imageNamed:@"PremiumClickToCallDarkIcon3"]:[UIImage imageNamed:@"PremiumClickToCallIcon3"]]];
            [self.featureDetails addObject:[[UIPremiumFeatureDetail alloc]initWithMessage:TwinmeLocalizedString(@"premium_services_view_controller_click_to_call_description_4", nil) image:darkMode ? [UIImage imageNamed:@"PremiumClickToCallDarkIcon4"]:[UIImage imageNamed:@"PremiumClickToCallIcon4"]]];
            break;
            
        case FeatureTypeConversation:
            [self.featureDetails addObject:[[UIPremiumFeatureDetail alloc]initWithMessage:TwinmeLocalizedString(@"premium_services_view_controller_conversation_description_1", nil) image:darkMode ? [UIImage imageNamed:@"PremiumConversationDarkIcon1"]:[UIImage imageNamed:@"PremiumConversationIcon1"]]];
            [self.featureDetails addObject:[[UIPremiumFeatureDetail alloc]initWithMessage:TwinmeLocalizedString(@"premium_services_view_controller_conversation_description_2", nil) image:darkMode ? [UIImage imageNamed:@"PremiumConversationDarkIcon2"]:[UIImage imageNamed:@"PremiumConversationIcon2"]]];
            [self.featureDetails addObject:[[UIPremiumFeatureDetail alloc]initWithMessage:TwinmeLocalizedString(@"premium_services_view_controller_conversation_description_3", nil) image:darkMode ? [UIImage imageNamed:@"PremiumConversationDarkIcon3"]:[UIImage imageNamed:@"PremiumConversationIcon3"]]];
            [self.featureDetails addObject:[[UIPremiumFeatureDetail alloc]initWithMessage:TwinmeLocalizedString(@"premium_services_view_controller_conversation_description_4", nil) image:darkMode ? [UIImage imageNamed:@"PremiumConversationDarkIcon4"]:[UIImage imageNamed:@"PremiumConversationIcon4"]]];
            break;
            
        case FeatureTypeGroupCall:
            [self.featureDetails addObject:[[UIPremiumFeatureDetail alloc]initWithMessage:TwinmeLocalizedString(@"premium_services_view_controller_group_call_description_1", nil) image:[UIImage imageNamed:@"PremiumGroupCallIcon1"]]];
            [self.featureDetails addObject:[[UIPremiumFeatureDetail alloc]initWithMessage:TwinmeLocalizedString(@"premium_services_view_controller_group_call_description_2", nil) image:darkMode ? [UIImage imageNamed:@"PremiumGroupCallDarkIcon2"]:[UIImage imageNamed:@"PremiumGroupCallIcon2"]]];
            [self.featureDetails addObject:[[UIPremiumFeatureDetail alloc]initWithMessage:TwinmeLocalizedString(@"premium_services_view_controller_group_call_description_3", nil) image:darkMode ? [UIImage imageNamed:@"PremiumGroupCallDarkIcon3"]:[UIImage imageNamed:@"PremiumGroupCallIcon3"]]];
            [self.featureDetails addObject:[[UIPremiumFeatureDetail alloc]initWithMessage:TwinmeLocalizedString(@"premium_services_view_controller_group_call_description_4", nil) image:darkMode ? [UIImage imageNamed:@"PremiumPrivacyDarkIcon1"]:[UIImage imageNamed:@"PremiumPrivacyIcon1"]]];
            break;
            
        case FeatureTypePrivacy:
            [self.featureDetails addObject:[[UIPremiumFeatureDetail alloc]initWithMessage:TwinmeLocalizedString(@"premium_services_view_controller_privacy_description_1", nil) image:darkMode ? [UIImage imageNamed:@"PremiumPrivacyDarkIcon1"]:[UIImage imageNamed:@"PremiumPrivacyIcon1"]]];
            [self.featureDetails addObject:[[UIPremiumFeatureDetail alloc]initWithMessage:TwinmeLocalizedString(@"premium_services_view_controller_privacy_description_2", nil) image:darkMode ? [UIImage imageNamed:@"PremiumPrivacyDarkIcon2"]:[UIImage imageNamed:@"PremiumPrivacyIcon2"]]];
            [self.featureDetails addObject:[[UIPremiumFeatureDetail alloc]initWithMessage:TwinmeLocalizedString(@"premium_services_view_controller_privacy_description_3", nil) image:darkMode ? [UIImage imageNamed:@"PremiumPrivacyDarkIcon3"]:[UIImage imageNamed:@"PremiumPrivacyIcon3"]]];
            [self.featureDetails addObject:[[UIPremiumFeatureDetail alloc]initWithMessage:TwinmeLocalizedString(@"premium_services_view_controller_privacy_description_4", nil) image:darkMode ? [UIImage imageNamed:@"PremiumPrivacyDarkIcon4"]:[UIImage imageNamed:@"PremiumPrivacyIcon4"]]];
            break;
            
        case FeatureTypeSpaces:
            [self.featureDetails addObject:[[UIPremiumFeatureDetail alloc]initWithMessage:TwinmeLocalizedString(@"premium_services_view_controller_space_description_1", nil) image:darkMode ? [UIImage imageNamed:@"PremiumSpaceDarkIcon1"]:[UIImage imageNamed:@"PremiumSpaceIcon1"]]];
            [self.featureDetails addObject:[[UIPremiumFeatureDetail alloc]initWithMessage:TwinmeLocalizedString(@"premium_services_view_controller_space_description_2", nil) image:darkMode ? [UIImage imageNamed:@"PremiumSpaceDarkIcon2"]:[UIImage imageNamed:@"PremiumSpaceIcon2"]]];
            [self.featureDetails addObject:[[UIPremiumFeatureDetail alloc]initWithMessage:TwinmeLocalizedString(@"premium_services_view_controller_space_description_3", nil) image:darkMode ? [UIImage imageNamed:@"PremiumSpaceDarkIcon3"]:[UIImage imageNamed:@"PremiumSpaceIcon3"]]];
            [self.featureDetails addObject:[[UIPremiumFeatureDetail alloc]initWithMessage:TwinmeLocalizedString(@"premium_services_view_controller_space_description_4", nil) image:darkMode ? [UIImage imageNamed:@"PremiumSpaceDarkIcon4"]:[UIImage imageNamed:@"PremiumSpaceIcon4"]]];
            break;
            
        case FeatureTypeStreaming:
            [self.featureDetails addObject:[[UIPremiumFeatureDetail alloc]initWithMessage:TwinmeLocalizedString(@"premium_services_view_controller_streaming_description_1", nil) image:darkMode ? [UIImage imageNamed:@"PremiumStreamingDarkIcon1"]:[UIImage imageNamed:@"PremiumStreamingIcon1"]]];
            [self.featureDetails addObject:[[UIPremiumFeatureDetail alloc]initWithMessage:TwinmeLocalizedString(@"premium_services_view_controller_streaming_description_2", nil) image:darkMode ? [UIImage imageNamed:@"PremiumStreamingDarkIcon2"]:[UIImage imageNamed:@"PremiumStreamingIcon2"]]];
            [self.featureDetails addObject:[[UIPremiumFeatureDetail alloc]initWithMessage:TwinmeLocalizedString(@"premium_services_view_controller_streaming_description_3", nil) image:darkMode ? [UIImage imageNamed:@"PremiumStreamingDarkIcon3"]:[UIImage imageNamed:@"PremiumStreamingIcon3"]]];
            [self.featureDetails addObject:[[UIPremiumFeatureDetail alloc]initWithMessage:TwinmeLocalizedString(@"premium_services_view_controller_streaming_description_4", nil) image:darkMode ? [UIImage imageNamed:@"PremiumStreamingDarkIcon4"]:[UIImage imageNamed:@"PremiumStreamingIcon4"]]];
            break;
            
        case FeatureTypeTransfertCall:
            [self.featureDetails addObject:[[UIPremiumFeatureDetail alloc]initWithMessage:TwinmeLocalizedString(@"premium_services_view_controller_transfert_description_1", nil) image:darkMode ? [UIImage imageNamed:@"PremiumTransfertCallDarkIcon1"]:[UIImage imageNamed:@"PremiumTransfertCallIcon1"]]];
            [self.featureDetails addObject:[[UIPremiumFeatureDetail alloc]initWithMessage:TwinmeLocalizedString(@"premium_services_view_controller_transfert_description_2", nil) image:darkMode ? [UIImage imageNamed:@"PremiumTransfertCallDarkIcon2"]:[UIImage imageNamed:@"PremiumTransfertCallIcon2"]]];
            [self.featureDetails addObject:[[UIPremiumFeatureDetail alloc]initWithMessage:TwinmeLocalizedString(@"premium_services_view_controller_transfert_description_3", nil) image:darkMode ? [UIImage imageNamed:@"PremiumTransfertCallDarkIcon3"]:[UIImage imageNamed:@"PremiumTransfertCallIcon3"]]];
            [self.featureDetails addObject:[[UIPremiumFeatureDetail alloc]initWithMessage:TwinmeLocalizedString(@"premium_services_view_controller_transfert_description_4", nil) image:darkMode ? [UIImage imageNamed:@"PremiumTransfertCallDarkIcon4"]:[UIImage imageNamed:@"PremiumTransfertCallIcon4"]]];
            break;
            
        case FeatureTypeRemoteControl:
            [self.featureDetails addObject:[[UIPremiumFeatureDetail alloc]initWithMessage:TwinmeLocalizedString(@"premium_services_view_controller_camera_control_description_1", nil) image:darkMode ? [UIImage imageNamed:@"PremiumCameraControlDarkIcon1"]:[UIImage imageNamed:@"PremiumCameraControlIcon1"]]];
            [self.featureDetails addObject:[[UIPremiumFeatureDetail alloc]initWithMessage:TwinmeLocalizedString(@"premium_services_view_controller_camera_control_description_2", nil) image:[UIImage imageNamed:@"PremiumCameraControlIcon2"]]];
            [self.featureDetails addObject:[[UIPremiumFeatureDetail alloc]initWithMessage:TwinmeLocalizedString(@"premium_services_view_controller_camera_control_description_3", nil) image:[UIImage imageNamed:@"PremiumCameraControlIcon3"]]];
            [self.featureDetails addObject:[[UIPremiumFeatureDetail alloc]initWithMessage:TwinmeLocalizedString(@"premium_services_view_controller_camera_control_description_4", nil) image:[UIImage imageNamed:@"PremiumCameraControlIcon4"]]];
            break;
            
        default:
            break;
    }
}

@end
