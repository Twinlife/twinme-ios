/*
 *  Copyright (c) 2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import "ProxyViewController.h"

#import "AddProxyViewController.h"

#import <Twinlife/TLConnectivityService.h>
#import <Twinlife/TLProxyDescriptor.h>

#include <Photos/Photos.h>

#import <Utils/NSString+Utils.h>

#import <TwinmeCommon/Design.h>
#import <TwinmeCommon/ProxyService.h>
#import <TwinmeCommon/Utils.h>

#import "DeviceAuthorization.h"
#import "OnboardingConfirmView.h"
#import "DefaultConfirmView.h"
#import "ProxyView.h"
#import "UIView+Toast.h"

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static NSString * URL_PATTERN = @"((http|https)://)?([(w|W)]{3}+\\.)?+(.)+\\.+[A-Za-z]{2,3}+(\\.)?+(/(.)*)?";
static NSString * IP_PATTERN = @"^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}$";

static const CGFloat DESIGN_QRCODE_TOP_MARGIN = 60;

//
// Interface: ProxyViewController ()
//

@interface ProxyViewController () <ProxyServiceDelegate, PHPhotoLibraryChangeObserver>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerViewTopConstraint;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *qrcodeViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *qrcodeViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *qrcodeView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *proxyLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *proxyLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *proxyLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *proxyLabel;
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
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *editViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *editViewTopConstraint;
@property (weak, nonatomic) IBOutlet UIView *editView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *editRoundedViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *editRoundedView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *editImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *editImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *editLabelTopConstraint;
@property (weak, nonatomic) IBOutlet UILabel *editLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *proxyCopyViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *proxyCopyView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *proxyCopyRoundedViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *proxyCopyRoundedView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *proxyCopyImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *proxyCopyImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *proxyCopyLabelTopConstraint;
@property (weak, nonatomic) IBOutlet UILabel *proxyCopyLabel;
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
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageLabelTopConstraint;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *removeViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *removeView;
@property (weak, nonatomic) IBOutlet UILabel *removeLabel;

@property (weak, nonatomic, nullable) TLSNIProxyDescriptor *proxyDescriptor;
@property (nonatomic) ProxyService *proxyService;

@property (nonatomic) BOOL saveQRCodeInGallery;
@property (nonatomic) BOOL zoomQRCode;
@property (nonatomic) CGFloat qrCodeInitialTop;
@property (nonatomic) CGFloat qrCodeInitialHeight;
@property (nonatomic) CGFloat qrCodeMaxHeight;

@end

//
// Implementation: ProxyViewController
//

#undef LOG_TAG
#define LOG_TAG @"ProxyViewController"

@implementation ProxyViewController

#pragma mark - UIViewController

- (instancetype)initWithCoder:(NSCoder *)coder {
    DDLogVerbose(@"%@ initWithCoder: %@", LOG_TAG, coder);
    
    self = [super initWithCoder:coder];
    
    if (self) {
        _saveQRCodeInGallery = NO;
        _qrCodeInitialTop = DESIGN_QRCODE_TOP_MARGIN * Design.HEIGHT_RATIO;
        _qrCodeInitialHeight = 0;
        _qrCodeMaxHeight = 0;
        _proxyService = [[ProxyService alloc] initWithTwinmeContext:self.twinmeContext delegate:self];
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
    
    NSMutableArray *proxies = [[self.twinmeContext getConnectivityService] getUserProxies];
    if (self.proxyPosition >= 0 && self.proxyPosition < proxies.count) {
        self.proxyDescriptor = [proxies objectAtIndex:self.proxyPosition];
    }
    
    if (self.proxyDescriptor) {
        [self.proxyService getProxyURI:self.proxyDescriptor];
    } else {
        [self finish];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    DDLogVerbose(@"%@ viewWillDisappear: %@", LOG_TAG, animated ? @"YES" : @"NO");
    
    [super viewWillDisappear:animated];
}

#pragma mark - ProxyServiceDelegate

- (void)onAddProxy:(nonnull TLSNIProxyDescriptor *)proxyDescriptor {
    DDLogVerbose(@"%@ onAddProxy: %@", LOG_TAG, proxyDescriptor);
    
}

- (void)onDeleteProxy:(nonnull TLSNIProxyDescriptor *)proxyDescriptor {
    DDLogVerbose(@"%@ onDeleteProxy: %@", LOG_TAG, proxyDescriptor);
    
    if ([proxyDescriptor isEqual:self.proxyDescriptor]) {
        [self finish];
    }
}

- (void)onErrorAddProxy {
    DDLogVerbose(@"%@ onErrorAddProxy", LOG_TAG);
        
}

- (void)onErrorAlreadyUsed {
    DDLogVerbose(@"%@ onErrorAlreadyUsed", LOG_TAG);
    
}

- (void)onErrorLimitReached {
    DDLogVerbose(@"%@ onErrorLimitReached", LOG_TAG);
    
}

- (void)onGetProxyUri:(nullable TLTwincodeURI *)twincodeURI proxyescriptor:(nonnull TLSNIProxyDescriptor *)proxyDescriptor {
    DDLogVerbose(@"%@ onGetProxyUri: %@ proxyescriptor: %@", LOG_TAG, twincodeURI, proxyDescriptor);
    
    if (twincodeURI && [self.proxyDescriptor isEqual:proxyDescriptor]) {
        [self updateProxy:twincodeURI];
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

#pragma mark - Private methods

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
        
    self.view.backgroundColor = Design.GREY_BACKGROUND_COLOR;
    
    [self setNavigationTitle:TwinmeLocalizedString(@"proxy_view_controller_title", nil)];
    
    self.containerViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.containerViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.containerViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.containerView.backgroundColor = Design.POPUP_BACKGROUND_COLOR;
    self.containerView.clipsToBounds = YES;
    
    self.containerView.layer.shadowOpacity = Design.SHADOW_OPACITY;
    self.containerView.layer.shadowOffset = Design.SHADOW_OFFSET;
    self.containerView.layer.shadowRadius = Design.SHADOW_RADIUS;
    self.containerView.layer.shadowColor = Design.SHADOW_COLOR_DEFAULT.CGColor;
    self.containerView.layer.cornerRadius = Design.POPUP_RADIUS;
    self.containerView.layer.masksToBounds = NO;
    
    self.qrcodeViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.qrcodeViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.qrcodeView.clipsToBounds = YES;
    self.qrcodeView.layer.cornerRadius = Design.CONTAINER_RADIUS;
    self.qrcodeView.userInteractionEnabled = YES;
    self.qrcodeView.backgroundColor = [UIColor whiteColor];
    
    [self.qrcodeView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleQRCodeTapGesture:)]];
        
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
    
    self.proxyLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.proxyLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.proxyLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    [self.proxyLabel setFont:Design.FONT_MEDIUM28];
    self.proxyLabel.textColor = [UIColor whiteColor];
    self.proxyLabel.numberOfLines = 1;
    [self.proxyLabel setAdjustsFontSizeToFitWidth:YES];
    self.proxyLabel.userInteractionEnabled = YES;
    [self.proxyLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleProxyCopyTapGesture:)]];
    
    self.editViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.editViewTopConstraint.constant *= Design.HEIGHT_RATIO;
        
    UITapGestureRecognizer *editCodeGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleEditTapGesture:)];
    [self.editView addGestureRecognizer:editCodeGestureRecognizer];
    self.editView.isAccessibilityElement = YES;
    self.editView.accessibilityLabel = TwinmeLocalizedString(@"application_edit", nil);
    
    self.editRoundedViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.editRoundedView.clipsToBounds = YES;
    self.editRoundedView.backgroundColor = Design.WHITE_COLOR;
    self.editRoundedView.layer.cornerRadius = self.editRoundedViewHeightConstraint.constant * 0.5;
    self.editRoundedView.layer.borderColor = Design.GREY_ITEM.CGColor;
    self.editRoundedView.layer.borderWidth = 1.0;
    
    self.editImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.editImageView.tintColor = Design.BLACK_COLOR;
    
    self.editLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.editLabel.font = Design.FONT_MEDIUM28;
    self.editLabel.textColor = [UIColor whiteColor];
    self.editLabel.text = TwinmeLocalizedString(@"application_edit", nil);
    
    self.saveViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.saveViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    UITapGestureRecognizer *saveCodeGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSaveQRCodeTapGesture:)];
    [self.saveView addGestureRecognizer:saveCodeGestureRecognizer];
    self.saveView.isAccessibilityElement = YES;
    self.saveView.accessibilityLabel = TwinmeLocalizedString(@"application_save", nil);
    
    self.saveRoundedViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.saveRoundedView.clipsToBounds = YES;
    self.saveRoundedView.backgroundColor = Design.WHITE_COLOR;
    self.saveRoundedView.layer.cornerRadius = self.saveRoundedViewHeightConstraint.constant * 0.5;
    self.saveRoundedView.layer.borderColor = Design.GREY_ITEM.CGColor;
    self.saveRoundedView.layer.borderWidth = 1.0;

    self.saveImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.saveImageView.tintColor =Design.BLACK_COLOR;
    
    self.saveLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.saveLabel.font = Design.FONT_MEDIUM28;
    self.saveLabel.textColor = [UIColor whiteColor];
    self.saveLabel.text = TwinmeLocalizedString(@"application_save", nil);
    
    self.proxyCopyViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    UITapGestureRecognizer *proxyCopyGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleProxyCopyTapGesture:)];
    [self.proxyCopyView addGestureRecognizer:proxyCopyGestureRecognizer];
    self.proxyCopyView.isAccessibilityElement = YES;
    self.proxyCopyView.accessibilityLabel = TwinmeLocalizedString(@"conversation_view_controller_menu_item_view_copy_title", nil);
    
    self.proxyCopyRoundedViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.proxyCopyRoundedView.clipsToBounds = YES;
    self.proxyCopyRoundedView.backgroundColor = [UIColor blackColor];
    self.proxyCopyRoundedView.layer.cornerRadius = self.proxyCopyRoundedViewHeightConstraint.constant * 0.5;
    self.proxyCopyRoundedView.layer.borderColor = Design.GREY_ITEM.CGColor;
    self.proxyCopyRoundedView.layer.borderWidth = 1.0;
    
    self.proxyCopyImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.proxyCopyImageView.tintColor = Design.BLACK_COLOR;
    
    self.proxyCopyLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.proxyCopyLabel.font = Design.FONT_MEDIUM28;
    self.proxyCopyLabel.textColor = [UIColor whiteColor];
    self.proxyCopyLabel.text = TwinmeLocalizedString(@"conversation_view_controller_menu_item_view_copy_title", nil);
    
    self.shareViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.shareViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.shareViewBottomConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.shareView.backgroundColor = Design.MAIN_COLOR;
    self.shareView.userInteractionEnabled = YES;
    self.shareView.layer.cornerRadius = self.shareViewHeightConstraint.constant * 0.5;
    self.shareView.clipsToBounds = YES;
    self.shareView.isAccessibilityElement = YES;
    self.shareView.accessibilityLabel = TwinmeLocalizedString(@"share_view_controller_title", nil);
    [self.shareView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleShareTapGesture:)]];
    
    self.shareImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.shareImageViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.shareImageView.tintColor = [UIColor whiteColor];
    
    self.shareLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.shareLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
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
    
    self.messageLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.messageLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.messageLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    [self.messageLabel setFont:Design.FONT_REGULAR30];
    self.messageLabel.textColor = [UIColor whiteColor];
    self.messageLabel.text = TwinmeLocalizedString(@"proxy_view_controller_share_message", nil);
        
    self.removeViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.removeView.backgroundColor = Design.BACKGROUND_COLOR_WHITE_OPACITY11;
    UITapGestureRecognizer *removeViewGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleRemoveTapGesture:)];
    [self.removeView addGestureRecognizer:removeViewGestureRecognizer];
    
    self.removeLabel.font = Design.FONT_REGULAR34;
    self.removeLabel.textColor = Design.DELETE_COLOR_RED;
    self.removeLabel.text = TwinmeLocalizedString(@"application_delete", nil);

    self.qrCodeInitialHeight = self.qrcodeViewHeightConstraint.constant;
    self.qrCodeInitialTop = self.qrcodeViewTopConstraint.constant;
    self.qrCodeMaxHeight = self.containerViewWidthConstraint.constant - self.proxyLabelLeadingConstraint.constant - self.proxyLabelTrailingConstraint.constant;
}

- (void)finish {
    DDLogVerbose(@"%@ finish",LOG_TAG);
    
    if (self.proxyService) {
        [self.proxyService dispose];
        self.proxyService = nil;
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)updateProxy:(nonnull TLTwincodeURI *)twincodeURI {
    DDLogVerbose(@"%@ updateProxy", LOG_TAG);
    
    if (self.proxyDescriptor) {
        NSString *proxyURL = [NSString stringWithFormat:@"%@/%@", TLTwincodeURI.PROXY_ACTION, self.proxyDescriptor.proxyDescription];
        self.qrcodeView.image = [Utils makeQRCode:proxyURL scale:10];
    }
    self.proxyLabel.text = self.proxyDescriptor.proxyDescription;
}

- (void)handleQRCodeTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleQRCodeTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        [self updateQRCodeSize];
    }
}

- (void)updateQRCodeSize {
    DDLogVerbose(@"%@ updateProfile", LOG_TAG);
    
    self.zoomQRCode = !self.zoomQRCode;
    float alpha = self.zoomQRCode ? 0.0 : 1.0;
    
    CGFloat qrCodeHeight = self.zoomQRCode ? self.qrCodeMaxHeight : self.qrCodeInitialHeight;
    CGFloat qrCodeTop = self.qrCodeInitialTop;
    CGFloat animateActionDelay = self.zoomQRCode ? 0.f : 0.1f;
    CGFloat animateQRCodeDelay = self.zoomQRCode ? 0.1f : 0.f;
   
    [self animateQRCodeAction:alpha delay:animateActionDelay];
    [self animateQRCodeSize:qrCodeTop height:qrCodeHeight delay:animateQRCodeDelay];
}

- (void)animateQRCodeAction:(CGFloat)alpha delay:(CGFloat)delay {
    DDLogVerbose(@"%@ animateQRCodeAction", LOG_TAG);
        
    [UIView animateWithDuration:0.1 delay:delay options: UIViewAnimationOptionCurveEaseInOut animations:^{
        self.proxyCopyView.alpha = alpha;
        self.editView.alpha = alpha;
        self.saveView.alpha = alpha;
        self.zoomView.alpha = alpha;
        self.proxyLabel.alpha = alpha;
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

- (void)handleEditTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleEditTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        AddProxyViewController *proxyViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AddProxyViewController"];
        proxyViewController.proxyDescriptor = self.proxyDescriptor;
        [self.navigationController pushViewController:proxyViewController animated:YES];
    }
}

- (void)handleProxyCopyTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleProxyCopyTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        [self hapticFeedBack:UIImpactFeedbackStyleHeavy];
        [[UIPasteboard generalPasteboard] setString:self.proxyDescriptor.proxyDescription];
        [[UIApplication sharedApplication].keyWindow makeToast:TwinmeLocalizedString(@"conversation_view_controller_menu_item_view_copy_message",nil)];
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

- (void)handleRemoveTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleRemoveTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {

        if (!self.proxyDescriptor) {
            return;
        }
        
        [self.proxyService deleteProxy:self.proxyDescriptor];
    }
}

- (void)handleShareTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleShareTapGesture ", LOG_TAG);
 
    [self hapticFeedBack:UIImpactFeedbackStyleHeavy];
        
    NSString *urlString = [NSString stringWithFormat:@"%@/%@", TLTwincodeURI.PROXY_ACTION, self.proxyDescriptor.proxyDescription];
    
    NSString *message = [NSString stringWithFormat:TwinmeLocalizedString(@"proxy_view_controller_share", nil), urlString];
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
    
    UIImage *qrcodeToSave;
    ProxyView *proxyView;
    
    if (self.proxyDescriptor) {
        proxyView = [[ProxyView alloc] initWithProxy:self.proxyDescriptor.proxyDescription qrcode:self.qrcodeView.image message:TwinmeLocalizedString(@"proxy_view_controller_share_message", nil)];
        qrcodeToSave = [proxyView screenshot];
    }
    
    if (!qrcodeToSave) {
        return;
    }
    
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title = %@", TwinmeLocalizedString(@"application_name", nil)];
    PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
    fetchOptions.predicate = predicate;
    PHFetchResult *result = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAny options:fetchOptions];
    
    proxyView = nil;
    
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

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    self.removeLabel.font = Design.FONT_REGULAR34;
    [self.saveLabel setFont:Design.FONT_MEDIUM28];
    [self.proxyCopyLabel setFont:Design.FONT_MEDIUM28];
    [self.editLabel setFont:Design.FONT_MEDIUM28];
    self.proxyLabel.font = Design.FONT_BOLD34;
    [self.messageLabel setFont:Design.FONT_REGULAR28];
    [self.shareLabel setFont:Design.FONT_MEDIUM32];
    self.shareSubLabel.font = Design.FONT_REGULAR24;
    self.removeLabel.font = Design.FONT_REGULAR34;
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    self.view.backgroundColor = Design.GREY_BACKGROUND_COLOR;
    self.proxyLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.containerView.backgroundColor = Design.POPUP_BACKGROUND_COLOR;
    self.messageLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.saveLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.editLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.proxyCopyLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.shareSubLabel.textColor = Design.FONT_COLOR_GREY;
    self.shareView.backgroundColor = Design.MAIN_COLOR;
    self.removeLabel.textColor = Design.DELETE_COLOR_RED;
    
    self.editRoundedView.backgroundColor = Design.WHITE_COLOR;
    self.editRoundedView.layer.borderColor = Design.GREY_ITEM.CGColor;
    self.editImageView.tintColor = Design.BLACK_COLOR;
    
    self.saveRoundedView.backgroundColor = Design.WHITE_COLOR;
    self.saveRoundedView.layer.borderColor = Design.GREY_ITEM.CGColor;
    self.saveImageView.tintColor = Design.BLACK_COLOR;
    
    self.proxyCopyRoundedView.backgroundColor = Design.WHITE_COLOR;
    self.proxyCopyRoundedView.layer.borderColor = Design.GREY_ITEM.CGColor;
    self.proxyCopyImageView.tintColor = Design.BLACK_COLOR;
}

@end
