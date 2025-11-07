/*
 *  Copyright (c) 2016-2024 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Marouane Qasmi (Marouane.Qasmi@twinlife-systems.com)
 *   Chedi Baccari (Chedi.Baccari@twinlife-systems.com)
 *   Christian Jacquemot (Christian.Jacquemot@twinlife-systems.com)
 *   Stephane Carrez (Stephane.Carrez@twin.life)
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

@import AVFoundation;

#import <CocoaLumberjack.h>

#import <Twinlife/TLConnectivityService.h>
#import <Twinlife/TLProxyDescriptor.h>
#import <Twinlife/TLTwinlife.h>
#import <Twinlife/TLTwincodeOutboundService.h>

#import <Twinme/TLContact.h>
#import <Twinme/TLProfile.h>
#import <Twinme/TLTwinmeContext.h>

#import <Utils/NSString+Utils.h>

#include <Photos/Photos.h>

#import "AddContactViewController.h"
#import "AcceptInvitationViewController.h"
#import "EnterInvitationCodeViewController.h"
#import "InvitationCodeViewController.h"
#import "ShowProfileViewController.h"
#import "SuccessAuthentifiedRelationViewController.h"
#import "SettingsAdvancedViewController.h"

#import <TwinmeCommon/Design.h>
#import <TwinmeCommon/ShareProfileService.h>
#import <TwinmeCommon/Utils.h>

#import "AlertMessageView.h"
#import "ResetInvitationConfirmView.h"

#import "DeviceAuthorization.h"
#import "TwincodeView.h"
#import "UIView+Toast.h"
#import "TwinmeTextField.h"
#import "UICustomTab.h"
#import "CustomTabView.h"
#import "DefaultConfirmView.h"

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static const CGFloat DESIGN_HIGHLIGHT_VIEW_CORNER_RADIUS = 4;
static const CGFloat DESIGN_PROFILE_TOP_MARGIN = 40;
static const CGFloat DESIGN_QRCODE_TOP_MARGIN = 60;

static UIColor *DESIGN_PLACEHOLDER_COLOR;

//
// Interface: AddContactViewController ()
//

@interface AddContactViewController () <AVCaptureMetadataOutputObjectsDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, AcceptInvitationDelegate, ShareProfileServiceDelegate, AlertMessageViewDelegate, PHPhotoLibraryChangeObserver, UITextFieldDelegate, SuccessAuthentifiedRelationDelegate, ConfirmViewDelegate, CustomTabViewDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *customTabViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *customTabViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *customTabContainerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *profileViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *profileViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *profileViewTopConstraint;
@property (weak, nonatomic) IBOutlet UIView *profileView;
@property (weak, nonatomic) IBOutlet UIImageView *avatarView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *twincodeViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *twincodeViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *twincodeViewTopConstraint;
@property (weak, nonatomic) IBOutlet UIView *twincodeView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageLabelBottomConstraint;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *qrcodeViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *qrcodeViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *qrcodeView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *twincodeLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *twincodeLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *twincodeLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *twincodeLabelHeightConstraint;
@property (weak, nonatomic) IBOutlet UILabel *twincodeLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *zoomViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *zoomViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *zoomViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *zoomView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *zoomImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *zoomImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *saveViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *saveViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *saveView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *saveRoundedViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *saveRoundedView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *saveImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *saveImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *saveLabelTopConstraint;
@property (weak, nonatomic) IBOutlet UILabel *saveLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *generateViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *generateViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *generateView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *generateRoundedViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *generateRoundedView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *generateImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *generateImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *generateLabelTopConstraint;
@property (weak, nonatomic) IBOutlet UILabel *generateLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *twincodeCopyViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *twincodeCopyView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *twincodeCopyRoundedViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *twincodeCopyRoundedView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *twincodeCopyImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *twincodeCopyImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *twincodeCopyLabelTopConstraint;
@property (weak, nonatomic) IBOutlet UILabel *twincodeCopyLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *shareViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *shareViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *shareViewBottomConstraint;
@property (weak, nonatomic) IBOutlet UIView *shareView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *shareLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *shareLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *shareLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *shareSubLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *shareSubLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *shareSubLabelTopConstraint;
@property (weak, nonatomic) IBOutlet UILabel *shareSubLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *shareImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *shareImageViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *shareImageView;
@property (weak, nonatomic) IBOutlet UIView *captureView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageScanViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageScanViewWidthConstraint;
@property (weak, nonatomic) IBOutlet UIView *messageScanView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageScanImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageScanImageViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *messageScanImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageScanLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageScanLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *messageScanLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageNoPermissionScanLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet UILabel *messageNoPermissionScanLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *importFromGalleryViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *importFromGalleryViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *importFromGalleryViewTopConstraint;
@property (weak, nonatomic) IBOutlet UIView *importFromGalleryView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *importFromGalleryLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *importFromGalleryLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *importFromGalleryLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *importFromGalleryImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *importFromGalleryImageViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *importFromGalleryImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *twincodePasteViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *twincodePasteViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *twincodePasteViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *twincodePasteView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *twincodeTextFieldLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *twincodeTextFieldTrailingConstraint;
@property (weak, nonatomic) IBOutlet TwinmeTextField *twincodeTextField;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *twincodeInviteViewWidthConstraint;
@property (weak, nonatomic) IBOutlet UIView *twincodeInviteView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *twincodeInviteImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *twincodeInviteImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *twincodePasteAddViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *twincodePasteAddView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *twincodePasteImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *twincodePasteImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *invitationCodeViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *invitationCodeViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *invitationCodeViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *invitationCodeViewBottomConstraint;
@property (weak, nonatomic) IBOutlet UIView *invitationCodeView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *invitationCodeImageViewLeading;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *invitationCodeImageViewHeight;
@property (weak, nonatomic) IBOutlet UIImageView *invitationCodeImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *invitationCodeLabelLeading;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *invitationCodeLabelTrailing;
@property (weak, nonatomic) IBOutlet UILabel *invitationCodeLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *invitationCodeAccessoryViewTrailing;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *invitationCodeAccessoryViewHeight;
@property (weak, nonatomic) IBOutlet UIImageView *invitationCodeAccessoryView;

@property (nonatomic) CustomTabView *customTabView;
@property (nonatomic) ResetInvitationConfirmView *resetInvitationConfirmView;

@property (nonatomic, nullable) UIView *highlightView;
@property (nonatomic, nullable) AVCaptureSession *captureSession;
@property (nonatomic, nullable) AVCaptureVideoPreviewLayer *previewLayer;

@property (nonatomic) TLProfile *profile;
@property (nonatomic, nullable) TLTwincodeURI *uri;
@property (nonatomic) TLContact *contact;
@property (nonatomic) ShareProfileService *shareProfileService;
@property (nonatomic) InvitationMode invitationMode;
@property (nonatomic, nullable) NSString *proxyToAdd;

@property (nonatomic) BOOL saveQRCodeInGallery;
@property (nonatomic) BOOL zoomQRCode;
@property (nonatomic) BOOL initTwincodeHeight;

@property (nonatomic) BOOL keyboardHidden;
@property (nonatomic) CGFloat yOffset;
@property (nonatomic) CGFloat qrCodeInitialTop;
@property (nonatomic) CGFloat qrCodeInitialHeight;
@property (nonatomic) CGFloat qrCodeMaxHeight;

@end

//
// Implementation: AddContactViewController
//

#undef LOG_TAG
#define LOG_TAG @"AddContactViewController"

@implementation AddContactViewController

+ (void)initialize {
    DDLogVerbose(@"%@ initialize", LOG_TAG);
    
    DESIGN_PLACEHOLDER_COLOR = [UIColor colorWithRed:32./255. green:41./255 blue:73./255 alpha:0.3];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    DDLogVerbose(@"%@ initWithCoder: %@", LOG_TAG, coder);
    
    self = [super initWithCoder:coder];
    
    if (self) {
        _saveQRCodeInGallery = NO;
        _keyboardHidden = YES;
        _zoomQRCode = NO;
        _initTwincodeHeight = NO;
        _invitationMode = InvitationModeScan;
        _yOffset = 0;
        _qrCodeInitialTop = DESIGN_QRCODE_TOP_MARGIN * Design.HEIGHT_RATIO;
        _qrCodeInitialHeight = 0;
        _qrCodeMaxHeight = 0;
    }
    return self;
}

- (void)viewDidLoad {
    DDLogVerbose(@"%@ viewDidLoad", LOG_TAG);
    
    [super viewDidLoad];
    
    [self initViews];
}

- (void)viewWillAppear:(BOOL)animated {
    DDLogVerbose(@"%@ viewWillAppear: %d", LOG_TAG, animated);
    
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didPasteItemNotification:) name:TwinmeTextFieldDidPasteItemNotification object:nil];
    
    [self updateViews];
    
    // Update again the QR-code because the twincode could change.
    if (self.profile) {
        [self updateProfile];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    DDLogVerbose(@"%@ viewWillDisappear: %@", LOG_TAG, animated ? @"YES" : @"NO");
    
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TwinmeTextFieldDidPasteItemNotification object:nil];
    
    [self dismissKeyboard];
    
    if (self.captureSession) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self.captureSession stopRunning];
        });
    }
}

- (void)viewDidLayoutSubviews {
    DDLogVerbose(@"%@ viewDidLayoutSubviews", LOG_TAG);
    
    [super viewDidLayoutSubviews];
    
    if (!self.customTabView) {
        [self initCustomTab];
    }
    
    if (self.view.safeAreaLayoutGuide.layoutFrame.size.height > 0 && !self.initTwincodeHeight) {
        self.initTwincodeHeight = YES;
        [self updateTwincodeHeight];
    }
}

- (void)setupCaptureSession {
    DDLogVerbose(@"%@ setupCaptureSession", LOG_TAG);
    
    if (!self.captureSession) {
        self.captureSession = [[AVCaptureSession alloc] init];
        self.captureSession.sessionPreset = AVCaptureSessionPresetPhoto;
        AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        NSError *error = nil;
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
        if (input) {
            [self.captureSession addInput:input];
            
            __weak typeof(self) weakSelf = self;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (weakSelf) {
                    __strong typeof(weakSelf) strongSelf = weakSelf;
                    strongSelf.messageScanView.hidden = YES;
                }
            });
        } else {
            self.messageScanView.hidden = YES;
            self.messageNoPermissionScanLabel.hidden = NO;
        }
        
        AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
        [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
        [self.captureSession addOutput:output];
        output.metadataObjectTypes = [output availableMetadataObjectTypes];
        
        if (self.previewLayer) {
            [self.previewLayer removeFromSuperlayer];
        }
        self.previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.captureSession];
        self.previewLayer.frame = self.captureView.bounds;
        self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        self.previewLayer.cornerRadius = Design.POPUP_RADIUS;
        [self.captureView.layer insertSublayer:self.previewLayer atIndex:0];
        [self.captureView bringSubviewToFront:self.highlightView];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self.captureSession startRunning];
        });
        
    }
}

#pragma mark - Public methods

- (void)initWithProfile:(TLProfile *)profile invitationMode:(InvitationMode)invitationMode  {
    DDLogVerbose(@"%@ initWithProfile: %@", LOG_TAG, profile);
    
    self.profile = profile;
    self.invitationMode = invitationMode;
    self.shareProfileService = [[ShareProfileService alloc] initWithTwinmeContext:self.twinmeContext delegate:self];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    DDLogVerbose(@"%@ textFieldShouldReturn: %@", LOG_TAG, textField);
    
    [textField resignFirstResponder];
    return NO;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    DDLogVerbose(@"%@ textView: %@ shouldChangeCharactersInRange: %lu shouldChangeCharactersInRange: %@", LOG_TAG, textField, (unsigned long)range.length, string);
    
    return YES;
}


- (void)textFieldDidChange:(UITextField *)textField{
    DDLogVerbose(@"%@ textFieldDidChange: %@", LOG_TAG, textField);
    
    if (![self.twincodeTextField.text isEqualToString:@""]) {
        self.twincodePasteAddView.hidden = NO;
        self.twincodeTextFieldTrailingConstraint.constant = self.twincodeInviteViewWidthConstraint.constant;
    } else {
        self.twincodePasteAddView.hidden = YES;
        self.twincodeTextFieldTrailingConstraint.constant = self.twincodeTextFieldLeadingConstraint.constant;
    }
}

- (void)keyboardWillShow:(NSNotification *)notification {
    DDLogVerbose(@"%@ keyboardWillShow: %@", LOG_TAG, notification);
    
    if (!self.keyboardHidden) {
        return;
    }
    
    self.keyboardHidden = NO;
    NSDictionary *info = [notification userInfo];
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    CGRect frame = CGRectMake(0, 0, Design.DISPLAY_WIDTH, Design.DISPLAY_HEIGHT);
    frame.origin.y = -keyboardSize.height;
    self.view.frame = frame;
    
    [self.twinmeApplication setDefaultKeyboardHeight:keyboardSize.height];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    DDLogVerbose(@"%@ keyboardWillHide: %@", LOG_TAG, notification);
    
    self.keyboardHidden = YES;
    
    CGRect frame = self.view.frame;
    frame.origin.y = self.yOffset;
    self.view.frame = frame;
}

- (void)keyboardWillChangeFrame:(NSNotification *)notification {
    DDLogVerbose(@"%@ keyboardWillChangeFrame: %@", LOG_TAG, notification);
    
    NSDictionary *info = [notification userInfo];
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    CGRect frame = CGRectMake(0, 0, Design.DISPLAY_WIDTH, Design.DISPLAY_HEIGHT);
    frame.origin.y = -keyboardSize.height;
    self.view.frame = frame;
}

- (void)didPasteItemNotification:(NSNotification *)notification {
    DDLogVerbose(@"%@ didPasteItemNotification: %@", LOG_TAG, notification);
    
    NSString *pastedContent = (NSString *)notification.object;
    if (pastedContent) {
        NSURL *url = [NSURL URLWithString:pastedContent];
        [self.shareProfileService parseUriWithUri:url withBlock:^(TLBaseServiceErrorCode errorCode, TLTwincodeURI *uri) {
            self.twincodeInviteImageView.hidden = NO;
            self.twincodeTextFieldTrailingConstraint.constant = self.twincodeInviteViewWidthConstraint.constant;
            if (errorCode != TLBaseServiceErrorCodeSuccess) {
                self.twincodeTextField.text = pastedContent;
            } else {
                // SCz this is not correct: we will loose information such as public key.
                self.twincodeTextField.text = uri.label;
            }
        }];
    }
}


#pragma mark - PHPhotoLibraryChangeObserver Methods

- (void)photoLibraryDidChange:(PHChange *)changeInstance {
    DDLogVerbose(@"%@ photoLibraryDidChange: %@", LOG_TAG, changeInstance);
    
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
    if (self.saveQRCodeInGallery) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self saveQRCodeWithPermissionCheck];
        });
    }
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    DDLogVerbose(@"%@ captureOutput:%@ didOutputMetadataObjects: %@ fromConnection: %@", LOG_TAG, captureOutput, metadataObjects, connection);
    
    NSString *decodedResult = nil;
    for (AVMetadataObject *metadataObject in metadataObjects) {
        if ([metadataObject.type isEqualToString:AVMetadataObjectTypeQRCode]) {
            AVMetadataMachineReadableCodeObject *readableCodeObject;
            readableCodeObject = (AVMetadataMachineReadableCodeObject*)[self.previewLayer transformedMetadataObjectForMetadataObject:(AVMetadataMachineReadableCodeObject *)metadataObject];
            self.highlightView.frame = readableCodeObject.bounds;
            decodedResult = [(AVMetadataMachineReadableCodeObject *)metadataObject stringValue];
            [self.captureSession stopRunning];
            
            [self hapticFeedBack:UIImpactFeedbackStyleHeavy];
            [self handleDecode:decodedResult];
            break;
        }
    }
}

#pragma mark - ImagePicker Delegate Methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    DDLogVerbose(@"%@ imagePickerController: %@ didFinishPickingMediaWithInfo: %@", LOG_TAG, picker, info);
    
    [picker dismissViewControllerAnimated:YES completion:^{
        CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:nil];
        
        UIImage *originalImage = info[UIImagePickerControllerOriginalImage];
        CIImage *image = [[CIImage alloc] initWithCGImage:originalImage.CGImage options:nil];
        NSArray *features = [detector featuresInImage:image];
        
        BOOL detectQRCode = NO;
        
        for (CIFeature *feature in features) {
            if ([feature.type isEqualToString:CIFeatureTypeQRCode]) {
                detectQRCode = YES;
                CIQRCodeFeature *qrCodeFeature = (CIQRCodeFeature *) feature;
                [self handleDecode:qrCodeFeature.messageString];
                break;
            }
        }
        
        if (!detectQRCode) {
            [self incorrectQRCode:-1];
        }
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    DDLogVerbose(@"%@ imagePickerControllerDidCancel: %@", LOG_TAG, picker);
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - AcceptInvitationDelegate

- (void)invitationDidFinish:(nullable TLContact *)contact {
    DDLogVerbose(@"%@ invitationDidFinish", LOG_TAG);
    
    self.contact = contact;
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - ShareProfileServiceDelegate

- (void)onGetDefaultProfile:(TLProfile *)profile {
    DDLogVerbose(@"%@ onGetDefaultProfile: %@", LOG_TAG, profile);
    
}

- (void)onGetDefaultProfileNotFound {
    DDLogVerbose(@"%@ onGetDefaultProfileNotFound", LOG_TAG);
    
}

- (void)onGetTwincodeURI:(nonnull TLTwincodeURI *)uri {
    DDLogVerbose(@"%@ onGetTwincodeURI: %@", LOG_TAG, uri);
    
    self.uri = uri;
    [self updateProfile];
}

- (void)onCreateContact:(nonnull TLContact *)contact {
    DDLogVerbose(@"%@ onCreateContact: %@", LOG_TAG, contact);
    
    if ([self isViewLoaded] && self.view.window) {
        self.contact = contact;
        
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

#pragma mark - AlertMessageViewDelegate

- (void)didCloseAlertMessage:(nonnull AlertMessageView *)alertMessageView {
    DDLogVerbose(@"%@ didCloseAlertMessage: %@", LOG_TAG, alertMessageView);
    
    [alertMessageView closeAlertView];
}

- (void)didFinishCloseAlertMessageAnimation:(nonnull AlertMessageView *)alertMessageView {
    DDLogVerbose(@"%@ didFinishCloseAlertMessageAnimation: %@", LOG_TAG, alertMessageView);
    
    if (self.captureSession) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self.captureSession startRunning];
        });
    } else {
        [self setupCaptureSession];
    }
    
    self.twincodeTextField.text = @"";
    self.twincodePasteAddView.hidden = YES;
    self.twincodeTextFieldTrailingConstraint.constant = self.twincodeTextFieldLeadingConstraint.constant;
    
    [alertMessageView removeFromSuperview];
}

#pragma mark - ConfirmViewDelegate

- (void)didTapConfirm:(nonnull AbstractConfirmView *)abstractConfirmView {
    DDLogVerbose(@"%@ didTapConfirm: %@", LOG_TAG, abstractConfirmView);
    
    if (self.resetInvitationConfirmView) {
        [self.shareProfileService changeProfileTwincode:self.profile];
        [self.resetInvitationConfirmView closeConfirmView];
    } else if ([abstractConfirmView isKindOfClass:[DefaultConfirmView class]]) {
        [self addProxy];
        [abstractConfirmView closeConfirmView];
    }
}

- (void)didTapCancel:(nonnull AbstractConfirmView *)abstractConfirmView {
    DDLogVerbose(@"%@ didTapCancel: %@", LOG_TAG, abstractConfirmView);
    
    if ([abstractConfirmView isKindOfClass:[DefaultConfirmView class]]) {
        if (self.captureSession) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self.captureSession startRunning];
            });
        } else {
            [self setupCaptureSession];
        }
    }
    
    [abstractConfirmView closeConfirmView];
}

- (void)didClose:(nonnull AbstractConfirmView *)abstractConfirmView {
    DDLogVerbose(@"%@ didClose: %@", LOG_TAG, abstractConfirmView);
    
    [abstractConfirmView closeConfirmView];
}

- (void)didFinishCloseAnimation:(nonnull AbstractConfirmView *)abstractConfirmView {
    DDLogVerbose(@"%@ didFinishCloseAnimation: %@", LOG_TAG, abstractConfirmView);
    
    [abstractConfirmView removeFromSuperview];
    
    if (self.proxyToAdd) {
        self.proxyToAdd = nil;
    }
    
    if (self.resetInvitationConfirmView) {
        self.resetInvitationConfirmView = nil;
    }
}

#pragma mark - SuccessAuthentifiedRelationDelegate

- (void)closeSuccessAuthentifiedRelation {
    DDLogVerbose(@"%@ closeSuccessAuthentifiedRelation", LOG_TAG);
    
    if (self.captureSession) {
        self.highlightView.frame = CGRectZero;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self.captureSession startRunning];
        });
    } else {
        [self setupCaptureSession];
    }
}

#pragma mark - CustomTabViewDelegate

- (void)didSelectTab:(UICustomTab *)uiCustomTab {
    DDLogVerbose(@"%@ didSelectTab: %@", LOG_TAG, uiCustomTab);
    
    [self hapticFeedBack:UIImpactFeedbackStyleHeavy];
    
    self.invitationMode = uiCustomTab.tag;
    
    [self updateViews];
}

#pragma mark - Private methods

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    [self.view setBackgroundColor:Design.GREY_BACKGROUND_COLOR];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    tapGesture.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGesture];
    
    if (self.invitationMode == InvitationModeOnlyInvite) {
        [self setNavigationTitle:TwinmeLocalizedString(@"import_privilege_card_view_controller_title", nil)];
    } else {
        [self setNavigationTitle:TwinmeLocalizedString(@"main_view_controller_add_contact", nil)];
    }
    
    self.profileViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.profileViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    
    self.customTabViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.customTabViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    if (self.invitationMode == InvitationModeOnlyInvite) {
        self.customTabContainerView.hidden = YES;
        self.profileViewTopConstraint.constant = DESIGN_PROFILE_TOP_MARGIN * Design.HEIGHT_RATIO;
    } else {
        self.profileViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    }
    
    self.profileView.userInteractionEnabled = YES;
    UITapGestureRecognizer *profileGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleProfileTapGesture:)];
    [self.profileView addGestureRecognizer:profileGestureRecognizer];
    
    self.twincodeViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.twincodeViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.twincodeViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.twincodeView.backgroundColor = Design.POPUP_BACKGROUND_COLOR;
    self.twincodeView.clipsToBounds = YES;
    
    CALayer *twincodeViewLayer = self.twincodeView.layer;
    twincodeViewLayer.shadowOpacity = Design.SHADOW_OPACITY;
    twincodeViewLayer.shadowOffset = Design.SHADOW_OFFSET;
    twincodeViewLayer.shadowRadius = Design.SHADOW_RADIUS;
    twincodeViewLayer.shadowColor = Design.SHADOW_COLOR_DEFAULT.CGColor;
    twincodeViewLayer.cornerRadius = Design.POPUP_RADIUS;
    twincodeViewLayer.masksToBounds = NO;
    
    self.avatarView.clipsToBounds = YES;
    self.avatarView.layer.cornerRadius = self.profileViewHeightConstraint.constant * 0.5;
    
    self.nameLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.nameLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    [self.nameLabel setFont:Design.FONT_MEDIUM32];
    self.nameLabel.textColor = Design.FONT_COLOR_DEFAULT;
    
    self.messageLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.messageLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.messageLabelTopConstraint.constant *= Design.MIN_RATIO;
    self.messageLabelBottomConstraint.constant *= Design.MIN_RATIO;
    
    [self.messageLabel setFont:Design.FONT_REGULAR28];
    self.messageLabel.textColor = Design.FONT_COLOR_GREY;
    
    if (self.invitationMode == InvitationModeOnlyInvite) {
        self.messageLabel.text = TwinmeLocalizedString(@"twincode_view_controller_message", nil);
    } else {
        self.messageLabel.text = TwinmeLocalizedString(@"add_contact_view_controller_message", nil);
    }
    
    self.qrcodeViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.qrcodeViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.qrcodeView.userInteractionEnabled = YES;
    self.qrcodeView.isAccessibilityElement = YES;
    UITapGestureRecognizer *qrCodeGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleQRCodeTapGesture:)];
    [self.qrcodeView addGestureRecognizer:qrCodeGestureRecognizer];
    
    self.twincodeLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.twincodeLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.twincodeLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.twincodeLabelHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.twincodeLabel.font = Design.FONT_BOLD34;
    self.twincodeLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.twincodeLabel.numberOfLines = 1;
    [self.twincodeLabel setAdjustsFontSizeToFitWidth:YES];
    self.twincodeLabel.userInteractionEnabled = YES;
    [self.twincodeLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleCopyTwincodeTapGesture:)]];
    
    self.zoomViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.zoomViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.zoomViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.zoomView.clipsToBounds = YES;
    self.zoomView.backgroundColor = Design.WHITE_COLOR;
    self.zoomView.layer.cornerRadius = self.zoomViewHeightConstraint.constant * 0.5;
    self.zoomView.layer.borderColor = Design.GREY_ITEM.CGColor;
    self.zoomView.layer.borderWidth = 1.0;
    self.zoomView.isAccessibilityElement = YES;
    
    UITapGestureRecognizer *zoomGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleQRCodeTapGesture:)];
    [self.zoomView addGestureRecognizer:zoomGestureRecognizer];
    
    self.zoomImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.zoomImageView.tintColor = Design.BLACK_COLOR;
    
    self.saveViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.saveViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.saveView.isAccessibilityElement = YES;
    UITapGestureRecognizer *saveCodeGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSaveQRCodeTapGesture:)];
    [self.saveView addGestureRecognizer:saveCodeGestureRecognizer];
    self.saveView.accessibilityLabel = TwinmeLocalizedString(@"application_save", nil);
    
    self.saveRoundedViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.saveRoundedView.clipsToBounds = YES;
    self.saveRoundedView.backgroundColor = Design.WHITE_COLOR;
    self.saveRoundedView.layer.cornerRadius = self.saveRoundedViewHeightConstraint.constant * 0.5;
    self.saveRoundedView.layer.borderColor = Design.GREY_ITEM.CGColor;
    self.saveRoundedView.layer.borderWidth = 1.0;
    
    self.saveImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.saveImageView.tintColor = Design.BLACK_COLOR;
    
    self.saveLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.saveLabel.font = Design.FONT_MEDIUM28;
    self.saveLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.saveLabel.text = TwinmeLocalizedString(@"application_save", nil);
    
    self.generateViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.generateViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.generateView.isAccessibilityElement = YES;
    self.generateView.accessibilityLabel = TwinmeLocalizedString(@"main_view_controller_reset_conversation", nil);
    UITapGestureRecognizer *generateCodeGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGenerateTwincodeTapGesture:)];
    [self.generateView addGestureRecognizer:generateCodeGestureRecognizer];
    
    self.generateRoundedViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.generateRoundedView.clipsToBounds = YES;
    self.generateRoundedView.backgroundColor = Design.WHITE_COLOR;
    self.generateRoundedView.layer.cornerRadius = self.generateRoundedViewHeightConstraint.constant * 0.5;
    self.generateRoundedView.layer.borderColor = Design.GREY_ITEM.CGColor;
    self.generateRoundedView.layer.borderWidth = 1.0;
    
    self.generateImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.generateImageView.tintColor = Design.BLACK_COLOR;
    
    self.generateLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.generateLabel.font = Design.FONT_MEDIUM28;
    self.generateLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.generateLabel.text = TwinmeLocalizedString(@"main_view_controller_reset_conversation", nil);
    
    self.twincodeCopyViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.twincodeCopyView.isAccessibilityElement = YES;
    self.twincodeCopyView.accessibilityLabel = TwinmeLocalizedString(@"conversation_view_controller_menu_item_view_copy_title", nil);
    UITapGestureRecognizer *twincodeCopyCodeGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleCopyTwincodeTapGesture:)];
    [self.twincodeCopyView addGestureRecognizer:twincodeCopyCodeGestureRecognizer];
    
    self.twincodeCopyRoundedViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.twincodeCopyRoundedView.clipsToBounds = YES;
    self.twincodeCopyRoundedView.backgroundColor = Design.WHITE_COLOR;
    self.twincodeCopyRoundedView.layer.cornerRadius = self.twincodeCopyRoundedViewHeightConstraint.constant * 0.5;
    self.twincodeCopyRoundedView.layer.borderColor = Design.GREY_ITEM.CGColor;
    self.twincodeCopyRoundedView.layer.borderWidth = 1.0;
    
    self.twincodeCopyImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.twincodeCopyImageView.tintColor = Design.BLACK_COLOR;
    
    self.twincodeCopyLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.twincodeCopyLabel.font = Design.FONT_MEDIUM28;
    self.twincodeCopyLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.twincodeCopyLabel.text = TwinmeLocalizedString(@"conversation_view_controller_menu_item_view_copy_title", nil);
    
    self.shareViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.shareViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.shareViewBottomConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.shareView.isAccessibilityElement = YES;
    self.shareView.backgroundColor = Design.MAIN_COLOR;
    self.shareView.userInteractionEnabled = YES;
    self.shareView.layer.cornerRadius = self.shareViewHeightConstraint.constant * 0.5;
    self.shareView.clipsToBounds = YES;
    [self.shareView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSocialTapGesture)]];
    self.shareView.accessibilityLabel = TwinmeLocalizedString(@"share_view_controller_title", nil);
    
    self.shareImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.shareImageViewLeadingConstraint.constant = Design.BUTTON_PADDING;
    
    self.shareImageView.tintColor = [UIColor whiteColor];
    
    self.shareLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.shareLabelTrailingConstraint.constant = Design.BUTTON_PADDING;
    
    self.shareLabel.font = Design.FONT_MEDIUM36;
    self.shareLabel.textColor = [UIColor whiteColor];
    self.shareLabel.text = TwinmeLocalizedString(@"share_view_controller_title", nil);
    
    [self.shareLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    
    self.shareSubLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.shareSubLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.shareSubLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.shareSubLabel.font = Design.FONT_REGULAR24;
    self.shareSubLabel.textColor = Design.FONT_COLOR_GREY;
    self.shareSubLabel.text = TwinmeLocalizedString(@"add_contact_view_controller_social_subtitle", nil);
    
    [self.captureView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleCameraTapGesture:)]];
    self.captureView.hidden = YES;
    self.captureView.clipsToBounds = YES;
    self.captureView.layer.cornerRadius = Design.POPUP_RADIUS;
    
    self.messageScanViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.messageScanViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    
    self.messageScanImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.messageScanImageViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.messageScanImageView.tintColor = [UIColor whiteColor];
    
    self.messageScanLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.messageScanLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    [self.messageScanLabel setFont:Design.FONT_MEDIUM32];
    self.messageScanLabel.textColor = [UIColor whiteColor];
    self.messageScanLabel.text = TwinmeLocalizedString(@"add_contact_view_controller_scan_code", nil);
    
    self.messageNoPermissionScanLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    
    [self.messageNoPermissionScanLabel setFont:Design.FONT_MEDIUM32];
    self.messageNoPermissionScanLabel.textColor = [UIColor whiteColor];
    self.messageNoPermissionScanLabel.text = TwinmeLocalizedString(@"application_permission_scan_code", nil);
    self.messageNoPermissionScanLabel.hidden = YES;
    
    self.highlightView = [[UIView alloc] init];
    self.highlightView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
    self.highlightView.layer.borderColor = [UIColor greenColor].CGColor;
    self.highlightView.layer.borderWidth = DESIGN_HIGHLIGHT_VIEW_CORNER_RADIUS * Design.HEIGHT_RATIO;
    [self.captureView addSubview:self.highlightView];
    [self.captureView bringSubviewToFront:self.highlightView];
    
    self.importFromGalleryViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.importFromGalleryViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.importFromGalleryViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.importFromGalleryView.isAccessibilityElement = YES;
    self.importFromGalleryView.backgroundColor = Design.MAIN_COLOR;
    self.importFromGalleryView.userInteractionEnabled = YES;
    self.importFromGalleryView.hidden = YES;
    self.importFromGalleryView.clipsToBounds = YES;
    self.importFromGalleryView.layer.cornerRadius = self.importFromGalleryViewHeightConstraint.constant * 0.5;
    [self.importFromGalleryView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleImportQRCodeTapGesture:)]];
    self.importFromGalleryView.accessibilityLabel = TwinmeLocalizedString(@"add_contact_view_controller_gallery_title", nil);
    
    self.importFromGalleryImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.importFromGalleryImageViewLeadingConstraint.constant *= Design.HEIGHT_RATIO;
    self.importFromGalleryImageView.tintColor = [UIColor whiteColor];
    
    self.importFromGalleryLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.importFromGalleryLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.importFromGalleryLabel.font = Design.FONT_MEDIUM36;
    self.importFromGalleryLabel.textColor = [UIColor whiteColor];
    self.importFromGalleryLabel.text = TwinmeLocalizedString(@"add_contact_view_controller_gallery_title", nil);
    
    self.twincodePasteViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.twincodePasteViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.twincodePasteViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    
    self.twincodePasteView.backgroundColor = Design.POPUP_BACKGROUND_COLOR;
    self.twincodePasteView.layer.cornerRadius = Design.CONTAINER_RADIUS;
    self.twincodePasteView.clipsToBounds = YES;
    self.twincodePasteView.hidden = YES;
    
    self.twincodeTextFieldLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.twincodeTextFieldTrailingConstraint.constant = self.twincodeTextFieldLeadingConstraint.constant;
    self.twincodeTextField.font = Design.FONT_MEDIUM34;
    self.twincodeTextField.textColor = Design.FONT_COLOR_DEFAULT;
    self.twincodeTextField.tintColor = Design.FONT_COLOR_DEFAULT;
    self.twincodeTextField.overrideDeleteBackWard = NO;
    
    self.twincodeTextField.attributedPlaceholder = [[NSAttributedString alloc]initWithString:TwinmeLocalizedString(@"scan_view_controller_paste_code", nil) attributes:[NSDictionary dictionaryWithObject:Design.PLACEHOLDER_COLOR forKey:NSForegroundColorAttributeName]];
    [self.twincodeTextField setReturnKeyType:UIReturnKeyDone];
    self.twincodeTextField.delegate = self;
    [self.twincodeTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    self.twincodeInviteViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.twincodeInviteView.userInteractionEnabled = YES;
    self.twincodeInviteView.isAccessibilityElement = YES;
    [self.twincodeInviteView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTwincodeInviteTapGesture:)]];
    
    self.twincodeInviteImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.twincodeInviteImageView.clipsToBounds = YES;
    self.twincodeInviteImageView.layer.cornerRadius = self.twincodeInviteImageViewHeightConstraint.constant * 0.5;
    
    self.twincodePasteAddViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.twincodePasteAddView.userInteractionEnabled = NO;
    self.twincodePasteAddView.hidden = YES;
    self.twincodePasteAddView.clipsToBounds = YES;
    self.twincodePasteAddView.layer.cornerRadius = self.twincodePasteAddViewHeightConstraint.constant * 0.5;
    self.twincodePasteAddView.backgroundColor = Design.MAIN_COLOR;
    
    self.twincodePasteImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.twincodePasteImageView.tintColor = Design.BLACK_COLOR;
    
    self.invitationCodeViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.invitationCodeViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.invitationCodeViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.invitationCodeViewBottomConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.invitationCodeView.backgroundColor = Design.POPUP_BACKGROUND_COLOR;
    self.invitationCodeView.clipsToBounds = YES;
    self.invitationCodeView.layer.shadowOpacity = Design.SHADOW_OPACITY;
    self.invitationCodeView.layer.shadowOffset = Design.SHADOW_OFFSET;
    self.invitationCodeView.layer.shadowRadius = Design.SHADOW_RADIUS;
    self.invitationCodeView.layer.shadowColor = Design.SHADOW_COLOR_DEFAULT.CGColor;
    self.invitationCodeView.layer.cornerRadius = Design.POPUP_RADIUS;
    self.invitationCodeView.layer.masksToBounds = NO;
    
    [self.invitationCodeView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleInvitationCodeTapGesture:)]];
    
    self.invitationCodeImageViewLeading.constant *= Design.WIDTH_RATIO;
    self.invitationCodeImageViewHeight.constant *= Design.HEIGHT_RATIO;
    
    self.invitationCodeLabelLeading.constant *= Design.WIDTH_RATIO;
    self.invitationCodeLabelTrailing.constant *= Design.WIDTH_RATIO;
    
    self.invitationCodeLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.invitationCodeLabel.font = Design.FONT_MEDIUM34;
    self.invitationCodeLabel.text = TwinmeLocalizedString(@"add_contact_view_controller_invitation_code_title", nil);

    self.invitationCodeAccessoryViewTrailing.constant *= Design.WIDTH_RATIO;
    self.invitationCodeAccessoryViewHeight.constant *= Design.HEIGHT_RATIO;
    
    self.invitationCodeAccessoryView.tintColor = Design.BLACK_COLOR;
}

- (void)initCustomTab {
    DDLogVerbose(@"%@ initCustomTab", LOG_TAG);
    
    NSMutableArray *customTabs = [[NSMutableArray alloc]init];
    
    [customTabs addObject:[[UICustomTab alloc]initWithTitle:TwinmeLocalizedString(@"add_contact_view_controller_invite", nil) tag:InvitationModeInvite isSelected:self.invitationMode == InvitationModeInvite]];
    [customTabs addObject:[[UICustomTab alloc]initWithTitle:TwinmeLocalizedString(@"add_contact_view_controller_scan_title", nil) tag:InvitationModeScan isSelected:self.invitationMode == InvitationModeScan]];
    
    self.customTabView = [[CustomTabView alloc] initWithCustomTab:customTabs];
    self.customTabView.customTabViewDelegate = self;
    [self.customTabView updateColor:Design.GREY_BACKGROUND_COLOR mainColor:Design.GREY_BACKGROUND_COLOR textSelectedColor:Design.BLACK_COLOR borderColor:nil];
    [self.customTabContainerView addSubview:self.customTabView];
}

- (void)updateViews {
    DDLogVerbose(@"%@ updateViews", LOG_TAG);
    
    if (self.invitationMode == InvitationModeScan) {
        self.captureView.hidden = NO;
        self.twincodeView.hidden = YES;
        self.importFromGalleryView.hidden = NO;
        self.twincodePasteView.hidden = NO;
        self.messageLabel.hidden = YES;
        self.shareView.hidden = YES;
        self.shareLabel.hidden = YES;
        self.shareSubLabel.hidden = YES;
        
        if (self.captureSession) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self.captureSession startRunning];
            });
        } else {
            [self setupCaptureSession];
        }
        
        self.previewLayer.frame = self.captureView.bounds;
    } else {
        self.captureView.hidden = YES;
        self.twincodeView.hidden = NO;
        self.importFromGalleryView.hidden = YES;
        self.twincodePasteView.hidden = YES;
        self.messageLabel.hidden = NO;
        self.shareView.hidden = NO;
        self.shareLabel.hidden = NO;
        self.shareSubLabel.hidden = NO;
        if (self.captureSession) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self.captureSession stopRunning];
            });
        }
    }
}

- (void)finish {
    DDLogVerbose(@"%@ finish", LOG_TAG);
    
    // The peer has scanned our QR-code: we are done and can show the new contact.
    // (if we scan the others' QR-code we will end up in AcceptInvitationViewController.onCreateContact).
    if (self.contact) {
        [self showContactWithContact:self.contact popToRoot:NO];
        self.contact = nil;
    }
    
    if (self.shareProfileService) {
        [self.shareProfileService dispose];
        self.shareProfileService = nil;
    }
}

- (void)dismissKeyboard {
    DDLogVerbose(@"%@ dismissKeyboard", LOG_TAG);
    
    if (!self.keyboardHidden) {
        [self.twincodeTextField resignFirstResponder];
    }
}

- (void)handleDecode:(NSString *)decodedResult {
    DDLogVerbose(@"%@ handleDecode: %@ ", LOG_TAG, decodedResult);
    
    NSURL *url = [NSURL URLWithString:decodedResult];
    if (!url) {
        [self incorrectQRCode:-1];
        return;
    }
    
    [self.shareProfileService parseUriWithUri:url withBlock:^(TLBaseServiceErrorCode errorCode, TLTwincodeURI *uri) {
        if (errorCode != TLBaseServiceErrorCodeSuccess) {
            [self incorrectQRCode:errorCode];
            return;
        }
        [self didCaptureUrl:url twincodeUri:uri];
    }];
}

- (void)incorrectQRCode:(TLBaseServiceErrorCode)errorCode {
    DDLogVerbose(@"%@ incorrectQRCode", LOG_TAG);
    
    NSString *message;
    
    switch (errorCode) {
        case TLBaseServiceErrorCodeBadRequest:
            message = TwinmeLocalizedString(@"add_contact_view_controller_scan_error_incorect_link", nil);
            break;
            
        case TLBaseServiceErrorCodeFeatureNotImplemented:
            message = TwinmeLocalizedString(@"add_contact_view_controller_scan_error_not_managed_link", nil);
            break;
            
        case TLBaseServiceErrorCodeItemNotFound:
            message = TwinmeLocalizedString(@"add_contact_view_controller_scan_error_corrupt_link", nil);
            break;
            
        default:
            message = TwinmeLocalizedString(@"capture_view_controller_incorrect_qrcode", nil);
            break;
    }
    
    AlertMessageView *alertMessageView = [[AlertMessageView alloc] init];
    alertMessageView.alertMessageViewDelegate = self;
    [alertMessageView initWithTitle:TwinmeLocalizedString(@"delete_account_view_controller_warning", nil) message:message];
    [self.navigationController.view addSubview:alertMessageView];
    [alertMessageView showAlertView];
}

- (void)didCaptureUrl:(nonnull NSURL *)url twincodeUri:(nonnull TLTwincodeURI *)twincodeUri {
    DDLogVerbose(@"%@ didCaptureUrl: %@ twincodeUri: %@", LOG_TAG, url, twincodeUri);
    
    if (twincodeUri.kind == TLTwincodeURIKindInvitation) {
        AcceptInvitationViewController *acceptInvitationViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AcceptInvitationViewController"];
        [acceptInvitationViewController initWithProfile:self.profile url:url descriptorId:nil originatorId:nil isGroup:NO notification:nil popToRootViewController:YES];
        acceptInvitationViewController.acceptInvitationDelegate = self;
        [acceptInvitationViewController showInView:self.navigationController.view];
    } else if (twincodeUri.kind == TLTwincodeURIKindProxy) {
        [self showProxy:twincodeUri.twincodeOptions];
    } else if (twincodeUri.kind == TLTwincodeURIKindAuthenticate) {
        [self.shareProfileService verifyAuthenticateWithURI:url withBlock:^(TLBaseServiceErrorCode errorCode, TLContact *contact) {
            if (errorCode == TLBaseServiceErrorCodeSuccess) {
                [self.shareProfileService getImageWithContact:contact withBlock:^(UIImage *image) {
                    SuccessAuthentifiedRelationViewController *successAuthentifiedRelationViewController = [[UIStoryboard storyboardWithName:@"Contact" bundle:nil] instantiateViewControllerWithIdentifier:@"SuccessAuthentifiedRelationViewController"];
                    successAuthentifiedRelationViewController.successAuthentifiedRelationDelegate = self;
                    [successAuthentifiedRelationViewController initWithName:contact.name avatar:image];
                    [successAuthentifiedRelationViewController showInView:self.navigationController];
                }];
            } else {
                [self incorrectQRCode:TLBaseServiceErrorCodeBadRequest];
            }
        }];
    } else {
        NSString *message = TwinmeLocalizedString(@"capture_view_controller_incorrect_qrcode", nil);
        
        switch (twincodeUri.kind) {
            case TLTwincodeURIKindCall:
                message = TwinmeLocalizedString(@"add_contact_view_controller_scan_message_call_link", nil);
                break;
                
            case TLTwincodeURIKindAccountMigration:
                message = TwinmeLocalizedString(@"add_contact_view_controller_scan_message_migration_link", nil);
                break;
                
            case TLTwincodeURIKindTransfer:
                message = TwinmeLocalizedString(@"add_contact_view_controller_scan_message_transfer_link", nil);
                break;
                
            default:
                break;
        }
        
        AlertMessageView *alertMessageView = [[AlertMessageView alloc] init];
        alertMessageView.alertMessageViewDelegate = self;
        [alertMessageView initWithTitle:TwinmeLocalizedString(@"delete_account_view_controller_warning", nil) message:message];
        [self.navigationController.view addSubview:alertMessageView];
        [alertMessageView showAlertView];
    }
}

- (void)handleCameraTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleCameraTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        NSError *error = nil;
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
        if (!input) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
        }
    }
}

- (void)handleSaveQRCodeTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleSaveQRCodeTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        
        [self hapticFeedBack:UIImpactFeedbackStyleHeavy];
        
        self.saveQRCodeInGallery = YES;
        [self saveQRCodeWithPermissionCheck];
    }
}

- (void)handleProfileTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleProfileTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        ShowProfileViewController *showProfileViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ShowProfileViewController"];
        [showProfileViewController initWithProfile:self.profile isActive:YES];
        [self.navigationController pushViewController:showProfileViewController animated:YES];
    }
}

- (void)saveQRCodeWithPermissionCheck {
    DDLogVerbose(@"%@ saveQRCodeWithPermissionCheck", LOG_TAG);
    
    PHAuthorizationStatus photoAuthorizationStatus = [DeviceAuthorization devicePhotoAuthorizationStatus];
    switch (photoAuthorizationStatus) {
        case PHAuthorizationStatusNotDetermined: {
            if (@available(iOS 14, *)) {
                [PHPhotoLibrary requestAuthorizationForAccessLevel:PHAccessLevelAddOnly handler:^(PHAuthorizationStatus authorizationStatus) {
                    if ([DeviceAuthorization devicePhotoAuthorizationAccessGranted:authorizationStatus]) {
                        dispatch_async(dispatch_get_main_queue(), ^(void) {
                            [self saveQRCode];
                        });
                    }
                }];
            } else {
                [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus authorizationStatus) {
                    if ([DeviceAuthorization devicePhotoAuthorizationAccessGranted:authorizationStatus]) {
                        dispatch_async(dispatch_get_main_queue(), ^(void) {
                            [self saveQRCode];
                        });
                    }
                }];
            }
            break;
        }
            
        case PHAuthorizationStatusRestricted:
        case PHAuthorizationStatusDenied:
            [DeviceAuthorization showPhotoSettingsAlertInController:self];
            break;
            
        case PHAuthorizationStatusAuthorized:
        case PHAuthorizationStatusLimited:
            [self saveQRCode];
            break;
    }
}

- (void)saveQRCode {
    DDLogVerbose(@"%@ saveQRCode", LOG_TAG);
    
    [self.shareProfileService getImageWithProfile:self.profile withBlock:^(UIImage *image) {
        [self saveQRCodeWithAvatar:image];
    }];
}

- (void)saveQRCodeWithAvatar:(nonnull UIImage *)avatar {
    DDLogVerbose(@"%@ saveQRCodeWithAvatar", LOG_TAG);
    
    UIImage *qrcodeToSave;
    TwincodeView *twincodeView;
    
    if (self.profile) {
        twincodeView = [[TwincodeView alloc] initWithName:self.profile.name avatar:avatar qrcode:self.qrcodeView.image twincodeId:self.profile.twincodeOutbound.uuid];
        qrcodeToSave = [twincodeView screenshot];
    }
    
    if (!qrcodeToSave) {
        return;
    }
    
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title = %@", TwinmeLocalizedString(@"application_name", nil)];
    PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
    fetchOptions.predicate = predicate;
    PHFetchResult *result = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAny options:fetchOptions];
    
    twincodeView = nil;
    
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        PHAssetCollectionChangeRequest *albumRequest;
        if (result.count == 0) {
            albumRequest = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:TwinmeLocalizedString(@"application_name", nil)];
        } else {
            albumRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:result.firstObject];
        }
        PHAssetChangeRequest *createImageRequest = [PHAssetChangeRequest creationRequestForAssetFromImage:qrcodeToSave];
        [albumRequest addAssets:@[createImageRequest.placeholderForCreatedAsset]];
    } completionHandler:^(BOOL success, NSError *error) {
        if (success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.saveQRCodeInGallery = NO;
                [[UIApplication sharedApplication].keyWindow makeToast:TwinmeLocalizedString(@"capture_view_controller_qrcode_saved",nil)];
            });
        }
    }];
}

- (void)handleGenerateTwincodeTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleGenerateTwincodeTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        
        [self hapticFeedBack:UIImpactFeedbackStyleHeavy];
        [self openResetInvitationConfirmView:self.avatarView.image];
    }
}

- (void)handleCopyTwincodeTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleCopyTwincodeTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded && self.uri) {
        [self hapticFeedBack:UIImpactFeedbackStyleHeavy];
        [[UIPasteboard generalPasteboard] setString:self.uri.uri];
        [[UIApplication sharedApplication].keyWindow makeToast:TwinmeLocalizedString(@"conversation_view_controller_menu_item_view_copy_message",nil)];
    }
}

- (void)handleSocialTapGesture {
    DDLogVerbose(@"%@ handleSocialTapGesture", LOG_TAG);
    
    [self hapticFeedBack:UIImpactFeedbackStyleHeavy];
    
    // To avoid hyperlink injections in names, we replace '.' and ':' into special UTF-8 characters
    // that also visually correspond to '.' and ':'.  These two replacements allow to break
    // hyperlink recognition and forwarding.  Even cut&paste will not allow to follow such link.
    NSString *name = [self.profile.name stringByReplacingOccurrencesOfString:@"." withString:@"\u2024"];
    name = [name stringByReplacingOccurrencesOfString:@":" withString:@"\u02d0"];
    NSString *message = [NSString stringWithFormat:TwinmeLocalizedString(@"add_contact_view_controller_invite_message %@ %@", nil), self.uri.uri, name];
    
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[message] applicationActivities:nil];
    activityViewController.excludedActivityTypes = @[UIActivityTypeAirDrop,
                                                     UIActivityTypePrint,
                                                     UIActivityTypeAssignToContact,
                                                     UIActivityTypeSaveToCameraRoll,
                                                     UIActivityTypeAddToReadingList,
                                                     UIActivityTypePostToFlickr,
                                                     UIActivityTypePostToVimeo];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self presentViewController:activityViewController animated:YES completion:nil];
    } else {
        activityViewController.modalPresentationStyle = UIModalPresentationPopover;
        activityViewController.popoverPresentationController.sourceView = self.view;
        activityViewController.popoverPresentationController.sourceRect = CGRectMake(self.view.frame.size.width/2, self.view.frame.size.height/4, 0, 0);
        activityViewController.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionAny;
        [self presentViewController:activityViewController animated:YES completion:nil];
    }
}

- (void)handleQRCodeTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleQRCodeTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        [self updateQRCodeSize];
    }
}

- (void)handleImportQRCodeTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleImportQRCodeTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        
        [self hapticFeedBack:UIImpactFeedbackStyleHeavy];
        
        UIImagePickerController *mediaPicker = [[UIImagePickerController alloc] init];
        mediaPicker.delegate = self;
        mediaPicker.modalPresentationStyle = UIModalPresentationCurrentContext;
        mediaPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:mediaPicker animated:YES completion:nil];
    }
}

- (void)handleTwincodeInviteTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleTwincodeInviteTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        
        [self hapticFeedBack:UIImpactFeedbackStyleHeavy];
        
        if (![self.twincodeTextField.text isEqualToString:@""]) {
            [self.twincodeTextField resignFirstResponder];
            [self handleDecode:self.twincodeTextField.text];
        }
    }
}

- (void)handleInvitationCodeTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleTwincodeInviteTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        
        [self hapticFeedBack:UIImpactFeedbackStyleHeavy];
        
        if (self.invitationMode == InvitationModeScan) {
            EnterInvitationCodeViewController *enterInvitationCodeViewController = [[UIStoryboard storyboardWithName:@"Contact" bundle:nil] instantiateViewControllerWithIdentifier:@"EnterInvitationCodeViewController"];
            [self.navigationController pushViewController:enterInvitationCodeViewController animated:YES];
        } else {
            InvitationCodeViewController *invitationCodeViewController = [[UIStoryboard storyboardWithName:@"Contact" bundle:nil] instantiateViewControllerWithIdentifier:@"InvitationCodeViewController"];
            [self.navigationController pushViewController:invitationCodeViewController animated:YES];
        }
    }
}

- (void)openResetInvitationConfirmView:(UIImage *)avatar {
    DDLogVerbose(@"%@ openResetInvitationConfirmView", LOG_TAG);
    
    self.resetInvitationConfirmView = [[ResetInvitationConfirmView alloc] init];
    self.resetInvitationConfirmView.confirmViewDelegate = self;
    [self.resetInvitationConfirmView initWithTitle:TwinmeLocalizedString(@"delete_account_view_controller_warning", nil) message:TwinmeLocalizedString(@"fullscreen_qrcode_view_controller_generate_code_message", nil) avatar:avatar icon:[UIImage imageNamed:@"GenerateCode"]];
    [self.tabBarController.view addSubview:self.resetInvitationConfirmView];
    [self.resetInvitationConfirmView showConfirmView];
}

- (void)showProxy:(NSString *)proxy {
    DDLogVerbose(@"%@ showProxy: %@", LOG_TAG, proxy);
    
    NSMutableArray *proxies = [[self.twinmeContext getConnectivityService] getUserProxies];
    
    if (proxies.count  >= [TLConnectivityService MAX_PROXIES]) {
        AlertMessageView *alertMessageView = [[AlertMessageView alloc] init];
        alertMessageView.alertMessageViewDelegate = self;
        [alertMessageView initWithTitle:TwinmeLocalizedString(@"delete_account_view_controller_warning", nil) message:[NSString stringWithFormat:TwinmeLocalizedString(@"proxy_view_controller_limit", nil), [TLConnectivityService MAX_PROXIES]]];
        [self.tabBarController.view addSubview:alertMessageView];
        [alertMessageView showAlertView];
        return;
    }
        
    for (TLProxyDescriptor *proxyDescriptor in proxies) {
        if ([proxyDescriptor.description caseInsensitiveCompare:proxy] == NSOrderedSame) {
            AlertMessageView *alertMessageView = [[AlertMessageView alloc] init];
            alertMessageView.alertMessageViewDelegate = self;
            [alertMessageView initWithTitle:TwinmeLocalizedString(@"delete_account_view_controller_warning", nil) message:[NSString stringWithFormat:TwinmeLocalizedString(@"proxy_view_controller_already_use", nil), [TLConnectivityService MAX_PROXIES]]];
            [self.tabBarController.view addSubview:alertMessageView];
            [alertMessageView showAlertView];
            return;
        }
    }
    
    self.proxyToAdd = proxy;
    
    DefaultConfirmView *defaultConfirmView = [[DefaultConfirmView alloc] init];
    defaultConfirmView.confirmViewDelegate = self;

    [defaultConfirmView initWithTitle:TwinmeLocalizedString(@"proxy_view_controller_title", nil) message:TwinmeLocalizedString(@"proxy_view_controller_url", nil) image:[UIImage imageNamed:@"OnboardingProxy"] avatar:nil action: TwinmeLocalizedString(@"proxy_view_controller_enable", nil) actionColor:nil cancel:TwinmeLocalizedString(@"application_cancel", nil)];

    NSMutableAttributedString *attributedTitle = [[NSMutableAttributedString alloc] initWithString:TwinmeLocalizedString(@"proxy_view_controller_title", nil) attributes:[NSDictionary dictionaryWithObjectsAndKeys:Design.FONT_BOLD36, NSFontAttributeName, Design.FONT_COLOR_DEFAULT, NSForegroundColorAttributeName, nil]];
    [attributedTitle appendAttributedString:[[NSMutableAttributedString alloc] initWithString:@"\n\n"]];
    [attributedTitle appendAttributedString:[[NSMutableAttributedString alloc] initWithString:self.proxyToAdd attributes:[NSDictionary dictionaryWithObjectsAndKeys:Design.FONT_MEDIUM34, NSFontAttributeName, Design.FONT_COLOR_GREY, NSForegroundColorAttributeName, nil]]];
    
    [defaultConfirmView updateTitle:attributedTitle];
    
    [self.tabBarController.view addSubview:defaultConfirmView];
    [defaultConfirmView showConfirmView];
}

- (void)addProxy {
    DDLogVerbose(@"%@ addProxy", LOG_TAG);
    
    if (!self.proxyToAdd) {
        return;
    }
    
    NSMutableArray *proxies = [[self.twinmeContext getConnectivityService] getUserProxies];
    TLSNIProxyDescriptor *proxy = [TLSNIProxyDescriptor createWithProxyDescription:self.proxyToAdd];
    [proxies addObject:proxy];
    [[self.twinmeContext getConnectivityService] saveWithUserProxies:proxies];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        SettingsAdvancedViewController *settingsAdvancedViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SettingsAdvancedViewController"];
        [self.navigationController pushViewController:settingsAdvancedViewController animated:YES];
    });
}

- (void)updateProfile {
    DDLogVerbose(@"%@ updateProfile", LOG_TAG);
    
    [self.shareProfileService getImageWithProfile:self.profile withBlock:^(UIImage *image) {
        self.avatarView.image = image;
    }];
    if (self.uri) {
        self.qrcodeView.image = [Utils makeQRCodeWithUri:self.uri scale:10];
    }
    self.nameLabel.text = self.profile.name;
    self.twincodeLabel.text = self.uri.label;
}

- (void)updateQRCodeSize {
    DDLogVerbose(@"%@ updateProfile", LOG_TAG);
    
    self.zoomQRCode = !self.zoomQRCode;
    float alpha = self.zoomQRCode ? 0.0 : 1.0;
    
    CGFloat qrCodeHeight = self.zoomQRCode ? self.qrCodeMaxHeight : self.qrCodeInitialHeight;
    CGFloat qrCodeTop = self.zoomQRCode ? (self.twincodeViewHeightConstraint.constant - self.qrCodeMaxHeight) * 0.5f : self.qrCodeInitialTop;
    CGFloat animateActionDelay = self.zoomQRCode ? 0.f : 0.1f;
    CGFloat animateQRCodeDelay = self.zoomQRCode ? 0.1f : 0.f;
   
    [self animateQRCodeAction:alpha delay:animateActionDelay];
    [self animateQRCodeSize:qrCodeTop height:qrCodeHeight delay:animateQRCodeDelay];
}

- (void)animateQRCodeAction:(CGFloat)alpha delay:(CGFloat)delay {
    DDLogVerbose(@"%@ animateQRCodeAction", LOG_TAG);
        
    [UIView animateWithDuration:0.1 delay:delay options: UIViewAnimationOptionCurveEaseInOut animations:^{
        self.twincodeCopyView.alpha = alpha;
        self.generateView.alpha = alpha;
        self.saveView.alpha = alpha;
        self.zoomView.alpha = alpha;
        self.twincodeLabel.alpha = alpha;
    } completion:^(BOOL finished) {
    }];
}

- (void)animateQRCodeSize:(CGFloat)top height:(CGFloat)height delay:(CGFloat)delay {
    DDLogVerbose(@"%@ animateQRCodeSize", LOG_TAG);
    
    [UIView animateWithDuration:0.1 delay:delay options: UIViewAnimationOptionCurveEaseInOut animations:^{
        self.qrcodeViewTopConstraint.constant = top;
        self.qrcodeViewHeightConstraint.constant = height;
        
        [self.view setNeedsLayout];
        [self.view layoutIfNeeded];
        
    } completion:^(BOOL finished) {
    }];
}

- (void)updateTwincodeHeight {
    DDLogVerbose(@"%@ updateTwincodeHeight", LOG_TAG);

    CGFloat messageWidth = Design.DISPLAY_WIDTH - self.messageLabelLeadingConstraint.constant - self.messageLabelTrailingConstraint.constant;
    CGRect messageRect = [self.messageLabel.text boundingRectWithSize:CGSizeMake(messageWidth, MAXFLOAT) options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) attributes:@{
        NSFontAttributeName : Design.FONT_REGULAR28
    } context:nil];
            
    CGFloat shareLabelWidth = Design.DISPLAY_WIDTH - self.shareSubLabelLeadingConstraint.constant - self.shareSubLabelTrailingConstraint.constant;
    CGRect shareLabelRect = [self.shareSubLabel.text boundingRectWithSize:CGSizeMake(shareLabelWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{
        NSFontAttributeName : Design.FONT_REGULAR24
    } context:nil];
    
    CGFloat spaceAboveInvitationCodeView = 0;
    if (messageRect.size.height > self.twincodePasteViewHeightConstraint.constant) {
        spaceAboveInvitationCodeView = shareLabelRect.size.height + self.shareSubLabelTopConstraint.constant + self.importFromGalleryViewHeightConstraint.constant * 0.5f + self.messageLabelTopConstraint.constant + messageRect.size.height;
    } else {
        spaceAboveInvitationCodeView = shareLabelRect.size.height + self.shareSubLabelTopConstraint.constant + self.importFromGalleryViewHeightConstraint.constant * 0.5f + self.messageLabelTopConstraint.constant + self.twincodePasteViewHeightConstraint.constant;
    }
                    
    CGFloat customTabViewHeight = self.profileViewTopConstraint.constant;
    if (self.invitationMode != InvitationModeOnlyInvite) {
        customTabViewHeight = self.customTabViewHeightConstraint.constant;
    }

    CGFloat maxHeight = self.view.safeAreaLayoutGuide.layoutFrame.size.height - customTabViewHeight - self.profileViewHeightConstraint.constant - self.twincodeViewTopConstraint.constant - spaceAboveInvitationCodeView - self.invitationCodeViewTopConstraint.constant - self.invitationCodeViewHeightConstraint.constant - self.invitationCodeViewBottomConstraint.constant;
            
    self.twincodeViewHeightConstraint.constant = maxHeight;
    
    self.twincodePasteViewTopConstraint.constant = spaceAboveInvitationCodeView - self.twincodePasteViewHeightConstraint.constant;
        
    CGFloat qrCodeHeight = maxHeight - self.qrcodeViewTopConstraint.constant - self.twincodeLabelTopConstraint.constant - self.twincodeLabelHeightConstraint.constant - self.generateViewTopConstraint.constant - self.generateViewHeightConstraint.constant - self.shareViewHeightConstraint.constant;
    
    if (qrCodeHeight + (self.zoomViewHeightConstraint.constant * 2) > self.twincodeViewWidthConstraint.constant) {
        qrCodeHeight = qrCodeHeight - (self.zoomViewHeightConstraint.constant * 2);
    }
    
    self.qrCodeInitialHeight = qrCodeHeight;
    self.qrcodeViewHeightConstraint.constant = qrCodeHeight;
    
    CGFloat twincodeViewContentHeight = qrCodeHeight + self.twincodeLabelTopConstraint.constant + self.twincodeLabelHeightConstraint.constant + self.generateViewTopConstraint.constant + self.generateViewHeightConstraint.constant + self.shareViewHeightConstraint.constant;

    self.qrCodeInitialTop = MAX(DESIGN_QRCODE_TOP_MARGIN * Design.HEIGHT_RATIO, (maxHeight - twincodeViewContentHeight) * 0.5f);

    self.qrcodeViewTopConstraint.constant = self.qrCodeInitialTop;
    
    CGFloat qrCodeMaxHeight = self.twincodeViewWidthConstraint.constant - self.twincodeLabelLeadingConstraint.constant - self.twincodeLabelTrailingConstraint.constant;
    
    if (qrCodeMaxHeight > (maxHeight - (self.shareViewBottomConstraint.constant * 2))) {
        qrCodeMaxHeight = maxHeight - (self.shareViewBottomConstraint.constant * 2);
    }
    
    self.qrCodeMaxHeight = qrCodeMaxHeight;
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    [self.messageScanLabel setFont:Design.FONT_MEDIUM32];
    [self.messageNoPermissionScanLabel setFont:Design.FONT_MEDIUM32];
    [self.nameLabel setFont:Design.FONT_MEDIUM32];
    [self.saveLabel setFont:Design.FONT_MEDIUM28];
    [self.generateLabel setFont:Design.FONT_MEDIUM28];
    self.twincodeLabel.font = Design.FONT_BOLD34;
    [self.messageLabel setFont:Design.FONT_REGULAR28];
    [self.shareLabel setFont:Design.FONT_MEDIUM32];
    self.shareSubLabel.font = Design.FONT_REGULAR24;
    [self.importFromGalleryLabel setFont:Design.FONT_MEDIUM32];
    self.twincodeTextField.font = Design.FONT_MEDIUM34;
    self.invitationCodeLabel.font = Design.FONT_MEDIUM34;
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    [self.view setBackgroundColor:Design.GREY_BACKGROUND_COLOR];
    self.nameLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.avatarView.layer.borderColor = Design.WHITE_COLOR.CGColor;
    self.twincodeView.backgroundColor = Design.POPUP_BACKGROUND_COLOR;
    self.messageLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.saveLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.generateLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.twincodeLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.shareSubLabel.textColor = Design.FONT_COLOR_GREY;
    self.invitationCodeView.backgroundColor = Design.POPUP_BACKGROUND_COLOR;
    self.invitationCodeAccessoryView.tintColor = Design.BLACK_COLOR;
    self.invitationCodeLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.twincodeCopyImageView.tintColor = Design.BLACK_COLOR;
    self.twincodePasteAddView.backgroundColor = Design.MAIN_COLOR;
    
    self.twincodeTextField.attributedPlaceholder = [[NSAttributedString alloc]initWithString:TwinmeLocalizedString(@"scan_view_controller_paste_code", nil) attributes:[NSDictionary dictionaryWithObject:Design.PLACEHOLDER_COLOR forKey:NSForegroundColorAttributeName]];
}

@end
