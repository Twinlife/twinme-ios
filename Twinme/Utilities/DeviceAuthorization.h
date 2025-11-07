/*
 *  Copyright (c) 2017-2020 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Phetsana Phommarinh (pphommarinh@skyrock.com)
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 *
 */

//
// Interface: DeviceAuthorization
//

#include <Photos/Photos.h>
#include <MediaPlayer/MediaPlayer.h>

@interface DeviceAuthorization : NSObject

+ (PHAuthorizationStatus)devicePhotoAuthorizationStatus;

+ (BOOL)devicePhotoAuthorizationAccessGranted:(PHAuthorizationStatus)status;

+ (AVAuthorizationStatus)deviceCameraAuthorizationStatus;

+ (AVAudioSessionRecordPermission)deviceMicrophonePermissionStatus;

+ (MPMediaLibraryAuthorizationStatus)deviceMediaLibraryAuthorizationStatus;

+ (void)showPhotoSettingsAlertInController:(UIViewController *)controller;

+ (void)showCameraSettingsAlertInController:(UIViewController *)controller;

+ (void)showMicrophoneSettingsAlertInController:(UIViewController *)controller;

+ (void)showMicrophoneCameraSettingsAlertInController:(UIViewController *)controller;

+ (void)showMediaSettingsAlertInController:(UIViewController *)controller;

@end

