/*
 *  Copyright (c) 2023 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

@import AVFoundation;

#import <CocoaLumberjack.h>

#import <Twinlife/TLTwinlife.h>

#import <Twinme/TLProfile.h>

#import <Utils/NSString+Utils.h>

#import "InvitationSubscriptionViewController.h"
#import "AcceptInvitationSubscriptionViewController.h"

#import "AlertMessageView.h"
#import <TwinmeCommon/Design.h>
#import "DeviceAuthorization.h"
#import "TwincodeView.h"
#import "UIView+Toast.h"
#import "TwinmeTextField.h"

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static const CGFloat DESIGN_HIGHLIGHT_VIEW_CORNER_RADIUS = 4;

static UIColor *DESIGN_PLACEHOLDER_COLOR;

//
// Interface: InvitationSubscriptionViewController ()
//

@interface InvitationSubscriptionViewController () <AVCaptureMetadataOutputObjectsDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, AlertMessageViewDelegate, AcceptInvitationSubscriptionDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageLabelTopConstraint;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *captureViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *captureViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *captureViewWidthConstraint;
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
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *twincodeViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *twincodeViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *twincodeViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *twincodeView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *twincodeTextFieldLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *twincodeTextFieldTrailingConstraint;
@property (weak, nonatomic) IBOutlet TwinmeTextField *twincodeTextField;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *twincodeInviteViewWidthConstraint;
@property (weak, nonatomic) IBOutlet UIView *twincodeInviteView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *twincodeInviteImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *twincodeInviteImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *twincodeCopyImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *twincodeCopyImageViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *twincodeCopyImageView;

@property UIView *highlightView;
@property AVCaptureSession *captureSession;
@property AVCaptureVideoPreviewLayer *previewLayer;

@property (nonatomic) BOOL keyboardHidden;
@property (nonatomic) CGFloat yOffset;

@end

//
// Implementation: InvitationSubscriptionViewController
//

#undef LOG_TAG
#define LOG_TAG @"InvitationSubscriptionViewController"

@implementation InvitationSubscriptionViewController

+ (void)initialize {
    DDLogVerbose(@"%@ initialize", LOG_TAG);
    
    DESIGN_PLACEHOLDER_COLOR = [UIColor colorWithRed:32./255. green:41./255 blue:73./255 alpha:0.3];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    DDLogVerbose(@"%@ initWithCoder: %@", LOG_TAG, coder);
    
    self = [super initWithCoder:coder];
    
    if (self) {
        _keyboardHidden = YES;
        _yOffset = 0;
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didPasteItemNotification:) name:TwinmeTextFieldDidPasteItemNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    DDLogVerbose(@"%@ viewWillDisappear: %@", LOG_TAG, animated ? @"YES" : @"NO");
    
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TwinmeTextFieldDidPasteItemNotification object:nil];
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
        self.previewLayer.cornerRadius = Design.CONTAINER_RADIUS;
        [self.captureView.layer insertSublayer:self.previewLayer atIndex:0];
        [self.captureView bringSubviewToFront:self.highlightView];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self.captureSession startRunning];
        });
        
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    DDLogVerbose(@"%@ textFieldShouldReturn: %@", LOG_TAG, textField);
    
    [textField resignFirstResponder];
    return NO;
}

- (void)textFieldDidChange:(UITextField *)textField{
    DDLogVerbose(@"%@ textFieldDidChange: %@", LOG_TAG, textField);
    
    if (![self.twincodeTextField.text isEqualToString:@""]) {
        self.twincodeInviteImageView.hidden = NO;
        self.twincodeTextFieldTrailingConstraint.constant = self.twincodeInviteViewWidthConstraint.constant;
    } else {
        self.twincodeInviteImageView.hidden = YES;
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
    CGRect twincodeViewFrame = self.twincodeView.frame;
    CGRect frame = self.view.frame;
    self.yOffset = frame.origin.y;
    CGFloat offset = keyboardSize.height - (frame.size.height - (twincodeViewFrame.origin.y + twincodeViewFrame.size.height + 24.0 * Design.HEIGHT_RATIO));
    frame.origin.y -= offset;
    self.view.frame = frame;
    
    if ([self.twinmeApplication getDefaultKeyboardHeight] != keyboardSize.height) {
        [self.twinmeApplication setDefaultKeyboardHeight:keyboardSize.height];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification {
    DDLogVerbose(@"%@ keyboardWillHide: %@", LOG_TAG, notification);
    
    self.keyboardHidden = YES;
    
    CGRect frame = self.view.frame;
    frame.origin.y = self.yOffset;
    self.view.frame = frame;
}

- (void)didPasteItemNotification:(NSNotification *)notification {
    DDLogVerbose(@"%@ didPasteItemNotification: %@", LOG_TAG, notification);
    
    NSString *pastedContent = (NSString *)notification.object;
    if (pastedContent) {
        NSString *prefix = [NSString stringWithFormat:@"https://invite.%@/?skredcodeId=", [TLTwinlife TWINLIFE_DOMAIN]];
        if ([pastedContent containsString:prefix]) {
            self.twincodeTextField.text = [pastedContent stringByReplacingOccurrencesOfString:prefix withString:@""];
        } else {
            self.twincodeTextField.text = pastedContent;
        }
        
        self.twincodeInviteImageView.hidden = NO;
        self.twincodeTextFieldTrailingConstraint.constant = self.twincodeInviteViewWidthConstraint.constant;
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
            [self incorrectQRCode];
        }
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    DDLogVerbose(@"%@ imagePickerControllerDidCancel: %@", LOG_TAG, picker);
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - AcceptInvitationSubscriptionDelegate Methods

- (void)invitationSubscriptionDidFinish:(TLBaseServiceErrorCode)errorCode  {
    DDLogVerbose(@"%@ invitationSubscriptionDidFinish: %u", LOG_TAG, errorCode);
    
    if (errorCode == TLBaseServiceErrorCodeSuccess) {
        [self finish];
        [self.invitationSubscriptionDelegate invitationSubscriptionSuccess];
    } else {
        NSString *errorMessage;
        if (errorCode == TLBaseServiceErrorCodeExpired) {
            errorMessage = TwinmeLocalizedString(@"in_app_subscription_view_controller_expired_code", nil);
        } else if (errorCode == TLBaseServiceErrorCodeLimitReached) {
            errorMessage = TwinmeLocalizedString(@"in_app_subscription_view_controller_used_code", nil);
        } else {
            errorMessage = TwinmeLocalizedString(@"in_app_subscription_view_controller_invalid_code", nil);
        }
    
        AlertMessageView *alertMessageView = [[AlertMessageView alloc] init];
        alertMessageView.alertMessageViewDelegate = self;
        [alertMessageView initWithTitle:TwinmeLocalizedString(@"delete_account_view_controller_warning", nil) message:errorMessage];
        [self.navigationController.view addSubview:alertMessageView];
        [alertMessageView showAlertView];
    }
}

- (void)invitationSubscriptionDidCancel {
    DDLogVerbose(@"%@ invitationSubscriptionDidCancel", LOG_TAG);
    
    if (self.captureSession) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self.captureSession startRunning];
        });
    } else {
        [self setupCaptureSession];
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
    
    [alertMessageView removeFromSuperview];
}

#pragma mark - Private methods

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    [self.view setBackgroundColor:Design.GREY_BACKGROUND_COLOR];
    
    [self setNavigationTitle:TwinmeLocalizedString(@"add_contact_view_controller_title", nil)];
    
    self.messageLabelWidthConstraint.constant *= Design.MIN_RATIO;
    self.messageLabelTopConstraint.constant *= Design.MIN_RATIO;
    
    [self.messageLabel setFont:Design.FONT_REGULAR30];
    self.messageLabel.textColor = Design.FONT_COLOR_GREY;
    
    self.messageLabel.text = TwinmeLocalizedString(@"in_app_subscription_view_controller_invitation_code", nil);

    self.captureViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.captureViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.captureViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    
    [self.captureView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleCameraTapGesture:)]];
    self.captureView.clipsToBounds = YES;
    self.captureView.layer.cornerRadius = Design.CONTAINER_RADIUS;
    
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
    
    self.importFromGalleryView.backgroundColor = Design.MAIN_COLOR;
    self.importFromGalleryView.userInteractionEnabled = YES;
    self.importFromGalleryView.clipsToBounds = YES;
    self.importFromGalleryView.layer.cornerRadius = self.importFromGalleryViewHeightConstraint.constant * 0.5;
    [self.importFromGalleryView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleImportQRCodeTapGesture:)]];
    
    self.importFromGalleryImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.importFromGalleryImageViewLeadingConstraint.constant *= Design.HEIGHT_RATIO;
    self.importFromGalleryImageView.tintColor = [UIColor whiteColor];
    
    self.importFromGalleryLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.importFromGalleryLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.importFromGalleryLabel.font = Design.FONT_MEDIUM36;
    self.importFromGalleryLabel.textColor = [UIColor whiteColor];
    self.importFromGalleryLabel.text = TwinmeLocalizedString(@"add_contact_view_controller_gallery_title", nil);
    
    self.twincodeViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.twincodeViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.twincodeViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    
    self.twincodeView.backgroundColor = [UIColor whiteColor];
    self.twincodeView.layer.cornerRadius = Design.CONTAINER_RADIUS;
    self.twincodeView.clipsToBounds = YES;
    
    self.twincodeTextFieldLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.twincodeTextFieldTrailingConstraint.constant = self.twincodeTextFieldLeadingConstraint.constant;
    self.twincodeTextField.font = Design.FONT_REGULAR30;
    self.twincodeTextField.textColor = Design.FONT_COLOR_DEFAULT;
    self.twincodeTextField.tintColor = Design.FONT_COLOR_DEFAULT;
    
    self.twincodeTextField.attributedPlaceholder = [[NSAttributedString alloc]initWithString:TwinmeLocalizedString(@"scan_view_controller_paste_code", nil) attributes:[NSDictionary dictionaryWithObject:DESIGN_PLACEHOLDER_COLOR forKey:NSForegroundColorAttributeName]];
    [self.twincodeTextField setReturnKeyType:UIReturnKeyDone];
    self.twincodeTextField.delegate = self;
    [self.twincodeTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    self.twincodeInviteViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.twincodeInviteView.userInteractionEnabled = YES;
    [self.twincodeInviteView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTwincodeInviteTapGesture:)]];
    
    self.twincodeInviteImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.twincodeInviteImageView.clipsToBounds = YES;
    self.twincodeInviteImageView.layer.cornerRadius = self.twincodeInviteImageViewHeightConstraint.constant * 0.5;
    self.twincodeInviteImageView.hidden = YES;
    self.twincodeInviteImageView.tintColor = Design.MAIN_COLOR;
    
    self.twincodeCopyImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.twincodeCopyImageViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
   
    self.twincodeCopyImageView.tintColor = DESIGN_PLACEHOLDER_COLOR;
    
    [self setupCaptureSession];
    self.previewLayer.frame = CGRectMake(0, 0, self.captureViewWidthConstraint.constant, self.captureViewHeightConstraint.constant);
}

- (void)finish {
    DDLogVerbose(@"%@ finish", LOG_TAG);
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)handleDecode:(NSString *)decodedResult {
    DDLogVerbose(@"%@ handleDecode: %@ ", LOG_TAG, decodedResult);
    
    NSURL *url = [NSURL URLWithString:decodedResult];
    if (!url) {
        [self incorrectQRCode];
        return;
    }
    
    NSString *action = url.host;
    NSString *value = nil;
    if ([[TLTwinmeContext INVITE_ACTION] isEqualToString:action]) {
        NSArray *queryItems = [[[NSURLComponents alloc] initWithURL:url resolvingAgainstBaseURL:NO] queryItems];
        for (NSURLQueryItem *queryItem in queryItems) {
            if ([@"skredcodeId" isEqualToString: queryItem.name]) {
                value = queryItem.value;
                break;
            }
        }
                
        if (!value) {
            [self incorrectQRCode];
            return;
        }
        
        NSArray *components = [value componentsSeparatedByString:@"."];
        if (components.count == 2) {
            NSUUID *uuid = [NSString toUUID:[components objectAtIndex:0]];
            if (!uuid) {
                [self incorrectQRCode];
                return;
            }
            
            AcceptInvitationSubscriptionViewController *acceptInvitationSubscriptionViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AcceptInvitationSubscriptionViewController"];
            acceptInvitationSubscriptionViewController.acceptInvitationSubscriptionDelegate = self;
            [acceptInvitationSubscriptionViewController initWithPeerTwincodeOutboundId:uuid activationCode:[components objectAtIndex:1]];
            [acceptInvitationSubscriptionViewController showInView:self.navigationController.view];
        } else {
            [self incorrectQRCode];
        }
    } else {
        NSArray *components = [self.twincodeTextField.text componentsSeparatedByString:@"."];
        if (components.count == 2) {
            NSUUID *uuid = [NSString toUUID:[components objectAtIndex:0]];
            if (!uuid) {
                [self incorrectQRCode];
                return;
            }
            
            AcceptInvitationSubscriptionViewController *acceptInvitationSubscriptionViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AcceptInvitationSubscriptionViewController"];
            acceptInvitationSubscriptionViewController.acceptInvitationSubscriptionDelegate = self;
            [acceptInvitationSubscriptionViewController initWithPeerTwincodeOutboundId:uuid activationCode:[components objectAtIndex:1]];
            [acceptInvitationSubscriptionViewController showInView:self.navigationController.view];
        } else {
            [self incorrectQRCode];
        }
    }
}

- (void)incorrectQRCode {
    DDLogVerbose(@"%@ incorrectQRCode", LOG_TAG);
        
    AlertMessageView *alertMessageView = [[AlertMessageView alloc] init];
    alertMessageView.alertMessageViewDelegate = self;
    [alertMessageView initWithTitle:TwinmeLocalizedString(@"delete_account_view_controller_warning", nil) message:TwinmeLocalizedString(@"capture_view_controller_incorrect_qrcode", nil)];
    [self.navigationController.view addSubview:alertMessageView];
    [alertMessageView showAlertView];
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

- (void)handleCloseTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleCloseTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        
        [self finish];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)handleImportQRCodeTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleImportQRCodeTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
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
        
        if (![self.twincodeTextField.text isEqualToString:@""]) {
            [self.twincodeTextField resignFirstResponder];
            [self handleDecode:self.twincodeTextField.text];
        }
    }
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    [self.messageLabel setFont:Design.FONT_REGULAR30];
    [self.messageScanLabel setFont:Design.FONT_MEDIUM32];
    [self.messageNoPermissionScanLabel setFont:Design.FONT_MEDIUM32];
    [self.messageLabel setFont:Design.FONT_MEDIUM28];
    [self.importFromGalleryLabel setFont:Design.FONT_MEDIUM32];
    self.twincodeTextField.font = Design.FONT_REGULAR30;
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    [self.view setBackgroundColor:Design.GREY_BACKGROUND_COLOR];
    self.messageLabel.textColor = Design.FONT_COLOR_GREY;
}

@end
