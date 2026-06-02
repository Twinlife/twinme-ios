/*
 *  Copyright (c) 2023-2026 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "UITemplateExternalCall.h"

#import <Utils/NSString+Utils.h>

#import <Twinme/TLTimeRange.h>

//
// Interface: UITemplateExternalCall ()
//

@interface UITemplateExternalCall ()

@property (nonatomic) NSString *name;
@property (nonatomic) NSString *placeholder;
@property (nonatomic, nullable) NSString *message;
@property (nonatomic) UIImage *image;
@property (nonatomic) NSString *imageURL;
@property (nonatomic) BOOL allowVoiceCall;
@property (nonatomic) BOOL allowVideoCall;
@property (nonatomic) BOOL allowGroupCall;
@property (nonatomic) TLLinkValidity linkValidity;
@property (nonatomic) ConfigExternalCallTypeCall typeCall;
@property (nonatomic, nullable) TLTime *scheduleStartTime;
@property (nonatomic, nullable) TLTime *scheduleEndTime;
@property (nonatomic, nullable) NSArray *scheduleRecurrentDays;

@end

//
// Implementation: UITemplateExternalCall
//

@implementation UITemplateExternalCall

- (nonnull instancetype)initWithTemplateType:(TemplateExternalCallType)templateType {
        
    self = [super init];
    
    if (self) {
        _templateType = templateType;
        
        [self initTemplateInformation];
    }
    return self;
}

- (void)updateName:(nonnull NSString *)name image:(nonnull UIImage *)image {
    
    self.name = name;
    self.image = image;
}

- (void)initTemplateInformation {
    
    switch (self.templateType) {
        case TemplateExternalCallTypeClassifiedAd:
            self.name = TwinmeLocalizedString(@"template_click_to_call_view_template_classified_ad", nil);
            self.placeholder = TwinmeLocalizedString(@"template_click_to_call_view_template_classified_ad_placeholder", nil);
            self.message = TwinmeLocalizedString(@"template_click_to_call_view_template_classified_ad_description", nil);
            self.imageURL = @"https://twin.me/download/click_to_call_sample_classified_ad_2026.jpg";
            self.image = [UIImage imageNamed:@"ClickToCallSampleClassifiedAd"];
            self.typeCall = ConfigExternalCallTypeCallDirect;
            self.linkValidity = TLLinkValidityPermanent;
            self.allowVoiceCall = YES;
            self.allowVideoCall = NO;
            self.allowGroupCall = NO;
            self.scheduleRecurrentDays = nil;
            self.scheduleStartTime = nil;
            self.scheduleEndTime = nil;
            break;
            
        case TemplateExternalCallTypeJob:
            self.name = TwinmeLocalizedString(@"template_click_to_call_view_template_job", nil);
            self.placeholder = TwinmeLocalizedString(@"template_click_to_call_view_template_job_placeholder", nil);
            self.message = TwinmeLocalizedString(@"template_click_to_call_view_template_job_description", nil);
            self.imageURL = @"https://twin.me/download/click_to_call_sample_job_2026.jpg";
            self.image = [UIImage imageNamed:@"ClickToCallSampleJob"];
            self.typeCall = ConfigExternalCallTypeCallDirect;
            self.linkValidity = TLLinkValidityPermanent;
            self.allowVoiceCall = YES;
            self.allowVideoCall = NO;
            self.allowGroupCall = NO;
            self.scheduleRecurrentDays = nil;
            self.scheduleStartTime = nil;
            self.scheduleEndTime = nil;
            break;
            
        case TemplateExternalCallTypeHelp:
            self.name = TwinmeLocalizedString(@"template_click_to_call_view_template_help", nil);
            self.placeholder = TwinmeLocalizedString(@"template_click_to_call_view_template_help_placeholder", nil);
            self.message = TwinmeLocalizedString(@"template_click_to_call_view_template_help_description", nil);
            self.imageURL = @"https://twin.me/download/click_to_call_sample_help_2026.jpg";
            self.image = [UIImage imageNamed:@"ClickToCallSampleHelp"];
            self.typeCall = ConfigExternalCallTypeCallDirect;
            self.linkValidity = TLLinkValidityPeriodic;
            self.allowVoiceCall = YES;
            self.allowVideoCall = NO;
            self.allowGroupCall = NO;
            self.scheduleRecurrentDays = @[[NSNumber numberWithInt:MONDAY], [NSNumber numberWithInt:TUESDAY], [NSNumber numberWithInt:WEDNESDAY], [NSNumber numberWithInt:THURSDAY], [NSNumber numberWithInt:FRIDAY]];
            self.scheduleStartTime = [[TLTime alloc] initWithTimeString:@"10:00"];
            self.scheduleEndTime = [[TLTime alloc] initWithTimeString:@"18:00"];
            break;
            
        case TemplateExternalCallTypeMeeting:
            self.name = TwinmeLocalizedString(@"template_click_to_call_view_template_meeting", nil);
            self.placeholder = TwinmeLocalizedString(@"template_click_to_call_view_template_meeting_placeholder", nil);
            self.message = TwinmeLocalizedString(@"template_click_to_call_view_template_meeting_description", nil);
            self.imageURL = @"https://twin.me/download/click_to_call_sample_meeting_2026.jpg";
            self.image = [UIImage imageNamed:@"ClickToCallSampleMeeting"];
            self.typeCall = ConfigExternalCallTypeCallConference;
            self.linkValidity = TLLinkValiditySingleUse;
            self.allowVoiceCall = YES;
            self.allowVideoCall = YES;
            self.allowGroupCall = YES;
            self.scheduleRecurrentDays = nil;
            self.scheduleStartTime = nil;
            self.scheduleEndTime = nil;
            break;
            
        case TemplateExternalCallTypeVideoBell:
            self.name = TwinmeLocalizedString(@"template_click_to_call_view_template_video_bell", nil);
            self.placeholder = TwinmeLocalizedString(@"template_click_to_call_view_template_video_bell_placeholder", nil);
            self.message = TwinmeLocalizedString(@"template_click_to_call_view_template_video_bell_description", nil);
            self.imageURL = @"https://twin.me/download/click_to_call_sample_video_bell.jpg";
            self.image = [UIImage imageNamed:@"ClickToCallSampleVideoBell"];
            self.typeCall = ConfigExternalCallTypeCallDirect;
            self.linkValidity = TLLinkValidityPermanent;
            self.allowVoiceCall = YES;
            self.allowVideoCall = YES;
            self.allowGroupCall = NO;
            self.scheduleRecurrentDays = nil;
            self.scheduleStartTime = nil;
            self.scheduleEndTime = nil;
            break;
            
        case TemplateExternalCallTypeOther:
            self.name = TwinmeLocalizedString(@"premium_services_view_click_to_call_title", nil);
            self.placeholder = TwinmeLocalizedString(@"create_external_call_view_placeholder", nil);
            self.message = TwinmeLocalizedString(@"template_click_to_call_view_template_default_description", nil);
            self.imageURL = nil;
            self.image = nil;
            self.typeCall = ConfigExternalCallTypeCallDirect;
            self.linkValidity = TLLinkValidityPermanent;
            self.allowVoiceCall = YES;
            self.allowVideoCall = YES;
            self.allowGroupCall = NO;
            self.scheduleRecurrentDays = nil;
            self.scheduleStartTime = nil;
            self.scheduleEndTime = nil;
            break;
            
        case TemplateExternalCallTypeProfile:
            self.name = TwinmeLocalizedString(@"premium_services_view_click_to_call_title", nil);
            self.placeholder = TwinmeLocalizedString(@"create_external_call_view_placeholder", nil);
            self.message = TwinmeLocalizedString(@"template_click_to_call_view_template_profile_description", nil);
            self.imageURL = nil;
            self.image = nil;
            self.typeCall = ConfigExternalCallTypeCallDirect;
            self.linkValidity = TLLinkValidityPermanent;
            self.allowVoiceCall = YES;
            self.allowVideoCall = YES;
            self.allowGroupCall = NO;
            self.scheduleRecurrentDays = nil;
            self.scheduleStartTime = nil;
            self.scheduleEndTime = nil;
            break;
            
        default:
            
            break;
    }
}

- (nonnull NSString *)getName {
    
    return self.name;
}

- (nonnull NSString *)getPlaceholder {
    
    return self.placeholder;
}

- (nullable NSString *)getMessage {
    
    return self.message;
}

- (nullable UIImage *)getImage {
    
    return self.image;;
}

- (nullable NSString *)getImageUrl {
    
    return self.imageURL;
}

- (BOOL)voiceCallAllowed {
    
    return self.allowVoiceCall;
}

- (BOOL)videoCallAllowed {
    
    return self.allowVideoCall;
}

- (BOOL)groupCallAllowed {
    
    return self.allowGroupCall;
}

- (TLLinkValidity)validity {
 
    return self.linkValidity;
}

- (ConfigExternalCallTypeCall)configTypeCall {
 
    return self.typeCall;
}

- (nullable NSArray *)getScheduleRecurrentDays {
    
    return self.scheduleRecurrentDays;
}

- (nonnull TLTime *)getScheduleStartTime {
    
    return self.scheduleStartTime;
}

- (nonnull TLTime *)getScheduleEndTime {
    
    return self.scheduleEndTime;
}

@end
