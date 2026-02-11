/*
 *  Copyright (c) 2023 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "UITemplateExternalCall.h"

#import <Utils/NSString+Utils.h>

//
// Interface: UITemplateExternalCall ()
//

@interface UITemplateExternalCall ()

@property (nonatomic) NSString *name;
@property (nonatomic) NSString *placeholder;
@property (nonatomic) UIImage *image;
@property (nonatomic) NSString *imageURL;
@property (nonatomic) BOOL allowVoiceCall;
@property (nonatomic) BOOL allowVideoCall;
@property (nonatomic) BOOL allowGroupCall;
@property (nonatomic) BOOL enableSchedule;

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

- (void)initTemplateInformation {
    
    switch (self.templateType) {
        case TemplateExternalCallTypeClassifiedAd:
            self.name = TwinmeLocalizedString(@"template_click_to_call_view_controller_template_classified_ad", nil);
            self.placeholder = TwinmeLocalizedString(@"template_click_to_call_view_controller_template_classified_ad_placeholder", nil);
            self.imageURL = @"https://twin.me/download/click_to_call_sample_classified_ad.jpg";
            self.image = [UIImage imageNamed:@"ClickToCallSampleClassifiedAd"];
            self.enableSchedule = NO;
            self.allowVoiceCall = YES;
            self.allowVideoCall = NO;
            self.allowGroupCall = NO;
            break;
            
        case TemplateExternalCallTypeHelp:
            self.name = TwinmeLocalizedString(@"template_click_to_call_view_controller_template_help", nil);
            self.placeholder = TwinmeLocalizedString(@"template_click_to_call_view_controller_template_help_placeholder", nil);
            self.imageURL = @"https://twin.me/download/click_to_call_sample_help.jpg";
            self.image = [UIImage imageNamed:@"ClickToCallSampleHelp"];
            self.enableSchedule = NO;
            self.allowVoiceCall = YES;
            self.allowVideoCall = NO;
            self.allowGroupCall = NO;
            break;
            
        case TemplateExternalCallTypeMeeting:
            self.name = TwinmeLocalizedString(@"template_click_to_call_view_controller_template_meeting", nil);
            self.placeholder = TwinmeLocalizedString(@"template_click_to_call_view_controller_template_meeting_placeholder", nil);
            self.imageURL = @"https://twin.me/download/click_to_call_sample_meeting.jpg";
            self.image = [UIImage imageNamed:@"ClickToCallSampleMeeting"];
            self.enableSchedule = YES;
            self.allowVoiceCall = YES;
            self.allowVideoCall = YES;
            self.allowGroupCall = YES;
            break;
            
        case TemplateExternalCallTypeVideoBell:
            self.name = TwinmeLocalizedString(@"template_click_to_call_view_controller_template_video_bell", nil);
            self.placeholder = TwinmeLocalizedString(@"template_click_to_call_view_controller_template_video_bell_placeholder", nil);
            self.imageURL = @"https://twin.me/download/click_to_call_sample_video_bell.jpg";
            self.image = [UIImage imageNamed:@"ClickToCallSampleVideoBell"];
            self.enableSchedule = NO;
            self.allowVoiceCall = YES;
            self.allowVideoCall = YES;
            self.allowGroupCall = NO;
            break;
            
        case TemplateExternalCallTypeOther:
            self.name = TwinmeLocalizedString(@"template_space_view_controller_template_other", nil);
            self.placeholder = TwinmeLocalizedString(@"create_external_call_view_controller_placeholder", nil);
            self.imageURL = nil;
            self.image = nil;
            self.enableSchedule = NO;
            self.allowVoiceCall = YES;
            self.allowVideoCall = YES;
            self.allowGroupCall = NO;
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

- (BOOL)hasSchedule {
 
    return self.enableSchedule;
}


@end
