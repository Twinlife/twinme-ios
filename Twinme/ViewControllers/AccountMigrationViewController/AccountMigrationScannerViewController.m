/*
 *  Copyright (c) 2020 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

@import AVFoundation;

#import <CocoaLumberjack.h>

#import <Twinlife/TLTwincodeURI.h>
#import <Twinlife/TLAccountMigrationService.h>
#import <Twinme/TLProfile.h>
#import <Twinme/TLSpace.h>
#import <Twinme/TLAccountMigration.h>
#import <Twinme/TLTwinmeAttributes.h>
#import <TwinmeCommon/AccountMigrationScannerService.h>
#import <TwinmeCommon/AccountMigrationService.h>

#import <Utils/NSString+Utils.h>

#import "AccountMigrationScannerViewController.h"
#import "AccountMigrationViewController.h"
#import <TwinmeCommon/TwinmeNavigationController.h>
#import <TwinmeCommon/MainViewController.h>

#import "AlertMessageView.h"
#import "DefaultConfirmView.h"
#import "OnboardingConfirmView.h"
#import <TwinmeCommon/Design.h>
#import <TwinmeCommon/Utils.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static const CGFloat DESIGN_HIGHLIGHT_VIEW_CORNER_RADIUS = 4;

//
// Interface: AccountMigrationScannerViewController ()
//

@interface AccountMigrationScannerViewController () <AVCaptureMetadataOutputObjectsDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, AlertMessageViewDelegate, ConfirmViewDelegate, AccountMigrationScannerServiceDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *accountViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *accountViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *accountViewTopConstraint;
@property (weak, nonatomic) IBOutlet UIView *accountView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *qrcodeViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *qrcodeView;
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
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;

@property UIView *highlightView;
@property AVCaptureSession *captureSession;
@property AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic) TLProfile *profile;
@property (nonatomic) TLAccountMigration *accountMigration;
@property (nonatomic) TLTwincodeOutbound *twincodeOutbound;
@property (nonatomic) TLTwincodeURI *accountMigrationLink;
@property (nonatomic) BOOL hasRelations;
@property (nonatomic, nonnull) AccountMigrationScannerService *accountMigrationScannerService;
@property (nonatomic) BOOL showOnboardingView;

@end

//
// Implementation: AccountMigrationScannerViewController
//

#undef LOG_TAG
#define LOG_TAG @"AccountMigrationScannerViewController"

@implementation AccountMigrationScannerViewController

- (instancetype)initWithCoder:(NSCoder *)coder {
    DDLogVerbose(@"%@ initWithCoder: %@", LOG_TAG, coder);
    
    self = [super initWithCoder:coder];
    
    if (self) {
        _accountMigrationScannerService = [[AccountMigrationScannerService alloc] initWithTwinmeContext:self.twinmeContext delegate:self];
        _hasRelations = NO;
        _fromCurrentDevice = NO;
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
    
    if (!self.showOnboardingView && [self.twinmeApplication startOnboarding:OnboardingTypeTransfer]) {
        self.showOnboardingView = YES;
        
        OnboardingConfirmView *onboardingConfirmView = [[OnboardingConfirmView alloc] init];
        onboardingConfirmView.confirmViewDelegate = self;

        UIImage *image = [self.twinmeApplication darkModeEnable] ? [UIImage imageNamed:@"OnboardingMigrationDark"] : [UIImage imageNamed:@"OnboardingMigration"];
        
        [onboardingConfirmView initWithTitle:TwinmeLocalizedString(@"account_view_controller_migration_title", nil) message: TwinmeLocalizedString(@"account_view_controller_migration_message", nil) image:image action:TwinmeLocalizedString(@"application_ok", nil) actionColor:nil cancel:TwinmeLocalizedString(@"application_do_not_display", nil)];
        
        NSMutableAttributedString *attributedTitle = [[NSMutableAttributedString alloc] initWithString:TwinmeLocalizedString(@"account_view_controller_migration_title", nil) attributes:[NSDictionary dictionaryWithObjectsAndKeys:Design.FONT_BOLD36, NSFontAttributeName, Design.FONT_COLOR_DEFAULT, NSForegroundColorAttributeName, nil]];
        [onboardingConfirmView updateTitle:attributedTitle];
        
        [self.navigationController.view addSubview:onboardingConfirmView];
        [onboardingConfirmView showConfirmView];
    }
}

- (void)finish {
    DDLogVerbose(@"%@ finish", LOG_TAG);
    
    if (self.accountMigrationScannerService) {
        [self.accountMigrationScannerService dispose];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Public methods

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

- (void)didCaptureUrl:(NSURL *)url action:(NSString *)action {
    DDLogVerbose(@"%@ didCaptureUrl: %@ action: %@", LOG_TAG, url, action);
    
    [self handleDecodeWithURI:url];
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
            [self handleDecodeWithDecodedResult:decodedResult];
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
                [self handleDecodeWithDecodedResult:qrCodeFeature.messageString];
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

- (void)invitationDidFinish {
    DDLogVerbose(@"%@ invitationDidFinish", LOG_TAG);
    
    [self.navigationController popToRootViewControllerAnimated:YES];
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

#pragma mark - ConfirmViewDelegate

- (void)didTapConfirm:(nonnull AbstractConfirmView *)abstractConfirmView {
    DDLogVerbose(@"%@ didTapConfirm: %@", LOG_TAG, abstractConfirmView);
    
    if ([abstractConfirmView isKindOfClass:[DefaultConfirmView class]]) {
        if (self.twincodeOutbound) {
            [self.accountMigrationScannerService bindAccountMigrationWithTwincodeOutbound:self.twincodeOutbound];
        }
    }
    
    [abstractConfirmView closeConfirmView];
}

- (void)didTapCancel:(nonnull AbstractConfirmView *)abstractConfirmView {
    DDLogVerbose(@"%@ didTapCancel: %@", LOG_TAG, abstractConfirmView);
    
    if ([abstractConfirmView isKindOfClass:[DefaultConfirmView class]]) {
        if (self.twincodeOutbound) {
            [self finish];
        }
    } else {
        [self.twinmeApplication setShowOnboardingType:OnboardingTypeTransfer state:NO];
    }
    
    
    [abstractConfirmView closeConfirmView];
}

- (void)didClose:(nonnull AbstractConfirmView *)abstractConfirmView {
    DDLogVerbose(@"%@ didClose: %@", LOG_TAG, abstractConfirmView);
    
    if ([abstractConfirmView isKindOfClass:[OnboardingConfirmView class]]) {
        if (self.twincodeOutbound) {
            [self finish];
        }
    }
    
    [abstractConfirmView closeConfirmView];
}

- (void)didFinishCloseAnimation:(nonnull AbstractConfirmView *)abstractConfirmView {
    DDLogVerbose(@"%@ didFinishCloseAnimation: %@", LOG_TAG, abstractConfirmView);
    
    [abstractConfirmView removeFromSuperview];
}

#pragma mark - Private methods

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    [self.view setBackgroundColor:Design.GREY_BACKGROUND_COLOR];
    
    [self setNavigationTitle:TwinmeLocalizedString(@"account_view_controller_migration_title", nil)];
    
    self.accountViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.accountViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.accountViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.accountView.backgroundColor = Design.POPUP_BACKGROUND_COLOR;
    self.accountView.layer.cornerRadius = Design.CONTAINER_RADIUS;
    self.accountView.clipsToBounds = YES;
    
    self.qrcodeViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.qrcodeView.backgroundColor = Design.WHITE_COLOR;
    self.qrcodeView.layer.cornerRadius = Design.POPUP_RADIUS;
    self.qrcodeView.clipsToBounds = YES;
    
    self.captureView.clipsToBounds = YES;
    self.captureView.layer.cornerRadius = Design.POPUP_RADIUS;
    
    [self.captureView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleCameraTapGesture:)]];
    
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
    
    self.messageLabelWidthConstraint.constant *= Design.MIN_RATIO;
    [self.messageLabel setFont:Design.FONT_REGULAR34];
    self.messageLabel.textColor = Design.FONT_COLOR_DEFAULT;
    
    self.highlightView = [[UIView alloc] init];
    self.highlightView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
    self.highlightView.layer.borderColor = [UIColor greenColor].CGColor;
    self.highlightView.layer.borderWidth = DESIGN_HIGHLIGHT_VIEW_CORNER_RADIUS * Design.HEIGHT_RATIO;
    [self.captureView addSubview:self.highlightView];
    [self.captureView bringSubviewToFront:self.highlightView];
    self.captureView.hidden = YES;
    
    [self updateQRCode];
    
    if (self.fromCurrentDevice) {
        self.captureView.hidden = NO;
        self.accountView.hidden = YES;
        
        [self setupCaptureSession];
        self.previewLayer.frame = self.captureView.bounds;
        self.messageLabel.text = TwinmeLocalizedString(@"account_migration_scanner_view_controller_migration_start_from_current_device_message", nil);
    } else {
        self.captureView.hidden = YES;
        self.accountView.hidden = NO;
        self.messageLabel.text = TwinmeLocalizedString(@"account_migration_scanner_view_controller_migration_start_from_another_device_message", nil);
    }
}

- (void)handleDecodeWithURI:(nonnull NSURL *)uri {
    DDLogVerbose(@"%@ handleDecodeWithURI: %@", LOG_TAG, uri);
    
    [self.accountMigrationScannerService parseURIWithUri:uri withBlock:^(TLBaseServiceErrorCode errorCode, TLTwincodeURI * _Nullable twincodeUri) {
        DDLogVerbose(@"%@ onParseTwincodeURI: %@", LOG_TAG, twincodeUri);
        
        // @todo Handle errors and report an accurate message:
        // ErrorCode.BAD_REQUEST: link is not well formed or not one of our link
        // ErrorCode.FEATURE_NOT_IMPLEMENTED: link does not target our application or domain.
        // ErrorCode.ITEM_NOT_FOUND: link targets the application but it is not compatible with the version.
        if (errorCode == TLBaseServiceErrorCodeSuccess && twincodeUri) {
            if (twincodeUri.kind == TLTwincodeURIKindAccountMigration && twincodeUri.twincodeId) {
                [self.accountMigrationScannerService getTwincodeOutboundWithTwincodeOutboundId:twincodeUri.twincodeId];
                return;
            }
        }
        [self incorrectQRCode];
    }];
}

- (void)handleDecodeWithDecodedResult:(nonnull NSString *)decodedResult {
    DDLogVerbose(@"%@ handleDecodeWithDecodedResult: %@", LOG_TAG, decodedResult);
    
    NSURL *uri = [[NSURL alloc] initWithString:decodedResult];
    
    [self handleDecodeWithURI:uri];
}

- (void)incorrectQRCode {
    DDLogVerbose(@"%@ incorrectQRCode", LOG_TAG);
        
    AlertMessageView *alertMessageView = [[AlertMessageView alloc] init];
    alertMessageView.alertMessageViewDelegate = self;
    [alertMessageView initWithTitle:TwinmeLocalizedString(@"delete_account_view_controller_warning", nil) message:TwinmeLocalizedString(@"capture_view_controller_incorrect_qrcode", nil)];
    [self.tabBarController.view addSubview:alertMessageView];
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

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    [self.messageLabel setFont:Design.FONT_REGULAR34];
    [self.messageScanLabel setFont:Design.FONT_MEDIUM32];
    [self.messageNoPermissionScanLabel setFont:Design.FONT_MEDIUM32];
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    self.qrcodeView.backgroundColor = Design.WHITE_COLOR;
    self.messageLabel.textColor = Design.FONT_COLOR_DEFAULT;
}

- (void)onGetTwincodeNotFound {
    DDLogVerbose(@"%@ onGetTwincodeNotFound", LOG_TAG);
    
    [self incorrectQRCode];
}

- (void)onGetTwincodeWithTwincode:(nonnull TLTwincodeOutbound *)twincode avatar:(nullable UIImage *)avatar {
    DDLogVerbose(@"%@ onGetTwincodeWithTwincode twincodeOutbound:%@", LOG_TAG, twincode);
    
    TLAccountMigrationVersion *version = [TLTwinmeAttributes getTwincodeAttributeAccountMigrationWithTwincode:twincode];
    self.twincodeOutbound = twincode;
    
    [self checkVersionWithPeerAccountMigrationVersion:version withBlock:^{
        [self.accountMigrationScannerService bindAccountMigrationWithTwincodeOutbound:twincode];
    }];
}

- (void)onAccountMigrationConnected:(nonnull NSUUID *)accountMigrationId {
    DDLogVerbose(@"%@ onAccountMigrationConnected accountMigrationId:%@", LOG_TAG, accountMigrationId.UUIDString);

    ApplicationDelegate *delegate = (ApplicationDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate.accountMigrationService outgoingMigrationWithAccountMigrationId:accountMigrationId];

    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        ApplicationDelegate *delegate = (ApplicationDelegate *)[[UIApplication sharedApplication] delegate];
        MainViewController *mainViewController = delegate.mainViewController;
        TwinmeNavigationController *selectedNavigationController = mainViewController.selectedViewController;
        AccountMigrationViewController *accountMigrationViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AccountMigrationViewController"];
        [accountMigrationViewController initWithAccountMigration:self.accountMigration];
        
        TwinmeNavigationController *migrationNavigationController = [[TwinmeNavigationController alloc]initWithRootViewController:accountMigrationViewController];
        [selectedNavigationController presentViewController:migrationNavigationController animated:YES completion:nil];
    }];
    
    [self.navigationController popViewControllerAnimated:NO];

    [CATransaction commit];
}

- (void)onCreateAccountMigration:(nullable TLAccountMigration *)accountMigration twincodeUri:(nonnull TLTwincodeURI *)twincodeUri {
    DDLogVerbose(@"%@ onCreateAccountMigration accountMigration:%@", LOG_TAG, accountMigration);
    
    self.accountMigration = accountMigration;
    self.accountMigrationLink = twincodeUri;
    
    [self updateQRCode];
}

- (void)onUpdateAccountMigration:(nonnull TLAccountMigration *)accountMigration {
    DDLogVerbose(@"%@ onUpdateAccountMigration: %@", LOG_TAG, accountMigration);

    // TODO: redirect to the next view controller if the peer is now connected.
    if ([accountMigration isBound]) {
        [self onAccountMigrationConnected:accountMigration.uuid];
    }
}

- (void)onDeleteAccountMigration:(nonnull NSUUID *)accountMigrationId {
    DDLogVerbose(@"%@ onDeleteAccountMigration: %@", LOG_TAG, accountMigrationId);

    if (self.accountMigration && [self.accountMigration.uuid isEqual:accountMigrationId]) {
        [self finish];
    }
}

- (void)onGetDefaultProfile:(nonnull TLProfile *)profile {
    DDLogVerbose(@"%@ onGetDefaultProfile profile:%@", LOG_TAG, profile);
    
    self.profile = profile;
}

- (void)onGetDefaultProfileNotFound {
    DDLogVerbose(@"%@ onGetDefaultProfileNotFound", LOG_TAG);
    
}

- (void)onHasRelations {
    DDLogVerbose(@"%@ onHasRelations", LOG_TAG);
    
    self.hasRelations = YES;
}

- (void)checkVersionWithPeerAccountMigrationVersion:(nonnull TLAccountMigrationVersion *)peerAccountMigrationVersion withBlock:(nonnull void (^)(void))block {
    DDLogVerbose(@"%@ checkVersion peerVersion=", peerAccountMigrationVersion);
    
    // If the peer version is too old, there is a strong risk to lose data: if we send our database
    // it has a new format that is not compatible with the peer device application.
    // - if version match, we can proceed,
    // - if our version is newer and there is no relation, we can proceed,
    // - if our version is older and the peer has no relation, we can proceed.
    
    TLVersion *supportedVersion = [[TLVersion alloc] initWithVersion:TLAccountMigrationService.VERSION];
    
    TLVersion *peerVersion = peerAccountMigrationVersion.version;
    BOOL peerHasRelations = peerAccountMigrationVersion.hasRelations;
    
    if (peerVersion.major == supportedVersion.major
        || (peerVersion.major < supportedVersion.major && !self.hasRelations)
        || (peerVersion.major > supportedVersion.major && !peerHasRelations)) {
        block();
    } else {
        // Ask confirmation here to issue the bindMigration()
        DDLogError(@"%@ AccountMigration is stopped because the peer device is old!", LOG_TAG);
        
        NSString *message;
        if (peerVersion.major < supportedVersion.major) {
            message = TwinmeLocalizedString(@"account_migration_scanner_view_controller_message_older_version_target", nil);
        } else {
            message = TwinmeLocalizedString(@"account_migration_scanner_view_controller_message_older_version", nil);
        }
        
        DefaultConfirmView *migrationConfirmView = [[DefaultConfirmView alloc] init];
        migrationConfirmView.confirmViewDelegate = self;
        UIImage *image = [self.twinmeApplication darkModeEnable] ? [UIImage imageNamed:@"OnboardingMigrationDark"] : [UIImage imageNamed:@"OnboardingMigration"];
        [migrationConfirmView initWithTitle:TwinmeLocalizedString(@"delete_account_view_controller_warning", nil) message:message image:image avatar:nil action:TwinmeLocalizedString(@"account_migration_view_controller_start", nil) actionColor:nil cancel:nil];
        [self.tabBarController.view addSubview:migrationConfirmView];
        [migrationConfirmView showConfirmView];
    }
}

- (void)updateQRCode {
    DDLogVerbose(@"%@ updateQRCode", LOG_TAG);
    
    if (!self.accountMigration || !self.accountMigrationLink) {
        return;
    }
    
    UIImage *qrCode = [Utils makeQRCodeWithUri:self.accountMigrationLink scale:10];
    
    self.qrcodeView.image = qrCode;
}

@end
