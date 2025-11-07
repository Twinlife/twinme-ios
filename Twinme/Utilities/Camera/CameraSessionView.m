/*
 *  Copyright (c) 2016-2021 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Chedi Baccari (Chedi.Baccari@twinlife-systems.com)
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 *   Christian Jacquemot (Christian.Jacquemot@twinlife-systems.com)
 */

#import "CameraSessionView.h"
#import "CaptureSessionManager.h"
#import <ImageIO/ImageIO.h>
#import "Constants.h"

//
// Interface: CameraSessionView ()
//

@interface CameraSessionView () <CaptureSessionManagerDelegate>

@property CameraType cameraUsed;
@property CaptureSessionManager *captureManager;
@property UILabel *ISOLabel;
@property UILabel *apertureLabel;
@property UILabel *shutterSpeedLabel;
@property (nonatomic) float videoZoom;

@property (nonatomic) UIPinchGestureRecognizer *pinchGestureRecognizer;

@end

//
// Implementation: CameraSessionView
//

@implementation CameraSessionView

- (void)drawRect:(CGRect)rect {
    
    if (![[self.captureManager captureSession] isRunning]) {
        self.animationInProgress = NO;
        self.videoZoom = 1.0;
        
        self.pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(didPinchVideo:)];
        [self addGestureRecognizer:self.pinchGestureRecognizer];
        
        [self setupCaptureManager:RearFacingCamera];
        self.cameraUsed = RearFacingCamera;
        
        UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(focusGesture:)];
        if (singleTapGestureRecognizer) {
            [self addGestureRecognizer:singleTapGestureRecognizer];
        }
        self.captureManager.enableTorch = NO;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[self.captureManager captureSession] startRunning];
        });
    }
}

- (void)didPinchVideo:(UIPinchGestureRecognizer *)pinchGestureRecognizer {
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    static CGFloat initialZoomFactor = 0;
    if (pinchGestureRecognizer.state == UIGestureRecognizerStateBegan) {
        initialZoomFactor = device.videoZoomFactor;
    } else if (pinchGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        NSError *error = nil;
        if ([device lockForConfiguration:&error]) {
            CGFloat zoomFactor = MAX(1.0, MIN(initialZoomFactor * pinchGestureRecognizer.scale, device.activeFormat.videoMaxZoomFactor));
            [device rampToVideoZoomFactor:zoomFactor withRate:2.0];
            [device unlockForConfiguration];
        }
    }
}

#pragma mark - Setup

- (void)setupCaptureManager:(CameraType)camera {
    
    if (self.captureManager && self.captureManager.captureSession.inputs.count > 0) {
        AVCaptureInput* currentCameraInput = [self.captureManager.captureSession.inputs objectAtIndex:0];
        [self.captureManager.captureSession removeInput:currentCameraInput];
    }
    
    self.captureManager = [CaptureSessionManager new];
    [self.captureManager.captureSession beginConfiguration];
    [self.captureManager setDelegate:self];
    [self.captureManager initiateCaptureSessionForCamera:camera];
    [self.captureManager addStillImageOutput];
    [self.captureManager addVideoPreviewLayer];
    [self.captureManager.captureSession commitConfiguration];
    
    CGRect layerRect = self.layer.bounds;
    [self.captureManager.previewLayer setBounds:layerRect];
    [self.captureManager.previewLayer setPosition:CGPointMake(CGRectGetMidX(layerRect),CGRectGetMidY(layerRect))];
    [self.captureManager.previewLayer setVideoGravity:AVLayerVideoGravityResizeAspect];
    CATransition *applicationLoadViewIn =[CATransition animation];
    [applicationLoadViewIn setDuration:0.6];
    [applicationLoadViewIn setType:kCATransitionReveal];
    [applicationLoadViewIn setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
    [self.captureManager.previewLayer addAnimation:applicationLoadViewIn forKey:kCATransitionReveal];
    
    [self.layer addSublayer:_captureManager.previewLayer];
}

#pragma mark - User Interaction

- (void)onTapShutterButton {
    
    [self animateShutterRelease];
    [self.captureManager captureStillImage];
}

- (void)onTapFlashButton {
    
    BOOL enable = !self.captureManager.isTorchEnabled;
    self.captureManager.enableTorch = enable;
}

- (void)onTapToggleButton {
    
    if (self.cameraUsed == RearFacingCamera) {
        [self setupCaptureManager:FrontFacingCamera];
        self.cameraUsed = FrontFacingCamera;
        [[self.captureManager captureSession] startRunning];
    } else {
        [self setupCaptureManager:RearFacingCamera];
        self.cameraUsed = RearFacingCamera;
        [[self.captureManager captureSession] startRunning];
    }
}

- (void)onTapDismissButton {
    
    [UIView animateWithDuration:0.3 animations:^{
        self.center = CGPointMake(self.center.x, self.center.y*3);
    } completion:^(BOOL finished) {
        [self.captureManager stop];
        [self removeFromSuperview];
    }];
}

- (void)focusGesture:(id)sender {
    
    if ([sender isKindOfClass:[UITapGestureRecognizer class]]) {
        UITapGestureRecognizer *tap = sender;
        if (tap.state == UIGestureRecognizerStateRecognized) {
            CGPoint location = [sender locationInView:self];
            [self focusAtPoint:location completionHandler:^{
                [self animateFocusReticuleToPoint:location];
            }];
        }
    }
}

- (void)startCapture {
    
    if (![[self.captureManager captureSession] isRunning]) {
        [[self.captureManager captureSession] startRunning];
    }
}

- (void)stopCapture {
    
    if ([[self.captureManager captureSession] isRunning]) {
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        NSError *error = nil;
        if ([device lockForConfiguration:&error]) {
            [device rampToVideoZoomFactor:1.0 withRate:2.0];
            [device unlockForConfiguration];
        }
        [[self.captureManager captureSession] stopRunning];
    }
}

- (void)startVideoCapture {
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    [self.captureManager startVideoCapture];
}

- (void)stopVideoCapture {
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error = nil;
    if ([device lockForConfiguration:&error]) {
        [device rampToVideoZoomFactor:1.0 withRate:2.0];
        [device unlockForConfiguration];
    }
    
    [self.captureManager stopVideoCapture];
    
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(didCaptureVideo:)]) {
            [self.delegate didCaptureVideo:[[self captureManager] movieFileURL]];
        }
    }
}

