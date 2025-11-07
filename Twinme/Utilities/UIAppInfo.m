/*
 *  Copyright (c) 2024 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "UIAppInfo.h"

#import <Utils/NSString+Utils.h>

//
// Interface: UIAppInfo ()
//

@interface UIAppInfo ()

@property (nonatomic) NSString *title;
@property (nonatomic) NSString *message;
@property (nonatomic) UIImage *image;
@property (nonatomic) UIColor *color;

@end

//
// Implementation: UIAppInfo
//

@implementation UIAppInfo

- (nonnull instancetype)initWithInfoType:(InfoFloatingViewType)infoFloatingViewType {
    
    self = [super init];
    
    if (self) {
        _infoFloatingViewType = infoFloatingViewType;
        [self initAppInfo];
    }
    return self;
}

- (void)initAppInfo {
        
    switch (self.infoFloatingViewType) {
        case InfoFloatingViewTypeConnected:
            self.title = TwinmeLocalizedString(@"application_connected", nil);
            self.message = @"";
            self.image = [UIImage imageNamed:@"ConnectedIcon"];
            self.color = nil;
            break;
           
        case InfoFloatingViewTypeConnectionInProgress:
            self.title = TwinmeLocalizedString(@"application_not_connected", nil);
            self.message = @"";
            self.image = [UIImage imageNamed:@"NoNetwork"];
            self.color = [UIColor colorWithRed:192./255. green:124./255. blue:65./255. alpha:1.0];
            break;

        case InfoFloatingViewTypeOffline:
            self.title = TwinmeLocalizedString(@"application_connection_status_no_network", nil);
            self.message = TwinmeLocalizedString(@"application_connection_status_no_network_message", nil);
            self.image = [UIImage imageNamed:@"NoNetwork"];
            self.color = nil;
            break;
            
        case InfoFloatingViewTypeNoServices:
            self.title = TwinmeLocalizedString(@"application_connection_status_no_services", nil);
            self.message = TwinmeLocalizedString(@"application_connection_status_no_services_message", nil);
            self.image = [UIImage imageNamed:@"NoAccessServices"];
            self.color = nil;
            break;
            
        default:
            break;
    }
}

- (nonnull NSString *)getAppInfoTitle {
        
    return self.title;
}

- (nonnull NSString *)getAppInfoMessage {
    
    return self.message;
}

- (nonnull UIImage *)getAppInfoImage {
    
    return self.image;
}

- (nullable UIColor *)getAppInfoColor {
    
    return self.color;
}

@end
