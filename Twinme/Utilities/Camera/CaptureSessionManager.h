/*
 *  Copyright (c) 2016-2021 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Chedi Baccari (Chedi.Baccari@twinlife-systems.com)
 *   Stephane Carrez (Stephane.Carrez@twin.life)
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <AVFoundation/AVFoundation.h>
#import <Foundation/Foundation.h>
#define kImageCapturedSuccessfully @"imageCapturedSuccessfully"
#import "Constants.h"

//
// Protocol: CaptureSessionManagerDelegate
//

@protocol CaptureSessionManagerDelegate <NSObject>

- (void)cameraSessionManagerDidCaptureImage;

- (void)cameraSessionManagerFailedToCaptureImage;

- (void)cameraSessionManagerDidReportAvailability:(BOOL)deviceAvailability forCameraType:(CameraType)cameraType;

@end

//
// Interface: CaptureSessionManager
//

@interface CaptureSessionManager : NSObject

@property (nonatomic, weak) id<CaptureSessionManagerDelegate>delegate;
@property (nonatomic, weak) AVCaptureDevice *activeCamera;

@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureStillImageOutput *stillImageOutput;
@property (nonatomic, strong) AVCaptureMovieFileOutput *movieFileOutput;
@property (nonatomic, strong) UIImage *stillImage;
@property (nonatomic, strong) NSData *stillImageData;
@property (nonatomic, strong) NSURL *movieFileURL;

@property (nonatomic,assign,getter=isTorchEnabled) BOOL enableTorch;

- (void)addStillImageOutput;

- (void)captureStillImage;

- (void)addVideoPreviewLayer;

- (void)initiateCaptureSessionForCamera:(CameraType)cameraType;

- (void)stop;

- (void)startVideoCapture;

- (void)stopVideoCapture;

@end
