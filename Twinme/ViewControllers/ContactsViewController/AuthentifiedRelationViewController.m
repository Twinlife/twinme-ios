/*
 *  Copyright (c) 2024 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

@import AVFoundation;

#import <CocoaLumberjack.h>

#import <Twinlife/TLTwincodeURI.h>

#import <Twinme/TLContact.h>

#import <Utils/NSString+Utils.h>

#import "AuthentifiedRelationViewController.h"
#import "SuccessAuthentifiedRelationView.h"

#import "AlertMessageView.h"
#import "OnboardingConfirmView.h"

#import <TwinmeCommon/Design.h>
#import <TwinmeCommon/MainViewController.h>
#import <TwinmeCommon/MnemonicCodeUtils.h>
#import <TwinmeCommon/ShowContactService.h>
#import <TwinmeCommon/TwinmeNavigationController.h>
#import <TwinmeCommon/Utils.h>

#import <CommonCrypto/CommonDigest.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static const CGFloat DESIGN_HIGHLIGHT_VIEW_CORNER_RADIUS = 4;

//
// Interface: AuthentifiedRelationViewController ()
//

@interface AuthentifiedRelationViewController () <AVCaptureMetadataOutputObjectsDelegate, ShowContactServiceDelegate, AlertMessageViewDelegate, ConfirmViewDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *certifiedViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *certifiedViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *certifiedViewTopConstraint;
@property (weak, nonatomic) IBOutlet UIView *certifiedView;
@property (weak, nonatomic) IBOutlet UIView *fingerPrintView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fingerPrintTitleLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fingerPrintTitleTrailingonstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fingerPrintTitleTopConstraint;
@property (weak, nonatomic) IBOutlet UILabel *fingerPrintTitle;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fingerPrintContentViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fingerPrintContentViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fingerPrintContentViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fingerPrintContentViewTrailingonstraint;
@property (weak, nonatomic) IBOutlet UIView *fingerPrintContentView;
@property (weak, nonatomic) IBOutlet UILabel *fingerPrintLabel;
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
@property (nonatomic) BOOL showOnboardingView;
@property (nonatomic) BOOL showWords;

@property (nonatomic) TLContact *contact;
@property (nonatomic) TLCertificationLevel certificationLevel;
@property (nonatomic) ShowContactService *showContactService;
@property (nonatomic) TLTwincodeURI *certifiedLink;
@property (nonatomic) UIImage *contactAvatar;
@property (nonatomic) NSArray<NSString *> *words;

@end

//
// Implementation: AuthentifiedRelationViewController
//

#undef LOG_TAG
#define LOG_TAG @"AuthentifiedRelationViewController"

@implementation AuthentifiedRelationViewController

- (instancetype)initWithCoder:(NSCoder *)coder {
    DDLogVerbose(@"%@ initWithCoder: %@", LOG_TAG, coder);
    
    self = [super initWithCoder:coder];
    
    if (self) {
        _showContactService = [[ShowContactService alloc] initWithTwinmeContext:self.twinmeContext delegate:self];
        _showWords = YES;
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
    
    if (!self.showOnboardingView && self.contact.certificationLevel != TLCertificationLevel4 && [self.twinmeApplication startOnboarding:OnboardingTypeCertifiedRelation]) {
        self.showOnboardingView = YES;
        OnboardingConfirmView *onboardingConfirmView = [[OnboardingConfirmView alloc] init];
        onboardingConfirmView.confirmViewDelegate = self;

        UIImage *image = [self.twinmeApplication darkModeEnable] ? [UIImage imageNamed:@"OnboardingAuthentifiedRelationDark"] : [UIImage imageNamed:@"OnboardingAuthentifiedRelation"];
        NSString *message =  TwinmeLocalizedString(@"authentified_relation_view_controller_onboarding_message", nil);
        
        NSMutableAttributedString *attributedTitle = [[NSMutableAttributedString alloc] initWithString:TwinmeLocalizedString(@"authentified_relation_view_controller_to_be_certified_title", nil) attributes:[NSDictionary dictionaryWithObjectsAndKeys:Design.FONT_BOLD36, NSFontAttributeName, Design.FONT_COLOR_DEFAULT, NSForegroundColorAttributeName, nil]];
        [attributedTitle appendAttributedString:[[NSMutableAttributedString alloc] initWithString:@"\n\n"]];
        [attributedTitle appendAttributedString:[[NSMutableAttributedString alloc] initWithString:TwinmeLocalizedString(@"authentified_relation_view_controller_onboarding_subtitle", nil) attributes:[NSDictionary dictionaryWithObjectsAndKeys:Design.FONT_MEDIUM34, NSFontAttributeName, Design.FONT_COLOR_GREY, NSForegroundColorAttributeName, nil]]];
                
        [onboardingConfirmView initWithTitle:TwinmeLocalizedString(@"authentified_relation_view_controller_to_be_certified_title", nil) message:message image:image action:TwinmeLocalizedString(@"authentified_relation_view_controller_start", nil) actionColor:nil cancel:TwinmeLocalizedString(@"application_do_not_display", nil)];
        [onboardingConfirmView updateTitle:attributedTitle];
        
        [self.navigationController.view addSubview:onboardingConfirmView];
        [onboardingConfirmView showConfirmView];
    }
    
    [self updateContact];
}

- (void)finish {
    DDLogVerbose(@"%@ finish", LOG_TAG);
    
    if (self.showContactService) {
        [self.showContactService dispose];
        self.showContactService = nil;
    }
    
    self.navigationController.navigationBarHidden = YES;
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Public methods

- (void)initWithContact:(TLContact *)contact {
    DDLogVerbose(@"%@ initWithContact: %@", LOG_TAG, contact);
    
    self.contact = contact;
    self.certificationLevel = self.contact.certificationLevel;
    [self.showContactService initWithContact:contact];
    
    [self.showContactService getImageWithContact:self.contact withBlock:^(UIImage *image) {
        self.contactAvatar = image;
    }];
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

#pragma mark - AcceptInvitationDelegate

- (void)invitationDidFinish {
    DDLogVerbose(@"%@ invitationDidFinish", LOG_TAG);
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - ConfirmViewDelegate

- (void)didTapConfirm:(nonnull AbstractConfirmView *)abstractConfirmView {
    DDLogVerbose(@"%@ didTapConfirm: %@", LOG_TAG, abstractConfirmView);
        
    [abstractConfirmView closeConfirmView];
}

- (void)didTapCancel:(nonnull AbstractConfirmView *)abstractConfirmView {
    DDLogVerbose(@"%@ didTapCancel: %@", LOG_TAG, abstractConfirmView);
    
    if ([abstractConfirmView isKindOfClass:[OnboardingConfirmView class]]) {
        [self.twinmeApplication setShowOnboardingType:OnboardingTypeCertifiedRelation state:NO];
        [abstractConfirmView closeConfirmView];
    }
}

- (void)didClose:(nonnull AbstractConfirmView *)abstractConfirmView {
    DDLogVerbose(@"%@ didClose: %@", LOG_TAG, abstractConfirmView);
    
    [abstractConfirmView closeConfirmView];
}

- (void)didFinishCloseAnimation:(nonnull AbstractConfirmView *)abstractConfirmView {
    DDLogVerbose(@"%@ didFinishCloseAnimation: %@", LOG_TAG, abstractConfirmView);
    
    [abstractConfirmView removeFromSuperview];
}

#pragma mark - ShowContactServiceDelegate

- (void)onRefreshContactAvatar:(nonnull UIImage *)avatar {
    DDLogVerbose(@"%@ onRefreshContactAvatar: %@", LOG_TAG, avatar);

}

- (void)onUpdateContact:(nonnull TLContact *)contact avatar:(nullable UIImage *)avatar {
    DDLogVerbose(@"%@ onUpdateContact: %@", LOG_TAG, contact);
    
    if (!self.contact || ![contact.uuid isEqual:self.contact.uuid]) {
        return;
    }
    
    if (self.certificationLevel != contact.certificationLevel && contact.certificationLevel == TLCertificationLevel4) {
        [self showSuccessAuthentification];
    }
    
    self.contact = contact;
    self.certificationLevel = self.contact.certificationLevel;
    
    [self updateContact];
}

- (void)onDeleteContact:(NSUUID *)contactId {
    DDLogVerbose(@"%@ onDeleteContact: %@", LOG_TAG, contactId);
    
    if (!self.contact || ![contactId isEqual:self.contact.uuid]) {
        return;
    }
    
    [self finish];
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
    
    [self setNavigationTitle:TwinmeLocalizedString(@"authentified_relation_view_controller_to_be_certified_title", nil)];
    
    self.certifiedViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.certifiedViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.certifiedViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.certifiedView.backgroundColor = Design.POPUP_BACKGROUND_COLOR;
    self.certifiedView.layer.cornerRadius = Design.CONTAINER_RADIUS;
    self.certifiedView.clipsToBounds = YES;
    
    self.fingerPrintView.backgroundColor = Design.POPUP_BACKGROUND_COLOR;
    self.fingerPrintView.layer.cornerRadius = Design.POPUP_RADIUS;
    self.fingerPrintView.clipsToBounds = YES;
    
    self.fingerPrintTitleLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.fingerPrintTitleTrailingonstraint.constant *= Design.WIDTH_RATIO;
    self.fingerPrintTitleTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.fingerPrintTitle.font = Design.FONT_MEDIUM32;
    self.fingerPrintTitle.textColor = Design.FONT_COLOR_DEFAULT;
    self.fingerPrintTitle.text = TwinmeLocalizedString(@"authentified_relation_view_controller_relation_print_title", nil);
    
    self.fingerPrintContentViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.fingerPrintContentViewBottomConstraint.constant *= Design.HEIGHT_RATIO;
    self.fingerPrintContentViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.fingerPrintContentViewTrailingonstraint.constant *= Design.WIDTH_RATIO;
    
    self.fingerPrintContentView.backgroundColor = Design.GREY_BACKGROUND_COLOR;
    self.fingerPrintContentView.layer.cornerRadius = Design.POPUP_RADIUS;
    self.fingerPrintContentView.clipsToBounds = YES;
    self.fingerPrintContentView.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *fingerPrintGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleFingerPrintTapGesture:)];
    [self.fingerPrintContentView addGestureRecognizer:fingerPrintGestureRecognizer];
    
    self.fingerPrintLabel.font = Design.FONT_BOLD44;
    self.fingerPrintLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.fingerPrintLabel.text = @"";
    
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
}

- (void)handleDecodeWithURI:(nonnull NSURL *)uri {
    DDLogVerbose(@"%@ handleDecodeWithURI: %@", LOG_TAG, uri);
    
    [self.showContactService verifyAuthenticateWithURI:uri withBlock:^(TLBaseServiceErrorCode errorCode, TLContact *contact) {
        if (errorCode == TLBaseServiceErrorCodeSuccess) {
            self.contact = contact;
            [self updateContact];
            // Only display success if we reached level 4 (we could change from level 1 to level 3).
            if (contact.certificationLevel == TLCertificationLevel4) {
                [self showSuccessAuthentification];
            }
        } else {
            [self incorrectQRCode:errorCode];
        }
    }];
}

- (void)handleDecodeWithDecodedResult:(nonnull NSString *)decodedResult {
    DDLogVerbose(@"%@ handleDecodeWithDecodedResult: %@", LOG_TAG, decodedResult);
    
    NSURL *uri = [[NSURL alloc] initWithString:decodedResult];
    
    [self handleDecodeWithURI:uri];
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
    [self.tabBarController.view addSubview:alertMessageView];
    [alertMessageView showAlertView];
}

- (void)handleFingerPrintTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleFingerPrintTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        
        self.showWords = !self.showWords;
        [self updateFingerPrint];
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

- (void)updateQRCode {
    DDLogVerbose(@"%@ updateQRCode", LOG_TAG);
    
    if (!self.certifiedLink) {
        [self.showContactService createAuthenticateURIWithBlock:^(TLBaseServiceErrorCode errorCode, TLTwincodeURI *twincodeURI) {
            if (errorCode == TLBaseServiceErrorCodeSuccess) {
                self.certifiedLink = twincodeURI;
                [self updateContact];
                
                if (self.contact.certificationLevel != TLCertificationLevel4) {
                    UIImage *qrCode = [Utils makeQRCodeWithUri:self.certifiedLink scale:10];
                    self.qrcodeView.image = qrCode;
                }
            }
        }];
    }
}

- (void)updateContact {
    DDLogVerbose(@"%@ updateContact", LOG_TAG);
    
    if (self.contact.certificationLevel == TLCertificationLevel2
        || (self.contact.certificationLevel == TLCertificationLevel1 && !self.contact.publicPeerTwincodeOutboundId)) {
        [self setNavigationTitle:TwinmeLocalizedString(@"authentified_relation_view_controller_to_be_certified_title", nil)];
        self.captureView.hidden = NO;
        self.certifiedView.hidden = YES;
        self.fingerPrintView.hidden = YES;
        
        [self setupCaptureSession];
        self.previewLayer.frame = self.captureView.bounds;
        self.messageLabel.text = [NSString stringWithFormat:TwinmeLocalizedString(@"authentified_relation_view_controller_level_2", nil), self.contact.name];
    } else {
        self.captureView.hidden = YES;
        
        if (self.contact.certificationLevel != TLCertificationLevel4) {
            [self setNavigationTitle:TwinmeLocalizedString(@"authentified_relation_view_controller_to_be_certified_title", nil)];
            self.qrcodeView.hidden = NO;
            self.certifiedView.hidden = NO;
            self.fingerPrintView.hidden = YES;
            self.messageLabel.text = [NSString stringWithFormat:TwinmeLocalizedString(@"authentified_relation_view_controller_level_3", nil), self.contact.name];
        } else {
            [self setNavigationTitle:TwinmeLocalizedString(@"authentified_relation_view_controller_title", nil)];
            self.qrcodeView.hidden = YES;
            self.certifiedView.hidden = YES;
            self.fingerPrintView.hidden = NO;
            
            self.messageLabel.text = [NSString stringWithFormat:@"%@\n\n %@", [NSString stringWithFormat:TwinmeLocalizedString(@"authentified_relation_view_controller_level_4", nil), self.contact.name], TwinmeLocalizedString(@"authentified_relation_view_controller_relation_print_message", nil)];
            
            if (self.certifiedLink) {
                [self updateFingerPrint];
            }
        }
    }
}

- (void)updateFingerPrint {
    DDLogVerbose(@"%@ updateFingerPrint", LOG_TAG);
    
    if (!self.certifiedLink) {
        return;
    }
    
    if (!self.words) {
        MnemonicCodeUtils *mNemonicCodeUtils = [[MnemonicCodeUtils alloc]init];
        
        NSMutableData *outData = [NSMutableData dataWithLength:CC_SHA256_DIGEST_LENGTH];
        NSData *data = [self.certifiedLink.label dataUsingEncoding:NSUTF8StringEncoding];
        CC_SHA256(data.bytes, (CC_LONG) data.length,  outData.mutableBytes);
        
        self.words = [mNemonicCodeUtils xorAndMnemonicWithData:outData locale:[NSLocale currentLocale]];
    }
    
    if (self.showWords) {
        NSMutableString *mutableString = [[NSMutableString alloc]initWithString:@""];
        for (NSString *word in self.words) {
            if (![mutableString isEqual:@""]) {
                [mutableString appendString:@"\n"];
            }
            [mutableString appendString:word];
        }
        
        self.fingerPrintLabel.text = mutableString.uppercaseString;
    } else {
        self.fingerPrintLabel.text = self.certifiedLink.label.uppercaseString;
    }
}

- (void)showSuccessAuthentification {
    DDLogVerbose(@"%@ showSuccessAuthentification", LOG_TAG);
    
    SuccessAuthentifiedRelationView *successAuthentifiedRelationView = [[SuccessAuthentifiedRelationView alloc] init];
    successAuthentifiedRelationView.confirmViewDelegate = self;
    [successAuthentifiedRelationView initWithTitle:self.contact.name message:[NSString stringWithFormat:TwinmeLocalizedString(@"authentified_relation_view_controller_certified_message", nil), self.contact.name] avatar:self.contactAvatar icon:nil];
    [self.navigationController.view addSubview:successAuthentifiedRelationView];
    [successAuthentifiedRelationView showConfirmView];
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    [self.messageLabel setFont:Design.FONT_REGULAR34];
    [self.messageScanLabel setFont:Design.FONT_MEDIUM32];
    [self.messageNoPermissionScanLabel setFont:Design.FONT_MEDIUM32];
    self.fingerPrintTitle.font = Design.FONT_MEDIUM32;
    self.fingerPrintLabel.font = Design.FONT_BOLD44;
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    self.qrcodeView.backgroundColor = Design.WHITE_COLOR;
    self.messageLabel.textColor = Design.FONT_COLOR_DEFAULT;
    
    self.fingerPrintTitle.textColor = Design.FONT_COLOR_DEFAULT;
    self.fingerPrintLabel.textColor = Design.FONT_COLOR_DEFAULT;
}

@end
