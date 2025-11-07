/*
 *  Copyright (c) 2023 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "UITemplateSpace.h"

#import <Utils/NSString+Utils.h>
#import "UIColor+Hex.h"

//
// Interface: UITemplateSpace ()
//

@interface UITemplateSpace ()

@property (nonatomic) NSString *space;
@property (nonatomic) NSString *profile;
@property (nonatomic) NSString *profilePlaceholder;
@property (nonatomic) UIImage *image;
@property (nonatomic) NSString *imageURL;
@property (nonatomic) NSString *color;

@end

//
// Implementation: UITemplateSpace
//

@implementation UITemplateSpace

- (nonnull instancetype)initWithTemplateType:(TemplateType)templateType {
        
    self = [super init];
    
    if (self) {
        _templateType = templateType;
        
        [self initTemplateInformation];
    }
    return self;
}

- (void)initTemplateInformation {
    
    switch (self.templateType) {
        case TemplateTypeBusiness1:
            self.space = TwinmeLocalizedString(@"spaces_view_controller_sample_business", nil);
            self.profile = TwinmeLocalizedString(@"spaces_view_controller_sample_business_name", nil);
            self.profilePlaceholder = TwinmeLocalizedString(@"template_space_view_controller_template_business_placeholder", nil);
            self.imageURL = @"https://skred.mobi/download/space_sample_business_2.jpg";
            self.image = [UIImage imageNamed:@"SpaceSampleBusiness2"];
            self.color = @"#4B90E2";
            break;
            
            
        case TemplateTypeBusiness2:
            self.space = TwinmeLocalizedString(@"spaces_view_controller_sample_business", nil);
            self.profile = TwinmeLocalizedString(@"template_space_view_controller_template_business_profile", nil);
            self.profilePlaceholder = TwinmeLocalizedString(@"template_space_view_controller_template_business_placeholder", nil);
            self.imageURL = @"https://skred.mobi/download/space_sample_business_3.jpg";
            self.image = [UIImage imageNamed:@"SpaceSampleBusiness3"];
            self.color = @"#9DDBED";
            break;
            
        case TemplateTypeFamily1:
            self.space = TwinmeLocalizedString(@"spaces_view_controller_sample_family", nil);
            self.profile = TwinmeLocalizedString(@"spaces_view_controller_sample_family_name", nil);
            self.profilePlaceholder = TwinmeLocalizedString(@"template_space_view_controller_template_family_placeholder", nil);
            self.imageURL = @"https://skred.mobi/download/space_sample_family_2.jpg";
            self.image = [UIImage imageNamed:@"SpaceSampleFamily2"];
            self.color = @"#89AC8F";
            break;
            
        case TemplateTypeFamily2:
            self.space = TwinmeLocalizedString(@"spaces_view_controller_sample_family", nil);
            self.profile = TwinmeLocalizedString(@"template_space_view_controller_template_family_profile", nil);
            self.profilePlaceholder = TwinmeLocalizedString(@"template_space_view_controller_template_family_placeholder", nil);
            self.imageURL = @"https://skred.mobi/download/space_sample_family_3.jpg";
            self.image = [UIImage imageNamed:@"SpaceSampleFamily3"];
            self.color = @"#E99616";
            break;
            
        case TemplateTypeFriends1:
            self.space = TwinmeLocalizedString(@"spaces_view_controller_sample_friends", nil);
            self.profile = TwinmeLocalizedString(@"spaces_view_controller_sample_friends_name", nil);
            self.profilePlaceholder = TwinmeLocalizedString(@"template_space_view_controller_template_friends_placeholder", nil);
            self.imageURL = @"https://skred.mobi/download/space_sample_friends_2.jpg";
            self.image = [UIImage imageNamed:@"SpaceSampleFriends2"];
            self.color = @"#F0CB26";
            break;
            
        case TemplateTypeFriends2:
            self.space = TwinmeLocalizedString(@"spaces_view_controller_sample_friends", nil);
            self.profile = TwinmeLocalizedString(@"template_space_view_controller_template_friends_profile", nil);
            self.profilePlaceholder = TwinmeLocalizedString(@"template_space_view_controller_template_friends_placeholder", nil);
            self.imageURL = @"https://skred.mobi/download/space_sample_friends_3.jpg";
            self.image = [UIImage imageNamed:@"SpaceSampleFriends3"];
            self.color = @"#EBBDBF";
            break;
            
        case TemplateTypeOther:
            self.space = TwinmeLocalizedString(@"template_space_view_controller_template_other", nil);
            self.profile = nil;
            self.profilePlaceholder = TwinmeLocalizedString(@"template_space_view_controller_template_other_placeholder", nil);
            self.imageURL = nil;
            self.image = nil;
            self.color = nil;
            break;
            
        default:
            
            break;
    }
}

- (nonnull NSString *)getSpace {
    
    return self.space;
}

- (nullable NSString *)getProfile {
    
    return self.profile;
}

- (nonnull NSString *)getProfilePlaceholder {
    
    return self.profilePlaceholder;
}

- (nullable UIImage *)getImage {
    
    return self.image;;
}

- (nullable NSString *)getImageUrl {
    
    return self.imageURL;
}

- (nullable NSString *)getColor {
    
    return self.color;
}

@end
