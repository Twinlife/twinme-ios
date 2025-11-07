/*
 *  Copyright (c) 2016-2021 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Chedi Baccari (Chedi.Baccari@twinlife-systems.com)
 *   Stephane Carrez (Stephane.Carrez@twin.life)
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <ImageIO/ImageIO.h>

#import "CaptureSessionManager.h"

//
// Interface: CaptureSessionManager ()
//

@interface CaptureSessionManager() <AVCaptureFileOutputRecordingDelegate>

@end

//
// Implementation: CaptureSessionManager
//

@implementation CaptureSessionManager

#pragma mark Capture Session Configuration

- (id)init {
    
    if (self = [super init]) {
        [self setCaptureSession:[[AVCaptureSession alloc] init]];
        _captureSession.sessionPreset = AVCaptureSessionPresetPhoto;
    }
    return self;
}

- (void)addVideoPreviewLayer {
    
    [self setPreviewLayer:[[AVCaptureVideoPreviewLayer alloc] initWithSession:[self captureSession]]];
    [[self previewLayer] setVideoGravity:AVLayerVideoGravityResizeAspectFill];
}

- (void)initiateCaptureSessionForCamera:(CameraType)cameraType {
    
    // Iterate through devices and assign 'active camera' per parameter
    // Note: WebRTC uses AVCaptureDeviceTypeBuiltInWideAngleCamera
    AVCaptureDeviceDiscoverySession *captureDeviceDiscoverySession = [AVCaptureDeviceDiscoverySession discoverySessionWithDeviceTypes:@[AVCaptureDeviceTypeBuiltInWideAngleCamera] mediaType:AVMediaTypeVideo position:cameraType == FrontFacingCamera ? AVCaptureDevicePositionFront : AVCaptureDevicePositionBack];
    NSArray<AVCaptureDevice *> *captureDevices = [captureDeviceDiscoverySession devices];
    if (captureDevices.count > 0) {
        self.activeCamera = captureDevices[0];
    }
    
    NSError *error = nil;
    BOOL deviceAvailability = YES;
    AVCaptureDeviceInput *cameraDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:_activeCamera error:&error];
    if (!error && [[self captureSession] canAddInput:cameraDeviceInput]) {
        [[self captureSession] addInput:cameraDeviceInput];
    } else {
        deviceAvailability = NO;
    }
    
    //Report camera device availability
    if (self.delegate) {
        [self.delegate cameraSessionManagerDidReportAvailability:deviceAvailability forCameraType:cameraType];
    }
}

- (void)addStillImageOutput {
    
    [self setStillImageOutput:[[AVCaptureStillImageOutput alloc] init]];
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG,AVVideoCodecKey,nil];
    [[self stillImageOutput] setOutputSettings:outputSettings];
    
    [self getOrientationAdaptedCaptureConnection];
    
    [[self captureSession] addOutput:[self stillImageOutput]];
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
        [device lockForConfiguration:nil];
        [device setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
        [device unlockForConfiguration];
    }
}

- (void)captureStillImage {
    
    AVCaptureConnection *videoConnection = [self getOrientationAdaptedCaptureConnection];
    if (videoConnection) {
        [[self stillImageOutput] captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:
         ^(CMSampleBufferRef imageSampleBuffer, NSError *error) {
            if (error || !imageSampleBuffer) {
                return;
            }
            
            CFDictionaryRef exifAttachments = CMGetAttachment(imageSampleBuffer, kCGImagePropertyExifDictionary, NULL);
            if (exifAttachments) {
                //Attachements Found
            } else {
                //No Attachments
            }
            NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
            UIImage *image = [[UIImage alloc] initWithData:imageData];
            [self setStillImage:image];
            [self setStillImageData:imageData];
            
            if (self.delegate) {
                [self.delegate cameraSessionManagerDidCaptureImage];
            }
        }];
    }
    
    //Turn off the flash if on
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([device hasTorch]) {
        [device lockForConfiguration:nil];
        [device setTorchMode:AVCaptureTorchModeAuto];
        [device unlockForConfiguration];
    }
}

- (void)setEnableTorch:(BOOL)enableTorch {
    
    _enableTorch = enableTorch;
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([device hasTorch] && [device hasFlash]) {
        [device lockForConfiguration:nil];
        if (enableTorch) {
            [device setTorchMode:AVCaptureTorchModeOn];
        } else {
            [device setTorchMode:AVCaptureTorchModeOff];
        }
        [device unlockForConfiguration];
    }
}

#pragma mark - Helper Method(s)

- (void)assignVideoOrienationForVideoConnection:(AVCaptureConnection *)videoConnection {
    
    AVCaptureVideoOrientation newOrientation;
    switch ([[UIDevice currentDevice] orientation]) {
        case UIDeviceOrientationPortrait:
            newOrientation = AVCaptureVideoOrientationPortrait;
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            newOrientation = AVCaptureVideoOrientationPortraitUpsideDown;
            break;
        case UIDeviceOrientationLandscapeLeft:
            newOrientation = AVCaptureVideoOrientationLandscapeRight;
            break;
        case UIDeviceOrientationLandscapeRight:
            newOrientation = AVCaptureVideoOrientationLandscapeLeft;
            break;
        default:
            newOrientation = AVCaptureVideoOrientationPortrait;
    }
    [videoConnection setVideoOrientation: newOrientation];
}

- (AVCaptureConnection *)getOrientationAdaptedCaptureConnection {
    
    AVCaptureConnection *videoConnection = nil;
    for (AVCaptureConnection *connection in [[self stillImageOutput] connections]) {
        for (AVCaptureInputPort *port in [connection inputPorts]) {
            if ([[port mediaType] isEqual:AVMediaTypeVideo] ) {
                videoConnection = connection;
                [self assignVideoOrienationForVideoConnection:videoConnection];
                break;
            }
        }
        if (videoConnection) {
            [self assignVideoOrienationForVideoConnection:videoConnection];
            break;
        }
    }
    
    return videoConnection;
}

- (void)startVideoCapture {
    
    AVCaptureDevice *audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    AVCaptureDeviceInput *audioInput = [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:nil];
    if ([[self captureSession] canAddInput:audioInput]) {
        [[self captureSession] addInput:audioInput];
    }
    
    self.movieFileOutput = [AVCaptureMovieFileOutput new];
    if ([[self captureSession] canAddOutput:self.movieFileOutput]) {
        [[self captureSession] addOutput:self.movieFileOutput];
    }
        
    [[self captureSession] setSessionPreset:AVCaptureSessionPresetHigh];
  
    if ([self.movieFileOutput.availableVideoCodecTypes containsObject:AVVideoCodecTypeH264]) {
        AVCaptureConnection* connection = [self.movieFileOutput connectionWithMediaType:AVMediaTypeVideo];
        [self.movieFileOutput setOutputSettings:@{AVVideoCodecKey: AVVideoCodecTypeH264} forConnection:connection];
    }
    
    NSString *fileName = [NSString stringWithFormat:@"%@.mov", [[NSProcessInfo processInfo] globallyUniqueString]];
    
    self.movieFileURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:fileName]];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self.movieFileOutput startRecordingToOutputFileURL:self.movieFileURL recordingDelegate:self];
    });
}

- (void)stopVideoCapture {
    
    [self.captureSession stopRunning];
    [[self captureSession] removeOutput:self.movieFileOutput];
    [[self captureSession] setSessionPreset:AVCaptureSessionPresetPhoto];
}

- (void)captureOutput:(AVCaptureFileOutput *)output didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray<AVCaptureConnection *> *)connections {
    
}

- (void)captureOutput:(AVCaptureFileOutput *)output didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray<AVCaptureConnection *> *)connections error:(NSError *)error {
    
}

#pragma mark - Cleanup Functions

// stop the camera, otherwise it will lead to memory crashes
- (void)stop {
    
    [self.captureSession stopRunning];
    
    if(self.captureSession.inputs.count > 0) {
        AVCaptureInput* input = [self.captureSession.inputs objectAtIndex:0];
        [self.captureSession removeInput:input];
    }
    if(self.captureSession.outputs.count > 0) {
        AVCaptureVideoDataOutput* output = [self.captureSession.outputs objectAtIndex:0];
        [self.captureSession removeOutput:output];
    }
}

- (void)dealloc {
    [self stop];
}

@end
