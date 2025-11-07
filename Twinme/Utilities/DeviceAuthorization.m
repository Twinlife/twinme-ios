/*
 *  Copyright (c) 2019-2020 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 *
 */

#import <Utils/NSString+Utils.h>

#import "DeviceAuthorization.h"

//
// Implementation: DeviceAuthorization
//

@implementation DeviceAuthorization

+ (PHAuthorizationStatus)devicePhotoAuthorizationStatus {
    
    if (@available(iOS 14, *)) {
        return [PHPhotoLibrary authorizationStatusForAccessLevel:PHAccessLevelAddOnly];
    } else {
        return [PHPhotoLibrary authorizationStatus];
    }
}

+ (BOOL)devicePhotoAuthorizationAccessGranted:(PHAuthorizationStatus)status {
    
    if (@available(iOS 14, *)) {
        if (status == PHAuthorizationStatusLimited || status == PHAuthorizationStatusAuthorized) {
            return YES;
        }
        return NO;
    } else if (status == PHAuthorizationStatusAuthorized) {
        return YES;
    } else {
        return NO;
    }
}

+ (AVAuthorizationStatus)deviceCameraAuthorizationStatus {
    
    return [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
}

+ (AVAudioSessionRecordPermission)deviceMicrophonePermissionStatus {
    
    return [[AVAudioSession sharedInstance] recordPermission];
}

+ (MPMediaLibraryAuthorizationStatus)deviceMediaLibraryAuthorizationStatus {
    
    return [MPMediaLibrary authorizationStatus];
}

+ (CLAuthorizationStatus)deviceLocationAuthorizationStatus {
    
    return [CLLocationManager authorizationStatus];
}

+ (BOOL)deviceLocationServicesEnabled {
    
    return [CLLocationManager locationServicesEnabled];
}

+ (void)showSettingsAlertInController:(UIViewController *)controller message:(NSString *)message {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:TwinmeLocalizedString(@"application_authorization_title", nil) message:message  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *settingsButton = [UIAlertAction actionWithTitle:TwinmeLocalizedString(@"application_authorization_go_settings", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
    }];
    
    UIAlertAction *cancelButton = [UIAlertAction actionWithTitle:TwinmeLocalizedString(@"application_cancel", nil) style:UIAlertActionStyleCancel handler:nil];
    
    [alertController addAction:settingsButton];
    [alertController addAction:cancelButton];
    
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [controller presentViewController:alertController animated:YES completion:nil];
    });
}

+ (void)showPhotoSettingsAlertInController:(UIViewController *)controller {
    
    [DeviceAuthorization showSettingsAlertInController:controller message:TwinmeLocalizedString(@"application_authorization_photos", nil)];
}

+ (void)showCameraSettingsAlertInController:(UIViewController *)controller {
    
    [DeviceAuthorization showSettingsAlertInController:controller message:TwinmeLocalizedString(@"application_authorization_camera", nil)];
}

+ (void)showMicrophoneSettingsAlertInController:(UIViewController *)controller {
    
    [DeviceAuthorization showSettingsAlertInController:controller message:TwinmeLocalizedString(@"application_authorization_microphone", nil)];
}

+ (void)showMicrophoneCameraSettingsAlertInController:(UIViewController *)controller {
    
    [DeviceAuthorization showSettingsAlertInController:controller message:TwinmeLocalizedString(@"application_authorization_microphone_camera", nil)];
}

+ (void)showMediaSettingsAlertInController:(UIViewController *)controller {
    
    [DeviceAuthorization showSettingsAlertInController:controller message:TwinmeLocalizedString(@"application_authorization_media", nil)];
}

+ (void)showLocationSettingsAlertInController:(UIViewController*)controller {
    
    [DeviceAuthorization showSettingsAlertInController:controller message:TwinmeLocalizedString(@"application_authorization_location", nil)];
}

@end
