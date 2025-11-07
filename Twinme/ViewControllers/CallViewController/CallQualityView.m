/*
 *  Copyright (c) 2022 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import "CallQualityView.h"

#import <Utils/NSString+Utils.h>

#import <TwinmeCommon/Design.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

//
// Interface: CallQualityView ()
//

@interface CallQualityView ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *popupViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *popupViewWidthConstraint;
@property (weak, nonatomic) IBOutlet UIView *popupView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *starOneImageViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *starOneImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *starOneImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *starTwoImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *starTwoImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *starThreeImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *starThreeImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *starFourImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *starFourImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sendButtonHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sendButtonWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sendButtonBottomConstraint;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *closeImageViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *closeImageViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *closeImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *closeImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *closeViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *closeViewWidthConstraint;
@property (weak, nonatomic) IBOutlet UIView *closeView;

@property (nonatomic) UIView *backgroundView;

@property (weak, nonatomic) id<CallQualityViewDelegate> callQualityViewDelegate;

@property int callQuality;

@end

//
// Implementation: MenuRoomMemberView
//

#undef LOG_TAG
#define LOG_TAG @"MenuRoomMemberView"

@implementation CallQualityView

#pragma mark - UIView

- (instancetype)initWithDelegate:(id<CallQualityViewDelegate>)callQualityViewDelegate {
    DDLogVerbose(@"%@ initWithDelegate: %@", LOG_TAG, callQualityViewDelegate);
    
    self = [super init];
    
    if (self) {
        _callQuality = 4;
        _callQualityViewDelegate = callQualityViewDelegate;
    }
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

#pragma mark - Private methods

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    self.view.backgroundColor = [UIColor clearColor];
        
    self.popupViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.popupViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    
    self.popupView.clipsToBounds = YES;
    self.popupView.backgroundColor = Design.POPUP_BACKGROUND_COLOR;
    CALayer *poupViewLayer = self.popupView.layer;
    poupViewLayer.cornerRadius = Design.POPUP_RADIUS;
    
    self.starOneImageViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.starOneImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.starOneImageView.userInteractionEnabled = YES;
    self.starOneImageView.isAccessibilityElement = YES;
    UITapGestureRecognizer *starOneGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleStarTapGesture:)];
    [self.starOneImageView addGestureRecognizer:starOneGestureRecognizer];
    
    self.starTwoImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.starTwoImageView.userInteractionEnabled = YES;
    self.starTwoImageView.isAccessibilityElement = YES;
    UITapGestureRecognizer *starTwoGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleStarTapGesture:)];
    [self.starTwoImageView addGestureRecognizer:starTwoGestureRecognizer];
    
    self.starThreeImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.starThreeImageView.userInteractionEnabled = YES;
    self.starThreeImageView.isAccessibilityElement = YES;
    UITapGestureRecognizer *starThreeGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleStarTapGesture:)];
    [self.starThreeImageView addGestureRecognizer:starThreeGestureRecognizer];
    
    self.starFourImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.starFourImageView.userInteractionEnabled = YES;
    self.starFourImageView.isAccessibilityElement = YES;
    UITapGestureRecognizer *starFourGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleStarTapGesture:)];
    [self.starFourImageView addGestureRecognizer:starFourGestureRecognizer];
    
    self.titleLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.titleLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    
    self.titleLabel.font = Design.FONT_MEDIUM34;
    self.titleLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.titleLabel.text = TwinmeLocalizedString(@"call_view_controller_quality_title", nil);
    
    self.messageLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.messageLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    
    self.messageLabel.font = Design.FONT_MEDIUM32;
    self.messageLabel.textColor = Design.FONT_COLOR_DESCRIPTION;
    self.messageLabel.text = TwinmeLocalizedString(@"call_view_controller_quality_message", nil);
    
    self.sendButtonHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.sendButtonWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.sendButtonBottomConstraint.constant *= Design.HEIGHT_RATIO;
    
    [self.sendButton setTitle:TwinmeLocalizedString(@"feedback_view_controller_send", nil) forState:UIControlStateNormal];
    [self.sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.sendButton setBackgroundColor:Design.BLUE_NORMAL];
    [self.sendButton.titleLabel setFont:Design.FONT_BOLD28];
    CALayer *sendButtonLayer = self.sendButton.layer;
    sendButtonLayer.cornerRadius = 6.f;
    
    self.closeImageViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.closeImageViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.closeImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
        
    self.closeViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.closeViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    
    self.closeView.userInteractionEnabled = YES;
    self.closeView.isAccessibilityElement = YES;
    self.closeView.accessibilityLabel = TwinmeLocalizedString(@"application_cancel", nil);
    UITapGestureRecognizer *closeGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleCloseTapGesture:)];
    [self.closeView addGestureRecognizer:closeGestureRecognizer];
    
    [self updateStars];
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

- (void)closeCallQualityView {
    DDLogVerbose(@"%@ closeCallQualityView", LOG_TAG);
    
    [self.backgroundView removeFromSuperview];
    [self removeFromParentViewController];
    [self.view removeFromSuperview];
}

- (IBAction)sendAction:(id)sender {
    DDLogVerbose(@"%@ sendAction", LOG_TAG);
    
    if ([self.callQualityViewDelegate respondsToSelector:@selector(sendCallQuality:)]) {
        [self.callQualityViewDelegate sendCallQuality:self.callQuality];
        [self closeCallQualityView];
    }
}

- (void)handleCloseTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleBackTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        [self.callQualityViewDelegate closeCallQuality];
        [self closeCallQualityView];
    }
}

- (void)handleStarTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleStarTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        
        if (sender.view == self.starOneImageView) {
            self.callQuality = 1;
        } else if (sender.view == self.starTwoImageView) {
            self.callQuality = 2;
        } else if (sender.view == self.starThreeImageView) {
            self.callQuality = 3;
        } else if (sender.view == self.starFourImageView) {
            self.callQuality = 4;
        }
        
        [self updateStars];
    }
}

- (void)updateStars {
    DDLogVerbose(@"%@ updateStars", LOG_TAG);
    
    self.starOneImageView.image = self.callQuality > 0 ? [UIImage imageNamed:@"StarBlue"]:[UIImage imageNamed:@"StarGrey"];
    self.starTwoImageView.image = self.callQuality > 1 ? [UIImage imageNamed:@"StarBlue"]:[UIImage imageNamed:@"StarGrey"];
    self.starThreeImageView.image = self.callQuality > 2 ? [UIImage imageNamed:@"StarBlue"]:[UIImage imageNamed:@"StarGrey"];
    self.starFourImageView.image = self.callQuality > 3 ? [UIImage imageNamed:@"StarBlue"]:[UIImage imageNamed:@"StarGrey"];
}

@end
