/*
 *  Copyright (c) 2020-2026 twinlife SA.
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
#import "RestoreViewController.h"
#import <TwinmeCommon/TwinmeNavigationController.h>
#import <TwinmeCommon/MainViewController.h>

#import "AlertMessageView.h"
#import "DefaultConfirmView.h"
#import <TwinmeCommon/OnboardingConfirmView.h>
#import "UIAccountMigrationItem.h"
#import "AccountMigrationCell.h"

#import <TwinmeCommon/Design.h>
#import <TwinmeCommon/Utils.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static const CGFloat DESIGN_CELL_HEIGHT = 90;
static const CGFloat DESIGN_HIGHLIGHT_VIEW_CORNER_RADIUS = 4;

static NSString *ACCOUNT_MIGRATION_CELL_IDENTIFIER = @"AccountMigrationCellIdentifier";

static int RESTORE_ALERT_TAG = 10;

//
// Interface: AccountMigrationScannerViewController ()
//

@interface AccountMigrationScannerViewController () <AVCaptureMetadataOutputObjectsDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDataSource, UIDocumentPickerDelegate, UIDocumentInteractionControllerDelegate, AlertMessageViewDelegate, BottomSheetViewDelegate, AccountMigrationScannerServiceDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *accountViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *accountViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *accountViewTopConstraint;
@property (weak, nonatomic) IBOutlet UIView *accountView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *qrcodeViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *qrcodeViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *qrcodeViewBottomConstraint;
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
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageLabelTopConstraint;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewTopConstraint;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *restoreViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *restoreView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *restoreLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *restoreLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *restoreLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;

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
@property (nonatomic) NSMutableArray<UIAccountMigrationItem *> *accountMigrationItems;

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
        _accountMigrationItems = [[NSMutableArray alloc] init];
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
        onboardingConfirmView.bottomSheetViewDelegate = self;

        UIImage *image = [self.twinmeApplication darkModeEnable:[self currentSpaceSettings]] ? [UIImage imageNamed:@"OnboardingMigrationDark"] : [UIImage imageNamed:@"OnboardingMigration"];
        
        [onboardingConfirmView initWithTitle:TwinmeLocalizedString(@"account_view_migration_title", nil) message: TwinmeLocalizedString(@"account_view_migration_message", nil) image:image action:TwinmeLocalizedString(@"application_ok", nil) actionColor:nil cancel:TwinmeLocalizedString(@"application_do_not_display", nil)];
        
        NSMutableAttributedString *attributedTitle = [[NSMutableAttributedString alloc] initWithString:TwinmeLocalizedString(@"account_view_migration_title", nil) attributes:[NSDictionary dictionaryWithObjectsAndKeys:Design.FONT_BOLD36, NSFontAttributeName, Design.FONT_COLOR_DEFAULT, NSForegroundColorAttributeName, nil]];
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

#pragma mark - DocumentPickerDelegate

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray <NSURL *>*)urls {
    DDLogVerbose(@"%@ documentPicker: %@ didPickDocumentsAtURLs: %@", LOG_TAG, controller, urls);
    
    if (urls.count == 0) {
        return;
    }
    
    NSNumber *value = nil;
    NSURL *url = [urls firstObject];
    [url getResourceValue:&value forKey:NSURLIsPackageKey error:nil];
    [self unlockBackup:url];
}

#pragma mark - DocumentInteractionControllerDelegate

- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller {
    
    return self;
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

#pragma mark - BottomSheetViewDelegate

- (void)didTapConfirm:(nonnull AbstractBottomSheetView *)abstractBottomSheetView {
    DDLogVerbose(@"%@ didTapConfirm: %@", LOG_TAG, abstractBottomSheetView);
    
    if (abstractBottomSheetView.tag == RESTORE_ALERT_TAG) {
        UIDocumentPickerViewController *documentPicker = [[UIDocumentPickerViewController alloc] initForOpeningContentTypes:@[UTTypeData, UTTypeContent] asCopy:YES];
        documentPicker.delegate = self;
        documentPicker.modalPresentationStyle = UIModalPresentationFormSheet;
        [self presentViewController:documentPicker animated:YES completion:nil];
    } else if ([abstractBottomSheetView isKindOfClass:[DefaultConfirmView class]]) {
        if (self.twincodeOutbound) {
            [self.accountMigrationScannerService bindAccountMigrationWithTwincodeOutbound:self.twincodeOutbound];
        }
    }
    
    [abstractBottomSheetView closeConfirmView];
}

- (void)didTapCancel:(nonnull AbstractBottomSheetView *)abstractBottomSheetView {
    DDLogVerbose(@"%@ didTapCancel: %@", LOG_TAG, abstractBottomSheetView);
    
    if ([abstractBottomSheetView isKindOfClass:[DefaultConfirmView class]]) {
        if (self.twincodeOutbound) {
            [self finish];
        }
    } else {
        [self.twinmeApplication setShowOnboardingType:OnboardingTypeTransfer state:NO];
    }
    
    
    [abstractBottomSheetView closeConfirmView];
}

- (void)didClose:(nonnull AbstractBottomSheetView *)abstractBottomSheetView {
    DDLogVerbose(@"%@ didClose: %@", LOG_TAG, abstractBottomSheetView);
    
    if ([abstractBottomSheetView isKindOfClass:[OnboardingConfirmView class]]) {
        if (self.twincodeOutbound) {
            [self finish];
        }
    }
    
    [abstractBottomSheetView closeConfirmView];
}

- (void)didFinishCloseAnimation:(nonnull AbstractBottomSheetView *)abstractBottomSheetView {
    DDLogVerbose(@"%@ didFinishCloseAnimation: %@", LOG_TAG, abstractBottomSheetView);
    
    [abstractBottomSheetView removeFromSuperview];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    DDLogVerbose(@"%@ numberOfSectionsInTableView: %@", LOG_TAG, tableView);
    
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath  {
    DDLogVerbose(@"%@ tableView: %@ heightForRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    return roundf(DESIGN_CELL_HEIGHT * Design.HEIGHT_RATIO);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ heightForHeaderInSection: %ld", LOG_TAG, tableView, (long)section);
    
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ heightForFooterInSection: %ld", LOG_TAG, tableView, (long)section);
    
    return CGFLOAT_MIN;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ numberOfRowsInSection: %ld", LOG_TAG, tableView, (long)section);
    
    return self.accountMigrationItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ cellForRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    UIAccountMigrationItem *accountMigrationItem = [self.accountMigrationItems objectAtIndex:indexPath.row];
    AccountMigrationCell *cell = [tableView dequeueReusableCellWithIdentifier:ACCOUNT_MIGRATION_CELL_IDENTIFIER];
    if (!cell) {
        cell = [[AccountMigrationCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ACCOUNT_MIGRATION_CELL_IDENTIFIER];
    }
    
    [cell bindWithItem:accountMigrationItem];
    
    return cell;
}


#pragma mark - Private methods

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    [self.view setBackgroundColor:Design.GREY_BACKGROUND_COLOR];
    
    [self setNavigationTitle:TwinmeLocalizedString(@"account_view_migration_title", nil)];
    
    self.accountViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.accountViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.accountViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.accountView.backgroundColor = Design.POPUP_BACKGROUND_COLOR;
    self.accountView.layer.cornerRadius = Design.CONTAINER_RADIUS;
    self.accountView.clipsToBounds = YES;
    
    self.qrcodeViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.qrcodeViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.qrcodeViewBottomConstraint.constant *= Design.HEIGHT_RATIO;
    
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
    self.messageScanLabel.text = TwinmeLocalizedString(@"add_contact_view_scan_code", nil);
    
    self.messageNoPermissionScanLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    
    [self.messageNoPermissionScanLabel setFont:Design.FONT_MEDIUM32];
    self.messageNoPermissionScanLabel.textColor = [UIColor whiteColor];
    self.messageNoPermissionScanLabel.text = TwinmeLocalizedString(@"application_permission_scan_code", nil);
    self.messageNoPermissionScanLabel.hidden = YES;
    
    self.messageLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
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
    
    self.activityIndicatorView.hidesWhenStopped = YES;
    
    if ([self.twinmeApplication darkModeEnable:[self.twinmeContext defaultSpaceSettings]]) {
        self.activityIndicatorView.color = [UIColor whiteColor];
    }
    
    [self updateQRCode];
    
    if (self.fromCurrentDevice) {
        self.captureView.hidden = NO;
        self.accountView.hidden = YES;
        
        [self setupCaptureSession];
        self.previewLayer.frame = self.captureView.bounds;
        self.messageLabel.text = TwinmeLocalizedString(@"account_migration_scanner_view_header_my_device", nil);
    } else {
        self.captureView.hidden = YES;
        self.accountView.hidden = NO;
        self.messageLabel.text = TwinmeLocalizedString(@"account_migration_scanner_view_header_other_device", nil);
    }
    
    self.tableViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.tableViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.tableViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
        
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerNib:[UINib nibWithNibName:@"AccountMigrationCell" bundle:nil] forCellReuseIdentifier:ACCOUNT_MIGRATION_CELL_IDENTIFIER];

    self.tableView.backgroundColor = Design.WHITE_COLOR;
    self.tableView.dataSource = self;
    self.tableView.scrollEnabled = NO;
    self.tableView.rowHeight = roundf(DESIGN_CELL_HEIGHT * Design.HEIGHT_RATIO);
    self.tableView.clipsToBounds = YES;
    self.tableView.layer.cornerRadius = Design.POPUP_RADIUS;
    self.tableView.layer.masksToBounds = YES;
    
    UIView *shadowView = [[UIView alloc] initWithFrame:CGRectZero];
    shadowView.translatesAutoresizingMaskIntoConstraints = NO;
    shadowView.userInteractionEnabled = NO;
    shadowView.backgroundColor = Design.WHITE_COLOR;
    shadowView.layer.cornerRadius = Design.POPUP_RADIUS;
    shadowView.layer.shadowOpacity = Design.SHADOW_OPACITY;
    shadowView.layer.shadowOffset = Design.SHADOW_OFFSET;
    shadowView.layer.shadowRadius = Design.SHADOW_RADIUS;
    shadowView.layer.shadowColor = Design.SHADOW_COLOR_DEFAULT.CGColor;
    shadowView.layer.masksToBounds = NO;
    [self.tableView.superview insertSubview:shadowView belowSubview:self.tableView];
    
    [NSLayoutConstraint activateConstraints:@[
        [shadowView.leadingAnchor constraintEqualToAnchor:self.tableView.leadingAnchor],
        [shadowView.trailingAnchor constraintEqualToAnchor:self.tableView.trailingAnchor],
        [shadowView.topAnchor constraintEqualToAnchor:self.tableView.topAnchor],
        [shadowView.bottomAnchor constraintEqualToAnchor:self.tableView.bottomAnchor]
    ]];
    
    self.restoreViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.restoreView.userInteractionEnabled = YES;
    [self.restoreView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleRestoreTapGesture:)]];
    
    self.restoreLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.restoreLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
        
    self.restoreLabel.textColor = Design.MAIN_COLOR;
    self.restoreLabel.font = Design.FONT_MEDIUM32;
    
    NSMutableAttributedString *restoreAttributedString = [[NSMutableAttributedString alloc] initWithString:TwinmeLocalizedString(@"account_migration_scanner_view_restore_title", nil)];
    [restoreAttributedString addAttribute:NSUnderlineStyleAttributeName value:@1 range:NSMakeRange(0,[restoreAttributedString length])];
    [self.restoreLabel setAttributedText:restoreAttributedString];
    
    [self loadItems];
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

- (void)handleRestoreTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleRestoreTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        OnboardingConfirmView *onboardingConfirmView = [[OnboardingConfirmView alloc] init];
        onboardingConfirmView.bottomSheetViewDelegate = self;
        onboardingConfirmView.tag = RESTORE_ALERT_TAG;
        
        UIImage *image = [UIImage imageNamed:@"OnboardingBackup"];
        
        NSString *title = TwinmeLocalizedString(@"account_migration_scanner_view_restore_title", nil);
        NSString *message = [NSString stringWithFormat:@"%@\n\n%@", TwinmeLocalizedString(@"account_migration_scanner_view_restore_message",  nil), TwinmeLocalizedStringFromTable(@"restore_view_onboarding_words", @"LocalizableBackup", nil)];
        
        NSString *action = TwinmeLocalizedStringFromTable(@"restore_view_restore", @"LocalizableBackup", nil);
        
        [onboardingConfirmView initWithTitle:title message:message image:image action:action actionColor:nil cancel:TwinmeLocalizedString(@"application_cancel", nil)];
        
        [self.navigationController.view addSubview:onboardingConfirmView];
        [onboardingConfirmView showConfirmView];
    }
}

- (void)incorrectQRCode {
    DDLogVerbose(@"%@ incorrectQRCode", LOG_TAG);
        
    AlertMessageView *alertMessageView = [[AlertMessageView alloc] init];
    alertMessageView.alertMessageViewDelegate = self;
    [alertMessageView initWithTitle:TwinmeLocalizedString(@"deleted_account_view_warning", nil) message:TwinmeLocalizedString(@"capture_view_incorrect_qrcode", nil)];
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

- (void)onGetTwincodeNotFound {
    DDLogVerbose(@"%@ onGetTwincodeNotFound", LOG_TAG);
    
    [self incorrectQRCode];
}

- (void)onGetTwincodeExpired {
    DDLogVerbose(@"%@ onGetTwincodeExpired", LOG_TAG);
    
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
            message = TwinmeLocalizedString(@"account_migration_scanner_view_message_older_version_target", nil);
        } else {
            message = TwinmeLocalizedString(@"account_migration_scanner_view_message_older_version", nil);
        }
        
        DefaultConfirmView *migrationConfirmView = [[DefaultConfirmView alloc] init];
        migrationConfirmView.bottomSheetViewDelegate = self;
        UIImage *image = [self.twinmeApplication darkModeEnable:[self currentSpaceSettings]] ? [UIImage imageNamed:@"OnboardingMigrationDark"] : [UIImage imageNamed:@"OnboardingMigration"];
        [migrationConfirmView initWithTitle:TwinmeLocalizedString(@"deleted_account_view_warning", nil) message:message image:image avatar:nil action:TwinmeLocalizedString(@"account_migration_view_start", nil) actionColor:nil cancel:nil];
        [self.tabBarController.view addSubview:migrationConfirmView];
        [migrationConfirmView showConfirmView];
    }
}

- (void)updateQRCode {
    DDLogVerbose(@"%@ updateQRCode", LOG_TAG);
    
    if (!self.accountMigration || !self.accountMigrationLink) {
        return;
    }
        
    [self.activityIndicatorView startAnimating];
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *qrImage = [Utils makeQRCodeWithUri:weakSelf.accountMigrationLink scale:10];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!weakSelf) {
                return;
            }
            [self.activityIndicatorView stopAnimating];
            self.qrcodeView.image = qrImage;
        });
    });
}

- (void)unlockBackup:(NSURL *)filePath {
    DDLogVerbose(@"%@ unlockBackup", LOG_TAG);
    
    RestoreViewController *restoreViewController = [[UIStoryboard storyboardWithName:@"Backup" bundle:nil] instantiateViewControllerWithIdentifier:@"RestoreViewController"];
    [restoreViewController initWithFileURL:filePath verifyMode:NO pickFileInApp:YES];
    TwinmeNavigationController *navigationController = [[TwinmeNavigationController alloc] initWithRootViewController:restoreViewController];
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (void)loadItems {
    DDLogVerbose(@"%@ loadItems", LOG_TAG);
    
    [self.accountMigrationItems removeAllObjects];
    [self.accountMigrationItems addObject:[[UIAccountMigrationItem alloc] initWithPosition:1 text:TwinmeLocalizedString(@"account_migration_scanner_view_step_1", nil)]];
    [self.accountMigrationItems addObject:[[UIAccountMigrationItem alloc] initWithPosition:2 text:TwinmeLocalizedString(@"account_migration_scanner_view_step_2", nil)]];
    [self.accountMigrationItems addObject:[[UIAccountMigrationItem alloc] initWithPosition:3 text:TwinmeLocalizedString(@"account_migration_scanner_view_step_3", nil)]];
    
    if (self.fromCurrentDevice) {
        [self.accountMigrationItems addObject:[[UIAccountMigrationItem alloc] initWithPosition:4 text:TwinmeLocalizedString(@"account_migration_scanner_view_step_4_another_device", nil)]];
        [self.accountMigrationItems addObject:[[UIAccountMigrationItem alloc] initWithPosition:5 text:TwinmeLocalizedString(@"account_migration_scanner_view_step_5_my_device", nil)]];
    } else {
        [self.accountMigrationItems addObject:[[UIAccountMigrationItem alloc] initWithPosition:4 text:TwinmeLocalizedString(@"account_migration_scanner_view_step_4_my_device", nil)]];
        [self.accountMigrationItems addObject:[[UIAccountMigrationItem alloc] initWithPosition:5 text:TwinmeLocalizedString(@"account_migration_scanner_view_step_5_another_device", nil)]];
    }
    
    self.tableViewHeightConstraint.constant = roundf(DESIGN_CELL_HEIGHT * Design.HEIGHT_RATIO) * self.accountMigrationItems.count;
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
    self.tableView.backgroundColor = Design.POPUP_BACKGROUND_COLOR;
}

@end