- (BOOL)isTorchEnabled {
    
    return [self.captureManager isTorchEnabled];
}

#pragma mark - Animation

- (void)animateShutterRelease {
    
    self.animationInProgress = YES;
    [UIView animateWithDuration:.1 animations:^{
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:.1 animations:^{
        } completion:^(BOOL finished) {
            self.animationInProgress = NO; //Enables input manager
        }];
    }];
}

- (void)animateFocusReticuleToPoint:(CGPoint)targetPoint {
    
    self.animationInProgress = YES;
}

- (void)orientationChanged:(NSNotification *)notification {
}

#pragma mark - Camera Session Manager Delegate Methods

- (void)cameraSessionManagerDidCaptureImage {
    
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(didCaptureImage:)]) {
            [self.delegate didCaptureImage:[[self captureManager] stillImage]];
        }
        if ([self.delegate respondsToSelector:@selector(didCaptureImageWithData:)]) {
            [self.delegate didCaptureImageWithData:[[self captureManager] stillImageData]];
        }
    }
}

- (void)cameraSessionManagerFailedToCaptureImage {
}

- (void)cameraSessionManagerDidReportAvailability:(BOOL)deviceAvailability forCameraType:(CameraType)cameraType {
    
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(cameraAvailable:)]) {
            [self.delegate cameraAvailable:deviceAvailability];
        }
    }
}

#pragma mark - Helper Methods

- (void)focusAtPoint:(CGPoint)point completionHandler:(void(^)(void))completionHandler {
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    CGPoint pointOfInterest = CGPointZero;
    CGSize frameSize = self.bounds.size;
    pointOfInterest = CGPointMake(point.y / frameSize.height, 1.f - (point.x / frameSize.width));
    
    if ([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            if ([device isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeAutoWhiteBalance]) {
                [device setWhiteBalanceMode:AVCaptureWhiteBalanceModeAutoWhiteBalance];
            }
            if ([device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
                [device setFocusMode:AVCaptureFocusModeAutoFocus];
                [device setFocusPointOfInterest:pointOfInterest];
            }
            if([device isExposurePointOfInterestSupported] && [device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
                [device setExposurePointOfInterest:pointOfInterest];
                [device setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
            }
            [device unlockForConfiguration];
            
            completionHandler();
        }
    } else {
        completionHandler();
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (BOOL)shouldAutorotate {
    
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    
    return UIInterfaceOrientationMaskPortrait;
}

- (void)viewDidDisappear:(BOOL)animated {
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
