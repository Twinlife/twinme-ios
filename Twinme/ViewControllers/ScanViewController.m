/*
 *  Copyright (c) 2021-2024 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

@import AVFoundation;

#import <CocoaLumberjack.h>

#import <Twinlife/TLTwinlife.h>
#import <Twinlife/TLTwincodeURI.h>

#import <Twinme/TLProfile.h>

#import <Utils/NSString+Utils.h>

#import "ScanViewController.h"
#import "AcceptInvitationViewController.h"

#import <TwinmeCommon/ShareProfileService.h>

#import "AlertMessageView.h"
#import "TwinmeTextField.h"
#import <TwinmeCommon/Design.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static const CGFloat DESIGN_HIGHLIGHT_VIEW_CORNER_RADIUS = 4;
static UIColor *DESIGN_TWINCODE_COLOR;
static UIColor *DESIGN_PLACEHOLDER_COLOR;

//
// Interface: ScanViewController ()
//

@interface ScanViewController () <AVCaptureMetadataOutputObjectsDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, AcceptInvitationDelegate, ShareProfileServiceDelegate, AlertMessageViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *closeViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *closeViewWidthConstraint;
@property (weak, nonatomic) IBOutlet UIView *closeView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *closeImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *closeImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *importFromGalleryViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *importFromGalleryViewWidthConstraint;
@property (weak, nonatomic) IBOutlet UIView *importFromGalleryView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *importFromGalleryImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *importFromGalleryImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *twincodeViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *twincodeViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *twincodeViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *twincodeView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *twincodeTextFieldLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *twincodeTextFieldTrailingConstraint;
@property (weak, nonatomic) IBOutlet TwinmeTextField *twincodeTextField;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *twincodeInviteViewWidthConstraint;
@property (weak, nonatomic) IBOutlet UIView *twincodeInviteView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *twincodeInviteImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *twincodeInviteImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *captureViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *captureViewBottomConstraint;
@property (weak, nonatomic) IBOutlet UIView *captureView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *framingTopViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *framingTopViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *framingTopViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *framingTopViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *framingLeftViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *framingLeftViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *framingLeftViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *framingLeftViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *framingRightViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *framingRightViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *framingRightViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *framingRightViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *framingBottomViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *framingBottomViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *framingBottomViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *framingBottomViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;

@property UIView *highlightView;
@property AVCaptureSession *captureSession;
@property AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic) TLProfile *profile;
@property (nonatomic) TLContact *contact;
@property (nonatomic) ShareProfileService *shareProfileService;
@property (nonatomic) TLTwincodeURI *parsedURI;

@property (nonatomic) BOOL keyboardHidden;

@end

//
// Implementation: ScanViewController
//

#undef LOG_TAG
#define LOG_TAG @"ScanViewController"

@implementation ScanViewController

+ (void)initialize {
    DDLogVerbose(@"%@ initialize", LOG_TAG);
    
    DESIGN_TWINCODE_COLOR = [UIColor colorWithRed:226./255. green:226./255 blue:226./255 alpha:255./255];
    DESIGN_PLACEHOLDER_COLOR = [UIColor colorWithRed:162./255. green:162./255 blue:162./255 alpha:255./255];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    DDLogVerbose(@"%@ initWithCoder: %@", LOG_TAG, coder);
    
    self = [super initWithCoder:coder];
    
    if (self) {
        _keyboardHidden = YES;
    }
    return self;
}

- (void)viewDidLoad {
    DDLogVerbose(@"%@ viewDidLoad", LOG_TAG);
    
    [super viewDidLoad];
    
    [self initViews];
}

- (void)viewWillAppear:(BOOL)animated {
    DDLogVerbose(@"%@ viewWillAppear: %@", LOG_TAG, animated ? @"YES" : @"NO");
    
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

#pragma mark - Public methods

- (void)initWithProfile:(TLProfile *)profile {
    DDLogVerbose(@"%@ initWithProfile: %@", LOG_TAG, profile);
    
    self.profile = profile;
    self.shareProfileService = [[ShareProfileService alloc] initWithTwinmeContext:self.twinmeContext delegate:self];
}

- (void)viewDidLayoutSubviews {
    DDLogVerbose(@"%@ viewDidLayoutSubviews", LOG_TAG);
    
    [super viewDidLayoutSubviews];
    
    [self setupCaptureSession];
    self.previewLayer.frame = CGRectMake(0, 0, self.captureView.frame.size.width, self.captureView.frame.size.height);
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
                    strongSelf.messageLabel.hidden = YES;
                }
            });
        } else {
            self.messageLabel.text = TwinmeLocalizedString(@"application_permission_scan_code", nil);
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
        [self.captureView.layer insertSublayer:self.previewLayer atIndex:0];
        [self.captureView bringSubviewToFront:self.highlightView];
        
        [self.captureSession startRunning];
    }
}

- (void)didCaptureUrl:(nonnull NSURL *)url kind:(TLTwincodeURIKind)kind {
    DDLogVerbose(@"%@ didCaptureUrl: %@ kind: %ld", LOG_TAG, url, kind);
    
    if (kind == TLTwincodeURIKindInvitation) {
        AcceptInvitationViewController *acceptInvitationViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AcceptInvitationViewController"];
        [acceptInvitationViewController initWithProfile:self.profile url:url descriptorId:nil originatorId:nil isGroup:NO notification:nil popToRootViewController:YES];
        acceptInvitationViewController.acceptInvitationDelegate = self;
        [acceptInvitationViewController showInView:self.view];
    } else {
        NSString *message = TwinmeLocalizedString(@"capture_view_controller_incorrect_qrcode", nil);
        
        switch (kind) {
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

- (void)didPasteItemNotification:(NSNotification *)notification {
    DDLogVerbose(@"%@ didPasteItemNotification: %@", LOG_TAG, notification);
    
    NSString *pastedContent = (NSString *)notification.object;
    if (pastedContent) {
        NSURL *url = [NSURL URLWithString:pastedContent];
        self.parsedURI = nil;
        [self.shareProfileService parseUriWithUri:url withBlock:^(TLBaseServiceErrorCode errorCode, TLTwincodeURI *uri) {
            self.twincodeInviteImageView.hidden = NO;
            self.twincodeTextFieldTrailingConstraint.constant = self.twincodeInviteViewWidthConstraint.constant;
            if (errorCode != TLBaseServiceErrorCodeSuccess) {
                self.twincodeTextField.text = pastedContent;
            } else {
                // SCz this is not correct: we will loose information such as public key.
                self.twincodeTextField.text = uri.label;
                self.parsedURI = uri;
            }
        }];
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

#pragma mark - AcceptInvitationDelegate

- (void)invitationDidFinish:(nullable TLContact *)contact {
    DDLogVerbose(@"%@ invitationDidFinish", LOG_TAG);
    
    self.contact = contact;
    
    [self dismissViewControllerAnimated:YES completion:nil];
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

}

- (void)onCreateContact:(nonnull TLContact *)contact {
    DDLogVerbose(@"%@ onCreateContact: %@", LOG_TAG, contact);
    
    self.contact = contact;
    
    [self dismissViewControllerAnimated:YES completion:^{
        [self.navigationController popToRootViewControllerAnimated:YES];
    }];
}

#pragma mark - AlertMessageViewDelegate

- (void)didCloseAlertMessage:(nonnull AlertMessageView *)alertMessageView {
    DDLogVerbose(@"%@ didCloseAlertMessage: %@", LOG_TAG, alertMessageView);
    
    [alertMessageView closeAlertView];
}

- (void)didFinishCloseAlertMessageAnimation:(nonnull AlertMessageView *)alertMessageView {
    DDLogVerbose(@"%@ didFinishCloseAlertMessageAnimation: %@", LOG_TAG, alertMessageView);
    
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
                strongSelf.messageLabel.hidden = YES;
            }
        });
    } else {
        self.messageLabel.text = TwinmeLocalizedString(@"application_permission_scan_code", nil);
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
    [self.captureView.layer insertSublayer:self.previewLayer atIndex:0];
    [self.captureView bringSubviewToFront:self.highlightView];
    
    [self.captureSession startRunning];
    
    [alertMessageView removeFromSuperview];
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
    self.parsedURI = nil;
}

- (void)keyboardWillShow:(NSNotification *)notification {
    DDLogVerbose(@"%@ keyboardWillShow: %@", LOG_TAG, notification);
    
    if (!self.keyboardHidden) {
        return;
    }
    
    self.keyboardHidden = NO;
    NSDictionary *info = [notification userInfo];
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    CGRect nameViewFrame = self.twincodeView.frame;
    CGRect frame = self.view.frame;
    CGFloat yOffset = keyboardSize.height - (frame.size.height - (nameViewFrame.origin.y + nameViewFrame.size.height + 24.0 * Design.HEIGHT_RATIO));
    frame.origin.y -= yOffset;
    self.view.frame = frame;
    
    if ([self.twinmeApplication getDefaultKeyboardHeight] != keyboardSize.height) {
        [self.twinmeApplication setDefaultKeyboardHeight:keyboardSize.height];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification {
    DDLogVerbose(@"%@ keyboardWillHide: %@", LOG_TAG, notification);
    
    self.keyboardHidden = YES;
    
    CGRect frame = self.view.frame;
    frame.origin.y = 0;
    self.view.frame = frame;
}

#pragma mark - Private methods

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    [self.view setBackgroundColor:[UIColor blackColor]];
    
    self.closeViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.closeViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    
    self.closeView.userInteractionEnabled = YES;
    self.closeView.isAccessibilityElement = YES;
    self.closeView.accessibilityLabel = TwinmeLocalizedString(@"application_cancel", nil);
    [self.closeView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleCloseTapGesture:)]];
    
    self.closeImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.closeImageView.tintColor = [UIColor whiteColor];
    
    self.captureViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.captureViewBottomConstraint.constant *= Design.HEIGHT_RATIO;
    [self.captureView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleCameraTapGesture:)]];
    
    self.framingTopViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.framingTopViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.framingTopViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.framingTopViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.framingLeftViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.framingLeftViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.framingLeftViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.framingLeftViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.framingRightViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.framingRightViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.framingRightViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.framingRightViewBottomConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.framingBottomViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.framingBottomViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.framingBottomViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.framingBottomViewBottomConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.messageLabelWidthConstraint.constant *= Design.MIN_RATIO;
    [self.messageLabel setFont:Design.FONT_REGULAR34];
    self.messageLabel.text = TwinmeLocalizedString(@"capture_view_controller_message", nil);
    
    self.highlightView = [[UIView alloc] init];
    self.highlightView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
    self.highlightView.layer.borderColor = [UIColor greenColor].CGColor;
    self.highlightView.layer.borderWidth = DESIGN_HIGHLIGHT_VIEW_CORNER_RADIUS * Design.HEIGHT_RATIO;
    [self.captureView addSubview:self.highlightView];
    [self.captureView bringSubviewToFront:self.highlightView];
    
    self.importFromGalleryViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.importFromGalleryViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    
    self.importFromGalleryView.userInteractionEnabled = YES;
    self.importFromGalleryView.clipsToBounds = YES;
    [self.importFromGalleryView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleImportQRCodeTapGesture:)]];
    
    self.importFromGalleryImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.importFromGalleryImageView.tintColor = [UIColor whiteColor];
    
    self.twincodeViewBottomConstraint.constant *= Design.HEIGHT_RATIO;
    self.twincodeViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.twincodeViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.twincodeView.backgroundColor = Design.TEXTFIELD_CONVERSATION_BACKGROUND_COLOR;
    self.twincodeView.layer.cornerRadius = Design.CONTAINER_RADIUS;
    self.twincodeView.clipsToBounds = YES;
    
    self.twincodeTextFieldLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.twincodeTextFieldTrailingConstraint.constant = self.twincodeTextFieldLeadingConstraint.constant;
    self.twincodeTextField.font = Design.FONT_REGULAR30;
    self.twincodeTextField.textColor = Design.FONT_COLOR_DEFAULT;
    self.twincodeTextField.tintColor = Design.FONT_COLOR_DEFAULT;
    self.twincodeTextField.overrideDeleteBackWard = NO;
    
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

- (void)handleDecode:(NSString *)decodedResult {
    DDLogVerbose(@"%@ handleDecode: %@ ", LOG_TAG, decodedResult);
    
    NSURL *url = [NSURL URLWithString:decodedResult];
    if (!url) {
        [self incorrectQRCode];
        return;
    }
    
    [self.shareProfileService parseUriWithUri:url withBlock:^(TLBaseServiceErrorCode errorCode, TLTwincodeURI *uri) {
        if (errorCode != TLBaseServiceErrorCodeSuccess) {
            [self incorrectQRCode];
            return;
        }
        [self didCaptureUrl:url kind:uri.kind];
    }];
}

- (void)incorrectQRCode {
    DDLogVerbose(@"%@ incorrectQRCode", LOG_TAG);

    AlertMessageView *alertMessageView = [[AlertMessageView alloc] init];
    alertMessageView.alertMessageViewDelegate = self;
    [alertMessageView initWithTitle:TwinmeLocalizedString(@"delete_account_view_controller_warning", nil) message:TwinmeLocalizedString(@"capture_view_controller_incorrect_qrcode", nil)];
    [self.navigationController.view addSubview:alertMessageView];
    [alertMessageView showAlertView];
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

- (void)handleTwincodeInviteTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleTwincodeInviteTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        
        if (![self.twincodeTextField.text isEqualToString:@""]) {
            [self.twincodeTextField resignFirstResponder];
            [self handleDecode:self.twincodeTextField.text];
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

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    self.twincodeTextField.font = Design.FONT_REGULAR30;
    [self.messageLabel setFont:Design.FONT_REGULAR34];
}

@end
