/*
 *  Copyright (c) 2016-2021 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Chedi Baccari (Chedi.Baccari@twinlife-systems.com)
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

//
// Protocol: CameraSessionDelegate
//

@protocol CameraSessionDelegate <NSObject>

@optional - (void)didCaptureImage:(UIImage *)image;

@optional - (void)didCaptureVideo:(NSURL *)url;

@optional - (void)didCaptureImageWithData:(NSData *)imageData;

@optional - (void)inputManager:(id)sender;

@optional - (void)cameraAvailable:(BOOL)availability;

@end

//
// Interface: CameraSessionView
//

@interface CameraSessionView : UIView

@property (nonatomic, weak) id<CameraSessionDelegate>delegate;

@property BOOL animationInProgress;

- (void)onTapShutterButton;

- (void)onTapToggleButton;

- (void)onTapFlashButton;

- (void)startCapture;

- (void)stopCapture;

- (void)startVideoCapture;

- (void)stopVideoCapture;

- (BOOL)isTorchEnabled;

@end
