/*
 *  Copyright (c) 2022-2024 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <StoreKit/StoreKit.h>

#import "InAppSubscriptionViewController.h"
#import "InvitationSubscriptionViewController.h"
#import "WebViewController.h"

#import "InAppPurchaseManager.h"

#import "UIView+GradientBackgroundColor.h"
#import "CustomProgressBarView.h"
#import "TTTAttributedLabel.h"
#import "AlertView.h"

#import <TwinmeCommon/ApplicationDelegate.h>
#import <TwinmeCommon/Design.h>
#import <TwinmeCommon/InAppSubscriptionService.h>
#import <TwinmeCommon/TwinmeNavigationController.h>
#import <TwinmeCommon/UIViewController+Utils.h>

#import <Utils/NSString+Utils.h>


#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static UIColor *DESIGN_GREY_COLOR;
static UIColor *DESIGN_ACTIVITY_COLOR;
static UIColor *DESIGN_TOP_COLOR;
static UIColor *DESIGN_BOTTOM_COLOR;
static UIColor *DESIGN_DESCRIPTION_COLOR;
static UIColor *DESIGN_BEST_OFFER_COLOR;
static UIColor *DESIGN_SUBSCRIBE_COLOR;
static UIColor *DESIGN_BACKGROUND_DARK_COLOR;

static const int DESIGN_IMAGE_BOTTOM_MARGN = 6;

//
// Interface: InAppSubscriptionViewController ()
//

@interface InAppSubscriptionViewController () <InAppSubscriptionServiceDelegate, InAppPurchaseManagerDelegate, CustomProgressBarDelegate, TTTAttributedLabelDelegate, InvitationSubscriptionDelegate, AlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *laterViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *laterViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *laterViewTopConstraint;
@property (weak, nonatomic) IBOutlet UIView *laterView;
@property (weak, nonatomic) IBOutlet UILabel *laterLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *skredPlusLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet UILabel *skredPlusLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *descriptionViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *descriptionViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *descriptionViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *descriptionView;
@property (weak, nonatomic) IBOutlet UIView *descriptionShadowView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *progressBarOneViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *progressBarOneViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *progressBarOneViewTopConstraint;
@property (weak, nonatomic) IBOutlet CustomProgressBarView *progressBarOneView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *progressBarTwoViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *progressBarTwoViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet CustomProgressBarView *progressBarTwoView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *progressBarThreeViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *progressBarThreeViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet CustomProgressBarView *progressBarThreeView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *progressBarFourViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *progressBarFourViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet CustomProgressBarView *progressBarFourView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *descriptionLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *descriptionLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *descriptionLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *descriptionImageViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *descriptionImageViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *descriptionImageViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *descriptionImageViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *descriptionImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *oneYearSubscriptionViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *oneYearSubscriptionViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *oneYearSubscriptionViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *oneYearSubscriptionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *oneYearSubscriptionTitleLabelHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *oneYearSubscriptionTitleLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *oneYearSubscriptionTitleLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *oneYearSubscriptionTitleLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *oneYearSubscriptionTitleLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *oneYearSubscriptionSubTitleLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *oneYearSubscriptionSubTitleLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *oneYearSubscriptionSubTitleLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *oneYearSubscriptionSubTitleLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *oneYearSubscriptionDurationLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *oneYearSubscriptionDurationLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *oneYearSubscriptionDurationLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *oneYearSubscriptionDurationLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *oneYearSubscriptionUnitLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *oneYearSubscriptionUnitLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *oneYearSubscriptionUnitLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *oneYearSubscriptionUnitLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *oneYearSubscriptionPriceLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *oneYearSubscriptionPriceLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *oneYearSubscriptionPriceLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *oneYearSubscriptionPriceLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *oneYearSubscriptionReductionLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *oneYearSubscriptionReductionLabelBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *oneYearSubscriptionReductionLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *oneYearSubscriptionReductionLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *oneYearSubscriptionReductionLabel;
@property (weak, nonatomic) IBOutlet UIView *sixMonthSubscriptionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sixMonthSubscriptionTitleLabelHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sixMonthSubscriptionTitleLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sixMonthSubscriptionTitleLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sixMonthSubscriptionTitleLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *sixMonthSubscriptionTitleLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sixMonthSubscriptionSubTitleLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sixMonthSubscriptionSubTitleLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sixMonthSubscriptionSubTitleLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *sixMonthSubscriptionSubTitleLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sixMonthSubscriptionDurationLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sixMonthSubscriptionDurationLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sixMonthSubscriptionDurationLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *sixMonthSubscriptionDurationLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sixMonthSubscriptionUnitLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sixMonthSubscriptionUnitLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sixMonthSubscriptionUnitLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *sixMonthSubscriptionUnitLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sixMonthSubscriptionPriceLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sixMonthSubscriptionPriceLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sixMonthSubscriptionPriceLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *sixMonthSubscriptionPriceLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sixMonthSubscriptionReductionLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sixMonthSubscriptionReductionLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sixMonthSubscriptionReductionLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *sixMonthSubscriptionReductionLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *oneMonthSubscriptionViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet UIView *oneMonthSubscriptionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *oneMonthSubscriptionTitleLabelHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *oneMonthSubscriptionTitleLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *oneMonthSubscriptionTitleLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *oneMonthSubscriptionTitleLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *oneMonthSubscriptionTitleLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *oneMonthSubscriptionSubTitleLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *oneMonthSubscriptionSubTitleLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *oneMonthSubscriptionSubTitleLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *oneMonthSubscriptionSubTitleLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *oneMonthSubscriptionDurationLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *oneMonthSubscriptionDurationLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *oneMonthSubscriptionDurationLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *oneMonthSubscriptionDurationLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *oneMonthSubscriptionUnitLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *oneMonthSubscriptionUnitLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *oneMonthSubscriptionUnitLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *oneMonthSubscriptionUnitLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *oneMonthSubscriptionPriceLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *oneMonthSubscriptionPriceLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *oneMonthSubscriptionPriceLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *oneMonthSubscriptionPriceLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *freeTrialLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *freeTrialLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *freeTrialLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *freeTrialLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *subscribeViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *subscribeViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *subscribeViewTopConstraint;
@property (weak, nonatomic) IBOutlet UIView *subscribeView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *subscribeLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet UILabel *subscribeLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *restoreViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *restoreViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *restoreView;
@property (weak, nonatomic) IBOutlet UILabel *restoreLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *inviteViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *inviteViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *inviteView;
@property (weak, nonatomic) IBOutlet UILabel *inviteLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *footerLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *footerLabelBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *footerLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *footerLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *footerLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *closeViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *closeViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *closeView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *closeImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *closeImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *activityViewViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *activityViewViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *activityViewViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet UIView *activityView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *activityLabelBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *activityLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *activityLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *activityLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *activityIndicatorViewTopConstraint;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *subscribedLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *subscribedLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *subscribedLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *subscribedLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *premiumVersionImageHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *premiumVersionImageWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *premiumVersionImageTopConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *premiumVersionImage;

@property (nonatomic) InAppSubscriptionService *inAppSubscribeService;
@property (nonatomic) InAppPurchaseManager *inAppPurchaseManager;
@property (nonatomic) NSArray *products;
@property (nonatomic) SKProduct *selectedProduct;

@property (nonatomic) BOOL subscribeInProgress;
@property (nonatomic) BOOL isAlreadySubscribed;

@property (nonatomic) int descriptionStep;
@property (nonatomic) BOOL isVisible;
@property (nonatomic) TLTwincodeOutbound *subscriptionTwincode;
@property (nonatomic) UIImage *subscriptionImage;

@end

//
// Implementation: InAppSubscriptionViewController
//

#undef LOG_TAG
#define LOG_TAG @"InAppSubscriptionViewController"

@implementation InAppSubscriptionViewController

+ (void)initialize {
    DDLogVerbose(@"%@ initialize", LOG_TAG);
    
    DESIGN_GREY_COLOR = [UIColor colorWithRed:142./255. green:142./255. blue:147./255. alpha:1.0];
    DESIGN_ACTIVITY_COLOR = [UIColor colorWithRed:142./255. green:142./255. blue:142./255. alpha:1];
    DESIGN_TOP_COLOR = [UIColor colorWithRed:255./255. green:255./255. blue:255./255. alpha:1.0];
    DESIGN_BOTTOM_COLOR = [UIColor colorWithRed:231./255. green:231./255. blue:231./255. alpha:1.0];
    DESIGN_DESCRIPTION_COLOR = [UIColor colorWithRed:86./255. green:86./255. blue:86./255. alpha:1.0];
    DESIGN_BEST_OFFER_COLOR = [UIColor colorWithRed:255./255. green:32./255. blue:80./255. alpha:1.0];
    DESIGN_SUBSCRIBE_COLOR = [UIColor colorWithRed:255./255. green:32./255. blue:80./255. alpha:1.0];
    DESIGN_BACKGROUND_DARK_COLOR = [UIColor colorWithRed:52./255. green:52./255. blue:52./255. alpha:1.0];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    DDLogVerbose(@"%@ initWithCoder: %@", LOG_TAG, coder);
    
    self = [super initWithCoder:coder];
    
    if (self) {
        ApplicationDelegate *delegate = (ApplicationDelegate *)[[UIApplication sharedApplication] delegate];
        _isAlreadySubscribed = [delegate.twinmeApplication isSubscribedWithFeature:TLTwinmeApplicationFeatureGroupCall];
        
        _inAppPurchaseManager = [[InAppPurchaseManager alloc]initWithDelegate:self];
        [_inAppPurchaseManager getProducts];
        
        _inAppSubscribeService = [[InAppSubscriptionService alloc] initWithTwinmeContext:self.twinmeContext subscriptionTwincodeId:[self.twinmeApplication getInvitationSubscriptionTwincode]  delegate:self];
        _subscribeInProgress = NO;
        _descriptionStep = 0;
        _isVisible = NO;
    }
    return self;
}

- (void)viewDidLoad {
    DDLogVerbose(@"%@ viewDidLoad", LOG_TAG);
    
    [super viewDidLoad];
        
    [self initViews];
}

- (void)viewWillAppear:(BOOL)animated {
    DDLogVerbose(@"%@ viewWillAppear", LOG_TAG);
    
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    DDLogVerbose(@"%@ viewWillDisappear", LOG_TAG);
    
    [super viewWillDisappear:animated];
    
    self.navigationController.navigationBarHidden = NO;

    // Make sure to stop the animation while the view is hidden to avoid consuming 100% of CPU.
    self.isVisible = NO;
    [self.progressBarOneView stopAnimation];
    [self.progressBarTwoView stopAnimation];
    [self.progressBarThreeView stopAnimation];
    [self.progressBarFourView stopAnimation];
    self.descriptionStep = 0;
}

- (void)viewDidAppear:(BOOL)animated {
    DDLogVerbose(@"%@ viewDidAppear", LOG_TAG);
    
    [super viewDidAppear:animated];
    
    self.isVisible = YES;
    if (self.descriptionStep == 0) {
        [self nextDescription];
    }
    
    if (!self.isAlreadySubscribed) {
        self.containerViewHeightConstraint.constant = self.footerLabel.frame.origin.y + self.footerLabel.intrinsicContentSize.height + self.footerLabelBottomConstraint.constant;
    } else {
        self.containerViewHeightConstraint.constant = Design.DISPLAY_HEIGHT;
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    
    return UIStatusBarStyleDefault;
}

- (void)viewDidLayoutSubviews {
    DDLogVerbose(@"%@ viewDidLayoutSubviews", LOG_TAG);
    
    [super viewDidLayoutSubviews];
    
    if (self.descriptionStep == 0) {
        self.descriptionImageViewBottomConstraint.constant = 0;
        self.descriptionImageView.image = [UIImage imageNamed:@"InAppStep1"];
    }
    
    if (!self.isAlreadySubscribed) {
        self.containerViewHeightConstraint.constant = self.footerLabel.frame.origin.y + self.footerLabel.intrinsicContentSize.height + self.footerLabelBottomConstraint.constant;
    } else {
        self.containerViewHeightConstraint.constant = Design.DISPLAY_HEIGHT;
    }
}

#pragma mark - InAppPurchaseManagerDelegate

- (void)onGetProducts:(NSArray *)products {
    DDLogVerbose(@"%@ onGetProducts: %@", LOG_TAG, products);
    
    if(products) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.products = products;
            [self updateProducts];
            [self selectSubscription:SIX_MONTHS_SUBSCRIPTION_ID];
        });
    }
}

- (void)onTransactionSuccess:(SKPaymentTransaction *)transaction receipt:(NSString *)receipt {
    DDLogVerbose(@"%@ onTransactionSuccess: %@ receipt: %@", LOG_TAG, transaction, receipt);
    
    [self.inAppSubscribeService subscribeFeature:transaction.payment.productIdentifier purchaseToken:receipt purchaseOrderId:transaction.transactionIdentifier];
}

- (void)onTransactionRestored {
    DDLogVerbose(@"%@ onTransactionRestored", LOG_TAG);
    
    self.subscribeInProgress = NO;
    [self updateViews];
}

- (void)onTransactionFailed:(SKPaymentTransaction *)transaction {
    DDLogVerbose(@"%@ onTransactionFailed: %@", LOG_TAG, transaction);
    
    self.subscribeInProgress = NO;
    [self updateViews];
}

#pragma mark - InAppSubscriptionServiceDelegate

- (void)onSubscribeSuccess {
    DDLogVerbose(@"%@ onSubscribeSuccess", LOG_TAG);
    
    if (self.inAppSubscriptionViewControllerDelegate) {
        [self.inAppSubscriptionViewControllerDelegate onSubscribeSuccess];
    }
    self.subscribeInProgress = NO;
    [self updateViews];
    
    [self finish];
}

- (void)onSubscribeCancel {
    DDLogVerbose(@"%@ onSubscribeCancel", LOG_TAG);
    
    if ([self.twinmeApplication getInvitationSubscriptionImage]) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager removeItemAtPath:[self.twinmeApplication getInvitationSubscriptionImage] error:nil];
    }
    
    [self.twinmeApplication setInvitationSubscriptionTwincodeWithTwincode:nil];
    [self.twinmeApplication setInvitationSubscriptionImageWithImage:nil];
    
    self.subscribeInProgress = NO;
    [self updateViews];
    
    [self finish];
}

- (void)onSubscribeFailed:(TLBaseServiceErrorCode)errorCode {
    DDLogVerbose(@"%@ onSubscribeFailed errorCode: %d", LOG_TAG, errorCode);
    
    self.subscribeInProgress = NO;
    [self updateViews];
    [self finish];
}

- (void)onSubscriptionTwincode:(nonnull TLTwincodeOutbound *)twincodeOutbound image:(nonnull UIImage *)image {
    DDLogVerbose(@"%@ onSubscriptionTwincode: %@ image: %@", LOG_TAG, twincodeOutbound, image);
    
    self.subscriptionTwincode = twincodeOutbound;
    self.subscriptionImage = image;
    [self updateProducts];
}

#pragma mark - InAppSubscriptionServiceDelegate

- (void)invitationSubscriptionSuccess {
    DDLogVerbose(@"%@ invitationSubscriptionSuccess", LOG_TAG);
    
    if (self.inAppSubscriptionViewControllerDelegate) {
        [self.inAppSubscriptionViewControllerDelegate onSubscribeSuccess];
    }
    self.subscribeInProgress = NO;
    [self updateViews];
    
    [self finish];
}

#pragma mark - CustomProgressBarDelegate

- (void)customProgressBarEndAnimation:(CustomProgressBarView *)customProgressBarView {
    DDLogVerbose(@"%@ customProgressBarEndAnimation: %@", LOG_TAG, customProgressBarView);
    
    if (self.isVisible) {
        [self nextDescription];
    }
}

#pragma mark - TTTAttributedLabelDelegate

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    DDLogVerbose(@"%@ attributedLabel: %@ didSelectLinkWithURL: %@", LOG_TAG, label, url);
    
    WebViewController *webViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"WebViewController"];
    webViewController.fileName = url.host;
    webViewController.name = TwinmeLocalizedString(@"application_name", nil);
    [self.navigationController pushViewController:webViewController animated:YES];
}

#pragma mark - AlertViewDelegate

- (void)handleAcceptButtonClick:(AlertView *)alertView {
    DDLogVerbose(@"%@ handleAcceptButtonClick: %@", LOG_TAG, alertView);
    
    if ([self.twinmeApplication getInvitationSubscriptionTwincode]) {
        [self.inAppSubscribeService cancelFeature:[[self.twinmeApplication getInvitationSubscriptionTwincode] UUIDString]];
    }
}

- (void)handleCancelButtonClick:(AlertView *)alertView {
    DDLogVerbose(@"%@ handleCancelButtonClick: %@", LOG_TAG, alertView);

}

#pragma mark - Private methods

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    self.view.backgroundColor = Design.WHITE_COLOR;
    
    self.containerViewBottomConstraint.constant *= Design.HEIGHT_RATIO;
    self.containerViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.containerViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.containerViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.containerViewHeightConstraint.constant = Design.DISPLAY_HEIGHT;
    
    self.containerView.backgroundColor = Design.WHITE_COLOR;
    self.containerView.clipsToBounds = YES;
    self.containerView.layer.cornerRadius = Design.CONTAINER_RADIUS;
    
    self.laterViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.laterViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.laterViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.laterView.hidden = YES;
    self.laterView.userInteractionEnabled = YES;
    self.laterView.backgroundColor = [UIColor clearColor];
    [self.laterView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleLaterTapGesture:)]];
    
    self.laterLabel.font = Design.FONT_BOLD36;
    self.laterLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.laterLabel.text = TwinmeLocalizedString(@"application_later", nil).uppercaseString;
    
    self.skredPlusLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    
    self.skredPlusLabel.font = Design.FONT_BOLD54;
    self.skredPlusLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.skredPlusLabel.text = TwinmeLocalizedString(@"in_app_subscription_view_controller_title", nil);
    
    self.descriptionViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.descriptionViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.descriptionViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.descriptionView.layer.cornerRadius = Design.CONTAINER_RADIUS;
    
    if ([Design isDarkMode]) {
        [self.descriptionView setBackgroundColor:DESIGN_BACKGROUND_DARK_COLOR];
        self.titleLabel.textColor = [UIColor whiteColor];
        self.descriptionLabel.textColor = [UIColor whiteColor];
    } else {
        [self.descriptionView setupGradientBackgroundFromColors:@[(id)DESIGN_TOP_COLOR.CGColor, (id)DESIGN_BOTTOM_COLOR.CGColor]];
        self.titleLabel.textColor = [UIColor blackColor];
        self.descriptionLabel.textColor = DESIGN_DESCRIPTION_COLOR;
    }
    
    [self.descriptionView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDescriptionTapGesture:)]];
    
    self.descriptionShadowView.backgroundColor = Design.WHITE_COLOR;
    self.descriptionShadowView.layer.cornerRadius = Design.CONTAINER_RADIUS;
    self.descriptionShadowView.layer.shadowOpacity = Design.SHADOW_OPACITY;
    self.descriptionShadowView.layer.shadowOffset = Design.SHADOW_OFFSET;
    self.descriptionShadowView.layer.shadowRadius = Design.SHADOW_RADIUS;
    self.descriptionShadowView.layer.shadowColor = Design.SHADOW_COLOR.CGColor;
    self.descriptionShadowView.layer.masksToBounds = NO;
    
    CGFloat progressBarMargin = ((Design.DISPLAY_WIDTH - self.descriptionViewLeadingConstraint.constant - self.descriptionViewTrailingConstraint.constant) * 0.2) / 5;
    
    self.progressBarOneViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.progressBarOneViewTrailingConstraint.constant = progressBarMargin;
    self.progressBarOneViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.progressBarOneView.customProgressBarDelegate = self;
    
    self.progressBarTwoViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.progressBarTwoViewTrailingConstraint.constant = progressBarMargin * 0.5;
    
    self.progressBarTwoView.customProgressBarDelegate = self;
    
    self.progressBarThreeViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.progressBarThreeViewLeadingConstraint.constant = progressBarMargin * 0.5;
    
    self.progressBarThreeView.customProgressBarDelegate = self;
    
    self.progressBarFourViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.progressBarFourViewLeadingConstraint.constant = progressBarMargin;
    
    self.progressBarFourView.customProgressBarDelegate = self;
    
    self.titleLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.titleLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.titleLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.titleLabel.textColor = [UIColor blackColor];
    self.titleLabel.font = Design.FONT_MEDIUM36;
    self.titleLabel.text = TwinmeLocalizedString(@"in_app_subscription_view_controller_description_step1_title", nil);
    self.titleLabel.adjustsFontSizeToFitWidth = YES;
    
    self.descriptionLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.descriptionLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.descriptionLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.descriptionLabel.textColor = DESIGN_DESCRIPTION_COLOR;
    self.descriptionLabel.font = Design.FONT_MEDIUM32;
    self.descriptionLabel.text = TwinmeLocalizedString(@"in_app_subscription_view_controller_description_step1_subtitle", nil);
    self.descriptionLabel.adjustsFontSizeToFitWidth = YES;
    
    self.descriptionImageViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.descriptionImageViewBottomConstraint.constant *= Design.HEIGHT_RATIO;
    self.descriptionImageViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.descriptionImageViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.descriptionImageView.clipsToBounds = YES;
    
    self.oneYearSubscriptionViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.oneYearSubscriptionViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.oneYearSubscriptionViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.oneYearSubscriptionView.hidden = YES;
    self.oneYearSubscriptionView.layer.backgroundColor = [UIColor whiteColor].CGColor;
    self.oneYearSubscriptionView.layer.cornerRadius = Design.CONTAINER_RADIUS;
    self.oneYearSubscriptionView.layer.shadowOpacity = Design.SHADOW_OPACITY;
    self.oneYearSubscriptionView.layer.shadowOffset = Design.SHADOW_OFFSET;
    self.oneYearSubscriptionView.layer.shadowRadius = Design.SHADOW_RADIUS;
    self.oneYearSubscriptionView.layer.shadowColor = UIColor.clearColor.CGColor;
    self.oneYearSubscriptionView.layer.masksToBounds = NO;
    
    [self.oneYearSubscriptionView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleOneYearSubscriptionTapGesture:)]];
    
    self.oneYearSubscriptionTitleLabelHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.oneYearSubscriptionTitleLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.oneYearSubscriptionTitleLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.oneYearSubscriptionTitleLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.oneYearSubscriptionTitleLabel.textColor = DESIGN_GREY_COLOR;
    self.oneYearSubscriptionTitleLabel.font = Design.FONT_MEDIUM24;
    self.oneYearSubscriptionTitleLabel.text = @"";
    
    self.oneYearSubscriptionSubTitleLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.oneYearSubscriptionSubTitleLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.oneYearSubscriptionSubTitleLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.oneYearSubscriptionSubTitleLabel.textColor = DESIGN_GREY_COLOR;
    self.oneYearSubscriptionSubTitleLabel.font = Design.FONT_MEDIUM24;
    self.oneYearSubscriptionSubTitleLabel.text = TwinmeLocalizedString(@"in_app_subscription_view_controller_subscription_title", nil).uppercaseString;
    self.oneYearSubscriptionSubTitleLabel.adjustsFontSizeToFitWidth = YES;
    
    self.oneYearSubscriptionDurationLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.oneYearSubscriptionDurationLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.oneYearSubscriptionDurationLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.oneYearSubscriptionDurationLabel.textColor = [UIColor blackColor];
    self.oneYearSubscriptionDurationLabel.font = Design.FONT_REGULAR88;
    self.oneYearSubscriptionDurationLabel.text = TwinmeLocalizedString(@"12", nil);
    
    self.oneYearSubscriptionUnitLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.oneYearSubscriptionUnitLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.oneYearSubscriptionUnitLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.oneYearSubscriptionUnitLabel.textColor = [UIColor blackColor];
    self.oneYearSubscriptionUnitLabel.font = Design.FONT_REGULAR26;
    self.oneYearSubscriptionUnitLabel.text = TwinmeLocalizedString(@"in_app_subscription_view_controller_month", nil);
    
    self.oneYearSubscriptionPriceLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.oneYearSubscriptionPriceLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.oneYearSubscriptionPriceLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.oneYearSubscriptionPriceLabel.textColor = [UIColor blackColor];
    self.oneYearSubscriptionPriceLabel.font = Design.FONT_MEDIUM36;
    self.oneYearSubscriptionPriceLabel.text = @"";
    
    self.oneYearSubscriptionReductionLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.oneYearSubscriptionReductionLabelBottomConstraint.constant *= Design.HEIGHT_RATIO;
    self.oneYearSubscriptionReductionLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.oneYearSubscriptionReductionLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.oneYearSubscriptionReductionLabel.textColor = DESIGN_BEST_OFFER_COLOR;
    self.oneYearSubscriptionReductionLabel.font = Design.FONT_BOLD28;
    self.oneYearSubscriptionReductionLabel.text = @"";
        
    self.sixMonthSubscriptionView.hidden = YES;
    self.sixMonthSubscriptionView.layer.backgroundColor = [UIColor whiteColor].CGColor;
    self.sixMonthSubscriptionView.layer.cornerRadius = Design.CONTAINER_RADIUS;
    self.sixMonthSubscriptionView.layer.shadowOpacity = Design.SHADOW_OPACITY;
    self.sixMonthSubscriptionView.layer.shadowOffset = Design.SHADOW_OFFSET;
    self.sixMonthSubscriptionView.layer.shadowRadius = Design.SHADOW_RADIUS;
    self.sixMonthSubscriptionView.layer.shadowColor = Design.SHADOW_COLOR.CGColor;
    self.sixMonthSubscriptionView.layer.masksToBounds = NO;
    
    [self.sixMonthSubscriptionView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSixMonthSubscriptionTapGesture:)]];
    
    self.sixMonthSubscriptionTitleLabelHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.sixMonthSubscriptionTitleLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.sixMonthSubscriptionTitleLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.sixMonthSubscriptionTitleLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.sixMonthSubscriptionTitleLabel.clipsToBounds = YES;
    self.sixMonthSubscriptionTitleLabel.backgroundColor = DESIGN_BEST_OFFER_COLOR;
    self.sixMonthSubscriptionTitleLabel.layer.cornerRadius = Design.CONTAINER_RADIUS;
    self.sixMonthSubscriptionTitleLabel.numberOfLines = 2;
    self.sixMonthSubscriptionTitleLabel.textColor = [UIColor whiteColor];
    self.sixMonthSubscriptionTitleLabel.font = Design.FONT_BOLD28;
    self.sixMonthSubscriptionTitleLabel.text = TwinmeLocalizedString(@"in_app_subscription_view_controller_six_month_title", nil).uppercaseString;
    self.sixMonthSubscriptionTitleLabel.adjustsFontSizeToFitWidth = YES;
    
    self.sixMonthSubscriptionSubTitleLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.sixMonthSubscriptionSubTitleLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.sixMonthSubscriptionSubTitleLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.sixMonthSubscriptionSubTitleLabel.textColor = DESIGN_GREY_COLOR;
    self.sixMonthSubscriptionSubTitleLabel.font = Design.FONT_MEDIUM24;
    self.sixMonthSubscriptionSubTitleLabel.text = TwinmeLocalizedString(@"in_app_subscription_view_controller_subscription_title", nil).uppercaseString;
    self.sixMonthSubscriptionSubTitleLabel.adjustsFontSizeToFitWidth = YES;
    
    self.sixMonthSubscriptionDurationLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.sixMonthSubscriptionDurationLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.sixMonthSubscriptionDurationLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.sixMonthSubscriptionDurationLabel.textColor = [UIColor blackColor];
    self.sixMonthSubscriptionDurationLabel.font = Design.FONT_REGULAR88;
    self.sixMonthSubscriptionDurationLabel.text = @"6";
    
    self.sixMonthSubscriptionUnitLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.sixMonthSubscriptionUnitLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.sixMonthSubscriptionUnitLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.sixMonthSubscriptionUnitLabel.textColor = [UIColor blackColor];
    self.sixMonthSubscriptionUnitLabel.font = Design.FONT_REGULAR36;
    self.sixMonthSubscriptionUnitLabel.text = TwinmeLocalizedString(@"in_app_subscription_view_controller_month", nil);
    
    self.sixMonthSubscriptionPriceLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.sixMonthSubscriptionPriceLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.sixMonthSubscriptionPriceLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.sixMonthSubscriptionPriceLabel.textColor = [UIColor blackColor];
    self.sixMonthSubscriptionPriceLabel.font = Design.FONT_MEDIUM36;
    self.sixMonthSubscriptionPriceLabel.text = @"";
    
    self.sixMonthSubscriptionReductionLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.sixMonthSubscriptionReductionLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.sixMonthSubscriptionReductionLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.sixMonthSubscriptionReductionLabel.textColor = DESIGN_BEST_OFFER_COLOR;
    self.sixMonthSubscriptionReductionLabel.font = Design.FONT_BOLD28;
    self.sixMonthSubscriptionReductionLabel.text = @"";
    
    self.oneMonthSubscriptionViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.oneMonthSubscriptionView.hidden = YES;
    self.oneMonthSubscriptionView.layer.backgroundColor = [UIColor whiteColor].CGColor;
    self.oneMonthSubscriptionView.layer.cornerRadius = Design.CONTAINER_RADIUS;
    self.oneMonthSubscriptionView.layer.shadowOpacity = Design.SHADOW_OPACITY;
    self.oneMonthSubscriptionView.layer.shadowOffset = Design.SHADOW_OFFSET;
    self.oneMonthSubscriptionView.layer.shadowRadius = Design.SHADOW_RADIUS;
    self.oneMonthSubscriptionView.layer.shadowColor = UIColor.clearColor.CGColor;
    self.oneMonthSubscriptionView.layer.masksToBounds = NO;
    
    [self.oneMonthSubscriptionView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleOneMonthSubscriptionTapGesture:)]];
    
    self.oneMonthSubscriptionTitleLabelHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.oneMonthSubscriptionTitleLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.oneMonthSubscriptionTitleLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.oneMonthSubscriptionTitleLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.oneMonthSubscriptionTitleLabel.textColor = DESIGN_GREY_COLOR;
    self.oneMonthSubscriptionTitleLabel.font = Design.FONT_MEDIUM24;
    self.oneMonthSubscriptionTitleLabel.text = @"";
    
    self.oneMonthSubscriptionSubTitleLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.oneMonthSubscriptionSubTitleLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.oneMonthSubscriptionSubTitleLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.oneMonthSubscriptionSubTitleLabel.textColor = DESIGN_GREY_COLOR;
    self.oneMonthSubscriptionSubTitleLabel.font = Design.FONT_MEDIUM24;
    self.oneMonthSubscriptionSubTitleLabel.text = TwinmeLocalizedString(@"in_app_subscription_view_controller_subscription_title", nil).uppercaseString;
    self.oneMonthSubscriptionSubTitleLabel.adjustsFontSizeToFitWidth = YES;
    
    self.oneMonthSubscriptionDurationLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.oneMonthSubscriptionDurationLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.oneMonthSubscriptionDurationLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.oneMonthSubscriptionDurationLabel.textColor = [UIColor blackColor];
    self.oneMonthSubscriptionDurationLabel.font = Design.FONT_REGULAR88;
    self.oneMonthSubscriptionDurationLabel.text = @"1";
    
    self.oneMonthSubscriptionUnitLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.oneMonthSubscriptionUnitLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.oneMonthSubscriptionUnitLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.oneMonthSubscriptionUnitLabel.textColor = [UIColor blackColor];
    self.oneMonthSubscriptionUnitLabel.font = Design.FONT_REGULAR26;
    self.oneMonthSubscriptionUnitLabel.text = TwinmeLocalizedString(@"in_app_subscription_view_controller_month", nil);
    
    self.oneMonthSubscriptionPriceLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.oneMonthSubscriptionPriceLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.oneMonthSubscriptionPriceLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.oneMonthSubscriptionPriceLabel.textColor = [UIColor blackColor];
    self.oneMonthSubscriptionPriceLabel.font = Design.FONT_MEDIUM36;
    self.oneMonthSubscriptionPriceLabel.text = @"";
    
    self.freeTrialLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.freeTrialLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.freeTrialLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.freeTrialLabel.textColor = DESIGN_GREY_COLOR;
    self.freeTrialLabel.font = Design.FONT_MEDIUM40;
    self.freeTrialLabel.text = TwinmeLocalizedString(@"in_app_subscription_view_controller_free_trial", nil);
    self.freeTrialLabel.hidden = YES;
    
    self.subscribeViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.subscribeViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.subscribeViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.subscribeView.backgroundColor = DESIGN_SUBSCRIBE_COLOR;
    self.subscribeView.userInteractionEnabled = YES;
    self.subscribeView.layer.cornerRadius = Design.CONTAINER_RADIUS;
    self.subscribeView.clipsToBounds = YES;
    self.subscribeView.hidden = YES;
    [self.subscribeView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSubscribeTapGesture:)]];
    
    self.subscribeLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.subscribeLabel.font = Design.FONT_BOLD36;
    self.subscribeLabel.textColor = [UIColor whiteColor];
    self.subscribeLabel.text = TwinmeLocalizedString(@"in_app_subscription_view_controller_subscribe_title", nil).uppercaseString;
    self.subscribeLabel.adjustsFontSizeToFitWidth = YES;
    
    self.restoreViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.restoreViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.restoreView.userInteractionEnabled = YES;
    self.restoreView.hidden = YES;
    [self.restoreView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleRestoreTapGesture:)]];
    
    self.restoreLabel.font = Design.FONT_BOLD36;
    self.restoreLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.restoreLabel.text = TwinmeLocalizedString(@"in_app_subscription_view_controller_restore_title", nil).uppercaseString;
    
    self.inviteViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.inviteViewHeightConstraint.constant = 0;
    
    self.inviteView.userInteractionEnabled = YES;
    self.inviteView.hidden = YES;
    [self.inviteView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleInvitationTapGesture:)]];
    
    self.inviteLabel.font = Design.FONT_BOLD36;
    self.inviteLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.inviteLabel.text = TwinmeLocalizedString(@"add_contact_view_controller_title", nil).uppercaseString;
    
    self.footerLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.footerLabelBottomConstraint.constant *= Design.HEIGHT_RATIO;
    self.footerLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.footerLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.footerLabel.font = Design.FONT_REGULAR34;
    self.footerLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.footerLabel.hidden = YES;
    self.footerLabel.adjustsFontSizeToFitWidth = YES;
    
    self.footerLabel.text = [NSString stringWithFormat:@"%@ \n\n %@ - %@", TwinmeLocalizedString(@"in_app_subscription_view_controller_footer_message", nil), TwinmeLocalizedString(@"welcome_view_controller_terms_of_use", nil), TwinmeLocalizedString(@"welcome_view_controller_privacy_policy", nil)];
    
    NSString *termOfUse = TwinmeLocalizedString(@"welcome_view_controller_terms_of_use", nil);
    NSRange termOfUseRange = [self.footerLabel.text rangeOfString:termOfUse];
    NSURL *termOfUseURL = [NSURL URLWithString:TwinmeLocalizedString(@"welcome_view_controller_terms_of_use_url", nil)];
    self.footerLabel.enabledTextCheckingTypes = NSTextCheckingTypeLink;
    [self.footerLabel addLinkToURL:termOfUseURL withRange:termOfUseRange];
    NSString *privacyPolicy = TwinmeLocalizedString(@"welcome_view_controller_privacy_policy", nil);
    NSRange privacyPolicyRange = [self.footerLabel.text rangeOfString:privacyPolicy];
    NSURL *privacyPolicyURL = [NSURL URLWithString:TwinmeLocalizedString(@"welcome_view_controller_privacy_policy_url", nil)];
    [self.footerLabel addLinkToURL:privacyPolicyURL withRange:privacyPolicyRange];
    self.footerLabel.delegate = self;
    
    self.closeViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.closeViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.closeView.userInteractionEnabled = YES;
    [self.closeView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleCloseTapGesture:)]];
    
    self.closeImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.closeImageView.tintColor = Design.BLACK_COLOR;
    
    self.activityViewViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.activityViewViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.activityViewViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.activityView.backgroundColor = DESIGN_ACTIVITY_COLOR;
    self.activityView.clipsToBounds = YES;
    self.activityView.layer.cornerRadius = Design.CONTAINER_RADIUS;
    
    self.activityLabelBottomConstraint.constant *= Design.HEIGHT_RATIO;
    self.activityLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.activityLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.activityLabel.font = Design.FONT_REGULAR34;
    self.activityLabel.textColor = [UIColor whiteColor];
    self.activityLabel.text = TwinmeLocalizedString(@"in_app_subscription_view_controller_search", nil);
    
    self.activityIndicatorViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.activityIndicatorView.hidesWhenStopped = YES;
    self.activityIndicatorView.color = [UIColor whiteColor];
    [self.activityIndicatorView startAnimating];
    
    self.subscribedLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.subscribedLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.subscribedLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.subscribedLabel.font = Design.FONT_MEDIUM34;
    self.subscribedLabel.textColor = DESIGN_GREY_COLOR;
    self.subscribedLabel.text = TwinmeLocalizedString(@"side_menu_view_controller_subscribe_enable", nil);
    self.subscribedLabel.hidden = YES;
    
    self.premiumVersionImageHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.premiumVersionImageWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.premiumVersionImageTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.premiumVersionImage.hidden = YES;
}

- (void)finish {
    DDLogVerbose(@"%@ finish", LOG_TAG);
    
    [self.inAppSubscribeService dispose];
    self.inAppSubscribeService = nil;
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)handleDescriptionTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleDescriptionTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        
        if (self.descriptionStep == 1) {
            [self.progressBarOneView stopAnimation];
        } else if (self.descriptionStep == 2) {
            [self.progressBarTwoView stopAnimation];
        } else if (self.descriptionStep == 3) {
            [self.progressBarThreeView stopAnimation];
        } else {
            [self.progressBarFourView stopAnimation];
        }
        
        [self nextDescription];
    }
}

- (void)handleOneYearSubscriptionTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleOneYearSubscriptionTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        [self selectSubscription:ONE_YEAR_SUBSCRIPTION_ID];
    }
}

- (void)handleOneMonthSubscriptionTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleOneMonthSubscriptionTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        [self selectSubscription:ONE_MONTH_SUBSCRIPTION_ID];
    }
}

- (void)handleSixMonthSubscriptionTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleSixMonthSubscriptionTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        [self selectSubscription:SIX_MONTHS_SUBSCRIPTION_ID];
    }
}

- (void)handleSubscribeTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleSubscribeTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded && self.selectedProduct) {
        if (self.subscribeInProgress) {
            return;
        }
        
        if (!self.isAlreadySubscribed) {
            [self.inAppPurchaseManager subscribeProductWithProductId:self.selectedProduct.productIdentifier];
            self.subscribeInProgress = YES;
            [self updateViews];
        } else if ([self.twinmeApplication getInvitationSubscriptionTwincode]) {
            AlertView *alertView = [[AlertView alloc] initWithTitle:TwinmeLocalizedString(@"in_app_subscription_view_controller_cancel_subscription", nil) message:TwinmeLocalizedString(@"in_app_subscription_view_controller_cancel_subscription_confirmation", nil) cancelButtonTitle:TwinmeLocalizedString(@"application_cancel", nil) otherButtonTitles:TwinmeLocalizedString(@"application_ok", nil) alertViewDelegate:self];
            [alertView showInView:self.navigationController];
        } else {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://buy.itunes.apple.com/WebObjects/MZFinance.woa/wa/manageSubscriptions"] options:@{} completionHandler:nil];
        }
    }
}

- (void)handleRestoreTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleCloseTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        if (self.subscribeInProgress) {
            return;
        }
        self.subscribeInProgress = YES;
        [self updateViews];
        [self.inAppPurchaseManager restoreCompletedTransactions];
    }
}

- (void)handleCloseTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleCloseTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        [self finish];
    }
}

- (void)handleInvitationTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleInvitationTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        if (self.subscribeInProgress) {
            return;
        }
        
        InvitationSubscriptionViewController *invitationSubscriptionViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"InvitationSubscriptionViewController"];
        invitationSubscriptionViewController.invitationSubscriptionDelegate = self;
        [self.navigationController pushViewController:invitationSubscriptionViewController animated:YES];
    }
}

- (void)handleLaterTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleLaterTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        if (self.subscribeInProgress) {
            return;
        }
        
        [self finish];
    }
}

- (void)selectSubscription:(NSString *)productId {
    DDLogVerbose(@"%@ selectSubscription: %@", LOG_TAG, productId);
    
    if (self.subscribeInProgress) {
        return;
    }
    
    for (SKProduct *product in self.products) {
        if ([product.productIdentifier isEqualToString:productId]) {
            self.selectedProduct = product;
            break;
        }
    }
    
    [self updateViews];
}

- (void)updateProducts {
    DDLogVerbose(@"%@ updateProducts", LOG_TAG);
    
    if (self.products) {
        self.subscribeView.hidden = NO;
        
        if (!self.isAlreadySubscribed) {
            self.freeTrialLabel.hidden = NO;
            self.footerLabel.hidden = NO;
            self.laterView.hidden = NO;
            self.restoreView.hidden = NO;
            self.inviteView.hidden = YES;
        } else {
            if (self.subscriptionTwincode) {
                self.subscribeLabel.text = TwinmeLocalizedString(@"in_app_subscription_view_controller_cancel_subscription", nil).uppercaseString;
                if (self.subscriptionImage) {
                    self.premiumVersionImage.image = self.subscriptionImage;
                    self.premiumVersionImage.hidden = NO;
                }
            } else {
                self.subscribeLabel.text = TwinmeLocalizedString(@"in_app_subscription_view_controller_manage_subscription", nil).uppercaseString;
            }
            self.subscribedLabel.hidden = NO;
        }
        
        [self.activityIndicatorView stopAnimating];
        float oneMonthPrice = 0;
        float sixMonthPrice = 0;
        float oneYearPrice = 0;
        
        for (SKProduct *product in self.products) {
            
            if ([product.productIdentifier isEqual:ONE_YEAR_SUBSCRIPTION_ID]) {
                self.oneYearSubscriptionView.hidden = self.isAlreadySubscribed;
                self.oneYearSubscriptionPriceLabel.text = [self formatPrice:product];
                oneYearPrice = [product.price floatValue];
            } else if ([product.productIdentifier isEqual:SIX_MONTHS_SUBSCRIPTION_ID]) {
                self.sixMonthSubscriptionView.hidden = self.isAlreadySubscribed;
                self.sixMonthSubscriptionPriceLabel.text = [self formatPrice:product];
                sixMonthPrice = [product.price floatValue];
            } else if ([product.productIdentifier isEqual:ONE_MONTH_SUBSCRIPTION_ID]) {
                self.oneMonthSubscriptionView.hidden = self.isAlreadySubscribed;
                self.oneMonthSubscriptionPriceLabel.text = [self formatPrice:product];
                oneMonthPrice = [product.price floatValue];
            }
        }
        
        if (oneMonthPrice != 0 && sixMonthPrice != 0 && oneYearPrice != 0) {
            float sixMonthReduction = 1 - ((sixMonthPrice / 6) / oneMonthPrice);
            int sixMonthReductionPercent = sixMonthReduction * 100;
            float oneYearReduction = 1 - ((oneYearPrice / 12) / oneMonthPrice);
            int oneYearReductionPercent = oneYearReduction * 100;
            
            self.sixMonthSubscriptionReductionLabel.text = [NSString stringWithFormat:@"-%d%%", sixMonthReductionPercent];
            self.oneYearSubscriptionReductionLabel.text = [NSString stringWithFormat:@"-%d%%", oneYearReductionPercent];
        }
        
        if (!self.isAlreadySubscribed) {
            CGRect footerRect = [self.footerLabel.text boundingRectWithSize:CGSizeMake(Design.DISPLAY_WIDTH - self.footerLabelLeadingConstraint.constant * 2, MAXFLOAT) options:NSStringDrawingUsesFontLeading attributes:@{
                NSFontAttributeName : Design.FONT_REGULAR24
            } context:nil];
            
            self.containerViewHeightConstraint.constant = self.footerLabel.frame.origin.y + footerRect.size.height + self.footerLabelBottomConstraint.constant;
        } else {
            self.containerViewHeightConstraint.constant = Design.DISPLAY_HEIGHT;
        }
    }
}

- (NSString *)formatPrice:(SKProduct *)product {
    DDLogVerbose(@"%@ formatPrice: %@", LOG_TAG, product);
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle: NSNumberFormatterCurrencyStyle];
    [numberFormatter setLocale:product.priceLocale];
    return [numberFormatter stringFromNumber:[NSNumber numberWithDouble:[product.price doubleValue]]];
}

- (void)updateViews {
    DDLogVerbose(@"%@ updateViews", LOG_TAG);
    
    if (self.selectedProduct) {
        self.oneYearSubscriptionView.layer.shadowColor = UIColor.clearColor.CGColor;
        self.sixMonthSubscriptionView.layer.shadowColor = UIColor.clearColor.CGColor;
        self.oneMonthSubscriptionView.layer.shadowColor = UIColor.clearColor.CGColor;
        
        self.oneYearSubscriptionView.layer.backgroundColor = [UIColor clearColor].CGColor;
        self.sixMonthSubscriptionView.layer.backgroundColor = [UIColor clearColor].CGColor;
        self.oneMonthSubscriptionView.layer.backgroundColor = [UIColor clearColor].CGColor;
        
        self.oneMonthSubscriptionPriceLabel.textColor = Design.BLACK_COLOR;
        self.oneMonthSubscriptionUnitLabel.textColor = Design.BLACK_COLOR;
        self.oneMonthSubscriptionDurationLabel.textColor = Design.BLACK_COLOR;
        
        self.sixMonthSubscriptionPriceLabel.textColor = Design.BLACK_COLOR;
        self.sixMonthSubscriptionUnitLabel.textColor = Design.BLACK_COLOR;
        self.sixMonthSubscriptionDurationLabel.textColor = Design.BLACK_COLOR;
        
        self.oneYearSubscriptionPriceLabel.textColor = Design.BLACK_COLOR;
        self.oneYearSubscriptionUnitLabel.textColor = Design.BLACK_COLOR;
        self.oneYearSubscriptionDurationLabel.textColor = Design.BLACK_COLOR;
        
        if ([self.selectedProduct.productIdentifier isEqualToString:ONE_YEAR_SUBSCRIPTION_ID]) {
            self.oneYearSubscriptionView.layer.shadowColor = Design.SHADOW_COLOR.CGColor;
            self.oneYearSubscriptionView.layer.backgroundColor = [UIColor whiteColor].CGColor;
            
            if ([Design isDarkMode]) {
                self.oneYearSubscriptionPriceLabel.textColor = [UIColor blackColor];
                self.oneYearSubscriptionUnitLabel.textColor = [UIColor blackColor];
                self.oneYearSubscriptionDurationLabel.textColor = [UIColor blackColor];
            }
        } else if ([self.selectedProduct.productIdentifier isEqualToString:SIX_MONTHS_SUBSCRIPTION_ID]) {
            self.sixMonthSubscriptionView.layer.shadowColor = Design.SHADOW_COLOR.CGColor;
            self.sixMonthSubscriptionView.layer.backgroundColor = [UIColor whiteColor].CGColor;
            
            if ([Design isDarkMode]) {
                self.sixMonthSubscriptionPriceLabel.textColor = [UIColor blackColor];
                self.sixMonthSubscriptionUnitLabel.textColor = [UIColor blackColor];
                self.sixMonthSubscriptionDurationLabel.textColor = [UIColor blackColor];
            }
        } else if ([self.selectedProduct.productIdentifier isEqualToString:ONE_MONTH_SUBSCRIPTION_ID]) {
            self.oneMonthSubscriptionView.layer.shadowColor = Design.SHADOW_COLOR.CGColor;
            self.oneMonthSubscriptionView.layer.backgroundColor = [UIColor whiteColor].CGColor;
            
            if ([Design isDarkMode]) {
                self.oneMonthSubscriptionPriceLabel.textColor = [UIColor blackColor];
                self.oneMonthSubscriptionUnitLabel.textColor = [UIColor blackColor];
                self.oneMonthSubscriptionDurationLabel.textColor = [UIColor blackColor];
            }
        }
    }
    
    if (self.subscribeInProgress) {
        self.oneYearSubscriptionView.alpha = 0.5f;
        self.sixMonthSubscriptionView.alpha = 0.5f;
        self.oneMonthSubscriptionView.alpha = 0.5f;
        self.subscribeView.alpha = 0.5f;
        self.laterView.alpha = 0.5f;
        self.freeTrialLabel.alpha = 0.5f;
        self.descriptionView.alpha = 0.5f;
        self.laterView.alpha = 0.5f;
        self.restoreView.alpha = 0.5f;
        self.inviteView.alpha = 0.5f;
        
        [self.activityIndicatorView startAnimating];
        self.activityView.hidden = NO;
        self.activityLabel.text = TwinmeLocalizedString(@"in_app_subscription_view_controller_subscribe_in_progress", nil);
    } else {
        self.oneYearSubscriptionView.alpha = 1.f;
        self.sixMonthSubscriptionView.alpha = 1.f;
        self.oneMonthSubscriptionView.alpha = 1.f;
        self.subscribeView.alpha = 1.f;
        self.laterView.alpha = 1.f;
        self.freeTrialLabel.alpha = 1.f;
        self.descriptionView.alpha = 1.f;
        self.laterView.alpha = 1.f;
        self.restoreView.alpha = 1.f;
        self.inviteView.alpha = 1.f;
        self.activityView.hidden = YES;
        
        if ([self.activityIndicatorView isAnimating]) {
            [self.activityIndicatorView stopAnimating];
        }
    }
}

- (void)nextDescription {
    DDLogVerbose(@"%@ nextDescription", LOG_TAG);
    
    self.descriptionStep++;
    
    if (self.descriptionStep > 4) {
        self.descriptionStep = 1;
        [self.progressBarOneView resetAnimation];
        [self.progressBarTwoView resetAnimation];
        [self.progressBarThreeView resetAnimation];
        [self.progressBarFourView resetAnimation];
    }
    
    NSString *title = @"";
    NSString *subTitle = @"";
    NSString *image = @"";
    
    CGFloat imageBottomMargin = DESIGN_IMAGE_BOTTOM_MARGN * Design.HEIGHT_RATIO;
    
    if (self.descriptionStep == 1) {
        [self.progressBarOneView startAnimation];
        title = TwinmeLocalizedString(@"in_app_subscription_view_controller_description_step1_title", nil);
        subTitle = TwinmeLocalizedString(@"in_app_subscription_view_controller_description_step1_subtitle", nil);
        image = @"InAppStep1";
        imageBottomMargin = 0;
    } else if (self.descriptionStep == 2) {
        [self.progressBarTwoView startAnimation];
        title = TwinmeLocalizedString(@"in_app_subscription_view_controller_description_step2_title", nil);
        subTitle = TwinmeLocalizedString(@"in_app_subscription_view_controller_description_step2_subtitle", nil);
        image = @"InAppStep2";
    } else if (self.descriptionStep == 3) {
        [self.progressBarThreeView startAnimation];
        title = TwinmeLocalizedString(@"in_app_subscription_view_controller_description_step3_title", nil);
        subTitle = TwinmeLocalizedString(@"in_app_subscription_view_controller_description_step3_subtitle", nil);
        image = @"InAppStep3";
    } else {
        [self.progressBarFourView startAnimation];
        title = TwinmeLocalizedString(@"in_app_subscription_view_controller_description_step4_title", nil);
        subTitle = TwinmeLocalizedString(@"in_app_subscription_view_controller_description_step4_subtitle", nil);
        image = @"InAppStep4";
    }
    
    self.descriptionImageViewBottomConstraint.constant = imageBottomMargin;
    
    self.titleLabel.text = title;
    self.descriptionLabel.text = subTitle;
    self.descriptionImageView.image = [UIImage imageNamed:image];
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    self.laterLabel.font = Design.FONT_BOLD36;
    self.titleLabel.font = Design.FONT_MEDIUM36;
    self.descriptionLabel.font = Design.FONT_MEDIUM32;
    self.oneYearSubscriptionTitleLabel.font = Design.FONT_BOLD28;
    self.oneYearSubscriptionSubTitleLabel.font = Design.FONT_BOLD28;
    self.oneYearSubscriptionDurationLabel.font = Design.FONT_REGULAR88;
    self.oneYearSubscriptionUnitLabel.font = Design.FONT_REGULAR32;
    self.oneYearSubscriptionPriceLabel.font = Design.FONT_MEDIUM38;
    self.oneYearSubscriptionReductionLabel.font = Design.FONT_BOLD34;
    self.sixMonthSubscriptionTitleLabel.font = Design.FONT_BOLD28;
    self.sixMonthSubscriptionSubTitleLabel.font = Design.FONT_BOLD28;
    self.sixMonthSubscriptionDurationLabel.font = Design.FONT_REGULAR88;
    self.sixMonthSubscriptionUnitLabel.font = Design.FONT_REGULAR32;
    self.sixMonthSubscriptionPriceLabel.font = Design.FONT_MEDIUM38;
    self.sixMonthSubscriptionReductionLabel.font = Design.FONT_BOLD34;
    self.oneMonthSubscriptionTitleLabel.font = Design.FONT_BOLD28;
    self.oneMonthSubscriptionSubTitleLabel.font = Design.FONT_BOLD28;
    self.oneMonthSubscriptionDurationLabel.font = Design.FONT_REGULAR88;
    self.oneMonthSubscriptionUnitLabel.font = Design.FONT_REGULAR32;
    self.oneMonthSubscriptionPriceLabel.font = Design.FONT_MEDIUM38;
    self.subscribeLabel.font = Design.FONT_BOLD36;
    self.laterLabel.font = Design.FONT_BOLD32;
    self.restoreLabel.font = Design.FONT_BOLD32;
    self.inviteLabel.font = Design.FONT_BOLD32;
    self.footerLabel.font = Design.FONT_REGULAR34;
    self.freeTrialLabel.font = Design.FONT_MEDIUM36;
    self.skredPlusLabel.font = Design.FONT_BOLD54;
    self.activityLabel.font = Design.FONT_REGULAR34;
    self.subscribedLabel.font = Design.FONT_MEDIUM34;
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    self.closeImageView.tintColor = Design.BLACK_COLOR;
    self.footerLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.laterLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.restoreLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.inviteLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.skredPlusLabel.textColor = Design.FONT_COLOR_DEFAULT;
    
    if ([Design isDarkMode]) {
        [self.descriptionView setBackgroundColor:DESIGN_BACKGROUND_DARK_COLOR];
        self.titleLabel.textColor = [UIColor whiteColor];
        self.descriptionLabel.textColor = [UIColor whiteColor];
    } else {
        [self.descriptionView setupGradientBackgroundFromColors:@[(id)DESIGN_TOP_COLOR.CGColor, (id)DESIGN_BOTTOM_COLOR.CGColor]];
        self.titleLabel.textColor = [UIColor blackColor];
        self.descriptionLabel.textColor = DESIGN_DESCRIPTION_COLOR;
    }
}

@end
