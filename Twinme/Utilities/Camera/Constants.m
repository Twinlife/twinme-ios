/*
*  Copyright (c) 2016 twinlife SA.
*  SPDX-License-Identifier: AGPL-3.0-only
*
*  Contributors:
*   Chedi Baccari (Chedi.Baccari@twinlife-systems.com)
*/

#import "Constants.h"

@implementation Constants

CameraStatistics cameraStatisticsMake(float aperture, float exposureDuration, float ISO, float lensPostion) {
    CameraStatistics cameraStatistics;
    cameraStatistics.aperture = aperture;
    cameraStatistics.exposureDuration = exposureDuration;
    cameraStatistics.ISO = ISO;
    cameraStatistics.lensPosition = lensPostion;
    return cameraStatistics;
}

@end
