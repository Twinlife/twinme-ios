/*
 *  Copyright (c) 2016-2020 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Chedi Baccari (Chedi.Baccari@twinlife-systems.com)
 *   Christian Jacquemot (Christian.Jacquemot@twinlife-systems.com)
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#include <Twinlife/TLConnectivityService.h>

#import <Utils/NSString+Utils.h>

#import "AlertView.h"
#import <TwinmeCommon/Design.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

#define CONNECT_DELAY 10 // s

//
// Interface: AlertView ()
//

@interface AlertView ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *popupViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *popupViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *popupViewWidthConstraint;
@property (weak, nonatomic) IBOutlet UIView *popupView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLabelHeigthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLabelTopConstraint;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageLabelHeigthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageLabeTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageLabelBottomConstraint;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cancelButtonHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cancelButtonWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cancelButtonBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cancelButtonLeadingConstraint;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *acceptButtonWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *acceptButtonHeigthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *acceptButtonBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *acceptButtonTrailingConstraint;
@property (weak, nonatomic) IBOutlet UIButton *acceptButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *closeImageViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *closeImageViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *closeImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *closeImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *closeViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *closeViewWidthConstraint;
@property (weak, nonatomic) IBOutlet UIView *closeView;

@property (nonatomic) UIView *backgroundView;

@property (weak, nonatomic) id<AlertViewDelegate> alertViewDelegate;
@property (nonatomic) NSString* cancelButtonTitle;
@property (nonatomic) NSString* acceptButtonTitle;
@property (nonatomic) NSString* messageText;
@property (nonatomic) NSString* titleText;

@property (nonatomic) UIViewController *viewController;
@property (nonatomic) NSTimer *networkConnectTimer;

@property (nonatomic) BOOL isConnected;

@end

//
// Implementation: AlertView
//

#undef LOG_TAG
#define LOG_TAG @"AlertView"

@implementation AlertView

- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles alertViewDelegate:(id<AlertViewDelegate>)alertViewDelegate {
    DDLogVerbose(@"%@ initWithTitle: %@ message: %@ cancelButtonTitle: %@ otherButtonTitles: %@ alertViewDelegate: %@", LOG_TAG, title, message, cancelButtonTitle, otherButtonTitles, alertViewDelegate);
    
    self = [super init];
    
    if (self) {
        _titleText = title;
        _messageText  = message;
        _cancelButtonTitle = cancelButtonTitle;
        _acceptButtonTitle = otherButtonTitles;
        
        _alertViewDelegate = alertViewDelegate;
    }
    return self;
}

- (instancetype)initNetWorkAlertWithTitle:(NSString *)title alertViewDelegate:(id<AlertViewDelegate>)alertViewDelegate twinmeContext:(TLTwinmeContext *)twinmeContext viewController:(UIViewController *)viewController {
    
    _isConnected = [[twinmeContext getConnectivityService] isConnectedNetwork];
    
    NSString* message;
    if (_isConnected) {
        message = TwinmeLocalizedString(@"application_network_status_connected_no_internet", nil);
    } else {
        message = TwinmeLocalizedString(@"application_network_status_no_internet", nil);
    }
    
    self.viewController = viewController;
    
    self = [self initWithTitle:title message:message cancelButtonTitle:TwinmeLocalizedString(@"application_ok", nil) otherButtonTitles:nil alertViewDelegate:alertViewDelegate];
    
    return self;
}

- (void)viewDidLoad {
    DDLogVerbose(@"%@ viewDidLoad", LOG_TAG);
    
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    DDLogVerbose(@"%@ viewWillAppear", LOG_TAG);
    
    [super viewWillAppear:animated];
}

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    self.view.backgroundColor = [UIColor clearColor];
    
    self.popupViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.popupViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.popupViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    
    self.popupView.backgroundColor = Design.POPUP_BACKGROUND_COLOR;
    self.popupView.clipsToBounds = YES;
    CALayer *poupViewLayer = self.popupView.layer;
    poupViewLayer.cornerRadius = Design.POPUP_RADIUS;
    
    self.titleLabelHeigthConstraint.constant *= Design.HEIGHT_RATIO;
    self.titleLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.titleLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    [self.titleLabel setFont:Design.FONT_REGULAR34];
    self.titleLabel.text = self.titleText;
    self.titleLabel.textColor = Design.FONT_COLOR_DEFAULT;
    
    self.messageLabelHeigthConstraint.constant *= Design.HEIGHT_RATIO;
    self.messageLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.messageLabeTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.messageLabelBottomConstraint.constant *= Design.HEIGHT_RATIO;
    [self.messageLabel setFont:Design.FONT_REGULAR32];
    self.messageLabel.textColor = Design.FONT_COLOR_GREY;
    self.messageLabel.text = self.messageText;
    
    self.cancelButtonHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.cancelButtonWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.cancelButtonBottomConstraint.constant *= Design.HEIGHT_RATIO;
    self.cancelButtonLeadingConstraint.constant *= Design.WIDTH_RATIO;
    [self.cancelButton setTitle:self.cancelButtonTitle forState:UIControlStateNormal];
    [self.cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.cancelButton setBackgroundColor:Design.BUTTON_RED_COLOR];
    [self.cancelButton.titleLabel setFont:Design.FONT_BOLD28];
    CALayer *cancelButtonLayer = self.cancelButton.layer;
    cancelButtonLayer.cornerRadius = 6.f;
    
    self.acceptButtonWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.acceptButtonHeigthConstraint.constant *= Design.HEIGHT_RATIO;
    self.acceptButtonBottomConstraint.constant *= Design.HEIGHT_RATIO;
    self.acceptButtonTrailingConstraint.constant *= Design.WIDTH_RATIO;
    [self.acceptButton setTitle:self.acceptButtonTitle forState:UIControlStateNormal];
    [self.acceptButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.acceptButton setBackgroundColor:Design.BLUE_NORMAL];
    [self.acceptButton.titleLabel setFont:Design.FONT_BOLD28];
    CALayer *acceptButtonLayer = self.acceptButton.layer;
    acceptButtonLayer.cornerRadius = 6.f;
    
    if(!self.acceptButtonTitle) {
        [self.acceptButton setHidden:YES];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.cancelButtonWidthConstraint.constant = self.popupViewWidthConstraint.constant - (self.cancelButtonLeadingConstraint.constant * 2);
        });
    }
    
    self.closeImageViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.closeImageViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.closeImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.closeViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.closeViewWidthConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.closeView.userInteractionEnabled = YES;
    self.closeView.isAccessibilityElement = YES;
    self.closeView.accessibilityLabel = TwinmeLocalizedString(@"application_cancel", nil);
    UITapGestureRecognizer *closeGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleCloseTapGesture:)];
    [self.closeView addGestureRecognizer:closeGestureRecognizer];
}

- (void)showNetworkAlertView {
    DDLogVerbose(@"%@ showNetworkAlertView", LOG_TAG);
    
    // If we have the network, give some time to connect to Twinme server and raise the alert after a delay.
    if (self.isConnected) {
        self.networkConnectTimer = [NSTimer scheduledTimerWithTimeInterval:CONNECT_DELAY target:self selector:@selector(networkTimeout:) userInfo:nil repeats:NO];
    } else {
        [self showInView:self.viewController];
    }
}

- (void)showInView:(UIViewController *)view {
    DDLogVerbose(@"%@ showAlertInView", LOG_TAG);
    
    self.backgroundView = [[UIView alloc]initWithFrame:view.view.bounds];
    self.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.backgroundView.alpha = .3f;
    self.backgroundView.backgroundColor = [UIColor blackColor];
    
    [view.view insertSubview:self.backgroundView atIndex:0];
    [view.view bringSubviewToFront:self.backgroundView];
    
    self.view.frame = view.view.frame;
    [view addChildViewController:self];
    [view.view addSubview:self.view];
    [self didMoveToParentViewController:view];
    
    [self initViews];
    
    self.view.alpha = 0.;
    [UIView animateWithDuration:.2 animations:^{
        self.view.alpha = 1.;
    } completion:^(BOOL finished) {
    }];
}

- (void)closeAlertView {
    DDLogVerbose(@"%@ closeAlertView", LOG_TAG);
    
    [self.backgroundView removeFromSuperview];
    [self removeFromParentViewController];
    [self.view removeFromSuperview];
}

- (IBAction)acceptAction:(id)sender {
    DDLogVerbose(@"%@ acceptAction", LOG_TAG);
    
    [self closeAlertView];
    if ([self.alertViewDelegate respondsToSelector:@selector(handleAcceptButtonClick:)]) {
        [self.alertViewDelegate handleAcceptButtonClick:self];
    }
}

- (IBAction)cancelAction:(id)sender {
    DDLogVerbose(@"%@ cancelAction", LOG_TAG);
    
    [self closeAlertView];
    if ([self.alertViewDelegate respondsToSelector:@selector(handleCancelButtonClick:)]) {
        [self.alertViewDelegate handleCancelButtonClick:self];
    }
}

- (void)handleCloseTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleCloseTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        [self closeAlertView];
        if ([self.alertViewDelegate respondsToSelector:@selector(handleCloseButtonClick:)]) {
            [self.alertViewDelegate handleCloseButtonClick:self];
        }
    }
}

- (void)dispose {
    DDLogVerbose(@"%@ dispose", LOG_TAG);
    
    if (self.networkConnectTimer) {
        [self.networkConnectTimer invalidate];
        self.networkConnectTimer = nil;
    } else {
        [self closeAlertView];
    }
}

- (void)networkTimeout:(NSTimer *)timer {
    DDLogVerbose(@"%@ networkTimeout: %@", LOG_TAG, timer);
    
    [self showInView:self.viewController];
    self.networkConnectTimer = nil;
}

@end
